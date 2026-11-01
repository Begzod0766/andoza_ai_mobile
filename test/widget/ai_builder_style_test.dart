import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/l10n/app_localizations.dart';
import 'package:tamir_uy_mobile_flutter/models/api/api.dart';
import 'package:tamir_uy_mobile_flutter/providers/ai_provider.dart';
import 'package:tamir_uy_mobile_flutter/repositories/ai_repository.dart';
import 'package:tamir_uy_mobile_flutter/screens/studio/ai_builder_sheet.dart';

/// Records the requests the sheet sends; the stream ends at once.
class _FakeAi implements AiRepository {
  final prompts = <String>[];

  @override
  Stream<AiBuildEvent> build(String roomId, String prompt) {
    prompts.add(prompt);
    return const Stream.empty();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<_FakeAi> _pump(
  WidgetTester tester, {
  Locale locale = const Locale('uz'),
}) async {
  final ai = _FakeAi();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [aiRepositoryProvider.overrideWithValue(ai)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: locale,
        home: const Scaffold(body: AiBuilderSheet(roomId: 'r1')),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return ai;
}

Future<void> _send(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField), text);
  await tester.tap(find.byIcon(Icons.auto_awesome).last);
  await tester.pumpAndSettle();
}

void main() {
  test('styledPrompt puts the style in front, as the backend names it', () {
    expect(styledPrompt('divan qo\'sh', null), 'divan qo\'sh');
    expect(
      styledPrompt('divan qo\'sh', 'hitech'),
      'Hi-Tech uslubida. divan qo\'sh',
    );
    expect(styledPrompt('x', 'unknown'), 'x');
  });

  testWidgets('with no style picked the request goes as typed', (tester) async {
    final ai = await _pump(tester);
    await _send(tester, 'divan qo\'sh');
    expect(ai.prompts, ['divan qo\'sh']);
  });

  testWidgets('a picked style is put in front, and a second tap clears it', (
    tester,
  ) async {
    final ai = await _pump(tester);
    await tester.tap(find.text('Loft'));
    await tester.pump();
    await _send(tester, 'divan qo\'sh');
    expect(ai.prompts.last, 'Loft uslubida. divan qo\'sh');

    await tester.tap(find.text('Loft'));
    await tester.pump();
    await _send(tester, 'stol qo\'sh');
    expect(ai.prompts.last, 'stol qo\'sh');
  });

  testWidgets(
    'in Russian the chip is Russian but the request names it as the backend does',
    (tester) async {
      final ai = await _pump(tester, locale: const Locale('ru'));
      await tester.tap(find.text('Хай-тек'));
      await tester.pump();
      await _send(tester, 'добавь диван');
      expect(ai.prompts.last, 'Hi-Tech uslubida. добавь диван');
    },
  );
}
