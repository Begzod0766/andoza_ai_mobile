import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/l10n/app_localizations.dart';
import 'package:tamir_uy_mobile_flutter/providers/catalog_provider.dart';
import 'package:tamir_uy_mobile_flutter/screens/masters/u3_request_booking_screen.dart';

void main() {
  testWidgets('the masters list pulls to refresh', (tester) async {
    var loads = 0;
    await tester.pumpWidget(ProviderScope(
      overrides: [
        ustalarProvider.overrideWith((ref, filter) async {
          loads++;
          return const [];
        }),
      ],
      child: MaterialApp(
        locale: const Locale('uz'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const U3RequestBookingScreen(),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(RefreshIndicator), findsOneWidget);
    final before = loads;
    await tester.fling(find.byType(Scrollable).first, const Offset(0, 400), 1000);
    await tester.pumpAndSettle();
    expect(loads, greaterThan(before));
  });
}
