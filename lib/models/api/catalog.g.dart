// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Material _$MaterialFromJson(Map<String, dynamic> json) => _Material(
  id: json['id'] as String,
  storeId: json['store_id'] as String,
  category: json['category'] as String,
  nameUz: json['name_uz'] as String,
  unit: json['unit'] as String,
  priceUzs: (json['price_uzs'] as num).toInt(),
  colorHex: json['color_hex'] as String?,
  textureKey: json['texture_key'] as String?,
  pbrRoughness: (json['pbr_roughness'] as num?)?.toDouble() ?? 1.0,
  imageUrl: json['image_url'] as String?,
);

Map<String, dynamic> _$MaterialToJson(_Material instance) => <String, dynamic>{
  'id': instance.id,
  'store_id': instance.storeId,
  'category': instance.category,
  'name_uz': instance.nameUz,
  'unit': instance.unit,
  'price_uzs': instance.priceUzs,
  'color_hex': instance.colorHex,
  'texture_key': instance.textureKey,
  'pbr_roughness': instance.pbrRoughness,
  'image_url': instance.imageUrl,
};

_PaginatedMaterials _$PaginatedMaterialsFromJson(Map<String, dynamic> json) =>
    _PaginatedMaterials(
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => Material.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <Material>[],
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      perPage: (json['per_page'] as num?)?.toInt() ?? 20,
    );

Map<String, dynamic> _$PaginatedMaterialsToJson(_PaginatedMaterials instance) =>
    <String, dynamic>{
      'items': instance.items,
      'total': instance.total,
      'page': instance.page,
      'per_page': instance.perPage,
    };

_Furniture _$FurnitureFromJson(Map<String, dynamic> json) => _Furniture(
  id: json['id'] as String,
  storeId: json['store_id'] as String?,
  storeName: json['store_name'] as String?,
  category: json['category'] as String,
  nameUz: json['name_uz'] as String,
  priceUzs: (json['price_uzs'] as num?)?.toInt(),
  glbUrl: json['glb_url'] as String?,
  thumbnailUrl: json['thumbnail_url'] as String?,
  footprintW: (json['footprint_w'] as num?)?.toDouble(),
  footprintD: (json['footprint_d'] as num?)?.toDouble(),
  heightCm: (json['height_cm'] as num?)?.toDouble(),
);

Map<String, dynamic> _$FurnitureToJson(_Furniture instance) =>
    <String, dynamic>{
      'id': instance.id,
      'store_id': instance.storeId,
      'store_name': instance.storeName,
      'category': instance.category,
      'name_uz': instance.nameUz,
      'price_uzs': instance.priceUzs,
      'glb_url': instance.glbUrl,
      'thumbnail_url': instance.thumbnailUrl,
      'footprint_w': instance.footprintW,
      'footprint_d': instance.footprintD,
      'height_cm': instance.heightCm,
    };

_PaginatedFurniture _$PaginatedFurnitureFromJson(Map<String, dynamic> json) =>
    _PaginatedFurniture(
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => Furniture.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <Furniture>[],
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      perPage: (json['per_page'] as num?)?.toInt() ?? 20,
    );

Map<String, dynamic> _$PaginatedFurnitureToJson(_PaginatedFurniture instance) =>
    <String, dynamic>{
      'items': instance.items,
      'total': instance.total,
      'page': instance.page,
      'per_page': instance.perPage,
    };

_Store _$StoreFromJson(Map<String, dynamic> json) => _Store(
  id: json['id'] as String,
  name: json['name'] as String,
  district: json['district'] as String?,
  phone: json['phone'] as String?,
  telegram: json['telegram'] as String?,
  logoColor: json['logo_color'] as String?,
  partnerTier: json['partner_tier'] as String,
);

Map<String, dynamic> _$StoreToJson(_Store instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'district': instance.district,
  'phone': instance.phone,
  'telegram': instance.telegram,
  'logo_color': instance.logoColor,
  'partner_tier': instance.partnerTier,
};
