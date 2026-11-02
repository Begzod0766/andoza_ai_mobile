import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/design_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../models/business_profile.dart';
import '../../providers/business_provider.dart';
import 'business_labels.dart';

/// "Biznesim": the account's shop and/or usta profile with where each stands
/// with the admins, a way to resubmit a rejected one, and a way to add the
/// business the account does not have yet. What a shop or usta can then *do*
/// (products, customer requests) is built on top of an approved profile.
class BusinessScreen extends ConsumerWidget {
  const BusinessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final roles = ref.watch(accountRolesProvider).valueOrNull ?? AccountRoles.plainUser;
    return Scaffold(
      backgroundColor: DesignTokens.backgroundLight,
      appBar: AppBar(
        backgroundColor: DesignTokens.backgroundLight,
        elevation: 0,
        leading: IconButton(
          tooltip: AppLocalizations.of(context)!.actionBack,
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/profile'),
        ),
        title: Text(l10n.businessTitle, style: DesignTokens.heading3),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(accountRolesProvider);
          ref.invalidate(myShopProvider);
          ref.invalidate(myUstaProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(DesignTokens.screenPaddingHorizontal),
          children: [
            if (roles.isShopOwner) const _ShopCard(),
            if (roles.isUsta) const _UstaCard(),
            const SizedBox(height: DesignTokens.spacingMd),
            if (!roles.isShopOwner)
              _AddButton(
                icon: Icons.storefront_outlined,
                label: l10n.businessApplyShopTitle,
                onTap: () => context.push('/business/apply/shop'),
              ),
            if (!roles.isUsta)
              _AddButton(
                icon: Icons.handyman_outlined,
                label: l10n.businessApplyUstaTitle,
                onTap: () => context.push('/business/apply/usta'),
              ),
          ],
        ),
      ),
    );
  }
}

class _ShopCard extends ConsumerWidget {
  const _ShopCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return ref.watch(myShopProvider).when(
          loading: () => const _CardShell.loading(),
          error: (_, _) => _CardShell.message(l10n.businessLoadFailed),
          data: (shop) {
            if (shop == null) return const SizedBox.shrink();
            final newInquiries = ref.watch(myStatsProvider).valueOrNull?.inquiriesNew ?? 0;
            return _CardShell(
              icon: Icons.storefront_outlined,
              section: l10n.businessShopSection,
              name: shop.name,
              status: shop.status,
              note: shop.moderationNote,
              onResubmit: () async {
                await ref.read(businessRepositoryProvider).resubmitShop();
                ref.invalidate(myShopProvider);
                ref.invalidate(accountRolesProvider);
              },
              approvedFooter: l10n.shopProductsOpen,
              onApprovedTap: () => context.push('/business/products'),
              extraActionLabel: l10n.ustaEditOpen,
              onExtraAction: () => context.push('/business/shop/edit'),
              extraButtons: [
                TextButton.icon(
                  onPressed: () => context.push('/business/inquiries'),
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: Text(newInquiries > 0
                      ? l10n.shopInquiriesOpenWithNew(newInquiries)
                      : l10n.shopInquiriesOpen),
                ),
                TextButton.icon(
                  onPressed: () => context.push('/business/orders'),
                  icon: const Icon(Icons.local_shipping_outlined),
                  label: Text(l10n.shopOrdersOpen),
                ),
                TextButton.icon(
                  onPressed: () => context.push('/business/stats'),
                  icon: const Icon(Icons.insights_outlined),
                  label: Text(l10n.shopStatsOpen),
                ),
              ],
            );
          },
        );
  }
}

class _UstaCard extends ConsumerWidget {
  const _UstaCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return ref.watch(myUstaProvider).when(
          loading: () => const _CardShell.loading(),
          error: (_, _) => _CardShell.message(l10n.businessLoadFailed),
          data: (usta) {
            if (usta == null) return const SizedBox.shrink();
            final trade = usta.trade == null ? null : tradeLabel(l10n, usta.trade!);
            return _CardShell(
              icon: Icons.handyman_outlined,
              section: l10n.businessUstaSection,
              name: trade == null ? usta.name : '${usta.name} · $trade',
              status: usta.status,
              note: usta.moderationNote,
              onResubmit: () async {
                await ref.read(businessRepositoryProvider).resubmitUsta();
                ref.invalidate(myUstaProvider);
                ref.invalidate(accountRolesProvider);
              },
              approvedFooter: l10n.ustaLeadsOpen,
              onApprovedTap: () => context.push('/business/leads'),
              extraActionLabel: l10n.ustaEditOpen,
              onExtraAction: () => context.push('/business/usta/edit'),
              extraButtons: [
                TextButton.icon(
                  onPressed: () => context.push('/business/portfolio'),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(l10n.ustaPortfolioOpen),
                ),
              ],
            );
          },
        );
  }
}

