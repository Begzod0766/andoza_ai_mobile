import 'package:riverpod/riverpod.dart';
import '../models/api/api.dart';
import '../models/design_selection_model.dart';
import '../models/electrical_model.dart';
import '../models/shop_model.dart';
import '../utils/catalog_image.dart';
import '../utils/project_areas.dart';
import 'apartment_provider.dart';
import 'catalog_provider.dart';
import 'design_provider.dart';
import 'electrical_provider.dart';
import 'room_provider.dart';

/// A room the user can pick in Do'kon's room selector (S2), paired with its
/// apartment's name for display (`RoomOut` itself has no apartment
/// reference).
class SelectableRoom {
  const SelectableRoom({required this.room, required this.apartmentName});

  final RoomOut room;
  final String apartmentName;
}

/// Every room across every one of the user's apartments, flattened for the
/// S2 room picker — real backend data, not the single "whichever room was
/// last active" slot [activeRoomProvider] holds.
final selectableRoomsProvider = Provider<List<SelectableRoom>>((ref) {
  final apartments = ref.watch(apartmentsProvider).maybeWhen(
        data: (list) => list,
        orElse: () => const <Apartment>[],
      );
  return [
    for (final apartment in apartments)
      for (final room in apartment.rooms)
        SelectableRoom(room: room, apartmentName: apartment.name),
  ];
});

/// The room id the user explicitly picked in S2's room picker. Null means
/// "no explicit pick yet" — [_computeAreas] then falls back to whichever
/// room is globally active, matching the screen's behavior before the
/// picker existed.
final selectedShopRoomIdProvider = StateProvider<String?>((ref) => null);

ProjectAreas _computeAreas(Ref ref) {
  final selectedId = ref.watch(selectedShopRoomIdProvider);
  if (selectedId != null) {
    final rooms = ref.watch(selectableRoomsProvider);
    final selected =
        rooms.where((r) => r.room.id == selectedId).firstOrNull;
    if (selected != null) {
      return computeProjectAreasFromRoomOut(selected.room);
    }
  }
  return computeProjectAreas(
    ref.watch(activeRoomProvider),
    plan: ref.watch(activeRoomPlanProvider),
  );
}

/// Whether the room's starting condition already excludes [stage] from
/// the delta mechanic (shared with estimate_provider.dart so Do'kon
/// quantities and Smeta pricing always agree on which stages are needed).
bool stageExcluded(Ref ref, RenovationStage stage) {
  final design = ref.watch(activeDesignProvider);
  final condition = design?.roomCondition;
  if (condition == null) return false;
  final states = deriveStageStates(
    condition: condition,
    currentStage: design?.renovationStage ?? RenovationStage.suvoq,
  );
  return states[stage.index] == StageDisplayState.excluded;
}

/// Real device/wire counts from the active electrical layout (Batch D),
/// falling back to typical single-room defaults — shared by
/// shop_provider.dart (Do'kon quantities) and estimate_provider.dart
/// (Smeta pricing) so both agree on the same electrical scope.
class ElectricalNeed {
  const ElectricalNeed({
    required this.outletCount,
    required this.wireMeters,
    required this.switchCount,
    required this.lightCount,
    required this.pipeCount,
  });

  final int outletCount;
  final double wireMeters;
  final int switchCount;
  final int lightCount;
  final int pipeCount;
}

ElectricalNeed computeElectricalNeed(Ref ref) {
  final layout = ref.watch(electricalLayoutProvider);
  if (layout == null || layout.devices.isEmpty) {
    return const ElectricalNeed(
      outletCount: 8,
      wireMeters: 72.0,
      switchCount: 4,
      lightCount: 6,
      pipeCount: 4,
    );
  }
  int countOf(DeviceType type) =>
      layout.devices.where((d) => d.type == type).length;
  final outletCount = countOf(DeviceType.outlet);
  final wireMeters = computeTotalWireLengthMeters(layout);
  return ElectricalNeed(
    outletCount: outletCount > 0 ? outletCount : 8,
    wireMeters: wireMeters > 0 ? wireMeters : 72.0,
    switchCount: countOf(DeviceType.lightSwitch) > 0
        ? countOf(DeviceType.lightSwitch)
        : 4,
    lightCount: countOf(DeviceType.light) > 0 ? countOf(DeviceType.light) : 6,
    pipeCount: layout.pipes.isNotEmpty ? layout.pipes.length : 4,
  );
}

/// Maps a backend `Material.category` free-form string onto the UI's
/// [ShopCategory] enum. The two vocabularies diverge (server `plitka` vs UI
/// `kafel`, server `elektr_mat` vs UI `elektr`). Any future/unknown string
/// falls back to [ShopCategory.sement] so mapping never throws.
ShopCategory _mapCategory(String serverCategory) => switch (serverCategory) {
  'boyoq' => ShopCategory.boyoq,
  'oboy' => ShopCategory.oboy,
  'dekorativ' => ShopCategory.boyoq, // decorative coating → paint bucket
  'laminat' => ShopCategory.laminat,
  'parket' => ShopCategory.parket,
  'plitka' => ShopCategory.kafel,
  'gips' => ShopCategory.gips,
  'sement' => ShopCategory.sement,
  'santexnika' => ShopCategory.santexnika,
  'elektr_mat' => ShopCategory.elektr,
  'eshik' => ShopCategory.eshik,
  'deraza' => ShopCategory.deraza,
  _ => ShopCategory.sement,
};

