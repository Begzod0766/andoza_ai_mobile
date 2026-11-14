import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../config/design_tokens.dart';
import '../../l10n/app_localizations.dart';
import 'home_tour_keys.dart';
import 'home_tour_steps.dart';

(String, String) _texts(AppLocalizations l, HomeTourTarget t) => switch (t) {
      HomeTourTarget.newProject => (l.homeTourNewProjectTitle, l.homeTourNewProjectBody),
      HomeTourTarget.resume => (l.homeTourResumeTitle, l.homeTourResumeBody),
      HomeTourTarget.estimate => (l.homeTourEstimateTitle, l.homeTourEstimateBody),
      HomeTourTarget.shop => (l.homeTourShopTitle, l.homeTourShopBody),
      HomeTourTarget.masters => (l.homeTourMastersTitle, l.homeTourMastersBody),
      HomeTourTarget.help => (l.homeTourHelpTitle, l.homeTourHelpBody),
    };

/// Shows the blurred coach-mark tour over the visible targets. [onFinish] runs
/// exactly once, whether the tour is completed or skipped.
///
/// The package's overlay sits above the app and absorbs taps, so tapping the
/// highlighted target advances the tour and never reaches the widget below.
Future<void> showHomeTour(
  BuildContext context,
  HomeTourKeys keys, {
  required bool hasProjects,
  required VoidCallback onFinish,
}) async {
  final l = AppLocalizations.of(context)!;
  final steps = presentTargets(homeTourSteps(hasProjects: hasProjects), keys);
  if (steps.isEmpty) {
    onFinish();
    return;
  }

  var finished = false;
  void finishOnce() {
    if (finished) return;
    finished = true;
    onFinish();
  }

  late final TutorialCoachMark tour;
  final targets = <TargetFocus>[
    for (var i = 0; i < steps.length; i++)
      TargetFocus(
        identify: steps[i].name,
        keyTarget: keys.of(steps[i]),
        shape: ShapeLightFocus.RRect,
        radius: 16,
        enableOverlayTab: false,
        enableTargetTab: true,
        contents: [
          TargetContent(
            // Nav-bar targets sit at the bottom: the card goes above them.
            align: (steps[i] == HomeTourTarget.shop || steps[i] == HomeTourTarget.masters)
                ? ContentAlign.top
                : ContentAlign.bottom,
            builder: (ctx, controller) {
              final (title, body) = _texts(l, steps[i]);
              return _TourCard(
                title: title,
                body: body,
                counter: l.tourStepOf(i + 1, steps.length),
                skipLabel: l.tourSkip,
                nextLabel: i == steps.length - 1 ? l.tourDone : l.tourNext,
                onSkip: tour.skip,
                onNext: i == steps.length - 1 ? tour.finish : tour.next,
              );
            },
          ),
        ],
      ),
  ];

  tour = TutorialCoachMark(
    targets: targets,
    imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
    colorShadow: DesignTokens.shadowGray,
    opacityShadow: 0.6,
    hideSkip: true,
    pulseEnable: false,
    onFinish: finishOnce,
    onSkip: () {
      finishOnce();
      return true;
    },
  );
  tour.show(context: context);
}

class _TourCard extends StatelessWidget {
  const _TourCard({
    required this.title,
    required this.body,
    required this.counter,
    required this.skipLabel,
    required this.nextLabel,
    required this.onSkip,
    required this.onNext,
  });

  final String title, body, counter, skipLabel, nextLabel;
  final VoidCallback onSkip, onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignTokens.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700, color: DesignTokens.textDark)),
          const SizedBox(height: 6),
          Text(body,
              style: const TextStyle(fontSize: 14, height: 1.4, color: DesignTokens.textGray)),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(counter,
                  style: const TextStyle(fontSize: 13, color: DesignTokens.textMuted)),
              const Spacer(),
              TextButton(onPressed: onSkip, child: Text(skipLabel)),
              const SizedBox(width: 4),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: DesignTokens.primaryBlue),
                onPressed: onNext,
                child: Text(nextLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
