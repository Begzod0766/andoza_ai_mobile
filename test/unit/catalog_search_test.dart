import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/providers/shop_provider.dart';
import 'package:tamir_uy_mobile_flutter/repositories/catalog_repository.dart';
import 'package:tamir_uy_mobile_flutter/services/api_client.dart';

/// Serves [total] furniture items, 100 a page, and records each request.
class _PagedAdapter implements HttpClientAdapter {
  _PagedAdapter(this.total);

  final int total;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final page = int.parse('${options.queryParameters['page']}');
    final start = (page - 1) * 100;
    final count = (total - start).clamp(0, 100);
    final items = [
      for (var i = start; i < start + count; i++)
        {'id': 'f$i', 'store_id': 's1', 'category': 'stol', 'name_uz': 'Stol $i', 'price_uzs': 1, 'styles': []},
    ];
    return ResponseBody.fromString(
      jsonEncode({'items': items, 'total': total, 'page': page, 'per_page': 100}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

(CatalogRepository, _PagedAdapter) _repo(int total) {
  final adapter = _PagedAdapter(total);
  final client = ApiClient(baseUrl: 'http://test.local/api/v1');
  client.httpDioForTest.httpClientAdapter = adapter;
  return (CatalogRepository(client), adapter);
}

void main() {
  test('the whole catalog is fetched, page after page', () async {
    final (repo, adapter) = _repo(267);
    final items = await repo.getAllFurniture();
    expect(items, hasLength(267));
    expect(adapter.requests.map((r) => r.queryParameters['page']), [1, 2, 3]);
    expect(adapter.requests.every((r) => r.queryParameters['per_page'] == 100), isTrue);
  });

  test('a search is sent to the server as q', () async {
    final (repo, adapter) = _repo(3);
    await repo.getAllFurniture(query: 'stol');
    expect(adapter.requests.single.queryParameters['q'], 'stol');
  });

  test('paging stops at the page cap', () async {
    final (repo, adapter) = _repo(5000);
    expect(await repo.getAllFurniture(maxPages: 2), hasLength(200));
    expect(adapter.requests, hasLength(2));
  });

  test('a search is trimmed and kept within the server limit', () {
    expect(shopSearchQuery('  divan '), 'divan');
    expect(shopSearchQuery('a' * 150), 'a' * 100);
  });
}
