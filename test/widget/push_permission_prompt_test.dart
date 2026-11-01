import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tamir_uy_mobile_flutter/services/firebase_setup.dart';
import 'package:tamir_uy_mobile_flutter/services/push_permission.dart';
import 'package:tamir_uy_mobile_flutter/widgets/push_permission_prompt.dart';

import '../support/localized_pump.dart';

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
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firebaseReadyProvider.overrideWithValue(firebaseReady),
          pushPermissionProvider.overrideWithValue(perm),
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
