import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/design_tokens.dart';
import '../../l10n/app_localizations.dart';
import 'home_tour_keys.dart';
import 'home_tour_launcher.dart';
import 'home_tour_steps.dart';

/// "?" button that replays the home tour. It carries the tour's `help` key, so
/// only one instance may be in the tree at a time (the empty and the
/// with-projects home states are mutually exclusive).
class HomeTourHelpButton extends ConsumerWidget {
  const HomeTourHelpButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keys = ref.watch(homeTourKeysProvider);
    final tooltip = AppLocalizations.of(context)!.tourHelpTooltip;
    return IconButton(
      key: keys.of(HomeTourTarget.help),
      tooltip: tooltip,
      icon: const Icon(Icons.help_outline, color: DesignTokens.primaryBlue),
      onPressed: () => ref.read(homeTourRequestProvider.notifier).state++,
    );
  }
}
