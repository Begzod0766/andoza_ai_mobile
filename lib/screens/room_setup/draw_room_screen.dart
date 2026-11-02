import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/design_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../geometry/geometry_config.dart';
import '../../geometry/room_geometry.dart';
import '../../models/room_plan.dart';
import '../../services/room_plan_handoff.dart';
import '../../widgets/room/iso_projector.dart';
import '../../widgets/room/isometric_room_view.dart';
import '../../widgets/common/unsaved_changes_guard.dart';

/// How the room outline is created.
enum _DrawMode { freehand, polygon }

/// Which axis a Vizual (isometric) corner-handle drag is locked to.
enum _DragAxis { none, floor, height }

/// "O'zingiz chizing" — sketch a room outline (any N-corner shape) with live
/// per-wall measurements, in two modes: freehand tracing (auto-straightened via
/// the geometry module) or tap-to-place polygon. Corners are draggable to
/// resize/reshape. All state is kept in METRES; the [RoomPlan] it produces is
/// handed off via [handoffRoomPlan].
class DrawRoomScreen extends ConsumerStatefulWidget {
  const DrawRoomScreen({super.key});

  @override
  ConsumerState<DrawRoomScreen> createState() => _DrawRoomScreenState();
}

class _DrawRoomScreenState extends ConsumerState<DrawRoomScreen>
    with TickerProviderStateMixin {
  /// Logical pixels per metre for the top-down canvas.
  static const double _ppm = 30.0;
  static const double _grabRadiusPx = 24.0;
  static const List<double> _heightPresets = [2.5, 2.7, 2.8, 3.0, 3.2];

  _DrawMode _mode = _DrawMode.polygon;

  /// Authoritative room corners, in METRES.
  List<Vec2> _corners = [];
  bool _closed = false;
  int? _dragIndex;
  double _height = GeometryConfig.defaultHeightM;
  bool _saving = false;

  // Freehand
  bool _freehandDrawing = false;
  List<Vec2> _rawStrokeM = [];
  List<Vec2>? _rawCornersM; // before regularization (for the toggle)
  List<Vec2>? _regularizedM; // after regularization
  bool _showRaw = false;

  // Regularization animation (raw → clean)
  // No per-tick setState: the regularization morph repaints only the 2D
  // CustomPaint, scoped via an AnimatedBuilder in [_build2dCanvas].
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );
  List<Vec2>? _animFrom;
  List<Vec2>? _animTo;

  // Rejection "shake" when a drag would self-intersect the polygon.
  // No per-tick setState: the shake only translates the editor subtree,
  // scoped via an AnimatedBuilder around it in [build].
  late final AnimationController _shakeCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );

  // Undo / redo history (snapshots of corners + closed).
  final List<({List<Vec2> corners, bool closed})> _undoStack = [];
  final List<({List<Vec2> corners, bool closed})> _redoStack = [];

  // --- Vizual (isometric 3D) editing ---------------------------------------
  /// Orbit angle of the isometric view (radians).
  double _orbit = 0;

  /// Pinch-zoom multiplier of the isometric view (1.0 = auto-fit).
  double _zoom = 1.0;

  /// Zoom captured at the start of a two-finger gesture, for relative pinch.
  double _zoomStart = 1.0;

  static const double _minZoom = 0.5;
  static const double _maxZoom = 3.0;

  /// Highlighted floor corner (the one being dragged), or null.
  int? _activeCorner;

  /// Full-drag horizontal travel ≈ half a turn of orbit.
  static const double _orbitPerPx = 0.01;

  /// Radius (px) to grab an isometric corner handle at drag start.
  static const double _isoGrabPx = 28.0;

  /// Last measured size of the isometric canvas (set by its LayoutBuilder).
  Size _isoSize = Size.zero;

  // Iso corner-drag bookkeeping (captured at drag start, held until release).
  IsoProjector? _dragProj;
  int? _dragCorner;
  Vec2? _dragStartCornerM;
  double _dragStartHeight = 0;
  Offset _dragStartFocal = Offset.zero;
  _DragAxis _dragAxis = _DragAxis.none;

  @override
  void initState() {
    super.initState();
    // Default mode is Vizual — seed a box so it is immediately editable.
    if (_mode == _DrawMode.polygon && (_corners.isEmpty || !_closed)) {
      _corners = _defaultBox();
      _closed = true;
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  /// A decaying horizontal shake offset (px) for the reject animation.
  double get _shakeDx => _shakeCtrl.isAnimating
      ? math.sin(_shakeCtrl.value * math.pi * 4) *
          8 *
          (1 - _shakeCtrl.value)
      : 0;

  void _triggerShake() {
    HapticFeedback.mediumImpact();
    _shakeCtrl.forward(from: 0);
  }

  /// Whether moving corner [i] to [moved] would make the polygon self-cross.
  bool _wouldSelfIntersect(int i, Vec2 moved) {
    final cand = List.of(_corners);
    cand[i] = moved;
    return isSelfIntersecting(cand);
  }

  /// Axis-aligned 4.0 × 3.0 m seed rectangle for the Vizual tab.
  List<Vec2> _defaultBox() => [
        const Vec2(0, 0),
        const Vec2(4.0, 0),
        const Vec2(4.0, 3.0),
        const Vec2(0, 3.0),
      ];

  // --- coordinate transform -------------------------------------------------

  Offset _toScreen(Vec2 w) => Offset(w.x * _ppm, w.y * _ppm);
  Vec2 _toWorld(Offset s) => Vec2(s.dx / _ppm, s.dy / _ppm);
  Vec2 _snap(Vec2 w) => Vec2(
        roundTo(w.x, GeometryConfig.wallLengthStepM),
        roundTo(w.y, GeometryConfig.wallLengthStepM),
      );

  /// Corners currently displayed (lerped mid-animation).
  List<Vec2> get _display {
    if (_anim.isAnimating &&
        _animFrom != null &&
        _animTo != null &&
        _animFrom!.length == _animTo!.length) {
      final t = Curves.easeOut.transform(_anim.value);
      return [
        for (var i = 0; i < _animTo!.length; i++)
          _animFrom![i] + (_animTo![i] - _animFrom![i]) * t,
      ];
    }
    return _corners;
  }

  RoomPlan get _plan => RoomPlan.fromCorners(
        _corners,
        ceilingHeightM: _height,
        source: _mode == _DrawMode.freehand
            ? RoomSource.sketch
            : RoomSource.drag,
      );

  int? _cornerAt(Offset screen) {
    for (var i = 0; i < _corners.length; i++) {
      if ((_toScreen(_corners[i]) - screen).distance <= _grabRadiusPx) return i;
    }
    return null;
  }

  // --- gestures -------------------------------------------------------------

  void _onTapUp(TapUpDetails d) {
    // Once closed, tapping a wall-length label edits that wall numerically.
    if (_closed) {
      final e = _edgeLabelAt(d.localPosition);
      if (e != null) _editWallLength(e);
      return;
    }
    if (_mode != _DrawMode.polygon) return;
    _pushUndo();
    setState(() {
      if (_corners.length >= 3 &&
          (_toScreen(_corners.first) - d.localPosition).distance <=
              _grabRadiusPx) {
        _closed = true;
      } else {
        _corners.add(_snap(_toWorld(d.localPosition)));
      }
    });
  }

  void _onPanStart(DragStartDetails d) {
    final pos = d.localPosition;
    if (_closed) {
      final v = _cornerAt(pos);
      if (v != null) {
        _pushUndo();
        setState(() => _dragIndex = v);
      }
      return;
    }
    if (_mode == _DrawMode.freehand) {
      _pushUndo();
      setState(() {
        _freehandDrawing = true;
        _rawStrokeM = [_toWorld(pos)];
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_dragIndex != null) {
      final moved = _snap(_toWorld(d.localPosition));
      if (_wouldSelfIntersect(_dragIndex!, moved)) {
        _triggerShake();
        return;
      }
      setState(() => _corners[_dragIndex!] = moved);
    } else if (_freehandDrawing) {
      setState(() => _rawStrokeM.add(_toWorld(d.localPosition)));
    }
  }

  void _onPanEnd(DragEndDetails d) {
    if (_freehandDrawing) {
      final raw = mergeCloseVertices(rdpSimplify(resample(_rawStrokeM)));
      setState(() {
        _freehandDrawing = false;
        _rawStrokeM = [];
        if (raw.length >= 3) {
          final reg = regularize(raw);
          _rawCornersM = raw;
          _regularizedM = reg;
          _corners = reg;
          _closed = true;
          _showRaw = false;
          _animFrom = raw;
          _animTo = reg;
          _anim.forward(from: 0);
        }
      });
    }
    setState(() => _dragIndex = null);
  }

  void _closeShape() {
    if (_corners.length >= 3 && !_closed) {
      _pushUndo();
      setState(() => _closed = true);
    }
  }

  // --- undo / redo ----------------------------------------------------------

  void _pushUndo() {
    _undoStack.add((corners: List.of(_corners), closed: _closed));
    if (_undoStack.length > 60) _undoStack.removeAt(0);
    _redoStack.clear();
  }

  void _undo() {
    if (_undoStack.isEmpty) return;
    setState(() {
      _redoStack.add((corners: List.of(_corners), closed: _closed));
      final s = _undoStack.removeLast();
      _corners = List.of(s.corners);
      _closed = s.closed;
      _dragIndex = null;
    });
  }

  void _redo() {
    if (_redoStack.isEmpty) return;
    setState(() {
      _undoStack.add((corners: List.of(_corners), closed: _closed));
      final s = _redoStack.removeLast();
      _corners = List.of(s.corners);
      _closed = s.closed;
    });
  }

  // --- numeric + long-press editing ----------------------------------------

  /// Index of the wall whose length-label is under [pos], or null.
  int? _edgeLabelAt(Offset pos) {
    final n = _corners.length;
    if (!_closed || n < 3) return null;
    for (var i = 0; i < n; i++) {
      final a = _toScreen(_corners[i]);
      final b = _toScreen(_corners[(i + 1) % n]);
      final mid = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
      if ((mid - pos).distance <= 30) return i;
    }
    return null;
  }

  /// Prompt for an exact wall length; moves the wall's far endpoint along the
  /// wall direction to match.
  Future<void> _editWallLength(int i) async {
    final n = _corners.length;
    final a = _corners[i];
    final b = _corners[(i + 1) % n];
    final ctrl =
        TextEditingController(text: a.distanceTo(b).toStringAsFixed(2));
    final l10n = AppLocalizations.of(context)!;
    final value = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.drawWallLength),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(suffixText: 'm'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.actionCancelShort)),
          FilledButton(
            onPressed: () => Navigator.pop(
                ctx, double.tryParse(ctrl.text.replaceAll(',', '.'))),
            child: Text(l10n.actionOk),
          ),
        ],
      ),
    );
    if (value == null || value < GeometryConfig.minWallM) return;
    _pushUndo();
    setState(() {
      final dir = (b - a).normalized;
      _corners[(i + 1) % n] = a + dir * value;
    });
  }

  void _onLongPressStart(LongPressStartDetails d) {
    final pos = d.localPosition;
    final v = _cornerAt(pos);
    if (v != null) {
      // Delete a corner (keep at least a triangle).
      if (_corners.length > 3) {
        _pushUndo();
        setState(() => _corners.removeAt(v));
      }
      return;
    }
    if (_closed) {
      // Add a corner on the nearest wall.
      final e = _nearestEdge(pos);
      if (e != null) {
        _pushUndo();
        setState(() =>
            _corners.insert(e.index + 1, _snap(_toWorld(e.point))));
      }
    }
  }

  ({int index, Offset point})? _nearestEdge(Offset pos) {
    final n = _corners.length;
    if (n < 3) return null;
    var best = 24.0;
    int? bi;
    var bp = pos;
    for (var i = 0; i < n; i++) {
      final a = _toScreen(_corners[i]);
      final b = _toScreen(_corners[(i + 1) % n]);
      final proj = _projectToSegment(pos, a, b);
      final dist = (proj - pos).distance;
      if (dist < best) {
        best = dist;
        bi = i;
        bp = proj;
      }
    }
    return bi == null ? null : (index: bi, point: bp);
  }

  Offset _projectToSegment(Offset p, Offset a, Offset b) {
    final ab = b - a;
    final len2 = ab.dx * ab.dx + ab.dy * ab.dy;
    if (len2 == 0) return a;
    var t = ((p.dx - a.dx) * ab.dx + (p.dy - a.dy) * ab.dy) / len2;
    t = t.clamp(0.0, 1.0);
    return Offset(a.dx + ab.dx * t, a.dy + ab.dy * t);
  }

  void _toggleRawAfter() {
    if (_rawCornersM == null || _regularizedM == null) return;
    setState(() {
      _showRaw = !_showRaw;
      _corners = _showRaw ? List.of(_rawCornersM!) : List.of(_regularizedM!);
      _anim.stop();
    });
  }

  void _clear() {
    if (_corners.isNotEmpty || _closed) _pushUndo();
    setState(() {
      _dragIndex = null;
      _dragCorner = null;
      _activeCorner = null;
      _orbit = 0;
      _zoom = 1.0;
      _rawCornersM = null;
      _regularizedM = null;
      _anim.stop();
      // Vizual always needs an editable box (there is no tap-to-place there);
      // Qo'lda clears to an empty drawing surface as before.
      if (_mode == _DrawMode.polygon) {
        _corners = _defaultBox();
        _closed = true;
      } else {
        _corners = [];
        _closed = false;
      }
    });
  }

  void _switchMode(_DrawMode m) {
    if (m == _mode) return;
    setState(() {
      _mode = m;
      _orbit = 0;
      _zoom = 1.0;
      _activeCorner = null;
      _dragCorner = null;
      _dragIndex = null;
    });
    if (m == _DrawMode.freehand) {
      // Qo'lda starts from a clean surface (original behaviour).
      _clear();
    } else if (_corners.isEmpty || !_closed) {
      // Vizual: keep any shape drawn in Qo'lda, else seed a default box.
      _pushUndo();
      setState(() {
        _corners = _defaultBox();
        _closed = true;
      });
    }
  }

  // --- Vizual (isometric) gestures -----------------------------------------

  /// Build a projector for the current shape/height/orbit against the last
  /// known iso canvas size, or null if the shape is not renderable.
  IsoProjector? _buildProjector() {
    if (_corners.length < 3 || _isoSize.isEmpty) return null;
    return IsoProjector(
      floorCornersM: [for (final c in _corners) Offset(c.x, c.y)],
      heightM: _height,
      canvasSize: _isoSize,
      orbitRad: _orbit,
      zoom: _zoom,
    );
  }

  /// Nearest corner handle within [_isoGrabPx] of [p], or null.
  int? _handleAt(Offset p, IsoProjector proj) {
    int? best;
    var bestD = _isoGrabPx;
    for (var i = 0; i < proj.cornerCount; i++) {
      final d = (proj.floorScreen(i) - p).distance;
      if (d <= bestD) {
        bestD = d;
        best = i;
      }
    }
    return best;
  }

  void _onIsoScaleStart(ScaleStartDetails d) {
    _dragAxis = _DragAxis.none;
    // Two fingers = orbit + pinch-zoom; capture the zoom baseline so the
    // gesture's d.scale (relative to its own start) applies on top of it.
    if (d.pointerCount >= 2) {
      _zoomStart = _zoom;
      setState(() => _dragCorner = null);
      return;
    }
    final proj = _buildProjector();
    final i = proj == null ? null : _handleAt(d.localFocalPoint, proj);
    if (i == null) {
      setState(() => _dragCorner = null);
      return;
    }
    _pushUndo();
    setState(() {
      _dragCorner = i;
      _dragProj = proj;
      _dragStartCornerM = _corners[i];
      _dragStartHeight = _height;
      _dragStartFocal = d.localFocalPoint;
      _activeCorner = i;
    });
  }

  void _onIsoScaleUpdate(ScaleUpdateDetails d) {
    // Two-finger gesture: horizontal drag orbits, pinch zooms (about centre).
    if (d.pointerCount >= 2) {
      setState(() {
        _orbit += d.focalPointDelta.dx * _orbitPerPx;
        _zoom = (_zoomStart * d.scale).clamp(_minZoom, _maxZoom);
      });
      return;
    }
    if (_dragCorner == null || _dragProj == null) return;
    final screenDelta = d.localFocalPoint - _dragStartFocal;
    // Decide + lock the axis from the initial movement.
    if (_dragAxis == _DragAxis.none) {
      if (screenDelta.distance < 6) return;
      _dragAxis = screenDelta.dx.abs() >= screenDelta.dy.abs()
          ? _DragAxis.floor
          : _DragAxis.height;
    }
    if (_dragAxis == _DragAxis.floor) {
      _dragFloor(screenDelta);
    } else {
      _dragHeight(screenDelta);
    }
  }

  /// Horizontal-locked drag: move the corner in the floor plane.
  void _dragFloor(Offset screenDelta) {
    final i = _dragCorner!;
    final dM = _dragProj!.floorDeltaFromScreen(screenDelta);
    final moved = _snap(_dragStartCornerM! + Vec2(dM.dx, dM.dy));
    final n = _corners.length;
    final prev = _corners[(i - 1 + n) % n];
    final next = _corners[(i + 1) % n];
    // Reject any move that would shrink an adjacent wall below the minimum.
    if (moved.distanceTo(prev) < GeometryConfig.minWallM ||
        moved.distanceTo(next) < GeometryConfig.minWallM) {
      return;
    }
    if (_wouldSelfIntersect(i, moved)) {
      _triggerShake();
      return;
    }
    if (_corners[i] == moved) return; // sub-5cm jitter, no step
    setState(() => _corners[i] = moved);
    HapticFeedback.selectionClick();
  }

  /// Vertical-locked drag: change the ceiling height.
  void _dragHeight(Offset screenDelta) {
    final mpp = _dragProj!.heightMetrePerScreenY;
    final raw = _dragStartHeight + (-screenDelta.dy) * mpp;
    final h = roundTo(raw, GeometryConfig.wallLengthStepM)
        .clamp(GeometryConfig.minHeightM, GeometryConfig.maxHeightM)
        .toDouble();
    if ((h - _height).abs() < 1e-9) return; // no 5cm step crossed
    setState(() => _height = h);
    HapticFeedback.selectionClick();
  }

  void _onIsoScaleEnd(ScaleEndDetails d) {
    setState(() {
      _dragCorner = null;
      _dragProj = null;
      _dragAxis = _DragAxis.none;
      _activeCorner = null;
    });
  }

  /// Single-tap near an edge midpoint edits that wall's length numerically.
  void _onIsoTapUp(TapUpDetails d) {
    final proj = _buildProjector();
    if (proj == null) return;
    final n = proj.cornerCount;
    for (var i = 0; i < n; i++) {
      final mid = (proj.floorScreen(i) + proj.floorScreen((i + 1) % n)) / 2;
      if ((mid - d.localPosition).distance <= 30) {
        _editWallLength(i);
        return;
      }
    }
  }

  Widget _isoHandle(bool active) {
    return IgnorePointer(
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? DesignTokens.accentOrange : DesignTokens.primaryBlue,
          border: Border.all(color: DesignTokens.white, width: 2.5),
          boxShadow: const [DesignTokens.shadowCard],
        ),
      ),
    );
  }

  Widget _buildIsoEditor() {
    return LayoutBuilder(
      builder: (context, constraints) {
        _isoSize = constraints.biggest;
        final floorM = [for (final c in _corners) Offset(c.x, c.y)];
        final proj = (_corners.length >= 3 && !_isoSize.isEmpty)
            ? IsoProjector(
                floorCornersM: floorM,
                heightM: _height,
                canvasSize: _isoSize,
                orbitRad: _orbit,
                zoom: _zoom,
              )
            : null;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onScaleStart: _onIsoScaleStart,
          onScaleUpdate: _onIsoScaleUpdate,
          onScaleEnd: _onIsoScaleEnd,
          onDoubleTap: () => setState(() {
            _orbit = 0;
            _zoom = 1.0;
          }),
          onTapUp: _onIsoTapUp,
          child: Container(
            width: double.infinity,
            color: DesignTokens.white,
            child: Stack(
              children: [
                Positioned.fill(
                  child: IsometricRoomView.polygon(
                    floorCornersM: floorM,
                    heightM: _height,
                    orbitRad: _orbit,
                    activeCorner: _activeCorner,
                    zoom: _zoom,
                  ),
                ),
                if (proj != null)
                  for (var i = 0; i < _corners.length; i++)
                    Positioned(
                      left: proj.floorScreen(i).dx - 11,
                      top: proj.floorScreen(i).dy - 11,
                      child: _isoHandle(i == _activeCorner),
                    ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _build2dCanvas() {
    return GestureDetector(
      onTapUp: _onTapUp,
      onLongPressStart: _onLongPressStart,
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Container(
        width: double.infinity,
        color: DesignTokens.white,
        // Repaint only this CustomPaint while the raw→clean morph animates,
        // instead of rebuilding the whole screen every frame. [_display],
        // the wall-length labels and the area readout all derive from
        // _anim.value, so they are recomputed inside the builder.
        child: AnimatedBuilder(
          animation: _anim,
          builder: (context, _) {
            final display = _display;
            return CustomPaint(
              painter: _RoomPainter(
                corners: [for (final c in display) _toScreen(c)],
                closed: _closed,
                rawStroke: _freehandDrawing
                    ? [for (final p in _rawStrokeM) _toScreen(p)]
                    : const [],
                ppm: _ppm,
                wallLengths: _wallLengths(display, _closed),
                areaM2: _closed ? shoelaceArea(display) : 0,
              ),
            );
          },
        ),
      ),
    );
  }

  // --- build ----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final plan = _plan;
    return UnsavedChangesGuard(
      // Any edit leaves an undo step; finishing leaves via context.go.
      hasChanges: _undoStack.isNotEmpty,
      child: Scaffold(
      backgroundColor: DesignTokens.backgroundLight,
      appBar: AppBar(
        backgroundColor: DesignTokens.backgroundLight,
        elevation: 0,
        title: Text(l10n.drawTitle, style: DesignTokens.heading3),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spacingMd,
              vertical: DesignTokens.spacingSm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _ModeChip(
                    icon: Icons.gesture,
                    label: l10n.drawModeManual,
                    selected: _mode == _DrawMode.freehand,
                    onTap: () => _switchMode(_DrawMode.freehand),
                  ),
                ),
                const SizedBox(width: DesignTokens.spacingSm),
                Expanded(
                  child: _ModeChip(
                    icon: Icons.timeline,
                    label: l10n.drawModeVisual,
                    selected: _mode == _DrawMode.polygon,
                    onTap: () => _switchMode(_DrawMode.polygon),
                  ),
                ),
              ],
            ),
          ),
          _HintBar(
            text: _hint,
            canClose:
                _mode == _DrawMode.polygon && !_closed && _corners.length >= 3,
            onClose: _closeShape,
            canToggle: _rawCornersM != null && _closed,
            showRaw: _showRaw,
            onToggle: _toggleRawAfter,
            canUndo: _undoStack.isNotEmpty,
            onUndo: _undo,
            canRedo: _redoStack.isNotEmpty,
            onRedo: _redo,
            onClear: _clear,
          ),
          Expanded(
            // Scope the reject "shake" repaint to just the editor subtree:
            // only the Transform.translate re-runs per frame, not the whole
            // screen. The editor itself is built once and passed as `child`.
            child: AnimatedBuilder(
              animation: _shakeCtrl,
              child: _mode == _DrawMode.polygon
                  ? _buildIsoEditor()
                  : _build2dCanvas(),
              builder: (context, child) => Transform.translate(
                offset: Offset(_shakeDx, 0),
                child: child,
              ),
            ),
          ),
          _BottomPanel(
            plan: plan,
            height: _height,
            heightPresets: _heightPresets,
            saving: _saving,
            onHeight: (h) => setState(() => _height = h),
            onFinish:
                plan.isValid && !_saving && _closed ? _finish : null,
          ),
        ],
      ),
    ));
  }

  List<double> _wallLengths(List<Vec2> pts, bool closed) {
    final n = pts.length;
    if (n < 2) return const [];
    final last = closed ? n : n - 1;
    return [
      for (var i = 0; i < last; i++) pts[i].distanceTo(pts[(i + 1) % n]),
    ];
  }

  String get _hint {
    final l10n = AppLocalizations.of(context)!;
    if (_showRaw) return l10n.drawHintRaw;
    if (_closed) {
      return l10n.drawHintShapeReady;
    }
    if (_mode == _DrawMode.freehand) {
      return l10n.drawHintFreehand;
    }
    if (_corners.isEmpty) return l10n.drawHintMarkCorners;
    if (_corners.length < 3) {
      return l10n.drawHintMorePoints(3 - _corners.length);
    }
    return l10n.drawHintClose;
  }

  Future<void> _finish() async {
    setState(() => _saving = true);
    final plan = _plan;
    final saved = await saveDrawnRoom(
      () => handoffRoomPlan(ref, plan),
      onSaved: (roomId) {
        if (mounted) context.go('/studio/$roomId');
      },
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (!saved) {
      // Keep the drawing: the user retries instead of losing it.
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.roomSaveFailed),
        action: SnackBarAction(label: l10n.actionRetry, onPressed: _finish),
      ));
    }
  }
}

