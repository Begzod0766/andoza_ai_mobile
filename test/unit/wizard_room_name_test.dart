import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/l10n/app_localizations.dart';
import 'package:tamir_uy_mobile_flutter/utils/room_type_size.dart';

// Mobile QA 2026-11-18: every room from the wizard was called «Ремонт
// гостиной», a bathroom and a kitchen too. A picked type names the room.
void main() {
  final ru = lookupAppLocalizations(const Locale('ru'));
  final uz = lookupAppLocalizations(const Locale('uz'));

  test('a picked type names the room in the app language', () {
    expect(wizardRoomName(ru, 'hammom'), ru.roomHammom);
    expect(wizardRoomName(ru, 'oshxona'), ru.roomOshxona);
    expect(wizardRoomName(uz, 'yotoqxona'), uz.roomYotoqxona);
  });

  test('without a type the old default name stays', () {
    expect(wizardRoomName(ru, null), ru.roomSetupDefaultProjectName);
  });
}
