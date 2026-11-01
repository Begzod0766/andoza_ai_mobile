import '../models/api/api.dart';
import '../services/api_client.dart';

/// Read access to the backend catalog: materials, furniture, partner stores,
/// and the craftsmen (ustalar) directory. Endpoints are mounted under
/// `/api/v1`, so paths here are relative to that base (see [ApiClient]).
///
/// The backend caches these responses for 10 minutes; callers can layer their
/// own provider-level caching on top (Riverpod keeps the future alive while
/// watched).
class CatalogRepository {
  CatalogRepository(this._client);

  final ApiClient _client;

  /// Paginated active materials, optionally filtered by [category] (e.g.
  /// `boyoq`, `oboy`, `laminat`, `plitka`, `eshik`, `deraza`, `gips`) and/or a
  /// specific [storeId].
  Future<PaginatedMaterials> getMaterials({
    String? category,
    String? storeId,
    String? query,
    int page = 1,
    int perPage = 20,
  }) {
    return _client.get<PaginatedMaterials>(
      '/materials',
      queryParameters: _params({
        'category': category,
        'store': storeId,
        'q': query,
        'page': page,
        'per_page': perPage,
      }),
      fromJson: (json) =>
          PaginatedMaterials.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Paginated furniture / 3D-model catalog — shops' own models — optionally
  /// filtered by [category] and/or one shop ([storeId]).
  Future<PaginatedFurniture> getFurniture({
    String? category,
    String? storeId,
    String? query,
    int page = 1,
    int perPage = 20,
  }) {
    return _client.get<PaginatedFurniture>(
      '/furniture',
      queryParameters: _params({
        'category': category,
        'store': storeId,
        'q': query,
        'page': page,
        'per_page': perPage,
      }),
      fromJson: (json) =>
          PaginatedFurniture.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Every active material matching the filters, page after page (the
  /// server caps a page at 100), up to [maxPages] pages. [query] is the
  /// server-side name search (`q`, at most 100 characters).
  Future<List<Material>> getAllMaterials({String? category, String? query, int maxPages = 10}) {
    return _allPages(
      (page) async {
        final r = await getMaterials(category: category, query: query, page: page, perPage: 100);
        return (items: r.items, total: r.total);
      },
      maxPages,
    );
  }

  /// Every live furniture item matching the filters, as [getAllMaterials].
  Future<List<Furniture>> getAllFurniture({String? category, String? query, int maxPages = 10}) {
    return _allPages(
      (page) async {
        final r = await getFurniture(category: category, query: query, page: page, perPage: 100);
        return (items: r.items, total: r.total);
      },
      maxPages,
    );
  }

  static Future<List<T>> _allPages<T>(
    Future<({List<T> items, int total})> Function(int page) fetch,
    int maxPages,
  ) async {
    final all = <T>[];
    for (var page = 1; page <= maxPages; page++) {
      final r = await fetch(page);
      all.addAll(r.items);
      if (r.items.isEmpty || all.length >= r.total) break;
    }
    return all;
  }

  /// One live furniture item (`GET /furniture/{id}`); 404 once it is off sale.
  Future<Furniture> getFurnitureItem(String id) {
    return _client.get<Furniture>(
      '/furniture/$id',
      fromJson: (json) => Furniture.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Per-store offers for a single material (`GET /materials/{id}/offers`),
  /// cheapest first. Each row is a real price/stock/delivery quote from one
  /// store for [materialId] — what S4's dealer comparison lists.
  Future<List<MaterialOffer>> getMaterialOffers(String materialId) {
    return _client.get<List<MaterialOffer>>(
      '/materials/$materialId/offers',
      fromJson: (json) => (json as List<dynamic>)
          .map((e) => MaterialOffer.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// All active partner stores (ordered by tier then name on the server).
  Future<List<Store>> getStores() {
    return _client.get<List<Store>>(
      '/stores',
      fromJson: (json) => (json as List<dynamic>)
          .map((e) => Store.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// One open shop (`GET /stores/{id}`), for its page; 404 when it is closed.
  Future<Store> getStore(String id) {
    return _client.get<Store>(
      '/stores/$id',
      fromJson: (json) => Store.fromJson(json as Map<String, dynamic>),
    );
  }

  /// The craftsmen directory, optionally filtered by [category] and/or
  /// [district]. Ordered by rating (desc) on the server.
  Future<List<Usta>> getUstalar({String? category, String? district}) {
    return _client.get<List<Usta>>(
      '/ustalar',
      queryParameters: _params({'category': category, 'district': district}),
      fromJson: (json) => (json as List<dynamic>)
          .map((e) => Usta.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Drops null-valued entries so dio doesn't send `?category=null`.
  Map<String, dynamic> _params(Map<String, dynamic> raw) {
    final out = <String, dynamic>{};
    raw.forEach((k, v) {
      if (v != null) out[k] = v;
    });
    return out;
  }
}
