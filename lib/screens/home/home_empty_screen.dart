import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/design_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/empty_state_pattern.dart';
import '../room_setup/new_project_sheet.dart';

// The home-screen state provider + merge logic and the ProjectItem/HomeState
// data classes were relocated to lib/providers/projects_provider.dart and
// lib/models/project_item.dart. Re-exported here so existing imports of this
// screen file keep resolving those symbols.
export '../../models/project_item.dart';
export '../../providers/projects_provider.dart';

/// One of the three "story circle" onboarding shortcuts on A1 — animated
/// conic-gradient ring (2.5s spin) that greys out once tapped.
class _StoryCircle extends StatefulWidget {
  const _StoryCircle({
    required this.icon,
    required this.label,
    required this.seen,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool seen;
  final VoidCallback onTap;

  @override
  State<_StoryCircle> createState() => _StoryCircleState();
}

class _StoryCircleState extends State<_StoryCircle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: DesignTokens.animationStoryRing,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
      onTap: widget.onTap,
      child: Column(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: widget.seen
                ? Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: DesignTokens.existingStateGray,
                        width: 2.5,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        widget.icon,
                        color: DesignTokens.textMuted,
                        size: DesignTokens.iconMd,
                      ),
                    ),
                  )
                : AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _ConicRingPainter(_controller.value),
                        child: Center(
                          child: Icon(
                            widget.icon,
                            color: DesignTokens.primaryBlue,
                            size: DesignTokens.iconMd,
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: DesignTokens.spacingXs),
          // The whole column width (a third of the row), and at most 1.5×
          // text: a fixed 72 px split "Qanday" mid-word at large text.
          Text(
            widget.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: DesignTokens.caption,
            textScaler: MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.5),
          ),
        ],
      ),
    ),
    );
  }
}

/// Blue→orange conic-gradient ring, per spec ("animated blue→orange conic
/// rings, 2.5s spin").
class _ConicRingPainter extends CustomPainter {
  _ConicRingPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: 6.28319,
        transform: GradientRotation(progress * 6.28319),
        colors: const [
          DesignTokens.primaryBlue,
          DesignTokens.accentOrange,
          DesignTokens.primaryBlue,
        ],
      ).createShader(rect);
    canvas.drawOval(rect.deflate(1.25), paint);
  }

  @override
  bool shouldRepaint(_ConicRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Empty-state body content (A1), shared between the standalone
/// [HomeEmptyScreen] route and [HomeWithProjectsScreen] (which supplies its
/// own AppBar/nav and swaps this in when the project list is empty).
class HomeEmptyBody extends StatelessWidget {
  const HomeEmptyBody({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: SingleChildScrollView(
        // Always scrollable so the home's pull-to-refresh works when it fits.
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.screenPaddingHorizontal,
          vertical: DesignTokens.spacingLg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Three story-circle onboarding shortcuts.
            // Top-aligned so a one-line label doesn't drop its circle lower.
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _StoryCircle(
                    icon: Icons.help_outline,
                    label: l10n.homeStoryHowItWorks,
                    seen: false,
                    onTap: () => context.push('/onboarding/e7'),
                  ),
                ),
                Expanded(
                  child: _StoryCircle(
                    icon: Icons.play_circle_outline,
                    label: l10n.homeStoryDemoGuide,
                    seen: true,
                    onTap: () => context.push('/onboarding/e8'),
                  ),
                ),
                Expanded(
                  child: _StoryCircle(
                    icon: Icons.auto_awesome,
                    label: l10n.homeStoryDemo,
                    seen: false,
                    onTap: () => context.push('/onboarding/e8'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.spacingXl),
            EmptyStatePattern(
              icon: Icons.home_outlined,
              title: l10n.homeEmptyTitle,
              message: l10n.homeEmptyMessage,
              actionLabel: l10n.homeEmptyAction,
              onAction: () => showNewProjectSheet(context),
            ),
            const SizedBox(height: DesignTokens.spacingXl),
            // Tezkor amallar — 2x2 quick-action grid.
            Text(l10n.homeQuickActions, style: DesignTokens.subtitle1),
            const SizedBox(height: DesignTokens.spacingMd),
            Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    icon: Icons.camera_alt_outlined,
                    label: l10n.homeQuickScan,
                    onTap: () => showNewProjectSheet(context),
                  ),
                ),
                const SizedBox(width: DesignTokens.spacingMd),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.receipt_long_outlined,
                    label: l10n.homeQuickEstimate,
                    onTap: () => context.go('/estimation/e1'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.spacingMd),
            Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    icon: Icons.storefront_outlined,
                    label: l10n.homeQuickDealers,
                    onTap: () => context.go('/shop/s1'),
                  ),
                ),
                const SizedBox(width: DesignTokens.spacingMd),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.groups_outlined,
                    label: l10n.navMasters,
                    onTap: () => context.go('/masters/u1'),
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

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(DesignTokens.spacingMd),
        decoration: BoxDecoration(
          color: DesignTokens.white,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
          border: Border.all(color: DesignTokens.borderGray),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: DesignTokens.borderGrayAlt,
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              ),
              child: Icon(
                icon,
                color: DesignTokens.primaryBlue,
                size: DesignTokens.iconMd,
              ),
            ),
            const SizedBox(height: DesignTokens.spacingSm),
            Text(
              label,
              style: DesignTokens.body2.copyWith(
                fontWeight: FontWeight.w600,
                color: DesignTokens.textDark,
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
