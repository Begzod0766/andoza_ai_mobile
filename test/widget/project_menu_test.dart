import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/l10n/app_localizations.dart';
import 'package:tamir_uy_mobile_flutter/models/api/api.dart';
import 'package:tamir_uy_mobile_flutter/models/project_item.dart';
import 'package:tamir_uy_mobile_flutter/providers/apartment_provider.dart';
import 'package:tamir_uy_mobile_flutter/providers/projects_provider.dart';
import 'package:tamir_uy_mobile_flutter/repositories/apartment_repository.dart';
import 'package:tamir_uy_mobile_flutter/screens/projects/project_menu.dart';
import 'package:tamir_uy_mobile_flutter/utils/error_mapper.dart';

final l10n = lookupAppLocalizations(const Locale('uz'));

/// Records what the menu asked the server to do; [fail] makes every call throw.
class _FakeRepo implements ApartmentRepository {
  _FakeRepo({this.fail = false});
  final bool fail;
  final calls = <String>[];

  Future<void> _maybeFail() async {
    if (fail) throw Exception('offline');
  }

  @override
  Future<Apartment> updateApartment(String id, {int? renovationStage, String? name, String? address}) async {
    await _maybeFail();
    calls.add('renameApartment $id $name');
    return _flat.copyWith(name: name!);
  }

  @override
  Future<void> deleteApartment(String apartmentId) async {
    await _maybeFail();
    calls.add('deleteApartment $apartmentId');
  }

  @override
  Future<RoomOut> updateRoom(String roomId,
      {String? name,
      double? ceilingH,
      Map<String, dynamic>? geometry,
      Map<String, dynamic>? surfaces,
      List<dynamic>? furnitureLayout,
      Map<String, dynamic>? state}) async {
    await _maybeFail();
    calls.add('renameRoom $roomId $name');
    return _room('r1', name!);
  }

