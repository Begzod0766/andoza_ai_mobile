import 'package:riverpod/riverpod.dart';
import '../models/shop_model.dart';

/// The most of one product a single order line may ask for; the API refuses
/// more with a 422 (`OrderLineCreate.quantity`, le=100 000), so the cart never
/// holds more than that.
const double maxLineQuantity = 100000;

/// Local-only Do'kon cart — no backend `/cart` endpoint exists, same
/// rationale as shop_provider.dart's mock catalog.
class CartNotifier extends StateNotifier<List<CartLine>> {
  CartNotifier() : super(const []);

  void add(Product product, Dealer dealer, {double quantity = 1}) {
    final index = state.indexWhere(
      (l) => l.product.id == product.id && l.dealer.id == dealer.id,
    );
    if (index != -1) {
      final existing = state[index];
      state = [
        ...state.sublist(0, index),
        existing.copyWith(
          quantity: (existing.quantity + quantity).clamp(0.0, maxLineQuantity),
        ),
        ...state.sublist(index + 1),
      ];
      return;
    }
    state = [
      ...state,
      CartLine(
        product: product,
        dealer: dealer,
        quantity: quantity.clamp(0.0, maxLineQuantity),
      ),
    ];
  }

  void updateQuantity(String productId, String dealerId, double quantity) {
    if (quantity <= 0) {
      remove(productId, dealerId);
      return;
    }
    state = [
      for (final line in state)
        if (line.product.id == productId && line.dealer.id == dealerId)
          line.copyWith(quantity: quantity.clamp(0.0, maxLineQuantity))
        else
          line,
    ];
  }

  void remove(String productId, String dealerId) {
    state = state
        .where((l) => !(l.product.id == productId && l.dealer.id == dealerId))
        .toList();
  }

  void clear() => state = const [];
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartLine>>(
  (ref) => CartNotifier(),
);

/// Badge count shown on S1's cart icon and anywhere else in the shell —
/// counts distinct lines, not total units, matching the spec's "(3)" badge
/// convention for line count.
final cartLineCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).length;
});

/// Cart lines grouped by dealer, for S5's dealer-block layout.
final cartByDealerProvider = Provider<Map<Dealer, List<CartLine>>>((ref) {
  final lines = ref.watch(cartProvider);
  final grouped = <Dealer, List<CartLine>>{};
  for (final line in lines) {
    grouped.putIfAbsent(line.dealer, () => []).add(line);
  }
  return grouped;
});

int cartMaterialsTotal(List<CartLine> lines) =>
    lines.fold(0, (sum, l) => sum + l.lineTotal);

/// Flat per-dealer delivery fee — a fixed mock fee per dealer block, since
/// no real logistics pricing exists yet.
int deliveryFeeFor(Dealer dealer) => dealer.isOfficial ? 15000 : 25000;
