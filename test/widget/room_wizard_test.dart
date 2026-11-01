import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tamir_uy_mobile_flutter/l10n/app_localizations.dart';
import 'package:tamir_uy_mobile_flutter/providers/room_provider.dart';
import 'package:tamir_uy_mobile_flutter/screens/room_setup/room_wizard_screen.dart';
import 'package:tamir_uy_mobile_flutter/widgets/room/isometric_room_view.dart';

/// Minimal router so the wizard's `context.go('/estimation/e1')` on "Smeta
/// ko'rish" resolves without pulling in the real estimation screen.
GoRouter _router() => GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const RoomWizardScreen(),
        ),
        GoRoute(
          path: '/estimation/e1',
          builder: (_, _) => const Scaffold(body: Text('E1')),
        ),
        GoRoute(
          path: '/design/b1',
          builder: (_, _) => const Scaffold(body: Text('B1')),
        ),
      ],
    );

/// The wizard (iso preview + steps + bottom nav) is taller than the default
/// 800×600 test surface; give it room so the "Keyingi" button is hittable.
Future<void> _enlarge(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(1000, 2000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

void main() {
  testWidgets(
    'finishing the 3D wizard lands a 4-corner rectangle plan + mirrored Room',
    (tester) async {
      await _enlarge(tester);
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: _router(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('uz'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Advance ceiling → A → B → C → D → summary (5 "Keyingi" taps).
      for (var i = 0; i < 5; i++) {
        await tester.tap(find.text('Keyingi'));
        await tester.pumpAndSettle();
      }

      // Summary → "Smeta ko'rish" runs _setupRoom and navigates to E1.
      await tester.tap(find.text('Smeta ko\'rish'));
      await tester.pumpAndSettle();
      expect(find.text('E1'), findsOneWidget);

      final container = ProviderScope.containerOf(
        tester.element(find.text('E1')),
      );

      // The polygon plan is the in-app source of truth: a 4-corner rectangle
      // with the seeded defaults (width = wall B = 3.2, length = wall A = 4.5).
      final plan = container.read(activeRoomPlanProvider);
      expect(plan, isNotNull);
      expect(plan!.corners, hasLength(4));
      expect(plan.isAxisAlignedRect, isTrue);
      expect(plan.boundingSize.width, closeTo(3.2, 1e-9));
      expect(plan.boundingSize.length, closeTo(4.5, 1e-9));
      expect(plan.ceilingHeightM, closeTo(2.8, 1e-9));

      // The mirrored legacy Room matches the plan's bounding box for display.
      final room = container.read(activeRoomProvider);
      expect(room, isNotNull);
      expect(room!.name, 'Mehmonxona ta\'miri');
      expect(room.dimensions.width, closeTo(3.2, 1e-9));
      expect(room.dimensions.length, closeTo(4.5, 1e-9));
      expect(room.dimensions.height, closeTo(2.8, 1e-9));
      expect(room.walls, hasLength(4));
    },
  );

  testWidgets('ceiling preset flows into the finished plan height',
      (tester) async {
    await _enlarge(tester);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: _router(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('uz'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Pick the 3.0 m ceiling preset on the first step.
    await tester.tap(find.text('3.0 m'));
    await tester.pumpAndSettle();

    for (var i = 0; i < 5; i++) {
      await tester.tap(find.text('Keyingi'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Smeta ko\'rish'));
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.text('E1')),
    );
    expect(
      container.read(activeRoomPlanProvider)!.ceilingHeightM,
      closeTo(3.0, 1e-9),
    );
  });

  testWidgets('a ceiling height out of range is said, and Keyingi waits',
      (tester) async {
    await _enlarge(tester);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: _router(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('uz'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final next = find.widgetWithText(ElevatedButton, 'Keyingi');
    bool nextEnabled() => tester.widget<ElevatedButton>(next).onPressed != null;

    await tester.enterText(find.byType(TextField), '99');
    await tester.pump();
    expect(find.textContaining('Shift balandligi 2 m dan 5 m gacha'),
        findsOneWidget);
    expect(nextEnabled(), isFalse);

    // A comma is how a decimal is typed on many Uzbek keyboards.
    await tester.enterText(find.byType(TextField), '3,1');
    await tester.pump();
    expect(find.textContaining('Shift balandligi'), findsNothing);
    expect(nextEnabled(), isTrue);
  });

  testWidgets('the room preview steps aside while the keyboard is up',
      (tester) async {
    await _enlarge(tester);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: _router(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('uz'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(IsometricRoomView), findsOneWidget);

    // A keyboard over the bottom of the screen (physical pixels).
    tester.view.viewInsets = const FakeViewPadding(bottom: 900);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    expect(find.byType(IsometricRoomView), findsNothing);
    expect(find.byType(TextField), findsOneWidget);
  });
}
