import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/l10n/app_localizations_uz.dart';
import 'package:tamir_uy_mobile_flutter/providers/auth_provider.dart';
import 'package:tamir_uy_mobile_flutter/repositories/auth_repository.dart';
import 'package:tamir_uy_mobile_flutter/screens/mebel/mebel_webview_screen.dart';

import '../support/localized_pump.dart';

class _NoRepo implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation i) => null;
}

void main() {
  testWidgets('signed out, the workshop asks to sign in instead of loading', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(_NoRepo())],
      child: wrapLocalized(const MebelWebViewScreen(), withProviderScope: false),
    ));
    await tester.pumpAndSettle();
    final l10n = AppLocalizationsUz();
    expect(find.text(l10n.profileMenuMebel), findsOneWidget); // the app bar
    expect(find.text(l10n.studioLoginRequired), findsOneWidget);
  });
}
