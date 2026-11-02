import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/l10n/app_localizations.dart';
import 'package:tamir_uy_mobile_flutter/l10n/app_localizations_uz.dart';
import 'package:tamir_uy_mobile_flutter/models/shop_model.dart';
import 'package:tamir_uy_mobile_flutter/providers/orders_provider.dart';
import 'package:tamir_uy_mobile_flutter/screens/profile/e6_orders_screen.dart';

final l10n = AppLocalizationsUz();

final _order = ShopOrder(
  id: 'o1',
  lines: const [],
  total: 250000,
  currentStep: OrderStep.onTheWay,
  dealerName: 'Stroy Master',
  createdAt: DateTime(2026, 11, 1),
);

Future<void> _pump(WidgetTester tester, Future<List<ShopOrder>> Function() load) async {
  await tester.pumpWidget(ProviderScope(
    overrides: [serverOrdersProvider.overrideWith((ref) => load())],
    child: MaterialApp(
      locale: const Locale('uz'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const E6OrdersScreen(),
    ),
  ));
}

void main() {
  testWidgets('while loading it shows progress, not "no orders"', (tester) async {
    final never = Completer<List<ShopOrder>>();
    await _pump(tester, () => never.future);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text(l10n.profileOrdersEmptyTitle), findsNothing);
  });

  testWidgets('a failed load says so and offers a retry', (tester) async {
    var calls = 0;
    await _pump(tester, () async {
      calls++;
      throw Exception('offline');
    });
    await tester.pumpAndSettle();
    expect(find.text(l10n.profileOrdersEmptyTitle), findsNothing);
    expect(find.text(l10n.actionRetry), findsOneWidget);
    await tester.tap(find.text(l10n.actionRetry));
    await tester.pumpAndSettle();
    expect(calls, 2);
  });

  testWidgets('orders load, and pulling down reloads them', (tester) async {
    var calls = 0;
    await _pump(tester, () async {
      calls++;
      return [_order];
    });
    await tester.pumpAndSettle();
    expect(find.textContaining('#o1'), findsOneWidget);
    expect(find.byType(RefreshIndicator), findsOneWidget);
    await tester.fling(find.byType(Scrollable).last, const Offset(0, 400), 1000);
    await tester.pumpAndSettle();
    expect(calls, 2);
  });

  testWidgets('no orders still pulls to refresh', (tester) async {
    await _pump(tester, () async => const []);
    await tester.pumpAndSettle();
    expect(find.text(l10n.profileOrdersEmptyTitle), findsOneWidget);
    expect(find.byType(RefreshIndicator), findsOneWidget);
  });
}
