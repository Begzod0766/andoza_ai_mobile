import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:tamir_uy_mobile_flutter/models/user_model.dart';
import 'package:tamir_uy_mobile_flutter/providers/auth_provider.dart';
import 'package:tamir_uy_mobile_flutter/repositories/auth_repository.dart';

/// A fully in-memory AuthRepository: no ApiClient, no network. Each method is
/// scripted per-test so we can exercise the AuthNotifier state machine (login
/// success, the null-phone parsing regression, the error path, and the
/// handleUnauthorized guard) without touching real HTTP.
class _FakeAuthRepository implements AuthRepository {
  // ignore_for_file: prefer_initializing_formals
  _FakeAuthRepository({AuthResponse? loginResult, Object? loginError})
      : _loginResult = loginResult,
        _loginError = loginError;

  final AuthResponse? _loginResult;
  final Object? _loginError;

  @override
  String? token;

  @override
  Future<AuthResponse> login(String email, String password) async {
    if (_loginError != null) throw _loginError;
    return _loginResult!;
  }

  @override
  Future<AuthResponse> loginWithGoogle(String idToken) async {
    if (_loginError != null) throw _loginError;
    return _loginResult!;
  }

  @override
  Future<AuthResponse> loginWithApple(String identityToken,
      {String? name}) async {
    if (_loginError != null) throw _loginError;
    return _loginResult!;
  }

  @override
  Future<void> requestOtp(String phone) async {}

  @override
  Future<AuthResponse> verifyOtp(String phone, String code) async =>
      _loginResult!;

  @override
  Future<AuthResponse> register(
          String username, String password, String? name) async =>
      _loginResult!;

  @override
  Future<void> logout() async {}

  @override
  Future<void> deleteAccount({String? password}) async {}

  /// Records the local-teardown call so tests can assert handleUnauthorized /
  /// logout drop the session, and nulls the in-memory bits like the real impl.
  int clearSessionCalls = 0;

  @override
  Future<void> clearSession() async {
    clearSessionCalls++;
    token = null;
    cachedUser = null;
  }

  @override
  User? cachedUser;

  @override
  Future<User?> getCurrentUser() async => _loginResult?.user;

  @override
  Future<void> restoreToken() async {}
}

/// Builds a container with the auth repository swapped for a fake.
ProviderContainer _container(AuthRepository repo) {
  final container = ProviderContainer(
    overrides: [authRepositoryProvider.overrideWithValue(repo)],
  );
  addTearDown(container.dispose);
  return container;
}

AuthResponse _response({String? phone, String token = 'tok-123'}) =>
    AuthResponse(
      token: token,
      refreshToken: 'refresh-abc',
      tokenType: 'bearer',
      user: User(id: 'u1', username: 'rimefara', name: 'Test User', phone: phone),
    );

