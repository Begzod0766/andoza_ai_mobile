import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

import '../../config/design_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../features/room_scan/models/captured_room.dart';
import '../../features/room_scan/pending_scan_store.dart';
import '../../features/room_scan/room_scan_converter.dart';
import '../../features/room_scan/room_scan_service.dart';
import '../../geometry/room_geometry.dart';
import '../../models/room_plan.dart';
import '../../services/room_plan_handoff.dart';
import 'scan_openings_editor.dart';
import '../../utils/error_mapper.dart';

/// Nav payload for [RoomScanReviewPage] (passed via go_router `extra`).
class RoomScanReviewArgs {
  final RoomScanDraft draft;

  /// The LiDAR scan payload (mesh + raw RoomPlan JSON) uploaded with the room;
  /// `null` for an Android camera (ARCore) measurement, which has none.
  final ScanResult? scan;
  const RoomScanReviewArgs({required this.draft, required this.scan});
}

const List<double> _ceilingChips = [2.5, 2.7, 2.8, 3.0, 3.2];

/// Review + confirm a LiDAR-scanned room before creating the project: a 2-D
/// top-down preview, an editable ceiling height and per-wall lengths.
/// "Davom etish" persists the room (same handoff as the manual flow),
/// uploads the scan artifacts, then opens the studio.
class RoomScanReviewPage extends ConsumerStatefulWidget {
  const RoomScanReviewPage({required this.args, super.key});

  final RoomScanReviewArgs args;

  @override
  ConsumerState<RoomScanReviewPage> createState() => _RoomScanReviewPageState();
}

class _RoomScanReviewPageState extends ConsumerState<RoomScanReviewPage> {
  static final Logger _logger = Logger();
  late double _ceiling;
  bool _busy = false;

  // The scanned plan, with the user's door/window edits.
  late RoomPlan _plan = widget.args.draft.plan;

  @override
  void initState() {
    super.initState();
    _ceiling = _plan.ceilingHeightM;
  }

