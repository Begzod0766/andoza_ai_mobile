import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// One phone input for every form that takes an Uzbek contact number
/// (checkout, master booking, shop and usta profiles, business application):
/// phone keyboard, autofill, and "+998 90 123 45 67" as you type. The
/// controller holds that whole text, so `normalizeUzPhone(controller.text)`
/// from `utils/phone.dart` reads it. (Login has its own +998 box design.)
class PhoneField extends StatelessWidget {
  const PhoneField({
    required this.controller,
    this.label,
    this.hint = '+998 90 123 45 67',
    this.errorText,
    this.onChanged,
    this.textInputAction,
    this.border,
    super.key,
  });

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final InputBorder? border;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.phone,
      autofillHints: const [AutofillHints.telephoneNumber],
      inputFormatters: [UzPhoneInputFormatter()],
      textInputAction: textInputAction,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        // The hint/example number doesn't always fit one line.
        errorMaxLines: 2,
        border: border,
      ),
    );
  }
}

/// Keeps the text as "+998 XX XXX XX XX": the prefix comes with the first
/// digit, a pasted number in any shape ("998901234567", "(90) 123-45-67") is
/// regrouped, at most nine national digits, and deleting them all empties
/// the field.
class UzPhoneInputFormatter extends TextInputFormatter {
  static final _nonDigits = RegExp(r'\D');

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final raw = newValue.text.trim();
    var digits = raw.replaceAll(_nonDigits, '');
    // The prefix's own "998", or a full number typed/pasted with it.
    if (raw.startsWith('+998') || (digits.length > 9 && digits.startsWith('998'))) {
      digits = digits.substring(3);
    }
    if (digits.length > 9) digits = digits.substring(0, 9);
    if (digits.isEmpty) return const TextEditingValue();

    final out = StringBuffer('+998 ');
    for (var i = 0; i < digits.length; i++) {
      if (i == 2 || i == 5 || i == 7) out.write(' ');
      out.write(digits[i]);
    }
    final text = out.toString();
    return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}
