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
  _offscreenTests();
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

  testWidgets('system back closes the tour like Skip and does not leave the app', (t) async {
    var done = 0;
    await _start(t, onFinish: () => done++);
    final l = AppLocalizations.of(t.element(find.byType(Scaffold).first))!;
    final handled = await t.binding.handlePopRoute();
    await _settle(t);
    expect(handled, isTrue);
    expect(done, 1);
    expect(find.text(l.homeTourNewProjectTitle), findsNothing);
  });

  testWidgets('back after the tour ended is no longer intercepted', (t) async {
    await _start(t, onFinish: () {});
    final l = AppLocalizations.of(t.element(find.byType(Scaffold).first))!;
    await t.tap(find.text(l.tourSkip));
    await _settle(t);
    // A second back must fall through to the app (nothing handles it here).
    expect(await t.binding.handlePopRoute(), isFalse);
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

  testWidgets('card for a target at the screen bottom stays on screen', (t) async {
    final keys = HomeTourKeys();
    await t.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('uz'),
      home: Builder(
        builder: (ctx) => Scaffold(
          body: Stack(children: [
            Center(
              child: TextButton(
                onPressed: () => showHomeTour(ctx, keys, hasProjects: false, onFinish: () {}),
                child: const Text('go'),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(key: keys.of(HomeTourTarget.newProject), width: 60, height: 60),
            ),
            Align(
              alignment: Alignment.topRight,
              child: SizedBox(key: keys.of(HomeTourTarget.help), width: 40, height: 40),
            ),
          ]),
        ),
      ),
    ));
    await t.tap(find.text('go'));
    await t.pump();
    await _settle(t);
    final l = AppLocalizations.of(t.element(find.byType(Scaffold).first))!;
    final title = find.text(l.homeTourNewProjectTitle);
    expect(title, findsOneWidget);
    expect(t.getBottomLeft(title).dy, lessThanOrEqualTo(t.view.physicalSize.height / t.view.devicePixelRatio));
    expect(t.getBottomLeft(find.text(l.tourNext)).dy, lessThan(t.getTopLeft(find.byKey(keys.of(HomeTourTarget.newProject))).dy));
  });
}

void _offscreenTests() {
  Future<void> pumpTall(WidgetTester t, HomeTourKeys keys, {required bool resumeBelowFold}) async {
    t.view.physicalSize = const Size(874, 402);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('uz'),
      home: Builder(
        builder: (ctx) => Scaffold(
          body: SingleChildScrollView(
            child: Column(children: [
              SizedBox(key: keys.of(HomeTourTarget.newProject), width: 120, height: 60),
              SizedBox(height: resumeBelowFold ? 600 : 100),
              SizedBox(key: keys.of(HomeTourTarget.resume), width: 120, height: 60),
              TextButton(
                onPressed: () => showHomeTour(ctx, keys, hasProjects: true, onFinish: () {}),
                child: const Text('go'),
              ),
            ]),
          ),
        ),
      ),
    ));
  }

  testWidgets('target below the fold is skipped on a short landscape screen', (t) async {
    final keys = HomeTourKeys();
    await pumpTall(t, keys, resumeBelowFold: true);
    final steps = presentTargets(homeTourSteps(hasProjects: true), keys);
    expect(steps, [HomeTourTarget.newProject]);
  });

  testWidgets('fully visible target is kept on a short screen', (t) async {
    final keys = HomeTourKeys();
    await pumpTall(t, keys, resumeBelowFold: false);
    final steps = presentTargets(homeTourSteps(hasProjects: true), keys);
    expect(steps, [HomeTourTarget.newProject, HomeTourTarget.resume]);
  });
}
