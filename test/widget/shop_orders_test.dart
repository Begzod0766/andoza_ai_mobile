import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/l10n/app_localizations.dart';
import 'package:tamir_uy_mobile_flutter/models/api/api.dart';
import 'package:tamir_uy_mobile_flutter/models/business_profile.dart';
import 'package:tamir_uy_mobile_flutter/models/shop_model.dart';
import 'package:tamir_uy_mobile_flutter/providers/business_provider.dart';
import 'package:tamir_uy_mobile_flutter/providers/cart_provider.dart';
import 'package:tamir_uy_mobile_flutter/providers/orders_provider.dart';
import 'package:tamir_uy_mobile_flutter/repositories/business_repository.dart';
import 'package:tamir_uy_mobile_flutter/repositories/orders_repository.dart';
import 'package:tamir_uy_mobile_flutter/screens/business/shop_orders_screen.dart';
import 'package:tamir_uy_mobile_flutter/screens/shop/s6_checkout_screen.dart';
import 'package:tamir_uy_mobile_flutter/services/api_client.dart';
import 'package:tamir_uy_mobile_flutter/widgets/periodic_refresh.dart';

class _FakeBusiness implements BusinessRepository {
  final calls = <String>[];
  int fetches = 0;
  bool conflict = false;
  SellerOrderStage stage = SellerOrderStage.accepted;

  SellerOrder get _order => SellerOrder(
    id: 'o1',
    dealerName: 'Dealer',
    totalUzs: 345210,
    status: stage,
    createdAt: DateTime(2026, 10, 8),
    deliveryAddress: 'Toshkent, Chilonzor',
    phone: '+998901112233',
    paymentMethod: 'cash',
    lines: const [
      SellerOrderLine(
        productName: 'Boyoq',
        unit: 'litr',
        quantity: 2,
        unitPriceUzs: 100,
      ),
    ],
  );

  @override
  Future<List<SellerOrder>> fetchSellerOrders() async {
    fetches++;
    return [_order];
  }

  @override
  Future<SellerOrder> advanceSellerOrder(
    String id,
    SellerOrderStage status,
  ) async {
    calls.add('$id ${status.wire}');
    if (conflict) {
      throw ApiException(
        message: 'Conflict: x',
        statusCode: 409,
        response: {'detail': "Buyurtma holatini faqat keyingi bosqichga o'tkazish mumkin."},
      );
    }
    stage = status;
    return _order;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

class _FakeOrders implements OrdersRepository {
  _FakeOrders({this.fail = false});
  final bool fail;
  int calls = 0;
  List<OrderLineCreate> lastLines = const [];
  String? lastPhone;

  @override
  Future<ServerOrder> createOrder({
    required String dealerName,
    required List<OrderLineCreate> lines,
    String? deliveryAddress,
    String? phone,
    String? paymentMethod,
  }) async {
    calls++;
    lastLines = lines;
    lastPhone = phone;
    if (fail) {
      throw ApiException(
        message: 'Bad request: x',
        statusCode: 400,
        response: {'detail': 'Mahsulot topilmadi'},
      );
    }
    throw UnimplementedError();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

Widget _app(List<Override> overrides, Widget home) => ProviderScope(
  overrides: overrides,
  child: MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('uz'),
    home: home,
  ),
);

const _uuid = '11111111-1111-4111-8111-111111111111';

CartNotifier _cart(String productId, {int dealerPrice = 100}) {
  final dealer = Dealer(
    id: 'd1',
    name: 'Dealer',
    isOfficial: true,
    district: 'Chilonzor',
    deliveryDays: 1,
    pricePerUnit: dealerPrice,
  );
  final product = Product(
    id: productId,
    name: 'Boyoq',
    brand: 'B',
    category: ShopCategory.boyoq,
    pricePerUnit: 100,
    unit: 'litr',
    isOfficialDealer: true,
  );
  return CartNotifier()..add(product, dealer, quantity: 2);
}

void main() {
  testWidgets('seller orders: shows order, advances one stage, hides at delivered', (
    tester,
  ) async {
    final repo = _FakeBusiness();
    await tester.pumpWidget(
      _app([businessRepositoryProvider.overrideWithValue(repo)], const ShopOrdersScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dealer'), findsOneWidget);
    expect(find.text('Qabul qilindi'), findsOneWidget);
    expect(find.textContaining('345 210'), findsOneWidget);
    expect(find.textContaining('Boyoq × 2 litr'), findsOneWidget);
    expect(find.textContaining('Toshkent, Chilonzor'), findsOneWidget);
    expect(find.text('+998901112233'), findsOneWidget);

    await tester.tap(find.text("Yig'ilmoqda deb belgilash"));
    await tester.pumpAndSettle();
    expect(repo.calls, ['o1 gathering']);
    expect(find.text("Yo'lda deb belgilash"), findsOneWidget);

    repo.stage = SellerOrderStage.delivered;
    await tester.drag(find.byType(ListView), const Offset(0, 400));
    await tester.pumpAndSettle();
    expect(find.textContaining('deb belgilash'), findsNothing);
  });

  testWidgets('seller orders: a 409 shows the server text and refreshes', (
    tester,
  ) async {
    final repo = _FakeBusiness()..conflict = true;
    await tester.pumpWidget(
      _app([businessRepositoryProvider.overrideWithValue(repo)], const ShopOrdersScreen()),
    );
    await tester.pumpAndSettle();
    final before = repo.fetches;
    await tester.tap(find.text("Yig'ilmoqda deb belgilash"));
    await tester.pumpAndSettle();
    expect(find.textContaining('faqat keyingi bosqichga'), findsOneWidget);
    expect(repo.fetches, greaterThan(before));
  });

  testWidgets('seller orders refresh every 30 seconds and stop on dispose', (
    tester,
  ) async {
    final repo = _FakeBusiness();
    await tester.pumpWidget(
      _app([businessRepositoryProvider.overrideWithValue(repo)], const ShopOrdersScreen()),
    );
    await tester.pumpAndSettle();
    expect(repo.fetches, 1);
    await tester.pump(const Duration(seconds: 30));
    await tester.pumpAndSettle();
    expect(repo.fetches, 2);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 90));
    expect(repo.fetches, 2);
  });

  testWidgets('PeriodicRefresh ticks on the interval and cancels on dispose', (
    tester,
  ) async {
    var ticks = 0;
    await tester.pumpWidget(
      PeriodicRefresh(onTick: () => ticks++, child: const SizedBox()),
    );
    await tester.pump(const Duration(seconds: 29));
    expect(ticks, 0);
    await tester.pump(const Duration(seconds: 1));
    expect(ticks, 1);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 60));
    expect(ticks, 1);
  });

  testWidgets('checkout: a server refusal keeps the cart and shows the detail', (
    tester,
  ) async {
    final orders = _FakeOrders(fail: true);
    await tester.pumpWidget(
      _app([
        ordersRepositoryProvider.overrideWithValue(orders),
        cartProvider.overrideWith((ref) => _cart(_uuid)),
      ], const S6CheckoutScreen()),
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(S6CheckoutScreen)),
    );
    await _enterPhone(tester);
    await tester.tap(find.text("To'lash"));
    await tester.pumpAndSettle();

    expect(orders.calls, 1);
    expect(find.textContaining('Mahsulot topilmadi'), findsOneWidget);
    expect(container.read(cartProvider), hasLength(1));
    expect(container.read(ordersProvider), isEmpty);
    expect(find.byType(S6CheckoutScreen), findsOneWidget);
  });

