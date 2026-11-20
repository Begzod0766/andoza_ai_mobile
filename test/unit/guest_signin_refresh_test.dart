import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/repositories/auth_repository.dart';
import 'package:tamir_uy_mobile_flutter/services/api_client.dart';
import 'package:tamir_uy_mobile_flutter/services/secure_storage.dart';

class _Adapter implements HttpClientAdapter {
  _Adapter(this._handle);
  final FutureOr<ResponseBody> Function(RequestOptions o) _handle;
  final seen = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    seen.add(options);
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

Map<String, dynamic> _session(String access, String refresh, Map user) => {
      'access_token': access,
      'refresh_token': refresh,
      'token_type': 'bearer',
      'user': user,
    };

/// A guest whose 30-minute access token has expired (the Studio WebView never
/// refreshed it): the server only recognises a guest by a valid bearer, so
/// the sign-in must carry a freshly refreshed one or the rooms are lost.
({AuthRepositoryImpl repo, _Adapter adapter}) _expiredGuest(
    {bool guestDead = false}) {
  FlutterSecureStorage.setMockInitialValues({});
  final storage = SecureStorageService();
  final client = ApiClient(
    baseUrl: 'http://test.local/api/v1',
    onTokensRefreshed: (a, r) async {
      await storage.saveToken(a);
      if (r != null) await storage.saveRefreshToken(r);
    },
    onTokensCleared: storage.clear,
  );
  final adapter = _Adapter((o) {
    switch (o.path) {
      case '/auth/guest':
        return _json(_session('expired', 'g-refresh', {'id': 'g1', 'is_guest': true}), 201);
      case '/auth/refresh':
        return guestDead
            ? _json({'detail': 'gone'}, 401)
            : _json(_session('fresh', 'g-refresh-2', {'id': 'g1', 'is_guest': true}), 200);
      default:
        return _json(_session('user-access', 'user-refresh', {'id': 'g1'}), 200);
    }
  });
  client.httpDioForTest.httpClientAdapter = adapter;
  client.refreshDioForTest.httpClientAdapter = adapter;
  return (repo: AuthRepositoryImpl(client, storage), adapter: adapter);
}

void main() {
  final signIns = <String, Future<Object?> Function(AuthRepositoryImpl r)>{
    '/auth/register': (r) => r.register('newname', 'pw-not-real', null),
    '/auth/login': (r) => r.login('someone', 'pw-not-real'),
    '/auth/otp/verify': (r) => r.verifyOtp('+998901234567', '123456'),
    '/auth/google': (r) => r.loginWithGoogle('google-id-token'),
    '/auth/apple': (r) => r.loginWithApple('apple-id-token'),
  };

  for (final entry in signIns.entries) {
    test('${entry.key} after an expired guest token sends a fresh guest bearer',
        () async {
      final s = _expiredGuest();
      await s.repo.startGuestSession();
      await entry.value(s.repo);
      final paths = s.adapter.seen.map((o) => o.path).toList();
      expect(paths.sublist(1), ['/auth/refresh', entry.key]);
      expect(s.adapter.seen.last.headers['Authorization'], 'Bearer fresh');
    });
  }

  test('a dead guest signs in as nobody (nothing to merge)', () async {
    final s = _expiredGuest(guestDead: true);
    await s.repo.startGuestSession();
    await s.repo.register('newname', 'pw-not-real', null);
    expect(s.adapter.seen.last.path, '/auth/register');
    expect(s.adapter.seen.last.headers['Authorization'], isNull);
    expect(await SecureStorageService().getToken(), 'user-access');
  });

  test('a registered user signing in again does not refresh first', () async {
    final s = _expiredGuest();
    await s.repo.login('someone', 'pw-not-real');
    await s.repo.login('someone', 'pw-not-real');
    expect(s.adapter.seen.map((o) => o.path),
        everyElement(isNot('/auth/refresh')));
  });
}
