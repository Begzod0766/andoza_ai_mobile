import 'dart:math' as math;

import 'geometry_config.dart';

/// A 2-D point/vector in **metres**. Pure Dart (no Flutter) so the whole
/// geometry layer is unit-testable without a widget binding.
class Vec2 {
  final double x;
  final double y;
  const Vec2(this.x, this.y);

  Vec2 operator +(Vec2 o) => Vec2(x + o.x, y + o.y);
  Vec2 operator -(Vec2 o) => Vec2(x - o.x, y - o.y);
  Vec2 operator *(double s) => Vec2(x * s, y * s);

  double get length => math.sqrt(x * x + y * y);
  double distanceTo(Vec2 o) => (this - o).length;
  double dot(Vec2 o) => x * o.x + y * o.y;

  Vec2 get normalized {
    final l = length;
    return l == 0 ? const Vec2(0, 0) : Vec2(x / l, y / l);
  }

  @override
  bool operator ==(Object other) =>
      other is Vec2 && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() =>
      'Vec2(${x.toStringAsFixed(3)}, ${y.toStringAsFixed(3)})';
}

/// The single, canonical length formatter (metres). All UI must format lengths
/// through this so units/precision stay consistent.
String formatLength(double meters) => '${meters.toStringAsFixed(2)} m';

// ---------------------------------------------------------------------------
// Measures
// ---------------------------------------------------------------------------

/// Perimeter of a closed polygon (m).
double perimeter(List<Vec2> poly) {
  if (poly.length < 2) return 0;
  var p = 0.0;
  for (var i = 0; i < poly.length; i++) {
    p += poly[i].distanceTo(poly[(i + 1) % poly.length]);
  }
  return p;
}

/// Absolute area of a closed polygon via the shoelace formula (m²).
double shoelaceArea(List<Vec2> poly) {
  if (poly.length < 3) return 0;
  var a = 0.0;
  for (var i = 0; i < poly.length; i++) {
    final p1 = poly[i];
    final p2 = poly[(i + 1) % poly.length];
    a += p1.x * p2.y - p2.x * p1.y;
  }
  return a.abs() / 2;
}

/// Axis-aligned bounding size of a polygon (m).
({double width, double length}) boundingSize(List<Vec2> poly) {
  if (poly.isEmpty) return (width: 0, length: 0);
  var minX = poly.first.x, maxX = poly.first.x;
  var minY = poly.first.y, maxY = poly.first.y;
  for (final p in poly) {
    minX = math.min(minX, p.x);
    maxX = math.max(maxX, p.x);
    minY = math.min(minY, p.y);
    maxY = math.max(maxY, p.y);
  }
  return (width: maxX - minX, length: maxY - minY);
}

// ---------------------------------------------------------------------------
// Cleanup primitives
// ---------------------------------------------------------------------------

/// Resample an open polyline to roughly even [step]-spaced points.
List<Vec2> resample(List<Vec2> path,
    [double step = GeometryConfig.resampleStepM]) {
  if (path.length < 2 || step <= 0) return List.of(path);
  final out = <Vec2>[path.first];
  var acc = 0.0;
  for (var i = 1; i < path.length; i++) {
    var a = out.last;
    final b = path[i];
    var seg = a.distanceTo(b);
    while (acc + seg >= step && seg > 1e-9) {
      final t = (step - acc) / seg;
      final np = a + (b - a) * t;
      out.add(np);
      a = np;
      seg = a.distanceTo(b);
      acc = 0;
    }
    acc += seg;
  }
  if (out.last.distanceTo(path.last) > 1e-9) out.add(path.last);
  return out;
}

/// Ramer–Douglas–Peucker polyline simplification (keeps corner candidates).
List<Vec2> rdpSimplify(List<Vec2> pts,
    [double eps = GeometryConfig.rdpEpsilonM]) {
  if (pts.length < 3) return List.of(pts);
  var maxD = 0.0;
  var idx = 0;
  final end = pts.length - 1;
  for (var i = 1; i < end; i++) {
    final d = _perpDist(pts[i], pts[0], pts[end]);
    if (d > maxD) {
      maxD = d;
      idx = i;
    }
  }
  if (maxD > eps) {
    final left = rdpSimplify(pts.sublist(0, idx + 1), eps);
    final right = rdpSimplify(pts.sublist(idx), eps);
    return [...left.sublist(0, left.length - 1), ...right];
  }
  return [pts.first, pts.last];
}