/// Locally-computed "how much this project needs" for a product, keyed by its
/// mapped [ShopCategory] (and, for electrical, its [unit] to tell wire from
/// outlets). This is the delta mechanic preserved from the old hardcoded
/// catalog — server data has no such field, so it stays computed from the
/// active room/design/electrical state. Returns null when the category isn't
/// tied to a needed renovation stage.
double? _projectQuantityFor(
  ShopCategory category,
  String unit,
  ProjectAreas areas,
  ElectricalNeed electrical, {
  required bool shpaklovkaNeeded,
  required bool boyoqOboiNeeded,
  required bool polNeeded,
}) {
  switch (category) {
    case ShopCategory.gips:
      return shpaklovkaNeeded ? (areas.wallArea / 6).ceilToDouble() : null;
    case ShopCategory.oboy:
      return boyoqOboiNeeded ? (areas.wallArea / 5).ceilToDouble() : null;
    case ShopCategory.boyoq:
      return boyoqOboiNeeded
          ? double.parse((areas.wallArea * 0.2).toStringAsFixed(1))
          : null;
    case ShopCategory.laminat:
      return polNeeded
          ? double.parse((areas.floorArea * 1.1).toStringAsFixed(1))
          : null;
    case ShopCategory.elektr:
      // Cable is sold by the metre; outlets/switches by the piece.
      return unit == 'm'
          ? double.parse(electrical.wireMeters.toStringAsFixed(1))
          : double.parse(electrical.outletCount.toStringAsFixed(0));
    case ShopCategory.kafel:
    case ShopCategory.parket:
    case ShopCategory.sement:
    case ShopCategory.santexnika:
    case ShopCategory.eshik:
    case ShopCategory.deraza:
      return null;
  }
}

/// Maps the backend [Material] rows into UI [Product]s, re-attaching the
/// locally-computed [Product.projectQuantity] per mapped category. [stores]
/// (joined by `store_id`) supplies the [Product.brand] and the
/// [Product.isOfficialDealer] flag (gold/platinum partner tiers count as
/// official); missing stores default to official with an empty brand.
List<Product> _mapToProducts(
  List<Material> materials,
  List<Store> stores,
  Ref ref,
) {
  final areas = _computeAreas(ref);
  final electrical = computeElectricalNeed(ref);
  final shpaklovkaNeeded = !stageExcluded(ref, RenovationStage.shpaklovka);
  final boyoqOboiNeeded = !stageExcluded(ref, RenovationStage.boyoqOboi);
  final polNeeded = !stageExcluded(ref, RenovationStage.pol);

  final storeById = {for (final s in stores) s.id: s};

  return materials.map((m) {
    final category = _mapCategory(m.category);
    final store = storeById[m.storeId];
    final isOfficial = store == null ||
        store.partnerTier == 'gold' ||
        store.partnerTier == 'platinum';
    return Product(
      id: m.id,
      name: m.nameUz,
      brand: store?.name ?? '',
      category: category,
      pricePerUnit: m.priceUzs,
      unit: m.unit,
      isOfficialDealer: isOfficial,
      imageUrl: catalogImageUrl(m.imageUrl),
      storeId: m.storeId,
      projectQuantity: _projectQuantityFor(
        category,
        m.unit,
        areas,
        electrical,
        shpaklovkaNeeded: shpaklovkaNeeded,
        boyoqOboiNeeded: boyoqOboiNeeded,
        polNeeded: polNeeded,
      ),
    );
  }).toList();
}

/// The full Do'kon catalog, sourced from the backend `/materials` endpoint via
/// [materialsProvider], with [Product.projectQuantity] re-computed locally from
/// real room/design/electrical state (delta mechanic: excluded stages need no
/// material, so their products carry no project quantity).
///
/// Kept synchronous so its consumers stay unchanged: returns `[]` while the
/// async material/store lists are loading or errored, and the mapped catalog
/// once they resolve.
final shopCatalogProvider = Provider<List<Product>>((ref) {
  final stores = ref.watch(storesProvider).maybeWhen(
        data: (s) => s,
        orElse: () => const <Store>[],
      );
  return ref.watch(materialsProvider(null)).maybeWhen(
        data: (materials) => _mapToProducts(materials, stores, ref),
        orElse: () => const <Product>[],
      );
});

