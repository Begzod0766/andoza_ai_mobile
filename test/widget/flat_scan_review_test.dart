import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tamir_uy_mobile_flutter/features/room_scan/models/captured_room.dart';
import 'package:tamir_uy_mobile_flutter/features/room_scan/room_scan_service.dart';
import 'package:tamir_uy_mobile_flutter/l10n/app_localizations.dart';
import 'package:tamir_uy_mobile_flutter/models/api/api.dart';
import 'package:tamir_uy_mobile_flutter/providers/apartment_provider.dart';
import 'package:tamir_uy_mobile_flutter/providers/room_persistence_provider.dart';
import 'package:tamir_uy_mobile_flutter/repositories/apartment_repository.dart';
import 'package:tamir_uy_mobile_flutter/screens/scanning/flat_scan_review_page.dart';
import 'package:tamir_uy_mobile_flutter/services/api_client.dart';

import '../features/room_scan/flat_layout_test.dart' show box;

RoomOut _room(String id) =>
    RoomOut(id: id, apartmentId: 'a1', name: 'x', updatedAt: DateTime(2026));

class _FakePersistence extends RoomPersistenceNotifier {
  _FakePersistence(super.ref);
  @override
  Future<void> ensurePersisted({RoomCreate? override}) async {
    state = AsyncValue.data(PersistedRoom(clientRoomId: 'c', room: _room('r1')));
  }
}

class _FakeRepo extends ApartmentRepository {
  _FakeRepo({this.failCreate = false}) : super(ApiClient(baseUrl: 'http://test'));
  final bool failCreate;
  final names = <String, String>{};
  var _n = 1;
  @override
  Future<RoomOut> createRoom(String apartmentId, RoomCreate body) async {
    if (failCreate) throw Exception('HTTP 500');
    return _room('r${++_n}');
  }

  @override
  Future<List<RoomOut>> listRooms(String apartmentId) async => const [];
  @override
  Future<RoomOut> updateRoom(String roomId,
      {String? name,
      double? ceilingH,
      Map<String, dynamic>? geometry,
      Map<String, dynamic>? surfaces,
      List<dynamic>? furnitureLayout,
      Map<String, dynamic>? state}) async {
    if (name != null) names[roomId] = name;
    return _room(roomId);
  }
}

class _RecordingScan implements RoomScanService {
  final groups = <String, String?>{};
  final thumbnails = <String>[];
  @override
  Future<Map<String, dynamic>> upload(String roomId, ScanResult scan, {String? scanGroup}) async {
    groups[roomId] = scanGroup;
    return {};
  }

  @override
  Future<Map<String, dynamic>> uploadThumbnail(String roomId, Uint8List png) async {
    thumbnails.add(roomId);
    return {};
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _scan = ScanResult(
    room: CapturedRoom(), rawJson: '{}', usdzPath: '/tmp/x.usdz', version: 'roomplan-1');

Uri? _lastStudio;

Future<(_RecordingScan scan, _FakeRepo repo)> _pump(
    WidgetTester tester, FlatScanReviewArgs args, {_FakeRepo? repo}) async {
  _lastStudio = null;
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final scan = _RecordingScan();
  repo ??= _FakeRepo();
  final router = GoRouter(initialLocation: '/review', routes: [
    GoRoute(path: '/review', builder: (_, _) => FlatScanReviewPage(args: args)),
    GoRoute(
      path: '/studio/:roomId',
      builder: (_, state) {
        _lastStudio = state.uri;
        return Scaffold(body: Text('studio ${state.pathParameters['roomId']}'));
      },
    ),
  ]);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      roomPersistenceProvider.overrideWith((r) => _FakePersistence(r)),
      apartmentRepositoryProvider.overrideWithValue(repo),
      roomScanServiceProvider.overrideWithValue(scan),
    ],
    child: MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('uz'),
      routerConfig: router,
    ),
  ));
  await tester.pumpAndSettle();
  return (scan, repo);
}

void main() {
  testWidgets('flat review lists every room and opens the studio on the first',
      (tester) async {
    final args = FlatScanReviewArgs(
        drafts: [box(4, 3), box(3, 3, ox: 4.1)], scans: const [_scan, _scan]);
    final (scan, repo) = await _pump(tester, args);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('1-xona'), findsOneWidget);
    expect(find.text('2-xona'), findsOneWidget);

    final go = find.text('Studiyada ochish');
    await tester.runAsync(() async {
      await tester.tap(go);
      await Future<void>.delayed(const Duration(milliseconds: 500));
    });
    await tester.pumpAndSettle();

    expect(find.text('studio r1'), findsOneWidget);
    expect(_lastStudio!.queryParameters.containsKey('focus'), isFalse);
    expect(scan.groups.keys, ['r1', 'r2']);
    expect(scan.groups['r1'], isNotNull);
    expect(scan.groups['r1'], scan.groups['r2']);
    expect(repo.names, {'r1': '1-xona', 'r2': '2-xona'});
  });

  testWidgets('flat review shows the partial and dropped notices', (tester) async {
    await _pump(
        tester,
        FlatScanReviewArgs(
            drafts: [box(4, 3)], scans: const [_scan], partial: true, dropped: 2));
    expect(find.text("Skaner to'xtadi — 1 ta xona saqlandi"), findsOneWidget);
    expect(find.text("2 ta xona o'qilmadi va qo'shilmadi"), findsOneWidget);
  });

  testWidgets('rooms that could not be saved are reported', (tester) async {
    final args = FlatScanReviewArgs(
        drafts: [box(4, 3), box(3, 3, ox: 4.1), box(3, 3, ox: 7.2)],
        scans: const [_scan, _scan, _scan]);
    await _pump(tester, args, repo: _FakeRepo(failCreate: true));
    await tester.runAsync(() async {
      await tester.tap(find.text('Studiyada ochish'));
      await Future<void>.delayed(const Duration(milliseconds: 500));
    });
    await tester.pumpAndSettle();
    expect(find.text('studio r1'), findsOneWidget);
    expect(find.text('3 ta xonadan 1 tasi saqlandi — qolganlarini qayta skanerlang'),
        findsOneWidget);
  });
}
