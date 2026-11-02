import 'dart:math' as math;

import '../../geometry/room_geometry.dart';
import '../../models/room_plan.dart';
import '../../utils/opening_position.dart';

/// What the Android ARCore scanner hands back over `andoza/arscan`: raw floor
/// corners in metres (ARCore's X/Z, arbitrary orientation) plus the measured
/// ceiling height. All cleaning-up happens in [buildArcorePlan].
class ArScanRaw {
  const ArScanRaw({
    required this.corners,
    required this.height,
    required this.heightMeasured,
    required this.closed,
    required this.trackingLossCount,
    required this.durationSec,
    this.openings = const [],
  });

  /// When [closed], the last point is the tap that snapped onto the first
  /// corner (the loop's closure error), not a corner of its own.
  final List<Vec2> corners;
  final double height;
  final bool heightMeasured;
  final bool closed;
  final int trackingLossCount;
  final int durationSec;

  /// Doors/windows marked on the outline (empty from an older scanner).
  final List<ArRawOpening> openings;

  factory ArScanRaw.fromMap(Map<String, dynamic> m) => ArScanRaw(
        corners: [
          for (final p in (m['corners'] as List? ?? const []))
            Vec2((p as List)[0].toDouble(), p[1].toDouble()),
        ],
        height: (m['height'] as num? ?? 0).toDouble(),
        heightMeasured: m['heightMeasured'] == true,
        closed: m['closed'] == true,
        trackingLossCount: (m['trackingLossCount'] as num? ?? 0).toInt(),
        durationSec: (m['durationSec'] as num? ?? 0).toInt(),
        openings: [
          for (final o in (m['openings'] as List? ?? const []))
            ArRawOpening.fromMap(Map<String, dynamic>.from(o as Map)),
        ],
      );
}

/// A door/window as the scanner marked it: the stretch [t0]..[t1] (fractions)
/// of outline edge [edge], i.e. corner `edge` → `edge + 1` of the loop with a
/// closed outline's closing tap dropped.
class ArRawOpening {
  const ArRawOpening(this.type, this.edge, this.t0, this.t1);

  /// `'door'` or `'window'`.
  final String type;
  final int edge;
  final double t0;
  final double t1;

  factory ArRawOpening.fromMap(Map<String, dynamic> m) => ArRawOpening(
        m['type'] == 'window' ? 'window' : 'door',
        (m['edge'] as num).toInt(),
        (m['t0'] as num).toDouble(),
        (m['t1'] as num).toDouble(),
      );
}

sealed class ArPlanResult {
  const ArPlanResult();
}

class ArPlanOk extends ArPlanResult {
  const ArPlanOk(this.plan);
  final RoomPlan plan;
}

/// [reason]: `too_few_corners` | `self_intersecting` | `wall_too_long`.
class ArPlanRejected extends ArPlanResult {
  const ArPlanRejected(this.reason);
  final String reason;
}

const double _mergeM = 0.10;
const double _snapToleranceDeg = 8;
const double _maxWallM = 30;
const double _doorHeightM = 2.0;
const double _windowHeightM = 1.5;
const double _windowSillM = 0.9;
const double _ceilingGapM = 0.10;

