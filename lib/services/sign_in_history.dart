import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Whether this device has ever been signed in to a registered account.
///
/// Decides the cold start when there is no session: a device that has (the
/// user signed out or deleted the account) shows the login screen; a fresh
/// one opens a silent guest session. Set on every registered sign-in, never
/// cleared. Not a secret, so `shared_preferences`, not secure storage.
class SignInHistory {
  static const _key = 'auth.hasSignedInBefore';

  Future<bool> hasSignedInBefore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_key) ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> markSignedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, true);
    } catch (_) {
      // Best effort: the worst case is a silent guest instead of /login.
    }
  }
}

final signInHistoryProvider = Provider<SignInHistory>((ref) => SignInHistory());
