import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/features/ar_scan/arcore_plan.dart';
import 'package:tamir_uy_mobile_flutter/geometry/room_geometry.dart';
import 'package:tamir_uy_mobile_flutter/models/room_plan.dart';

ArScanRaw _raw(List<List<double>> pts,
        {bool closed = false, double height = 2.7, List<ArRawOpening> openings = const []}) =>
    ArScanRaw(
      corners: [for (final p in pts) Vec2(p[0], p[1])],
      height: height,
      heightMeasured: true,
      closed: closed,
      trackingLossCount: 0,
      durationSec: 60,
      openings: openings,
    );

RoomPlan _ok(ArPlanResult r) {
  expect(r, isA<ArPlanOk>(), reason: r is ArPlanRejected ? r.reason : null);
  return (r as ArPlanOk).plan;
}

String _rejected(ArPlanResult r) {
  expect(r, isA<ArPlanRejected>());
  return (r as ArPlanRejected).reason;
}

/// Interior angle at corner i, in degrees.
double _angleAt(List<Vec2> c, int i) {
  final n = c.length;
  final a = c[(i - 1 + n) % n] - c[i];
  final b = c[(i + 1) % n] - c[i];
  final cos = a.dot(b) / (a.length * b.length);
  return math.acos(cos.clamp(-1.0, 1.0)) * 180 / math.pi;
}

List<double> _sortedWalls(RoomPlan p) => [for (final w in p.walls) w.lengthM]..sort();

