import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/design_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/masters_provider.dart';
import '../../widgets/common/app_image.dart';

/// U3: Ustalar list view — vertical cards, online craftsmen sorted first.
class U3RequestBookingScreen extends ConsumerWidget {
  const U3RequestBookingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final masters = [...ref.watch(mockMastersProvider)]
      ..sort((a, b) => (b.isOnline ? 1 : 0) - (a.isOnline ? 1 : 0));

    return Scaffold(
      backgroundColor: DesignTokens.backgroundLight,
      appBar: AppBar(
        backgroundColor: DesignTokens.backgroundLight,
        elevation: 0,
        title: Text(l10n.navMasters, style: DesignTokens.heading3),
      ),
      body: RefreshIndicator(
        onRefresh: () => reloadMasters(ref),
        child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(DesignTokens.screenPaddingHorizontal),
        itemCount: masters.length,
        separatorBuilder: (_, _) =>
            const SizedBox(height: DesignTokens.spacingMd),
        itemBuilder: (context, index) {
          final m = masters[index];
          return Semantics(
            button: true,
            child: InkWell(
            onTap: () => context.push('/masters/u4', extra: m),
            borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
            child: Container(
              padding: const EdgeInsets.all(DesignTokens.spacingMd),
              decoration: BoxDecoration(
                color: DesignTokens.white,
                borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                border: Border.all(color: DesignTokens.borderGray),
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      Builder(
                        builder: (context) {
                          final initial = CircleAvatar(
                            radius: 28,
                            backgroundColor: Color(m.trade.colorValue),
                            child: Text(
                              m.initial,
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                          final url = m.master.avatar;
                          if (url == null) return initial;
                          return ClipOval(
                            child: AppImage(
                              url: url,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              placeholder: initial,
                              errorWidget: initial,
                            ),
                          );
                        },
                      ),
                      if (m.isOnline)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: DesignTokens.successGreen,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: DesignTokens.white,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: DesignTokens.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(m.master.name, style: DesignTokens.subtitle2),
                            if (m.isVerified) ...[
                              const SizedBox(width: DesignTokens.spacingXs),
                              const Icon(
                                Icons.verified,
                                size: 14,
                                color: DesignTokens.primaryBlue,
                              ),
                            ],
                          ],
                        ),
                        Text(
                          '${m.trade.emoji} ${m.trade.label(l10n)}',
                          style: DesignTokens.caption.copyWith(
                            color: DesignTokens.textGray,
                          ),
                        ),
                        const SizedBox(height: DesignTokens.spacingXs),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: DesignTokens.accentOrange,
                            ),
                            Text(
                              ' ${m.master.rating}',
                              style: DesignTokens.caption,
                            ),
                            const SizedBox(width: DesignTokens.spacingSm),
                            Text(
                              m.master.distanceKm != null
                                  ? l10n.mastersAreaDistance(
                                      m.areaName,
                                      '${m.master.distanceKm}',
                                    )
                                  : m.areaName,
                              style: DesignTokens.caption.copyWith(
                                color: DesignTokens.textGray,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: DesignTokens.textMuted,
                  ),
                ],
              ),
            ),
          ),
          );
        },
      )),
    );
  }
}
