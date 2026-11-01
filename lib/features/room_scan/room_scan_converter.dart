import 'dart:math' as math;

import '../../geometry/geometry_config.dart';
import '../../geometry/room_geometry.dart';
import '../../models/room_plan.dart';
import 'models/captured_room.dart';

/// A furniture/object detected by RoomPlan, projected onto the app's 2-D floor
/// plane (metres). Kept separate from [RoomPlan] because the room DTO
/// ([RoomCreate].geometry) has no furniture field — objects ride in their own
/// `scanObjects` payload for the studio/backend to consume later (see the
/// Phase 0 discovery doc §3f).
class ScanObjectPlacement {
  final ScanObjectCategory category;

  /// Centre on the app floor plane, metres, in the same normalised frame as
  /// [RoomScanDraft.plan] (origin at the room's bounding-box min corner).
  final double x;
  final double y;

  /// Footprint + height, metres.
  final double width;
  final double depth;
  final double height;

  /// Yaw around the vertical axis, radians.
  final double rotationRad;

  final ScanConfidence confidence;

  const ScanObjectPlacement({
    required this.category,
    required this.x,
    required this.y,
    required this.width,
    required this.depth,
    required this.height,
    required this.rotationRad,
    required this.confidence,
  });
}

/// The full result of converting a RoomPlan scan: the unified [RoomPlan] (which
/// flows through the *existing* handoff/mappers exactly like a manually-drawn
/// room) plus the detected [objects] carried alongside.
class RoomScanDraft {
  final RoomPlan plan;
  final List<ScanObjectPlacement> objects;

  /// Where [plan]'s origin (its bounding-box min corner) sits in the scan's
  /// world, on the floor plane (x = world X, y = world Z), metres. Rooms of
  /// one multi-room scan share that world, so this places them in the flat.
  final Vec2 worldOrigin;

  const RoomScanDraft({
    required this.plan,
    required this.objects,
    this.worldOrigin = const Vec2(0, 0),
  });
}

/// Converts an Apple RoomPlan [CapturedRoom] into the app's unified room
/// representation.
///
/// Coordinate mapping (authoritative — see discovery doc §3e / §8):
/// * RoomPlan is **Y-up, metres**. The floor is the world **XZ** plane, so a
///   surface's world position `(tx, ty, tz)` maps to app 2-D `(x = tx, y = tz)`.
/// * A wall surface's local **X axis** (transform column 0) runs along its
///   length; `dimensions.x` is that length. The two wall endpoints are the
///   centre ± half-length along that axis, projected to XZ.
/// * Corners are the merged wall endpoints, ordered into a loop, **normalised so
///   the bounding-box min corner sits at the origin** (matching the manual
///   flow's `(0,0)` origin), then straightened: any edge within **±3°** of an
///   axis is snapped square (a deliberately tighter tolerance than the 12°
///   freehand snap, so genuinely angled walls survive).
/// * Ceiling height = **median** wall height, kept raw (only the UI snaps it to
///   the 2.5/2.7/2.8/3.0/3.2 chips), clamped to the app's height range.
/// * The world origin sits at *device* height, **not** on the floor (a real
///   scan puts the floor near `y = -1.6`), so the floor plane is taken as the
///   lowest wall base and window sills are measured from it.
/// * Openings → nearest wall by perpendicular distance; `position` = projected
///   offset / wall length (0..1). Doors/openings get `sillHeight 0`; windows
///   derive the sill from the opening's lower edge above that floor plane
///   (fallback 0.9 m, as the manual mapper defaults).
class RoomScanConverter {
  /// Shortest a detected door / pass-through may be and still be believed.
  static const double _minDoorHeightM = 1.5;

  const RoomScanConverter._();

  /// Endpoints are considered the same corner when closer than this (metres).
  static const double _cornerMergeM = 0.35;

  /// Edges within this of an axis are snapped square. Tighter than the freehand
  /// [GeometryConfig.angleSnapToleranceDeg] (12°) on purpose.
  static const double _scanStraightenToleranceDeg = 3.0;

  // Sill limits, all measured from the room's own floor plane.
  /// Schema cap for `RoomOpening.sillHeight`.
  static const double _maxSillM = 2.5;

  /// How far below the derived floor a sill may sit before it counts as bad
  /// data rather than measurement noise.
  static const double _sillSlackM = 0.25;

  /// Used only for missing / absurd data — the manual mapper's default.
  static const double _fallbackSillM = 0.9;

