import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_setup.dart';

/// The notification permission, behind an interface so tests can fake it.
abstract class PushPermission {
  /// Asks the OS (Android 13+ POST_NOTIFICATIONS, iOS). True if granted.
  Future<bool> request();
  Future<bool> isGranted();
}

class FirebasePushPermission implements PushPermission {
  static bool _ok(NotificationSettings s) =>
      s.authorizationStatus == AuthorizationStatus.authorized ||
      s.authorizationStatus == AuthorizationStatus.provisional;

  @override
  Future<bool> request() async {
    try {
      return _ok(await FirebaseMessaging.instance.requestPermission());
    } catch (e) {
      debugPrint('Push permission request failed: $e');
      return false;
    }
  }

  @override
  Future<bool> isGranted() async {
    try {
      return _ok(await FirebaseMessaging.instance.getNotificationSettings());
    } catch (e) {
      debugPrint('Push permission check failed: $e');
      return false;
    }
  }
}

/// Used when Firebase did not initialise: never granted.
class NoopPushPermission implements PushPermission {
  @override
  Future<bool> request() async => false;
  @override
  Future<bool> isGranted() async => false;
}

final pushPermissionProvider = Provider<PushPermission>((ref) {
  return ref.watch(firebaseReadyProvider)
      ? FirebasePushPermission()
      : NoopPushPermission();
});
