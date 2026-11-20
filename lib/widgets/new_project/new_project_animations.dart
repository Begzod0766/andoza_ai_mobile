import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../config/design_tokens.dart';
import '../room/iso_projector.dart';
import '../room/isometric_room_view.dart';

/// Drives a looping illustration: [builder] gets `t` in [0, 1), repeating
/// every [period]. With `MediaQuery.disableAnimations` no ticker runs and the
/// builder gets [staticT] — one representative still frame.
class LoopingAnimation extends StatefulWidget {
  const LoopingAnimation({
    required this.period,
    required this.staticT,
    required this.builder,
    super.key,
  });

  final Duration period;
  final double staticT;
  final Widget Function(BuildContext context, double t) builder;

  @override
  State<LoopingAnimation> createState() => _LoopingAnimationState();
}

class _LoopingAnimationState extends State<LoopingAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.period,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return widget.builder(context, widget.staticT);
    }
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => widget.builder(context, _c.value),
    );
  }
}

/// 0 → 1 as [t] goes from [a] to [b], eased; clamped outside.
double _phase(double t, double a, double b) =>
    Curves.easeInOut.transform(((t - a) / (b - a)).clamp(0.0, 1.0));

String _m(double v) => '${v.toStringAsFixed(1)} m';

void _paintFinger(Canvas canvas, Offset at, double alpha) {
  if (alpha <= 0) return;
  canvas.drawCircle(
    at,
    13,
    Paint()..color = DesignTokens.primaryBlue.withValues(alpha: 0.18 * alpha),
  );
  canvas.drawCircle(
    at,
    7,
    Paint()..color = DesignTokens.white.withValues(alpha: alpha),
  );
  canvas.drawCircle(
    at,
    7,
    Paint()
      ..color = DesignTokens.primaryBlue.withValues(alpha: alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2,
  );
}

void _paintNumber(
  Canvas canvas,
  String text,
  Offset centre, {
  double alpha = 1,
  double size = 11,
  Color color = DesignTokens.textGray,
}) {
  if (alpha <= 0) return;
  final tp = TextPainter(
    textDirection: TextDirection.ltr,
    text: TextSpan(
      text: text,
      style: TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: color.withValues(alpha: alpha),
      ),
    ),
  )..layout();
  tp.paint(canvas, centre - Offset(tp.width / 2, tp.height / 2));
}

// ---------------------------------------------------------------------------
// 3D Master: a finger drags the front corner of the wizard's iso room box;
// the walls stretch and the "W m × D m" readout follows.
// ---------------------------------------------------------------------------

class WizardBoxAnimation extends StatelessWidget {
  const WizardBoxAnimation({super.key});

  static const _height = 2.6;

  @override
  Widget build(BuildContext context) {
    return LoopingAnimation(
      period: const Duration(milliseconds: 3500),
      staticT: 0.65,
      builder: (context, t) {
        // Drag out over 0.12–0.55, hold, then ease back over 0.72–0.95.
        final e = _phase(t, 0.12, 0.55) - _phase(t, 0.72, 0.95);
        final w = 3.0 + e;
        final d = 2.5 + 0.5 * e;
        final corners = [Offset.zero, Offset(w, 0), Offset(w, d), Offset(0, d)];
        final zoom = 0.95 + 0.2 * e;
        final finger = t < 0.05
            ? t / 0.05
            : (t < 0.72 ? 1.0 : 1 - _phase(t, 0.72, 0.8));
        return Stack(
          fit: StackFit.expand,
          children: [
            IsometricRoomView.polygon(
              floorCornersM: corners,
              heightM: _height,
              showEdgeLengths: false,
              zoom: zoom,
            ),
            CustomPaint(
              painter: _WizardOverlayPainter(
                corners: corners,
                zoom: zoom,
                finger: finger,
                readout: '${_m(w)} × ${_m(d)}',
              ),
            ),
          ],
        );
      },
    );
  }
}

class _WizardOverlayPainter extends CustomPainter {
  _WizardOverlayPainter({
    required this.corners,
    required this.zoom,
    required this.finger,
    required this.readout,
  });

  final List<Offset> corners;
  final double zoom;
  final double finger;
  final String readout;

