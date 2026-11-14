import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tamir_uy_mobile_flutter/features/tour/startup_dialogs.dart';
import 'package:tamir_uy_mobile_flutter/services/firebase_setup.dart';
import 'package:tamir_uy_mobile_flutter/services/push_permission.dart';
import 'package:tamir_uy_mobile_flutter/widgets/push_permission_prompt.dart';

import '../support/localized_pump.dart';

class _FakePermission implements PushPermission {
  @override
  Future<bool> request() async => true;

  @override
  Future<bool> isGranted() async => false;
}

void main() {
  Future<ProviderContainer> pump(WidgetTester tester) async {
    final container = ProviderContainer(overrides: [
      firebaseReadyProvider.overrideWithValue(true),
      pushPermissionProvider.overrideWithValue(_FakePermission()),
    ]);
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: wrapLocalized(
          const PushPermissionPrompt(child: Text('home')),
          withProviderScope: false,
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('push dialog marks a startup dialog as shown', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final c = await pump(tester);
    expect(find.text('Xabar beraylikmi?'), findsOneWidget);
    expect(c.read(startupDialogShownProvider), isTrue);
  });

  testWidgets('no dialog leaves the flag false', (tester) async {
    SharedPreferences.setMockInitialValues({pushPromptAnsweredKey: true});
    final c = await pump(tester);
    expect(find.text('Xabar beraylikmi?'), findsNothing);
    expect(c.read(startupDialogShownProvider), isFalse);
  });
}
