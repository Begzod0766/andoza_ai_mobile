import 'dart:async';

import 'package:tamir_uy_mobile_flutter/providers/auth_provider.dart';
import 'package:tamir_uy_mobile_flutter/repositories/auth_repository.dart';
import 'package:tamir_uy_mobile_flutter/repositories/push_repository.dart';
import 'package:tamir_uy_mobile_flutter/services/push_service.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeMessaging implements MessagingClient {
  FakeMessaging(this.log, {this.token = 'tok-1'});
  final List<String> log;
  String? token;
  final refresh = StreamController<String>.broadcast();

  @override
  Future<String?> getToken() async => token;
  @override
  Stream<String> get onTokenRefresh => refresh.stream;
  @override
  Future<void> deleteToken() async => log.add('messaging.deleteToken');
}

class FakeRepo implements PushRepository {
  FakeRepo(this.log);
  final List<String> log;
  bool failRegister = false;
  Completer<void>? hangUnregister;

  @override
  Future<void> register(String token, String platform, String locale) async {
    if (failRegister) throw Exception('backend down');
    log.add('repo.register $token $platform $locale');
  }

  @override
  Future<void> unregister(String token) async {
    if (hangUnregister != null) return hangUnregister!.future;
    log.add('repo.unregister $token');
  }
}

class FakeAuthRepo implements AuthRepository {
  FakeAuthRepo(this.log);
  final List<String> log;
  @override
  Future<void> logout() async => log.add('authRepo.logout');
  @override
  Future<void> clearSession() async => log.add('authRepo.clearSession');
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late List<String> log;
  late FakeMessaging messaging;
  late FakeRepo repo;
  late PushService service;

  setUp(() {
    log = [];
    messaging = FakeMessaging(log);
    repo = FakeRepo(log);
    service = PushService(messaging, repo, locale: () => 'ru', platform: 'android');
  });

  test('signing in registers the token with platform and locale', () async {
    await service.registerCurrent();
    expect(log, ['repo.register tok-1 android ru']);
  });

  test('a refreshed token is registered again', () async {
    service.listenForRefresh();
    messaging.refresh.add('tok-2');
    await Future<void>.delayed(Duration.zero);
    expect(log, ['repo.register tok-2 android ru']);
  });

  test('logout unregisters before the session is cleared', () async {
    final notifier = AuthNotifier(FakeAuthRepo(log))
      ..beforeLogout = service.unregister;
    await service.registerCurrent();
    log.clear();
    await notifier.logout();
    expect(log, [
      'repo.unregister tok-1',
      'messaging.deleteToken',
      'authRepo.logout',
    ]);
  });

  test('logout still completes when the server never answers', () async {
    repo.hangUnregister = Completer<void>(); // never completed
    final slow = PushService(
      messaging,
      repo,
      locale: () => 'ru',
      platform: 'android',
      timeout: const Duration(milliseconds: 50),
    );
    final notifier = AuthNotifier(FakeAuthRepo(log))
      ..beforeLogout = slow.unregister;
    await notifier.logout().timeout(const Duration(seconds: 2));
    expect(log, ['messaging.deleteToken', 'authRepo.logout']);
    expect(notifier.state, isA<AuthInitial>());
  });

  test('a dead session only drops the local token', () async {
    final notifier = AuthNotifier(FakeAuthRepo(log))
      ..onSessionEnded = service.discardLocalToken;
    await notifier.completeAccountDeletion();
    expect(log, ['messaging.deleteToken', 'authRepo.clearSession']);
  });

  test('no token (iOS without APNs) is not an error', () async {
    messaging.token = null;
    await service.registerCurrent();
    expect(log, isEmpty);
  });

  test('a backend error does not break sign-in', () async {
    repo.failRegister = true;
    await service.registerCurrent();
    expect(log, isEmpty);
  });
}
