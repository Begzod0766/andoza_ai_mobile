import 'package:tamir_uy_mobile_flutter/services/analytics_service.dart';

/// Records every analytics call instead of sending it to Firebase.
class FakeSink implements AnalyticsSink {
  final events = <(String, Map<String, Object>?)>[];
  final userIds = <String?>[];

  @override
  Future<void> logEvent(String name, [Map<String, Object>? params]) async =>
      events.add((name, params));

  @override
  Future<void> setUserId(String? id) async => userIds.add(id);
}
