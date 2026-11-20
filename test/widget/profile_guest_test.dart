import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tamir_uy_mobile_flutter/l10n/app_localizations.dart';
import 'package:tamir_uy_mobile_flutter/models/business_profile.dart';
import 'package:tamir_uy_mobile_flutter/models/user_model.dart';
import 'package:tamir_uy_mobile_flutter/providers/auth_provider.dart';
import 'package:tamir_uy_mobile_flutter/providers/business_provider.dart';
import 'package:tamir_uy_mobile_flutter/providers/orders_provider.dart';
import 'package:tamir_uy_mobile_flutter/repositories/auth_repository.dart';
import 'package:tamir_uy_mobile_flutter/screens/auth/login_screen.dart';
import 'package:tamir_uy_mobile_flutter/screens/home/home_empty_screen.dart';
import 'package:tamir_uy_mobile_flutter/screens/profile/delete_account_dialog.dart';
import 'package:tamir_uy_mobile_flutter/screens/profile/e4_profile_settings_screen.dart';

class _Repo implements AuthRepository {
  final deletes = <String?>[];
  AuthResponse? loginResult;

  @override
  Future<void> deleteAccount({String? password}) async => deletes.add(password);

  @override
  Future<AuthResponse> login(String email, String password) async =>
      loginResult!;

  @override
  Future<void> clearSession() async {}

  @override
  dynamic noSuchMethod(Invocation i) => null;
}

class _Auth extends AuthNotifier {
  _Auth(super.repo, AuthState s) {
    state = s;
  }
}

const _guest = AuthAuthenticated(
  user: User(id: 'g1', isGuest: true),
  token: 'g',
);
const _registered = AuthAuthenticated(
  user: User(id: 'u1', username: 'ali'),
  token: 'u',
);

late AppLocalizations l10n;

Future<_Repo> _pumpProfile(WidgetTester t, AuthState auth) async {
  t.view.physicalSize = const Size(800, 2000);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  final repo = _Repo();
  final router = GoRouter(routes: [
    GoRoute(path: '/', builder: (_, _) => const E4ProfileSettingsScreen()),
    GoRoute(
      path: '/signup',
      builder: (_, _) => const Scaffold(body: Text('signup page')),
    ),
  ]);
  await t.pumpWidget(ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(repo),
      authStateProvider.overrideWith((ref) => _Auth(repo, auth)),
      projectsProvider.overrideWithValue(const AsyncData([])),
      currentUserProvider.overrideWith((ref) async =>
          auth is AuthAuthenticated ? auth.user : null),
      serverOrdersProvider.overrideWith((ref) async => []),
      accountRolesProvider.overrideWith((ref) async => const AccountRoles()),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('uz'),
    ),
  ));
  await t.pumpAndSettle();
  return repo;
}

void main() {
  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('uz'));
  });

  testWidgets('guest profile has CTA and no logout', (t) async {
    await _pumpProfile(t, _guest);
    expect(find.text('Mehmon'), findsOneWidget);
    expect(
      find.text(
          "Siz ro'yxatdan o'tmagansiz. Ilovani o'chirsangiz, xonalaringiz yo'qoladi."),
      findsOneWidget,
    );
    expect(find.text(l10n.profileMenuLogout), findsNothing);
    expect(find.text(l10n.profileMenuDeleteAccount), findsNothing);
    expect(find.text(l10n.commonVerifiedBadge), findsNothing);
    expect(find.text(l10n.profileGuestDelete), findsOneWidget);
    await t.tap(find.text("Ro'yxatdan o'tish yoki kirish"));
    await t.pumpAndSettle();
    expect(find.text('signup page'), findsOneWidget);
  });

  testWidgets('registered profile unchanged', (t) async {
    await _pumpProfile(t, _registered);
    expect(find.text('Mehmon'), findsNothing);
    expect(find.text(l10n.profileGuestCta), findsNothing);
    expect(find.text(l10n.profileMenuLogout), findsOneWidget);
    expect(find.text(l10n.profileMenuDeleteAccount), findsOneWidget);
    expect(find.text(l10n.commonVerifiedBadge), findsOneWidget);
  });

  testWidgets('guest delete shows the warning and no password', (t) async {
    final repo = await _pumpProfile(t, _guest);
    await t.tap(find.text(l10n.profileGuestDelete));
    await t.pumpAndSettle();
    expect(find.byType(DeleteAccountDialog), findsOneWidget);
    expect(
      find.text("Barcha xonalaringiz o'chiriladi. Buni qaytarib bo'lmaydi."),
      findsOneWidget,
    );
    expect(find.byType(TextField), findsNothing);
    await t.tap(find.widgetWithText(TextButton, l10n.actionDelete));
    await t.pumpAndSettle();
    expect(repo.deletes, [null]);
  });

  testWidgets('merge snackbar shows the count', (t) async {
    final repo = _Repo()
      ..loginResult = const AuthResponse(
        token: 'u',
        user: User(id: 'u9'),
        guestMergedRooms: 3,
      );
    await t.pumpWidget(ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('uz'),
        home: Scaffold(body: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<bool>(
              builder: (_) => const LoginScreen(fromGuest: true),
            )),
            child: const Text('open'),
          ),
        )),
      ),
    ));
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    await t.enterText(find.widgetWithText(TextField, 'Login'), 'someone');
    await t.enterText(find.widgetWithText(TextField, 'Parol'), 'pw-x');
    await t.tap(find.widgetWithText(ElevatedButton, 'Kirish'));
    await t.pumpAndSettle();
    expect(find.text("3 xona akkauntingizga qo'shildi"), findsOneWidget);
  });

  test('merged rooms text in three languages', () {
    expect(lookupAppLocalizations(const Locale('ru')).guestMergedRooms(1),
        contains('1'));
    expect(lookupAppLocalizations(const Locale('en')).guestMergedRooms(1),
        '1 room was added to your account');
    expect(lookupAppLocalizations(const Locale('en')).guestMergedRooms(2),
        '2 rooms were added to your account');
  });
}