  Future<void> _continue() async {
    setState(() => _busy = true);
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    // Rebuild the plan with the (possibly overridden) ceiling height.
    final plan = RoomPlan(
      corners: _plan.corners,
      walls: _plan.walls,
      ceilingHeightM: _ceiling,
      source: _plan.source,
      name: _plan.name,
    );
    try {
      final roomId = await handoffRoomPlan(ref, plan);
      if (roomId == null) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.scanReviewSaveFailed)),
        );
        if (mounted) setState(() => _busy = false);
        return;
      }
      // The room is durably in the backend now — the local safety copy (see
      // PendingScanStore) has done its job and would otherwise keep
      // resurfacing a "resume your scan?" prompt for a scan that's already
      // saved. Best-effort: never let cleanup block getting to the studio.
      try {
        await PendingScanStore.clear();
      } catch (e) {
        _logger.w('pending-scan clear failed (non-fatal): $e');
      }
      // Best-effort: attach the scan artifacts. Becomes functional once the
      // Phase 4 endpoint exists; a failure here must not block the studio since
      // the room itself is already created from the parametric data.
      String? uploadError;
      final scan = widget.args.scan;
      if (scan != null) {
        try {
          await ref.read(roomScanServiceProvider).upload(roomId, scan);
        } catch (e) {
          _logger.w('roomscan artifact upload failed (Phase 4 endpoint?): $e');
          uploadError = mapErrorToMessage(e);
        }
      }
      // Best-effort: give the room a preview of its own shape, so it does not
      // show as a blank card in the project list. Same non-blocking contract as
      // the artifact upload above — the room is already saved either way.
      String? thumbnailError;
      try {
        final png = await renderRoomScanThumbnailPng(
          corners: plan.corners,
          walls: plan.walls,
        );
        await ref.read(roomScanServiceProvider).uploadThumbnail(roomId, png);
      } catch (e) {
        _logger.w('roomscan thumbnail upload failed: $e');
        thumbnailError = mapErrorToMessage(e);
      }
      // Straight after a scan the user wants THAT room, not the flat's earlier
      // scans stacked around it.
      router.pushReplacement('/studio/$roomId?focus=1');
      // Non-blocking: the user is already in the studio; the root
      // ScaffoldMessenger keeps this snackbar visible across the transition so
      // a silently lost mesh is at least noticed.
      if (uploadError != null) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.scanReviewUploadFailed(uploadError))),
        );
      }
      if (thumbnailError != null) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.scanReviewThumbnailFailed(thumbnailError))),
        );
      }
    } catch (e) {
      _logger.e('roomscan continue failed', error: e);
      messenger.showSnackBar(SnackBar(content: Text(mapErrorToMessage(e))));
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final corners = _plan.corners;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.scanReviewTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(DesignTokens.screenPaddingHorizontal),
          children: [
            // "What we detected" summary — lets the user judge the scan (and
            // rescan) before committing, instead of discovering a missed door
            // later in the studio.
            if (widget.args.scan case final scan?)
              ScanDetectionSummary(plan: _plan, room: scan.room),
            // A camera measurement is only as good as ARCore's tracking — say so.
            if (_plan.source == RoomSource.arcore)
              Text(
                l10n.scanReviewArcoreAccuracy,
                style: DesignTokens.body2.copyWith(color: DesignTokens.textGray),
              ),
            const SizedBox(height: DesignTokens.spacingLg),

            // 2-D top-down preview.
            AspectRatio(
              aspectRatio: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FA),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                  border: Border.all(color: DesignTokens.borderGray),
                ),
                child: CustomPaint(
                  painter: RoomScanPainter(
                    corners: corners,
                    walls: _plan.walls,
                  ),
                ),
              ),
            ),
            const SizedBox(height: DesignTokens.spacingLg),

            // Doors and windows: fix what the scan got wrong or missed.
            ScanOpeningsEditor(plan: _plan, onChanged: (p) => setState(() => _plan = p)),
            const SizedBox(height: DesignTokens.spacingLg),

            // Ceiling height override.
            Text(l10n.ceilingHeightLabel, style: DesignTokens.subtitle2),
            const SizedBox(height: DesignTokens.spacingXs),
            Text(l10n.scanReviewDetected(formatLength(_plan.ceilingHeightM)),
                style: DesignTokens.caption.copyWith(color: DesignTokens.textGray)),
            const SizedBox(height: DesignTokens.spacingSm),
            Wrap(
              spacing: DesignTokens.spacingSm,
              children: [
                for (final h in _ceilingChips)
                  ChoiceChip(
                    label: Text(l10n.scanReviewCeilingHeightValue(h.toString())),
                    selected: (_ceiling - h).abs() < 0.001,
                    onSelected: (_) => setState(() => _ceiling = h),
                  ),
              ],
            ),
            const SizedBox(height: DesignTokens.spacingLg),

            // Per-wall lengths.
            Text(l10n.scanReviewWalls(_plan.walls.length),
                style: DesignTokens.subtitle2),
            const SizedBox(height: DesignTokens.spacingXs),
            for (var i = 0; i < _plan.walls.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.scanReviewWall(i + 1), style: DesignTokens.body2),
                    Text(formatLength(_plan.walls[i].lengthM),
                        style: DesignTokens.body2.copyWith(color: DesignTokens.textGray)),
                  ],
                ),
              ),
            const SizedBox(height: DesignTokens.spacingXl),

            // Actions.
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _busy
                        ? null
                        : () => context.pushReplacement('/scanning/roomplan'),
                    child: Text(l10n.scanReviewRescan),
                  ),
                ),
                const SizedBox(width: DesignTokens.spacingMd),
                Expanded(
                  child: FilledButton(
                    onPressed: _busy ? null : _continue,
                    child: _busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.actionContinue),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact "what we detected" summary: counts of
/// walls/doors/windows, a low-confidence warning, and — when RoomPlan
/// reported no doors or no windows — a two-line hint that glass and open
/// doorways are commonly missed and that a closer, slower rescan usually
/// helps. Furniture is out of scope: a LiDAR scan is for the room's own
/// shape, not what's in it (see [RoomScanConverter.toRoomDraft]).
///
/// Counts come from the converted [plan] (i.e. exactly what would be saved),
/// while the confidence flag reads the raw [room], because [RoomOpening]
/// carries no confidence field — the RoomPlan value survives only on the
/// [CapturedRoom] that rides along on the scan result.
class ScanDetectionSummary extends StatelessWidget {
  const ScanDetectionSummary({
    required this.plan,
    required this.room,
    super.key,
  });

  final RoomPlan plan;
  final CapturedRoom room;

  int get _doors => _openings('door');
  int get _windows => _openings('window');

  int _openings(String type) {
    var n = 0;
    for (final w in plan.walls) {
      for (final o in w.openings) {
        if (o.type == type) n++;
      }
    }
    return n;
  }

  /// Walls/doors/windows RoomPlan itself flagged as low-confidence.
  int get _lowConfidence {
    var n = 0;
    for (final s in [
      ...room.walls,
      ...room.doors,
      ...room.windows,
      ...room.openings,
    ]) {
      if (s.confidence == ScanConfidence.low) n++;
    }
    return n;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final low = _lowConfidence;
    final missingOpenings = _doors == 0 || _windows == 0;
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacingMd),
      decoration: BoxDecoration(
        color: DesignTokens.primaryTint,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.scanReviewSummaryTitle, style: DesignTokens.subtitle2),
          const SizedBox(height: DesignTokens.spacingSm),
          Wrap(
            spacing: DesignTokens.spacingSm,
            runSpacing: DesignTokens.spacingXs,
            children: [
              _Count(count: plan.walls.length, label: l10n.scanReviewSummaryWalls),
              _Count(count: _doors, label: l10n.scanReviewSummaryDoors),
              _Count(count: _windows, label: l10n.scanReviewSummaryWindows),
            ],
          ),
          if (low > 0) ...[
            const SizedBox(height: DesignTokens.spacingSm),
            Text(
              l10n.scanReviewSummaryLowConfidence(low),
              style: DesignTokens.caption.copyWith(color: DesignTokens.textGray),
            ),
          ],
          if (missingOpenings) ...[
            const SizedBox(height: DesignTokens.spacingSm),
            Text(
              l10n.scanReviewSummaryNoOpenings,
              style: DesignTokens.caption.copyWith(color: DesignTokens.textDark),
            ),
            Text(
              l10n.scanReviewSummaryRescanHint,
              style: DesignTokens.caption.copyWith(color: DesignTokens.textGray),
            ),
          ],
        ],
      ),
    );
  }
}

