import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/config/router.dart';
import 'package:tamir_uy_mobile_flutter/l10n/app_localizations.dart';
import 'package:tamir_uy_mobile_flutter/models/user_model.dart';
import 'package:tamir_uy_mobile_flutter/providers/auth_provider.dart';
import 'package:tamir_uy_mobile_flutter/repositories/auth_repository.dart';
import 'package:tamir_uy_mobile_flutter/services/push_router.dart';

class _NoRepo implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError();
}

class _FakeAuth extends AuthNotifier {
  _FakeAuth() : super(_NoRepo());
  void set(AuthState s) => state = s;
}

const _signedIn = AuthAuthenticated(user: User(id: 'u1'), token: 't');

void main() {
  group('safePushRoute', () {
    test('allowed routes pass', () {
      for (final r in [
        '/studio/3626078d-a9b0-46a2-9789-5befa9f60684',
        '/profile/e6',
        '/masters/u3',
      ]) {
        expect(safePushRoute({'kind': 'x', 'route': r}), r);
      }
    });

    test('anything else goes home', () {
      for (final data in <Map<String, dynamic>>[
        {'route': '/studio/../login'},
        {'route': '/business/orders'},
        {'route': 'https://evil.example'},
        {'kind': 'order'},
        {'route': ''},
        {'route': 42},
        {'route': '/studio/3626078d-a9b0-46a2-9789-5befa9f60684/x'},
        {'route': '/profile/e6?x=1'},
      ]) {
        expect(safePushRoute(data), '/', reason: '$data');
      }
    });
  });

  group('PushTapHandler.openRoute', () {
    test('signed out: the route waits in pendingPushRouteProvider', () {
      final auth = _FakeAuth();
      final c = ProviderContainer(
        overrides: [authStateProvider.overrideWith((ref) => auth)],
      );
      addTearDown(c.dispose);
      final opened = <String>[];
      final handler = PushTapHandler(c.read, navigate: opened.add);
      handler.openRoute('/masters/u3');
      expect(c.read(pendingPushRouteProvider), '/masters/u3');
      expect(opened, isEmpty);
    });

    test('signed in: goes straight there; unsafe payloads go home', () {
      final auth = _FakeAuth()..set(_signedIn);
      final c = ProviderContainer(
        overrides: [authStateProvider.overrideWith((ref) => auth)],
      );
      addTearDown(c.dispose);
      final opened = <String>[];
      final handler = PushTapHandler(c.read, navigate: opened.add);
      handler.openRoute('/profile/e6');
      handler.openRoute('/business/orders');
      handler.openRoute(null);
      expect(opened, ['/profile/e6', '/', '/']);
      expect(c.read(pendingPushRouteProvider), isNull);
    });
  });

  testWidgets('a pending route opens after sign-in', (tester) async {
    final auth = _FakeAuth();
    final c = ProviderContainer(
      overrides: [authStateProvider.overrideWith((ref) => auth)],
    );
    addTearDown(c.dispose);
    final router = c.read(routerProvider);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    router.go('/login');
    await tester.pump();
    expect(router.routerDelegate.currentConfiguration.uri.path, '/login');

    c.read(pendingPushRouteProvider.notifier).state = '/profile/e6';
    auth.set(_signedIn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(router.routerDelegate.currentConfiguration.uri.path, '/profile/e6');
    expect(c.read(pendingPushRouteProvider), isNull);

    // Let the splash screen's timers run out before the test ends.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 5));
  });
}

