import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tamir_uy_mobile_flutter/features/tour/home_tour_help_button.dart';
import 'package:tamir_uy_mobile_flutter/features/tour/home_tour_launcher.dart';
import 'package:tamir_uy_mobile_flutter/features/tour/home_tour_store.dart';
import 'package:tamir_uy_mobile_flutter/features/tour/startup_dialogs.dart';
import 'package:tamir_uy_mobile_flutter/l10n/app_localizations.dart';
import 'package:tamir_uy_mobile_flutter/screens/home/home_empty_screen.dart';
import 'package:tamir_uy_mobile_flutter/screens/home/home_with_projects_screen.dart';

import '../support/localized_pump.dart';

ProjectItem _project() => ProjectItem(
      id: 'p-1',
      name: 'Mening loyiham',
      location: 'Chilonzor',
      roomCount: 1,
      createdAt: DateTime(2026, 1, 1),
    );

late ProviderContainer _container;

Future<void> _pump(
  WidgetTester t, {
  required bool done,
  bool startupDialog = false,
  AsyncValue<List<ProjectItem>>? projects,
}) async {
  // Tall enough for the tour card to fit below the lowest target.
  t.view.physicalSize = const Size(800, 1600);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  SharedPreferences.setMockInitialValues({if (done) homeTourDoneKey: true});
  await t.pumpWidget(
    UncontrolledProviderScope(
      container: _container = ProviderContainer(overrides: [
        projectsProvider.overrideWithValue(projects ?? AsyncData([_project()])),
      ]),
      child: wrapLocalized(const Scaffold(body: HomeWithProjectsScreen()), withProviderScope: false),
    ),
  );
  if (startupDialog) _container.read(startupDialogShownProvider.notifier).state = true;
  await t.pump();
}

Future<void> _settle(WidgetTester t, {int ms = 3000}) async {
  for (var i = 0; i < ms ~/ 500; i++) {
    await t.pump(const Duration(milliseconds: 500));
  }
}

AppLocalizations _l(WidgetTester t) => AppLocalizations.of(t.element(find.byType(Scaffold).first))!;

Future<bool> _done() async => isHomeTourDone(await SharedPreferences.getInstance());

void main() {
  testWidgets('(a) first open, no dialog: tour card appears after 1500 ms', (t) async {
    await _pump(t, done: false);
    await t.pump(const Duration(milliseconds: 1000));
    expect(find.text(_l(t).tourSkip), findsNothing);
    await _settle(t);
    expect(find.text(_l(t).tourSkip), findsOneWidget);
  });

  testWidgets('(b) already done: no tour', (t) async {
    await _pump(t, done: true);
    await _settle(t, ms: 4000);
    expect(find.text(_l(t).tourSkip), findsNothing);
  });

  testWidgets('(c) startup dialog shown: no tour, flag not set', (t) async {
    await _pump(t, done: false, startupDialog: true);
    await _settle(t, ms: 4000);
    expect(find.text(_l(t).tourSkip), findsNothing);
    expect(await _done(), isFalse);
  });

  testWidgets('(d) done, but a replay request shows the tour', (t) async {
    await _pump(t, done: true);
    await _settle(t, ms: 2000);
    expect(find.text(_l(t).tourSkip), findsNothing);
    _container.read(homeTourRequestProvider.notifier).state++;
    await t.pump();
    await _settle(t);
    expect(find.text(_l(t).tourSkip), findsOneWidget);
  });

  testWidgets('(e) projects loading: no tour', (t) async {
    await _pump(t, done: false, projects: const AsyncLoading());
    await t.pump(const Duration(milliseconds: 2000));
    await t.pump(const Duration(milliseconds: 2000));
    expect(find.text(_l(t).tourSkip), findsNothing);
    expect(await _done(), isFalse);
  });

  testWidgets('(f) skip marks the tour done', (t) async {
    await _pump(t, done: false);
    await _settle(t);
    expect(await _done(), isFalse);
    await t.tap(find.text(_l(t).tourSkip));
    await _settle(t);
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    expect(await t.runAsync(_done), isTrue);
  });

  testWidgets('(g) a dialog on top blocks the auto-start', (t) async {
    await _pump(t, done: false);
    showDialog<void>(
      context: t.element(find.byType(Scaffold).first),
      builder: (_) => const AlertDialog(content: Text('dlg')),
    );
    await t.pump();
    await _settle(t, ms: 4000);
    expect(find.text(_l(t).tourSkip), findsNothing);
    expect(await _done(), isFalse);
  });

  testWidgets('(h) help button is shown once and replays', (t) async {
    await _pump(t, done: true);
    expect(find.byType(HomeTourHelpButton), findsOneWidget);
    await t.tap(find.byIcon(Icons.help_outline));
    await t.pump();
    await _settle(t);
    expect(find.text(_l(t).tourSkip), findsOneWidget);
  });
}
