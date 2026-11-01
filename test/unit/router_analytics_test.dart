import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tamir_uy_mobile_flutter/config/router.dart';
import 'package:tamir_uy_mobile_flutter/services/analytics_service.dart';
import 'package:tamir_uy_mobile_flutter/services/firebase_setup.dart';

void main() {
  ShellRoute shellOf(GoRouter router) =>
      router.configuration.routes.whereType<ShellRoute>().single;

  test('no screen-view observer outside release, even with Firebase up', () {
    final c = ProviderContainer(
      overrides: [firebaseReadyProvider.overrideWithValue(true)],
    );
    addTearDown(c.dispose);
    expect(c.read(screenViewObserverFactoryProvider), isNull);
    expect(shellOf(c.read(routerProvider)).observers, isNull);
  });

  test('ready + enabled: root and shell navigators each get an observer', () {
    final c = ProviderContainer(
      overrides: [
        screenViewObserverFactoryProvider.overrideWithValue(
          () => NavigatorObserver(),
        ),
      ],
    );
    addTearDown(c.dispose);
    final router = c.read(routerProvider);
    final shellObservers = shellOf(router).observers;
    expect(shellObservers, hasLength(1));
    final rootObservers = router.routerDelegate.builder.observers;
    expect(rootObservers, hasLength(1));
    expect(identical(shellObservers!.single, rootObservers.single), isFalse);
  });

  testWidgets('shell NoTransitionPages are named by their route template', (
    tester,
  ) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final router = c.read(routerProvider);
    late BuildContext context;
    await tester.pumpWidget(
      Builder(
        builder: (ctx) {
          context = ctx;
          return const SizedBox();
        },
      ),
    );

    final tabs = shellOf(
      router,
    ).routes.whereType<GoRoute>().where((r) => r.pageBuilder != null).toList();
    expect(tabs, isNotEmpty);
    for (final r in tabs) {
      final state = GoRouterState(
        router.configuration,
        uri: Uri.parse(r.path),
        matchedLocation: r.path,
        path: r.path,
        fullPath: r.path,
        pathParameters: const {},
        pageKey: ValueKey(r.path),
      );
      final page = r.pageBuilder!(context, state);
      expect(page.name, r.path, reason: 'page for ${r.path}');
    }
  });
}
