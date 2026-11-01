import 'package:riverpod/riverpod.dart';

import '../models/api/api.dart';
import '../repositories/catalog_repository.dart';
import 'auth_provider.dart';

/// Backend catalog repository (materials, furniture, stores, ustalar).
final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return CatalogRepository(ref.watch(apiClientProvider));
});

/// Active materials, optionally filtered by category (null = all). All pages:
/// the catalog outgrew one page of 100 (the demo shops alone add ~270).
final materialsProvider =
    FutureProvider.autoDispose.family<List<Material>, String?>((ref, category) {
  return ref.watch(catalogRepositoryProvider).getAllMaterials(category: category);
});

/// Materials whose name matches a search, found by the server (`q`), so the
/// whole catalog is searched, not just what was loaded.
final materialSearchProvider =
    FutureProvider.autoDispose.family<List<Material>, String>((ref, query) {
  return ref.watch(catalogRepositoryProvider).getAllMaterials(query: query);
});

/// Furniture / 3D-model catalog, optionally filtered by category (null = all).
final furnitureProvider =
    FutureProvider.autoDispose.family<List<Furniture>, String?>((ref, category) {
  return ref.watch(catalogRepositoryProvider).getAllFurniture(category: category);
});

/// Furniture whose name matches a search, found by the server (`q`).
final furnitureSearchProvider =
    FutureProvider.autoDispose.family<List<Furniture>, String>((ref, query) {
  return ref.watch(catalogRepositoryProvider).getAllFurniture(query: query);
});

/// One shop's own furniture / 3D models, for its page.
final storeFurnitureProvider = FutureProvider.autoDispose
    .family<List<Furniture>, String>((ref, storeId) async {
      final repo = ref.watch(catalogRepositoryProvider);
      final result = await repo.getFurniture(storeId: storeId, perPage: 100);
      return result.items;
    });

/// One furniture item by id — for its page when it was opened without the
/// item in hand (a deep link, or a list that has since changed).
final furnitureItemProvider = FutureProvider.autoDispose
    .family<Furniture, String>((ref, id) {
      return ref.watch(catalogRepositoryProvider).getFurnitureItem(id);
    });

/// One open shop, for its page.
final storeProvider = FutureProvider.autoDispose.family<Store, String>((
  ref,
  id,
) {
  return ref.watch(catalogRepositoryProvider).getStore(id);
});

/// All active partner stores.
final storesProvider = FutureProvider.autoDispose<List<Store>>((ref) {
  return ref.watch(catalogRepositoryProvider).getStores();
});

/// Real per-store offers for one material (S4 dealer comparison), cheapest
/// first from the server.
final materialOffersProvider =
    FutureProvider.autoDispose.family<List<MaterialOffer>, String>((ref, materialId) {
  return ref.watch(catalogRepositoryProvider).getMaterialOffers(materialId);
});

/// Filter key for the ustalar directory. A record so the FutureProvider.family
/// gets structural equality for free (same category+district → same request).
typedef UstaFilter = ({String? category, String? district});

/// The craftsmen directory, optionally filtered by category/district.
final ustalarProvider =
    FutureProvider.autoDispose.family<List<Usta>, UstaFilter>((ref, filter) {
  return ref.watch(catalogRepositoryProvider).getUstalar(
        category: filter.category,
        district: filter.district,
      );
});
