import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/design_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../models/api/api.dart';
import '../../utils/error_mapper.dart';
import '../../models/shop_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/orders_provider.dart';
import '../../services/analytics_service.dart';
import '../../utils/currency.dart';
import '../../utils/phone.dart';

/// Matches a canonical UUID — used to decide whether a cart product's id is a
/// real backend material UUID (send as `material_id`) or a local/synthetic
/// slug (send null).
final _uuidRe = RegExp(
  r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
);

enum _PaymentMethod { payme, click, uzum, cash }

extension on _PaymentMethod {
  /// What the server stores: it knows only cash on delivery or a card payment.
  String get wire => this == _PaymentMethod.cash ? 'cash' : 'card';

  String get label => switch (this) {
    _PaymentMethod.payme => 'Payme',
    _PaymentMethod.click => 'Click',
    _PaymentMethod.uzum => 'Uzum Bank',
    _PaymentMethod.cash => 'Naqd (yetkazishda)',
  };

  IconData get icon => switch (this) {
    _PaymentMethod.payme => Icons.account_balance_wallet_outlined,
    _PaymentMethod.click => Icons.touch_app_outlined,
    _PaymentMethod.uzum => Icons.credit_card_outlined,
    _PaymentMethod.cash => Icons.payments_outlined,
  };
}

/// S6: To'lov — delivery address, phone, in-app payment method tiles
/// (Payme/Click/Uzum/Naqd — never an external redirect), order summary,
/// sticky "To'lash" total. No card numbers or payment credentials are
/// collected here — method selection only, per the mock-payment scope of
/// this rebuild pass.
class S6CheckoutScreen extends ConsumerStatefulWidget {
  const S6CheckoutScreen({super.key});

  @override
  ConsumerState<S6CheckoutScreen> createState() => _S6CheckoutScreenState();
}

class _S6CheckoutScreenState extends ConsumerState<S6CheckoutScreen> {
  final _addressController = TextEditingController(
    text: 'Toshkent sh., Chilonzor tumani',
  );
  final _phoneController = TextEditingController();
  _PaymentMethod _method = _PaymentMethod.payme;

