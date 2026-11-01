import 'package:flutter/material.dart';

import '../../config/design_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../models/business_profile.dart';

/// The name of a furniture style id from [furnitureStyles].
String furnitureStyleLabel(AppLocalizations l10n, String id) => switch (id) {
      'neoklassika' => l10n.furnitureStyleNeoklassika,
      'klassik' => l10n.furnitureStyleKlassik,
      'zamonaviy' => l10n.furnitureStyleZamonaviy,
      'hitech' => l10n.furnitureStyleHitech,
      'minimalist' => l10n.furnitureStyleMinimalist,
      'skandinav' => l10n.furnitureStyleSkandinav,
      'loft' => l10n.furnitureStyleLoft,
      'milliy' => l10n.furnitureStyleMilliy,
      _ => id,
    };

/// Picks the design styles a model suits. None picked means every style.
/// The web app's `StyleChips` (andoza_ai `components/dokon/StyleChips.tsx`).
class StyleChips extends StatelessWidget {
  const StyleChips({
    required this.value,
    required this.onChanged,
    this.enabled = true,
    super.key,
  });

  final List<String> value;
  final ValueChanged<List<String>> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.furnitureStylesLabel, style: DesignTokens.subtitle2),
        const SizedBox(height: DesignTokens.spacingXs),
        Wrap(
          spacing: DesignTokens.spacingSm,
          runSpacing: DesignTokens.spacingXs,
          children: [
            for (final id in furnitureStyles)
              FilterChip(
                label: Text(furnitureStyleLabel(l10n, id)),
                selected: value.contains(id),
                // The theme's selected chip is blue: its text must be white to
                // be read (the default stayed grey on blue).
                labelStyle: DesignTokens.body2.copyWith(
                  color: value.contains(id)
                      ? DesignTokens.white
                      : DesignTokens.textDark,
                ),
                checkmarkColor: DesignTokens.white,
                onSelected: !enabled
                    ? null
                    : (on) => onChanged([
                          // Kept in the API's order, like the server stores them.
                          for (final s in furnitureStyles)
                            if (s == id ? on : value.contains(s)) s,
                        ]),
              ),
          ],
        ),
        if (value.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: DesignTokens.spacingXs),
            child: Text(
              l10n.furnitureStylesAll,
              style: DesignTokens.caption.copyWith(color: DesignTokens.textGray),
            ),
          ),
      ],
    );
  }
}
