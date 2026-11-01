import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/models/room_plan.dart';
import 'package:tamir_uy_mobile_flutter/services/analytics_service.dart';

import '../support/fake_analytics_sink.dart';

void main() {
  test('each event has its exact name and params', () async {
    final sink = FakeSink();
    final a = AnalyticsService(sink);
    await a.login('google');
    await a.roomCreated(RoomSource.arcore);
    await a.roomCreated(RoomSource.sketch);
    await a.roomCreated(RoomSource.drag);
    await a.scanFinished('lidar');
    await a.estimateViewed();
    await a.orderPlaced(3);
    await a.leadSent();
    expect(sink.events.map((e) => '${e.$1} ${e.$2}').toList(), [
      "login {method: google}",
      "room_created {method: arcore}",
      "room_created {method: draw}",
      "room_created {method: draw}",
      "scan_finished {kind: lidar}",
      "estimate_viewed null",
      "order_placed {lines: 3}",
      "lead_sent null",
    ]);
  });

  test(
    'FirebaseAnalyticsSink is a no-op when Firebase is not initialised',
    () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final sink = FirebaseAnalyticsSink();
      await sink.logEvent('x', {'a': 1});
      await sink.setUserId('u');
      await sink.setUserId(null);
    },
  );

  test(
    'FirebaseAnalyticsSink never touches Firebase outside release',
    () async {
      var touched = 0;
      final sink = FirebaseAnalyticsSink(
        release: false,
        firebaseReady: () => true,
        analytics: () {
          touched++;
          throw StateError('Firebase touched');
        },
      );
      await sink.logEvent('x', {'a': 1});
      await sink.setUserId('u');
      await sink.setUserId(null);
      expect(touched, 0);
    },
  );
}
