import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/features/room_scan/room_scan_service.dart';
import 'package:tamir_uy_mobile_flutter/l10n/app_localizations_en.dart';

void main() {
  test('every text the native scanner shows is sent, in the app language', () {
    final labels = roomScanLabels(AppLocalizationsEn());
    // The keys RoomScanLabels (ios/Runner/RoomScan) reads.
    expect(labels.keys, unorderedEquals([
      'nextRoom', 'finish', 'cancel', 'done', 'roomN', 'start', 'moveCloser',
      'moveAway', 'slowDown', 'turnOnLight', 'lowTexture', 'good', 'keepGoing',
    ]));
    expect(labels['good'], 'Going well — keep walking around the room at this pace');
    expect(labels['roomN'], contains('{n}'));
    expect(labels.values.every((v) => v.isNotEmpty), isTrue);
  });
}
