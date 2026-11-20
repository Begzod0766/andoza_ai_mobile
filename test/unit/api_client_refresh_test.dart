import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/services/api_client.dart';

/// A fake dio adapter that dispatches by request path so we can simulate an
/// expired-access-token flow without any real HTTP. It records how many times
/// the refresh endpoint was hit so tests can assert the loop/concurrency guards.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this._handle);

  final ResponseBody Function(RequestOptions options) _handle;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
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

void main() {
  group('ApiClient auto-refresh on 401', () {
    test('401 on a normal call refreshes the token and retries once', () async {
      var refreshCalls = 0;
      String? refreshCookieSeen;
      final refreshedTokens = <List<String?>>[];

      final client = ApiClient(
        baseUrl: 'http://test.local/api/v1',
        onTokensRefreshed: (access, refresh) async {
          refreshedTokens.add([access, refresh]);
        },
      );
      client.setAuthToken('expired-access');
      client.setRefreshToken('refresh-abc');

      final adapter = _FakeAdapter((options) {
        final path = options.path;
        if (path.endsWith('/auth/refresh')) {
          refreshCalls++;
          refreshCookieSeen = options.headers['Cookie'] as String?;
          return _json({
            'access_token': 'fresh-access',
            'refresh_token': 'refresh-def',
            'token_type': 'bearer',
            'user': {'id': 'u1'},
          }, 200);
        }
        if (path.endsWith('/apartments')) {
          final auth = options.headers['Authorization'];
          if (auth == 'Bearer fresh-access') {
            return _json([
              {'id': 'a1'},
            ], 200);
          }
          return _json({'detail': 'Not authenticated'}, 401);
        }
        return _json({'detail': 'unexpected'}, 500);
      });
      client.httpDioForTest.httpClientAdapter = adapter;
      client.refreshDioForTest.httpClientAdapter = adapter;

      final result = await client.get<List<dynamic>>(
        '/apartments',
        fromJson: (json) => json as List<dynamic>,
      );

      expect(refreshCalls, 1);
      expect(refreshCookieSeen, 'refresh_token=refresh-abc');
      expect(result, isA<List<dynamic>>());
      expect(result.length, 1);
      // Rotated tokens were surfaced for persistence.
      expect(refreshedTokens, [
        ['fresh-access', 'refresh-def'],
      ]);
    });

    test('does NOT refresh when the 401 comes from an auth endpoint', () async {
      var refreshCalls = 0;

      final client = ApiClient(baseUrl: 'http://test.local/api/v1');
      client.setRefreshToken('refresh-abc');

      final adapter = _FakeAdapter((options) {
        if (options.path.endsWith('/auth/refresh')) {
          refreshCalls++;
          return _json({'access_token': 'x'}, 200);
        }
        // /auth/login etc. always 401 here.
        return _json({'detail': 'Invalid credentials'}, 401);
      });
      client.httpDioForTest.httpClientAdapter = adapter;
      client.refreshDioForTest.httpClientAdapter = adapter;

      await expectLater(
        client.post<Map<String, dynamic>>(
          '/auth/login',
          data: {'username': 'a', 'password': 'b'},
          fromJson: (json) => json as Map<String, dynamic>,
        ),
        throwsA(isA<ApiException>()),
      );

      expect(refreshCalls, 0, reason: 'auth endpoints must not loop');
    });

    test('concurrent 401s trigger only a single refresh', () async {
      var refreshCalls = 0;

      final client = ApiClient(baseUrl: 'http://test.local/api/v1');
      client.setAuthToken('expired-access');
      client.setRefreshToken('refresh-abc');

      final adapter = _FakeAdapter((options) {
        final path = options.path;
        if (path.endsWith('/auth/refresh')) {
          refreshCalls++;
          return _json({
            'access_token': 'fresh-access',
            'refresh_token': 'refresh-def',
          }, 200);
        }
        final auth = options.headers['Authorization'];
        if (auth == 'Bearer fresh-access') {
          return _json({'ok': true}, 200);
        }
        return _json({'detail': 'Not authenticated'}, 401);
      });
      client.httpDioForTest.httpClientAdapter = adapter;
      client.refreshDioForTest.httpClientAdapter = adapter;

      final results = await Future.wait([
        client.get<Map<String, dynamic>>('/apartments',
            fromJson: (j) => j as Map<String, dynamic>),
        client.get<Map<String, dynamic>>('/rooms',
            fromJson: (j) => j as Map<String, dynamic>),
        client.get<Map<String, dynamic>>('/orders',
            fromJson: (j) => j as Map<String, dynamic>),
      ]);

      expect(refreshCalls, 1);
      expect(results.every((r) => r['ok'] == true), isTrue);
    });

    test('refresh failure clears tokens and surfaces the original 401',
        () async {
      var cleared = false;

      final client = ApiClient(
        baseUrl: 'http://test.local/api/v1',
        onTokensCleared: () async {
          cleared = true;
        },
      );
      client.setAuthToken('expired-access');
      client.setRefreshToken('dead-refresh');

      final adapter = _FakeAdapter((options) {
        if (options.path.endsWith('/auth/refresh')) {
          return _json({'detail': 'Refresh token missing.'}, 401);
        }
        return _json({'detail': 'Not authenticated'}, 401);
      });
      client.httpDioForTest.httpClientAdapter = adapter;
      client.refreshDioForTest.httpClientAdapter = adapter;

      await expectLater(
        client.get<dynamic>('/apartments', fromJson: (j) => j),
        throwsA(isA<ApiException>()),
      );
      expect(cleared, isTrue);
    });

    for (final authPath in ['/auth/apple', '/auth/guest']) {
      final name = authPath == '/auth/apple'
          ? 'apple 401 does not refresh'
          : 'guest 401 does not refresh';
      test(name, () async {
        var refreshCalls = 0;
        var unauthorized = 0;
        final client = ApiClient(
          baseUrl: 'http://test.local/api/v1',
          onUnauthorized: () => unauthorized++,
        );
        client.setAuthToken('guest-access');
        client.setRefreshToken('guest-refresh');
        final adapter = _FakeAdapter((options) {
          if (options.path.endsWith('/auth/refresh')) {
            refreshCalls++;
            return _json({'access_token': 'x'}, 200);
          }
          return _json({'detail': 'Invalid token'}, 401);
        });
        client.httpDioForTest.httpClientAdapter = adapter;
        client.refreshDioForTest.httpClientAdapter = adapter;

        await expectLater(
          client.post<dynamic>(authPath, data: {}, fromJson: (j) => j),
          throwsA(isA<ApiException>()),
        );
        expect(refreshCalls, 0);
        expect(unauthorized, 0);
      });
    }
  });
}
