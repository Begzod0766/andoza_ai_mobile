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

  testWidgets('guest mode switched off (503) hides the button', (tester) async {
    final repo = _Repo(guestError: ApiException(message: 'x', statusCode: 503));
    await _pump(tester, repo);
    final button = find.text(_continue);
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.text(_continue), findsNothing);
    expect(
      find.text('Xonalaringiz bu qurilmada mehmon sifatida saqlanadi.'),
      findsNothing,
    );
    // Nothing to retry: no "couldn't connect" message either.
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('after a 503 at cold start the button is not offered',
      (tester) async {
    final repo = _Repo(guestError: ApiException(message: 'x', statusCode: 503));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(repo)],
        child: Consumer(builder: (context, ref, _) {
          return wrapLocalized(const _ColdStartThenLogin(),
              withProviderScope: false);
        }),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text(_continue), findsNothing);
  });

  testWidgets('a failed guest start says so', (tester) async {
    final repo = _Repo(guestError: ApiException(message: 'offline'));
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

  testWidgets('fromGuest flips the session, then pops true', (tester) async {
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
    // Signed in by the time the caller (the sign-up sheet) gets `true`.
    expect(observer.stateAtPop, isA<AuthAuthenticated>());
    expect(observer.stateAtPop?.isGuest, isFalse);
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

/// Tries a guest session (as the splash does), then shows the login screen.
class _ColdStartThenLogin extends ConsumerStatefulWidget {
  const _ColdStartThenLogin();

  @override
  ConsumerState<_ColdStartThenLogin> createState() => _ColdStartThenLoginState();
}

class _ColdStartThenLoginState extends ConsumerState<_ColdStartThenLogin> {
  bool _done = false;

  @override
  void initState() {
    super.initState();
    ref.read(authStateProvider.notifier).startGuestSession().then((_) {
      if (mounted) setState(() => _done = true);
    });
  }

  @override
  Widget build(BuildContext context) =>
      _done ? const LoginScreen() : const SizedBox.shrink();
}