  static RoomScanDraft toRoomDraft(
    CapturedRoom room, {
    RoomSource source = RoomSource.lidar,
    String name = 'Xona',
  }) {
    // 1. Corners from wall endpoints (world XZ), ordered into a loop.
    var corners = _buildCorners(room.walls);

    // 2. Straighten near-axis edges (±3°), drop collinear points.
    if (corners.length >= 3) {
      corners = _straighten(corners);
    }

    // 3. Normalise so the bounding min corner is the origin (metres).
    final origin = _minCorner(corners);
    corners = [for (final c in corners) c - origin];

    // 4. Ceiling = median wall height (raw), clamped to app range; floor = the
    //    lowest wall base (the world origin is at device height, not the floor).
    final ceiling = _ceilingHeight(room.walls);
    final floorY = _floorLevel(room.walls);

    // 5. Openings → nearest wall (positions 0..1 along the final loop).
    final openingsPerWall =
        List<List<RoomOpening>>.generate(corners.length, (_) => <RoomOpening>[]);
    if (corners.length >= 3) {
      void assign(ScanSurface s, String type) {
        // RoomPlan still reports a low-confidence hit when it noticed
        // *something* (glass, a reflection, poor lighting) but isn't sure it
        // was really a door/window — folding those into the plan as if they
        // were solid detections used to plant openings that were never
        // there. Skipping them trades a few missed real openings (rare: a
        // genuine opening in good scan conditions is normally medium/high)
        // for far fewer fabricated ones.
        if (s.confidence == ScanConfidence.low) return;
        // A "door" (or door-less pass-through) well under a person's height is
        // not one: RoomPlan sometimes tags a radiator, a vent, a low cabinet
        // or a wall niche as a door, and it then shows up in the 3D room as a
        // stray door-coloured square on the wall. Real doors are ~2 m.
        if (type == 'door' && s.dimensions.y < _minDoorHeightM) return;
        final centre = _worldToPlane(s.transform) - origin;
        final hit = _nearestWall(corners, centre);
        if (hit == null) return;
        final height = s.dimensions.y.clamp(0.3, 3.5);
        openingsPerWall[hit.wallIndex].add(RoomOpening(
          type: type,
          width: s.dimensions.x.clamp(0.3, 5.0),
          height: height,
          position: hit.position.clamp(0.0, 1.0),
          sillHeight:
              type == 'window' ? _windowSill(s, height, floorY) : 0.0,
        ));
      }

      for (final d in room.doors) {
        assign(d, 'door');
      }
      for (final w in room.windows) {
        assign(w, 'window');
      }
      // RoomPlan "openings" are door-less pass-throughs → treat as open doorways.
      for (final o in room.openings) {
        assign(o, 'door');
      }
    }

    // 6. Assemble the RoomPlan (corners + walls carrying their openings).
    final plan = _assemble(corners, openingsPerWall, ceiling, source, name);

    // 7. Furniture detection is deliberately dropped: a LiDAR scan is for the
    //    room's own shape (walls, doors, windows), and RoomPlan's furniture
    //    guesses — boxy, often-wrong placeholders the review screen and
    //    studio had to render as "ghost" boxes to avoid passing off as real
    //    models — just aren't part of that job. `room.objects` is otherwise
    //    unused from here down.
    const objects = <ScanObjectPlacement>[];

    return RoomScanDraft(plan: plan, objects: objects, worldOrigin: origin);
  }

  // ── corners ──────────────────────────────────────────────────────────────

  /// A wall surface's two endpoints on the app floor plane (metres).
  static List<Vec2> _wallEndpoints(ScanSurface wall) {
    final centre = _worldToPlane(wall.transform);
    final m = wall.transform.m;
    // Local X axis (column 0) projected onto the XZ floor plane.
    var dir = Vec2(m[0], m[2]);
    if (dir.length < 1e-6) {
      dir = const Vec2(1, 0);
    } else {
      dir = dir.normalized;
    }
    final half = wall.dimensions.x / 2.0;
    return <Vec2>[centre - dir * half, centre + dir * half];
  }

  /// World transform translation → app floor point `(x = worldX, y = worldZ)`.
  static Vec2 _worldToPlane(ScanTransform t) => Vec2(t.m[12], t.m[14]);

