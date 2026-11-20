import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tamir_uy_mobile_flutter/models/user_model.dart';
import 'package:tamir_uy_mobile_flutter/providers/auth_provider.dart';
import 'package:tamir_uy_mobile_flutter/repositories/auth_repository.dart';
import 'package:tamir_uy_mobile_flutter/services/firebase_setup.dart';
import 'package:tamir_uy_mobile_flutter/services/push_permission.dart';
import 'package:tamir_uy_mobile_flutter/widgets/push_permission_prompt.dart';

import '../support/localized_pump.dart';

class _NoRepo implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError();
}

class _GuestAuth extends AuthNotifier {
  _GuestAuth() : super(_NoRepo()) {
    state = const AuthAuthenticated(
      user: User(id: 'g1', isGuest: true),
      token: 'g',
    );
  }
}

class _FakePermission implements PushPermission {
  _FakePermission({this.granted = false});
  bool granted;
  int requests = 0;

  @override
  Future<bool> request() async {
    requests++;
    return granted = true;
  }

  @override
  Future<bool> isGranted() async => granted;
}

void main() {
  Future<void> pump(
    WidgetTester tester,
    _FakePermission perm, {
    bool firebaseReady = true,
    bool guest = false,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firebaseReadyProvider.overrideWithValue(firebaseReady),
          pushPermissionProvider.overrideWithValue(perm),
          if (guest) authStateProvider.overrideWith((ref) => _GuestAuth()),
        ],
        child: wrapLocalized(
          const PushPermissionPrompt(child: Text('home')),
          withProviderScope: false,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('no permission dialog for a guest', (tester) async {
    final perm = _FakePermission();
    await pump(tester, perm, guest: true);
    expect(find.text('Xabar beraylikmi?'), findsNothing);
    expect(perm.requests, 0);
  });

  testWidgets('the prompt shows once', (tester) async {
    final perm = _FakePermission();
    await pump(tester, perm);
    expect(find.text('Xabar beraylikmi?'), findsOneWidget);

    await tester.tap(find.text('Keyinroq'));
    await tester.pumpAndSettle();
    expect(find.text('Xabar beraylikmi?'), findsNothing);
    expect(perm.requests, 0);

    await tester.pumpWidget(const SizedBox());
    await pump(tester, perm);
    expect(find.text('Xabar beraylikmi?'), findsNothing);
  });

  testWidgets('yes asks the system', (tester) async {
    final perm = _FakePermission();
    await pump(tester, perm);
    await tester.tap(find.text('Ha'));
    await tester.pumpAndSettle();
    expect(perm.requests, 1);
    expect(find.text('Xabar beraylikmi?'), findsNothing);
    final prefs = await SharedPreferences.getInstance();
    expect(await shouldAskForPush(prefs), isFalse);
  });

  testWidgets('no prompt when already granted or Firebase is off',
      (tester) async {
    await pump(tester, _FakePermission(granted: true));
    expect(find.text('Xabar beraylikmi?'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    await pump(tester, _FakePermission(), firebaseReady: false);
    expect(find.text('Xabar beraylikmi?'), findsNothing);
  });
}
