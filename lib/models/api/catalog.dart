import 'package:freezed_annotation/freezed_annotation.dart';

part 'catalog.freezed.dart';
part 'catalog.g.dart';

/// A material row from the backend catalog (`GET /api/v1/materials`).
///
/// Mirrors `app/schemas/material.py::MaterialOut`. Categories are free-form
/// strings on purpose (boyoq, oboy, laminat, plitka, eshik, deraza, gips, …).
@freezed
abstract class Material with _$Material {
  const factory Material({
    required String id,
    @JsonKey(name: 'store_id') required String storeId,
    required String category,
    @JsonKey(name: 'name_uz') required String nameUz,
    required String unit,
    @JsonKey(name: 'price_uzs') required int priceUzs,
    @JsonKey(name: 'color_hex') String? colorHex,
    @JsonKey(name: 'texture_key') String? textureKey,
    @JsonKey(name: 'pbr_roughness') @Default(1.0) double pbrRoughness,
    @JsonKey(name: 'image_url') String? imageUrl,
  }) = _Material;

  factory Material.fromJson(Map<String, dynamic> json) =>
      _$MaterialFromJson(json);
}

/// Paginated envelope for `GET /api/v1/materials`.
@freezed
abstract class PaginatedMaterials with _$PaginatedMaterials {
  const factory PaginatedMaterials({
    @Default(<Material>[]) List<Material> items,
    @Default(0) int total,
    @Default(1) int page,
    @JsonKey(name: 'per_page') @Default(20) int perPage,
  }) = _PaginatedMaterials;

  factory PaginatedMaterials.fromJson(Map<String, dynamic> json) =>
      _$PaginatedMaterialsFromJson(json);
}

/// A furniture/3D-model catalog row (`GET /api/v1/furniture`).
///
/// Mirrors `app/schemas/catalog.py::FurnitureOut`. [glbUrl] is the 3D model
/// (null for a photo-only listing, which the Studio cannot place);
/// [footprintW]/[footprintD]/[heightCm] are in centimetres.
@freezed
abstract class Furniture with _$Furniture {
  const factory Furniture({
    required String id,
    @JsonKey(name: 'store_id') String? storeId,
    @JsonKey(name: 'store_name') String? storeName,
    required String category,
    @JsonKey(name: 'name_uz') required String nameUz,
    @JsonKey(name: 'price_uzs') int? priceUzs,
    @JsonKey(name: 'glb_url') String? glbUrl,
    @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
    @JsonKey(name: 'footprint_w') double? footprintW,
    @JsonKey(name: 'footprint_d') double? footprintD,
    @JsonKey(name: 'height_cm') double? heightCm,
  }) = _Furniture;

  factory Furniture.fromJson(Map<String, dynamic> json) =>
      _$FurnitureFromJson(json);
}

/// Paginated envelope for `GET /api/v1/furniture`.
@freezed
abstract class PaginatedFurniture with _$PaginatedFurniture {
  const factory PaginatedFurniture({
    @Default(<Furniture>[]) List<Furniture> items,
    @Default(0) int total,
    @Default(1) int page,
    @JsonKey(name: 'per_page') @Default(20) int perPage,
  }) = _PaginatedFurniture;

  factory PaginatedFurniture.fromJson(Map<String, dynamic> json) =>
      _$PaginatedFurnitureFromJson(json);
}

/// A partner store (`GET /api/v1/stores`).
///
/// Mirrors `app/schemas/catalog.py::StoreOut`.
@freezed
abstract class Store with _$Store {
  const factory Store({
    required String id,
    required String name,
    String? district,
    String? phone,
    String? telegram,
    @JsonKey(name: 'logo_color') String? logoColor,
    @JsonKey(name: 'partner_tier') required String partnerTier,
  }) = _Store;

  factory Store.fromJson(Map<String, dynamic> json) => _$StoreFromJson(json);
}