/// Merge polygon vertices that sit closer than [minDist] (incl. the wrap-around
/// closing vertex).
List<Vec2> mergeCloseVertices(List<Vec2> poly,
        [double minDist = GeometryConfig.mergeDistM]) =>
    [for (final i in mergeCloseVertexIndices(poly, minDist)) poly[i]];

/// The indices of [poly] that [mergeCloseVertices] keeps, in order.
List<int> mergeCloseVertexIndices(List<Vec2> poly,
    [double minDist = GeometryConfig.mergeDistM]) {
  if (poly.length < 3) return [for (var i = 0; i < poly.length; i++) i];
  final out = <int>[];
  for (var i = 0; i < poly.length; i++) {
    if (out.isEmpty || poly[out.last].distanceTo(poly[i]) >= minDist) out.add(i);
  }
  while (out.length > 3 && poly[out.first].distanceTo(poly[out.last]) < minDist) {
    out.removeLast();
  }
  return out;
}

// ---------------------------------------------------------------------------
// Angle snapping + regularization
// ---------------------------------------------------------------------------

/// Snap an angle (radians) to the nearest configured base multiple if it is
/// within [GeometryConfig.angleSnapToleranceDeg]; otherwise return it unchanged
/// (free angle preserved).
double snapAngleRad(double thetaRad) {
  final deg = _deg(thetaRad);
  double? best;
  var bestDiff = GeometryConfig.angleSnapToleranceDeg;
  for (final base in GeometryConfig.snapBasesDeg) {
    final cand = (deg / base).round() * base;
    final diff = _angDiff(deg, cand);
    if (diff <= bestDiff) {
      best = cand;
      bestDiff = diff;
    }
  }
  return best == null ? thetaRad : _rad(best);
}

/// Regularize a *simplified* polygon: snap each edge's direction to a nice angle
/// (when within tolerance), round wall lengths to 5 cm, and re-close the loop by
/// spreading the residual gap across the vertices. Free (non-snapped) edges keep
/// their orientation, so deliberately skewed rooms survive.
List<Vec2> regularize(List<Vec2> poly) {
  final n = poly.length;
  if (n < 3) return List.of(poly);

  final lens = <double>[];
  final dirs = <double>[];
  for (var i = 0; i < n; i++) {
    final e = poly[(i + 1) % n] - poly[i];
    lens.add(roundTo(e.length, GeometryConfig.wallLengthStepM));
    dirs.add(snapAngleRad(math.atan2(e.y, e.x)));
  }

  // Walk the (open) chain with snapped directions + rounded lengths.
  final walk = <Vec2>[poly[0]];
  for (var i = 0; i < n; i++) {
    walk.add(walk.last + Vec2(math.cos(dirs[i]), math.sin(dirs[i])) * lens[i]);
  }

  // Spread the closing gap so the polygon comes back to its start.
  final gap = walk[0] - walk[n];
  final out = <Vec2>[];
  for (var i = 0; i < n; i++) {
    out.add(walk[i] + gap * (i / n));
  }
  // Drop straightened-out (collinear) vertices so a wobbly straight wall
  // collapses to a single wall.
  return removeCollinearVertices(out);
}

/// Remove vertices whose turn angle is below [tolDeg] (they lie on a straight
/// wall). Keeps at least 3 corners.
List<Vec2> removeCollinearVertices(List<Vec2> poly,
        [double tolDeg = GeometryConfig.collinearToleranceDeg]) =>
    [for (final i in collinearKeepIndices(poly, tolDeg)) poly[i]];

