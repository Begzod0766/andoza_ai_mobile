import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/models/api/api.dart';
import 'package:tamir_uy_mobile_flutter/screens/estimation/e1_estimation_intro_screen.dart';

import '../support/localized_pump.dart';

Estimate _estimate({required bool guest}) => Estimate(
      id: 'e',
      roomId: 'r',
      totalUzs: 1,
      totalMin: 1,
      totalMax: 1,
      createdAt: DateTime(2026),
      pricesApproximateForGuest: guest,
    );

const _note = "Narxlar taxminiy. Ro'yxatdan o'tsangiz, aniqlashtiriladi.";

void main() {
  testWidgets('note shows only with the flag', (tester) async {
    var taps = 0;
    await pumpLocalized(
      tester,
      Scaffold(
        body: Column(children: [
          GuestPricesNote(estimate: _estimate(guest: true), onSignUp: () => taps++),
          GuestPricesNote(estimate: _estimate(guest: false), onSignUp: () {}),
          GuestPricesNote(estimate: null, onSignUp: () {}),
        ]),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(_note), findsOneWidget);
    await tester.tap(find.text("Ro'yxatdan o'tish"));
    expect(taps, 1);
  });
}