  @override
  void paint(Canvas canvas, Size size) {
    // Same projector the room view builds, so the finger sits on the corner.
    final proj = IsoProjector(
      floorCornersM: corners,
      heightM: WizardBoxAnimation._height,
      canvasSize: size,
      zoom: zoom,
    );
    final corner = proj.floorScreen(2);
    canvas.drawCircle(corner, 4, Paint()..color = DesignTokens.primaryBlue);
    _paintFinger(canvas, corner + const Offset(6, 8), finger);
    _paintNumber(
      canvas,
      readout,
      Offset(size.width / 2, 12),
      size: 12,
      color: DesignTokens.primaryBlue,
    );
  }

  @override
  bool shouldRepaint(_WizardOverlayPainter old) =>
      old.zoom != zoom || old.finger != finger || old.readout != readout;
}

// ---------------------------------------------------------------------------
// LiDAR: a phone glyph sweeps around a floor plan, walls appear one by one,
// then a 3D box takes the plan's place.
// ---------------------------------------------------------------------------

class LidarScanAnimation extends StatelessWidget {
  const LidarScanAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return LoopingAnimation(
      period: const Duration(milliseconds: 3600),
      staticT: 0.88,
      builder: (context, t) => CustomPaint(painter: _LidarPainter(t)),
    );
  }
}

class _LidarPainter extends CustomPainter {
  _LidarPainter(this.t);

  final double t;

  static const _w = 4.0, _d = 3.0, _h = 2.6;

  @override
  void paint(Canvas canvas, Size size) {
    final out = 1 - _phase(t, 0.93, 1.0);
    final boxIn = _phase(t, 0.66, 0.8);
    final c = size.center(Offset.zero);
    final planH = size.height * 0.5;
    final plan = Rect.fromCenter(
      center: c,
      width: planH * _w / _d,
      height: planH,
    );

    // Floor plan: walls appear one by one while the phone sweeps.
    final planAlpha = (1 - boxIn) * out;
    final walls = [
      (plan.topLeft, plan.topRight),
      (plan.topRight, plan.bottomRight),
      (plan.bottomRight, plan.bottomLeft),
      (plan.bottomLeft, plan.topLeft),
    ];
    canvas.drawRect(
      plan,
      Paint()
        ..color = DesignTokens.primaryBlue.withValues(alpha: 0.05 * planAlpha),
    );
    for (var i = 0; i < 4; i++) {
      final g = _phase(t, 0.08 + i * 0.13, 0.2 + i * 0.13);
      if (g == 0) continue;
      final (a, b) = walls[i];
      canvas.drawLine(
        a,
        Offset.lerp(a, b, g)!,
        Paint()
          ..color = DesignTokens.primaryBlue.withValues(alpha: planAlpha)
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
    }

    // Phone glyph orbiting the plan, its beam on the plan's centre.
    final sweep = _phase(t, 0.04, 0.66);
    if (planAlpha > 0 && t < 0.72) {
      final ang = -math.pi / 2 + sweep * 2 * math.pi;
      final r = Offset(plan.width * 0.5 + 26, plan.height * 0.5 + 12);
      final p = c + Offset(math.cos(ang) * r.dx, math.sin(ang) * r.dy);
      final dir = (c - p) / (c - p).distance;
      final normal = Offset(-dir.dy, dir.dx);
      canvas.drawPath(
        Path()
          ..moveTo(p.dx, p.dy)
          ..lineTo(
            (p + dir * 34 + normal * 16).dx,
            (p + dir * 34 + normal * 16).dy,
          )
          ..lineTo(
            (p + dir * 34 - normal * 16).dx,
            (p + dir * 34 - normal * 16).dy,
          )
          ..close(),
        Paint()
          ..color = DesignTokens.primaryBlue.withValues(
            alpha: 0.14 * planAlpha,
          ),
      );
      canvas.save();
      canvas.translate(p.dx, p.dy);
      canvas.rotate(ang + math.pi / 2);
      final body = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 14, height: 24),
        const Radius.circular(3),
      );
      canvas.drawRRect(
        body,
        Paint()..color = DesignTokens.textGray.withValues(alpha: planAlpha),
      );
      canvas.drawRRect(
        body.deflate(2),
        Paint()..color = DesignTokens.white.withValues(alpha: planAlpha),
      );
      canvas.restore();
    }

