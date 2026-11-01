import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/design_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../models/shop_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/shop_provider.dart';
import '../../utils/currency.dart';
import '../../widgets/common/app_image.dart';
import '../../widgets/common/load_status.dart';
import 'furniture_card.dart';

/// S1: Do'kon bosh — search, project-linked banner ("SIZNING
/// LOYIHANGIZ"), category chips, 2-col product grid with "Loyihada" tags
/// for items the active project actually needs.
class S1ShopHomeScreen extends ConsumerStatefulWidget {
  const S1ShopHomeScreen({super.key});

  @override
  ConsumerState<S1ShopHomeScreen> createState() => _S1ShopHomeScreenState();
}

class _S1ShopHomeScreenState extends ConsumerState<S1ShopHomeScreen> {
  ShopCategory? _filter;
  // What the server is asked for: the typed text, once typing pauses.
  String _search = '';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onQuery(String text) {
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
    final source = found == null ? catalog : (found.valueOrNull ?? const <Product>[]);
    final status = found == null
        ? loadStatus(
            isEmpty: catalog.isEmpty,
            loading: ref.watch(shopCatalogLoadingProvider),
            error: ref.watch(shopCatalogErrorProvider),
            onRetry: () => shopCatalogSources.forEach(ref.invalidate),
          )
        : loadStatus(
            isEmpty: source.isEmpty,
            loading: found.isLoading,
            error: found.error,
            onRetry: () => ref.invalidate(materialSearchProvider(_search)),
          );
    final cartCount = ref.watch(cartLineCountProvider);
    final projectItems = catalog.where((p) => p.isInProject).toList();

    final products =
        source.where((p) => _filter == null || p.category == _filter).toList();

    return Scaffold(
      backgroundColor: DesignTokens.backgroundLight,
      appBar: AppBar(
        backgroundColor: DesignTokens.backgroundLight,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(l10n.navShop, style: DesignTokens.heading3),
        actions: [
          // Replaces the old full-width "Loyihangiz uchun" banner — same
          // destination (S2's stage-grouped materials checklist), but as a
          // compact header icon+badge so the product grid gets the space
          // back instead of a banner repeating what the badge already says.
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.grid_view_rounded),
                tooltip: l10n.shopMaterialsTitle,
                onPressed: () => context.push('/shop/s2'),
              ),
              if (projectItems.isNotEmpty)
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: DesignTokens.primaryBlue,
                      borderRadius: BorderRadius.circular(
                        DesignTokens.radiusFull,
                      ),
                      border: Border.all(
                        color: DesignTokens.backgroundLight,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      '${projectItems.length}',
                      style: const TextStyle(
                        color: DesignTokens.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                tooltip: l10n.shopCartTooltip,
                onPressed: () => context.push('/shop/s5'),
              ),
              if (cartCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: const BoxDecoration(
                      color: DesignTokens.accentOrange,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$cartCount',
                      style: const TextStyle(
                        color: DesignTokens.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: DesignTokens.spacingSm),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(DesignTokens.screenPaddingHorizontal),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spacingMd,
            ),
            decoration: BoxDecoration(
              color: DesignTokens.white,
              borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
              boxShadow: const [DesignTokens.shadowCard],
            ),
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: l10n.shopSearchHint,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: _onQuery,
              onSubmitted: (value) =>
                  context.push('/shop/search', extra: value),
            ),
          ),
          const SizedBox(height: DesignTokens.spacingLg),
          SizedBox(
            height: 40,
            child: ShaderMask(
              shaderCallback: (bounds) {
                return const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Colors.black, Colors.black, Colors.transparent],
                  stops: [0.0, 0.88, 1.0],
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstIn,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _CategoryChip(
                    label: l10n.shopFilterAll,
                    selected: _filter == null,
                    onTap: () => setState(() => _filter = null),
                  ),
                  for (final category in ShopCategory.values)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: DesignTokens.spacingSm,
                      ),
                      child: _CategoryChip(
                        label: category.label(l10n),
                        selected: _filter == category,
                        onTap: () => setState(() => _filter = category),
                      ),
                    ),
                  // Trailing spacer so the gradient fades over blank space
                  // rather than clipping the last chip's text.
                  const SizedBox(width: DesignTokens.spacingMd),
                ],
              ),
            ),
          ),
          const SizedBox(height: DesignTokens.spacingLg),
          // Shops' own furniture (3D models). Not one of the material
          // categories, so it shows under "Barchasi" only.
          if (_filter == null) _FurnitureRail(query: _search),
          if (status != null)
            status
          else if (products.isEmpty)
            Padding(
              padding: const EdgeInsets.all(DesignTokens.spacingXl),
              child: Text(
                l10n.shopNoResults,
                textAlign: TextAlign.center,
                style: DesignTokens.bodyMedium.copyWith(
                  color: DesignTokens.textGray,
                ),
              ),
            )
          else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: DesignTokens.spacingMd,
              crossAxisSpacing: DesignTokens.spacingMd,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (context, index) {
              final product = products[index];
              return _ProductCard(
                product: product,
                onTap: () => context.push('/shop/s3', extra: product),
              );
            },
          ),
        ],
      ),
    );
  }
}


/// "Mebel": a horizontal rail of the shops' furniture, matching the search
/// box. Hidden while it loads, on an error and when there is none — the
/// materials below are the screen's main content and keep their own states.
class _FurnitureRail extends ConsumerWidget {
  const _FurnitureRail({required this.query});

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final items = (query.isEmpty
                ? ref.watch(furnitureProvider(null))
                : ref.watch(furnitureSearchProvider(query)))
            .valueOrNull ??
        const [];
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.shopFurnitureSection, style: DesignTokens.heading3),
        const SizedBox(height: DesignTokens.spacingMd),
        SizedBox(
          height: 244,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, _) =>
                const SizedBox(width: DesignTokens.spacingMd),
            itemBuilder: (context, index) =>
                SizedBox(width: 160, child: FurnitureCard(item: items[index])),
          ),
        ),
        const SizedBox(height: DesignTokens.spacingLg),
        Text(l10n.shopMaterials, style: DesignTokens.heading3),
        const SizedBox(height: DesignTokens.spacingMd),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      backgroundColor: DesignTokens.white,
      selectedColor: DesignTokens.primaryBlue,
      labelStyle: DesignTokens.caption.copyWith(
        color: selected ? DesignTokens.white : DesignTokens.textDark,
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      button: true,
      child: InkWell(
      onTap: onTap,
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
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.3,
                  child: Builder(
                    builder: (context) {
                      final placeholder = Container(
                        decoration: BoxDecoration(
                          color: DesignTokens.borderGrayAlt,
                          borderRadius: BorderRadius.circular(
                            DesignTokens.radiusSm,
                          ),
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
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        borderRadius: BorderRadius.circular(
                          DesignTokens.radiusSm,
                        ),
                        placeholder: placeholder,
                        errorWidget: placeholder,
                      );
                    },
                  ),
                ),
                if (product.isInProject)
                  Positioned(
                    left: 4,
                    top: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
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
                  ),
              ],
            ),
            const SizedBox(height: DesignTokens.spacingSm),
            Text(
              product.name,
              style: DesignTokens.body2.copyWith(color: DesignTokens.textDark),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              product.brand,
              style: DesignTokens.caption.copyWith(
                color: DesignTokens.textGray,
              ),
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
