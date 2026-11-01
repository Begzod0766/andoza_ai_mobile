import 'dart:io';

import 'package:tamir_uy_mobile_flutter/services/pdf_share_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const shareChannel = MethodChannel('dev.fluttercommunity.plus/share');
  const pathChannel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory tmp;
  final calls = <MethodCall>[];

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('pdf_share_test');
    calls.clear();
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(pathChannel, (call) async => tmp.path);
    messenger.setMockMethodCallHandler(shareChannel, (call) async {
      calls.add(call);
      return 'dev.fluttercommunity.plus/share/unavailable';
    });
  });

  tearDown(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(pathChannel, null);
    messenger.setMockMethodCallHandler(shareChannel, null);
    tmp.deleteSync(recursive: true);
  });

  test('writes the PDF and shares it from the given origin', () async {
    const origin = Rect.fromLTWH(16, 700, 180, 48);

    final path = await sharePdfBytes(
      [1, 2, 3],
      fileName: 'smeta_Oshxona',
      shareText: 'AndozaAI smeta — Oshxona',
      origin: origin,
    );

    expect(path, '${tmp.path}/smeta_Oshxona.pdf');
    expect(File(path).readAsBytesSync(), [1, 2, 3]);
    expect(calls, hasLength(1));
    final args = calls.single.arguments as Map;
    expect(calls.single.method, 'shareFiles');
    expect(args['paths'], [path]);
    expect(args['mimeTypes'], ['application/pdf']);
    expect(args['text'], 'AndozaAI smeta — Oshxona');
    // iOS 26 throws when the origin is missing or zero-sized.
    expect(args['originX'], 16);
    expect(args['originY'], 700);
    expect(args['originWidth'], 180);
    expect(args['originHeight'], 48);
  });

  test('keeps an existing .pdf extension', () async {
    final path = await sharePdfBytes(
      [0],
      fileName: 'smeta.pdf',
      origin: const Rect.fromLTWH(0, 0, 10, 10),
    );
    expect(path, '${tmp.path}/smeta.pdf');
  });
}
