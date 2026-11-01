import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/design_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../models/room_plan.dart';
import '../../providers/room_provider.dart';

const _totalPoints = 8;

/// 360° capture state — 8 points around a dashed circle, per spec.
class PhotoScanState {
  final int capturedPoints;

  PhotoScanState({required this.capturedPoints});

  bool get isComplete => capturedPoints >= _totalPoints;

  PhotoScanState copyWith({int? capturedPoints}) {
    return PhotoScanState(
      capturedPoints: capturedPoints ?? this.capturedPoints,
    );
  }
}

class PhotoScanNotifier extends StateNotifier<PhotoScanState> {
  PhotoScanNotifier() : super(PhotoScanState(capturedPoints: 0));

  void capturePoint() {
    if (state.isComplete) return;
    state = state.copyWith(capturedPoints: state.capturedPoints + 1);
  }
}

final photoScanProvider =
    StateNotifierProvider<PhotoScanNotifier, PhotoScanState>(
      (ref) => PhotoScanNotifier(),
    );

/// A5: 360° Foto skan — 8 points on a dashed circle; captured points show
/// green with a checkmark, the current target pulses orange, the rest are
/// translucent-white dots.
class PhotoScanningScreen extends ConsumerStatefulWidget {
  const PhotoScanningScreen({super.key});

  @override
  ConsumerState<PhotoScanningScreen> createState() =>
      _PhotoScanningScreenState();
}

class _PhotoScanningScreenState extends ConsumerState<PhotoScanningScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: DesignTokens.animationCapturePulse,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scanState = ref.watch(photoScanProvider);

    ref.listen<PhotoScanState>(photoScanProvider, (previous, next) {
      if (next.isComplete && previous?.isComplete == false) {
        // The 360° capture extracts no dimensions, so seed a default rectangle
        // plan (the app's historical default box) as the in-app source of
        // truth; the wall-measurements screen next refines it.
        ref
            .read(activeRoomPlanProvider.notifier)
            .setPlan(
              RoomPlan.rectangle(
                width: 3.2,
                length: 4.5,
                ceilingHeightM: 2.8,
                source: RoomSource.photo,
              ),
            );
        context.push('/setup/wall-measurements');
      }
    });

    // A dark screen with no AppBar: without this the status bar keeps the
    // app's dark icons and the time and battery vanish into the background.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: DesignTokens.darkBg,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(DesignTokens.spacingMd),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: DesignTokens.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DesignTokens.spacingMd,
                        vertical: DesignTokens.spacingSm,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(
                          DesignTokens.radiusFull,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.explore_outlined,
                            color: DesignTokens.white,
                            size: DesignTokens.iconSm,
                          ),
                          const SizedBox(width: DesignTokens.spacingSm),
                          Text(
                            l10n.photoPointsCount(
                              scanState.capturedPoints,
                              _totalPoints,
                            ),
                            style: DesignTokens.body2.copyWith(
                              color: DesignTokens.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return CustomPaint(
                        size: const Size(280, 200),
                        painter: _CaptureRingPainter(
                          capturedPoints: scanState.capturedPoints,
                          pulse: _pulseController.value,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Text(
                l10n.photoTurnHint,
                style: DesignTokens.body1.copyWith(color: DesignTokens.white),
              ),
              const SizedBox(height: DesignTokens.spacingXl),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spacingXl,
                  vertical: DesignTokens.spacingLg,
                ),
                child: GestureDetector(
                  onTap: scanState.isComplete
                      ? null
                      : () =>
                            ref.read(photoScanProvider.notifier).capturePoint(),
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: DesignTokens.white,
                      borderRadius: BorderRadius.circular(
                        DesignTokens.radiusFull,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                            color: DesignTokens.accentOrange,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: DesignTokens.spacingSm),
                        Text(
                          l10n.photoCapture,
                          style: DesignTokens.subtitle2.copyWith(
                            color: DesignTokens.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dashed ellipse with 8 point markers around it: captured = green with
/// checkmark, current target = pulsing orange with an arrow, remaining =
/// translucent white dots.
class _CaptureRingPainter extends CustomPainter {
  _CaptureRingPainter({required this.capturedPoints, required this.pulse});

  final int capturedPoints;
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rx = size.width / 2 - 20;
    final ry = size.height / 2 - 10;

    final dashPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    const dashCount = 60;
    for (int i = 0; i < dashCount; i++) {
      if (i.isOdd) continue;
      final a1 = (i / dashCount) * 2 * pi;
      final a2 = ((i + 1) / dashCount) * 2 * pi;
      canvas.drawLine(
        Offset(center.dx + rx * cos(a1), center.dy + ry * sin(a1)),
        Offset(center.dx + rx * cos(a2), center.dy + ry * sin(a2)),
        dashPaint,
      );
    }

    for (int i = 0; i < _totalPoints; i++) {
      final angle = (i / _totalPoints) * 2 * pi - pi / 2;
      final pos = Offset(
        center.dx + rx * cos(angle),
        center.dy + ry * sin(angle),
      );

      if (i < capturedPoints) {
        canvas.drawCircle(pos, 13, Paint()..color = const Color(0xFF159C5B));
        _drawCheck(canvas, pos);
      } else if (i == capturedPoints) {
        canvas.drawCircle(
          pos,
          18 + pulse * 6,
          Paint()..color = DesignTokens.accentOrange.withValues(alpha: 0.25),
        );
        canvas.drawCircle(pos, 18, Paint()..color = DesignTokens.accentOrange);
      } else {
        canvas.drawCircle(
          pos,
          10,
          Paint()..color = Colors.white.withValues(alpha: 0.3),
        );
      }
    }
  }

  void _drawCheck(Canvas canvas, Offset center) {
    final path = Path()
      ..moveTo(center.dx - 5, center.dy)
      ..lineTo(center.dx - 1, center.dy + 4)
      ..lineTo(center.dx + 6, center.dy - 5);
    canvas.drawPath(
      path,
      Paint()
        ..color = DesignTokens.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_CaptureRingPainter oldDelegate) =>
      oldDelegate.capturedPoints != capturedPoints ||
      oldDelegate.pulse != pulse;
}