  /// Cluster wall endpoints into unique corners and order them into a polygon
  /// loop by walking the wall-edge graph (falls back to a polar-angle sort when
  /// the graph isn't a clean single cycle). Returns CCW-ordered corners.
  static List<Vec2> _buildCorners(List<ScanSurface> walls) {
    if (walls.length < 3) return const <Vec2>[];

    final corners = <Vec2>[];
    final edges = <List<int>>[];

    int indexOf(Vec2 p) {
      for (var k = 0; k < corners.length; k++) {
        if (corners[k].distanceTo(p) < _cornerMergeM) return k;
      }
      corners.add(p);
      return corners.length - 1;
    }

    for (final w in walls) {
      final ep = _wallEndpoints(w);
      final i = indexOf(ep[0]);
      final j = indexOf(ep[1]);
      if (i != j) edges.add(<int>[i, j]);
    }
    if (corners.length < 3) return const <Vec2>[];

    final ordered = _orderLoop(corners, edges) ?? _polarSort(corners);
    return _ensureCcw(ordered);
  }

  /// Walk the edge graph into a single ordered cycle. Returns null when the
  /// graph isn't a clean loop (some corner not degree-2 / dead end), so the
  /// caller can fall back.
  static List<Vec2>? _orderLoop(List<Vec2> corners, List<List<int>> edges) {
    final n = corners.length;
    final adj = List<List<int>>.generate(n, (_) => <int>[]);
    for (final e in edges) {
      adj[e[0]].add(e[1]);
      adj[e[1]].add(e[0]);
    }
    final order = <int>[0];
    final seen = <int>{0};
    var prev = -1;
    var cur = 0;
    while (order.length < n) {
      final nexts = adj[cur].where((x) => x != prev).toList();
      final next = nexts.firstWhere((x) => !seen.contains(x), orElse: () => -1);
      if (next == -1) break;
      order.add(next);
      seen.add(next);
      prev = cur;
      cur = next;
    }
    if (order.length != n) return null;
    return [for (final k in order) corners[k]];
  }

  /// Order points CCW by polar angle around their centroid (works for convex /
  /// simple rooms; used only when the edge walk fails).
  static List<Vec2> _polarSort(List<Vec2> pts) {
    var cx = 0.0, cy = 0.0;
    for (final p in pts) {
      cx += p.x;
      cy += p.y;
    }
    cx /= pts.length;
    cy /= pts.length;
    final sorted = [...pts]
      ..sort((a, b) =>
          math.atan2(a.y - cy, a.x - cx).compareTo(math.atan2(b.y - cy, b.x - cx)));
    return sorted;
  }

  /// Force counter-clockwise winding (positive signed area).
  static List<Vec2> _ensureCcw(List<Vec2> poly) {
    var a = 0.0;
    for (var i = 0; i < poly.length; i++) {
      final p1 = poly[i];
      final p2 = poly[(i + 1) % poly.length];
      a += p1.x * p2.y - p2.x * p1.y;
    }
    return a < 0 ? poly.reversed.toList() : poly;
  }

  // ── straighten ───────────────────────────────────────────────────────────

  /// Snap edges within ±3° of an axis to exactly square, round lengths to 5 cm,
  /// re-close the loop, and drop collinear vertices. Mirrors
  /// [regularize] but with a scan-specific tolerance and 90°-only snap base
  /// (diagonals are risky to force on a real scan).
  static List<Vec2> _straighten(List<Vec2> poly) {
    final n = poly.length;
    if (n < 3) return List.of(poly);

    final lens = <double>[];
    final dirs = <double>[];
    for (var i = 0; i < n; i++) {
      final e = poly[(i + 1) % n] - poly[i];
      lens.add(roundTo(e.length, GeometryConfig.wallLengthStepM));
      dirs.add(_snapToAxis(math.atan2(e.y, e.x)));
    }

    final walk = <Vec2>[poly[0]];
    for (var i = 0; i < n; i++) {
      walk.add(walk.last + Vec2(math.cos(dirs[i]), math.sin(dirs[i])) * lens[i]);
    }
    final gap = walk[0] - walk[n];
    final out = <Vec2>[];
    for (var i = 0; i < n; i++) {
      out.add(walk[i] + gap * (i / n));
    }
    return removeCollinearVertices(out);
  }

  /// Snap [thetaRad] to the nearest multiple of 90° only when within
  /// [_scanStraightenToleranceDeg]; otherwise keep the free angle.
  static double _snapToAxis(double thetaRad) {
    final deg = thetaRad * 180 / math.pi;
    final cand = (deg / 90).round() * 90;
    var diff = (deg - cand).abs() % 360;
    if (diff > 180) diff = 360 - diff;
    if (diff <= _scanStraightenToleranceDeg) {
      return cand * math.pi / 180;
    }
    return thetaRad;
  }

  // ── openings ─────────────────────────────────────────────────────────────

