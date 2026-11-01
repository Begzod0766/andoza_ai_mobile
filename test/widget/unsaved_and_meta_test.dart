import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/l10n/app_localizations.dart';
import 'package:tamir_uy_mobile_flutter/screens/profile/e5_projects_screen.dart';
import 'package:tamir_uy_mobile_flutter/screens/studio/studio_webview_screen.dart';
import 'package:tamir_uy_mobile_flutter/widgets/common/unsaved_changes_guard.dart';

Widget _app({required bool hasChanges}) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('uz'),
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => UnsavedChangesGuard(
                  hasChanges: hasChanges,
                  child: Scaffold(appBar: AppBar(), body: const Text('editor')),
                ),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );

void main() {
  final l10n = lookupAppLocalizations(const Locale('uz'));

  testWidgets('back with unsaved edits asks; "Qolish" stays, "Chiqish" leaves', (tester) async {
    await tester.pumpWidget(_app(hasChanges: true));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text(l10n.unsavedChangesTitle), findsOneWidget);

    await tester.tap(find.text(l10n.unsavedChangesStay));
    await tester.pumpAndSettle();
    expect(find.text('editor'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.unsavedChangesLeave));
    await tester.pumpAndSettle();
    expect(find.text('editor'), findsNothing);
    expect(find.text('open'), findsOneWidget);
  });

  testWidgets('nothing to lose: back just leaves', (tester) async {
    await tester.pumpWidget(_app(hasChanges: false));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text(l10n.unsavedChangesTitle), findsNothing);
    expect(find.text('open'), findsOneWidget);
  });

  test('the studio page is told it runs inside the app', () {
    expect(studioPageUrl('https://x.uz', '/studio/r1'), 'https://x.uz/studio/r1?app=1');
    expect(studioPageUrl('https://x.uz', '/studio/r1?focus=1'), 'https://x.uz/studio/r1?focus=1&app=1');
  });

  test("the studio page opens in the app's language", () {
    expect(studioPageUrl('https://x.uz', '/studio/r1', language: 'ru'), 'https://x.uz/studio/r1?app=1&lang=ru');
    expect(
      studioPageUrl('https://x.uz', '/studio/r1?place=f1', language: 'en'),
      'https://x.uz/studio/r1?place=f1&app=1&lang=en',
    );
  });

  test('project meta skips an empty address instead of printing "· ·"', () {
    final d = DateTime(2026, 9, 30);
    expect(projectMetaDetails('', d), '30.9.2026');
    expect(projectMetaDetails('  ', d), '30.9.2026');
    expect(projectMetaDetails('Chilonzor', d), 'Chilonzor · 30.9.2026');
    expect(
      l10n.profileProjectMeta(6, projectMetaDetails('', d)),
      '6 xona · 30.9.2026',
    );
  });
}
