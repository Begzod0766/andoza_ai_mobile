import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/design_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../models/design_selection_model.dart';
import '../../providers/design_provider.dart';
import '../../widgets/room/room_perspective_view.dart';

/// D10: Loyihangiz tayyor — finished, fully decorated and wired room.
/// Money is not shown here either — only the CTA into E1 (Smeta), the
/// first screen where a price appears.
class D10FinalConfirmationScreen extends ConsumerWidget {
  const D10FinalConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final condition =
        ref.watch(activeDesignProvider.select((d) => d?.roomCondition));

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: RoomPerspectiveView(
              wallCondition: condition?.wall ?? SurfaceCondition.raw,
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.45)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(
                DesignTokens.screenPaddingHorizontal,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: const BoxDecoration(
                      color: DesignTokens.successGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: DesignTokens.white,
                      size: 44,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacingLg),
                  Text(
                    l10n.electricalProjectReady,
                    style: DesignTokens.heading2.copyWith(
                      color: DesignTokens.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: DesignTokens.spacingXxl),
                  SizedBox(
                    width: double.infinity,
                    height: DesignTokens.buttonHeightLarge,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignTokens.accentOrangeStrong,
                      ),
                      onPressed: () => context.push('/estimation/e1'),
                      child: Text(l10n.electricalViewEstimate),
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacingMd),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: DesignTokens.white,
                      ),
                      onPressed: () => context.go('/design/b2'),
                      child: Text(l10n.commonBackTo3d),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