  /// Nearest wall (edge `corners[i] → corners[i+1]`) to [centre], with the
  /// projected fractional [position] along it. Null when there are no walls.
  static ({int wallIndex, double position})? _nearestWall(
      List<Vec2> corners, Vec2 centre) {
    final n = corners.length;
    if (n < 2) return null;
    int? best;
    var bestDist = double.infinity;
    var bestT = 0.5;
    for (var i = 0; i < n; i++) {
      final a = corners[i];
      final b = corners[(i + 1) % n];
      final ab = b - a;
      final len2 = ab.dot(ab);
      final t = len2 == 0 ? 0.0 : ((centre - a).dot(ab) / len2).clamp(0.0, 1.0);
      final proj = a + ab * t;
      final d = proj.distanceTo(centre);
      if (d < bestDist) {
        bestDist = d;
        best = i;
        bestT = t;
      }
    }
    return best == null ? null : (wallIndex: best, position: bestT);
  }

  /// World Y of the room's floor plane, derived from the walls themselves.
  ///
  /// RoomPlan's world origin sits roughly at *device* height, **not** on the
  /// floor, so floor-level geometry normally has a negative Y (a real scan
  /// measured -1.622 m). Every wall runs floor-to-ceiling, so the lowest wall
  /// base is the floor. Uses the same wall filter as [_ceilingHeight] — the two
  /// read the same surfaces, one for the top, one for the bottom.
  ///
  /// Returns null when no usable wall exists (degenerate scan).
  static double? _floorLevel(List<ScanSurface> walls) {
    double? lowest;
    for (final w in walls) {
      final h = w.dimensions.y;
      final ty = w.transform.m[13];
      if (!h.isFinite || !ty.isFinite || h <= 0.1) continue;
      final base = ty - h / 2.0;
      if (lowest == null || base < lowest) lowest = base;
    }
    return lowest;
  }

  /// Height of a window's lower edge above the floor, in metres.
  ///
  /// The surface transform's Y is the opening's *centre* in RoomPlan world
  /// space; subtracting the floor plane is what makes it a sill. The old code
  /// used the absolute world Y, which on every real scan is negative and so hit
  /// the fallback every time.
  static double _windowSill(ScanSurface s, double height, double? floorY) {
    if (floorY == null) return _fallbackSillM;
    final sill = s.transform.m[13] - height / 2.0 - floorY;
    if (!sill.isFinite || sill < -_sillSlackM || sill > _maxSillM) {
      return _fallbackSillM;
    }
    // A hair below the floor plane is measurement noise, not bad data.
    return math.max(0.0, sill);
  }

  // ── misc ─────────────────────────────────────────────────────────────────

  static Vec2 _minCorner(List<Vec2> corners) {
    if (corners.isEmpty) return const Vec2(0, 0);
    var minX = corners.first.x, minY = corners.first.y;
    for (final c in corners) {
      minX = math.min(minX, c.x);
      minY = math.min(minY, c.y);
    }
    return Vec2(minX, minY);
  }

  static double _ceilingHeight(List<ScanSurface> walls) {
    final heights = [
      for (final w in walls)
        if (w.dimensions.y > 0.1) w.dimensions.y,
    ]..sort();
    if (heights.isEmpty) return GeometryConfig.defaultHeightM;
    final mid = heights.length ~/ 2;
    final median = heights.length.isOdd
        ? heights[mid]
        : (heights[mid - 1] + heights[mid]) / 2.0;
    return median.clamp(GeometryConfig.minHeightM, GeometryConfig.maxHeightM);
  }

  static RoomPlan _assemble(
    List<Vec2> corners,
    List<List<RoomOpening>> openingsPerWall,
    double ceiling,
    RoomSource source,
    String name,
  ) {
    if (corners.length < 3) {
      // Degenerate scan — hand back a minimal (invalid) plan; the UI surfaces
      // `plan.invalidReason` and offers a re-scan.
      return RoomPlan.fromCorners(
        corners.isEmpty
            ? const <Vec2>[Vec2(0, 0), Vec2(0, 0), Vec2(0, 0)]
            : corners,
        ceilingHeightM: ceiling,
        source: source,
        name: name,
      );
    }
    final n = corners.length;
    final walls = <RoomWall>[
      for (var i = 0; i < n; i++)
        RoomWall(
          i,
          (i + 1) % n,
          corners[i].distanceTo(corners[(i + 1) % n]),
          openings: openingsPerWall[i],
        ),
    ];
    return RoomPlan(
      corners: List.unmodifiable(corners),
      walls: List.unmodifiable(walls),
      ceilingHeightM: ceiling,
      source: source,
      name: name,
    );
  }
}
