import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/design_tokens.dart';
import '../../features/moderation/report_repository.dart';
import '../../features/moderation/report_sheet.dart';
import '../../l10n/app_localizations.dart';
import '../../models/api/api.dart';
import '../../models/shop_model.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/shop_provider.dart';
import '../../utils/currency.dart';
import '../../widgets/common/error_view.dart';
import 'furniture_card.dart';

/// A shop's public page: who it is (name, district, partner badge), how to
/// reach it (call, Telegram), and everything it sells — its furniture (3D
/// models a buyer can put in a room) and its building materials.
class StorePageScreen extends ConsumerWidget {
  const StorePageScreen({required this.storeId, super.key});

  final String storeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final store = ref.watch(storeProvider(storeId));
    return Scaffold(
      backgroundColor: DesignTokens.backgroundLight,
      appBar: AppBar(
        backgroundColor: DesignTokens.backgroundLight,
        elevation: 0,
        title: Text(
          store.valueOrNull?.name ?? l10n.navShop,
          style: DesignTokens.subtitle1,
        ),
        actions: [
          // App Store guideline 1.2: anyone can open a shop, so others can
          // report it.
          PopupMenuButton<ReportTarget>(
            icon: const Icon(Icons.more_vert),
            onSelected: (target) =>
                showReportSheet(context, target: target, targetId: storeId),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: ReportTarget.seller,
                child: Text(l10n.storeReport),
              ),
            ],
          ),
        ],
      ),
      body: store.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          error: e,
          title: l10n.storeLoadFailed,
          onRetry: () => ref.invalidate(storeProvider(storeId)),
        ),
        data: (store) => _StoreBody(store: store),
      ),
    );
  }
}

class _StoreBody extends ConsumerWidget {
  const _StoreBody({required this.store});

  final Store store;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final furniture = ref.watch(storeFurnitureProvider(store.id));
    final materials = ref
        .watch(shopCatalogProvider)
        .where((p) => p.storeId == store.id)
        .toList();
    final furnitureItems = furniture.valueOrNull ?? const <Furniture>[];
    final empty =
        furniture.hasValue && furnitureItems.isEmpty && materials.isEmpty;

    return ListView(
      padding: const EdgeInsets.all(DesignTokens.screenPaddingHorizontal),
      children: [
        _StoreHeader(store: store),
        const SizedBox(height: DesignTokens.spacingLg),
        if (furniture.isLoading && !furniture.hasValue)
          const Padding(
            padding: EdgeInsets.all(DesignTokens.spacingXl),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (furniture.hasError)
          ErrorView(
            error: furniture.error,
            onRetry: () => ref.invalidate(storeFurnitureProvider(store.id)),
          ),
        if (furnitureItems.isNotEmpty) ...[
          Text(l10n.shopFurnitureSection, style: DesignTokens.heading3),
          const SizedBox(height: DesignTokens.spacingMd),
          _Grid(
            children: [
              for (final item in furnitureItems)
                FurnitureCard(item: item, showStore: false),
            ],
          ),
          const SizedBox(height: DesignTokens.spacingLg),
        ],
        if (materials.isNotEmpty) ...[
          Text(l10n.shopMaterials, style: DesignTokens.heading3),
          const SizedBox(height: DesignTokens.spacingMd),
          _Grid(
            children: [
              for (final product in materials) _MaterialCard(product: product),
            ],
          ),
        ],
        if (empty)
          Padding(
            padding: const EdgeInsets.all(DesignTokens.spacingXl),
            child: Text(
              l10n.storeNoProducts,
              textAlign: TextAlign.center,
              style: DesignTokens.bodyMedium.copyWith(
                color: DesignTokens.textGray,
              ),
            ),
          ),
      ],
    );
  }
}

class _StoreHeader extends StatelessWidget {
  const _StoreHeader({required this.store});

