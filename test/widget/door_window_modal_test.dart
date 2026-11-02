import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/l10n/app_localizations.dart';
import 'package:tamir_uy_mobile_flutter/l10n/app_localizations_uz.dart';
import 'package:tamir_uy_mobile_flutter/models/room_model.dart';
import 'package:tamir_uy_mobile_flutter/screens/room_setup/door_window_modal.dart';

final l10n = AppLocalizationsUz();

typedef _Added = ({OpeningType type, double width, double height, double offset, double sill});

Future<List<_Added>> _pump(
  WidgetTester tester, {
  DoorWindowInitial? initial,
  bool showSill = false,
  VoidCallback? onDelete,
}) async {
  final added = <_Added>[];
  await tester.pumpWidget(MaterialApp(
    locale: const Locale('uz'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: SingleChildScrollView(
        child: DoorWindowModal(
          initial: initial,
          showSill: showSill,
          onDelete: onDelete,
          onAdd: (type, width, height, offset, sill) =>
              added.add((type: type, width: width, height: height, offset: offset, sill: sill)),
        ),
      ),
    ),
  ));
  return added;
}

void main() {
  testWidgets('without initial it looks as before: add button, no fields, no delete', (tester) async {
    final added = await _pump(tester);
    expect(find.text(l10n.openingAddToWall), findsOneWidget);
    expect(find.byKey(const Key('opening-width')), findsNothing);
    expect(find.byKey(const Key('opening-sill')), findsNothing);
    expect(find.text(l10n.openingDelete), findsNothing);
    await tester.tap(find.text(l10n.openingAddToWall));
    expect(added.single.width, 0.90);
    expect(added.single.height, 2.05);
    expect(added.single.sill, 0);
  });

  testWidgets('"other size" shows number fields that feed onAdd', (tester) async {
    final added = await _pump(tester);
    await tester.tap(find.text(l10n.openingSizeOther));
    await tester.pump();
    await tester.enterText(find.byKey(const Key('opening-width')), '93');
    await tester.enterText(find.byKey(const Key('opening-height')), '207');
    await tester.pump();
    await tester.tap(find.text(l10n.openingAddToWall));
    expect(added.single.width, closeTo(0.93, 1e-9));
    expect(added.single.height, closeTo(2.07, 1e-9));
  });

  testWidgets('initial values are filled in and saved', (tester) async {
    final added = await _pump(tester,
        initial: const DoorWindowInitial(
            type: OpeningType.dual, width: 1.23, height: 1.5, offset: 0.4, sill: 0.9),
        showSill: true);
    expect(find.text(l10n.openingSave), findsOneWidget);
    expect(find.text(l10n.openingAddToWall), findsNothing);
    expect(find.widgetWithText(TextField, '123'), findsOneWidget);
    expect(find.widgetWithText(TextField, '150'), findsOneWidget);
    expect(find.widgetWithText(TextField, '90'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('opening-sill')), '80');
    await tester.pump();
    await tester.tap(find.text(l10n.openingSave));
    final a = added.single;
    expect(a.type, OpeningType.dual);
    expect(a.width, closeTo(1.23, 1e-9));
    expect(a.offset, closeTo(0.4, 1e-9));
    expect(a.sill, closeTo(0.8, 1e-9));
  });

  testWidgets('the sill field is only for windows', (tester) async {
    await _pump(tester,
        initial: const DoorWindowInitial(
            type: OpeningType.single, width: 0.9, height: 2, offset: 0, sill: 0),
        showSill: true);
    expect(find.byKey(const Key('opening-sill')), findsNothing);
    await tester.tap(find.text(l10n.openingTypeWindow));
    await tester.pump();
    expect(find.byKey(const Key('opening-sill')), findsOneWidget);
  });

  testWidgets('delete is offered when onDelete is given', (tester) async {
    var deleted = 0;
    await _pump(tester,
        initial: const DoorWindowInitial(
            type: OpeningType.single, width: 0.9, height: 2, offset: 0, sill: 0),
        onDelete: () => deleted++);
    await tester.tap(find.text(l10n.openingDelete));
    expect(deleted, 1);
  });

  testWidgets('an empty or zero width keeps the button off', (tester) async {
    final added = await _pump(tester);
    await tester.tap(find.text(l10n.openingSizeOther));
    await tester.pump();
    await tester.enterText(find.byKey(const Key('opening-width')), '0');
    await tester.enterText(find.byKey(const Key('opening-height')), '200');
    await tester.pump();
    await tester.tap(find.text(l10n.openingAddToWall));
    expect(added, isEmpty);
  });

  testWidgets('a door switched to a window gets the 90 cm sill, not 0', (tester) async {
    final added = await _pump(tester,
        initial: const DoorWindowInitial(
            type: OpeningType.single, width: 0.9, height: 2, offset: 0.5, sill: 0),
        showSill: true);
    await tester.tap(find.text(l10n.openingTypeWindow));
    await tester.pump();
    expect(find.widgetWithText(TextField, '90'), findsWidgets);
    await tester.ensureVisible(find.text(l10n.openingSave));
    await tester.tap(find.text(l10n.openingSave));
    expect(added.single.sill, closeTo(0.9, 1e-9));
  });

  testWidgets('with a wall length the position is a cm field and stays on the wall', (tester) async {
    final added = <double>[];
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('uz'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(
          child: DoorWindowModal(
            initial: const DoorWindowInitial(
                type: OpeningType.single, width: 1.0, height: 2, offset: 0.5),
            maxOffset: 3.0,
            onAdd: (type, width, height, offset, sill) => added.add(offset),
          ),
        ),
      ),
    ));
    expect(find.byType(Slider), findsNothing);
    expect(find.widgetWithText(TextField, '50'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('opening-offset')), '250');
    await tester.pump();
    await tester.ensureVisible(find.text(l10n.openingSave));
    await tester.tap(find.text(l10n.openingSave));
    // 3.0 m wall, 1.0 m door: the left edge can be at most 2.0 m.
    expect(added.single, closeTo(2.0, 1e-9));
  });
}