/// Saves the drawn room and hands its id to [onSaved]. False when the save
/// threw or the server gave no room — the caller stays on the drawing then,
/// rather than detouring into the old offline design flow.
Future<bool> saveDrawnRoom(
  Future<String?> Function() save, {
  required void Function(String roomId) onSaved,
}) async {
  try {
    final roomId = await save();
    if (roomId == null) return false;
    onSaved(roomId);
    return true;
  } catch (_) {
    return false;
  }
}

// ---------------------------------------------------------------------------
// Mode chip
// ---------------------------------------------------------------------------

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacingSm),
        decoration: BoxDecoration(
          color: selected ? DesignTokens.primaryBlue : DesignTokens.white,
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          border: Border.all(
            color:
                selected ? DesignTokens.primaryBlue : DesignTokens.borderGray,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 18,
                color: selected ? DesignTokens.white : DesignTokens.textGray),
            const SizedBox(width: DesignTokens.spacingXs),
            Text(
              label,
              style: DesignTokens.subtitle2.copyWith(
                color: selected ? DesignTokens.white : DesignTokens.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hint bar
// ---------------------------------------------------------------------------

class _HintBar extends StatelessWidget {
  const _HintBar({
    required this.text,
    required this.canClose,
    required this.onClose,
    required this.canToggle,
    required this.showRaw,
    required this.onToggle,
    required this.canUndo,
    required this.onUndo,
    required this.canRedo,
    required this.onRedo,
    required this.onClear,
  });

  final String text;
  final bool canClose;
  final VoidCallback onClose;
  final bool canToggle;
  final bool showRaw;
  final VoidCallback onToggle;
  final bool canUndo;
  final VoidCallback onUndo;
  final bool canRedo;
  final VoidCallback onRedo;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DesignTokens.spacingMd,
        0,
        DesignTokens.spacingMd,
        DesignTokens.spacingSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: DesignTokens.caption.copyWith(color: DesignTokens.textGray),
          ),
          Row(
            children: [
              if (canClose)
                FilledButton.icon(
                  onPressed: onClose,
                  icon: const Icon(Icons.check, size: 16),
                  label: Text(l10n.actionClose),
                  style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact),
                ),
              if (canToggle)
                OutlinedButton.icon(
                  onPressed: onToggle,
                  icon: const Icon(Icons.compare_arrows, size: 16),
                  label: Text(showRaw ? l10n.drawToggleClean : l10n.drawToggleRaw),
                  style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact),
                ),
              const Spacer(),
              IconButton(
                onPressed: canUndo ? onUndo : null,
                icon: const Icon(Icons.undo, size: 20),
                tooltip: l10n.actionBack,
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                onPressed: canRedo ? onRedo : null,
                icon: const Icon(Icons.redo, size: 20),
                tooltip: l10n.drawRedo,
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                onPressed: onClear,
                icon: const Icon(Icons.delete_outline, size: 20),
                tooltip: l10n.drawClear,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Painter
// ---------------------------------------------------------------------------

class _RoomPainter extends CustomPainter {
  _RoomPainter({
    required this.corners,
    required this.closed,
    required this.rawStroke,
    required this.ppm,
    required this.wallLengths,
    required this.areaM2,
  });

  final List<Offset> corners;
  final bool closed;
  final List<Offset> rawStroke;
  final double ppm;
  final List<double> wallLengths;
  final double areaM2;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = const Color(0xFFEDEFF3)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += ppm) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += ppm) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    if (rawStroke.length > 1) {
      final p = Path()..moveTo(rawStroke.first.dx, rawStroke.first.dy);
      for (final o in rawStroke.skip(1)) {
        p.lineTo(o.dx, o.dy);
      }
      canvas.drawPath(
        p,
        Paint()
          ..color = DesignTokens.primaryBlue
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
    }

    if (corners.isEmpty) return;

    final line = Paint()
      ..color = DesignTokens.primaryBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round;

    if (closed && corners.length >= 3) {
      final fill = Path()..moveTo(corners.first.dx, corners.first.dy);
      for (final o in corners.skip(1)) {
        fill.lineTo(o.dx, o.dy);
      }
      fill.close();
      canvas.drawPath(
          fill, Paint()..color = DesignTokens.primaryBlue.withValues(alpha: 0.10));
      canvas.drawPath(fill, line);
    } else {
      final p = Path()..moveTo(corners.first.dx, corners.first.dy);
      for (final o in corners.skip(1)) {
        p.lineTo(o.dx, o.dy);
      }
      canvas.drawPath(p, line);
    }

    final n = corners.length;
    final edges = closed ? n : n - 1;
    for (var i = 0; i < edges && i < wallLengths.length; i++) {
      final a = corners[i], b = corners[(i + 1) % n];
      _label(canvas, formatLength(wallLengths[i]),
          Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2));
    }
    if (closed && areaM2 > 0) {
      var cx = 0.0, cy = 0.0;
      for (final o in corners) {
        cx += o.dx;
        cy += o.dy;
      }
      _label(canvas, '${areaM2.toStringAsFixed(1)} m²',
          Offset(cx / n, cy / n),
          muted: true);
    }

    for (final o in corners) {
      canvas.drawCircle(o, 6, Paint()..color = DesignTokens.primaryBlue);
      canvas.drawCircle(
          o,
          6,
          Paint()
            ..color = DesignTokens.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);
    }
  }

  void _label(Canvas canvas, String text, Offset at, {bool muted = false}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: muted ? DesignTokens.textGray : DesignTokens.primaryBlue,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = at.dx - tp.width / 2;
    final dy = at.dy - tp.height / 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(dx - 4, dy - 2, tp.width + 8, tp.height + 4),
          const Radius.circular(6)),
      Paint()..color = DesignTokens.white.withValues(alpha: 0.9),
    );
    tp.paint(canvas, Offset(dx, dy));
  }

  @override
  bool shouldRepaint(_RoomPainter old) =>
      old.corners != corners ||
      old.closed != closed ||
      old.rawStroke != rawStroke;
}

