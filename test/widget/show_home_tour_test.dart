import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/features/tour/home_tour_keys.dart';
import 'package:tamir_uy_mobile_flutter/features/tour/home_tour_steps.dart';
import 'package:tamir_uy_mobile_flutter/features/tour/show_home_tour.dart';
import 'package:tamir_uy_mobile_flutter/l10n/app_localizations.dart';

class _Host extends StatelessWidget {
  const _Host({required this.keys, required this.onTap, required this.onFinish, this.locale = const Locale('uz')});
  final HomeTourKeys keys;
  final VoidCallback onTap;
  final VoidCallback onFinish;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      home: Builder(
        builder: (ctx) => Scaffold(
          body: Column(children: [
            const SizedBox(height: 60),
            GestureDetector(
              key: keys.of(HomeTourTarget.newProject),
              onTap: onTap,
              child: const SizedBox(width: 120, height: 60, child: Text('np')),
            ),
            const SizedBox(height: 60),
            SizedBox(key: keys.of(HomeTourTarget.shop), width: 120, height: 60),
            const SizedBox(height: 60),
            SizedBox(key: keys.of(HomeTourTarget.help), width: 120, height: 60),
            TextButton(
              onPressed: () => showHomeTour(ctx, keys, hasProjects: true, onFinish: onFinish),
              child: const Text('go'),
            ),
          ]),
        ),
      ),
    );
  }
}

Future<void> _settle(WidgetTester t) async {
  for (var i = 0; i < 6; i++) {
    await t.pump(const Duration(milliseconds: 500));
  }
}

Future<void> _start(WidgetTester t, {Locale locale = const Locale('uz'), VoidCallback? onTap, required VoidCallback onFinish}) async {
  final keys = HomeTourKeys();
  await t.pumpWidget(_Host(keys: keys, onTap: onTap ?? () {}, onFinish: onFinish, locale: locale));
  await t.tap(find.text('go'));
  await t.pump();
  await _settle(t);
}

void main() {
  testWidgets('shows only rendered steps, Next advances', (t) async {
    var done = 0;
    await _start(t, onFinish: () => done++);
    final l = AppLocalizations.of(t.element(find.byType(Scaffold).first))!;
    expect(find.text(l.homeTourNewProjectTitle), findsOneWidget);
    expect(find.text('1/3'), findsOneWidget);
    await t.tap(find.text(l.tourNext));
    await _settle(t);
    expect(find.text(l.homeTourShopTitle), findsOneWidget);
    expect(find.text('2/3'), findsOneWidget);
  });

  testWidgets('tapping the target advances without calling its onTap', (t) async {
    var taps = 0;
    await _start(t, onTap: () => taps++, onFinish: () {});
    final l = AppLocalizations.of(t.element(find.byType(Scaffold).first))!;
    await t.tapAt(t.getCenter(find.text('np')));
    await _settle(t);
    expect(taps, 0);
    expect(find.text(l.homeTourShopTitle), findsOneWidget);
  });

  testWidgets('skip calls onFinish once', (t) async {
    var done = 0;
    await _start(t, onFinish: () => done++);
    final l = AppLocalizations.of(t.element(find.byType(Scaffold).first))!;
    await t.tap(find.text(l.tourSkip));
    await _settle(t);
    expect(done, 1);
    expect(find.text(l.homeTourNewProjectTitle), findsNothing);
  });

  testWidgets('finishing the last step calls onFinish once', (t) async {
    var done = 0;
    await _start(t, onFinish: () => done++);
    final l = AppLocalizations.of(t.element(find.byType(Scaffold).first))!;
    for (var i = 0; i < 2; i++) {
      await t.tap(find.text(l.tourNext));
      await _settle(t);
    }
    await t.tap(find.text(l.tourDone));
    await _settle(t);
    expect(done, 1);
  });

  testWidgets('ru locale shows Russian title', (t) async {
    await _start(t, locale: const Locale('ru'), onFinish: () {});
    expect(find.text('Новый проект'), findsOneWidget);
  });
}
