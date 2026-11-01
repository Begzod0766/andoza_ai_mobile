import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show NavigatorObserver;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/room_plan.dart';
import 'firebase_setup.dart';

abstract class AnalyticsSink {
  Future<void> logEvent(String name, [Map<String, Object>? params]);

  /// Sets the user id for analytics and crashlytics (null clears it).
  Future<void> setUserId(String? id);
}

/// Forwards to Firebase; a silent no-op unless this build collects telemetry
/// ([telemetryEnabled]) and Firebase is initialised.
class FirebaseAnalyticsSink implements AnalyticsSink {
  FirebaseAnalyticsSink({
    this.release = kReleaseMode,
    bool Function()? firebaseReady,
    FirebaseAnalytics Function()? analytics,
  }) : _firebaseReady = firebaseReady ?? (() => Firebase.apps.isNotEmpty),
       _analytics = analytics ?? (() => FirebaseAnalytics.instance);

  /// Whether this is a release build (injectable for tests).
  final bool release;
  final bool Function() _firebaseReady;
  final FirebaseAnalytics Function() _analytics;

  bool get _active => telemetryEnabled(release: release) && _firebaseReady();

  @override
  Future<void> logEvent(String name, [Map<String, Object>? params]) async {
    if (!_active) return;
    try {
      await _analytics().logEvent(name: name, parameters: params);
    } catch (e) {
      debugPrint('Analytics logEvent failed: $e');
    }
  }

  @override
  Future<void> setUserId(String? id) async {
    if (!_active) return;
    try {
      await _analytics().setUserId(id: id);
      await FirebaseCrashlytics.instance.setUserIdentifier(id ?? '');
    } catch (e) {
      debugPrint('Analytics setUserId failed: $e');
    }
  }
}

class AnalyticsService {
  AnalyticsService(this._sink);
  final AnalyticsSink _sink;

  /// [method]: 'password' | 'google'.
  Future<void> login(String method) =>
      _sink.logEvent('login', {'method': method});

  /// method: 'wizard' | 'draw' | 'lidar' | 'arcore' | 'photo' (sketch and
  /// drag are both hand-drawn rooms, reported as 'draw').
  Future<void> roomCreated(RoomSource source) =>
      _sink.logEvent('room_created', {'method': _roomMethod(source)});

  static String _roomMethod(RoomSource source) => switch (source) {
    RoomSource.sketch || RoomSource.drag => 'draw',
    _ => source.name,
  };

  /// [kind]: 'lidar' | 'arcore'.
  Future<void> scanFinished(String kind) =>
      _sink.logEvent('scan_finished', {'kind': kind});

  Future<void> estimateViewed() => _sink.logEvent('estimate_viewed');

  Future<void> orderPlaced(int lines) =>
      _sink.logEvent('order_placed', {'lines': lines});

  Future<void> leadSent() => _sink.logEvent('lead_sent');
}

final analyticsSinkProvider = Provider<AnalyticsSink>(
  (ref) => FirebaseAnalyticsSink(),
);

final analyticsProvider = Provider<AnalyticsService>(
  (ref) => AnalyticsService(ref.watch(analyticsSinkProvider)),
);

/// Makes one screen-view observer per navigator, or null when screen views
/// must not be sent (Firebase down or telemetry off for this build).
final screenViewObserverFactoryProvider =
    Provider<NavigatorObserver Function()?>(
      (ref) => ref.watch(firebaseReadyProvider) && telemetryEnabled()
          ? () =>
                FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance)
          : null,
    );
