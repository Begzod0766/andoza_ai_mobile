import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/models/api/api.dart';
import 'package:tamir_uy_mobile_flutter/repositories/catalog_repository.dart';
import 'package:tamir_uy_mobile_flutter/screens/shop/furniture_detail_screen.dart';
import 'package:tamir_uy_mobile_flutter/screens/shop/store_page_screen.dart';
import 'package:tamir_uy_mobile_flutter/screens/studio/studio_webview_screen.dart';
import 'package:tamir_uy_mobile_flutter/services/api_client.dart';

class _Adapter implements HttpClientAdapter {
  _Adapter(this.body);

  final String body;
  RequestOptions? last;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    last = options;
    return ResponseBody.fromString(
      body,
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

const _furnitureJson =
    '{"id":"f1","store_id":"s1","store_name":"Mebel Plus","category":"divan",'
    '"room_type":null,"placement":"pol","model_yaw":0,"name_uz":"Divan",'
    '"price_uzs":4500000,"glb_url":"https://andozaai.uz/media/a.glb",'
    '"thumbnail_url":"https://andozaai.uz/media/a.png","footprint_w":220.0,'
    '"footprint_d":90.0,"height_cm":80.0,"styles":[]}';

(CatalogRepository, _Adapter) _repo(String body) {
  final adapter = _Adapter(body);
  final client = ApiClient(baseUrl: 'http://test.local/api/v1');
  client.httpDioForTest.httpClientAdapter = adapter;
  return (CatalogRepository(client), adapter);
}

void main() {
  group('catalog repository', () {
    test('a shop is fetched by id', () async {
      final (repo, adapter) = _repo(
        '{"id":"s1","name":"Mebel Plus","district":null,"phone":null,'
        '"telegram":null,"logo_color":null,"partner_tier":"standard"}',
      );
      final store = await repo.getStore('s1');
      expect(adapter.last!.path, endsWith('/stores/s1'));
      expect(store.name, 'Mebel Plus');
    });

    test("a shop's furniture is filtered on the server", () async {
      final (repo, adapter) = _repo(
        '{"items":[$_furnitureJson],"total":1,"page":1,"per_page":100}',
      );
      final page = await repo.getFurniture(storeId: 's1', perPage: 100);
      expect(adapter.last!.path, endsWith('/furniture'));
      expect(adapter.last!.queryParameters, {
        'store': 's1',
        'page': 1,
        'per_page': 100,
      });
      final item = page.items.single;
      expect(item.storeName, 'Mebel Plus');
      expect(item.glbUrl, 'https://andozaai.uz/media/a.glb');
      expect(item.thumbnailUrl, 'https://andozaai.uz/media/a.png');
      expect(item.heightCm, 80);
    });

    test('one furniture item by id', () async {
      final (repo, adapter) = _repo(_furnitureJson);
      final item = await repo.getFurnitureItem('f1');
      expect(adapter.last!.path, endsWith('/furniture/f1'));
      expect(item.nameUz, 'Divan');
    });
  });

  group('telegramUri', () {
    test('accepts a handle in any of the usual forms', () {
      for (final raw in [
        '@mebelplus',
        'mebelplus',
        't.me/mebelplus',
        'https://t.me/mebelplus/',
        ' @mebelplus ',
      ]) {
        expect(
          telegramUri(raw),
          Uri.parse('https://t.me/mebelplus'),
          reason: raw,
        );
      }
    });

    test('drops anything that is not a username', () {
      for (final raw in [
        null,
        '',
        'abc',
        'javascript:alert(1)',
        'https://evil.example/mebelplus',
        't.me/mebel plus',
      ]) {
        expect(telegramUri(raw), isNull, reason: raw);
      }
    });
  });

  group('phoneUri', () {
    test('rebuilds the number from its digits', () {
      expect(phoneUri('+998 90 123-45-67'), Uri.parse('tel:+998901234567'));
      expect(phoneUri('90 123 45 67'), Uri.parse('tel:+998901234567'));
    });

    test('drops what cannot be a number', () {
      expect(phoneUri(null), isNull);
      expect(phoneUri('12-34'), isNull);
      expect(phoneUri('javascript:alert(1)'), isNull);
    });
  });

  group('furnitureSizeLabel', () {
    test('W × D × H, whole centimetres without decimals', () {
      expect(
        furnitureSizeLabel(
          const Furniture(
            id: 'f',
            category: 'divan',
            nameUz: 'D',
            footprintW: 220,
            footprintD: 90.5,
            heightCm: 80,
          ),
        ),
        '220 × 90.5 × 80',
      );
    });

    test('no height: W × D; no footprint: null', () {
      expect(
        furnitureSizeLabel(
          const Furniture(
            id: 'f',
            category: 'divan',
            nameUz: 'D',
            footprintW: 220,
            footprintD: 90,
          ),
        ),
        '220 × 90',
      );
      expect(
        furnitureSizeLabel(
          const Furniture(id: 'f', category: 'divan', nameUz: 'D'),
        ),
        isNull,
      );
    });
  });

  test('the studio path carries the furniture to place', () {
    expect(studioRoomPath('r1', place: 'f1'), '/studio/r1?place=f1');
    expect(studioRoomPath('r1'), '/studio/r1');
  });
}
