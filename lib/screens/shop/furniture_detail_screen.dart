import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/design_tokens.dart';
import '../../features/moderation/report_repository.dart';
import '../../features/moderation/report_sheet.dart';
import '../../l10n/app_localizations.dart';
import '../../models/api/api.dart';
import '../../providers/apartment_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../utils/currency.dart';
import '../../widgets/common/error_view.dart';
import '../studio/studio_webview_screen.dart';
import 'furniture_card.dart';

/// A shop's piece of furniture: picture, price, size, the shop selling it, and
/// "Xonamga qo'yish" — which opens one of the user's rooms in the Studio with
/// this model already placed (the web studio's `?place=`).
///
/// [initial] is the item as the list that opened the page had it; without one
/// (a deep link) the page fetches it by [id].
class FurnitureDetailScreen extends ConsumerWidget {
  const FurnitureDetailScreen({required this.id, this.initial, super.key});

  final String id;
  final Furniture? initial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final initial = this.initial;
    if (initial != null) return _FurnitureView(item: initial);
    return ref
        .watch(furnitureItemProvider(id))
        .when(
          data: (item) => _FurnitureView(item: item),
          loading: () => Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Scaffold(
            appBar: AppBar(),
            body: ErrorView(
              error: e,
              title: l10n.furnitureLoadFailed,
              onRetry: () => ref.invalidate(furnitureItemProvider(id)),
            ),
          ),
        );
  }
}

class _FurnitureView extends StatelessWidget {
  const _FurnitureView({required this.item});

  final Furniture item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final price = item.priceUzs;
    final size = furnitureSizeLabel(item);
    final storeId = item.storeId;
    return Scaffold(
      backgroundColor: DesignTokens.backgroundLight,
      appBar: AppBar(
        backgroundColor: DesignTokens.backgroundLight,
        elevation: 0,
        title: Text(item.nameUz, style: DesignTokens.subtitle1),
        actions: [
          // App Store guideline 1.2: shops publish these, so others can report them.
          PopupMenuButton<ReportTarget>(
            icon: const Icon(Icons.more_vert),
            onSelected: (target) =>
                showReportSheet(context, target: target, targetId: item.id),
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
                  child: FurniturePicture(
                    url: item.thumbnailUrl,
                    radius: DesignTokens.radiusLg,
                  ),
                ),
                const SizedBox(height: DesignTokens.spacingMd),
                Text(item.nameUz, style: DesignTokens.heading3),
                const SizedBox(height: DesignTokens.spacingXs),
                Text(
                  price == null ? l10n.shopFurnitureNoPrice : formatSom(price),
                  style: DesignTokens.heading3.copyWith(
                    color: DesignTokens.primaryBlue,
                  ),
                ),
                if (size != null) ...[
                  const SizedBox(height: DesignTokens.spacingMd),
                  Row(
                    children: [
                      Text(
                        l10n.furnitureSize,
                        style: DesignTokens.body2.copyWith(
                          color: DesignTokens.textGray,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        l10n.furnitureSizeValue(size),
                        style: DesignTokens.body2,
                      ),
                    ],
                  ),
                ],
                if (storeId != null) ...[
                  const SizedBox(height: DesignTokens.spacingLg),
                  StoreLinkRow(storeId: storeId, storeName: item.storeName),
                ],
                if (item.glbUrl == null) ...[
                  const SizedBox(height: DesignTokens.spacingLg),
                  Text(
                    l10n.furnitureNoModel,
                    style: DesignTokens.body2.copyWith(
                      color: DesignTokens.textGray,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (item.glbUrl != null)
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
                  child: FilledButton.icon(
                    onPressed: () => _placeInRoom(context),
                    icon: const Icon(Icons.view_in_ar_outlined),
                    label: Text(l10n.furniturePlaceInRoom),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _placeInRoom(BuildContext context) async {
    final roomId = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      builder: (_) => const _RoomPickerSheet(),
    );
    if (roomId == null || !context.mounted) return;
    context.push(studioRoomPath(roomId, place: item.id));
  }
}

/// "W × D × H" in centimetres from what the catalog knows, or null when it
/// knows no footprint.
String? furnitureSizeLabel(Furniture item) {
  final w = item.footprintW;
  final d = item.footprintD;
  if (w == null || d == null) return null;
  final h = item.heightCm;
  return [w, d, ?h].map(formatQuantity).join(' × ');
}

/// The row that opens a shop's page ("Mebel Plus do'koni").
class StoreLinkRow extends StatelessWidget {
  const StoreLinkRow({required this.storeId, this.storeName, super.key});

  final String storeId;
  final String? storeName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final name = storeName;
    return Semantics(
      button: true,
      child: InkWell(
        onTap: () => context.push('/shop/store/$storeId'),
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(DesignTokens.spacingMd),
          decoration: BoxDecoration(
            color: DesignTokens.white,
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
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
                  name == null ? l10n.navShop : l10n.storePageOpen(name),
                  style: DesignTokens.body2,
                ),
              ),
              const Icon(Icons.chevron_right, color: DesignTokens.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

/// Picks the room to place the furniture in; pops with its id.
class _RoomPickerSheet extends ConsumerWidget {
  const _RoomPickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: ref
          .watch(apartmentsProvider)
          .when(
            loading: () => const Padding(
              padding: EdgeInsets.all(DesignTokens.spacingXl),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => ErrorView(
              error: e,
              onRetry: () => ref.invalidate(apartmentsProvider),
            ),
            data: (apartments) {
              final rooms = [
                for (final apt in apartments)
                  for (final room in apt.rooms) (apt, room),
              ];
              return ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(
                  DesignTokens.screenPaddingHorizontal,
                  0,
                  DesignTokens.screenPaddingHorizontal,
                  DesignTokens.spacingMd,
                ),
                children: [
                  Text(l10n.furniturePickRoom, style: DesignTokens.heading3),
                  const SizedBox(height: DesignTokens.spacingMd),
                  if (rooms.isEmpty)
                    Text(l10n.furnitureNoRooms, style: DesignTokens.body2)
                  else
                    for (final (apt, room) in rooms)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.meeting_room_outlined),
                        title: Text(room.name, style: DesignTokens.subtitle2),
                        subtitle: Text(apt.name),
                        onTap: () => Navigator.of(context).pop(room.id),
                      ),
                ],
              );
            },
          ),
    );
  }
}
