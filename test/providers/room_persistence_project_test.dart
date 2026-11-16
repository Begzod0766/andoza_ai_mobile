import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:tamir_uy_mobile_flutter/models/api/api.dart';
import 'package:tamir_uy_mobile_flutter/models/room_model.dart';
import 'package:tamir_uy_mobile_flutter/models/room_plan.dart';
import 'package:tamir_uy_mobile_flutter/providers/apartment_provider.dart';
import 'package:tamir_uy_mobile_flutter/providers/room_persistence_provider.dart';
import 'package:tamir_uy_mobile_flutter/providers/room_provider.dart';
import 'package:tamir_uy_mobile_flutter/repositories/apartment_repository.dart';

/// Which project does a newly saved room land in?
/// - started from "Yangi loyiha" (wizard / drawing) → a project of its own;
/// - anything else (e.g. a LiDAR rescan) → the newest existing project, so
///   several scans of the same room stay together and none is overwritten.
class _FakeApartments implements ApartmentRepository {
  final created = <String>[];
  final roomsIn = <String>[];
  final bodies = <RoomCreate>[];
  bool failNextRoom = false;

  @override
  Future<List<Apartment>> listApartments() async => [
        Apartment(id: 'newest', userId: 'u', name: 'Eski', createdAt: DateTime(2026)),
      ];

  @override
  Future<Apartment> createApartment({required String name, String? address, String? developer}) async {
    final id = 'apt-${created.length + 1}';
    created.add(id);
    return Apartment(id: id, userId: 'u', name: name, createdAt: DateTime(2026));
  }

  @override
  Future<RoomOut> createRoom(String apartmentId, RoomCreate body) async {
    if (failNextRoom) {
      failNextRoom = false;
      throw Exception('offline');
    }
    roomsIn.add(apartmentId);
    bodies.add(body);
    return RoomOut(id: 'room-${roomsIn.length}', apartmentId: apartmentId, name: body.name, updatedAt: DateTime(2026));
  }

  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError('${i.memberName}');
}

const _body = RoomCreate(name: 'Xona', ceilingH: 2.8, geometry: RoomGeometryCreate(walls: []));

void main() {
  late _FakeApartments repo;
  late ProviderContainer c;
  var n = 0;

  void newLocalRoom() => c.read(activeRoomProvider.notifier).setLocal(Room(
        id: 'local-${++n}',
        name: 'Xona',
        dimensions: const RoomDimensions(width: 3, height: 2.8, length: 4),
        createdAt: DateTime(2026),
      ));

  setUp(() {
    repo = _FakeApartments();
    c = ProviderContainer(overrides: [apartmentRepositoryProvider.overrideWithValue(repo)]);
  });
  tearDown(() => c.dispose());

  test('a room started from "Yangi loyiha" gets its own new project', () async {
    c.read(roomPersistenceProvider.notifier).startNewProject();
    newLocalRoom();
    await c.read(roomPersistenceProvider.notifier).ensurePersisted(override: _body);
    expect(repo.created, ['apt-1']);
    expect(repo.roomsIn, ['apt-1']);
  });

  test('rescans join the newest project, each as its own room', () async {
    final p = c.read(roomPersistenceProvider.notifier)..continueCurrentProject();
    newLocalRoom();
    await p.ensurePersisted(override: _body);
    newLocalRoom();
    await p.ensurePersisted(override: _body);
    expect(repo.created, isEmpty);
    expect(repo.roomsIn, ['newest', 'newest']);
  });

  test('a retry after a failed save reuses the project it already made', () async {
    final p = c.read(roomPersistenceProvider.notifier)..startNewProject();
    newLocalRoom();
    repo.failNextRoom = true;
    await p.ensurePersisted(override: _body);
    expect(c.read(roomPersistenceProvider).hasError, isTrue);
    await p.ensurePersisted(override: _body);
    expect(repo.created, ['apt-1']);
    expect(repo.roomsIn, ['apt-1']);
  });

  test('the "new project" wish is used once, then rooms join that newest project again', () async {
    final p = c.read(roomPersistenceProvider.notifier)..startNewProject();
    newLocalRoom();
    await p.ensurePersisted(override: _body);
    newLocalRoom();
    await p.ensurePersisted(override: _body);
    expect(repo.created, ['apt-1']);
    expect(repo.roomsIn, ['apt-1', 'newest']);
  });

  test('the picked room type of the plan is sent with the room', () async {
    final p = c.read(roomPersistenceProvider.notifier)..startNewProject();
    c.read(activeRoomPlanProvider.notifier).setPlan(
          RoomPlan.rectangle(
            width: 2.0,
            length: 2.5,
            ceilingHeightM: 2.7,
            source: RoomSource.wizard,
            roomType: 'hammom',
          ),
          legacyRoomId: 'local-typed',
        );
    await p.ensurePersisted();
    expect(repo.bodies.single.roomType, 'hammom');
    expect(repo.bodies.single.toJson()['room_type'], 'hammom');
  });

  test('no type picked: room_type is not sent', () async {
    final p = c.read(roomPersistenceProvider.notifier)..startNewProject();
    c.read(activeRoomPlanProvider.notifier).setPlan(
          RoomPlan.rectangle(
            width: 3.2,
            length: 4.5,
            ceilingHeightM: 2.8,
            source: RoomSource.wizard,
          ),
          legacyRoomId: 'local-untyped',
        );
    await p.ensurePersisted();
    expect(repo.bodies.single.toJson().containsKey('room_type'), isFalse);
  });
}