/// One "N Label" pill in the detection summary.
class _Count extends StatelessWidget {
  const _Count({required this.count, required this.label});

  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    final zero = count == 0;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacingSm,
        vertical: DesignTokens.spacingXs,
      ),
      decoration: BoxDecoration(
        color: DesignTokens.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
        border: Border.all(
          color: zero ? DesignTokens.warningYellow : DesignTokens.borderGray,
        ),
      ),
      child: Text(
        '$count $label',
        style: DesignTokens.body2.copyWith(
          color: zero ? DesignTokens.textGray : DesignTokens.textDark,
        ),
      ),
    );
  }
}

/// Draws a top-down floor plan of the scanned room: floor polygon, walls and
/// openings (door = green, window = blue). Furniture is deliberately not
/// drawn — a LiDAR scan covers the room's own shape, not what's in it.
class RoomScanPainter extends CustomPainter {
  RoomScanPainter({
    required this.corners,
    required this.walls,
  });

  final List<Vec2> corners;
  final List<RoomWall> walls;

  @override
  void paint(Canvas canvas, Size size) {
    if (corners.length < 3) return;

    // Fit the room (metres) into the canvas with padding, Y-up (north up).
    const pad = 16.0;
    var minX = corners.first.x, maxX = corners.first.x;
    var minY = corners.first.y, maxY = corners.first.y;
    for (final c in corners) {
      minX = math.min(minX, c.x);
      maxX = math.max(maxX, c.x);
      minY = math.min(minY, c.y);
      maxY = math.max(maxY, c.y);
    }
    final spanX = math.max(maxX - minX, 0.01);
    final spanY = math.max(maxY - minY, 0.01);
    final scale = math.min((size.width - 2 * pad) / spanX, (size.height - 2 * pad) / spanY);
    // Centre the drawing.
    final offX = (size.width - spanX * scale) / 2;
    final offY = (size.height - spanY * scale) / 2;
    Offset p(Vec2 v) => Offset(
          offX + (v.x - minX) * scale,
          // flip Y so +y (room length) points up on screen
          size.height - (offY + (v.y - minY) * scale),
        );

    // Floor fill.
    final path = Path()..moveTo(p(corners.first).dx, p(corners.first).dy);
    for (var i = 1; i < corners.length; i++) {
      path.lineTo(p(corners[i]).dx, p(corners[i]).dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFE9ECF2));

    // Walls + openings.
    final wallPaint = Paint()
      ..color = const Color(0xFF2B3242)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final n = corners.length;
    for (var i = 0; i < n; i++) {
      final a = corners[i];
      final b = corners[(i + 1) % n];
      canvas.drawLine(p(a), p(b), wallPaint);

      // Openings along this wall, drawn as a coloured chunk at their fraction.
      final wall = i < walls.length ? walls[i] : null;
      if (wall == null) continue;
      final wallLen = a.distanceTo(b);
      if (wallLen <= 0) continue;
      for (final o in wall.openings) {
        final halfFrac = (o.width / wallLen) / 2;
        final t0 = (o.position - halfFrac).clamp(0.0, 1.0);
        final t1 = (o.position + halfFrac).clamp(0.0, 1.0);
        final s0 = a + (b - a) * t0;
        final s1 = a + (b - a) * t1;
        final paint = Paint()
          ..color = o.type == 'window'
              ? const Color(0xFF2563EB)
              : DesignTokens.successGreen
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.butt;
        canvas.drawLine(p(s0), p(s1), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant RoomScanPainter old) =>
      old.corners != corners || old.walls != walls;
}

/// Renders the same top-down plan the review screen shows into a square PNG,
/// off-screen, so a freshly scanned room can carry its own project-card
/// thumbnail. Reuses [RoomScanPainter] verbatim — there is deliberately no
/// second renderer to keep in sync.
///
/// Throws if the engine cannot rasterise or encode the picture; the caller
/// treats that as a best-effort failure.
Future<Uint8List> renderRoomScanThumbnailPng({
  required List<Vec2> corners,
  required List<RoomWall> walls,
  int size = 512,
}) async {
  final side = size.toDouble();
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  // Same card background as the in-app preview, so the thumbnail and the
  // review screen read as the same drawing.
  canvas.drawRect(
    Rect.fromLTWH(0, 0, side, side),
    Paint()..color = const Color(0xFFF7F8FA),
  );
  RoomScanPainter(corners: corners, walls: walls).paint(canvas, Size(side, side));
  final picture = recorder.endRecording();
  try {
    final image = await picture.toImage(size, size);
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) {
        throw StateError('thumbnail encode failed');
      }
      return data.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  } finally {
    picture.dispose();
  }
}
