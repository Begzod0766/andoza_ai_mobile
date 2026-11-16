// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_create.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WallElementCreate _$WallElementCreateFromJson(Map<String, dynamic> json) =>
    _WallElementCreate(
      type: $enumDecode(
        _$WallElementTypeEnumMap,
        json['type'],
        unknownValue: WallElementType.unknown,
      ),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      sillHeight: (json['sill_height'] as num?)?.toDouble() ?? 0.0,
      position: (json['position'] as num?)?.toDouble() ?? 0.5,
    );

Map<String, dynamic> _$WallElementCreateToJson(_WallElementCreate instance) =>
    <String, dynamic>{
      'type': _$WallElementTypeEnumMap[instance.type]!,
      'width': instance.width,
      'height': instance.height,
      'sill_height': instance.sillHeight,
      'position': instance.position,
    };

const _$WallElementTypeEnumMap = {
  WallElementType.eshik: 'eshik',
  WallElementType.deraza: 'deraza',
  WallElementType.balkon: 'balkon',
  WallElementType.unknown: 'unknown',
};

_WallCreate _$WallCreateFromJson(Map<String, dynamic> json) => _WallCreate(
  id: json['id'] as String,
  length: (json['length'] as num).toDouble(),
  elements:
      (json['elements'] as List<dynamic>?)
          ?.map((e) => WallElementCreate.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <WallElementCreate>[],
);

Map<String, dynamic> _$WallCreateToJson(_WallCreate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'length': instance.length,
      'elements': instance.elements,
    };

_RoomGeometryCreate _$RoomGeometryCreateFromJson(Map<String, dynamic> json) =>
    _RoomGeometryCreate(
      walls: (json['walls'] as List<dynamic>)
          .map((e) => WallCreate.fromJson(e as Map<String, dynamic>))
          .toList(),
      vertices: (json['vertices'] as List<dynamic>?)
          ?.map(
            (e) =>
                (e as List<dynamic>).map((e) => (e as num).toDouble()).toList(),
          )
          .toList(),
    );

Map<String, dynamic> _$RoomGeometryCreateToJson(_RoomGeometryCreate instance) =>
    <String, dynamic>{'walls': instance.walls, 'vertices': ?instance.vertices};

_RoomCreate _$RoomCreateFromJson(Map<String, dynamic> json) => _RoomCreate(
  name: json['name'] as String,
  ceilingH: (json['ceiling_h'] as num).toDouble(),
  geometry: RoomGeometryCreate.fromJson(
    json['geometry'] as Map<String, dynamic>,
  ),
  roomType: json['room_type'] as String?,
);

Map<String, dynamic> _$RoomCreateToJson(_RoomCreate instance) =>
    <String, dynamic>{
      'name': instance.name,
      'ceiling_h': instance.ceilingH,
      'geometry': instance.geometry,
      'room_type': ?instance.roomType,
    };
