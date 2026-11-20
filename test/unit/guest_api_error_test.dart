import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/models/user_model.dart';
import 'package:tamir_uy_mobile_flutter/services/api_client.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this._handle);

  final ResponseBody Function(RequestOptions options) _handle;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async =>
      _handle(options);

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

Map<String, dynamic> _gate(String feature) => {
      'detail': {
        'code': 'registration_required',
        'feature': feature,
        'message': "Ro'yxatdan o'ting",
      },
    };

ApiClient _client(ResponseBody Function(RequestOptions) handle) {
  final client = ApiClient(baseUrl: 'http://test.local/api/v1');
  final adapter = _FakeAdapter(handle);
  client.httpDioForTest.httpClientAdapter = adapter;
  client.refreshDioForTest.httpClientAdapter = adapter;
  return client;
}

void main() {
  test('User parses is_guest', () {
    expect(User.fromJson({'id': 'u', 'is_guest': true}).isGuest, isTrue);
    expect(User.fromJson({'id': 'u'}).isGuest, isFalse);
  });

  test('AuthResponse parses guest_merged_rooms', () {
    final base = {
      'access_token': 'a',
      'user': {'id': 'u'},
    };
    expect(
      AuthResponse.fromJson({...base, 'guest_merged_rooms': 3})
          .guestMergedRooms,
      3,
    );
    expect(AuthResponse.fromJson(base).guestMergedRooms, isNull);
  });

  test('403 carries code and feature', () async {
    final client = _client((_) => _json(_gate('render'), 403));
    final e = await client
        .post<dynamic>('/render', data: {}, fromJson: (j) => j)
        .then<Object>((_) => 'no error', onError: (Object e) => e);
    expect(e, isA<ApiException>());
    final api = e as ApiException;
    expect(
      [api.isRegistrationRequired, api.feature, api.message],
      [true, 'render', "Ro'yxatdan o'ting"],
    );
  });

  test('stream 403 carries code and feature', () async {
    final client = _client((_) => _json(_gate('ai_build'), 403));
    await expectLater(
      client.stream('/rooms/r/ai-build', data: {'prompt': 'x'}),
      emitsError(
        isA<ApiException>()
            .having((e) => e.feature, 'feature', 'ai_build')
            .having((e) => e.isRegistrationRequired, 'gate', isTrue),
      ),
    );
  });

  test('a plain-string 403 has no code', () async {
    final client = _client(
      (_) => _json({'detail': 'Faqat sotuvchi va administrator uchun'}, 403),
    );
    final e = await client
        .post<dynamic>('/models/from-photo', data: {}, fromJson: (j) => j)
        .then<Object>((_) => 'no error', onError: (Object e) => e);
    final api = e as ApiException;
    expect(api.code, isNull);
    expect(api.isRegistrationRequired, isFalse);
    expect(api.statusCode, 403);
  });
}