void main() {
  test('squares a slightly skewed rectangle', () {
    final plan = _ok(buildArcorePlan(_raw([
      [0, 0], [4.02, 0.05], [3.98, 3.03], [-0.03, 2.98],
    ])));
    expect(plan.corners, hasLength(4));
    for (var i = 0; i < 4; i++) {
      expect(_angleAt(plan.corners, i), closeTo(90, 0.01));
    }
    expect(plan.areaM2, closeTo(12.0, 0.25));
  });

  test('squares a rectangle that is rotated in the ARCore frame', () {
    // Same room, but ARCore's x axis sits 30° off the walls.
    final r = 30 * math.pi / 180;
    Vec2 rot(double x, double y) => Vec2(x * math.cos(r) - y * math.sin(r), x * math.sin(r) + y * math.cos(r));
    final pts = [rot(0, 0), rot(4.02, 0.05), rot(3.98, 3.03), rot(-0.03, 2.98)];
    final plan = _ok(buildArcorePlan(_raw([for (final p in pts) [p.x, p.y]])));
    for (var i = 0; i < 4; i++) {
      expect(_angleAt(plan.corners, i), closeTo(90, 0.01));
    }
  });

  test('keeps all six corners of an L-shape', () {
    final plan = _ok(buildArcorePlan(_raw([
      [0, 0], [4, 0], [4, 2], [2, 2], [2, 4], [0, 4],
    ])));
    expect(plan.corners, hasLength(6));
    expect(plan.areaM2, closeTo(12.0, 0.05));
  });

  test('leaves a genuinely slanted wall slanted', () {
    // Trapezoid: the right wall leans 15° (75° corner at the bottom right).
    final dx = 3 / math.tan(75 * math.pi / 180);
    final plan = _ok(buildArcorePlan(_raw([
      [0, 0], [5, 0], [5 - dx, 3], [0, 3],
    ])));
    final angles = [for (var i = 0; i < 4; i++) _angleAt(plan.corners, i)]..sort();
    expect(angles.first, closeTo(75, 1));
  });

  test('spreads the closure error along the walls', () {
    // A true 4 × 3 room measured with drift that grows linearly to (0.10, 0.06)
    // by the time the user is back at the first corner.
    const ex = 0.10, ey = 0.06, total = 14.0;
    List<double> drifted(double x, double y, double walked) =>
        [x + ex * walked / total, y + ey * walked / total];
    final plan = _ok(buildArcorePlan(_raw([
      drifted(0, 0, 0), drifted(4, 0, 4), drifted(4, 3, 7), drifted(0, 3, 11),
      drifted(0, 0, 14),
    ], closed: true)));
    expect(plan.corners, hasLength(4));
    expect(perimeter(plan.corners), closeTo(14.0, 0.05));
  });

  test('merges corners closer than 10 cm', () {
    final plan = _ok(buildArcorePlan(_raw([
      [0, 0], [4, 0], [4.06, 0.0], [4, 3], [0, 3],
    ])));
    expect(plan.corners, hasLength(4));
  });

  test('closes an open outline without redistributing', () {
    final plan = _ok(buildArcorePlan(_raw([
      [0, 0], [4, 0], [4, 3], [0, 3],
    ])));
    expect(plan.walls, hasLength(4));
    expect(_sortedWalls(plan), [3.0, 3.0, 4.0, 4.0]);
  });

  test('clockwise and counter-clockwise give the same plan', () {
    final ccw = _ok(buildArcorePlan(_raw([[0, 0], [4, 0], [4, 3], [0, 3]])));
    final cw = _ok(buildArcorePlan(_raw([[0, 0], [0, 3], [4, 3], [4, 0]])));
    expect(cw.areaM2, closeTo(ccw.areaM2, 1e-6));
    expect(_sortedWalls(cw), _sortedWalls(ccw));
  });

  test('rejects fewer than 3 corners', () {
    expect(_rejected(buildArcorePlan(_raw([[0, 0], [4, 0]]))), 'too_few_corners');
  });

  test('rejects a self-intersecting outline', () {
    expect(_rejected(buildArcorePlan(_raw([[0, 0], [4, 3], [4, 0], [0, 3]]))), 'self_intersecting');
  });

  test('rejects an outlier corner', () {
    expect(_rejected(buildArcorePlan(_raw([[0, 0], [35, 0], [35, 3], [0, 3]]))), 'wall_too_long');
  });

  test('rejects a wall that squaring stretches past 30 m', () {
    // Every raw wall is under 30 m (longest 29.91 m), but closing the squared
    // outline stretches the bottom wall to ~30.2 m.
    expect(
      _rejected(buildArcorePlan(_raw([[0, 0], [29.91, 0], [30.52, 5.48], [1.4, 5.45]]))),
      'wall_too_long',
    );
  });

  test('tags the plan as arcore and rounds to 1 cm', () {
    final plan = _ok(buildArcorePlan(_raw([[0, 0], [4.123, 0], [4.123, 3.0567], [0, 3.0567]])));
    expect(plan.source, RoomSource.arcore);
    expect(plan.ceilingHeightM, 2.7);
    for (final w in plan.walls) {
      expect((w.lengthM * 100 - (w.lengthM * 100).round()).abs(), lessThan(1e-6));
    }
  });

  test('ArScanRaw.fromMap parses the channel payload', () {
    final raw = ArScanRaw.fromMap({
      'corners': [[0.0, 0.0], [4.0, 0.0], [4.0, 3.0]],
      'height': 2.74,
      'heightMeasured': true,
      'closed': true,
      'trackingLossCount': 2,
      'durationSec': 95,
    });
    expect(raw.corners, [const Vec2(0, 0), const Vec2(4, 0), const Vec2(4, 3)]);
    expect(raw.height, 2.74);
    expect(raw.heightMeasured, isTrue);
    expect(raw.closed, isTrue);
    expect(raw.trackingLossCount, 2);
    expect(raw.durationSec, 95);
  });

  test('moves the plan to the origin like the iOS scan does', () {
    // ARCore's world origin is wherever the session started, so raw corners
    // are often negative; the saved plan starts at (0, 0).
    final plan = _ok(buildArcorePlan(_raw([[-3.2, -1.5], [0.8, -1.5], [0.8, 1.5], [-3.2, 1.5]])));
    final minX = plan.corners.map((c) => c.x).reduce(math.min);
    final minY = plan.corners.map((c) => c.y).reduce(math.min);
    expect(minX, closeTo(0, 1e-9));
    expect(minY, closeTo(0, 1e-9));
  });

  group('doors and windows', () {
    const rect = [[0.0, 0.0], [4.0, 0.0], [4.0, 3.0], [0.0, 3.0]];

    RoomOpening only(RoomPlan p, int wall) => p.walls[wall].openings.single;

    /// Wall whose corners are [a] → [b] in the final plan.
    int wallBetween(RoomPlan p, Vec2 a, Vec2 b) => p.walls.indexWhere((w) =>
        p.corners[w.a].distanceTo(a) < 0.02 && p.corners[w.b].distanceTo(b) < 0.02);

    test('a result without openings parses to none', () {
      final raw = ArScanRaw.fromMap({
        'corners': rect,
        'height': 2.7,
        'heightMeasured': true,
        'closed': false,
      });
      expect(raw.openings, isEmpty);
      expect(_ok(buildArcorePlan(raw)).walls.every((w) => w.openings.isEmpty), isTrue);
    });

    test('fromMap reads openings', () {
      final raw = ArScanRaw.fromMap({
        'corners': rect,
        'height': 2.7,
        'openings': [
          {'type': 'window', 'edge': 2, 't0': 0.25, 't1': 0.5},
        ],
      });
      final o = raw.openings.single;
      expect([o.type, o.edge, o.t0, o.t1], ['window', 2, 0.25, 0.5]);
    });

    test('a door lands on its rectangle wall', () {
      final p = _ok(buildArcorePlan(_raw(rect, openings: const [ArRawOpening('door', 0, 0.25, 0.5)])));
      final o = only(p, 0);
      expect(o.type, 'door');
      expect(o.width, closeTo(1.0, 0.005));
      expect(o.height, 2.0);
      expect(o.sillHeight, 0.0);
      expect(o.position, closeTo(0.375, 0.005));
    });

    test('a window gets the window defaults', () {
      final o = only(_ok(buildArcorePlan(_raw(rect, openings: const [ArRawOpening('window', 1, 0.2, 0.6)]))), 1);
      expect(o.type, 'window');
      expect(o.height, 1.5);
      expect(o.sillHeight, 0.9);
    });

    test('an opening on the closing wall of a closed outline', () {
      final p = _ok(buildArcorePlan(_raw([...rect, [0.05, 0.03]],
          closed: true, openings: const [ArRawOpening('door', 3, 0.4, 0.6)])));
      // Corner order survives (the plan may come out turned): edge 3 is wall 3.
      expect(p.walls[3].lengthM, closeTo(3.0, 0.02));
      expect(only(p, 3).position, closeTo(0.5, 0.01));
      expect(only(p, 3).width, closeTo(0.6, 0.02));
      expect([0, 1, 2].every((i) => p.walls[i].openings.isEmpty), isTrue);
    });

    test('an opening on the last wall of an open outline', () {
      final p = _ok(buildArcorePlan(_raw(rect, openings: const [ArRawOpening('window', 3, 0.4, 0.6)])));
      final w = wallBetween(p, const Vec2(0, 3), const Vec2(0, 0));
      expect(only(p, w).position, closeTo(0.5, 0.01));
    });

    test('an opening on a wall that was merged from two raw walls', () {
      // An extra corner half-way along the 4 m wall: raw edges 0 (0→2 m) and 1 (2→4 m).
      final p = _ok(buildArcorePlan(_raw(
        [[0, 0], [2, 0], [4, 0], [4, 3], [0, 3]],
        openings: const [ArRawOpening('door', 1, 0.5, 1.0)], // 3.0 → 4.0 m
      )));
      // The 4 m back wall is the longest, so the plan comes out turned 180°.
      expect(p.walls, hasLength(4));
      final w = p.walls.singleWhere((w) => w.openings.isNotEmpty);
      expect(w.lengthM, closeTo(4.0, 0.01));
      expect(w.openings.single.width, closeTo(1.0, 0.01));
      expect(w.openings.single.position, closeTo(3.5 / 4, 0.01));
    });

    test('an opening on a merged wall when the first raw corner was dropped', () {
      // Corner 0 sits mid-wall and is removed as collinear; edge 4 (0,3)→(0,1.5) and
      // edge 0 (0,1.5)→(0,0) make one wall.
      final p = _ok(buildArcorePlan(_raw(
        [[0, 1.5], [0, 0], [4, 0], [4, 3], [0, 3]],
        openings: const [ArRawOpening('door', 4, 0.0, 0.5)], // (0,3) → (0,2.25)
      )));
      expect(p.walls, hasLength(4));
      final len = 3.0;
      for (final w in p.walls) {
        if (w.openings.isEmpty) continue;
        expect(w.lengthM, closeTo(len, 0.01));
        expect(w.openings.single.width, closeTo(0.75, 0.01));
        // From the wall's start (0,3): centre at 0.375 m.
        expect(p.corners[w.a].distanceTo(const Vec2(0, 3)), lessThan(0.02));
        expect(w.openings.single.position, closeTo(0.375 / len, 0.01));
        return;
      }
      fail('no wall has the door');
    });

    test('an opening flush against a corner stays on the wall', () {
      final p = _ok(buildArcorePlan(_raw(rect, openings: const [
        ArRawOpening('door', 0, 0.0, 0.25),
        ArRawOpening('window', 0, 0.75, 1.0),
      ])));
      final len = p.walls[0].lengthM;
      for (final o in p.walls[0].openings) {
        expect(o.position - o.width / 2 / len, greaterThanOrEqualTo(-1e-9));
        expect(o.position + o.width / 2 / len, lessThanOrEqualTo(1 + 1e-9));
      }
    });

    test('a low measured ceiling shrinks the defaults', () {
      final p = _ok(buildArcorePlan(_raw(rect, height: 2.05, openings: const [
        ArRawOpening('door', 0, 0.1, 0.3),
        ArRawOpening('window', 1, 0.2, 0.6),
      ])));
      expect(only(p, 0).height, closeTo(1.95, 0.001));
      expect(only(p, 1).height, closeTo(1.05, 0.001));
    });
  });
}
