import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tamir_uy_mobile_flutter/features/room_scan/models/captured_room.dart';
import 'package:tamir_uy_mobile_flutter/features/room_scan/pending_scan_store.dart';
import 'package:tamir_uy_mobile_flutter/features/room_scan/room_scan_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory docs;
  late Directory tmp;
  final sampleJson =
      File('test/features/room_scan/fixtures/captured_room_sample.json').readAsStringSync();

  ScanResult scan(String json, String name) {
    final f = File('${tmp.path}/$name.usdz')..writeAsBytesSync([1, 2, 3]);
    return ScanResult(
      room: parseCapturedRoom(const {}),
      rawJson: json,
      usdzPath: f.path,
      version: 'roomplan-1',
    );
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    docs = await Directory.systemTemp.createTemp('docs');
    tmp = await Directory.systemTemp.createTemp('scan');
    PendingScanStore.documentsDir = () async => docs;
  });

  test('save two rooms, then load', () async {
    await PendingScanStore.saveFlat(MultiScanResult(
        rooms: [scan(sampleJson, 'a'), scan(sampleJson, 'b')], partial: false));
    expect(await PendingScanStore.hasPendingFlat(), isTrue);
    final loaded = await PendingScanStore.loadFlat();
    expect(loaded!.drafts.length, 2);
    expect(loaded.scans.length, 2);
    expect(File(loaded.scans[1].usdzPath).existsSync(), isTrue);
  });

  test('clearFlat forgets the set and its files', () async {
    await PendingScanStore.saveFlat(
        MultiScanResult(rooms: [scan(sampleJson, 'a')], partial: false));
    await PendingScanStore.clearFlat();
    expect(await PendingScanStore.hasPendingFlat(), isFalse);
    expect(docs.listSync().whereType<File>().where((f) => f.path.endsWith('.usdz')), isEmpty);
  });

  test('a saved set with one invalid room loads with 1 draft', () async {
    await PendingScanStore.saveFlat(MultiScanResult(
        rooms: [scan(sampleJson, 'a'), scan('{"walls": []}', 'b')], partial: false));
    final loaded = await PendingScanStore.loadFlat();
    expect(loaded!.drafts.length, 1);
    expect(loaded.scans.length, 1);
  });

  test('the single-room slot is separate', () async {
    await PendingScanStore.saveFlat(
        MultiScanResult(rooms: [scan(sampleJson, 'a')], partial: false));
    expect(await PendingScanStore.hasPending(), isFalse);
  });
}