/// A fake dio adapter that dispatches by request path so the real ApiClient +
/// AuthRepositoryImpl can be driven end-to-end without any network. Also
/// records the Authorization header of the last non-refresh request so tests
/// can prove the in-memory bearer was cleared.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this._handle);

  final ResponseBody Function(RequestOptions options) _handle;
  String? lastAuthHeader;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (!options.path.endsWith('/auth/refresh')) {
      lastAuthHeader = options.headers['Authorization'] as String?;
    }
    return _handle(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(Object? body, int status) => ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

/// Builds the REAL provider graph (AuthNotifier → AuthRepositoryImpl →
/// ApiClient + SecureStorageService) with only the HTTP adapter and the
/// secure-storage backing map swapped for fakes, so the auth-lifecycle wiring
/// (onUnauthorized / onTokensCleared / restore) is exercised for real.
({ProviderContainer container, _FakeAdapter adapter, Map<String, String> store})
    _realStack({
  required Map<String, String> seed,
  required ResponseBody Function(RequestOptions) handle,
}) {
  FlutterSecureStorage.setMockInitialValues(seed);
  final adapter = _FakeAdapter(handle);
  final container = ProviderContainer();
  addTearDown(container.dispose);
  final client = container.read(apiClientProvider);
  client.httpDioForTest.httpClientAdapter = adapter;
  client.refreshDioForTest.httpClientAdapter = adapter;
  return (container: container, adapter: adapter, store: seed);
}

void main() {
  group('AuthNotifier.login — success', () {
    test('successful login moves state to AuthAuthenticated with the user', () async {
      final container = _container(
        _FakeAuthRepository(loginResult: _response(phone: '998901234567')),
      );
      final notifier = container.read(authStateProvider.notifier);

      await notifier.login('rimefara', '12345678');

      final state = container.read(authStateProvider);
      expect(state, isA<AuthAuthenticated>());
      final authed = state as AuthAuthenticated;
      expect(authed.user.id, 'u1');
      expect(authed.user.username, 'rimefara');
      expect(authed.token, 'tok-123');
    });
  });

  group('AuthNotifier — null-phone regression (prior CastError)', () {
    test('a User with phone == null parses without crashing', () {
      // The original production crash was a CastError on json[phone] as String.
      // With phone nullable, parsing a phone-less (username/password) account
      // must succeed.
      final user = User.fromJson({
        'id': 'u1',
        'username': 'rimefara',
        'name': 'Test User',
        'phone': null,
      });
      expect(user.phone, isNull);
      expect(user.username, 'rimefara');
    });

    test('login with a phone==null user still reaches Authenticated cleanly',
        () async {
      final container = _container(
        _FakeAuthRepository(loginResult: _response(phone: null)),
      );
      final notifier = container.read(authStateProvider.notifier);

      await notifier.login('rimefara', '12345678');

      final state = container.read(authStateProvider);
      expect(state, isA<AuthAuthenticated>());
      expect((state as AuthAuthenticated).user.phone, isNull);
    });

    test('setSession with a phone==null user reaches Authenticated cleanly', () {
      final container = _container(_FakeAuthRepository());
      final notifier = container.read(authStateProvider.notifier);

      notifier.setSession(_response(phone: null));

      final state = container.read(authStateProvider);
      expect(state, isA<AuthAuthenticated>());
      expect((state as AuthAuthenticated).user.phone, isNull);
    });
  });

  group('AuthNotifier.login — failure path', () {
    test('repository throwing lands in AuthError (not stuck AuthLoading)',
        () async {
      final container = _container(
        _FakeAuthRepository(loginError: AuthException('Invalid credentials')),
      );
      final notifier = container.read(authStateProvider.notifier);

      await notifier.login('rimefara', 'wrong');

      final state = container.read(authStateProvider);
      expect(state, isA<AuthError>());
      expect((state as AuthError).message, contains('Invalid credentials'));
    });

    test('a 401 AuthException carries its statusCode into AuthError', () async {
      final container = _container(
        _FakeAuthRepository(
          loginError: AuthException('Unauthorized', statusCode: 401),
        ),
      );
      final notifier = container.read(authStateProvider.notifier);

      await notifier.login('rimefara', 'wrong');

      final state = container.read(authStateProvider);
      expect(state, isA<AuthError>());
      expect((state as AuthError).statusCode, 401);
    });

    test('even a raw Error (e.g. a parse CastError) becomes AuthError', () async {
      // Guards the "catch Error too" behaviour: a malformed response must not
      // leave the login button spinning in AuthLoading forever.
      final container = _container(
        _FakeAuthRepository(loginError: TypeError()),
      );
      final notifier = container.read(authStateProvider.notifier);

      await notifier.login('rimefara', '12345678');

      expect(container.read(authStateProvider), isA<AuthError>());
    });
  });

  group('AuthNotifier.handleUnauthorized', () {
    test('when Authenticated, tears down the session and flips to Initial',
        () async {
      final repo =
          _FakeAuthRepository(loginResult: _response(phone: '998901234567'));
      final container = _container(repo);
      final notifier = container.read(authStateProvider.notifier);
      await notifier.login('rimefara', '12345678');
      expect(container.read(authStateProvider), isA<AuthAuthenticated>());

      await notifier.handleUnauthorized();

      // Reused the same local-teardown path as logout (no server call).
      expect(repo.clearSessionCalls, 1);
      expect(container.read(authStateProvider), isNot(isA<AuthAuthenticated>()));
      expect(container.read(authStateProvider), isA<AuthInitial>());
    });

    test('does not clobber a mid-login AuthLoading state', () {
      final container = _container(_FakeAuthRepository());
      final notifier = container.read(authStateProvider.notifier);
      // Kick off a login that never completes to leave state in AuthLoading.
      // ignore: unawaited_futures
      notifier.login('rimefara', '12345678');
      expect(container.read(authStateProvider), isA<AuthLoading>());

      notifier.handleUnauthorized();

      // Still loading — the in-flight login was not overwritten.
      expect(container.read(authStateProvider), isA<AuthLoading>());
    });

    test('is a no-op from AuthInitial', () {
      final container = _container(_FakeAuthRepository());
      final notifier = container.read(authStateProvider.notifier);
      expect(container.read(authStateProvider), isA<AuthInitial>());

      notifier.handleUnauthorized();

      expect(container.read(authStateProvider), isA<AuthInitial>());
    });
  });

  group('auth lifecycle — full teardown & cold-start restore (real stack)', () {
    test(
        'handleUnauthorized wipes secure storage AND the in-memory bearer '
        '(not just the state)', () async {
      // Log in for real so storage + the ApiClient in-memory token are set,
      // then simulate a dead-session 401 arriving via handleUnauthorized.
      final stack = _realStack(
        seed: <String, String>{},
        handle: (options) {
          if (options.path.endsWith('/auth/login')) {
            return _json({
              'access_token': 'access-1',
              'refresh_token': 'refresh-1',
              'token_type': 'bearer',
              'user': {'id': 'u1', 'username': 'rimefara'},
            }, 200);
          }
          // A probe request after teardown: succeed so we can inspect its
          // (absent) Authorization header.
          return _json({'ok': true}, 200);
        },
      );
      final notifier = stack.container.read(authStateProvider.notifier);
      final repo = stack.container.read(authRepositoryProvider);

      await notifier.login('rimefara', '12345678');
      expect(stack.container.read(authStateProvider), isA<AuthAuthenticated>());
      expect(stack.store['auth_token'], 'access-1');
      expect(repo.token, 'access-1');

      await notifier.handleUnauthorized();

      // State dropped, cached token gone, and secure storage fully cleared
      // (not just token+refresh — user_id too).
      expect(stack.container.read(authStateProvider), isA<AuthInitial>());
      expect(repo.token, isNull);
      expect(stack.store, isEmpty);

      // In-memory bearer is gone too: a fresh request carries no Authorization.
      await stack.container
          .read(apiClientProvider)
          .get<dynamic>('/anything', fromJson: (j) => j);
      expect(stack.adapter.lastAuthHeader, isNull);
    });

    test(
        'cold-start restore KEEPS the session on a transient 5xx (does not '
        'bounce a valid token to login)', () async {
      final stack = _realStack(
        seed: <String, String>{'auth_token': 'valid-token', 'user_id': 'u1'},
        handle: (options) {
          // No refresh token seeded, so /auth/me's failure propagates directly.
          if (options.path.endsWith('/auth/me')) {
            return _json({'detail': 'boom'}, 500);
          }
          return _json({'detail': 'unexpected'}, 500);
        },
      );
      final notifier = stack.container.read(authStateProvider.notifier);

      await notifier.restoreToken();

      // Optimistically authenticated from the restored token — NOT logged out.
      final state = stack.container.read(authStateProvider);
      expect(state, isA<AuthAuthenticated>());
      expect((state as AuthAuthenticated).token, 'valid-token');
      // Tokens were preserved, not cleared.
      expect(stack.store['auth_token'], 'valid-token');
    });

    test(
        'cold-start restore CLEARS the session on a genuine 401 '
        '(session really invalid)', () async {
      final stack = _realStack(
        seed: <String, String>{'auth_token': 'stale-token', 'user_id': 'u1'},
        handle: (options) {
          // No refresh token, so the 401 is terminal for this session.
          return _json({'detail': 'Not authenticated'}, 401);
        },
      );
      final notifier = stack.container.read(authStateProvider.notifier);

      await notifier.restoreToken();

      expect(stack.container.read(authStateProvider), isA<AuthInitial>());
      // Session torn down: stored tokens dropped.
      expect(stack.store, isEmpty);
    });
  });
}
