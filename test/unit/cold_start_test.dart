import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tamir_uy_mobile_flutter/models/user_model.dart';
import 'package:tamir_uy_mobile_flutter/providers/auth_provider.dart';
import 'package:tamir_uy_mobile_flutter/repositories/auth_repository.dart';
import 'package:tamir_uy_mobile_flutter/services/api_client.dart';
import 'package:tamir_uy_mobile_flutter/services/sign_in_history.dart';

class _Repo implements AuthRepository {
  AuthResponse? loginResult;
  Object? guestError;
  int guestCalls = 0;
  User? restoredUser;

  @override
  String? token;

  @override
  User? cachedUser;

  @override
  Future<AuthResponse> startGuestSession() async {
    guestCalls++;
    if (guestError != null) throw guestError!;
    return const AuthResponse(
      token: 'g',
      refreshToken: 'gr',
      user: User(id: 'g1', isGuest: true),
    );
  }

  @override
  Future<AuthResponse> login(String email, String password) async =>
      loginResult!;

  @override
  Future<void> restoreToken() async {
    if (restoredUser != null) token = 'stored';
  }

  @override
  Future<User?> getCurrentUser() async => token == null ? null : restoredUser;

  @override
  Future<void> clearSession() async {
    token = null;
    cachedUser = null;
  }

  @override
  Future<void> logout() => clearSession();

  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError();
}

const _registered = AuthResponse(token: 'u', user: User(id: 'u1'));

void main() {
  late _Repo repo;
  late SignInHistory history;
  late AuthNotifier notifier;
  late ProviderContainer container;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repo = _Repo();
    history = SignInHistory();
    container = ProviderContainer(overrides: [
      authRepositoryProvider.overrideWithValue(repo),
      signInHistoryProvider.overrideWithValue(history),
    ]);
    notifier = container.read(authStateProvider.notifier);
  });
  tearDown(() => container.dispose());

  test('fresh install becomes a guest', () async {
    expect(await resolveColdStart(notifier, history), ColdStart.home);
    expect(repo.guestCalls, 1);
    expect(container.read(authStateProvider).isGuest, isTrue);
  });

  test('a stored session goes home without a guest', () async {
    repo.restoredUser = const User(id: 'u1');
    expect(await resolveColdStart(notifier, history), ColdStart.home);
    expect(repo.guestCalls, 0);
  });

  test('cold start after logout goes to login', () async {
    repo.loginResult = _registered;
    await notifier.login('a', 'b');
    await pumpEventQueue();
    await notifier.logout();
    expect(await resolveColdStart(notifier, history), ColdStart.login);
    expect(repo.guestCalls, 0);
  });

  test('cold start after account deletion goes to login', () async {
    notifier.setSession(_registered);
    await pumpEventQueue();
    await notifier.completeAccountDeletion();
    expect(await resolveColdStart(notifier, history), ColdStart.login);
    expect(repo.guestCalls, 0);
  });

  test('guest failure falls back to login', () async {
    repo.guestError = ApiException(message: 'off', statusCode: 503);
    expect(await resolveColdStart(notifier, history), ColdStart.login);
    expect(container.read(authStateProvider), isA<AuthInitial>());
  });

  test('registered sign-in marks history, guest does not', () async {
    await notifier.startGuestSession();
    await pumpEventQueue();
    expect(await history.hasSignedInBefore(), isFalse);

    // The guest signs up: the same notifier now holds a registered user.
    notifier.setSession(_registered);
    await pumpEventQueue();
    expect(await history.hasSignedInBefore(), isTrue);
    expect(await SignInHistory().hasSignedInBefore(), isTrue);
  });

  test('a restored registered session marks history', () async {
    repo.restoredUser = const User(id: 'u1');
    await notifier.restoreToken();
    await pumpEventQueue();
    expect(await history.hasSignedInBefore(), isTrue);
  });
}
