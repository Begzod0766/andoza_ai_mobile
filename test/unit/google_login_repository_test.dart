import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/repositories/auth_repository.dart';
import 'package:tamir_uy_mobile_flutter/services/api_client.dart';
import 'package:tamir_uy_mobile_flutter/services/secure_storage.dart';

class _Adapter implements HttpClientAdapter {
  RequestOptions? last;
  int status = 200;
  Object? body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    last = options;
    return ResponseBody.fromString(
      body == null ? '' : jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late _Adapter adapter;
  late ApiClient client;
  late SecureStorageService storage;
  late AuthRepositoryImpl repo;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    adapter = _Adapter();
    client = ApiClient(baseUrl: 'http://test.local/api/v1');
    client.httpDioForTest.httpClientAdapter = adapter;
    storage = SecureStorageService();
    repo = AuthRepositoryImpl(client, storage);
  });

  test('posts {"id_token": ...} to /auth/google and persists the session',
      () async {
    adapter.body = {
      'access_token': 'acc',
      'refresh_token': 'ref',
      'token_type': 'bearer',
      'user': {'id': 'u1', 'username': 'g'},
    };

    final res = await repo.loginWithGoogle('google-id-token');

    expect(adapter.last!.method, 'POST');
    expect(adapter.last!.path, endsWith('/auth/google'));
    expect(adapter.last!.data, {'id_token': 'google-id-token'});
    expect(res.user.id, 'u1');
    expect(repo.token, 'acc');
    expect(repo.cachedUser?.id, 'u1');
    expect(await storage.getToken(), 'acc');
    expect(await storage.getRefreshToken(), 'ref');
    expect(await storage.getUserId(), 'u1');
  });

  test('401 surfaces as AuthException carrying the status', () async {
    adapter
      ..status = 401
      ..body = {'detail': "Google tokeni yaroqsiz"};

    await expectLater(
      repo.loginWithGoogle('bad'),
      throwsA(isA<AuthException>()
          .having((e) => e.statusCode, 'statusCode', 401)),
    );
    expect(repo.token, isNull);
  });

  test('posts the Apple identity token and name to /auth/apple', () async {
    adapter.body = {
      'access_token': 'acc',
      'refresh_token': 'ref',
      'token_type': 'bearer',
      'user': {'id': 'u2'},
    };

    final res = await repo.loginWithApple('apple-token', name: 'Ali Valiyev');

    expect(adapter.last!.path, endsWith('/auth/apple'));
    expect(adapter.last!.data,
        {'identity_token': 'apple-token', 'name': 'Ali Valiyev'});
    expect(res.user.id, 'u2');
    expect(await storage.getToken(), 'acc');
  });

  test('no name key when Apple did not share one', () async {
    adapter.body = {
      'access_token': 'acc',
      'token_type': 'bearer',
      'user': {'id': 'u2'},
    };

    await repo.loginWithApple('apple-token');

    expect(adapter.last!.data, {'identity_token': 'apple-token'});
  });
}
