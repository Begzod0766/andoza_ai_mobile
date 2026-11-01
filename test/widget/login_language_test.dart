import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tamir_uy_mobile_flutter/providers/auth_provider.dart';
import 'package:tamir_uy_mobile_flutter/providers/locale_provider.dart';
import 'package:tamir_uy_mobile_flutter/repositories/auth_repository.dart';
import 'package:tamir_uy_mobile_flutter/screens/auth/login_screen.dart';

import '../support/localized_pump.dart';

class _NoRepo implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation i) => null;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({'app_locale': 'uz'}));

  testWidgets('the language can be changed before signing in', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(_NoRepo())],
      child: wrapLocalized(const LoginScreen(), withProviderScope: false),
    ));
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(tester.element(find.byType(LoginScreen)));

    await tester.tap(find.textContaining("O'zbekcha"));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Русский').last);
    await tester.pumpAndSettle();

    expect(container.read(localeProvider), const Locale('ru'));
    expect(find.textContaining('Русский'), findsOneWidget); // the button now
  });
}