/// The indices of [poly] that [removeCollinearVertices] keeps, in order.
List<int> collinearKeepIndices(List<Vec2> poly,
    [double tolDeg = GeometryConfig.collinearToleranceDeg]) {
  final n = poly.length;
  final all = [for (var i = 0; i < n; i++) i];
  if (n < 4) return all;
  final tol = _rad(tolDeg);
  final keep = <int>[];
  for (var i = 0; i < n; i++) {
    if (_turnAngle(poly[(i - 1 + n) % n], poly[i], poly[(i + 1) % n]) > tol) keep.add(i);
  }
  return keep.length >= 3 ? keep : all;
}

/// Turn angle at [b] on the path a→b→c (radians; 0 = straight).
double _turnAngle(Vec2 a, Vec2 b, Vec2 c) {
  final v1 = b - a, v2 = c - b;
  final l1 = v1.length, l2 = v2.length;
  if (l1 == 0 || l2 == 0) return 0;
  return math.acos((v1.dot(v2) / (l1 * l2)).clamp(-1.0, 1.0));
}

/// Full "raw finger stroke → clean polygon" pipeline used by freehand drawing:
/// resample → RDP → merge-close → regularize.
List<Vec2> regularizeFreehand(List<Vec2> raw) {
  if (raw.length < 3) return List.of(raw);
  return regularize(mergeCloseVertices(rdpSimplify(resample(raw))));
}

// ---------------------------------------------------------------------------
// Validity
// ---------------------------------------------------------------------------

/// Whether [corners] describe a plain axis-aligned rectangle: exactly 4 corners
/// where every edge (including the closing edge) is purely horizontal or purely
/// vertical (|dx| < [eps] or |dy| < [eps]). Non-rectangles (L-shapes,
/// trapezoids, triangles, skewed quads, …) return false so their true polygon
/// is persisted instead of a bounding box.
bool isAxisAlignedRectangle(List<Vec2> corners, [double eps = 0.02]) {
  if (corners.length != 4) return false;
  for (var i = 0; i < 4; i++) {
    final e = corners[(i + 1) % 4] - corners[i];
    if (e.x.abs() >= eps && e.y.abs() >= eps) return false;
  }
  return true;
}

/// Whether any two non-adjacent edges of the closed polygon cross.
bool isSelfIntersecting(List<Vec2> poly) {
  final n = poly.length;
  if (n < 4) return false;
  for (var i = 0; i < n; i++) {
    final a1 = poly[i];
    final a2 = poly[(i + 1) % n];
    for (var j = i + 1; j < n; j++) {
      // Skip edges that share a vertex with edge i (adjacent or same).
      if (j == i || (i + 1) % n == j || (j + 1) % n == i) continue;
      final b1 = poly[j];
      final b2 = poly[(j + 1) % n];
      if (_segmentsIntersect(a1, a2, b1, b2)) return true;
    }
  }
  return false;
}

/// Round [v] to the nearest multiple of [step].
double roundTo(double v, double step) =>
    step <= 0 ? v : (v / step).round() * step;

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

double _deg(double rad) => rad * 180 / math.pi;
double _rad(double deg) => deg * math.pi / 180;

/// Smallest absolute difference between two angles in degrees (0..180).
double _angDiff(double a, double b) {
  var d = (a - b).abs() % 360;
  if (d > 180) d = 360 - d;
  return d;
}

double _perpDist(Vec2 p, Vec2 a, Vec2 b) {
  final dx = b.x - a.x, dy = b.y - a.y;
  final len = math.sqrt(dx * dx + dy * dy);
  if (len == 0) return p.distanceTo(a);
  return ((p.x - a.x) * dy - (p.y - a.y) * dx).abs() / len;
}

double _cross(Vec2 o, Vec2 a, Vec2 b) =>
    (a.x - o.x) * (b.y - o.y) - (a.y - o.y) * (b.x - o.x);

bool _segmentsIntersect(Vec2 p1, Vec2 p2, Vec2 p3, Vec2 p4) {
  final d1 = _cross(p3, p4, p1);
  final d2 = _cross(p3, p4, p2);
  final d3 = _cross(p1, p2, p3);
  final d4 = _cross(p1, p2, p4);
  if (((d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0)) &&
      ((d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0))) {
    return true;
  }
  return false;
}
