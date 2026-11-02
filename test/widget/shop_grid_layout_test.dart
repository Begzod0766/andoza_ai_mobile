import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tamir_uy_mobile_flutter/l10n/app_localizations.dart';
import 'package:tamir_uy_mobile_flutter/models/shop_model.dart';
import 'package:tamir_uy_mobile_flutter/providers/apartment_provider.dart';
import 'package:tamir_uy_mobile_flutter/providers/cart_provider.dart';
import 'package:tamir_uy_mobile_flutter/providers/catalog_provider.dart';
import 'package:tamir_uy_mobile_flutter/providers/shop_provider.dart';
import 'package:tamir_uy_mobile_flutter/screens/shop/s1_shop_home_screen.dart';

// Long, two-line names next to short ones — what the real catalogue has.
const _products = [
  Product(
    id: 'm1',
    name: 'Bra',
    brand: 'Stroy Master',
    category: ShopCategory.boyoq,
    pricePerUnit: 180000,
    unit: 'dona',
    isOfficialDealer: false,
    projectQuantity: 1,
  ),
  Product(
    id: 'm2',
    name: 'Knauf gipsokarton 12.5 mm (1.2×2.5 m)',
    brand: 'Leroy Merlin Tashkent',
    category: ShopCategory.boyoq,
    pricePerUnit: 96000,
    unit: 'dona',
    isOfficialDealer: false,
    projectQuantity: 1,
  ),
  Product(
    id: 'm3',
    name: 'Polistirol plintus 2.5 m',
    brand: 'Qurilish Bozori',
    category: ShopCategory.boyoq,
    pricePerUnit: 31000,
    unit: 'dona',
    isOfficialDealer: false,
  ),
];

Future<void> _pump(WidgetTester tester, double textScale) async {
  // iPhone 17 Pro: 402 × 874 points.
  tester.view.physicalSize = const Size(1206, 2622);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final router = GoRouter(
    initialLocation: '/shop/s1',
    routes: [GoRoute(path: '/shop/s1', builder: (_, _) => const S1ShopHomeScreen())],
  );
  await tester.pumpWidget(ProviderScope(
    overrides: [
      furnitureProvider.overrideWith((ref, category) async => const []),
      shopCatalogProvider.overrideWithValue(_products),
      shopCatalogLoadingProvider.overrideWithValue(false),
      shopCatalogErrorProvider.overrideWithValue(null),
      cartLineCountProvider.overrideWithValue(0),
      apartmentsProvider.overrideWith((ref) async => const []),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('uz'),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  for (final scale in [1.0, 1.35, 2.0]) {
    testWidgets('product cards fit their text at text scale $scale', (tester) async {
      await _pump(tester, scale);
      expect(tester.takeException(), isNull);
      // Every price is laid out (not clipped away by a fixed-height cell).
      for (final price in ['180 000', '96 000', '31 000']) {
        final f = find.textContaining(price);
        await tester.scrollUntilVisible(f, 200, scrollable: find.byType(Scrollable).first);
        expect(f, findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  }
}