  @override
  Future<void> deleteRoom(String roomId) async {
    await _maybeFail();
    calls.add('deleteRoom $roomId');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

RoomOut _room(String id, String name) =>
    RoomOut(id: id, apartmentId: 'a1', name: name, updatedAt: DateTime(2026));

final _flat = Apartment(
  id: 'a1',
  userId: 'u1',
  name: 'Mening uyim',
  createdAt: DateTime(2026),
  rooms: [_room('r1', 'Mehmonxona'), _room('r2', 'Oshxona')],
);

final _project = ProjectItem(
  id: 'a1',
  name: 'Mening uyim',
  location: '',
  roomCount: 2,
  createdAt: DateTime(2026),
);

Future<(_FakeRepo, ProviderContainer)> _pump(WidgetTester tester,
    {bool fail = false, ProjectItem? project, bool listFails = false}) async {
  final repo = _FakeRepo(fail: fail);
  var loads = 0;
  final container = ProviderContainer(overrides: [
    apartmentRepositoryProvider.overrideWithValue(repo),
    apartmentsProvider.overrideWith((ref) async {
      loads++;
      if (listFails) throw Exception('offline');
      return [_flat];
    }),
  ]);
  addTearDown(container.dispose);
  // The screens behind the menu keep the list alive; so does this.
  container.listen(apartmentsProvider, (_, _) {});
  if (!listFails) await container.read(apartmentsProvider.future);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      locale: const Locale('uz'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: Center(child: ProjectMenuButton(project: project ?? _project))),
    ),
  ));
  await tester.pumpAndSettle();
  expect(loads, greaterThanOrEqualTo(1));
  return (repo, container);
}

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.byTooltip(l10n.projectMenuTooltip));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the menu button is a 48 dp target with a tooltip', (tester) async {
    await _pump(tester);
    final size = tester.getSize(find.byTooltip(l10n.projectMenuTooltip));
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
  });

  testWidgets('rename saves the new name and reloads the projects', (tester) async {
    final (repo, container) = await _pump(tester);
    await _open(tester);
    await tester.tap(find.text(l10n.projectRename));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, 'Mening uyim'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '  Dacha  ');
    await tester.tap(find.text(l10n.actionSave));
    await tester.pumpAndSettle();
    expect(repo.calls, ['renameApartment a1 Dacha']);
    expect(container.read(apartmentsProvider).isLoading || container.read(apartmentsProvider).hasValue, isTrue);
  });

  testWidgets('an empty name cannot be saved', (tester) async {
    final (repo, _) = await _pump(tester);
    await _open(tester);
    await tester.tap(find.text(l10n.projectRename));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '   ');
    await tester.pump();
    await tester.tap(find.text(l10n.actionSave));
    await tester.pumpAndSettle();
    expect(repo.calls, isEmpty);
  });

  testWidgets('delete asks first; cancel keeps the project', (tester) async {
    final (repo, _) = await _pump(tester);
    await _open(tester);
    await tester.tap(find.text(l10n.projectDelete));
    await tester.pumpAndSettle();
    expect(find.text(l10n.projectDeleteBody('Mening uyim', 2)), findsOneWidget);
    await tester.tap(find.text(l10n.actionCancel));
    await tester.pumpAndSettle();
    expect(repo.calls, isEmpty);
  });

  testWidgets('confirmed delete removes the project', (tester) async {
    final (repo, _) = await _pump(tester);
    await _open(tester);
    await tester.tap(find.text(l10n.projectDelete));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, l10n.actionDelete));
    await tester.pumpAndSettle();
    expect(repo.calls, ['deleteApartment a1']);
  });

  testWidgets('a project that only exists on the phone is removed locally', (tester) async {
    final local = ProjectItem(id: 'local-1', name: 'Qoralama', location: '', roomCount: 0, createdAt: DateTime(2026));
    final (repo, container) = await _pump(tester, project: local);
    container.read(homeStateProvider.notifier).addProject(local);
    await _open(tester);
    expect(find.text(l10n.projectRename), findsNothing);
    await tester.tap(find.text(l10n.projectDelete));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, l10n.actionDelete));
    await tester.pumpAndSettle();
    expect(repo.calls, isEmpty);
    expect(container.read(homeStateProvider).projects.where((p) => p.id == 'local-1'), isEmpty);
  });

  testWidgets('rooms can be renamed and deleted', (tester) async {
    final (repo, _) = await _pump(tester);
    await _open(tester);
    await tester.tap(find.text(l10n.projectRooms));
    await tester.pumpAndSettle();
    expect(find.text('Mehmonxona'), findsOneWidget);
    expect(find.text('Oshxona'), findsOneWidget);

    await tester.tap(find.byTooltip(l10n.roomMenuTooltip('Oshxona')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.actionDelete).last);
    await tester.pumpAndSettle();
    expect(find.text(l10n.roomDeleteBody('Oshxona')), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, l10n.actionDelete));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip(l10n.roomMenuTooltip('Mehmonxona')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.projectRename).last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Zal');
    await tester.tap(find.text(l10n.actionSave));
    await tester.pumpAndSettle();

    expect(repo.calls, ['deleteRoom r2', 'renameRoom r1 Zal']);
  });

  testWidgets('a failed delete says so and changes nothing', (tester) async {
    final (repo, _) = await _pump(tester, fail: true);
    await _open(tester);
    await tester.tap(find.text(l10n.projectDelete));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, l10n.actionDelete));
    await tester.pumpAndSettle();
    expect(repo.calls, isEmpty);
    expect(find.text(errorGeneric), findsOneWidget);
  });

  testWidgets('if the project list did not load, delete still goes to the server', (tester) async {
    final (repo, _) = await _pump(tester, listFails: true);
    await _open(tester);
    await tester.tap(find.text(l10n.projectDelete));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, l10n.actionDelete));
    await tester.pumpAndSettle();
    expect(repo.calls, ['deleteApartment a1']);
  });
}
