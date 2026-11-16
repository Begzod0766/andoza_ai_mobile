import '../models/api/room_create.dart';
import '../models/room_model.dart' as client;
import '../models/room_plan.dart';

/// Clamps [v] to the inclusive range [lo, hi]. Used to keep captured
/// measurements inside the backend's validation bounds so a room POST doesn't
/// 422 on a slightly-out-of-range value.
double _clamp(double v, double lo, double hi) =>
    v < lo ? lo : (v > hi ? hi : v);

String _wallLetter(client.WallType type) => switch (type) {
      client.WallType.wallA => 'A',
      client.WallType.wallB => 'B',
      client.WallType.wallC => 'C',
      client.WallType.wallD => 'D',
      client.WallType.unknown => 'A',
    };

/// Converts the app's captured [client.Room] into the backend [RoomCreate]
/// request body.
///
/// - Ceiling height comes from the room's overall height (falls back to the
///   first wall's height, then a 2.8 m default), clamped to 1.8–6.0 m.
/// - Each wall's doors become `eshik` elements (sill 0) and windows become
///   `deraza` elements (sill defaulted to 0.9 m, since the capture flow doesn't
///   record a sill), positioned by their fractional position along the wall.
/// - All lengths/dimensions are clamped to the backend's accepted ranges.
RoomCreate roomToRoomCreate(client.Room room) {
  final ceiling = _clamp(
    room.dimensions.height > 0
        ? room.dimensions.height
        : (room.walls.isNotEmpty ? room.walls.first.measurements.height : 2.8),
    1.8,
    6.0,
  );

  // An opening's height + sill must not exceed the ceiling, or the backend
  // rejects the whole room (RoomCreate.check_element_heights → 422). Clamp each
  // element's height to fit under the ceiling given its sill.
  double openingHeight(double raw, double sill) =>
      _clamp(raw, 0.3, (ceiling - sill - 0.01).clamp(0.3, 3.5));

  const windowSill = 0.9;

  final walls = <WallCreate>[
    for (final wall in room.walls)
      WallCreate(
        id: _wallLetter(wall.type),
        length: _clamp(wall.measurements.length, 0.51, 24.9),
        elements: [
          for (final door in room.doors.where((d) => d.wallId == wall.id))
            WallElementCreate(
              type: WallElementType.eshik,
              width: _clamp(door.width, 0.3, 5.0),
              height: openingHeight(door.height, 0.0),
              position: _clamp(door.position, 0.0, 1.0),
            ),
          for (final window in room.windows.where((w) => w.wallId == wall.id))
            WallElementCreate(
              type: WallElementType.deraza,
              width: _clamp(window.width, 0.3, 5.0),
              height: openingHeight(window.height, windowSill),
              sillHeight: windowSill,
              position: _clamp(window.position, 0.0, 1.0),
            ),
        ],
      ),
  ];

  return RoomCreate(
    name: room.name.isEmpty ? 'Xona' : room.name,
    ceilingH: ceiling,
    geometry: RoomGeometryCreate(walls: walls),
  );
}

/// Converts a real (non-rectangular) [RoomPlan] polygon into a [RoomCreate] that
/// preserves the actual shape: it carries the ordered polygon [RoomGeometryCreate.vertices]
/// (metres, `[[x, y], …]`) plus one wall per edge with **non-ABCD ids**
/// `'0'..'N-1'`. This is what lets the web 3D Studio render the true L-shape /
/// trapezoid / triangle instead of a bounding box (the studio's [NWallRoomShell]
/// kicks in for ≥3 vertices when the walls are not exactly the 4 legacy A/B/C/D).
///
/// Rectangles must NOT go through here — they keep the legacy 4-wall A–D path via
/// [roomToRoomCreate], whose renderer is nicer for plain boxes.
RoomCreate roomPlanToPolygonRoomCreate(RoomPlan plan, {String name = 'Xona'}) {
  final ceiling = _clamp(plan.ceilingHeightM, 1.8, 6.0);

  // Same "must fit under the ceiling given its sill" clamp [roomToRoomCreate]
  // applies — without it a scanned opening whose raw height (from RoomPlan,
  // not backend-validated) exceeds the ceiling would 422 the whole room.
  double openingHeight(double raw, double sill) =>
      _clamp(raw, 0.3, (ceiling - sill - 0.01).clamp(0.3, 3.5));

  final walls = <WallCreate>[
    for (var i = 0; i < plan.walls.length; i++)
      WallCreate(
        id: '$i',
        length: _clamp(plan.walls[i].lengthM, 0.51, 24.9),
        elements: [
          for (final opening in plan.walls[i].openings)
            () {
              // The height bound MUST be computed from the same sill value
              // that actually gets stored below — using the raw (unclamped)
              // sill here let a noisy scan (e.g. a slightly negative sill
              // from the floor-plane estimate) compute a too-generous height
              // ceiling, while the stored sill clamped up to 0.0. The two
              // disagreeing meant `height + sill_height` could still exceed
              // ceiling_h after clamping — exactly the 422 this clamp exists
              // to prevent, just reintroduced through the back door.
              final sill = _clamp(opening.sillHeight, 0.0, 2.5);
              return WallElementCreate(
                type: opening.type == 'window'
                    ? WallElementType.deraza
                    : WallElementType.eshik,
                width: _clamp(opening.width, 0.3, 5.0),
                height: openingHeight(opening.height, sill),
                sillHeight: sill,
                position: _clamp(opening.position, 0.0, 1.0),
              );
            }(),
        ],
      ),
  ];

  final vertices = <List<double>>[
    for (final c in plan.corners) [c.x, c.y],
  ];

  return RoomCreate(
    name: name.isEmpty ? 'Xona' : name,
    ceilingH: ceiling,
    geometry: RoomGeometryCreate(walls: walls, vertices: vertices),
    roomType: plan.roomType,
  );
}
