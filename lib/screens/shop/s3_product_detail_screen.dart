import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/design_tokens.dart';
import '../../features/moderation/report_repository.dart';
import '../../features/moderation/report_sheet.dart';
import '../../l10n/app_localizations.dart';
import '../../models/shop_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/shop_provider.dart';
import '../../utils/currency.dart';
import '../../widgets/common/app_image.dart';
import 'furniture_detail_screen.dart' show StoreLinkRow;

/// S3: Mahsulot kartasi — product detail with a blue recommendation card
/// showing the real computed project quantity (never a hardcoded guess)
/// when this product is tied to the active project's needs.
class S3ProductDetailScreen extends ConsumerStatefulWidget {
  const S3ProductDetailScreen({required this.product, super.key});

  final Product product;

  @override
  ConsumerState<S3ProductDetailScreen> createState() =>
      _S3ProductDetailScreenState();
}

class _S3ProductDetailScreenState extends ConsumerState<S3ProductDetailScreen> {
  late double _quantity = widget.product.projectQuantity ?? 1;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final product = widget.product;
    final defaultDealer = bestDealer(dealersForProduct(product));

    return Scaffold(
      backgroundColor: DesignTokens.backgroundLight,
      appBar: AppBar(
        backgroundColor: DesignTokens.backgroundLight,
        elevation: 0,
        title: Text(product.name, style: DesignTokens.subtitle1),
        actions: [
          // App Store guideline 1.2: sellers publish products, so others can
          // report them.
          PopupMenuButton<ReportTarget>(
            icon: const Icon(Icons.more_vert),
            onSelected: (target) => showReportSheet(
              context,
              target: target,
              targetId: product.id,
            ),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: ReportTarget.product,
                child: Text(l10n.reportAction),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(
                DesignTokens.screenPaddingHorizontal,
              ),
              children: [
                AspectRatio(
                  aspectRatio: 1.4,
                  child: Builder(
                    builder: (context) {
                      final placeholder = Container(
                        decoration: BoxDecoration(
                          color: DesignTokens.borderGrayAlt,
                          borderRadius: BorderRadius.circular(
                            DesignTokens.radiusLg,
                          ),
                        ),
                        child: const Icon(
                          Icons.image_outlined,
                          size: DesignTokens.iconXxl,
                          color: DesignTokens.textMuted,
                        ),
                      );
                      final url = product.imageUrl;
                      if (url == null) return placeholder;
                      return AppImage(
                        url: url,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        borderRadius: BorderRadius.circular(
                          DesignTokens.radiusLg,
                        ),
                        placeholder: placeholder,
                        errorWidget: placeholder,
                      );
                    },
                  ),
                ),
                const SizedBox(height: DesignTokens.spacingMd),
                if (product.isOfficialDealer)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DesignTokens.spacingSm,
                      vertical: DesignTokens.spacingXs,
                    ),
                    decoration: BoxDecoration(
                      color: DesignTokens.successGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        DesignTokens.radiusSm,
                      ),
                    ),
                    child: Text(
                      l10n.shopOfficialDealer,
                      style: DesignTokens.caption.copyWith(
                        color: DesignTokens.successGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(height: DesignTokens.spacingXs),
                Text(product.brand, style: DesignTokens.body2),
                Text(product.name, style: DesignTokens.heading3),
                const SizedBox(height: DesignTokens.spacingXs),
                Text(
                  '${formatSom(defaultDealer.pricePerUnit)} / ${product.unit}',
                  style: DesignTokens.subtitle1.copyWith(
                    color: DesignTokens.primaryBlue,
                  ),
                ),
                Text(
                  l10n.shopPriceFromDealer(defaultDealer.name),
                  style: DesignTokens.caption.copyWith(
                    color: DesignTokens.textGray,
                  ),
                ),
                if (product.isInProject) ...[
                  const SizedBox(height: DesignTokens.spacingMd),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(DesignTokens.spacingMd),
                    decoration: BoxDecoration(
                      color: DesignTokens.primaryBlue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(
                        DesignTokens.radiusMd,
                      ),
                      border: Border.all(
                        color: DesignTokens.primaryBlue.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      l10n.shopProjectNeed(
                            formatQuantity(product.projectQuantity!),
                            product.unit,
                          ) +
                          (product.coverage != null
                              ? ' — ${product.coverage}'
                              : ''),
                      style: DesignTokens.body2.copyWith(
                        color: DesignTokens.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: DesignTokens.spacingLg),
                Row(
                  children: [
                    Text(l10n.shopQuantityLabel, style: DesignTokens.body2),
                    const Spacer(),
                    _QtyButton(
                      icon: Icons.remove,
                      label: l10n.a11yQuantityDecrease,
                      onTap: () => setState(
                        () => _quantity = (_quantity - 1).clamp(1, 9999),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DesignTokens.spacingMd,
                      ),
                      child: Text(
                        '${formatQuantity(_quantity)} ${product.unit}',
                        style: DesignTokens.subtitle2,
                      ),
                    ),
                    _QtyButton(
                      icon: Icons.add,
                      label: l10n.a11yQuantityIncrease,
                      onTap: () => setState(() => _quantity += 1),
                    ),
                  ],
                ),
                const SizedBox(height: DesignTokens.spacingLg),
                if (product.coverage != null)
                  _SpecRow(
                    label: l10n.shopSpecCoverage,
                    value: product.coverage!,
                  ),
                if (product.dryingTime != null)
                  _SpecRow(
                    label: l10n.shopSpecDryingTime,
                    value: product.dryingTime!,
                  ),
                if (product.washable != null)
                  _SpecRow(
                    label: l10n.shopSpecWashable,
                    value: product.washable! ? l10n.commonYes : l10n.commonNo,
                  ),
                const SizedBox(height: DesignTokens.spacingLg),
                Semantics(
                  button: true,
                  child: InkWell(
                  onTap: () => context.push('/shop/s4', extra: product),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                  child: Container(
                    padding: const EdgeInsets.all(DesignTokens.spacingMd),
                    decoration: BoxDecoration(
                      color: DesignTokens.white,
                      borderRadius: BorderRadius.circular(
                        DesignTokens.radiusMd,
                      ),
                      border: Border.all(color: DesignTokens.borderGray),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.storefront_outlined,
                          color: DesignTokens.primaryBlue,
                        ),
                        const SizedBox(width: DesignTokens.spacingSm),
                        Expanded(
                          child: Text(
                            l10n.shopWhereToBuy(defaultDealer.name),
                            style: DesignTokens.body2,
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
                ),
                if (product.storeId != null) ...[
                  const SizedBox(height: DesignTokens.spacingSm),
                  StoreLinkRow(
                    storeId: product.storeId!,
                    storeName: product.brand.isEmpty ? null : product.brand,
                  ),
                ],
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
              child: SizedBox(
                width: double.infinity,
                height: DesignTokens.buttonHeightLarge,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignTokens.accentOrange,
                  ),
                  onPressed: () {
                    ref
                        .read(cartProvider.notifier)
                        .add(product, defaultDealer, quantity: _quantity);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.shopAddedToCart)),
                    );
                  },
                  child: Text(
                    l10n.shopAddToCartPrice(
                      formatSom(
                        (defaultDealer.pricePerUnit * _quantity).round(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({
    required this.icon,
    required this.onTap,
    required this.label,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: DesignTokens.borderGrayAlt,
            borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
          ),
          child: Icon(icon, size: DesignTokens.iconSm),
        ),
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  const _SpecRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacingXs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: DesignTokens.body2.copyWith(color: DesignTokens.textGray),
          ),
          Text(value, style: DesignTokens.body2),
        ],
      ),
    );
  }
}
