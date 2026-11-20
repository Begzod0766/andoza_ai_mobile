import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/models/api/apartment.dart';
import 'package:tamir_uy_mobile_flutter/models/api/estimate.dart';
import 'package:tamir_uy_mobile_flutter/models/user_model.dart';
import 'package:tamir_uy_mobile_flutter/providers/apartment_provider.dart';
import 'package:tamir_uy_mobile_flutter/providers/auth_provider.dart';
import 'package:tamir_uy_mobile_flutter/repositories/apartment_repository.dart';
import 'package:tamir_uy_mobile_flutter/providers/estimate_api_provider.dart';
import 'package:tamir_uy_mobile_flutter/repositories/estimate_repository.dart';
import 'package:tamir_uy_mobile_flutter/repositories/auth_repository.dart';
import 'package:tamir_uy_mobile_flutter/services/api_client.dart';
import 'package:tamir_uy_mobile_flutter/services/secure_storage.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this._handle);

  final FutureOr<ResponseBody> Function(RequestOptions options) _handle;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
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

Map<String, dynamic> _login(String access, String? refresh, Map user,
        {int? merged}) =>
    {
      'access_token': access,
      'refresh_token': refresh,
      'token_type': 'bearer',
      'user': user,
      'guest_merged_rooms': merged,
    };

({AuthRepositoryImpl repo, ApiClient client, _FakeAdapter adapter})
    _stack(Map<String, String> seed,
        FutureOr<ResponseBody> Function(RequestOptions) h,
        {void Function()? onUnauthorized}) {
  FlutterSecureStorage.setMockInitialValues(seed);
  final storage = SecureStorageService();
  late final ApiClient client;
  client = ApiClient(
    baseUrl: 'http://test.local/api/v1',
    onUnauthorized: onUnauthorized,
    onTokensRefreshed: (a, r) async {
      await storage.saveToken(a);
      if (r != null) await storage.saveRefreshToken(r);
    },
    onTokensCleared: storage.clear,
  );
  final adapter = _FakeAdapter(h);
  client.httpDioForTest.httpClientAdapter = adapter;
  client.refreshDioForTest.httpClientAdapter = adapter;
  final repo = AuthRepositoryImpl(client, storage, language: () => 'uz');
  return (repo: repo, client: client, adapter: adapter);
}