    // 3D box at the end.
    if (boxIn > 0) {
      final alpha = boxIn * out;
      final proj = IsoProjector(
        floorCornersM: const [
          Offset.zero,
          Offset(_w, 0),
          Offset(_w, _d),
          Offset(0, _d),
        ],
        heightM: _h,
        canvasSize: size,
        padPx: 14,
        zoom: 0.9 + 0.1 * boxIn,
      );
      final floor = proj.floorScreenAll;
      final top = proj.topScreenAll;
      canvas.drawPath(
        Path()..addPolygon(floor, true),
        Paint()
          ..color = DesignTokens.primaryBlue.withValues(alpha: 0.08 * alpha),
      );
      for (var i = 0; i < 4; i++) {
        final quad = [floor[i], floor[(i + 1) % 4], top[(i + 1) % 4], top[i]];
        final path = Path()..addPolygon(quad, true);
        canvas.drawPath(
          path,
          Paint()
            ..color = DesignTokens.primaryBlue.withValues(alpha: 0.12 * alpha),
        );
        canvas.drawPath(
          path,
          Paint()
            ..color = DesignTokens.primaryBlue.withValues(alpha: 0.7 * alpha)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_LidarPainter old) => old.t != t;
}

// ---------------------------------------------------------------------------
// Draw it yourself: a finger traces a room outline on an empty canvas; the
// outline closes and the sides get their metre numbers.
// ---------------------------------------------------------------------------

class DrawRoomAnimation extends StatelessWidget {
  const DrawRoomAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return LoopingAnimation(
      period: const Duration(milliseconds: 3400),
      staticT: 0.8,
      builder: (context, t) => CustomPaint(painter: _DrawPainter(t)),
    );
  }
}

class _DrawPainter extends CustomPainter {
  _DrawPainter(this.t);

  final double t;

  /// The room being drawn, metres.
  static const _room = [
    Offset(0, 0),
    Offset(4.0, 0),
    Offset(4.0, 3.0),
    Offset(0, 3.0),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    // Dot grid: the empty canvas.
    final dot = Paint()..color = DesignTokens.textMuted.withValues(alpha: 0.18);
    for (var x = 8.0; x < size.width; x += 16) {
      for (var y = 8.0; y < size.height; y += 16) {
        canvas.drawCircle(Offset(x, y), 1, dot);
      }
    }

    final out = 1 - _phase(t, 0.92, 1.0);
    final scale = (size.height - 44) / 3.0;
    final origin = Offset((size.width - 4.0 * scale) / 2, 20);
    final pts = [for (final p in _room) origin + p * scale];
    final segs = [
      for (var i = 0; i < pts.length; i++) (pts[i], pts[(i + 1) % pts.length]),
    ];
    final total = segs.fold<double>(0, (s, e) => s + (e.$2 - e.$1).distance);

    // Trace the outline up to `drawn` px along it.
    final drawn = total * _phase(t, 0.05, 0.6);
    final path = Path()..moveTo(pts[0].dx, pts[0].dy);
    var left = drawn;
    var tip = pts[0];
    for (final (a, b) in segs) {
      final len = (b - a).distance;
      if (left <= 0) break;
      final f = math.min(1.0, left / len);
      tip = Offset.lerp(a, b, f)!;
      path.lineTo(tip.dx, tip.dy);
      left -= len;
    }
    final closed = _phase(t, 0.6, 0.7);
    if (closed > 0) {
      canvas.drawPath(
        Path()..addPolygon(pts, true),
        Paint()
          ..color = DesignTokens.successGreen.withValues(
            alpha: 0.12 * closed * out,
          ),
      );
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = DesignTokens.successGreen.withValues(alpha: out)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawCircle(
      pts[0],
      3.5,
      Paint()..color = DesignTokens.successGreen.withValues(alpha: out),
    );

    // Side lengths once the outline closes, set just outside each side.
    final outline = Path()..addPolygon(pts, true);
    final numbers = _phase(t, 0.65, 0.78) * out;
    for (var i = 0; i < segs.length; i++) {
      final (a, b) = segs[i];
      final mid = (a + b) / 2;
      final dir = (b - a) / (b - a).distance;
      var outward = Offset(dir.dy, -dir.dx);
      if (outline.contains(mid + outward * 4)) outward = -outward;
      final metres = (_room[(i + 1) % _room.length] - _room[i]).distance;
      // Vertical sides need room for the label's width, horizontal ones
      // only for its height.
      final gap = dir.dx.abs() < 0.5 ? 22.0 : 11.0;
      _paintNumber(canvas, _m(metres), mid + outward * gap, alpha: numbers);
    }

    // The finger, while drawing.
    final finger = t < 0.62
        ? math.min(1.0, t / 0.05)
        : 1 - _phase(t, 0.62, 0.7);
    _paintFinger(canvas, tip + const Offset(5, 7), finger * out);
  }

  @override
  bool shouldRepaint(_DrawPainter old) => old.t != t;
}
