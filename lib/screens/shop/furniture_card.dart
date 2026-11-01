import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/design_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../models/api/api.dart';
import '../../utils/currency.dart';
import '../../widgets/common/app_image.dart';

/// A shop's piece of furniture (one of its 3D models) as a card: picture,
/// name, shop and price. Opens the furniture's page. Shared by the shop home's
/// "Mebel" rail and a shop's own page.
class FurnitureCard extends StatelessWidget {
  const FurnitureCard({required this.item, this.showStore = true, super.key});

  final Furniture item;

  /// Off on the shop's own page, where every card is that shop's.
  final bool showStore;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final price = item.priceUzs;
    return Semantics(
      button: true,
      child: InkWell(
        onTap: () => context.push('/shop/furniture/${item.id}', extra: item),
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
                  url: item.thumbnailUrl,
                  radius: DesignTokens.radiusSm,
                ),
              ),
              const SizedBox(height: DesignTokens.spacingSm),
              Text(
                item.nameUz,
                style: DesignTokens.body2.copyWith(
                  color: DesignTokens.textDark,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (showStore && item.storeName != null)
                Text(
                  item.storeName!,
                  style: DesignTokens.caption.copyWith(
                    color: DesignTokens.textGray,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              const Spacer(),
              Text(
                price == null ? l10n.shopFurnitureNoPrice : formatSom(price),
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

/// A furniture's picture, or a neutral placeholder when it has none.
class FurniturePicture extends StatelessWidget {
  const FurniturePicture({required this.url, required this.radius, super.key});

  final String? url;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      decoration: BoxDecoration(
        color: DesignTokens.borderGrayAlt,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: const Icon(Icons.chair_outlined, color: DesignTokens.textMuted),
    );
    final url = this.url;
    if (url == null || url.isEmpty) return placeholder;
    return AppImage(
      url: url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      borderRadius: BorderRadius.circular(radius),
      placeholder: placeholder,
      errorWidget: placeholder,
    );
  }
}
