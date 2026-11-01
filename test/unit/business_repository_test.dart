import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/repositories/business_repository.dart';
import 'package:tamir_uy_mobile_flutter/services/api_client.dart';

class _Adapter implements HttpClientAdapter {
  RequestOptions? last;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    last = options;
    return ResponseBody.fromString('{"job_id":"j1"}', 200, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late _Adapter adapter;
  late BusinessRepository repo;

  setUp(() {
    adapter = _Adapter();
    final client = ApiClient(baseUrl: 'http://test.local/api/v1');
    client.httpDioForTest.httpClientAdapter = adapter;
    repo = BusinessRepository(client);
  });

  test('single photo uploads only the file field', () async {
    final id = await repo.startModelFromPhoto([1], 'photo.jpg', 'image/jpeg');
    expect(id, 'j1');
    final form = adapter.last!.data as FormData;
    expect(form.files.map((f) => f.key), ['file']);
  });

  test('extra views are sent as left/back/right fields', () async {
    await repo.startModelFromPhoto(
      [1],
      'photo.jpg',
      'image/jpeg',
      extraViews: {
        'left': ([2], 'left.jpg', 'image/jpeg'),
        'right': ([3], 'right.png', 'image/png'),
      },
    );
    final form = adapter.last!.data as FormData;
    expect(form.files.map((f) => f.key), ['file', 'left', 'right']);
  });

  test('updateShop drops blank name and phone', () async {
    try {
      await repo.updateShop(name: ' ', phone: '', district: 'Chilonzor');
    } catch (_) {} // the fake returns a job body, not a shop
    expect(adapter.last!.path, endsWith('/seller/store'));
    expect(adapter.last!.data, {'district': 'Chilonzor'});
  });

  test('sendLead sends message only when not blank', () async {
    try {
      await repo.sendLead('u1', message: '  ');
    } catch (_) {}
    expect(adapter.last!.data, {'usta_id': 'u1'});
    try {
      await repo.sendLead('u1', message: ' salom ');
    } catch (_) {}
    expect(adapter.last!.data, {'usta_id': 'u1', 'message': 'salom'});
  });

  test('addPortfolioItem uploads file with caption field', () async {
    try {
      await repo.addPortfolioItem([1], 'a.png', 'image/png', caption: 'Hammom');
    } catch (_) {} // the fake returns a job body, not an item
    expect(adapter.last!.path, endsWith('/usta/portfolio'));
    expect(adapter.last!.method, 'POST');
    final form = adapter.last!.data as FormData;
    expect(form.files.map((f) => f.key), ['file']);
    expect(form.fields.map((f) => '${f.key}=${f.value}'), ['caption=Hammom']);
  });

  test('addPortfolioItem omits a blank caption', () async {
    try {
      await repo.addPortfolioItem([1], 'a.jpg', 'image/jpeg', caption: ' ');
    } catch (_) {}
    final form = adapter.last!.data as FormData;
    expect(form.fields, isEmpty);
  });

  test('createProduct sends the styles comma-separated, and none when empty', () async {
    Future<void> create(List<String> styles) async {
      try {
        await repo.createProduct(
          glb: [1],
          thumbnail: [2],
          thumbnailType: 'image/jpeg',
          name: 'Divan',
          category: 'divan',
          placement: 'pol',
          styles: styles,
        );
      } catch (_) {} // the fake returns a job body, not a product
    }

    await create(['zamonaviy', 'loft']);
    var form = adapter.last!.data as FormData;
    expect(
      form.fields.where((f) => f.key == 'styles').map((f) => f.value),
      ['zamonaviy,loft'],
    );

    await create(const []);
    form = adapter.last!.data as FormData;
    expect(form.fields.where((f) => f.key == 'styles'), isEmpty);
  });

  test('updateProduct sends styles only when given; [] clears them', () async {
    try {
      await repo.updateProduct('f1', name: 'Stol');
    } catch (_) {}
    expect(adapter.last!.data, {'name_uz': 'Stol'});
    try {
      await repo.updateProduct('f1', styles: const []);
    } catch (_) {}
    expect(adapter.last!.data, {'styles': <String>[]});
  });

  test('deletePortfolioItem calls DELETE', () async {
    try {
      await repo.deletePortfolioItem('p1');
    } catch (_) {}
    expect(adapter.last!.method, 'DELETE');
    expect(adapter.last!.path, endsWith('/usta/portfolio/p1'));
  });
}