/// Raw ARCore corners → a squared, validated [RoomPlan]:
/// spread the loop's closure error → merge corners < 10 cm apart → square walls
/// within ±8° of a right angle (slanted walls stay slanted) → validate → 1 cm.
ArPlanResult buildArcorePlan(ArScanRaw raw, {String name = 'Xona'}) {
  var pts = List<Vec2>.of(raw.corners);
  if (raw.closed && pts.length >= 4) pts = _spreadClosureError(pts);
  // The outline the scanner's opening edges index into, before any cleaning.
  final loop = List<Vec2>.unmodifiable(pts);
  // Which raw corner each remaining corner came from, through every step below.
  var origin = mergeCloseVertexIndices(pts, _mergeM);
  pts = [for (final i in origin) pts[i]];
  if (pts.length < 3) return const ArPlanRejected('too_few_corners');
  if (_longestEdge(pts) > _maxWallM) return const ArPlanRejected('wall_too_long');
  if (isSelfIntersecting(pts)) return const ArPlanRejected('self_intersecting');

  pts = _square(pts); // one corner in, one corner out
  final kept = collinearKeepIndices(pts);
  pts = [for (final i in kept) pts[i]];
  origin = [for (final i in kept) origin[i]];
  if (pts.length < 3) return const ArPlanRejected('too_few_corners');
  // Squaring re-closes the loop by stretching walls, so check the final plan too.
  if (_longestEdge(pts) > _maxWallM) return const ArPlanRejected('wall_too_long');
  if (isSelfIntersecting(pts)) return const ArPlanRejected('self_intersecting');

  // ARCore's origin is wherever the session started; start the plan at (0, 0)
  // like the iOS converter does.
  final minX = pts.map((p) => p.x).reduce(math.min);
  final minY = pts.map((p) => p.y).reduce(math.min);
  final corners = [for (final p in pts) Vec2(_cm(p.x - minX), _cm(p.y - minY))];
  final n = corners.length;
  final openings = _placeOpenings(raw, loop, origin, corners);
  return ArPlanOk(RoomPlan(
    corners: List.unmodifiable(corners),
    walls: List.unmodifiable([
      for (var i = 0; i < n; i++)
        RoomWall(i, (i + 1) % n, _cm(corners[i].distanceTo(corners[(i + 1) % n])),
            openings: List.unmodifiable(openings[i])),
    ]),
    ceilingHeightM: raw.height,
    source: RoomSource.arcore,
    name: name,
  ));
}

double _cm(double v) => (v * 100).roundToDouble() / 100;

/// Puts each scanned opening on the final wall its raw edge ended up in.
/// Final wall `j` is made of raw edges `origin[j] .. origin[j+1] - 1` (around
/// the loop); a door's distance from the wall start is measured along those raw
/// edges and scaled to the squared wall's length.
List<List<RoomOpening>> _placeOpenings(
    ArScanRaw raw, List<Vec2> loop, List<int> origin, List<Vec2> corners) {
  final n = corners.length;
  final m = loop.length;
  final out = [for (var j = 0; j < n; j++) <RoomOpening>[]];
  double rawLen(int e) => loop[e % m].distanceTo(loop[(e + 1) % m]);

  for (final o in raw.openings) {
    if (o.edge < 0 || o.edge >= m) continue;
    for (var j = 0; j < n; j++) {
      final start = origin[j];
      final span = (origin[(j + 1) % n] - start + m) % m; // raw edges in wall j
      final k = (o.edge - start + m) % m; // o.edge's place in that run
      if (span == 0 || k >= span) continue;
      var before = 0.0, total = 0.0;
      for (var e = 0; e < span; e++) {
        if (e < k) before += rawLen(start + e);
        total += rawLen(start + e);
      }
      final finalLen = corners[j].distanceTo(corners[(j + 1) % n]);
      if (total == 0 || finalLen == 0) break;
      final scale = finalLen / total;
      final edgeLen = rawLen(o.edge);
      final width = math.min((o.t1 - o.t0) * edgeLen * scale, finalLen);
      final left = ((before + o.t0 * edgeLen) * scale).clamp(0.0, finalLen - width);
      final window = o.type == 'window';
      var height = window ? _windowHeightM : _doorHeightM;
      final sill = window ? _windowSillM : 0.0;
      if (raw.heightMeasured) height = math.min(height, raw.height - _ceilingGapM - sill);
      out[j].add(RoomOpening(
        type: window ? 'window' : 'door',
        width: _cm(width),
        height: _cm(height),
        position: leftEdgeToCentreFraction(offsetM: left, wallLengthM: finalLen, widthM: width),
        sillHeight: sill,
      ));
      break;
    }
  }
  return out;
}

