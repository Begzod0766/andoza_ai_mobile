import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/l10n/app_localizations.dart';
import 'package:tamir_uy_mobile_flutter/screens/home/home_empty_screen.dart';

import '../support/localized_pump.dart';

Future<void> _pump(WidgetTester tester, double scale) async {
  tester.view.physicalSize = const Size(1206, 2622); // iPhone 17 Pro, 402 pt wide
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(wrapLocalized(Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
      child: const Scaffold(body: HomeEmptyBody()),
    ),
  )));
  // The rings spin forever: pump frames instead of settling.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  testWidgets('the three story circles line up', (tester) async {
    await _pump(tester, 1.0);
    // The tour's "?" button shares Icons.help_outline and comes first in the
    // tree; the story circle is the last match.
    final tops = [
      find.byIcon(Icons.help_outline).last,
      find.byIcon(Icons.play_circle_outline),
      find.byIcon(Icons.auto_awesome),
    ].map((f) => tester.getRect(f).top).toSet();
    expect(tops, hasLength(1));
  });

  // Widget tests draw every glyph as a square (Ahem), so real word widths
  // can't be measured here; check what prevents the mid-word split instead.
  testWidgets('story labels get a third of the row and cap text at 1.5×', (tester) async {
    await _pump(tester, 2.0);
    final l10n = lookupAppLocalizations(const Locale('uz'));
    for (final label in [l10n.homeStoryHowItWorks, l10n.homeStoryDemoGuide, l10n.homeStoryDemo]) {
      final finder = find.text(label);
      // Was a fixed 72 px; now the column's share of the 402 pt screen.
      final column = find.ancestor(of: finder, matching: find.byType(Column)).first;
      expect(tester.getSize(column).width, greaterThan(110), reason: label);
      final scaler = tester.widget<Text>(finder).textScaler!;
      expect(scaler.scale(10), 15, reason: label);
    }
  });
}
