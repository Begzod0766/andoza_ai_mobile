import '../geometry/geometry_config.dart';
import '../geometry/room_geometry.dart';
import 'room_model.dart' as rm;

/// Where a [RoomPlan] came from. The unified output of every room-capture
/// method (so all four flows can produce the same contract).
enum RoomSource { lidar, photo, wizard, sketch, drag, arcore }

/// A door/window opening on a [RoomWall]. Mirrors the fields the backend
/// [WallElementCreate] and the client [rm.Door]/[rm.Window] carry, kept as a
/// plain value so the geometry layer stays Flutter/Freezed-free.
class RoomOpening {
  /// `'door'` or `'window'`.
  final String type;

  /// Opening width in metres.
  final double width;

  /// Opening height in metres.
  final double height;

  /// The opening's CENTRE along the wall, as a fraction (0..1) — not its left
  /// edge. Matches the backend's `WallElement.position`, which the LiDAR
  /// converter, the smeta and the auto-electrical generator all read as a
  /// centre. Convert to/from the measuring UI's left-edge offset with
  /// `utils/opening_position.dart`.
  final double position;

  /// Sill height in metres (distance from the floor to the opening's bottom).
  final double sillHeight;

  const RoomOpening({
    required this.type,
    required this.width,
    required this.height,
    this.position = 0.5,
    this.sillHeight = 0.0,
  });
}

/// One wall of a [RoomPlan], referencing two corner indices.
class RoomWall {
  /// Index of the start corner in [RoomPlan.corners].
  final int a;

  /// Index of the end corner in [RoomPlan.corners].
  final int b;

  /// Wall length in metres.
  final double lengthM;

  /// Openings (doors/windows) on this wall. Empty by default.
  final List<RoomOpening> openings;

  const RoomWall(this.a, this.b, this.lengthM,
      {this.openings = const []});
}

/// The unified room contract: a closed, ordered polygon of corners (metres),
/// its walls, ceiling height and origin. NOT hardcoded to 4 walls — L-shaped
/// and other N-corner rooms are valid.
class RoomPlan {
  /// Ordered polygon corners in metres (closing edge is implied corners.last →
  /// corners.first).
  final List<Vec2> corners;
  final List<RoomWall> walls;
  final double ceilingHeightM;
  final RoomSource source;

  /// Human-readable room name, carried through to the legacy [rm.Room].
  final String name;

  /// The backend room type (`hammom`, `oshxona`, … — see `kRoomTypes`), or
  /// null when the user did not pick one. Sent as `room_type` on create so the
  /// Studio does not have to guess the type from the name.
  final String? roomType;

  const RoomPlan({
    required this.corners,
    required this.walls,
    required this.ceilingHeightM,
    required this.source,
    this.name = 'Xona',
    this.roomType,
  });

  /// Build a plain axis-aligned rectangle plan from a [width] (walls B/D span)
  /// and [length] (walls A/C span). Corners are laid out so the derived walls
  /// line up with [toLegacyRoom]'s A–D mapping — wall index 0 = A, 1 = B, 2 = C,
  /// 3 = D — with A/C running [length] and B/D running [width]. This is the
  /// single rectangle-producing entry point shared by every capture flow whose
  /// output is a box (the 3D wizard, LiDAR, photo, wall-measurements summary and
  /// the manual dimensions entry), so they all agree on the same geometry.
  ///
  /// [wallOpenings], when given, must be 4 lists of openings for walls A, B, C,
  /// D respectively.
  factory RoomPlan.rectangle({
    required double width,
    required double length,
    required double ceilingHeightM,
    required RoomSource source,
    String name = 'Xona',
    String? roomType,
    List<List<RoomOpening>>? wallOpenings,
  }) {
    final corners = <Vec2>[
      const Vec2(0, 0),
      Vec2(0, length),
      Vec2(width, length),
      Vec2(width, 0),
    ];
    final walls = <RoomWall>[
      for (var i = 0; i < 4; i++)
        RoomWall(
          i,
          (i + 1) % 4,
          corners[i].distanceTo(corners[(i + 1) % 4]),
          openings: wallOpenings != null ? wallOpenings[i] : const [],
        ),
    ];
    return RoomPlan(
      corners: List.unmodifiable(corners),
      walls: List.unmodifiable(walls),
      ceilingHeightM: ceilingHeightM,
      source: source,
      name: name,
      roomType: roomType,
    );
  }

  /// Build a plan from ordered corners, deriving the walls.
  factory RoomPlan.fromCorners(
    List<Vec2> corners, {
    required double ceilingHeightM,
    required RoomSource source,
    String name = 'Xona',
  }) {
    final walls = <RoomWall>[
      for (var i = 0; i < corners.length; i++)
        RoomWall(i, (i + 1) % corners.length,
            corners[i].distanceTo(corners[(i + 1) % corners.length]),
            openings: const []),
    ];
    return RoomPlan(
      corners: List.unmodifiable(corners),
      walls: List.unmodifiable(walls),
      ceilingHeightM: ceilingHeightM,
      source: source,
      name: name,
    );
  }

