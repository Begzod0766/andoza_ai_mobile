import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/design_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../models/business_profile.dart';
import '../../providers/business_provider.dart';
import 'business_labels.dart';
import '../../widgets/common/app_image.dart';
import 'style_chips.dart';

/// "Mahsulotlarim": the shop's own 3D models in every moderation status, with
/// the few things an owner may change on a phone — name, price, hiding an
/// approved model from the catalog, deleting. New ones are made from a photo (AddProductScreen).
class ShopProductsScreen extends ConsumerWidget {
  const ShopProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: DesignTokens.backgroundLight,
      appBar: AppBar(
        backgroundColor: DesignTokens.backgroundLight,
        elevation: 0,
        leading: IconButton(
          tooltip: AppLocalizations.of(context)!.actionBack,
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/business'),
        ),
        title: Text(l10n.shopProductsTitle, style: DesignTokens.heading3),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/business/products/new');
          ref.invalidate(myProductsProvider);
        },
        icon: const Icon(Icons.add_a_photo_outlined),
        label: Text(l10n.addProductTitle),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(myProductsProvider),
        child: ref.watch(myProductsProvider).when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => ListView(children: [
                Padding(
                  padding: const EdgeInsets.all(DesignTokens.spacingLg),
                  child: Text(l10n.businessLoadFailed, textAlign: TextAlign.center),
                ),
              ]),
              data: (items) => items.isEmpty
                  ? ListView(children: [
                      Padding(
                        padding: const EdgeInsets.all(DesignTokens.spacingLg),
                        child: Text(l10n.shopProductsEmpty,
                            textAlign: TextAlign.center,
                            style: DesignTokens.body2.copyWith(color: DesignTokens.textGray)),
                      ),
                    ])
                  : ListView.separated(
                      padding: const EdgeInsets.all(DesignTokens.screenPaddingHorizontal),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: DesignTokens.spacingSm),
                      itemBuilder: (_, i) => _ProductTile(product: items[i]),
                    ),
            ),
      ),
    );
  }
}

class _ProductTile extends ConsumerWidget {
  const _ProductTile({required this.product});

  final ShopProduct product;

  Future<void> _run(BuildContext context, WidgetRef ref, Future<void> Function() action) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
      ref.invalidate(myProductsProvider);
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.shopProductFailed)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.read(businessRepositoryProvider);
    final approved = product.status == ModerationStatus.approved;
    final chipColor = switch (product.status) {
      ModerationStatus.approved => DesignTokens.successGreen,
      ModerationStatus.rejected => DesignTokens.errorRed,
      ModerationStatus.pending => DesignTokens.accentOrange,
    };
    return Material(
      color: DesignTokens.white,
      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        onTap: () => _edit(context, ref),
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.spacingSm),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: product.thumbnailUrl == null
                      ? const ColoredBox(
                          color: DesignTokens.backgroundLight,
                          child: Icon(Icons.chair_alt_outlined, color: DesignTokens.textMuted),
                        )
                      : AppImage(
                          url: product.thumbnailUrl!,
                          width: 56,
                          height: 56,
                          placeholder: const ColoredBox(color: DesignTokens.backgroundLight),
                          errorWidget: const ColoredBox(
                            color: DesignTokens.backgroundLight,
                            child: Icon(Icons.chair_alt_outlined, color: DesignTokens.textMuted),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: DesignTokens.spacingSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name,
                        maxLines: 1, overflow: TextOverflow.ellipsis, style: DesignTokens.subtitle2),
                    const SizedBox(height: 2),
                    Text(
                      product.priceUzs == null ? l10n.shopProductNoPrice : _uzs(product.priceUzs!),
                      style: DesignTokens.body2.copyWith(color: DesignTokens.textGray),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusLabel(l10n, product.status),
                      style: DesignTokens.caption.copyWith(color: chipColor, fontWeight: FontWeight.w700),
                    ),
                    if (product.status == ModerationStatus.rejected &&
                        (product.moderationNote ?? '').isNotEmpty)
                      Text(l10n.businessRejectedReason(product.moderationNote!),
                          style: DesignTokens.caption.copyWith(color: DesignTokens.errorRed)),
                  ],
                ),
              ),
              if (approved)
                Semantics(
                  label: l10n.shopProductVisible,
                  child: Switch(
                    value: product.isActive,
                    onChanged: (v) =>
                        _run(context, ref, () => repo.updateProduct(product.id, isActive: v)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.read(businessRepositoryProvider);
    final name = TextEditingController(text: product.name);
    final price = TextEditingController(text: product.priceUzs?.toString() ?? '');
    var styles = product.styles;
    final action = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            DesignTokens.screenPaddingHorizontal, 0, DesignTokens.screenPaddingHorizontal,
            MediaQuery.of(ctx).viewInsets.bottom + DesignTokens.spacingLg),
        // Scrolls: with the style chips the sheet can outgrow a small screen
        // once the keyboard is up.
        child: SingleChildScrollView(
          child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.shopProductEdit, style: DesignTokens.heading3),
            const SizedBox(height: DesignTokens.spacingMd),
            TextField(controller: name, decoration: InputDecoration(labelText: l10n.shopProductName)),
            const SizedBox(height: DesignTokens.spacingSm),
            TextField(
              controller: price,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.shopProductPrice),
            ),
            const SizedBox(height: DesignTokens.spacingMd),
            StatefulBuilder(
              builder: (ctx, setSheet) => StyleChips(
                value: styles,
                onChanged: (v) => setSheet(() => styles = v),
              ),
            ),
            const SizedBox(height: DesignTokens.spacingMd),
            FilledButton(
                onPressed: () => Navigator.of(ctx).pop('save'), child: Text(l10n.shopProductSave)),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop('delete'),
              style: TextButton.styleFrom(foregroundColor: DesignTokens.errorRed),
              child: Text(l10n.shopProductDelete),
            ),
          ],
          ),
        ),
      ),
    );
    if (!context.mounted || action == null) return;
    if (action == 'save') {
      final newName = name.text.trim();
      final newPrice = int.tryParse(price.text.trim());
      await _run(
        context,
        ref,
        () => repo.updateProduct(
          product.id,
          name: newName.isEmpty || newName == product.name ? null : newName,
          priceUzs: newPrice == product.priceUzs ? null : newPrice,
          // Sent only when changed: [] clears them, an absent field leaves them.
          styles: _sameStyles(styles, product.styles) ? null : styles,
        ),
      );
    } else {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          content: Text(l10n.shopProductDeleteConfirm),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(false), child: Text(l10n.shopProductCancel)),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: TextButton.styleFrom(foregroundColor: DesignTokens.errorRed),
              child: Text(l10n.shopProductDelete),
            ),
          ],
        ),
      );
      if (ok == true && context.mounted) {
        await _run(context, ref, () => repo.deleteProduct(product.id));
      }
    }
  }
}

String _uzs(int v) {
  final s = v.toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(' ');
    b.write(s[i]);
  }
  return "$b so'm";
}

bool _sameStyles(List<String> a, List<String> b) =>
    a.length == b.length && a.every(b.contains);
