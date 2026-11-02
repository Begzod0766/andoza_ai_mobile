import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/design_tokens.dart';
import '../../l10n/app_localizations.dart';

/// E7: Qanday ishlaydi? — 4 full-screen dark-gradient onboarding slides
/// with segment progress + skip. Slide 2 is the delta-idea explainer and
/// must visually agree with the real mechanic in
/// design_selection_model.dart's [deriveStageStates] — a current-state
/// swatch (existingStateGray, matching the excluded-stage color used
/// everywhere else) becoming a finished-state swatch (delta.completed),
/// with the "faqat FARQ hisoblanadi" pill. Slide 3 follows slide 1's same
/// template per the spec (no independent reference frame exists for it).
class E7OnboardingWelcomeScreen extends StatefulWidget {
  const E7OnboardingWelcomeScreen({super.key});

  @override
  State<E7OnboardingWelcomeScreen> createState() =>
      _E7OnboardingWelcomeScreenState();
}

class _E7OnboardingWelcomeScreenState extends State<E7OnboardingWelcomeScreen> {
  final _controller = PageController();
  int _index = 0;

  static const _slideCount = 4;

  void _next() {
    if (_index < _slideCount - 1) {
      _controller.nextPage(
        duration: DesignTokens.animationNormal,
        curve: Curves.easeOut,
      );
    } else {
      context.go('/');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: DesignTokens.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spacingMd,
                vertical: DesignTokens.spacingSm,
              ),
              child: Row(
                children: [
                  for (var i = 0; i < _slideCount; i++)
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: DesignTokens.spacingXs,
                        ),
                        height: 4,
                        decoration: BoxDecoration(
                          color: i <= _index
                              ? DesignTokens.accentOrange
                              : DesignTokens.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(
                            DesignTokens.radiusFull,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(width: DesignTokens.spacingSm),
                  TextButton(
                    onPressed: () => context.go('/'),
                    child: Text(
                      l10n.onboardingSkip,
                      style: DesignTokens.caption.copyWith(
                        color: DesignTokens.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _index = i),
                children: const [
                  _MeasureSlide(),
                  _DeltaSlide(),
                  _DecorateSlide(),
                  _PriceSlide(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(DesignTokens.spacingLg),
              child: SizedBox(
                width: double.infinity,
                height: DesignTokens.buttonHeightLarge,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignTokens.accentOrangeStrong,
                  ),
                  onPressed: _next,
                  child: Text(
                    _index == _slideCount - 1
                        ? l10n.onboardingStart
                        : l10n.actionNext,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideScaffold extends StatelessWidget {
  const _SlideScaffold({
    required this.icon,
    required this.title,
    required this.description,
    this.child,
  });

  final IconData icon;
  final String title;
  final String description;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingXl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: DesignTokens.primaryBlue.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 56, color: DesignTokens.white),
          ),
          const SizedBox(height: DesignTokens.spacingXl),
          Text(
            title,
            style: DesignTokens.heading2.copyWith(color: DesignTokens.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DesignTokens.spacingMd),
          Text(
            description,
            style: DesignTokens.body1.copyWith(
              color: DesignTokens.white.withValues(alpha: 0.75),
            ),
            textAlign: TextAlign.center,
          ),
          if (child != null) ...[
            const SizedBox(height: DesignTokens.spacingXl),
            child!,
          ],
        ],
      ),
    );
  }
}

class _MeasureSlide extends StatelessWidget {
  const _MeasureSlide();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _SlideScaffold(
      icon: Icons.straighten,
      title: l10n.onboardingMeasureTitle,
      description: l10n.onboardingMeasureBody,
    );
  }
}

/// Slide 2 — the delta idea, visually tied to the real mechanic.
class _DeltaSlide extends StatelessWidget {
  const _DeltaSlide();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _SlideScaffold(
      icon: Icons.auto_awesome,
      title: l10n.onboardingDeltaTitle,
      description: l10n.onboardingDeltaBody,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _StateSwatch(
            color: DesignTokens.existingStateGray,
            label: l10n.onboardingDeltaCurrent,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: DesignTokens.spacingMd),
            child: Icon(Icons.arrow_forward, color: DesignTokens.white),
          ),
          _StateSwatch(color: DesignTokens.delta.completed, label: l10n.actionDone),
          const SizedBox(width: DesignTokens.spacingMd),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spacingSm,
              vertical: DesignTokens.spacingXs,
            ),
            decoration: BoxDecoration(
              color: DesignTokens.accentOrange,
              borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
            ),
            child: Text(
              l10n.onboardingDeltaPill,
              style: DesignTokens.caption.copyWith(
                color: DesignTokens.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StateSwatch extends StatelessWidget {
  const _StateSwatch({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
          ),
        ),
        const SizedBox(height: DesignTokens.spacingXs),
        Text(
          label,
          style: DesignTokens.caption.copyWith(
            color: DesignTokens.white.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
  }
}

class _DecorateSlide extends StatelessWidget {
  const _DecorateSlide();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _SlideScaffold(
      icon: Icons.view_in_ar_outlined,
      title: l10n.onboardingDecorateTitle,
      description: l10n.onboardingDecorateBody,
    );
  }
}

class _PriceSlide extends StatelessWidget {
  const _PriceSlide();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _SlideScaffold(
      icon: Icons.receipt_long_outlined,
      title: l10n.onboardingPriceTitle,
      description: l10n.onboardingPriceBody,
      child: Container(
        padding: const EdgeInsets.all(DesignTokens.spacingMd),
        decoration: BoxDecoration(
          color: DesignTokens.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        ),
        child: Text(
          l10n.onboardingPriceSaved,
          style: DesignTokens.subtitle2.copyWith(
            color: DesignTokens.delta.completed,
          ),
        ),
      ),
    );
  }
}
