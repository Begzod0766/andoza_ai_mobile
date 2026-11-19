import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tamir_uy_mobile_flutter/features/tour/home_tour_keys.dart';
import 'package:tamir_uy_mobile_flutter/features/tour/home_tour_steps.dart';
import 'package:tamir_uy_mobile_flutter/l10n/app_localizations.dart';
import 'package:tamir_uy_mobile_flutter/screens/app_shell.dart';
import 'package:tamir_uy_mobile_flutter/widgets/nav/magic_nav_bar.dart';

/// A minimal GoRouter that reuses the real [AppShell] as its ShellRoute
/// wrapper but swaps the heavy tab screens for trivial text bodies — so the
/// bottom-nav behaviour can be tested without pulling in the real screens
/// (which hit providers/network).
GoRouter _testRouter({String initial = '/'}) => GoRouter(
  initialLocation: initial,
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/', builder: (_, _) => const Text('HOME BODY')),
        GoRoute(path: '/shop/s1', builder: (_, _) => const Text('SHOP BODY')),
        GoRoute(
          path: '/masters/u1',
          builder: (_, _) => const Text('MASTERS BODY'),
        ),
        GoRoute(
          path: '/profile',
          builder: (_, _) => const Text('PROFILE BODY'),
        ),
        GoRoute(
          path: '/history',
          builder: (_, _) => const Text('HISTORY BODY'),
        ),
      ],
    ),
  ],
);

Future<ProviderContainer> _pumpShell(
  WidgetTester tester, {
  String initial = '/',
}) async {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('uz'),
        routerConfig: _testRouter(initial: initial),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

const _names = ['Uy', "Do'kon", "Yangi loyiha qo'shish", 'Ustalar', 'Profil'];

int? _selected(WidgetTester tester) =>
    tester.widget<MagicNavBar>(find.byType(MagicNavBar)).selectedIndex;

void main() {
  testWidgets('five equal items with their names', (tester) async {
    await _pumpShell(tester);
    final widths = <double>[];
    for (final n in _names) {
      final f = find.bySemanticsLabel(n);
      expect(f, findsOneWidget, reason: n);
      widths.add(tester.getSize(f).width);
    }
    expect(widths.toSet().length, 1, reason: '$widths');
    expect(find.text('HOME BODY'), findsOneWidget);
    expect(_selected(tester), 0);
  });

  testWidgets('tapping each item routes and the circle follows', (
    tester,
  ) async {
    await _pumpShell(tester);
    const cases = [
      ("Do'kon", 'SHOP BODY', 1),
      ('Ustalar', 'MASTERS BODY', 3),
      ('Profil', 'PROFILE BODY', 4),
      ('Uy', 'HOME BODY', 0),
    ];
    for (final (name, body, index) in cases) {
      await tester.tap(find.bySemanticsLabel(name));
      await tester.pumpAndSettle();
      expect(find.text(body), findsOneWidget, reason: name);
      expect(_selected(tester), index, reason: name);
      final circle = tester.getCenter(find.byKey(MagicNavBar.circleKey));
      final item = tester.getCenter(find.bySemanticsLabel(name));
      expect(circle.dx, moreOrLessEquals(item.dx, epsilon: 1), reason: name);
    }
  });

  testWidgets('no circle on a shell route that matches no tab', (tester) async {
    await _pumpShell(tester, initial: '/history');
    expect(find.text('HISTORY BODY'), findsOneWidget);
    expect(_selected(tester), isNull);
    expect(find.byKey(MagicNavBar.circleKey), findsNothing);
    await tester.tap(find.bySemanticsLabel('Profil'));
    await tester.pumpAndSettle();
    expect(find.text('PROFILE BODY'), findsOneWidget);
  });

  testWidgets('the «+» item keeps the home-tour key', (tester) async {
    final container = await _pumpShell(tester);
    final key = container
        .read(homeTourKeysProvider)
        .of(HomeTourTarget.newProject);
    expect(find.byKey(key), findsOneWidget);
    expect(
      tester.getCenter(find.byKey(key)).dx,
      moreOrLessEquals(
        tester.getCenter(find.bySemanticsLabel(_names[2])).dx,
        epsilon: 1,
      ),
    );
  });

  testWidgets('items show their names, even at large text', (tester) async {
    await _pumpShell(tester);
    for (final name in ['Uy', "Do'kon", 'Ustalar', 'Profil']) {
      expect(find.text(name), findsOneWidget, reason: name);
    }
    // Semantics stay one name per item (the visible text isn't read twice).
    expect(find.bySemanticsLabel('Uy'), findsOneWidget);

    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
