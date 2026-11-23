import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tamir_uy_mobile_flutter/screens/auth/login_screen.dart';

import '../support/localized_pump.dart';

/// No SMS provider is connected yet (SMS_LOGIN_ENABLED is off by default), so
/// the app opens on login/password with registration one tap away — the phone
/// / OTP form must not be offered.
void main() {
  Widget wrap() => wrapLocalized(const LoginScreen());

  testWidgets('opens on login + password, with the brand and no SMS form', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('andoza.ai'), findsOneWidget);
    expect(find.text("Ta'mir va interyer loyihalaringiz bir joyda"), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Login'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Parol'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Kirish'), findsOneWidget);

    expect(find.widgetWithText(TextField, '90 123 45 67'), findsNothing);
    expect(find.textContaining('OTP'), findsNothing);
    // First screen: there is nowhere to go "back" to.
    expect(find.text('Orqaga'), findsNothing);
  });

  testWidgets('empty login + password is caught before any network call', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Kirish'));
    await tester.pump();
    expect(find.textContaining('Login va parol majburiy'), findsOneWidget);
  });

  testWidgets('"Ro\'yxatdan o\'tish" opens registration, and back returns to login', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    final register = find.text("Ro'yxatdan o'tish");
    await tester.ensureVisible(register);
    await tester.pumpAndSettle();
    await tester.tap(register);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, 'Parolni tasdiqlang'), findsOneWidget);

    await tester.tap(find.text('Orqaga'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, 'Parolni tasdiqlang'), findsNothing);
    expect(find.widgetWithText(ElevatedButton, 'Kirish'), findsOneWidget);
  });

  testWidgets('password visibility toggle is labelled for screen readers', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();
    expect(find.byTooltip("Parolni ko'rsatish"), findsOneWidget);
    await tester.tap(find.byTooltip("Parolni ko'rsatish"));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Parolni yashirish'), findsOneWidget);
  });

  testWidgets('the version under the card is the installed app version', (tester) async {
    PackageInfo.setMockInitialValues(
      appName: 'AndozaAI',
      packageName: 'uz.andozaai.app',
      version: '1.0.3',
      buildNumber: '36',
      buildSignature: '',
    );
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();
    expect(find.text('AndozaAI v1.0.3'), findsOneWidget);
    expect(find.text('AndozaAI v1.0.0'), findsNothing);
  });
}
