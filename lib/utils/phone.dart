/// The rule the API applies to every contact phone it stores
/// (`normalize_contact_phone` in the backend's `app/schemas/auth.py`): an
/// Uzbek number, +998 and nine digits, with spaces, dashes and brackets
/// ignored. Checked before sending so a form can say what is wrong instead of
/// a generic 422, and so a shop or an usta is never handed a number it cannot
/// call. The web app's copy is `frontend/src/lib/phone.ts`.
library;

final _separators = RegExp(r'[\s\-()]');
final _uzPhone = RegExp(r'^\+?998\d{9}$');

/// True for "+998 90 123-45-67", "998901234567"; false for "12", "abc",
/// "+7 999 123 45 67" and for a blank value.
bool isUzPhone(String value) =>
    _uzPhone.hasMatch(value.replaceAll(_separators, ''));

/// [value] as +998XXXXXXXXX, or null when it is blank or not an Uzbek number.
/// Blank means "not given", the same as the backend.
String? normalizeUzPhone(String value) {
  final compact = value.replaceAll(_separators, '');
  if (!_uzPhone.hasMatch(compact)) return null;
  return compact.startsWith('+') ? compact : '+$compact';
}

/// True when [value] holds no number: empty, or only the "+998" a field is
/// prefilled with.
bool isPhoneBlank(String value) {
  final rest = value.replaceAll(_separators, '').replaceFirst('+', '');
  return rest.isEmpty || rest == '998';
}
