import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/l10n/app_localizations.dart';

// Mobile QA 2026-11-18: the Russian wizard showed a door as «70×200 sm»; the
// unit was hard-coded in Uzbek.
void main() {
  test('a door or window size reads in the app language', () {
    expect(lookupAppLocalizations(const Locale('uz')).openingSizeCm('70', '200'), '70×200 sm');
    expect(lookupAppLocalizations(const Locale('ru')).openingSizeCm('70', '200'), '70×200 см');
    expect(lookupAppLocalizations(const Locale('en')).openingSizeCm('70', '200'), '70×200 cm');
  });
}