// ---------------------------------------------------------------------------
// Bottom panel
// ---------------------------------------------------------------------------

class _BottomPanel extends StatelessWidget {
  const _BottomPanel({
    required this.plan,
    required this.height,
    required this.heightPresets,
    required this.saving,
    required this.onHeight,
    required this.onFinish,
  });

  final RoomPlan plan;
  final double height;
  final List<double> heightPresets;
  final bool saving;
  final ValueChanged<double> onHeight;
  final VoidCallback? onFinish;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final b = plan.boundingSize;
    final rect = plan.isRectangleLike;
    final title = rect
        ? l10n.drawTitleRect(
            b.width.toStringAsFixed(1),
            b.length.toStringAsFixed(1),
            height.toStringAsFixed(1),
          )
        : l10n.drawTitlePolygon(
            plan.corners.length,
            b.width.toStringAsFixed(1),
            b.length.toStringAsFixed(1),
          );
    final area = plan.corners.length >= 3 ? plan.areaM2 : 0.0;
    final reason = plan.invalidReason;
    final areaWarn = area > 0 &&
        (area < GeometryConfig.minAreaWarnM2 ||
            area > GeometryConfig.maxAreaWarnM2);

    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacingMd),
      decoration: const BoxDecoration(
          color: DesignTokens.white,
          boxShadow: [DesignTokens.shadowCard]),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: DesignTokens.subtitle1)),
                Text('${area.toStringAsFixed(1)} m²',
                    style: DesignTokens.subtitle2
                        .copyWith(color: DesignTokens.textGray)),
              ],
            ),
            if (areaWarn)
              Text(
                l10n.drawAreaWarning,
                style: DesignTokens.caption
                    .copyWith(color: DesignTokens.accentOrangeStrong),
              ),
            const SizedBox(height: DesignTokens.spacingXs),
            Text(l10n.ceilingHeightLabel,
                style: DesignTokens.caption
                    .copyWith(color: DesignTokens.textGray)),
            const SizedBox(height: DesignTokens.spacingXs),
            Wrap(
              spacing: DesignTokens.spacingSm,
              children: [
                for (final h in heightPresets)
                  ChoiceChip(
                    label: Text('${h.toStringAsFixed(1)} m'),
                    selected: (height - h).abs() < 0.01,
                    onSelected: (_) => onHeight(h),
                    backgroundColor: DesignTokens.backgroundLight,
                    selectedColor: DesignTokens.primaryBlue,
                    labelStyle: DesignTokens.caption.copyWith(
                      color: (height - h).abs() < 0.01
                          ? DesignTokens.white
                          : DesignTokens.textDark,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: DesignTokens.spacingMd),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onFinish,
                child: saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: DesignTokens.white),
                      )
                    : Text(onFinish != null
                        ? l10n.actionFinish
                        : (reason ?? l10n.drawTitle)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
