import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/utils/phone.dart';
import 'package:tamir_uy_mobile_flutter/widgets/common/phone_field.dart';

String _fmt(String oldText, String newText) => UzPhoneInputFormatter()
    .formatEditUpdate(TextEditingValue(text: oldText), TextEditingValue(text: newText))
    .text;

void main() {
  group('UzPhoneInputFormatter', () {
    test('the first digit brings the +998 prefix', () {
      expect(_fmt('', '9'), '+998 9');
    });

    test('groups as people write it', () {
      expect(_fmt('+998 90 123 45 6', '+998 90 123 45 67'), '+998 90 123 45 67');
      expect(_fmt('+998 90', '+998 901'), '+998 90 1');
    });

    test('a pasted number in any shape', () {
      expect(_fmt('', '+998901234567'), '+998 90 123 45 67');
      expect(_fmt('', '998 (90) 123-45-67'), '+998 90 123 45 67');
      expect(_fmt('', '901234567'), '+998 90 123 45 67');
    });

    test('a national number starting with 99 keeps its digits', () {
      expect(_fmt('+998 9', '+998 99'), '+998 99');
      expect(_fmt('+998 99', '+998 998'), '+998 99 8');
    });

    test('nine digits at most; deleting everything empties the field', () {
      expect(_fmt('+998 90 123 45 67', '+998 90 123 45 678'), '+998 90 123 45 67');
      expect(_fmt('+998 9', '+998 '), '');
    });

    test('the result is what normalizeUzPhone accepts', () {
      expect(normalizeUzPhone(_fmt('', '901234567')), '+998901234567');
    });
  });

  testWidgets('PhoneField: phone keyboard, autofill, formats as you type', (tester) async {
    final c = TextEditingController();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: PhoneField(controller: c, label: 'Telefon')),
    ));
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.keyboardType, TextInputType.phone);
    expect(field.autofillHints, contains(AutofillHints.telephoneNumber));
    await tester.enterText(find.byType(TextField), '901234567');
    expect(c.text, '+998 90 123 45 67');
    expect(find.text('Telefon'), findsOneWidget);
  });
}