  testWidgets('checkout: a line with no catalog id is caught before sending', (
    tester,
  ) async {
    final orders = _FakeOrders();
    await tester.pumpWidget(
      _app([
        ordersRepositoryProvider.overrideWithValue(orders),
        cartProvider.overrideWith((ref) => _cart('mock-paint-1')),
      ], const S6CheckoutScreen()),
    );
    await tester.tap(find.text("To'lash"));
    await tester.pumpAndSettle();

    expect(orders.calls, 0);
    expect(find.textContaining('katalogiga bog'), findsOneWidget);
    expect(find.textContaining('Boyoq'), findsWidgets);
  });

  testWidgets('checkout: the order is priced at what the cart showed (the dealer price)', (
    tester,
  ) async {
    // Product lists at 100, the chosen dealer sells at 90: the cart total is
    // 2 × 90, so the order must say 90 — not the catalog's 100.
    final orders = _FakeOrders(fail: true);
    await tester.pumpWidget(
      _app([
        ordersRepositoryProvider.overrideWithValue(orders),
        cartProvider.overrideWith((ref) => _cart(_uuid, dealerPrice: 90)),
      ], const S6CheckoutScreen()),
    );
    await _enterPhone(tester);
    await tester.tap(find.text("To'lash"));
    await tester.pumpAndSettle();

    expect(orders.lastLines, hasLength(1));
    expect(orders.lastLines.single.unitPriceUzs, 90);
    expect(orders.lastPhone, '+998901234567');
  });

  testWidgets('checkout: a phone that is not Uzbek is refused before sending', (
    tester,
  ) async {
    final orders = _FakeOrders();
    await tester.pumpWidget(
      _app([
        ordersRepositoryProvider.overrideWithValue(orders),
        cartProvider.overrideWith((ref) => _cart(_uuid)),
      ], const S6CheckoutScreen()),
    );
    await _enterPhone(tester, '12');
    await tester.tap(find.text("To'lash"));
    await tester.pumpAndSettle();

    expect(orders.calls, 0);
    expect(find.textContaining("Telefon raqami noto'g'ri"), findsOneWidget);
  });
}

/// The shop calls this number about delivery; checkout needs it.
Future<void> _enterPhone(
  WidgetTester tester, [
  String phone = '+998 90 123 45 67',
]) async {
  await tester.enterText(
    find.widgetWithText(TextField, 'Telefon raqami'),
    phone,
  );
}
