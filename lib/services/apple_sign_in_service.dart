import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// What "Sign in with Apple" hands back: the identity token the backend
/// verifies, and the person's name — which Apple shares only on the very first
/// authorization for this app, so it must be forwarded then or never.
class AppleCredential {
  const AppleCredential({required this.identityToken, this.name});

  final String identityToken;
  final String? name;
}

/// Thin wrapper over the `sign_in_with_apple` plugin, like
/// [GoogleSignInService]: the login screen only asks for a credential, and
/// tests swap it via [appleSignInServiceProvider].
class AppleSignInService {
  const AppleSignInService();

  /// Offered on iOS only. App Store guideline 4.8 wants it next to Google
  /// sign-in there; on Android it would need a web service id and a redirect.
  static bool get isAvailable => isAvailableFor(defaultTargetPlatform);

  @visibleForTesting
  static bool isAvailableFor(TargetPlatform platform) =>
      platform == TargetPlatform.iOS;

  /// Runs the native Apple sheet and returns the credential, or `null` when
  /// the user dismisses it. Other failures throw.
  Future<AppleCredential?> getCredential() async {
    try {
      final c = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final token = c.identityToken;
      if (token == null || token.isEmpty) {
        throw StateError('Apple sign-in returned no identity token');
      }
      return AppleCredential(
        identityToken: token,
        name: fullName(c.givenName, c.familyName),
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) return null;
      rethrow;
    }
  }

  @visibleForTesting
  static String? fullName(String? given, String? family) {
    final name = [
      given,
      family,
    ].map((p) => p?.trim() ?? '').where((p) => p.isNotEmpty).join(' ');
    return name.isEmpty ? null : name;
  }
}

final appleSignInServiceProvider = Provider<AppleSignInService>(
  (ref) => const AppleSignInService(),
);
