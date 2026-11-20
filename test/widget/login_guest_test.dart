import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tamir_uy_mobile_flutter/l10n/app_localizations.dart';
import 'package:tamir_uy_mobile_flutter/models/user_model.dart';
import 'package:tamir_uy_mobile_flutter/providers/auth_provider.dart';
import 'package:tamir_uy_mobile_flutter/repositories/auth_repository.dart';
import 'package:tamir_uy_mobile_flutter/screens/auth/login_screen.dart';
import 'package:tamir_uy_mobile_flutter/services/api_client.dart';

import '../support/localized_pump.dart';

class _Repo implements AuthRepository {
  _Repo({this.guestError});
  final Object? guestError;
  int guestCalls = 0;
  int loginCalls = 0;

  @override
  Future<AuthResponse> startGuestSession() async {
    guestCalls++;
    if (guestError != null) throw guestError!;
    return const AuthResponse(
      token: 'g',
      user: User(id: 'g1', isGuest: true),
    );
  }

  @override
  Future<AuthResponse> login(String email, String password) async {
    loginCalls++;
    return const AuthResponse(token: 'u', user: User(id: 'g1'));
  }

  @override
  dynamic noSuchMethod(Invocation i) => null;
}

const _continue = "Ro'yxatdan o'tmasdan davom etish";

Future<ProviderContainer> _pump(WidgetTester tester, _Repo repo,
    {bool fromGuest = false}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(repo)],
      child: wrapLocalized(LoginScreen(fromGuest: fromGuest),
          withProviderScope: false),
    ),
  );
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(tester.element(find.byType(LoginScreen)));
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('continue as guest starts a session', (tester) async {
    final repo = _Repo();
    final container = await _pump(tester, repo);
    expect(
      find.text('Xonalaringiz bu qurilmada mehmon sifatida saqlanadi.'),
      findsOneWidget,
    );
    final button = find.text(_continue);
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(repo.guestCalls, 1);
    expect(container.read(authStateProvider).isGuest, isTrue);
  });

  testWidgets('a failed guest start says so', (tester) async {
    final repo = _Repo(guestError: ApiException(message: 'x', statusCode: 503));
    await _pump(tester, repo);
    final button = find.text(_continue);
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(
      find.text(
          "Hozir ulanib bo'lmadi. Qayta urinib ko'ring yoki tizimga kiring."),
      findsOneWidget,
    );
  });

  testWidgets('fromGuest hides the continue button', (tester) async {
    await _pump(tester, _Repo(), fromGuest: true);
    expect(find.text(_continue), findsNothing);
    expect(find.byType(CloseButton), findsOneWidget);
  });

  testWidgets('fromGuest pops true before the session flips', (tester) async {
    final repo = _Repo();
    late ProviderContainer container;
    Object? popped = 'not popped';
    final observer = _PopObserver(() => container.read(authStateProvider));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('uz'),
          navigatorObservers: [observer],
          home: Builder(builder: (context) {
            container = ProviderScope.containerOf(context);
            return TextButton(
              onPressed: () async {
                popped = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(fromGuest: true),
                  ),
                );
              },
              child: const Text('open'),
            );
          }),
        ),
      ),
    );
    container.read(authStateProvider.notifier).setSession(
          const AuthResponse(token: 'g', user: User(id: 'g1', isGuest: true)),
        );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Login'), 'someone');
    await tester.enterText(find.widgetWithText(TextField, 'Parol'), 'pw-x');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Kirish'));
    await tester.pumpAndSettle();
    expect(repo.loginCalls, 1);
    expect(popped, isTrue);
    expect(find.byType(LoginScreen), findsNothing);
    // Popped while still a guest: the router's "/signup is for guests" rule
    // never sees a registered user on /signup and cannot reset the stack.
    expect(observer.stateAtPop?.isGuest, isTrue);
    expect(container.read(authStateProvider).isGuest, isFalse);
  });
}

class _PopObserver extends NavigatorObserver {
  _PopObserver(this._read);
  final AuthState Function() _read;
  AuthState? stateAtPop;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    stateAtPop ??= _read();
  }
}
