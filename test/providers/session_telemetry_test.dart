import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:tamir_uy_mobile_flutter/models/user_model.dart';
import 'package:tamir_uy_mobile_flutter/providers/auth_provider.dart';
import 'package:tamir_uy_mobile_flutter/repositories/auth_repository.dart';
import 'package:tamir_uy_mobile_flutter/services/analytics_service.dart';
import 'package:tamir_uy_mobile_flutter/services/session_telemetry.dart';

class _NoRepo implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError();
}

class _FakeAuth extends AuthNotifier {
  _FakeAuth() : super(_NoRepo());
  void set(AuthState s) => state = s;
}

class _Sink implements AnalyticsSink {
  final ids = <String?>[];
  final properties = <(String, String?)>[];
  @override
  Future<void> setUserProperty(String name, String? value) async =>
      properties.add((name, value));
  @override
  Future<void> logEvent(String name, [Map<String, Object>? params]) async {}
  @override
  Future<void> setUserId(String? id) async => ids.add(id);
}

void main() {
  test('session id follows login and logout', () {
    final sink = _Sink();
    final auth = _FakeAuth();
    final c = ProviderContainer(
      overrides: [
        analyticsSinkProvider.overrideWithValue(sink),
        authStateProvider.overrideWith((ref) => auth),
      ],
    );
    addTearDown(c.dispose);
    c.read(sessionTelemetryProvider);

    auth.set(const AuthLoading());
    expect(sink.ids, isEmpty);
    auth.set(
      const AuthAuthenticated(
        user: User(id: 'u1'),
        token: 't',
      ),
    );
    expect(sink.ids, ['u1']);
    auth.set(const AuthInitial());
    expect(sink.ids, ['u1', null]);
    auth.set(const AuthInitial());
    expect(sink.ids, ['u1', null]);
  });

  test('telemetry sets account_type', () {
    final sink = _Sink();
    final auth = _FakeAuth();
    final c = ProviderContainer(
      overrides: [
        analyticsSinkProvider.overrideWithValue(sink),
        authStateProvider.overrideWith((ref) => auth),
      ],
    );
    addTearDown(c.dispose);
    c.read(sessionTelemetryProvider);

    auth.set(const AuthAuthenticated(
        user: User(id: 'g1', isGuest: true), token: 'g'));
    auth.set(const AuthAuthenticated(user: User(id: 'g1'), token: 'u'));
    auth.set(const AuthInitial());
    expect(sink.properties, [
      ('account_type', 'guest'),
      ('account_type', 'registered'),
      ('account_type', null),
    ]);
    expect(sink.ids, ['g1', 'g1', null]);
  });
}