  /// Set when the phone was refused, cleared as soon as it is edited.
  bool _phoneInvalid = false;
  final _phoneKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // The shop calls this number about delivery: start from the account's
    // own phone when it has one (OTP accounts do, username accounts don't).
    final auth = ref.read(authStateProvider);
    final phone = auth is AuthAuthenticated ? auth.user.phone : null;
    if (phone != null) _phoneController.text = phone;
  }
  bool _isPlacing = false;

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// Places one server order per dealer (the server refuses an order that
  /// mixes shops). Nothing is shown as placed unless the server accepted it:
  /// accepted dealers' lines leave the cart, a refused dealer's lines stay and
  /// the error is shown here. When every dealer's order is accepted the
  /// confirmation opens.
  Future<void> _placeOrder(List<CartLine> lines) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);

    // A line with no catalog id can never be priced or routed by the server.
    final unlinked = [
      for (final line in lines)
        if (!_uuidRe.hasMatch(line.product.id)) line.product.name,
    ];
    if (unlinked.isNotEmpty) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.shopCheckoutUnlinkedLines(unlinked.join(', '))),
        ),
      );
      return;
    }

    // The shop needs a number it can call, and the API refuses one that is
    // not Uzbek with a 422: say so here, by the field.
    final phone = normalizeUzPhone(_phoneController.text);
    if (phone == null) {
      setState(() => _phoneInvalid = true);
      // The field sits low in the list, and with the keyboard up its error
      // fell behind the total panel: bring both into view.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final field = _phoneKey.currentContext;
        if (field != null && field.mounted) {
          Scrollable.ensureVisible(
            field,
            alignment: 0.2,
            duration: const Duration(milliseconds: 250),
          );
        }
      });
      return;
    }

    setState(() => _isPlacing = true);
    final repo = ref.read(ordersRepositoryProvider);
    final address = _addressController.text.trim();
    final method = _method.wire;

    final byDealer = <String, List<CartLine>>{};
    for (final line in lines) {
      byDealer.putIfAbsent(line.dealer.id, () => []).add(line);
    }

    final analytics = ref.read(analyticsProvider);
    final created = <ServerOrder>[];
    String? failedDealer;
    Object? failure;
    for (final dealerLines in byDealer.values) {
      final dealer = dealerLines.first.dealer;
      try {
        final order = await repo.createOrder(
          dealerName: dealer.name,
          deliveryAddress: address.isEmpty ? null : address,
          phone: phone,
          paymentMethod: method,
          lines: [
            for (final line in dealerLines)
              OrderLineCreate(
                materialId: line.product.id,
                productName: line.product.name,
                unit: line.product.unit,
                unitPriceUzs: line.dealer.pricePerUnit,
                quantity: line.quantity,
              ),
          ],
        );
        created.add(order);
        // One order per dealer: log each one the server accepted.
        analytics.orderPlaced(dealerLines.length);
        final cart = ref.read(cartProvider.notifier);
        for (final line in dealerLines) {
          cart.remove(line.product.id, line.dealer.id);
        }
      } catch (e) {
        failedDealer ??= dealer.name;
        failure ??= e;
      }
    }

    if (created.isNotEmpty) ref.invalidate(serverOrdersProvider);
    if (!mounted) return;
    setState(() => _isPlacing = false);

    if (failure != null) {
      final message = mapErrorWithServerDetail(failure);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            created.isEmpty
                ? l10n.shopOrderSaveError(message)
                : l10n.shopOrderPartial(failedDealer!, message),
          ),
        ),
      );
      return;
    }
    if (created.length == 1) {
      context.push('/shop/s7', extra: serverOrderToShopOrder(created.first));
    } else {
      context.go('/history');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lines = ref.watch(cartProvider);
    final grouped = ref.watch(cartByDealerProvider);
    final materialsTotal = cartMaterialsTotal(lines);
    final deliveryTotal = grouped.keys.fold<int>(
      0,
      (sum, dealer) => sum + deliveryFeeFor(dealer),
    );
    final grandTotal = materialsTotal + deliveryTotal;

    return Scaffold(
      backgroundColor: DesignTokens.backgroundLight,
      appBar: AppBar(
        backgroundColor: DesignTokens.backgroundLight,
        elevation: 0,
        title: Text(l10n.shopCheckoutTitle, style: DesignTokens.heading3),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(
                DesignTokens.screenPaddingHorizontal,
              ),
              children: [
                Text(l10n.shopDeliveryAddress, style: DesignTokens.subtitle2),
                const SizedBox(height: DesignTokens.spacingSm),
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: DesignTokens.borderGrayAlt,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.map_outlined,
                      color: DesignTokens.textMuted,
                      size: DesignTokens.iconXl,
                    ),
                  ),
                ),
                const SizedBox(height: DesignTokens.spacingSm),
                TextField(
                  controller: _addressController,
                  decoration: InputDecoration(hintText: l10n.shopAddressHint),
                ),
                const SizedBox(height: DesignTokens.spacingSm),
                TextField(
                  key: _phoneKey,
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  onChanged: (_) {
                    if (_phoneInvalid) setState(() => _phoneInvalid = false);
                  },
                  decoration: InputDecoration(
                    hintText: l10n.shopPhoneHint,
                    errorText: _phoneInvalid ? l10n.phoneErrorInvalid : null,
                    errorMaxLines: 2,
                  ),
                ),
                const SizedBox(height: DesignTokens.spacingLg),
                Text(l10n.shopPaymentMethod, style: DesignTokens.subtitle2),
                const SizedBox(height: DesignTokens.spacingSm),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: DesignTokens.spacingSm,
                  crossAxisSpacing: DesignTokens.spacingSm,
                  childAspectRatio: 2.4,
                  children: [
                    for (final method in _PaymentMethod.values)
                      _PaymentTile(
                        method: method,
                        selected: _method == method,
                        onTap: () => setState(() => _method = method),
                      ),
                  ],
                ),
                const SizedBox(height: DesignTokens.spacingLg),
                Text(l10n.shopOrderSummary, style: DesignTokens.subtitle2),
                const SizedBox(height: DesignTokens.spacingSm),
                Container(
                  padding: const EdgeInsets.all(DesignTokens.spacingMd),
                  decoration: BoxDecoration(
                    color: DesignTokens.white,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                    border: Border.all(color: DesignTokens.borderGray),
                  ),
                  child: Column(
                    children: [
                      _Row(
                        label: l10n.shopMaterials,
                        value: formatSom(materialsTotal),
                      ),
                      const SizedBox(height: DesignTokens.spacingXs),
                      _Row(
                        label: l10n.shopDelivery,
                        value: formatSom(deliveryTotal),
                      ),
                    ],
                  ),
                ),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.shopAmountDue, style: DesignTokens.subtitle1),
                      Text(
                        formatSom(grandTotal),
                        style: DesignTokens.heading3.copyWith(
                          color: DesignTokens.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.spacingMd),
                  SizedBox(
                    height: DesignTokens.buttonHeightLarge,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignTokens.accentOrange,
                      ),
                      onPressed: _isPlacing || lines.isEmpty
                          ? null
                          : () => _placeOrder(lines),
                      child: _isPlacing
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: DesignTokens.white,
                              ),
                            )
                          : Text(l10n.shopPay),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  final _PaymentMethod method;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingSm),
        decoration: BoxDecoration(
          color: selected
              ? DesignTokens.primaryBlue.withValues(alpha: 0.08)
              : DesignTokens.white,
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          border: Border.all(
            color: selected
                ? DesignTokens.primaryBlue
                : DesignTokens.borderGray,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              method.icon,
              color: selected
                  ? DesignTokens.primaryBlue
                  : DesignTokens.textGray,
            ),
            const SizedBox(width: DesignTokens.spacingSm),
            Expanded(
              child: Text(
                method.label,
                style: DesignTokens.caption.copyWith(
                  color: selected
                      ? DesignTokens.primaryBlue
                      : DesignTokens.textDark,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: DesignTokens.body2.copyWith(color: DesignTokens.textGray),
        ),
        Text(value, style: DesignTokens.body2),
      ],
    );
  }
}
