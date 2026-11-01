import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/models/user_model.dart';
import 'package:tamir_uy_mobile_flutter/providers/auth_provider.dart';
import 'package:tamir_uy_mobile_flutter/repositories/auth_repository.dart';
import 'package:tamir_uy_mobile_flutter/screens/auth/login_screen.dart';
import 'package:tamir_uy_mobile_flutter/services/apple_sign_in_service.dart';

import '../support/localized_pump.dart';

class _FakeApple extends AppleSignInService {
  const _FakeApple(this.credential);
  final AppleCredential? credential;

  @override
  Future<AppleCredential?> getCredential() async => credential;
}

class _FakeRepo implements AuthRepository {
  _FakeRepo({this.error});
  final Object? error;
  final calls = <(String, String?)>[];

  @override
  Future<AuthResponse> loginWithApple(
    String identityToken, {
    String? name,
  }) async {
    calls.add((identityToken, name));
    if (error != null) throw error!;
    return const AuthResponse(
      token: 'acc',
      user: User(id: 'u1'),
    );
  }

  @override
  dynamic noSuchMethod(Invocation i) => null;
}

const _appleLabel = 'Apple bilan kirish';

void main() {
  Future<ProviderContainer> pump(
    WidgetTester tester,
    AppleSignInService apple,
    _FakeRepo repo,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appleSignInServiceProvider.overrideWithValue(apple),
          authRepositoryProvider.overrideWithValue(repo),
        ],
        child: wrapLocalized(const LoginScreen(), withProviderScope: false),
      ),
    );
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(tester.element(find.byType(LoginScreen)));
  }

  Future<void> tapApple(WidgetTester tester) async {
    final button = find.widgetWithText(FilledButton, _appleLabel);
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  test('offered on iOS only', () {
    expect(AppleSignInService.isAvailableFor(TargetPlatform.iOS), isTrue);
    expect(AppleSignInService.isAvailableFor(TargetPlatform.android), isFalse);
  });

  test('full name joins the parts Apple shared', () {
    expect(AppleSignInService.fullName('Ali', 'Valiyev'), 'Ali Valiyev');
    expect(AppleSignInService.fullName(' Ali ', null), 'Ali');
    expect(AppleSignInService.fullName(null, ''), isNull);
  });

  testWidgets('no Apple button on Android', (tester) async {
    await pump(tester, const _FakeApple(null), _FakeRepo());
    expect(find.widgetWithText(FilledButton, _appleLabel), findsNothing);
  });

  testWidgets('on iOS the credential is exchanged and the session is set', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final repo = _FakeRepo();
    final container = await pump(
      tester,
      const _FakeApple(AppleCredential(identityToken: 'tok', name: 'Ali')),
      repo,
    );

    await tapApple(tester);

    expect(repo.calls, [('tok', 'Ali')]);
    expect(container.read(authStateProvider), isA<AuthAuthenticated>());
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('cancelling the Apple sheet makes no API call', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final repo = _FakeRepo();
    await pump(tester, const _FakeApple(null), repo);

    await tapApple(tester);

    expect(repo.calls, isEmpty);
    expect(
      find.text("Apple orqali kirib bo'lmadi. Qayta urinib ko'ring."),
      findsNothing,
    );
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('a rejected token (401) shows the Apple failure text', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final repo = _FakeRepo(error: AuthException('yaroqsiz', statusCode: 401));
    await pump(
      tester,
      const _FakeApple(AppleCredential(identityToken: 'bad')),
      repo,
    );

    await tapApple(tester);

    expect(
      find.text("Apple orqali kirib bo'lmadi. Qayta urinib ko'ring."),
      findsOneWidget,
    );
    debugDefaultTargetPlatformOverride = null;
  });
}