void main() {
  test('install id is stable', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final storage = SecureStorageService();
    final first = await storage.getOrCreateInstallId();
    expect(first, matches(RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')));
    expect(await storage.getOrCreateInstallId(), first);
    expect(await SecureStorageService().getOrCreateInstallId(), first);
  });

  test('clearing the session keeps the install id', () async {
    final seed = <String, String>{};
    FlutterSecureStorage.setMockInitialValues(seed);
    final storage = SecureStorageService();
    final id = await storage.getOrCreateInstallId();
    await storage.saveToken('t');
    await storage.saveRefreshToken('r');
    await storage.saveUserId('u');
    await storage.clear();
    expect(await storage.getToken(), isNull);
    expect(await storage.getRefreshToken(), isNull);
    expect(await storage.getUserId(), isNull);
    expect(await storage.getOrCreateInstallId(), id);
  });

  test('guest request body', () async {
    final s = _stack({}, (o) {
      return _json(
          _login('ga', 'gr', {'id': 'g1', 'is_guest': true}), 201);
    });
    final res = await s.repo.startGuestSession();
    final req = s.adapter.requests.single;
    expect(req.method, 'POST');
    expect(req.path, '/auth/guest');
    final installId = await SecureStorageService().getOrCreateInstallId();
    expect(req.data, {'install_id': installId, 'language': 'uz'});
    expect(res.user.isGuest, isTrue);
    expect(s.repo.token, 'ga');
    expect(await SecureStorageService().getToken(), 'ga');
    expect(await SecureStorageService().getRefreshToken(), 'gr');
  });

  test('a guest restored at cold start is still a guest offline', () async {
    final s = _stack({}, (o) {
      if (o.path == '/auth/guest') {
        return _json(_login('ga', 'gr', {'id': 'g1', 'is_guest': true}), 201);
      }
      return _json({'detail': 'down'}, 503);
    });
    await s.repo.startGuestSession();
    // A new process: fresh repository over the same storage.
    final again = AuthRepositoryImpl(s.client, SecureStorageService());
    await again.restoreToken();
    expect(again.cachedUser?.id, 'g1');
    expect(again.cachedUser?.isGuest, isTrue);
  });

  group('signing up as a guest replaces the guest tokens', () {
    test('new tokens are stored before the session is reported', () async {
      final s = _stack({}, (o) {
        if (o.path == '/auth/guest') {
          return _json(
              _login('ga', 'gr', {'id': 'g1', 'is_guest': true}), 201);
        }
        if (o.path == '/auth/register') {
          return _json(_login('ua', 'ur', {'id': 'g1'}), 201);
        }
        return _json({'ok': true}, 200);
      });
      await s.repo.startGuestSession();
      final res = await s.repo.register('newname', 'pw-not-real', null);
      // By the time register returns (and the notifier flips the state) the
      // upgraded tokens are already persisted and in use.
      expect(res.user.isGuest, isFalse);
      expect(await SecureStorageService().getToken(), 'ua');
      expect(await SecureStorageService().getRefreshToken(), 'ur');
      await s.client.get<dynamic>('/apartments', fromJson: (j) => j);
      expect(s.adapter.requests.last.headers['Authorization'], 'Bearer ua');
    });

    test('a login without a refresh token drops the guest refresh token',
        () async {
      var refreshCookie = <String?>[];
      var signedIn = false;
      final s = _stack({}, (o) {
        if (o.path == '/auth/guest') {
          return _json(
              _login('ga', 'gr', {'id': 'g1', 'is_guest': true}), 201);
        }
        if (o.path == '/auth/login') {
          return _json(_login('ua', null, {'id': 'u9'}, merged: 2), 200);
        }
        if (o.path == '/auth/refresh') {
          // Only the guest's own refresh right before signing in is fine.
          if (signedIn) refreshCookie.add(o.headers['Cookie'] as String?);
          return _json({'detail': 'guest merged'}, 401);
        }
        return _json({'detail': 'expired'}, 401);
      });
      await s.repo.startGuestSession();
      final res = await s.repo.login('someone', 'pw-not-real');
      signedIn = true;
      expect(res.guestMergedRooms, 2);
      expect(await SecureStorageService().getRefreshToken(), isNull);
      await expectLater(
        s.client.get<dynamic>('/apartments', fromJson: (j) => j),
        throwsA(isA<ApiException>()),
      );
      // Never refreshed with the dead guest's refresh token.
      expect(refreshCookie, isEmpty);
    });

    test(
        'a guest refresh that fails after sign-in does not wipe the new '
        'session', () async {
      late AuthRepositoryImpl repo;
      var signingIn = false;
      final s = _stack({}, (o) async {
        if (o.path == '/auth/guest') {
          return _json(
              _login('ga', 'gr', {'id': 'g1', 'is_guest': true}), 201);
        }
        if (o.path == '/auth/login') {
          return _json(_login('ua', 'ur', {'id': 'u9'}), 200);
        }
        if (o.path == '/auth/refresh') {
          // The sign-in completes while the guest's refresh is in flight; the
          // server then rejects the (now merged) guest's refresh token.
          if (!signingIn) {
            signingIn = true;
            await repo.login('someone', 'pw-not-real');
          }
          return _json({'detail': 'merged'}, 401);
        }
        final auth = o.headers['Authorization'];
        return auth == 'Bearer ua'
            ? _json({'ok': true}, 200)
            : _json({'detail': 'expired'}, 401);
      });
      repo = s.repo;
      await repo.startGuestSession();
      await s.client
          .get<dynamic>('/apartments', fromJson: (j) => j)
          .then<Object?>((v) => v, onError: (Object _) => null);
      expect(await SecureStorageService().getToken(), 'ua');
      expect(await SecureStorageService().getRefreshToken(), 'ur');
      await s.client.get<dynamic>('/apartments', fromJson: (j) => j);
      expect(s.adapter.requests.last.headers['Authorization'], 'Bearer ua');
    });
  });

  test('the rooms list refetches when the signed-in account changes',
      () async {
    var calls = 0;
    final container = ProviderContainer(overrides: [
      apartmentRepositoryProvider.overrideWithValue(_CountingApartments(() {
        calls++;
      })),
      authStateProvider.overrideWith((ref) => _SettableAuth()),
    ]);
    addTearDown(container.dispose);
    final auth = container.read(authStateProvider.notifier) as _SettableAuth;
    auth.set(const AuthAuthenticated(
        user: User(id: 'g1', isGuest: true), token: 'g'));
    final sub = container.listen(apartmentsProvider, (_, _) {});
    addTearDown(sub.close);
    await container.read(apartmentsProvider.future);
    expect(calls, 1);

    // Upgrade: same id, new token → no refetch needed.
    auth.set(const AuthAuthenticated(user: User(id: 'g1'), token: 'u'));
    await container.read(apartmentsProvider.future);
    expect(calls, 1);

    // Merge: the guest's rooms now live in another account → refetch.
    auth.set(const AuthAuthenticated(user: User(id: 'u9'), token: 'm'));
    await container.read(apartmentsProvider.future);
    expect(calls, 2);

    // Signed out: no request without a session (it would only 401).
    auth.set(const AuthInitial());
    expect(await container.read(apartmentsProvider.future), isEmpty);
    expect(calls, 2);
  });

  test('the server smeta refetches when a guest signs up', () async {
    var calls = 0;
    final container = ProviderContainer(overrides: [
      estimateRepositoryProvider.overrideWithValue(_CountingEstimates(() {
        calls++;
      })),
      authStateProvider.overrideWith((ref) => _SettableAuth()),
    ]);
    addTearDown(container.dispose);
    final auth = container.read(authStateProvider.notifier) as _SettableAuth;
    auth.set(const AuthAuthenticated(
        user: User(id: 'g1', isGuest: true), token: 'g'));
    final sub = container.listen(estimatePreviewProvider('r1'), (_, _) {});
    addTearDown(sub.close);
    await container.read(estimatePreviewProvider('r1').future);
    expect(calls, 1);

    // Signed up: the guest's approximate prices are no longer the answer.
    auth.set(const AuthAuthenticated(user: User(id: 'g1'), token: 'u'));
    await container.read(estimatePreviewProvider('r1').future);
    expect(calls, 2);

    // A token refresh is not a reason to price it again.
    auth.set(const AuthAuthenticated(user: User(id: 'g1'), token: 'u2'));
    await container.read(estimatePreviewProvider('r1').future);
    expect(calls, 2);
  });
}

class _CountingEstimates implements EstimateRepository {
  _CountingEstimates(this._onPreview);
  final void Function() _onPreview;

  @override
  Future<Estimate> preview(String roomId) async {
    _onPreview();
    return Estimate(
      id: 'e',
      roomId: roomId,
      totalUzs: 1,
      totalMin: 1,
      totalMax: 1,
      createdAt: DateTime(2026),
    );
  }

  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError();
}

class _NoRepo implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError();
}

class _SettableAuth extends AuthNotifier {
  _SettableAuth() : super(_NoRepo());
  void set(AuthState s) => state = s;
}

class _CountingApartments implements ApartmentRepository {
  _CountingApartments(this._onList);
  final void Function() _onList;

  @override
  Future<List<Apartment>> listApartments() async {
    _onList();
    return const [];
  }

  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError();
}
