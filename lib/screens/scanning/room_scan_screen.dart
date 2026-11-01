import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

import '../../config/design_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../services/analytics_service.dart';
import '../../features/room_scan/pending_scan_store.dart';
import '../../features/room_scan/room_scan_converter.dart';
import '../../features/room_scan/room_scan_service.dart';
import 'flat_scan_review_page.dart';
import 'room_scan_review_page.dart';

/// Drives the RoomPlan (LiDAR) capture: probe support → present the native
/// scanner → convert → hand off to [RoomScanReviewPage]. Reached from the
/// "LiDAR skaner" entry in the "Yangi loyiha" sheet (route `/scanning/roomplan`).
///
/// On an unsupported device (Android, non-Pro iPhone, iOS < 16) it explains the
/// requirement and offers the Photo / Draw fallbacks, then leaves.
class RoomScanScreen extends ConsumerStatefulWidget {
  const RoomScanScreen({super.key});

  @override
  ConsumerState<RoomScanScreen> createState() => _RoomScanScreenState();
}

class _RoomScanScreenState extends ConsumerState<RoomScanScreen> {
  static final Logger _logger = Logger();
  bool _busy = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    // Android has no RoomPlan/LiDAR: measure with ARCore instead.
    if (defaultTargetPlatform == TargetPlatform.android) {
      context.pushReplacement('/scanning/arcore');
      return;
    }
    final svc = ref.read(roomScanServiceProvider);
    final support = await svc.checkSupport();
    if (!mounted) return;
    _logger.i('roomscan support: ${support.supported} (${support.reason})');
    if (!support.supported) {
      final choice = await _showUnsupportedSheet();
      if (!mounted) return;
      switch (choice) {
        case 'photo':
          context.pushReplacement('/scanning/photo');
        case 'draw':
          context.pushReplacement('/setup/draw');
        default:
          context.pop();
      }
      return;
    }
    // Several rooms in one go only where RoomPlan can merge them (iOS 17+);
    // everywhere else the single-room scan, with no choice to make.
    if (support.multiRoom) {
      final choice = await _showChoiceSheet();
      if (!mounted) return;
      switch (choice) {
        case 'one':
          await _scan(svc);
        case 'flat':
          await _scanFlat(svc);
        default:
          context.pop();
      }
      return;
    }
    await _scan(svc);
  }

  Future<void> _scanFlat(RoomScanService svc) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await svc.scanRooms(labels: roomScanLabels(l10n));
      if (!mounted) return;
      if (result == null) {
        context.pop();
        return;
      }
      ref.read(analyticsProvider).scanFinished('lidar');
      final drafts = <RoomScanDraft>[];
      final scans = <ScanResult>[];
      for (final scan in result.rooms) {
        final draft = RoomScanConverter.toRoomDraft(scan.room);
        if (!draft.plan.isValid) continue;
        drafts.add(draft);
        scans.add(scan);
      }
      if (drafts.isEmpty) {
        setState(() => _error = l10n.scanNotDetected);
        return;
      }
      try {
        await PendingScanStore.saveFlat(MultiScanResult(rooms: scans, partial: result.partial));
      } catch (e) {
        _logger.w('roomscan pending-flat save failed (non-fatal): $e');
      }
      if (!mounted) return;
      context.pushReplacement(
        '/scanning/roomplan/review-flat',
        extra: FlatScanReviewArgs(
          drafts: drafts,
          scans: scans,
          partial: result.partial,
          dropped: result.rooms.length - drafts.length,
        ),
      );
    } on RoomScanException catch (e) {
      _logger.e('roomscan flat failed', error: e);
      if (mounted) setState(() => _error = _messageFor(context, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String?> _showChoiceSheet() {
    final l10n = AppLocalizations.of(context)!;
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: DesignTokens.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(DesignTokens.radiusSheet)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            DesignTokens.screenPaddingHorizontal,
            DesignTokens.spacingLg,
            DesignTokens.screenPaddingHorizontal,
            DesignTokens.spacingLg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.scanChoiceTitle, style: DesignTokens.heading3),
              const SizedBox(height: DesignTokens.spacingMd),
              ListTile(
                leading: const Icon(Icons.crop_square),
                title: Text(l10n.scanChoiceOneRoom),
                onTap: () => Navigator.of(sheetCtx).pop('one'),
              ),
              ListTile(
                leading: const Icon(Icons.dashboard_outlined),
                title: Text(l10n.scanChoiceFlat),
                subtitle: Text(l10n.scanChoiceFlatHint),
                onTap: () => Navigator.of(sheetCtx).pop('flat'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _scan(RoomScanService svc) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await svc.scan(labels: roomScanLabels(AppLocalizations.of(context)!));
      if (!mounted) return;
      if (result == null) {
        _logger.i('roomscan cancelled by user');
        context.pop();
        return;
      }
      ref.read(analyticsProvider).scanFinished('lidar');
      final draft = RoomScanConverter.toRoomDraft(result.room);
      if (!draft.plan.isValid) {
        setState(() => _error = draft.plan.invalidReason ??
            AppLocalizations.of(context)!.scanNotDetected);
        return;
      }
      _logger.i('roomscan → review (corners=${draft.plan.corners.length}, '
          'objects=${draft.objects.length})');
      // Persist the completed scan to disk before handing off to the review
      // screen — from here until "Davom etish" actually saves the room, the
      // only copy of a (possibly several-minutes-long) scan is in-memory
      // navigator state, which a backgrounded app or a low-memory kill can
      // drop. Best-effort: never block entering the review screen over this.
      try {
        await PendingScanStore.save(result);
      } catch (e) {
        _logger.w('roomscan pending-save failed (non-fatal): $e');
      }
      if (!mounted) return;
      context.pushReplacement(
        '/scanning/roomplan/review',
        extra: RoomScanReviewArgs(draft: draft, scan: result),
      );
    } on RoomScanException catch (e) {
      _logger.e('roomscan failed', error: e);
      if (mounted) setState(() => _error = _messageFor(context, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _messageFor(BuildContext context, RoomScanException e) {
    final l10n = AppLocalizations.of(context)!;
    switch (e.code) {
      case 'busy':
        return l10n.scanBusy;
      case 'scan_failed':
        // The native reason (RoomPlan's own error text) is what tells a failed
        // capture from an unsupported device or a bad export, so keep it visible.
        final reason = e.message.trim();
        return reason.isEmpty ? l10n.scanFailedRetry : '${l10n.scanFailedRetry}\n\n${l10n.scanFailedReason(reason)}';
      default:
        return l10n.scanErrorPrefixed(e.message);
    }
  }

  Future<String?> _showUnsupportedSheet() {
    final l10n = AppLocalizations.of(context)!;
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: DesignTokens.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(DesignTokens.radiusSheet)),
      ),
      builder: (sheetCtx) => Padding(
        padding: const EdgeInsets.fromLTRB(
          DesignTokens.screenPaddingHorizontal,
          DesignTokens.spacingLg,
          DesignTokens.screenPaddingHorizontal,
          DesignTokens.spacingXl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.scanLidarUnavailableTitle, style: DesignTokens.heading3),
            const SizedBox(height: DesignTokens.spacingSm),
            Text(
              l10n.scanLidarUnavailableBody,
              style: DesignTokens.body2.copyWith(color: DesignTokens.textGray),
            ),
            const SizedBox(height: DesignTokens.spacingLg),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(sheetCtx).pop('photo'),
                icon: const Icon(Icons.camera_alt_outlined),
                label: Text(l10n.newProjectPhotoTitle),
              ),
            ),
            const SizedBox(height: DesignTokens.spacingSm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.of(sheetCtx).pop('draw'),
                icon: const Icon(Icons.draw_outlined),
                label: Text(l10n.newProjectDrawTitle),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.newProjectLidarTitle)),
      body: Center(
        child: _error != null
            ? Padding(
                padding: const EdgeInsets.all(DesignTokens.spacingXl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: DesignTokens.textMuted),
                    const SizedBox(height: DesignTokens.spacingMd),
                    Text(_error!, textAlign: TextAlign.center, style: DesignTokens.body2),
                    const SizedBox(height: DesignTokens.spacingLg),
                    FilledButton(
                      onPressed: () => _scan(ref.read(roomScanServiceProvider)),
                      child: Text(l10n.actionRetry),
                    ),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: Text(l10n.actionCancel),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_busy) const CircularProgressIndicator(),
                  const SizedBox(height: DesignTokens.spacingMd),
                  Text(l10n.scanInProgress,
                      style: DesignTokens.body2.copyWith(color: DesignTokens.textGray)),
                ],
              ),
      ),
    );
  }
}
