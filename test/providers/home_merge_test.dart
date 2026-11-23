import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:tamir_uy_mobile_flutter/models/api/api.dart';
import 'package:tamir_uy_mobile_flutter/models/design_selection_model.dart';
import 'package:tamir_uy_mobile_flutter/models/project_item.dart';
import 'package:tamir_uy_mobile_flutter/providers/apartment_provider.dart';
import 'package:tamir_uy_mobile_flutter/providers/projects_provider.dart';

RoomOut _room(String id, DateTime updatedAt) => RoomOut(
      id: id,
      apartmentId: 'apt',
      name: 'Xona',
      updatedAt: updatedAt,
    );

Apartment _apartment({
  required String id,
  String name = 'Apartment',
  String? address,
  int renovationStage = 1,
  List<RoomOut> rooms = const [],
}) =>
    Apartment(
      id: id,
      userId: 'user-1',
      name: name,
      address: address,
      createdAt: DateTime(2026, 1, 1),
      renovationStage: renovationStage,
      rooms: rooms,
    );

ProjectItem _localProject(String id, {String name = 'Local'}) => ProjectItem(
      id: id,
      name: name,
      location: '',
      roomCount: 0,
      createdAt: DateTime(2026, 2, 2),
    );

/// Builds a container with [apartmentsProvider] overridden by a fixed server
/// list, resolves it, then optionally seeds local optimistic projects.
Future<ProviderContainer> _container(
  List<Apartment> serverApartments, {
  List<ProjectItem> localProjects = const [],
}) async {
  final container = ProviderContainer(
    overrides: [
      apartmentsProvider.overrideWith((ref) async => serverApartments),
    ],
  );
  addTearDown(container.dispose);
  await container.read(apartmentsProvider.future);
  for (final p in localProjects) {
    container.read(homeStateProvider.notifier).addProject(p);
  }
  return container;
}

void main() {
  group('projectsProvider — server/local merge', () {
    test('maps a server apartment to a ProjectItem', () async {
      final container = await _container([
        _apartment(
          id: 'srv-1',
          name: 'Yangi kvartira',
          address: 'Chilonzor 12',
          renovationStage: 3,
          rooms: [
            _room('room-old', DateTime(2026, 1, 1)),
            _room('room-new', DateTime(2026, 5, 1)),
          ],
        ),
      ]);
      final projects = container.read(projectsProvider).requireValue;
      final p = projects.single;
      expect(p.id, 'srv-1');
      expect(p.name, 'Yangi kvartira');
      expect(p.location, 'Chilonzor 12');
      expect(p.roomCount, 2);
      // 1-based server stage 3 → 0-based RenovationStage index 2.
      expect(p.renovationStage, RenovationStage.values[2]);
      // Resume the most-recently-edited room in the Studio.
      expect(p.studioRoomId, 'room-new');
    });

    test('appends a local-only optimistic project after the server ones',
        () async {
      final container = await _container(
        [_apartment(id: 'srv-1', name: 'Server')],
        localProjects: [_localProject('local-1', name: 'Optimistik')],
      );
      final projects = container.read(projectsProvider).requireValue;
      expect(projects.map((p) => p.id), ['srv-1', 'local-1']);
      expect(projects.last.name, 'Optimistik');
    });

    test('dedups by id with the server winning', () async {
      final container = await _container(
        [_apartment(id: 'dup', name: 'Server copy')],
        // Same id as the server apartment → the optimistic entry drops out.
        localProjects: [_localProject('dup', name: 'Local copy')],
      );
      final projects = container.read(projectsProvider).requireValue;
      expect(projects, hasLength(1));
      expect(projects.single.name, 'Server copy');
    });

    test('an apartment with no rooms has a null studioRoomId', () async {
      final container = await _container([_apartment(id: 'srv-1')]);
      expect(container.read(projectsProvider).requireValue.single.studioRoomId,
          isNull);
    });

    test('a room with no furniture yet counts 0 models, and its area shows', () async {
      final container = await _container([
        _apartment(id: 'srv-1', rooms: [
          RoomOut(id: 'r1', apartmentId: 'srv-1', name: 'Yotoqxona', floorArea: 14.0, updatedAt: DateTime(2026)),
        ]),
      ]);
      final p = container.read(projectsProvider).requireValue.single;
      expect(p.floorArea, 14.0);
      expect(p.furnitureCount, 0);
    });
  });
}
