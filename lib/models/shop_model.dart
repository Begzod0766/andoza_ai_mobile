/// Do'kon (Batch S) domain types.
library;

import '../l10n/app_localizations.dart';

// Mock/local-only — no backend `/shop` endpoint exists, same rationale as
// masters_provider.dart's [MockMaster].

enum ShopCategory {
  boyoq,
  oboy,
  laminat,
  kafel,
  parket,
  gips,
  sement,
  santexnika,
  elektr,
  eshik,
  deraza,
}

extension ShopCategoryInfo on ShopCategory {
  String label(AppLocalizations l10n) => switch (this) {
    ShopCategory.boyoq => l10n.shopCategoryBoyoq,
    ShopCategory.oboy => l10n.shopCategoryOboy,
    ShopCategory.laminat => l10n.shopCategoryLaminat,
    ShopCategory.kafel => l10n.shopCategoryKafel,
    ShopCategory.parket => l10n.shopCategoryParket,
    ShopCategory.gips => l10n.shopCategoryGips,
    ShopCategory.sement => l10n.shopCategorySement,
    ShopCategory.santexnika => l10n.shopCategorySantexnika,
    ShopCategory.elektr => l10n.shopCategoryElektr,
    ShopCategory.eshik => l10n.shopCategoryEshik,
    ShopCategory.deraza => l10n.shopCategoryDeraza,
  };
}

/// A shop product. [projectQuantity] is non-null only when the app can
/// compute how much of this item the active project actually needs (the
/// delta mechanic) — that quantity, never a hardcoded guess, is what
/// renders in S1's banner, S2's grouped list, and S3's recommendation card.
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.pricePerUnit,
    required this.unit,
    required this.isOfficialDealer,
    this.coverage,
    this.dryingTime,
    this.washable,
    this.projectQuantity,
    this.imageUrl,
    this.storeId,
  });

  final String id;
  final String name;
  final String brand;
  final ShopCategory category;
  final int pricePerUnit;
  final String unit;
  final bool isOfficialDealer;
  final String? coverage;
  final String? dryingTime;
  final bool? washable;

  /// Real computed requirement for the active project, or null if this
  /// product isn't tied to the current renovation stage's material need.
  final double? projectQuantity;

  /// Real product photo from the backend catalog, or null when the material
  /// has no image — consumers fall back to the grey placeholder box.
  final String? imageUrl;

  /// Backend id of the store that sells this material, or null for products
  /// not loaded from the catalog.
  final String? storeId;

  bool get isInProject => projectQuantity != null;
}

class Dealer {
  const Dealer({
    required this.id,
    required this.name,
    required this.isOfficial,
    required this.district,
    required this.deliveryDays,
    required this.pricePerUnit,
  });

  final String id;
  final String name;
  final bool isOfficial;
  final String district;
  final int deliveryDays;
  final int pricePerUnit;

  /// Value equality by [id] — used as a Map key by cart_provider.dart's
  /// grouped-by-dealer view, so identity equality would be wrong here.
  @override
  bool operator ==(Object other) => other is Dealer && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class CartLine {
  const CartLine({
    required this.product,
    required this.dealer,
    required this.quantity,
  });

  final Product product;
  final Dealer dealer;
  final double quantity;

  int get lineTotal => (dealer.pricePerUnit * quantity).round();

  CartLine copyWith({double? quantity}) => CartLine(
    product: product,
    dealer: dealer,
    quantity: quantity ?? this.quantity,
  );
}

/// One stage's worth of required materials for S2's grouped list — built
/// from the same [RenovationStage] enum the delta mechanic already uses,
/// so a stage the room's starting condition already excludes never shows
/// up here (nothing to buy for work that's already done).
class StageMaterialGroup {
  const StageMaterialGroup({required this.stageLabel, required this.items});

  final String stageLabel;
  final List<StageMaterialItem> items;
}

class StageMaterialItem {
  const StageMaterialItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.unit,
  });

  /// Looks this item back up in [Product] catalog (image, price, brand) for
  /// S2's row UI and cart add — kept as an id rather than embedding the
  /// whole [Product] so this stays a plain quantity/unit summary.
  final String productId;
  final String name;
  final double quantity;
  final String unit;
}

enum OrderStep { accepted, gathering, onTheWay, delivered }

extension OrderStepInfo on OrderStep {
  String label(AppLocalizations l10n) => switch (this) {
    OrderStep.accepted => l10n.orderStepAccepted,
    OrderStep.gathering => l10n.orderStepGathering,
    OrderStep.onTheWay => l10n.orderStepOnTheWay,
    OrderStep.delivered => l10n.orderStepDelivered,
  };
}

class ShopOrder {
  const ShopOrder({
    required this.id,
    required this.lines,
    required this.total,
    required this.currentStep,
    required this.dealerName,
    required this.createdAt,
  });

  final String id;
  final List<CartLine> lines;
  final int total;
  final OrderStep currentStep;
  final String dealerName;
  final DateTime createdAt;
}
