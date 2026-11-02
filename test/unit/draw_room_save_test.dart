import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/screens/room_setup/draw_room_screen.dart';

void main() {
  test('a saved room opens the Studio', () async {
    final opened = <String>[];
    expect(await saveDrawnRoom(() async => 'r1', onSaved: opened.add), isTrue);
    expect(opened, ['r1']);
  });

  test('no room id is a failure, not a silent detour', () async {
    final opened = <String>[];
    expect(await saveDrawnRoom(() async => null, onSaved: opened.add), isFalse);
    expect(opened, isEmpty);
  });

  test('a thrown save is a failure', () async {
    final opened = <String>[];
    expect(await saveDrawnRoom(() async => throw Exception('offline'), onSaved: opened.add), isFalse);
    expect(opened, isEmpty);
  });
}