  double get areaM2 => shoelaceArea(corners);
  double get perimeterM => perimeter(corners);

  /// Net wall (paintable) area: the full wall band ([perimeterM] × ceiling)
  /// minus every opening's face area. Estimates use this so doors/windows don't
  /// get charged as wall.
  double get netWallAreaM2 {
    final gross = perimeterM * ceilingHeightM;
    var openingArea = 0.0;
    for (final w in walls) {
      for (final o in w.openings) {
        openingArea += o.width * o.height;
      }
    }
    final net = gross - openingArea;
    return net < 0 ? 0 : net;
  }

  /// Adapts this plan onto the legacy rectangular [rm.Room] pipeline used by
  /// display widgets. The room's dimensions/walls come from the axis-aligned
  /// bounding box: 4 A–D walls where A/C run the bounding length and B/D the
  /// bounding width, all at the ceiling height. Openings are mapped onto the
  /// A–D walls only when this plan is itself a 4-wall shape (trivially
  /// mappable); otherwise doors/windows are omitted.
  rm.Room toLegacyRoom({String? id}) {
    final rid = id ?? DateTime.now().microsecondsSinceEpoch.toString();
    final b = boundingSize;
    const types = [
      rm.WallType.wallA,
      rm.WallType.wallB,
      rm.WallType.wallC,
      rm.WallType.wallD,
    ];
    final lengths = [b.length, b.width, b.length, b.width];
    final legacyWalls = <rm.Wall>[
      for (var i = 0; i < 4; i++)
        rm.Wall(
          id: '${rid}_${types[i].name}',
          type: types[i],
          measurements: rm.WallMeasurements(
            height: ceilingHeightM,
            length: lengths[i],
          ),
        ),
    ];

    final doors = <rm.Door>[];
    final windows = <rm.Window>[];
    if (walls.length == 4) {
      for (var i = 0; i < 4; i++) {
        final wallId = legacyWalls[i].id;
        var n = 0;
        for (final o in walls[i].openings) {
          final oid = '${wallId}_o${n++}';
          if (o.type == 'window') {
            windows.add(rm.Window(
              id: oid,
              wallId: wallId,
              position: o.position,
              width: o.width,
              height: o.height,
              type: rm.OpeningType.single,
            ));
          } else {
            doors.add(rm.Door(
              id: oid,
              wallId: wallId,
              position: o.position,
              width: o.width,
              height: o.height,
              type: rm.OpeningType.single,
            ));
          }
        }
      }
    }

    return rm.Room(
      id: rid,
      name: name,
      dimensions: rm.RoomDimensions(
        width: b.width,
        length: b.length,
        height: ceilingHeightM,
      ),
      walls: legacyWalls,
      doors: doors,
      windows: windows,
      createdAt: DateTime.now(),
    );
  }

  /// Axis-aligned bounding size — used by the adapter that maps a plan onto the
  /// existing rectangular room pipeline / 3D Studio.
  ({double width, double length}) get boundingSize => boundingSize2(corners);

  bool get isRectangleLike => corners.length == 4;

  /// True only for a plain axis-aligned rectangle (4 corners, every edge purely
  /// horizontal or vertical). Real polygons — L-shapes, trapezoids, triangles,
  /// skewed quads — are false, so the handoff persists their true vertices +
  /// N walls instead of collapsing them to a bounding box.
  bool get isAxisAlignedRect => isAxisAlignedRectangle(corners);

  /// A plan is valid when it is a simple (non-self-intersecting) closed polygon
  /// of ≥3 corners, each wall is at least [GeometryConfig.minWallM], and the
  /// ceiling height is in range.
  bool get isValid =>
      corners.length >= 3 &&
      !isSelfIntersecting(corners) &&
      walls.every((w) => w.lengthM >= GeometryConfig.minWallM) &&
      ceilingHeightM >= GeometryConfig.minHeightM &&
      ceilingHeightM <= GeometryConfig.maxHeightM;

  /// A human reason the plan can't be finished yet, or null when [isValid].
  String? get invalidReason {
    if (corners.length < 3) return 'Kamida 3 ta burchak kerak';
    if (isSelfIntersecting(corners)) return 'Devorlar kesishmasligi kerak';
    if (walls.any((w) => w.lengthM < GeometryConfig.minWallM)) {
      return 'Har bir devor kamida ${formatLength(GeometryConfig.minWallM)}';
    }
    if (ceilingHeightM < GeometryConfig.minHeightM ||
        ceilingHeightM > GeometryConfig.maxHeightM) {
      return 'Balandlik ${GeometryConfig.minHeightM}–${GeometryConfig.maxHeightM} m';
    }
    return null;
  }
}

/// Small alias so [RoomPlan.boundingSize] can call the free function without a
/// name clash with the getter.
({double width, double length}) boundingSize2(List<Vec2> poly) =>
    boundingSize(poly);
