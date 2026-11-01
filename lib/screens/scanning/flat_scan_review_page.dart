import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

import '../../config/design_tokens.dart';
import '../../features/room_scan/pending_scan_store.dart';
import '../../features/room_scan/room_scan_converter.dart';
import '../../features/room_scan/room_scan_service.dart';
import '../../geometry/room_geometry.dart';
import '../../l10n/app_localizations.dart';
import '../../services/flat_scan_handoff.dart';
import '../../utils/error_mapper.dart';
import 'room_scan_review_page.dart';

/// The rooms of one multi-room scan, on their way to the review page.
class FlatScanReviewArgs {
  const FlatScanReviewArgs({
    required this.drafts,
    required this.scans,
    this.partial = false,
    this.dropped = 0,
  });

  final List<RoomScanDraft> drafts;
  final List<ScanResult> scans;

  /// The session ended early (the app went to the background).
  final bool partial;

  /// Scanned rooms that could not be turned into a plan and were left out.
  final int dropped;
}

/// Review after a multi-room scan: every room drawn where it sits in the flat,
/// a name for each, then "Studiyada ochish" saves them all into one apartment
/// (each at its place, see [handoffScannedFlat]) and opens the studio on the
/// whole flat.
class FlatScanReviewPage extends ConsumerStatefulWidget {
  const FlatScanReviewPage({required this.args, super.key});

  final FlatScanReviewArgs args;

  @override
  ConsumerState<FlatScanReviewPage> createState() => _FlatScanReviewPageState();
}

class _FlatScanReviewPageState extends ConsumerState<FlatScanReviewPage> {
  static final Logger _logger = Logger();
  List<TextEditingController>? _names;
  bool _busy = false;

