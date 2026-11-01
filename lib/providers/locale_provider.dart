import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefsKeyLocale = 'app_locale';
const _prefsKeyPending = 'app_locale_pending';

/// The three languages the app ships with. Order here drives the language
/// picker's display order.
const supportedAppLocales = [
  Locale('uz'),
  Locale('ru'),
  Locale('en'),
];

/// The supported language matching [system] (the phone's first language),
/// else Uzbek.
Locale appLocaleFor(Locale system) => supportedAppLocales.firstWhere(
      (l) => l.languageCode == system.languageCode,
      orElse: () => supportedAppLocales.first,
    );

/// The app language: the one the user picked, else the phone's when the app
/// has it, else Uzbek.
final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);

class LocaleNotifier extends Notifier<Locale> {
  /// A language picked in the app that the account has not saved yet (no
  /// session then, or the save failed). Until it is saved it beats the
  /// account's language at sign-in, the way the web does.
  bool pending = false;

  /// Completes once the persisted choice (if any) has loaded.
  late Future<void> loaded;

  bool _touched = false;

  @override
  Locale build() {
    // The phone's language until the persisted choice (if any) loads.
    loaded = _loadPersisted();
    return appLocaleFor(PlatformDispatcher.instance.locale);
  }

  Future<void> _loadPersisted() async {
    final prefs = await _prefs();
    if (prefs == null || _touched) return;
    pending = prefs.getBool(_prefsKeyPending) ?? false;
    final code = prefs.getString(_prefsKeyLocale);
    final match = supportedAppLocales.where((l) => l.languageCode == code);
    if (match.isNotEmpty) state = match.first;
  }

  /// The user picked [locale] in the app: it waits to be saved on the account.
  Future<void> setLocale(Locale locale) => _set(locale, pending: true);

  /// The account's language, taken over at sign-in.
  Future<void> adopt(Locale locale) => _set(locale, pending: false);

  /// The account has saved [languageCode].
  Future<void> markSaved(String languageCode) async {
    if (state.languageCode != languageCode) return; // changed again meanwhile
    pending = false;
    await (await _prefs())?.setBool(_prefsKeyPending, false);
  }

  Future<void> _set(Locale locale, {required bool pending}) async {
    _touched = true;
    this.pending = pending;
    state = locale;
    final prefs = await _prefs();
    await prefs?.setString(_prefsKeyLocale, locale.languageCode);
    await prefs?.setBool(_prefsKeyPending, pending);
  }

  Future<SharedPreferences?> _prefs() async {
    try {
      return await SharedPreferences.getInstance();
    } catch (_) {
      return null; // No storage (e.g. a plain Dart test).
    }
  }
}
