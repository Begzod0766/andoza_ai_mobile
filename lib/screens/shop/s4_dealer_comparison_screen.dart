import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/design_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../models/shop_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/shop_provider.dart';
import '../../utils/currency.dart';

enum _DealerFilter { all, cheapest, official, fastest }

/// S4: Diler taqqoslash — dealer offer cards for one product; the
/// cheapest offer gets a green "ENG YAXSHI" ribbon.
class S4DealerComparisonScreen extends ConsumerStatefulWidget {
  const S4DealerComparisonScreen({required this.product, super.key});

  final Product product;

  @override
  ConsumerState<S4DealerComparisonScreen> createState() =>
      _S4DealerComparisonScreenState();
}

class _S4DealerComparisonScreenState
    extends ConsumerState<S4DealerComparisonScreen> {
  _DealerFilter _filter = _DealerFilter.all;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final product = widget.product;

    // Real per-store offers from the backend (cheapest first). When there are
    // none, or the request fails, show only the product's own store at its
    // catalog price — never invented dealers.
    final offersAsync = ref.watch(materialOffersProvider(product.id));
    final dealers = offersAsync.maybeWhen(
      data: (offers) => offers.isEmpty
          ? dealersForProduct(product)
          : offers.map(dealerFromOffer).toList(),
      orElse: () => dealersForProduct(product),
    );
    final isLoading = offersAsync.isLoading;
    final best = bestDealer(dealers);

    final visible = switch (_filter) {
      _DealerFilter.all => dealers,
      _DealerFilter.cheapest => [
        ...dealers,
      ]..sort((a, b) => a.pricePerUnit.compareTo(b.pricePerUnit)),
      _DealerFilter.official => dealers.where((d) => d.isOfficial).toList(),
      _DealerFilter.fastest => [
        ...dealers,
      ]..sort((a, b) => a.deliveryDays.compareTo(b.deliveryDays)),
    };

    return Scaffold(
      backgroundColor: DesignTokens.backgroundLight,
      appBar: AppBar(
        backgroundColor: DesignTokens.backgroundLight,
        elevation: 0,
        title: Text(l10n.shopDealerCompareTitle, style: DesignTokens.subtitle1),
      ),
      body: ListView(
        padding: const EdgeInsets.all(DesignTokens.screenPaddingHorizontal),
        children: [
          Container(
            padding: const EdgeInsets.all(DesignTokens.spacingMd),
            decoration: BoxDecoration(
              color: DesignTokens.white,
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              border: Border.all(color: DesignTokens.borderGray),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name, style: DesignTokens.subtitle2),
                      Text(
                        product.brand,
                        style: DesignTokens.caption.copyWith(
                          color: DesignTokens.textGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.spacingMd),
          // Sized by its chips (no fixed 40 px), so large text doesn't clip them.
          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                _FilterChip(
                  label: l10n.shopFilterAll,
                  selected: _filter == _DealerFilter.all,
                  onTap: () => setState(() => _filter = _DealerFilter.all),
                ),
                _FilterChip(
                  label: l10n.shopFilterCheapest,
                  selected: _filter == _DealerFilter.cheapest,
                  onTap: () => setState(() => _filter = _DealerFilter.cheapest),
                ),
                _FilterChip(
                  label: l10n.shopFilterOfficial,
                  selected: _filter == _DealerFilter.official,
                  onTap: () => setState(() => _filter = _DealerFilter.official),
                ),
                _FilterChip(
                  label: l10n.shopFilterFastest,
                  selected: _filter == _DealerFilter.fastest,
                  onTap: () => setState(() => _filter = _DealerFilter.fastest),
                ),
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.spacingMd),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: DesignTokens.spacingMd),
              child: LinearProgressIndicator(minHeight: 2),
            ),
          for (final dealer in visible) ...[
            _DealerCard(
              dealer: dealer,
              unit: product.unit,
              isBest: dealer.id == best.id,
              onSelect: () {
                ref.read(cartProvider.notifier).add(product, dealer);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.shopAddedToCart)),
                );
              },
            ),
            const SizedBox(height: DesignTokens.spacingSm),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: DesignTokens.spacingSm),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        backgroundColor: DesignTokens.white,
        selectedColor: DesignTokens.primaryBlue,
        labelStyle: DesignTokens.caption.copyWith(
          color: selected ? DesignTokens.white : DesignTokens.textDark,
        ),
      ),
    );
  }
}

class _DealerCard extends StatelessWidget {
  const _DealerCard({
    required this.dealer,
    required this.unit,
    required this.isBest,
    required this.onSelect,
  });

  final Dealer dealer;
  final String unit;
  final bool isBest;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacingMd),
      decoration: BoxDecoration(
        color: DesignTokens.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        border: Border.all(
          color: isBest ? DesignTokens.successGreen : DesignTokens.borderGray,
          width: isBest ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isBest)
            Padding(
              padding: const EdgeInsets.only(bottom: DesignTokens.spacingXs),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spacingSm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: DesignTokens.successGreen,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                ),
                child: Text(
                  l10n.shopBestRibbon,
                  style: DesignTokens.caption.copyWith(
                    color: DesignTokens.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: DesignTokens.borderGrayAlt,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                ),
                child: const Icon(
                  Icons.storefront_outlined,
                  color: DesignTokens.textMuted,
                ),
              ),
              const SizedBox(width: DesignTokens.spacingSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            dealer.name,
                            style: DesignTokens.subtitle2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (dealer.isOfficial) ...[
                          const SizedBox(width: DesignTokens.spacingXs),
                          const Icon(
                            Icons.verified,
                            size: 14,
                            color: DesignTokens.primaryBlue,
                          ),
                        ],
                      ],
                    ),
                    if (dealer.deliveryDays > 0 || dealer.district.isNotEmpty)
                      Text(
                        l10n.shopDeliveryDays(dealer.district, dealer.deliveryDays),
                        style: DesignTokens.caption.copyWith(
                          color: DesignTokens.textGray,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacingSm),
          // Price and button share a line while they fit; at large text the
          // button drops below instead of overflowing.
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: DesignTokens.spacingSm,
            runSpacing: DesignTokens.spacingSm,
            children: [
              Text(
                '${formatSom(dealer.pricePerUnit)} / $unit',
                style: DesignTokens.subtitle2.copyWith(
                  color: DesignTokens.primaryBlue,
                ),
              ),
              ElevatedButton(
                onPressed: onSelect,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.spacingLg,
                  ),
                ),
                child: Text(l10n.shopSelect),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