class _CardShell extends StatefulWidget {
  const _CardShell({
    required IconData this.icon,
    required String this.section,
    required String this.name,
    required ModerationStatus this.status,
    required this.note,
    required Future<void> Function() this.onResubmit,
    required String this.approvedFooter,
    this.onApprovedTap,
    this.extraActionLabel,
    this.onExtraAction,
    this.extraButtons = const [],
  })  : _loading = false,
        _message = null;

  const _CardShell.loading()
      : icon = null,
        section = null,
        name = null,
        status = null,
        note = null,
        onResubmit = null,
        approvedFooter = null,
        onApprovedTap = null,
        extraActionLabel = null,
        onExtraAction = null,
        extraButtons = const [],
        _loading = true,
        _message = null;

  const _CardShell.message(String this._message)
      : icon = null,
        section = null,
        name = null,
        status = null,
        note = null,
        onResubmit = null,
        approvedFooter = null,
        onApprovedTap = null,
        extraActionLabel = null,
        onExtraAction = null,
        extraButtons = const [],
        _loading = false;

  final IconData? icon;
  final String? section;
  final String? name;
  final ModerationStatus? status;
  final String? note;
  final Future<void> Function()? onResubmit;
  final String? approvedFooter;
  final VoidCallback? onApprovedTap;
  final String? extraActionLabel;
  final VoidCallback? onExtraAction;
  final List<Widget> extraButtons;
  final bool _loading;
  final String? _message;

  @override
  State<_CardShell> createState() => _CardShellState();
}

class _CardShellState extends State<_CardShell> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final decoration = BoxDecoration(
      color: DesignTokens.white,
      borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
      border: Border.all(color: DesignTokens.border),
    );
    const pad = EdgeInsets.all(DesignTokens.spacingMd);
    final margin = const EdgeInsets.only(bottom: DesignTokens.spacingMd);

    if (widget._loading) {
      return Container(
        margin: margin,
        padding: pad,
        decoration: decoration,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (widget._message != null) {
      return Container(
        margin: margin,
        padding: pad,
        decoration: decoration,
        child: Text(widget._message!, style: DesignTokens.body2),
      );
    }

    final status = widget.status!;
    final (Color chipColor, String hint) = switch (status) {
      ModerationStatus.pending => (const Color(0xFFB45309), l10n.businessPendingHint),
      ModerationStatus.approved => (DesignTokens.successGreen, l10n.businessApprovedHint),
      ModerationStatus.rejected => (DesignTokens.errorRed, ''),
    };
    return Container(
      margin: margin,
      padding: pad,
      decoration: decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(widget.icon, color: DesignTokens.textGray),
              const SizedBox(width: DesignTokens.spacingSm),
              Expanded(
                child: Text(widget.section!,
                    style: DesignTokens.caption.copyWith(color: DesignTokens.textGray)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: chipColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                ),
                child: Text(
                  statusLabel(l10n, status),
                  style: DesignTokens.caption.copyWith(color: chipColor, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacingSm),
          Text(widget.name!, style: DesignTokens.subtitle2),
          const SizedBox(height: DesignTokens.spacingXs),
          if (status == ModerationStatus.rejected) ...[
            if (widget.note != null && widget.note!.isNotEmpty)
              Text(l10n.businessRejectedReason(widget.note!),
                  style: DesignTokens.body2.copyWith(color: DesignTokens.errorText)),
            const SizedBox(height: DesignTokens.spacingSm),
            OutlinedButton(
              onPressed: _busy
                  ? null
                  : () async {
                      setState(() => _busy = true);
                      try {
                        await widget.onResubmit!();
                      } finally {
                        if (mounted) setState(() => _busy = false);
                      }
                    },
              child: Text(l10n.businessResubmit),
            ),
          ] else
            Text(hint, style: DesignTokens.body2.copyWith(color: DesignTokens.textGray)),
          if (status == ModerationStatus.approved) ...[
            const SizedBox(height: DesignTokens.spacingSm),
            if (widget.onApprovedTap != null) ...[
              FilledButton.tonalIcon(
                onPressed: widget.onApprovedTap,
                icon: Icon(widget.onExtraAction == null ? Icons.inventory_2_outlined : Icons.inbox_outlined),
                label: Text(widget.approvedFooter!),
              ),
              if (widget.onExtraAction != null)
                TextButton.icon(
                  onPressed: widget.onExtraAction,
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(widget.extraActionLabel!),
                ),
              if (widget.extraButtons.isNotEmpty)
                Wrap(spacing: DesignTokens.spacingSm, children: widget.extraButtons),
            ]
            else
              Text(widget.approvedFooter!,
                  style: DesignTokens.caption.copyWith(color: DesignTokens.textMuted)),
          ],
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: DesignTokens.spacingSm),
        child: OutlinedButton.icon(
          onPressed: onTap,
          icon: Icon(icon),
          label: Text(label),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            alignment: Alignment.centerLeft,
          ),
        ),
      );
}