double _longestEdge(List<Vec2> p) {
  var best = 0.0;
  for (var i = 0; i < p.length; i++) {
    best = math.max(best, p[i].distanceTo(p[(i + 1) % p.length]));
  }
  return best;
}

/// The last point is where the user closed the loop; it should have been the
/// first corner. Pull every corner back by its share of that error, in
/// proportion to how far along the walk it sits, then drop the closing point.
List<Vec2> _spreadClosureError(List<Vec2> pts) {
  final error = pts.last - pts.first;
  var total = 0.0;
  for (var i = 0; i < pts.length - 1; i++) {
    total += pts[i].distanceTo(pts[i + 1]);
  }
  if (total == 0) return pts.sublist(0, pts.length - 1);
  final out = <Vec2>[];
  var walked = 0.0;
  for (var i = 0; i < pts.length - 1; i++) {
    if (i > 0) walked += pts[i - 1].distanceTo(pts[i]);
    out.add(pts[i] - error * (walked / total));
  }
  return out;
}

/// Square the outline in the room's own frame (the longest wall along X):
/// edges within ±8° of a multiple of 90° become exact, the rest keep their
/// angle, and the loop is re-closed by stretching the squared walls along
/// their own axis so no snapped angle is disturbed.
List<Vec2> _square(List<Vec2> pts) {
  final n = pts.length;
  var longest = 0;
  for (var i = 1; i < n; i++) {
    if (_edge(pts, i).length > _edge(pts, longest).length) longest = i;
  }
  final e = _edge(pts, longest);
  final theta = math.atan2(e.y, e.x);
  final local = [for (final p in pts) _rotate(p, -theta)];

  final dirs = <double>[];
  final lens = <double>[];
  final axis = <int>[]; // 0 = along X, 1 = along Y, -1 = free
  for (var i = 0; i < n; i++) {
    final d = _edge(local, i);
    lens.add(d.length);
    final a = math.atan2(d.y, d.x);
    final snapped = (a / (math.pi / 2)).round() * (math.pi / 2);
    if ((a - snapped).abs() * 180 / math.pi <= _snapToleranceDeg) {
      dirs.add(snapped);
      axis.add(((snapped / (math.pi / 2)).round() % 2 == 0) ? 0 : 1);
    } else {
      dirs.add(a);
      axis.add(-1);
    }
  }

  Vec2 walkEnd() {
    var p = local[0];
    for (var i = 0; i < n; i++) {
      p = p + Vec2(math.cos(dirs[i]), math.sin(dirs[i])) * lens[i];
    }
    return p;
  }

  final gap = local[0] - walkEnd();
  for (final ax in const [0, 1]) {
    final g = ax == 0 ? gap.x : gap.y;
    final idx = [for (var i = 0; i < n; i++) if (axis[i] == ax) i];
    final sum = idx.fold<double>(0, (s, i) => s + lens[i]);
    if (sum == 0) continue;
    for (final i in idx) {
      final sign = ax == 0 ? math.cos(dirs[i]).sign : math.sin(dirs[i]).sign;
      lens[i] = math.max(0.01, lens[i] + sign * g * (lens[i] / sum));
    }
  }

  // Anything still open (no squared wall on an axis) is spread over the corners.
  final rest = local[0] - walkEnd();
  final out = <Vec2>[local[0]];
  for (var i = 0; i < n - 1; i++) {
    out.add(out.last + Vec2(math.cos(dirs[i]), math.sin(dirs[i])) * lens[i]);
  }
  return [for (var i = 0; i < n; i++) out[i] + rest * (i / n)];
}

Vec2 _edge(List<Vec2> p, int i) => p[(i + 1) % p.length] - p[i];

Vec2 _rotate(Vec2 p, double a) =>
    Vec2(p.x * math.cos(a) - p.y * math.sin(a), p.x * math.sin(a) + p.y * math.cos(a));