/// Catalog products whose name matches [query] (trimmed, at most 100
/// characters), searched by the server (`q`) over the whole catalog rather
/// than over what [shopCatalogProvider] loaded.
final shopSearchProvider =
    Provider.autoDispose.family<AsyncValue<List<Product>>, String>((ref, query) {
  final stores = ref.watch(storesProvider).valueOrNull ?? const <Store>[];
  return ref
      .watch(materialSearchProvider(query))
      .whenData((materials) => _mapToProducts(materials, stores, ref));
});

/// [text] as a catalog search: trimmed, cut to the server's 100 characters.
String shopSearchQuery(String text) {
  final q = text.trim();
  return q.length > 100 ? q.substring(0, 100) : q;
}

/// The error that made [shopCatalogProvider] empty, if any. [shopCatalogProvider]
/// itself collapses loading AND error into an empty list, so a screen watching
/// only the catalog can't tell "backend down" from "no results". Watch this
/// alongside it to show an error + retry instead of a misleading empty state;
/// it's `null` while loading and on success.
final shopCatalogErrorProvider = Provider<Object?>((ref) {
  return ref.watch(storesProvider).error ??
      ref.watch(materialsProvider(null)).error;
});

/// Whether the catalog is still loading, so the UI can distinguish "loading"
/// from "no results" — both of which leave [shopCatalogProvider] empty.
final shopCatalogLoadingProvider = Provider<bool>((ref) {
  return ref.watch(storesProvider).isLoading ||
      ref.watch(materialsProvider(null)).isLoading;
});

/// The requests behind [shopCatalogProvider]; invalidate these to retry.
final List<ProviderOrFamily> shopCatalogSources = [
  storesProvider,
  materialsProvider(null),
];

/// S2's grouped-by-stage list — only stages with a real (non-null)
/// project quantity for at least one product appear, so a stage the
/// room's starting condition already excludes never shows up here.
///
/// Built by grouping the catalog on the product's mapped [ShopCategory]
/// (not on fixed product ids, which the backend catalog doesn't have), so it
/// works over any set of real materials without crashing.
final projectMaterialsProvider = Provider<List<StageMaterialGroup>>((ref) {
  final catalog = ref.watch(shopCatalogProvider);

  const stageDefs = <(String, List<ShopCategory>)>[
    ('Shpaklovka', [ShopCategory.gips]),
    ('Bo\'yoq/Oboy', [ShopCategory.oboy, ShopCategory.boyoq]),
    ('Pol', [ShopCategory.laminat]),
    ('Elektr', [ShopCategory.elektr]),
  ];

  final groups = <StageMaterialGroup>[];
  for (final (label, cats) in stageDefs) {
    final items = [
      for (final p in catalog)
        if (cats.contains(p.category) && p.projectQuantity != null)
          StageMaterialItem(
            productId: p.id,
            name: p.name,
            quantity: p.projectQuantity!,
            unit: p.unit,
          ),
    ];
    if (items.isNotEmpty) {
      groups.add(StageMaterialGroup(stageLabel: label, items: items));
    }
  }

  return groups;
});

/// Total floor area covered by the active project's materials, shown in
/// S2's green banner ("34.6 m², 4 bosqich").
final projectMaterialsSummaryProvider = Provider<(double area, int stages)>((
  ref,
) {
  final areas = _computeAreas(ref);
  final groups = ref.watch(projectMaterialsProvider);
  return (areas.floorArea, groups.length);
});

/// The one offer we know is real without asking the server: the store that
/// listed this product, at its catalog price. Used until (or instead of)
/// per-store offers from `/materials/{id}/offers`. Delivery time is unknown,
/// so it is 0 and the UI leaves it out.
Dealer ownStoreDealer(Product product) => Dealer(
      id: product.storeId ?? product.id,
      name: product.brand,
      isOfficial: product.isOfficialDealer,
      district: '',
      deliveryDays: 0,
      pricePerUnit: product.pricePerUnit,
    );

/// Offers to show for [product] when the server has none: just its own store.
/// (This used to invent three dealers with made-up prices.)
List<Dealer> dealersForProduct(Product product) => [ownStoreDealer(product)];

/// Maps a real backend [MaterialOffer] onto the UI's [Dealer] shape so the
/// cart/checkout flow (which groups by `dealer.id` and prices off
/// `dealer.pricePerUnit`) works unchanged. Gold/platinum partner tiers count
/// as the "official" (verified) badge.
Dealer dealerFromOffer(MaterialOffer offer) => Dealer(
      id: offer.storeId,
      name: offer.storeName,
      isOfficial:
          offer.storePartnerTier == 'gold' ||
          offer.storePartnerTier == 'platinum',
      district: offer.storeDistrict ?? '',
      deliveryDays: offer.deliveryDays,
      pricePerUnit: offer.priceUzs,
    );

/// Best dealer per the spec's S4 rule: cheapest wins; official dealer
/// breaks ties in a way that favors trust over a marginal discount.
Dealer bestDealer(List<Dealer> dealers) {
  final sorted = [...dealers]
    ..sort((a, b) => a.pricePerUnit.compareTo(b.pricePerUnit));
  return sorted.first;
}
