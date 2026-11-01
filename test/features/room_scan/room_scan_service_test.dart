import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/features/room_scan/models/captured_room.dart';
import 'package:tamir_uy_mobile_flutter/features/room_scan/room_scan_service.dart';
import 'package:tamir_uy_mobile_flutter/services/api_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late RoomScanService service;

  void mock(Future<Object?>? Function(MethodCall) handler) {
    messenger.setMockMethodCallHandler(RoomScanService.channel, handler);
  }

  setUp(() => service = RoomScanService(apiClient: ApiClient(baseUrl: 'http://test')));
  tearDown(() => messenger.setMockMethodCallHandler(RoomScanService.channel, null));

  group('checkSupport', () {
    test('reports supported', () async {
      mock((call) async {
        expect(call.method, 'isSupported');
        return <String, dynamic>{'supported': true, 'reason': null};
      });
      final s = await service.checkSupport();
      expect(s.supported, isTrue);
      expect(s.reason, isNull);
    });

    test('reports unsupported with a reason', () async {
      mock((call) async => <String, dynamic>{'supported': false, 'reason': 'no_lidar'});
      final s = await service.checkSupport();
      expect(s.supported, isFalse);
      expect(s.reason, 'no_lidar');
    });

    test('checkSupport reads multiRoom', () async {
      mock((call) async =>
          <String, dynamic>{'supported': true, 'reason': null, 'multiRoom': true});
      final s = await service.checkSupport();
      expect(s.multiRoom, isTrue);
    });

    test('checkSupport defaults multiRoom to false', () async {
      mock((call) async => <String, dynamic>{'supported': true, 'reason': null});
      final s = await service.checkSupport();
      expect(s.multiRoom, isFalse);
    });

    test('no native handler (Android) → not_implemented, never throws', () async {
      // No mock handler installed → MissingPluginException path.
      final s = await service.checkSupport();
      expect(s.supported, isFalse);
      expect(s.reason, 'not_implemented');
    });
  });

  group('scan', () {
    final sampleJson = jsonEncode(<String, dynamic>{
      'walls': <dynamic>[],
      'doors': <dynamic>[],
      'windows': <dynamic>[],
      'openings': <dynamic>[],
      'objects': <dynamic>[],
    });

    test('returns a parsed ScanResult', () async {
      mock((call) async {
        expect(call.method, 'scanRoom');
        // The scanner's texts travel with the call, in the app's language.
        expect(call.arguments, {
          'labels': {'cancel': 'Отмена'},
        });
        return <String, dynamic>{
          'json': sampleJson,
          'usdzPath': '/tmp/scan.usdz',
          'version': 'roomplan-1',
        };
      });
      final r = await service.scan(labels: const {'cancel': 'Отмена'});
      expect(r, isNotNull);
      expect(r!.usdzPath, '/tmp/scan.usdz');
      expect(r.version, 'roomplan-1');
      expect(r.room.walls, isEmpty);
    });

    test('cancel → null', () async {
      mock((call) async => null);
      expect(await service.scan(labels: const {}), isNull);
    });

    test('busy → RoomScanException(busy)', () async {
      mock((call) async =>
          throw PlatformException(code: 'busy', message: 'already scanning'));
      await expectLater(
        service.scan(labels: const {}),
        throwsA(isA<RoomScanException>().having((e) => e.code, 'code', 'busy')),
      );
    });

    test('scan_failed → RoomScanException(scan_failed)', () async {
      mock((call) async => throw PlatformException(code: 'scan_failed'));
      await expectLater(
        service.scan(labels: const {}),
        throwsA(isA<RoomScanException>()
            .having((e) => e.code, 'code', 'scan_failed')),
      );
    });
  });

  group('scanRooms', () {
    final roomJson = jsonEncode(<String, dynamic>{
      'walls': <dynamic>[],
      'doors': <dynamic>[],
      'windows': <dynamic>[],
      'openings': <dynamic>[],
      'objects': <dynamic>[],
    });
    const labels = {'nextRoom': 'Next', 'finish': 'Finish', 'cancel': 'Cancel', 'roomN': 'Room {n}'};

    test('scanRooms parses every room', () async {
      mock((call) async {
        expect(call.method, 'scanRooms');
        expect((call.arguments as Map)['labels'], labels);
        return <String, dynamic>{
          'rooms': [
            {'json': roomJson, 'usdzPath': '/tmp/a.usdz'},
            {'json': roomJson, 'usdzPath': '/tmp/b.usdz'},
          ],
          'version': 'roomplan-1',
          'partial': false,
        };
      });
      final r = await service.scanRooms(labels: labels);
      expect(r!.rooms.length, 2);
      expect(r.partial, isFalse);
      expect(r.rooms[0].version, 'roomplan-1');
      expect(r.rooms[1].usdzPath, '/tmp/b.usdz');
    });

    test('scanRooms returns null on cancel', () async {
      mock((call) async => null);
      expect(await service.scanRooms(labels: labels), isNull);
    });

    test('scanRooms keeps partial', () async {
      mock((call) async => <String, dynamic>{
            'rooms': [
              {'json': roomJson, 'usdzPath': '/tmp/a.usdz'},
            ],
            'version': 'roomplan-1',
            'partial': true,
          });
      final r = await service.scanRooms(labels: labels);
      expect(r!.partial, isTrue);
      expect(r.rooms.length, 1);
    });

    test('scanRooms maps busy', () async {
      mock((call) async => throw PlatformException(code: 'busy'));
      await expectLater(
        service.scanRooms(labels: labels),
        throwsA(isA<RoomScanException>().having((e) => e.code, 'code', 'busy')),
      );
    });
  });

  group('upload scan_group', () {
    late _RecordingApi api;
    late ScanResult scan;

    setUp(() async {
      api = _RecordingApi();
      final dir = await Directory.systemTemp.createTemp('scan');
      final file = File('${dir.path}/a.usdz')..writeAsBytesSync([1, 2, 3]);
      scan = ScanResult(
        room: parseCapturedRoom(const {}),
        rawJson: '{}',
        usdzPath: file.path,
        version: 'roomplan-1',
      );
    });

    test('upload sends scan_group', () async {
      await RoomScanService(apiClient: api).upload('r1', scan, scanGroup: 'g1');
      expect(api.fields?['scan_group'], 'g1');
      expect(api.fields?['room_json'], '{}');
    });

    test('upload omits scan_group when null', () async {
      await RoomScanService(apiClient: api).upload('r1', scan);
      expect(api.fields!.containsKey('scan_group'), isFalse);
    });
  });

  group('scanObject (Phase 6)', () {
    test('returns the usdz path', () async {
      mock((call) async {
        expect(call.method, 'scanObject');
        return <String, dynamic>{'usdzPath': '/tmp/object.usdz'};
      });
      expect(await service.scanObject(), '/tmp/object.usdz');
    });

    test('cancel → null', () async {
      mock((call) async => null);
      expect(await service.scanObject(), isNull);
    });

    test('not_implemented (no handler) → RoomScanException', () async {
      await expectLater(
        service.scanObject(),
        throwsA(isA<RoomScanException>()
            .having((e) => e.code, 'code', 'not_implemented')),
      );
    });
  });
}

class _RecordingApi extends ApiClient {
  _RecordingApi() : super(baseUrl: 'http://test');
  Map<String, String>? fields;

  @override
  Future<T> uploadFile<T>(
    String path, {
    required List<int> bytes,
    required String filename,
    String fieldName = 'file',
    String? contentType,
    Map<String, String> fields = const {},
    required T Function(dynamic) fromJson,
  }) async {
    this.fields = fields;
    return fromJson(<String, dynamic>{});
  }
}
