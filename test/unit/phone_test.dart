import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/utils/phone.dart';

// The cases the web app and the backend agree on (MOBILE_QA_HANDOFF.md, 1.3).
void main() {
  group('isUzPhone', () {
    test('accepts an Uzbek number however it is spaced', () {
      expect(isUzPhone('+998 90 123-45-67'), isTrue);
      expect(isUzPhone('998901234567'), isTrue);
      expect(isUzPhone('+998 (90) 123 45 67'), isTrue);
    });

    test('refuses anything else', () {
      expect(isUzPhone('12'), isFalse);
      expect(isUzPhone('abc'), isFalse);
      expect(isUzPhone('+7 999 123 45 67'), isFalse);
      expect(isUzPhone('+998 90 123 45 6'), isFalse);
      expect(isUzPhone(''), isFalse);
    });
  });

  group('normalizeUzPhone', () {
    test('gives the +998XXXXXXXXX form the API stores', () {
      expect(normalizeUzPhone('+998 90 123-45-67'), '+998901234567');
      expect(normalizeUzPhone('998901234567'), '+998901234567');
    });

    test('is null for a blank or wrong number', () {
      expect(normalizeUzPhone(''), isNull);
      expect(normalizeUzPhone('12'), isNull);
    });
  });

  group('isPhoneBlank', () {
    test('an empty field or the bare "+998" prefix is no number', () {
      expect(isPhoneBlank(''), isTrue);
      expect(isPhoneBlank('  '), isTrue);
      expect(isPhoneBlank('+998'), isTrue);
      expect(isPhoneBlank('+998 '), isTrue);
      expect(isPhoneBlank('+'), isTrue);
    });

    test('anything typed after the prefix is a number to check', () {
      expect(isPhoneBlank('+998 9'), isFalse);
      expect(isPhoneBlank('abc'), isFalse);
    });
  });
}
