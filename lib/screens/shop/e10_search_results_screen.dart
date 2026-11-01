import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/design_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../models/shop_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/shop_provider.dart';
import '../../utils/currency.dart';
import '../../widgets/common/app_image.dart';
import '../../widgets/common/load_status.dart';

enum _ResultFilter { all, forMyProject, cheapest, rating }

/// E10: Qidiruv natijalari — active search with clear, filter chips
/// (Barchasi · Loyihamga mos · Eng arzon · Reyting), result count, rows
/// with "Loyihada" tags and a quick + to cart. Reuses Batch S's real
/// catalog/cart providers rather than a separate mock dataset.
class E10SearchResultsScreen extends ConsumerStatefulWidget {
  const E10SearchResultsScreen({this.initialQuery = '', super.key});

  final String initialQuery;

  @override
  ConsumerState<E10SearchResultsScreen> createState() =>
      _E10SearchResultsScreenState();
}

class _E10SearchResultsScreenState
    extends ConsumerState<E10SearchResultsScreen> {
  late final _controller = TextEditingController(text: widget.initialQuery);
  _ResultFilter _filter = _ResultFilter.all;
  // What the server is asked for: the typed text, once typing pauses.
  late String _search = shopSearchQuery(widget.initialQuery);
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQuery(String text) {
    setState(() {}); // the clear button
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _search = shopSearchQuery(text));
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final catalog = ref.watch(shopCatalogProvider);
    // A search goes to the server, so it covers the whole catalog.
    final found = _search.isEmpty ? null : ref.watch(shopSearchProvider(_search));
    var results = found == null ? catalog : (found.valueOrNull ?? const <Product>[]);
    final status = found == null
        ? loadStatus(
            isEmpty: catalog.isEmpty,
            loading: ref.watch(shopCatalogLoadingProvider),
            error: ref.watch(shopCatalogErrorProvider),
            onRetry: () => shopCatalogSources.forEach(ref.invalidate),
          )
        : loadStatus(
            isEmpty: results.isEmpty,
            loading: found.isLoading,
            error: found.error,
            onRetry: () => ref.invalidate(materialSearchProvider(_search)),
          );

    results = switch (_filter) {
      _ResultFilter.all => results,
      _ResultFilter.forMyProject =>
        results.where((p) => p.isInProject).toList(),
      _ResultFilter.cheapest => [
        ...results,
      ]..sort((a, b) => a.pricePerUnit.compareTo(b.pricePerUnit)),
      _ResultFilter.rating => results,
    };

    return Scaffold(
      backgroundColor: DesignTokens.backgroundLight,
      appBar: AppBar(
        backgroundColor: DesignTokens.backgroundLight,
        elevation: 0,
        title: Text(l10n.shopSearchResultsTitle, style: DesignTokens.subtitle1),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(DesignTokens.screenPaddingHorizontal),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spacingMd,
              ),
              decoration: BoxDecoration(
                color: DesignTokens.white,
                borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                border: Border.all(color: DesignTokens.borderGray),
              ),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: l10n.shopSearchHint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _controller.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close),
                          tooltip: l10n.actionClose,
                          onPressed: () => setState(() {
                            _controller.clear();
                            _debounce?.cancel();
                            _search = '';
                          }),
                        ),
                ),
                onChanged: _onQuery,
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.screenPaddingHorizontal,
              ),
              children: [
                _FilterChip(
                  label: l10n.shopFilterAll,
                  selected: _filter == _ResultFilter.all,
                  onTap: () => setState(() => _filter = _ResultFilter.all),
                ),
                _FilterChip(
                  label: l10n.shopFilterForProject,
                  selected: _filter == _ResultFilter.forMyProject,
                  onTap: () =>
                      setState(() => _filter = _ResultFilter.forMyProject),
                ),
                _FilterChip(
                  label: l10n.shopFilterCheapest,
                  selected: _filter == _ResultFilter.cheapest,
                  onTap: () => setState(() => _filter = _ResultFilter.cheapest),
                ),
                _FilterChip(
                  label: l10n.shopFilterRating,
                  selected: _filter == _ResultFilter.rating,
                  onTap: () => setState(() => _filter = _ResultFilter.rating),
                ),
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.spacingSm),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.screenPaddingHorizontal,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.shopResultCount(results.length),
                style: DesignTokens.caption.copyWith(
                  color: DesignTokens.textGray,
                ),
              ),
            ),
          ),
          Expanded(
            child: status ??
                (results.isEmpty
                    ? Center(
                        child: Text(
                          l10n.shopNoResults,
                          style: DesignTokens.bodyMedium.copyWith(
                            color: DesignTokens.textGray,
                          ),
                        ),
                      )
                    : ListView.separated(
              padding: const EdgeInsets.all(
                DesignTokens.screenPaddingHorizontal,
              ),
              itemCount: results.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: DesignTokens.spacingSm),
              itemBuilder: (context, index) =>
                  _ResultRow(product: results[index]),
            )),
          ),
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

class _ResultRow extends ConsumerWidget {
  const _ResultRow({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacingSm),
      decoration: BoxDecoration(
        color: DesignTokens.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        border: Border.all(color: DesignTokens.borderGray),
      ),
      child: Row(
        children: [
          Builder(
            builder: (context) {
              final placeholder = Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: DesignTokens.borderGrayAlt,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                ),
                child: const Icon(
                  Icons.image_outlined,
                  color: DesignTokens.textMuted,
                ),
              );
              final url = product.imageUrl;
              if (url == null) return placeholder;
              return AppImage(
                url: url,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                placeholder: placeholder,
                errorWidget: placeholder,
              );
            },
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
                        product.name,
                        style: DesignTokens.body2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (product.isInProject) ...[
                      const SizedBox(width: DesignTokens.spacingXs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: DesignTokens.primaryBlue,
                          borderRadius: BorderRadius.circular(
                            DesignTokens.radiusSm,
                          ),
                        ),
                        child: Text(
                          l10n.shopInProjectTag,
                          style: DesignTokens.caption.copyWith(
                            color: DesignTokens.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  '${formatSom(product.pricePerUnit)} / ${product.unit}',
                  style: DesignTokens.caption.copyWith(
                    color: DesignTokens.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.add_circle_outline,
              color: DesignTokens.primaryBlue,
            ),
            tooltip: l10n.a11yAddToCart,
            onPressed: () {
              final dealer = bestDealer(dealersForProduct(product));
              ref.read(cartProvider.notifier).add(product, dealer);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.shopAddedToCart)),
              );
            },
          ),
        ],
      ),
    );
  }
}
