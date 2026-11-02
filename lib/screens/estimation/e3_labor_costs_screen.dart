import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/design_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../models/design_selection_model.dart' show stageLabel;
import '../../providers/estimate_provider.dart';
import '../../utils/currency.dart';

/// E3: Smeta sozlash — quality tiers (Ekonom/Standart/Premium, total
/// recomputes live via [qualityTierProvider]), "Ishchi kuchini
/// qo'shmaslik" DIY toggle, breakdown including the green delta-savings
/// line, sticky new total + "Smetani saqlash" back to E1.
class E3LaborCostsScreen extends ConsumerWidget {
  const E3LaborCostsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final estimate = ref.watch(estimateProvider);
    final tier = ref.watch(qualityTierProvider);
    final diy = ref.watch(diyModeProvider);
    final materials = estimateMaterialsTotal(estimate);
    final labor = estimateLaborTotal(estimate);
    final savings = estimateSavingsTotal(estimate);
    final savingsStage = estimate.stages.firstWhere(
      (s) => s.isExcluded,
      orElse: () => estimate.stages.first,
    );

    return Scaffold(
      backgroundColor: DesignTokens.backgroundLight,
      appBar: AppBar(
        backgroundColor: DesignTokens.backgroundLight,
        elevation: 0,
        title: Text(l10n.estimateAdjust, style: DesignTokens.heading3),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(
                DesignTokens.screenPaddingHorizontal,
              ),
              children: [
                Text(l10n.estimateQualityLevel, style: DesignTokens.subtitle2),
                const SizedBox(height: DesignTokens.spacingSm),
                for (final t in QualityTier.values) ...[
                  _TierCard(
                    tier: t,
                    selected: t == tier,
                    total: estimate.totalPrice / tier.multiplier * t.multiplier,
                    onTap: () =>
                        ref.read(qualityTierProvider.notifier).state = t,
                  ),
                  const SizedBox(height: DesignTokens.spacingSm),
                ],
                const SizedBox(height: DesignTokens.spacingMd),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    l10n.estimateExcludeLabor,
                    style: DesignTokens.body2,
                  ),
                  subtitle: Text(
                    l10n.estimateDiySubtitle,
                    style: DesignTokens.caption.copyWith(
                      color: DesignTokens.textGray,
                    ),
                  ),
                  value: diy,
                  onChanged: (v) =>
                      ref.read(diyModeProvider.notifier).state = v,
                ),
                const SizedBox(height: DesignTokens.spacingMd),
                Container(
                  padding: const EdgeInsets.all(DesignTokens.spacingMd),
                  decoration: BoxDecoration(
                    color: DesignTokens.white,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                    border: Border.all(color: DesignTokens.borderGray),
                  ),
                  child: Column(
                    children: [
                      _SummaryRow(
                        label: l10n.shopMaterials,
                        value: formatSom(materials.round()),
                      ),
                      const SizedBox(height: DesignTokens.spacingXs),
                      _SummaryRow(
                        label: l10n.estimateLabor,
                        value: formatSom(labor.round()),
                      ),
                      if (savings > 0) ...[
                        const SizedBox(height: DesignTokens.spacingXs),
                        _SummaryRow(
                          label: l10n.estimateDeltaSavings(
                            stageLabel(savingsStage.name) ??
                                l10n.estimateStageFallback,
                          ),
                          value: '− ${formatSom(savings.round())}',
                          valueColor: DesignTokens.successGreen,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(DesignTokens.spacingMd),
            decoration: const BoxDecoration(
              color: DesignTokens.white,
              boxShadow: [DesignTokens.shadowNavBar],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.estimateNewTotal, style: DesignTokens.subtitle1),
                      Text(
                        formatSom(estimate.totalPrice.round()),
                        style: DesignTokens.heading3.copyWith(
                          color: DesignTokens.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.spacingMd),
                  SizedBox(
                    height: DesignTokens.buttonHeightLarge,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignTokens.accentOrangeStrong,
                      ),
                      onPressed: () => context.pop(),
                      child: Text(l10n.estimateSaveEstimate),
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

class _TierCard extends StatelessWidget {
  const _TierCard({
    required this.tier,
    required this.selected,
    required this.total,
    required this.onTap,
  });

  final QualityTier tier;
  final bool selected;
  final double total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(DesignTokens.spacingMd),
        decoration: BoxDecoration(
          color: selected
              ? DesignTokens.primaryBlue.withValues(alpha: 0.08)
              : DesignTokens.white,
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          border: Border.all(
            color: selected
                ? DesignTokens.primaryBlue
                : DesignTokens.borderGray,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected
                  ? DesignTokens.primaryBlue
                  : DesignTokens.textMuted,
            ),
            const SizedBox(width: DesignTokens.spacingSm),
            Expanded(child: Text(tier.label(AppLocalizations.of(context)!), style: DesignTokens.subtitle2)),
            Text(
              formatSom(total.round()),
              style: DesignTokens.subtitle2.copyWith(
                color: DesignTokens.primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: DesignTokens.body2.copyWith(color: DesignTokens.textGray),
        ),
        Text(
          value,
          style: DesignTokens.body2.copyWith(
            color: valueColor ?? DesignTokens.textDark,
            fontWeight: valueColor != null
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
