import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/l10n/app_localizations.dart';
import 'package:tamir_uy_mobile_flutter/models/shop_model.dart';
import 'package:tamir_uy_mobile_flutter/providers/catalog_provider.dart';
import 'package:tamir_uy_mobile_flutter/providers/shop_provider.dart';
import 'package:tamir_uy_mobile_flutter/screens/shop/e10_search_results_screen.dart';
import 'package:tamir_uy_mobile_flutter/screens/shop/s4_dealer_comparison_screen.dart';

const _paint = Product(
  id: 'm1',
  name: "Oq bo'yoq",
  brand: 'Stroy Master',
  category: ShopCategory.boyoq,
  pricePerUnit: 85000,
  unit: 'litr',
  isOfficialDealer: true,
);

Future<void> _pump(WidgetTester tester, Widget screen) async {
  tester.view.physicalSize = const Size(1206, 2622);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      shopCatalogProvider.overrideWithValue(const [_paint]),
      shopCatalogLoadingProvider.overrideWithValue(false),
      shopCatalogErrorProvider.overrideWithValue(null),
      materialOffersProvider.overrideWith((ref, id) async => const []),
    ],
    child: MaterialApp(
      locale: const Locale('uz'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(2.0)),
        child: child!,
      ),
      home: screen,
    ),
  ));
  await tester.pumpAndSettle();
}

/// The chip's text sits fully inside its horizontal row.
void _notClipped(WidgetTester tester, String label) {
  final chip = find.text(label).first;
  final row = find.ancestor(of: chip, matching: find.byType(Scrollable)).first;
  expect(tester.getRect(chip).bottom, lessThanOrEqualTo(tester.getRect(row).bottom), reason: label);
  expect(tester.getRect(chip).top, greaterThanOrEqualTo(tester.getRect(row).top), reason: label);
}

void main() {
  final l10n = lookupAppLocalizations(const Locale('uz'));

  testWidgets('search filter chips are not clipped at large text', (tester) async {
    await _pump(tester, const E10SearchResultsScreen());
    _notClipped(tester, l10n.shopFilterAll);
  });

  testWidgets('dealer filter chips are not clipped at large text', (tester) async {
    await _pump(tester, const S4DealerComparisonScreen(product: _paint));
    _notClipped(tester, l10n.shopFilterCheapest);
  });
}
