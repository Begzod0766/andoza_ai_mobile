import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../firebase_options.dart';

/// Whether [initFirebase] succeeded; overridden in `main` with its result.
final firebaseReadyProvider = Provider<bool>((ref) => false);

/// Whether Crashlytics/Analytics collect in this build.
bool telemetryEnabled({bool release = kReleaseMode}) => release;

/// Initialises Firebase and error reporting. Returns false (and leaves
/// telemetry off) on any failure; never throws.
Future<bool> initFirebase({
  Future<void> Function()? initializeApp,
  bool release = kReleaseMode,
}) async {
  try {
    await (initializeApp ??
        () => Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ))();

    final enabled = telemetryEnabled(release: release);
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(enabled);
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(enabled);

    if (release) {
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }
    return true;
  } catch (e, s) {
    debugPrint('Firebase init failed: $e\n$s');
    return false;
  }
}
