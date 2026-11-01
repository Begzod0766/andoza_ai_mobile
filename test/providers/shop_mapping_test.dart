import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:tamir_uy_mobile_flutter/models/api/api.dart';
import 'package:tamir_uy_mobile_flutter/models/shop_model.dart';
import 'package:tamir_uy_mobile_flutter/providers/catalog_provider.dart';
import 'package:tamir_uy_mobile_flutter/providers/shop_provider.dart';

/// Drives the real backend-`Material` → UI-`Product` mapping through
/// [shopCatalogProvider] with the async material/store lists overridden by
/// fakes, so no real HTTP happens. The active room/design/electrical
/// providers keep their (null) defaults, which fall back to the typical
/// single-room baseline.
Future<List<Product>> _catalog(
  List<Material> materials, {
  List<Store> stores = const [],
}) async {
  final container = ProviderContainer(
    overrides: [
      materialsProvider(null).overrideWith((ref) async => materials),
      storesProvider.overrideWith((ref) async => stores),
    ],
  );
  addTearDown(container.dispose);
  // Let the overridden futures resolve before reading the synchronous
  // catalog provider (which yields [] while its sources are loading).
  await container.read(materialsProvider(null).future);
  await container.read(storesProvider.future);
  return container.read(shopCatalogProvider);
}

Material _material({
  required String id,
  required String category,
  String nameUz = 'Mahsulot',
  String unit = 'kg',
  int priceUzs = 10000,
  String storeId = 'store-1',
}) =>
    Material(
      id: id,
      storeId: storeId,
      category: category,
      nameUz: nameUz,
      unit: unit,
      priceUzs: priceUzs,
    );

void main() {
  group('_mapCategory (via shopCatalogProvider) — category vocabulary bridge', () {
    test('server plitka maps to UI kafel', () async {
      final catalog = await _catalog([_material(id: 'm1', category: 'plitka')]);
      expect(catalog.single.category, ShopCategory.kafel);
    });

    test('server elektr_mat maps to UI elektr', () async {
      final catalog =
          await _catalog([_material(id: 'm1', category: 'elektr_mat', unit: 'm')]);
      expect(catalog.single.category, ShopCategory.elektr);
    });

    test('direct-name categories pass straight through', () async {
      final catalog = await _catalog([
        _material(id: 'a', category: 'boyoq'),
        _material(id: 'b', category: 'oboy'),
        _material(id: 'c', category: 'laminat'),
        _material(id: 'd', category: 'gips'),
        _material(id: 'e', category: 'sement'),
        _material(id: 'f', category: 'santexnika'),
        _material(id: 'g', category: 'parket'),
      ]);
      final byId = {for (final p in catalog) p.id: p.category};
      expect(byId['a'], ShopCategory.boyoq);
      expect(byId['b'], ShopCategory.oboy);
      expect(byId['c'], ShopCategory.laminat);
      expect(byId['d'], ShopCategory.gips);
      expect(byId['e'], ShopCategory.sement);
      expect(byId['f'], ShopCategory.santexnika);
      expect(byId['g'], ShopCategory.parket);
    });

    test('dekorativ collapses onto the paint bucket (boyoq)', () async {
      final catalog =
          await _catalog([_material(id: 'm1', category: 'dekorativ')]);
      expect(catalog.single.category, ShopCategory.boyoq);
    });

    test('doors and windows get their own category; unknown falls back to sement',
        () async {
      final catalog = await _catalog([
        _material(id: 'door', category: 'eshik'),
        _material(id: 'window', category: 'deraza'),
        _material(id: 'weird', category: 'totally_unknown_category'),
      ]);
      final byId = {for (final p in catalog) p.id: p.category};
      expect(byId['door'], ShopCategory.eshik);
      expect(byId['window'], ShopCategory.deraza);
      expect(byId['weird'], ShopCategory.sement);
    });
  });

  group('Material → Product field mapping', () {
    test('name_uz → name and price_uzs → pricePerUnit are carried across',
        () async {
      final catalog = await _catalog([
        _material(
          id: 'm1',
          category: 'boyoq',
          nameUz: 'Tikkurila Euro 3 Oq',
          unit: 'litr',
          priceUzs: 45000,
        ),
      ]);
      final product = catalog.single;
      expect(product.id, 'm1');
      expect(product.name, 'Tikkurila Euro 3 Oq');
      expect(product.pricePerUnit, 45000);
      expect(product.unit, 'litr');
    });

    test('store partner tier drives the official-dealer badge', () async {
      const stores = [
        Store(id: 'gold', name: 'Gold Store', partnerTier: 'gold'),
        Store(id: 'silver', name: 'Silver Store', partnerTier: 'silver'),
      ];
      final catalog = await _catalog(
        [
          _material(id: 'g', category: 'boyoq', storeId: 'gold'),
          _material(id: 's', category: 'boyoq', storeId: 'silver'),
          _material(id: 'orphan', category: 'boyoq', storeId: 'missing'),
        ],
        stores: stores,
      );
      final byId = {for (final p in catalog) p.id: p};
      // Gold/platinum tiers are "official"; a missing store defaults official.
      expect(byId['g']!.isOfficialDealer, isTrue);
      expect(byId['g']!.brand, 'Gold Store');
      expect(byId['s']!.isOfficialDealer, isFalse);
      expect(byId['orphan']!.isOfficialDealer, isTrue);
      expect(byId['orphan']!.brand, '');
    });
  });

  group('projectQuantity delta mechanic (default single-room baseline)', () {
    test('a stage-linked material gets a computed quantity', () async {
      // gips (shpaklovka) is a needed stage by default → non-null quantity.
      final catalog = await _catalog([_material(id: 'm1', category: 'gips')]);
      expect(catalog.single.projectQuantity, isNotNull);
      expect(catalog.single.isInProject, isTrue);
    });

    test('a non-stage material (sement) carries no project quantity', () async {
      final catalog = await _catalog([_material(id: 'm1', category: 'sement')]);
      expect(catalog.single.projectQuantity, isNull);
      expect(catalog.single.isInProject, isFalse);
    });
  });
}