  List<RoomScanDraft> get _drafts => widget.args.drafts;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;
    _names ??= [
      for (var i = 0; i < _drafts.length; i++)
        TextEditingController(text: l10n.scanRoomN(i + 1)),
    ];
  }

  @override
  void dispose() {
    for (final c in _names ?? const <TextEditingController>[]) {
      c.dispose();
    }
    super.dispose();
  }

  /// One id per session, so the backend never takes two of its rooms for a
  /// re-scan of one (`scan_group`).
  static String _newScanGroup() {
    final r = math.Random.secure();
    return List.generate(16, (_) => r.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
  }

  Future<void> _continue() async {
    setState(() => _busy = true);
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final names = [
      for (var i = 0; i < _drafts.length; i++)
        _names![i].text.trim().isEmpty ? l10n.scanRoomN(i + 1) : _names![i].text.trim(),
    ];
    List<String> ids;
    try {
      ids = await handoffScannedFlat(ref, _drafts,
          names: names, ceilings: [for (final d in _drafts) d.plan.ceilingHeightM]);
    } on FlatHandoffException catch (e) {
      _logger.e('flat handoff stopped', error: e.cause);
      ids = e.createdIds;
    }
    if (ids.isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.scanReviewSaveFailed)));
      if (mounted) setState(() => _busy = false);
      return;
    }
    try {
      await PendingScanStore.clearFlat();
    } catch (e) {
      _logger.w('pending flat clear failed (non-fatal): $e');
    }

    final svc = ref.read(roomScanServiceProvider);
    final group = _newScanGroup();
    String? uploadError;
    String? thumbnailError;
    for (var i = 0; i < ids.length; i++) {
      try {
        await svc.upload(ids[i], widget.args.scans[i], scanGroup: group);
      } catch (e) {
        _logger.w('flat room ${ids[i]} scan upload failed: $e');
        uploadError ??= mapErrorToMessage(e);
      }
      try {
        final plan = _drafts[i].plan;
        final png = await renderRoomScanThumbnailPng(corners: plan.corners, walls: plan.walls);
        await svc.uploadThumbnail(ids[i], png);
      } catch (e) {
        _logger.w('flat room ${ids[i]} thumbnail failed: $e');
        thumbnailError ??= mapErrorToMessage(e);
      }
    }
    // The whole flat, not one room on its own (no `focus`).
    router.pushReplacement('/studio/${ids.first}');
    if (ids.length < _drafts.length) {
      messenger.showSnackBar(SnackBar(
          content: Text(l10n.flatReviewSavedSome(ids.length, _drafts.length))));
    }
    if (uploadError != null) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.scanReviewUploadFailed(uploadError))));
    }
    if (thumbnailError != null) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.scanReviewThumbnailFailed(thumbnailError))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final notice = DesignTokens.body2.copyWith(color: DesignTokens.textGray);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.flatReviewTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(DesignTokens.screenPaddingHorizontal),
          children: [
            if (widget.args.partial)
              Text(l10n.flatReviewPartial(_drafts.length), style: notice),
            if (widget.args.dropped > 0)
              Text(l10n.flatReviewDropped(widget.args.dropped), style: notice),
            const SizedBox(height: DesignTokens.spacingMd),
            AspectRatio(
              aspectRatio: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FA),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                  border: Border.all(color: DesignTokens.borderGray),
                ),
                child: CustomPaint(painter: FlatScanPainter(_drafts)),
              ),
            ),
            const SizedBox(height: DesignTokens.spacingLg),
            for (var i = 0; i < _drafts.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: DesignTokens.spacingMd),
                child: TextField(
                  controller: _names![i],
                  enabled: !_busy,
                  decoration: InputDecoration(
                    labelText: l10n.flatReviewRoomName,
                    helperText:
                        '${_drafts[i].plan.areaM2.toStringAsFixed(1)} m² · ${formatLength(_drafts[i].plan.ceilingHeightM)}',
                    prefixText: '${i + 1}. ',
                  ),
                ),
              ),
            const SizedBox(height: DesignTokens.spacingLg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _busy ? null : () => context.pushReplacement('/scanning/roomplan'),
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
                        : Text(l10n.flatReviewContinue),
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

/// Top view of every scanned room at its place in the flat, numbered.
class FlatScanPainter extends CustomPainter {
  FlatScanPainter(this.drafts);

  final List<RoomScanDraft> drafts;

  @override
  void paint(Canvas canvas, Size size) {
    if (drafts.isEmpty) return;
    final rooms = [
      for (final d in drafts) [for (final c in d.plan.corners) d.worldOrigin + c],
    ];
    final all = rooms.expand((r) => r).toList();
    if (all.isEmpty) return;
    var minX = all.first.x, maxX = all.first.x, minY = all.first.y, maxY = all.first.y;
    for (final p in all) {
      minX = math.min(minX, p.x);
      maxX = math.max(maxX, p.x);
      minY = math.min(minY, p.y);
      maxY = math.max(maxY, p.y);
    }
    const pad = 16.0;
    final scale = math.min(
      (size.width - 2 * pad) / math.max(maxX - minX, 0.1),
      (size.height - 2 * pad) / math.max(maxY - minY, 0.1),
    );
    Offset at(Vec2 p) => Offset(pad + (p.x - minX) * scale, pad + (p.y - minY) * scale);

    final fill = Paint()..color = DesignTokens.primaryBlue.withValues(alpha: 0.08);
    final stroke = Paint()
      ..color = DesignTokens.textDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (var i = 0; i < rooms.length; i++) {
      final r = rooms[i];
      if (r.length < 3) continue;
      final path = Path()..moveTo(at(r.first).dx, at(r.first).dy);
      for (final p in r.skip(1)) {
        path.lineTo(at(p).dx, at(p).dy);
      }
      path.close();
      canvas.drawPath(path, fill);
      canvas.drawPath(path, stroke);
      var sum = const Vec2(0, 0);
      for (final p in r) {
        sum = sum + p;
      }
      final centre = at(sum * (1 / r.length));
      final label = TextPainter(
        text: TextSpan(text: '${i + 1}', style: DesignTokens.subtitle2),
        textDirection: TextDirection.ltr,
      )..layout();
      label.paint(canvas, centre - Offset(label.width / 2, label.height / 2));
    }
  }

  @override
  bool shouldRepaint(FlatScanPainter old) => old.drafts != drafts;
}
