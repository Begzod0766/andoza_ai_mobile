import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tamir_uy_mobile_flutter/l10n/app_localizations.dart';
import 'package:tamir_uy_mobile_flutter/screens/app_shell.dart';

/// A minimal GoRouter that reuses the real [AppShell] as its ShellRoute
/// wrapper but swaps the heavy tab screens for trivial text bodies — so the
/// bottom-nav / FAB behaviour can be tested without pulling in the real
/// screens (which hit providers/network).
GoRouter _testRouter() => GoRouter(
      initialLocation: '/',
      routes: [
        ShellRoute(
          builder: (context, state, child) => AppShell(child: child),
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) => const Text('HOME BODY'),
            ),
            GoRoute(
              path: '/shop/s1',
              builder: (_, _) => const Text('SHOP BODY'),
            ),
            GoRoute(
              path: '/masters/u1',
              builder: (_, _) => const Text('MASTERS BODY'),
            ),
            GoRoute(
              path: '/profile',
              builder: (_, _) => const Text('PROFILE BODY'),
            ),
          ],
        ),
      ],
    );

Future<void> _pumpShell(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('uz'),
        routerConfig: _testRouter(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders the four bottom-nav tabs and the home body',
      (tester) async {
    await _pumpShell(tester);

    // Each tab has one Semantics name (the visible label is excluded).
    expect(find.bySemanticsLabel('Uy'), findsOneWidget);
    expect(find.bySemanticsLabel("Do'kon"), findsOneWidget);
    expect(find.bySemanticsLabel('Ustalar'), findsOneWidget);
    expect(find.bySemanticsLabel('Profil'), findsOneWidget);
    expect(find.text('HOME BODY'), findsOneWidget);
  });

  testWidgets('exposes the center FAB with its accessibility semantics',
      (tester) async {
    await _pumpShell(tester);

    // The "+" new-project FAB carries an explicit Semantics label.
    expect(
      find.bySemanticsLabel('Yangi loyiha qo\'shish'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('tapping a tab navigates to that tab body', (tester) async {
    await _pumpShell(tester);
    expect(find.text('HOME BODY'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel("Do'kon"));
    await tester.pumpAndSettle();
    expect(find.text('SHOP BODY'), findsOneWidget);
    expect(find.text('HOME BODY'), findsNothing);

    await tester.tap(find.bySemanticsLabel('Ustalar'));
    await tester.pumpAndSettle();
    expect(find.text('MASTERS BODY'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Profil'));
    await tester.pumpAndSettle();
    expect(find.text('PROFILE BODY'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Uy'));
    await tester.pumpAndSettle();
    expect(find.text('HOME BODY'), findsOneWidget);
  });

  testWidgets('tabs show their names under the icons, even at large text', (tester) async {
    await _pumpShell(tester);
    for (final name in ['Uy', "Do'kon", 'Ustalar', 'Profil']) {
      expect(find.text(name), findsOneWidget, reason: name);
    }
    // Semantics stay one name per tab (the visible text isn't read twice).
    expect(find.bySemanticsLabel('Uy'), findsOneWidget);

    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
