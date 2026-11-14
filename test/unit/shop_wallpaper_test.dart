import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/models/business_profile.dart';
import 'package:tamir_uy_mobile_flutter/repositories/business_repository.dart';
import 'package:tamir_uy_mobile_flutter/services/api_client.dart';

const _row = {
  'id': 'w1',
  'name': 'Gul',
  'kind': 'oboy',
  'store_id': 's1',
  'store_name': 'Dokon',
  'price_uzs': 120000,
  'description': null,
  'width_cm': 106.5,
  'height_cm': null,
  'total_length_m': 10,
  'url': 'https://x/w1.jpg',
  'content_type': 'image/jpeg',
  'size_bytes': 10,
  'created_at': '2026-11-15T10:00:00Z',
  'status': 'rejected',
  'moderation_note': "Do'kon olib tashladi",
};

class _Adapter implements HttpClientAdapter {
  RequestOptions? last;
  String body = '{}';
  int code = 200;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    last = options;
    return ResponseBody.fromString(body, code, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('fromJson reads the backend WallpaperOut', () {
    final w = ShopWallpaper.fromJson(Map<String, dynamic>.from(_row));
    expect(w.id, 'w1');
    expect(w.priceUzs, 120000);
    expect(w.widthCm, 106.5);
    expect(w.totalLengthM, 10.0);
    expect(w.status, 'rejected');
    expect(w.createdAt, DateTime.utc(2026, 11, 15, 10));
    expect(w.isRemovedByShop, isTrue);
  });

  test('nulls and a plain rejection are not "removed by shop"', () {
    final w = ShopWallpaper.fromJson({
      ..._row,
      'price_uzs': null,
      'width_cm': null,
      'total_length_m': null,
      'moderation_note': 'Sifatsiz',
    });
    expect(w.priceUzs, isNull);
    expect(w.widthCm, isNull);
    expect(w.isRemovedByShop, isFalse);
  });

  group('repository', () {
    late _Adapter adapter;
    late BusinessRepository repo;

    setUp(() {
      adapter = _Adapter();
      final client = ApiClient(baseUrl: 'http://test.local/api/v1');
      client.httpDioForTest.httpClientAdapter = adapter;
      repo = BusinessRepository(client);
    });

    test('fetchWallpapers GETs the list', () async {
      adapter.body = '[${_json(_row)}]';
      final list = await repo.fetchWallpapers();
      expect(adapter.last!.method, 'GET');
      expect(adapter.last!.path, endsWith('/seller/wallpapers'));
      expect(list.single.name, 'Gul');
    });

    test('addWallpaper POSTs the file and string fields', () async {
      adapter.body = _json(_row);
      adapter.code = 201;
      await repo.addWallpaper(
        bytes: [1],
        filename: 'a.jpg',
        contentType: 'image/jpeg',
        name: 'Gul',
        priceUzs: 120000,
        widthCm: 106.5,
        totalLengthM: 10,
      );
      expect(adapter.last!.method, 'POST');
      expect(adapter.last!.path, endsWith('/seller/wallpapers'));
      final form = adapter.last!.data as FormData;
      expect(form.files.map((f) => f.key), ['file']);
      expect(Map.fromEntries(form.fields), {
        'name': 'Gul',
        'price_uzs': '120000',
        'width_cm': '106.5',
        'total_length_m': '10.0',
      });
    });

    test('updateWallpaper PATCHes only what changed, no file', () async {
      adapter.body = _json(_row);
      await repo.updateWallpaper('w1', priceUzs: 99000);
      expect(adapter.last!.method, 'PATCH');
      expect(adapter.last!.path, endsWith('/seller/wallpapers/w1'));
      final form = adapter.last!.data as FormData;
      expect(form.files, isEmpty);
      expect(Map.fromEntries(form.fields), {'price_uzs': '99000'});
    });

    test('updateWallpaper sends a replacement file', () async {
      adapter.body = _json(_row);
      await repo.updateWallpaper('w1', bytes: [1], filename: 'b.png', contentType: 'image/png');
      final form = adapter.last!.data as FormData;
      expect(form.files.map((f) => f.key), ['file']);
    });

    test('deleteWallpaper DELETEs', () async {
      adapter.code = 204;
      adapter.body = '';
      await repo.deleteWallpaper('w1');
      expect(adapter.last!.method, 'DELETE');
      expect(adapter.last!.path, endsWith('/seller/wallpapers/w1'));
    });
  });
}

String _json(Map<String, Object?> m) => jsonEncode(m);
