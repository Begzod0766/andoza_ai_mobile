import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/design_tokens.dart';
import '../../features/ar_scan/ar_scan_service.dart';
import '../../features/ar_scan/arcore_plan.dart';
import '../../features/room_scan/room_scan_converter.dart';
import '../../l10n/app_localizations.dart';
import '../../services/analytics_service.dart';
import 'room_scan_review_page.dart';

/// Copy for a [ArPlanRejected.reason].
String arScanRejectionText(AppLocalizations l10n, String reason) => switch (reason) {
      'too_few_corners' => l10n.arScanRejected_too_few_corners,
      'self_intersecting' => l10n.arScanRejected_self_intersecting,
      'wall_too_long' => l10n.arScanRejected_wall_too_long,
      _ => l10n.arScanFailed,
    };

/// `/scanning/arcore` — the Android camera measurement: check ARCore, open the
/// native scanner (`andoza/arscan`), clean its corners up into a [RoomPlan] and
/// hand it to the same review screen the iOS LiDAR scan uses.
class ArScanScreen extends ConsumerStatefulWidget {
  const ArScanScreen({super.key});

  @override
  ConsumerState<ArScanScreen> createState() => _ArScanScreenState();
}

enum _Problem { notInstalled, cameraDenied, unsupported, rejected, failed }

class _ArScanScreenState extends ConsumerState<ArScanScreen> with WidgetsBindingObserver {
  bool _busy = true;
  _Problem? _problem;
  String? _message;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Back from the Play Store after installing ARCore: check again by itself.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _problem == _Problem.notInstalled && !_busy) _start();
  }

  Map<String, String> _strings(AppLocalizations l10n) => {
        'arScanFindFloor': l10n.arScanFindFloor,
        'arScanCornersHint': l10n.arScanCornersHint,
        'arScanAddCorner': l10n.arScanAddCorner,
        'arScanUndo': l10n.arScanUndo,
        'arScanFinish': l10n.arScanFinish,
        'arScanSnapToFirst': l10n.arScanSnapToFirst,
        'arScanAimCeiling': l10n.arScanAimCeiling,
        'arScanConfirm': l10n.arScanConfirm,
        'arScanEnterManually': l10n.arScanEnterManually,
        'arScanExit': l10n.arScanExit,
        'arScanExitConfirm': l10n.arScanExitConfirm,
        'arScanTrackingLost': l10n.arScanTrackingLost,
        'arScanFloorHint': l10n.arScanFloorHint,
        'arScanCornersLost': l10n.arScanCornersLost,
        'arScanNoFloorHere': l10n.arScanNoFloorHere,
        'arScanKeepMeasuring': l10n.arScanKeepMeasuring,
        'arScanStepFloor': l10n.arScanStepFloor,
        'arScanStepCorners': l10n.arScanStepCorners,
        'arScanStepHeight': l10n.arScanStepHeight,
      };

  Future<void> _start() async {
    final l10n = AppLocalizations.of(context)!;
    final svc = ref.read(arScanServiceProvider);
    setState(() {
      _busy = true;
      _problem = null;
    });
    final support = await svc.checkSupport();
    if (!mounted) return;
    if (!support.supported) {
      _show(switch (support.reason) {
        'arcore_not_installed' => _Problem.notInstalled,
        'camera_denied' => _Problem.cameraDenied,
        'unsupported_device' || 'not_implemented' => _Problem.unsupported,
        // An inconclusive check (offline, timed out) is worth another try.
        _ => _Problem.failed,
      });
      return;
    }
    try {
      final raw = await svc.scanFloorPlan(_strings(l10n));
      if (!mounted) return;
      if (raw == null) {
        context.pop();
        return;
      }
      ref.read(analyticsProvider).scanFinished('arcore');
      switch (buildArcorePlan(raw)) {
        case ArPlanOk(:final plan):
          context.pushReplacement(
            '/scanning/roomplan/review',
            extra: RoomScanReviewArgs(draft: RoomScanDraft(plan: plan, objects: const []), scan: null),
          );
        case ArPlanRejected(:final reason):
          _show(_Problem.rejected, arScanRejectionText(l10n, reason));
      }
    } on ArScanException catch (e) {
      if (!mounted) return;
      _show(switch (e.code) {
        'camera_denied' => _Problem.cameraDenied,
        'arcore_not_installed' => _Problem.notInstalled,
        'unsupported_device' => _Problem.unsupported,
        _ => _Problem.failed,
      });
    }
  }

  void _show(_Problem p, [String? message]) => setState(() {
        _busy = false;
        _problem = p;
        _message = message;
      });

  Future<void> _installArCore() async {
    final market = Uri.parse('market://details?id=com.google.ar.core');
    if (!await launchUrl(market, mode: LaunchMode.externalApplication)) {
      await launchUrl(Uri.parse('https://play.google.com/store/apps/details?id=com.google.ar.core'),
          mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final problem = _problem;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.newProjectArScanTitle)),
      body: SafeArea(
        child: _busy || problem == null
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(DesignTokens.screenPaddingHorizontal),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      problem == _Problem.cameraDenied ? Icons.no_photography_outlined : Icons.view_in_ar_outlined,
                      size: DesignTokens.iconXl,
                      color: DesignTokens.textGray,
                    ),
                    const SizedBox(height: DesignTokens.spacingMd),
                    Text(
                      switch (problem) {
                        _Problem.notInstalled => l10n.arScanNotInstalled,
                        _Problem.cameraDenied => l10n.arScanCameraDenied,
                        _Problem.unsupported => l10n.arScanUnsupported,
                        _Problem.rejected => _message ?? l10n.arScanFailed,
                        _Problem.failed => l10n.arScanFailed,
                      },
                      textAlign: TextAlign.center,
                      style: DesignTokens.bodyMedium,
                    ),
                    const SizedBox(height: DesignTokens.spacingLg),
                    if (problem == _Problem.notInstalled)
                      ElevatedButton(onPressed: _installArCore, child: Text(l10n.arScanInstall)),
                    if (problem == _Problem.cameraDenied)
                      ElevatedButton(
                        onPressed: () => ref.read(arScanServiceProvider).openAppSettings(),
                        child: Text(l10n.arScanOpenSettings),
                      ),
                    if (problem != _Problem.unsupported) ...[
                      const SizedBox(height: DesignTokens.spacingSm),
                      OutlinedButton(onPressed: _start, child: Text(l10n.arScanRescan)),
                    ],
                    const SizedBox(height: DesignTokens.spacingSm),
                    TextButton(
                      onPressed: () => context.pushReplacement('/setup/draw'),
                      child: Text(l10n.newProjectDrawTitle),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