  final Store store;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final phone = phoneUri(store.phone);
    final telegram = telegramUri(store.telegram);
    final official =
        store.partnerTier == 'gold' || store.partnerTier == 'platinum';
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacingMd),
      decoration: BoxDecoration(
        color: DesignTokens.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        border: Border.all(color: DesignTokens.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor:
                    _parseColor(store.logoColor) ?? DesignTokens.primaryBlue,
                child: Text(
                  store.name.isEmpty ? '?' : store.name[0].toUpperCase(),
                  style: DesignTokens.heading3.copyWith(
                    color: DesignTokens.white,
                  ),
                ),
              ),
              const SizedBox(width: DesignTokens.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(store.name, style: DesignTokens.heading3),
                    if (store.district != null && store.district!.isNotEmpty)
                      Text(
                        store.district!,
                        style: DesignTokens.body2.copyWith(
                          color: DesignTokens.textGray,
                        ),
                      ),
                    if (official)
                      Text(
                        l10n.shopOfficialDealer,
                        style: DesignTokens.caption.copyWith(
                          color: DesignTokens.successGreen,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (phone != null || telegram != null) ...[
            const SizedBox(height: DesignTokens.spacingMd),
            Row(
              children: [
                if (phone != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => launchUrl(phone),
                      icon: const Icon(Icons.call_outlined),
                      label: Text(l10n.storeCall),
                    ),
                  ),
                if (phone != null && telegram != null)
                  const SizedBox(width: DesignTokens.spacingSm),
                if (telegram != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => launchUrl(
                        telegram,
                        mode: LaunchMode.externalApplication,
                      ),
                      icon: const Icon(Icons.send_outlined),
                      label: Text(l10n.storeTelegram),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// The shop's Telegram as a t.me link, or null when it is not a username.
/// "@mebelplus", "mebelplus" and "https://t.me/mebelplus" all give
/// https://t.me/mebelplus; anything else — a stray URL, a `javascript:`
/// string — is dropped rather than opened. Same rule as the web's
/// `telegramHandle` in `frontend/src/lib/storeContact.ts`.
Uri? telegramUri(String? raw) {
  final match = RegExp(
    r'^(?:https?://)?(?:t\.me/|telegram\.me/)?@?([A-Za-z0-9_]{5,32})/?$',
  ).firstMatch(raw?.trim() ?? '');
  return match == null ? null : Uri.https('t.me', '/${match[1]}');
}

/// The shop's phone as a tel: link, rebuilt from its digits; null when it
/// cannot be a number. A bare 9-digit local number is an Uzbek mobile. Same
/// rule as the web's `phoneHref`.
Uri? phoneUri(String? raw) {
  final digits = (raw ?? '').replaceAll(RegExp(r'\D'), '');
  if (digits.length < 9 || digits.length > 15) return null;
  final full = digits.length == 9 ? '998$digits' : digits;
  return Uri(scheme: 'tel', path: '+$full');
}

Color? _parseColor(String? hex) {
  final value = hex?.replaceFirst('#', '');
  if (value == null || value.length != 6) return null;
  final parsed = int.tryParse(value, radix: 16);
  return parsed == null ? null : Color(0xFF000000 | parsed);
}

class _Grid extends StatelessWidget {
  const _Grid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: DesignTokens.spacingMd,
      crossAxisSpacing: DesignTokens.spacingMd,
      childAspectRatio: 0.72,
      children: children,
    );
  }
}

/// One of the shop's building materials; opens the usual product page (S3).
class _MaterialCard extends StatelessWidget {
  const _MaterialCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: InkWell(
        onTap: () => context.push('/shop/s3', extra: product),
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(DesignTokens.spacingSm),
          decoration: BoxDecoration(
            color: DesignTokens.white,
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            border: Border.all(color: DesignTokens.borderGray),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1.3,
                child: FurniturePicture(
                  url: product.imageUrl,
                  radius: DesignTokens.radiusSm,
                ),
              ),
              const SizedBox(height: DesignTokens.spacingSm),
              Text(
                product.name,
                style: DesignTokens.body2.copyWith(
                  color: DesignTokens.textDark,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Text(
                '${formatSom(product.pricePerUnit)} / ${product.unit}',
                style: DesignTokens.subtitle2.copyWith(
                  color: DesignTokens.primaryBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
