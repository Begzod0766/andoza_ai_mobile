import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/design_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../models/shop_model.dart';
import '../../providers/orders_provider.dart';
import '../../utils/currency.dart';
import '../../widgets/common/error_view.dart';
import '../../widgets/empty_state_pattern.dart';
import '../../widgets/periodic_refresh.dart';

/// E6: Buyurtmalarim — real (session-local) order history, appended by
/// s6_checkout_screen.dart on each completed checkout. Also bound to the
/// shell's `/history` tab route — intentional: the spec has no separate
/// "history" concept, orders are the only history this app tracks.
class E6OrdersScreen extends ConsumerStatefulWidget {
  const E6OrdersScreen({super.key});

  @override
  ConsumerState<E6OrdersScreen> createState() => _E6OrdersScreenState();
}

class _E6OrdersScreenState extends ConsumerState<E6OrdersScreen> {
  OrderStep? _filter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // valueOrNull keeps the previous list while a periodic refresh reloads.
    final server = ref.watch(serverOrdersProvider);
    final local = ref.watch(ordersProvider);
    final List<ShopOrder> orders = server.valueOrNull ?? local;
    // Before the first answer: "no orders" would be a lie (the user may have
    // some), so show progress — or the error — unless local ones exist.
    final firstLoad = !server.hasValue && local.isEmpty;
    final visible = _filter == null
        ? orders
        : orders.where((o) => o.currentStep == _filter).toList();

    return Scaffold(
      backgroundColor: DesignTokens.backgroundLight,
      appBar: AppBar(
        backgroundColor: DesignTokens.backgroundLight,
        elevation: 0,
        title: Text(l10n.profileMenuOrders, style: DesignTokens.heading3),
      ),
      body: PeriodicRefresh(
        onTick: () => ref.invalidate(serverOrdersProvider),
        child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.screenPaddingHorizontal,
              vertical: DesignTokens.spacingSm,
            ),
            // Sized by its chips, so large system text doesn't clip them.
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: l10n.shopFilterAll,
                    selected: _filter == null,
                    onTap: () => setState(() => _filter = null),
                  ),
                  for (final step in [
                    OrderStep.gathering,
                    OrderStep.onTheWay,
                    OrderStep.delivered,
                  ])
                    Padding(
                      padding: const EdgeInsets.only(
                        left: DesignTokens.spacingSm,
                      ),
                      child: _FilterChip(
                        label: step.label(l10n),
                        selected: _filter == step,
                        onTap: () => setState(() => _filter = step),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: firstLoad && server.hasError
                ? ErrorView(
                    error: server.error,
                    onRetry: () => ref.invalidate(serverOrdersProvider),
                  )
                : firstLoad
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => ref.refresh(serverOrdersProvider.future),
                    child: visible.isEmpty
                        ? LayoutBuilder(
                            builder: (context, box) => ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                ConstrainedBox(
                                  constraints: BoxConstraints(minHeight: box.maxHeight),
                                  child: Padding(
                                    padding: const EdgeInsets.all(
                                      DesignTokens.screenPaddingHorizontal,
                                    ),
                                    child: Center(
                                      child: EmptyStatePattern(
                                        icon: Icons.shopping_bag_outlined,
                                        title: l10n.profileOrdersEmptyTitle,
                                        message: l10n.profileOrdersEmptyMessage,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(
                              DesignTokens.screenPaddingHorizontal,
                            ),
                            itemCount: visible.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: DesignTokens.spacingSm),
                            itemBuilder: (context, index) =>
                                _OrderCard(order: visible[index]),
                          ),
                  ),
          ),
        ],
      ),
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

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final ShopOrder order;

  Color get _statusColor => switch (order.currentStep) {
    OrderStep.accepted => DesignTokens.textGray,
    OrderStep.gathering => DesignTokens.accentOrange,
    OrderStep.onTheWay => DesignTokens.primaryBlue,
    OrderStep.delivered => DesignTokens.successGreen,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final extraCount = order.lines.length > 2 ? order.lines.length - 2 : 0;

    return Semantics(
      button: true,
      child: InkWell(
      onTap: () => context.push('/shop/s7', extra: order),
      borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(DesignTokens.spacingMd),
        decoration: BoxDecoration(
          color: DesignTokens.white,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
          border: Border.all(color: DesignTokens.borderGray),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '#${order.id.length > 8 ? order.id.substring(0, 8).toUpperCase() : order.id}',
                    style: DesignTokens.subtitle2,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.spacingSm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                  ),
                  child: Text(
                    order.currentStep.label(l10n),
                    style: DesignTokens.caption.copyWith(
                      color: _statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              '${order.createdAt.day}.${order.createdAt.month}.${order.createdAt.year}',
              style: DesignTokens.caption.copyWith(
                color: DesignTokens.textGray,
              ),
            ),
            const SizedBox(height: DesignTokens.spacingSm),
            Row(
              children: [
                for (final _ in order.lines.take(2))
                  Padding(
                    padding: const EdgeInsets.only(
                      right: DesignTokens.spacingXs,
                    ),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: DesignTokens.borderGrayAlt,
                        borderRadius: BorderRadius.circular(
                          DesignTokens.radiusSm,
                        ),
                      ),
                      child: const Icon(
                        Icons.image_outlined,
                        size: 18,
                        color: DesignTokens.textMuted,
                      ),
                    ),
                  ),
                if (extraCount > 0)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: DesignTokens.borderGrayAlt,
                      borderRadius: BorderRadius.circular(
                        DesignTokens.radiusSm,
                      ),
                    ),
                    child: Center(
                      child: Text('+$extraCount', style: DesignTokens.caption),
                    ),
                  ),
                const Spacer(),
                Text(
                  formatSom(order.total),
                  style: DesignTokens.subtitle2.copyWith(
                    color: DesignTokens.primaryBlue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
}
