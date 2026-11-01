import 'dart:async';
import 'dart:ui' show Locale;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../repositories/push_repository.dart';
import 'firebase_setup.dart';

/// The slice of FirebaseMessaging the push lifecycle needs.
abstract class MessagingClient {
  Future<String?> getToken();
  Stream<String> get onTokenRefresh;
  Future<void> deleteToken();
}

class FirebaseMessagingClient implements MessagingClient {
  FirebaseMessaging get _m => FirebaseMessaging.instance;

  @override
  Future<String?> getToken() => _m.getToken();
  @override
  Stream<String> get onTokenRefresh => _m.onTokenRefresh;
  @override
  Future<void> deleteToken() => _m.deleteToken();
}

/// Used when Firebase did not initialise: every call is a no-op.
class NoopMessagingClient implements MessagingClient {
  @override
  Future<String?> getToken() async => null;
  @override
  Stream<String> get onTokenRefresh => const Stream<String>.empty();
  @override
  Future<void> deleteToken() async {}
}

/// Keeps the backend's list of this phone's push token current. A push failure
/// must never break sign-in or logout, so every error is logged and swallowed.
class PushService {
  PushService(
    this._messaging,
    this._repo, {
    required this.locale,
    required this.platform,
    this.timeout = const Duration(seconds: 4),
  });

  final MessagingClient _messaging;
  final PushRepository _repo;
  final String Function() locale;
  final String platform;

  /// Upper bound on the network-bound parts of sign-out, so an offline phone
  /// never stalls logout.
  final Duration timeout;
  StreamSubscription<String>? _refreshSub;

  Future<void> registerCurrent() async {
    try {
      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) return;
      await _repo.register(token, platform, locale());
    } catch (e) {
      debugPrint('Push register failed: $e');
    }
  }

  void listenForRefresh() {
    _refreshSub?.cancel();
    _refreshSub = _messaging.onTokenRefresh.listen((token) async {
      try {
        await _repo.register(token, platform, locale());
      } catch (e) {
        debugPrint('Push re-register failed: $e');
      }
    });
  }

  void stopListening() {
    _refreshSub?.cancel();
    _refreshSub = null;
  }

  /// Signed-out path: remove the token on the server, then locally.
  Future<void> unregister() async {
    stopListening();
    try {
      await () async {
        final token = await _messaging.getToken();
        if (token != null && token.isNotEmpty) await _repo.unregister(token);
      }()
          .timeout(timeout);
    } catch (e) {
      debugPrint('Push unregister failed: $e');
    }
    await discardLocalToken();
  }

  /// Dead-session path (401 / account deleted): the server cannot be reached
  /// as this user any more, so only drop the token on this phone.
  Future<void> discardLocalToken() async {
    stopListening();
    try {
      await _messaging.deleteToken().timeout(timeout);
    } catch (e) {
      debugPrint('Push deleteToken failed: $e');
    }
  }
}

String pushLocaleCode(String languageCode) =>
    const {'uz', 'ru', 'en'}.contains(languageCode) ? languageCode : 'uz';

final pushServiceProvider = Provider<PushService>((ref) {
  final ready = ref.watch(firebaseReadyProvider);
  final service = PushService(
    ready ? FirebaseMessagingClient() : NoopMessagingClient(),
    PushRepository(ref.watch(apiClientProvider)),
    locale: () => pushLocaleCode(ref.read(localeProvider).languageCode),
    platform: defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
  );
  ref.onDispose(service.stopListening);
  return service;
});

/// Keep-alive: while signed in, the phone's token is registered with the
/// backend and re-registered when it rotates.
final pushRegistrationProvider = Provider<void>((ref) {
  final service = ref.read(pushServiceProvider);
  var active = false;

  void apply(AuthState state) {
    if (state is AuthAuthenticated) {
      if (active) return;
      active = true;
      service.registerCurrent();
      service.listenForRefresh();
    } else if (active) {
      active = false;
      service.stopListening();
    }
  }

  apply(ref.read(authStateProvider));
  ref.listen<AuthState>(authStateProvider, (_, next) => apply(next));
  // Pushes are written in the language the token was registered with, so a
  // language change registers it again.
  ref.listen<Locale>(localeProvider, (prev, next) {
    if (active && prev?.languageCode != next.languageCode) {
      service.registerCurrent();
    }
  });
});
