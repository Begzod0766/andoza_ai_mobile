import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../config/design_tokens.dart';
import '../../features/moderation/blocked_ustalar.dart';
import '../../features/moderation/report_repository.dart';
import '../../features/moderation/report_sheet.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/business_provider.dart';
import '../../providers/masters_provider.dart';
import 'master_not_found.dart';
import '../../widgets/common/app_image.dart';
import '../../widgets/common/osm_attribution.dart';

/// U4: full craftsman profile — stat cards, portfolio, services, a
/// location mini-map showing only the approximate zone (never an exact
/// address, per spec's privacy rule), and reviews. Footer:
/// "Smetani yuborish" (primary).
class U4ReviewRatingScreen extends ConsumerWidget {
  const U4ReviewRatingScreen({this.master, super.key});

  final MockMaster? master;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final m = master;
    if (m == null) return const MasterNotFoundScreen();

    return Scaffold(
      backgroundColor: DesignTokens.backgroundLight,
      appBar: AppBar(
        backgroundColor: DesignTokens.backgroundLight,
        elevation: 0,
        actions: [_ModerationMenu(ustaId: m.master.id)],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(DesignTokens.screenPaddingHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Builder(
                      builder: (context) {
                        final initial = CircleAvatar(
                          radius: 44,
                          backgroundColor: Color(m.trade.colorValue),
                          child: Text(
                            m.initial,
                            style: const TextStyle(
                              color: DesignTokens.white,
                              fontSize: 32,
                            ),
                          ),
                        );
                        final url = m.master.avatar;
                        if (url == null) return initial;
                        return ClipOval(
                          child: AppImage(
                            url: url,
                            width: 88,
                            height: 88,
                            fit: BoxFit.cover,
                            placeholder: initial,
                            errorWidget: initial,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: DesignTokens.spacingMd),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${m.trade.emoji} ${m.trade.label(l10n)}',
                          style: DesignTokens.subtitle1,
                        ),
                        if (m.isVerified) ...[
                          const SizedBox(width: DesignTokens.spacingXs),
                          const Icon(
                            Icons.verified,
                            color: DesignTokens.primaryBlue,
                            size: 18,
                          ),
                        ],
                      ],
                    ),
                    Text(m.master.name, style: DesignTokens.heading3),
                    if (m.isVerified)
                      Text(
                        l10n.commonVerifiedBadge,
                        style: DesignTokens.caption.copyWith(
                          color: DesignTokens.successGreen,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: DesignTokens.spacingLg),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      value: '${m.master.rating}',
                      label: l10n.mastersStatRating,
                    ),
                  ),
                  const SizedBox(width: DesignTokens.spacingSm),
                  Expanded(
                    child: _StatCard(
                      value: '${m.master.reviewCount}',
                      label: l10n.mastersStatReviews,
                    ),
                  ),
                  const SizedBox(width: DesignTokens.spacingSm),
                  Expanded(
                    child: _StatCard(
                      value: '${m.experienceYears * 40}',
                      label: l10n.mastersStatJobs,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DesignTokens.spacingLg),
              Text(l10n.mastersPortfolio, style: DesignTokens.subtitle1),
              const SizedBox(height: DesignTokens.spacingSm),
              Builder(builder: (context) {
                final emptyText = Text(
                  l10n.mastersPortfolioEmpty,
                  style: DesignTokens.caption.copyWith(
                    color: DesignTokens.textGray,
                  ),
                );
                return ref.watch(ustaPortfolioProvider(m.master.id)).maybeWhen(
                      data: (items) => items.isEmpty
                          ? emptyText
                          : SizedBox(
                              height: 110,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: items.length,
                                separatorBuilder: (_, _) => const SizedBox(width: DesignTokens.spacingSm),
                                itemBuilder: (_, i) => ClipRRect(
                                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: AppImage(
                                      url: items[i].imageUrl,
                                      placeholder: const ColoredBox(color: DesignTokens.white),
                                      errorWidget: const ColoredBox(
                                        color: DesignTokens.white,
                                        child: Icon(Icons.image_not_supported_outlined,
                                            color: DesignTokens.textMuted),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      orElse: () => emptyText,
                    );
              }),
              const SizedBox(height: DesignTokens.spacingLg),
              Text(l10n.mastersServices, style: DesignTokens.subtitle1),
              const SizedBox(height: DesignTokens.spacingSm),
              _ServiceRow(label: l10n.mastersServiceTrade(m.trade.label(l10n))),
              _ServiceRow(label: l10n.mastersServiceConsultation),
              const SizedBox(height: DesignTokens.spacingLg),
              Text(l10n.mastersLocation, style: DesignTokens.subtitle1),
              const SizedBox(height: DesignTokens.spacingXs),
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
              const SizedBox(height: DesignTokens.spacingSm),
              SizedBox(
                height: 140,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(
                        m.master.latitude ?? 41.2995,
                        m.master.longitude ?? 69.2401,
                      ),
                      initialZoom: 12,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.none,
                      ),
                    ),
                    children: [
                      osmTileLayer(),
                      CircleLayer(
                        circles: [
                          CircleMarker(
                            point: LatLng(
                              m.master.latitude ?? 41.2995,
                              m.master.longitude ?? 69.2401,
                            ),
                            radius: 800,
                            useRadiusInMeter: true,
                            color: Color(
                              m.trade.colorValue,
                            ).withValues(alpha: 0.2),
                            borderColor: Color(m.trade.colorValue),
                            borderStrokeWidth: 2,
                          ),
                        ],
                      ),
                      const OsmAttribution(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: DesignTokens.spacingXl),
              SizedBox(
                width: double.infinity,
                height: DesignTokens.buttonHeightLarge,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignTokens.accentOrange,
                  ),
                  onPressed: () => context.push('/masters/u5', extra: m),
                  child: Text(l10n.mastersSendEstimate),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacingMd),
      decoration: BoxDecoration(
        color: DesignTokens.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        border: Border.all(color: DesignTokens.borderGray),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: DesignTokens.subtitle1.copyWith(
              color: DesignTokens.primaryBlue,
            ),
          ),
          Text(
            label,
            style: DesignTokens.caption.copyWith(color: DesignTokens.textGray),
          ),
        ],
      ),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacingXs),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 16,
            color: DesignTokens.successGreen,
          ),
          const SizedBox(width: DesignTokens.spacingSm),
          Text(label, style: DesignTokens.body2),
        ],
      ),
    );
  }
}

enum _ModerationAction { report, block }

/// ⋮ → "Shikoyat qilish" / "Bloklash" (App Store guideline 1.2: content other
/// users publish can be reported, and its author blocked).
class _ModerationMenu extends ConsumerWidget {
  const _ModerationMenu({required this.ustaId});

  final String ustaId;

  Future<void> _block(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.blockUstaTitle),
        content: Text(l10n.blockUstaBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.blockUstaConfirm),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(blockedUstalarProvider.notifier).block(ustaId);
    if (context.mounted) Navigator.of(context).maybePop();
    messenger.showSnackBar(SnackBar(content: Text(l10n.blockUstaDone)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return PopupMenuButton<_ModerationAction>(
      icon: const Icon(Icons.more_vert),
      onSelected: (a) => switch (a) {
        _ModerationAction.report => showReportSheet(
            context,
            target: ReportTarget.usta,
            targetId: ustaId,
          ),
        _ModerationAction.block => _block(context, ref),
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: _ModerationAction.report,
          child: Text(l10n.reportAction),
        ),
        PopupMenuItem(
          value: _ModerationAction.block,
          child: Text(l10n.blockUstaAction),
        ),
      ],
    );
  }
}
