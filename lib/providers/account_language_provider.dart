import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_provider.dart';
import 'locale_provider.dart';

/// Keep-alive: keeps the app language and the account's (`users.language`) in
/// step, the way the web does.
/// - A language picked in the app is saved on the account
///   (`PATCH /auth/me`); until that succeeds it stays pending.
/// - At sign-in a pending choice is saved; otherwise the app takes the
///   account's language from `/auth/me`.
final accountLanguageSyncProvider = Provider<void>((ref) {
  bool signedIn() => ref.read(authStateProvider) is AuthAuthenticated;

  Future<void> save(String language) async {
    try {
      await ref
          .read(apiClientProvider)
          .patch<void>('/auth/me', data: {'language': language}, fromJson: (_) {});
      await ref.read(localeProvider.notifier).markSaved(language);
    } catch (e) {
      debugPrint('Account language save failed: $e'); // stays pending
    }
  }

  Future<void> onSignIn() async {
    final notifier = ref.read(localeProvider.notifier);
    await notifier.loaded;
    if (!signedIn()) return;
    if (notifier.pending) return save(ref.read(localeProvider).languageCode);
    try {
      final user = await ref.read(authRepositoryProvider).getCurrentUser();
      final match = supportedAppLocales.where((l) => l.languageCode == user?.language);
      if (match.isNotEmpty && signedIn()) await notifier.adopt(match.first);
    } catch (e) {
      debugPrint('Account language read failed: $e'); // keep the app's
    }
  }

  ref.listen<Locale>(localeProvider, (prev, next) {
    if (prev?.languageCode == next.languageCode) return;
    if (signedIn() && ref.read(localeProvider.notifier).pending) save(next.languageCode);
  });
  ref.listen<AuthState>(authStateProvider, (prev, next) {
    if (next is AuthAuthenticated && prev is! AuthAuthenticated) onSignIn();
  });
});
