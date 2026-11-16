import 'package:freezed_annotation/freezed_annotation.dart';

part 'room_create.freezed.dart';
part 'room_create.g.dart';

/// A wall opening type as the backend expects it (`app/schemas/room.py`).
enum WallElementType {
  /// Door.
  @JsonValue('eshik')
  eshik,

  /// Window.
  @JsonValue('deraza')
  deraza,

  /// Balcony door.
  @JsonValue('balkon')
  balkon,

  /// Fallback for any element type the backend adds that this client predates.
  /// Deserialization maps unknown strings here instead of throwing.
  unknown,
}

/// A door/window opening on a wall, in the create-room request shape.
/// Backend bounds: width 0.3–5.0, height 0.3–3.5, sillHeight 0.0–2.5,
/// position 0.0–1.0 (fraction along the wall).
@freezed
abstract class WallElementCreate with _$WallElementCreate {
  const factory WallElementCreate({
    @JsonKey(unknownEnumValue: WallElementType.unknown)
    required WallElementType type,
    required double width,
    required double height,
    @JsonKey(name: 'sill_height') @Default(0.0) double sillHeight,
    @Default(0.5) double position,
  }) = _WallElementCreate;

  factory WallElementCreate.fromJson(Map<String, dynamic> json) =>
      _$WallElementCreateFromJson(json);
}

/// A wall in the create-room request. Backend bounds: length 0.5–25.0 m.
@freezed
abstract class WallCreate with _$WallCreate {
  const factory WallCreate({
    required String id,
    required double length,
    @Default(<WallElementCreate>[]) List<WallElementCreate> elements,
  }) = _WallCreate;

  factory WallCreate.fromJson(Map<String, dynamic> json) =>
      _$WallCreateFromJson(json);
}

/// Room geometry: at least 3 walls. Vertices are auto-computed server-side for
/// legacy 4-wall rectangular rooms, so the client omits them there. For real
/// polygons (L-shapes, trapezoids, …) the client sends the ordered polygon
/// [vertices] (metres, `[[x, y], …]`) plus one wall per edge so the web 3D
/// Studio can render the actual shape instead of a bounding box.
@freezed
abstract class RoomGeometryCreate with _$RoomGeometryCreate {
  const factory RoomGeometryCreate({
    required List<WallCreate> walls,
    @JsonKey(name: 'vertices', includeIfNull: false)
    List<List<double>>? vertices,
  }) = _RoomGeometryCreate;

  factory RoomGeometryCreate.fromJson(Map<String, dynamic> json) =>
      _$RoomGeometryCreateFromJson(json);
}

/// Body for `POST /apartments/{aptId}/rooms` (mirrors `RoomCreate`).
/// Backend bounds: ceilingH 1.8–6.0 m; opening height + sill must not exceed
/// the ceiling height.
@freezed
abstract class RoomCreate with _$RoomCreate {
  const factory RoomCreate({
    required String name,
    @JsonKey(name: 'ceiling_h') required double ceilingH,
    required RoomGeometryCreate geometry,
    /// `hammom`, `oshxona`, … (backend `RoomType`); omitted when not picked.
    @JsonKey(name: 'room_type', includeIfNull: false) String? roomType,
  }) = _RoomCreate;

  factory RoomCreate.fromJson(Map<String, dynamic> json) =>
      _$RoomCreateFromJson(json);
}
