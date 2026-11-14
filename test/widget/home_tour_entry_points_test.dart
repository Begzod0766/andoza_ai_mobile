import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tamir_uy_mobile_flutter/features/tour/home_tour_launcher.dart';
import 'package:tamir_uy_mobile_flutter/l10n/app_localizations.dart';
import 'package:tamir_uy_mobile_flutter/models/business_profile.dart';
import 'package:tamir_uy_mobile_flutter/providers/auth_provider.dart';
import 'package:tamir_uy_mobile_flutter/providers/business_provider.dart';
import 'package:tamir_uy_mobile_flutter/providers/orders_provider.dart';
import 'package:tamir_uy_mobile_flutter/screens/home/home_empty_screen.dart';
import 'package:tamir_uy_mobile_flutter/screens/home/home_with_projects_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tamir_uy_mobile_flutter/features/tour/home_tour_store.dart';
import 'package:tamir_uy_mobile_flutter/screens/profile/e4_profile_settings_screen.dart';

late ProviderContainer _container;
late GoRouter _router;

Future<void> _pump(WidgetTester t, String initial, Map<String, Widget> pages) async {
  t.view.physicalSize = const Size(800, 1600);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  _router = GoRouter(
    initialLocation: initial,
    routes: [
      for (final e in pages.entries) GoRoute(path: e.key, builder: (_, _) => e.value),
    ],
  );
  _container = ProviderContainer(overrides: [
    projectsProvider.overrideWithValue(const AsyncData([])),
    currentUserProvider.overrideWith((ref) async => null),
    serverOrdersProvider.overrideWith((ref) async => []),
    accountRolesProvider.overrideWith((ref) async => const AccountRoles()),
  ]);
  addTearDown(_container.dispose);
  await t.pumpWidget(
    UncontrolledProviderScope(
      container: _container,
      child: MaterialApp.router(
        routerConfig: _router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('uz'),
      ),
    ),
  );
  await t.pump();
}

AppLocalizations _l(WidgetTester t) => AppLocalizations.of(t.element(find.byType(Scaffold).first))!;

void main() {
  testWidgets('profile help row goes home and requests the tour', (t) async {
    await _pump(t, '/profile', {
      '/': const Scaffold(body: Text('HOME')),
      '/profile': const E4ProfileSettingsScreen(),
      '/onboarding/e8': const Scaffold(body: Text('E8')),
    });
    final help = find.text(_l(t).profileMenuHelp);
    await t.ensureVisible(help);
    await t.tap(help);
    await t.pump();
    await t.pump();
    expect(find.text('HOME'), findsOneWidget);
    expect(find.text('E8'), findsNothing);
    expect(_container.read(homeTourRequestProvider), 1);
  });

  testWidgets('empty-home story circles request the tour, not E8', (t) async {
    await _pump(t, '/', {
      '/': const Scaffold(body: HomeEmptyBody()),
      '/onboarding/e8': const Scaffold(body: Text('E8')),
      '/onboarding/e7': const Scaffold(body: Text('E7')),
    });
    await t.tap(find.text(_l(t).homeStoryDemoGuide));
    await t.pump();
    expect(_container.read(homeTourRequestProvider), 1);
    await t.tap(find.text(_l(t).homeStoryDemo));
    await t.pump();
    expect(_container.read(homeTourRequestProvider), 2);
    expect(find.text('E8'), findsNothing);
    expect(_router.routeInformationProvider.value.uri.path, '/');
  });

  testWidgets('help row: the freshly mounted home launcher replays the tour', (t) async {
    SharedPreferences.setMockInitialValues({homeTourDoneKey: true});
    await _pump(t, '/profile', {
      '/': const Scaffold(body: HomeWithProjectsScreen()),
      '/profile': const E4ProfileSettingsScreen(),
    });
    final help = find.text(_l(t).profileMenuHelp);
    await t.ensureVisible(help);
    await t.tap(help);
    for (var i = 0; i < 6; i++) {
      await t.pump(const Duration(milliseconds: 500));
    }
    expect(find.text(_l(t).tourSkip), findsOneWidget);
  });
}
