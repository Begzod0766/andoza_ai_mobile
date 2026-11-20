import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tamir_uy_mobile_flutter/config/router.dart';
import 'package:tamir_uy_mobile_flutter/l10n/app_localizations.dart';
import 'package:tamir_uy_mobile_flutter/models/user_model.dart';
import 'package:tamir_uy_mobile_flutter/providers/auth_provider.dart';
import 'package:tamir_uy_mobile_flutter/repositories/auth_repository.dart';
import 'package:tamir_uy_mobile_flutter/screens/auth/login_screen.dart';

class _Repo implements AuthRepository {
  @override
  Future<AuthResponse> login(String email, String password) async =>
      const AuthResponse(token: 'u', user: User(id: 'g1'));

  @override
  dynamic noSuchMethod(Invocation i) => null;
}

/// The same auth-driven refresh and `/signup` rule the app router has, over a
/// stand-in for the Studio, so the stack under `/signup` can be checked.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('signing in on /signup returns to the screen under it',
      (tester) async {
    final container = ProviderContainer(overrides: [
      authRepositoryProvider.overrideWithValue(_Repo()),
    ]);
    addTearDown(container.dispose);
    final router = GoRouter(
      initialLocation: '/studio',
      refreshListenable: container.read(authRouterRefreshProvider),
      redirect: (context, state) => state.matchedLocation == '/signup'
          ? signupRedirect(container.read(authStateProvider))
          : null,
      routes: [
        GoRoute(path: '/', builder: (_, _) => const Text('home')),
        GoRoute(
          path: '/studio',
          builder: (context, _) => Scaffold(
            body: TextButton(
              onPressed: () => context.push<bool>('/signup'),
              child: const Text('studio'),
            ),
          ),
        ),
        GoRoute(
          path: '/signup',
          builder: (_, _) => const LoginScreen(fromGuest: true),
        ),
      ],
    );
    container.read(authStateProvider.notifier).setSession(
          const AuthResponse(token: 'g', user: User(id: 'g1', isGuest: true)),
        );
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('uz'),
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('studio'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Login'), 'someone');
    await tester.enterText(find.widgetWithText(TextField, 'Parol'), 'pw-x');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Kirish'));
    await tester.pumpAndSettle();

    expect(container.read(authStateProvider).isGuest, isFalse);
    expect(find.byType(LoginScreen), findsNothing);
    expect(find.text('studio'), findsOneWidget);
  });

  test('the router refreshes on sign-in and sign-out, not on a guest upgrade',
      () {
    final container = ProviderContainer(overrides: [
      authRepositoryProvider.overrideWithValue(_Repo()),
    ]);
    addTearDown(container.dispose);
    var refreshes = 0;
    container.read(authRouterRefreshProvider).addListener(() => refreshes++);
    final auth = container.read(authStateProvider.notifier);

    auth.setSession(
        const AuthResponse(token: 'g', user: User(id: 'g1', isGuest: true)));
    expect(refreshes, 1);
    auth.setSession(const AuthResponse(token: 'u', user: User(id: 'g1')));
    expect(refreshes, 1);
  });
}
