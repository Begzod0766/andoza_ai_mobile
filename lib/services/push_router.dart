import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../config/router.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import 'firebase_setup.dart';
import 'local_notifications.dart';

/// Routes a push is allowed to open. Anything else opens Home.
final _allowedPushRoutes = <RegExp>[
  RegExp(r'^/studio/[0-9a-f-]{36}$'),
  RegExp(r'^/profile/e6$'),
  RegExp(r'^/masters/u3$'),
];

/// The route to open for a push's data, or '/' if it isn't one we allow.
String safePushRoute(Map<String, dynamic> data) {
  final route = data['route'];
  if (route is! String) return '/';
  return _allowedPushRoutes.any((r) => r.hasMatch(route)) ? route : '/';
}

/// A push route tapped while signed out (or before the session was restored).
/// The router's redirect opens it after sign-in and clears it.
final pendingPushRouteProvider = StateProvider<String?>((ref) => null);

/// Reads a provider; `Ref.read`, `WidgetRef.read` and `ProviderContainer.read`
/// all fit.
typedef ProviderReader = T Function<T>(ProviderListenable<T> provider);

/// Opens the screen a tapped notification points at: system notifications
/// (cold start and background) and our own foreground ones.
class PushTapHandler {
  PushTapHandler(this._read, {this.navigate});

  final ProviderReader _read;

  /// Opens a route; [attach] sets it to the app router's `go`.
  void Function(String route)? navigate;
  final _subs = <StreamSubscription<Object?>>[];

  /// Opens [raw] (re-checked against the allow-list) if signed in, otherwise
  /// keeps it for after sign-in.
  void openRoute(String? raw) {
    final route = safePushRoute({'route': raw});
    final go = navigate;
    if (_read(authStateProvider) is AuthAuthenticated && go != null) {
      go(route);
    } else {
      _read(pendingPushRouteProvider.notifier).state = route;
    }
  }

  void openMessage(RemoteMessage message) =>
      openRoute(safePushRoute(message.data));

  /// Wires FirebaseMessaging and local notifications to [router]. Only call
  /// when Firebase is ready.
  Future<void> attach(
    GoRouter router,
    LocalNotifications local, {
    String? channelName,
  }) async {
    navigate = router.go;
    try {
      await local.init(onTap: openRoute, channelName: channelName);
      _subs.add(FirebaseMessaging.onMessageOpenedApp.listen(openMessage));
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        // iOS shows nothing for a push that arrives while the app is open
        // unless told to; a re-post through local notifications was dropped
        // too (shouldPresentAlert: NO). Let the system show the push itself:
        // one banner, and a tap comes back through onMessageOpenedApp.
        await FirebaseMessaging.instance
            .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      } else {
        // Android never shows an FCM notification in the foreground.
        _subs.add(FirebaseMessaging.onMessage.listen(local.showForeground));
      }
      final initial = await FirebaseMessaging.instance.getInitialMessage();
      if (initial != null) {
        openMessage(initial);
      } else {
        final launchRoute = await local.launchPayload();
        if (launchRoute != null) openRoute(launchRoute);
      }
    } catch (e) {
      debugPrint('Push tap setup failed: $e');
    }
  }

  void detach() {
    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();
  }
}

/// Keep-alive: when Firebase is up, shows foreground pushes and opens the
/// right screen for tapped ones. Without Firebase it does nothing.
final pushNotificationsProvider = Provider<void>((ref) {
  if (!ref.watch(firebaseReadyProvider)) return;
  final handler = PushTapHandler(ref.read);
  handler.attach(
    ref.read(routerProvider),
    LocalNotifications(),
    channelName: lookupAppLocalizations(
      ref.read(localeProvider),
    ).pushChannelName,
  );
  ref.onDispose(handler.detach);
});
