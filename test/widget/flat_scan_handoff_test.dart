import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/models/api/api.dart';
import 'package:tamir_uy_mobile_flutter/providers/apartment_provider.dart';
import 'package:tamir_uy_mobile_flutter/providers/room_persistence_provider.dart';
import 'package:tamir_uy_mobile_flutter/repositories/apartment_repository.dart';
import 'package:tamir_uy_mobile_flutter/services/api_client.dart';
import 'package:tamir_uy_mobile_flutter/services/flat_scan_handoff.dart';

import '../features/room_scan/flat_layout_test.dart' show box;

RoomOut _room(String id) =>
    RoomOut(id: id, apartmentId: 'a1', name: 'x', updatedAt: DateTime(2026));

/// The first room's persistence, as the single-room handoff does it.
class _FakePersistence extends RoomPersistenceNotifier {
  _FakePersistence(super.ref);
  @override
  Future<void> ensurePersisted({RoomCreate? override}) async {
    state = AsyncValue.data(PersistedRoom(clientRoomId: 'c', room: _room('r1')));
  }
}

class _FakeRepo extends ApartmentRepository {
  _FakeRepo({this.failOn, this.existing = const []}) : super(ApiClient(baseUrl: 'http://test'));
  final int? failOn;
  final List<RoomOut> existing;

  @override
  Future<List<RoomOut>> listRooms(String apartmentId) async =>
      [...existing, for (final id in states.keys) _room(id)];
  final created = <String>[]; // apartment ids
  final states = <String, Map<String, dynamic>>{};
  final names = <String, String>{};
  var _n = 1;

  @override
  Future<RoomOut> createRoom(String apartmentId, RoomCreate body) async {
    _n++;
    if (failOn == _n) throw Exception('HTTP 500');
    created.add(apartmentId);
    return _room('r$_n');
  }

  @override
  Future<RoomOut> updateRoom(String roomId,
      {String? name,
      double? ceilingH,
      Map<String, dynamic>? geometry,
      Map<String, dynamic>? surfaces,
      List<dynamic>? furnitureLayout,
      Map<String, dynamic>? state}) async {
    if (state != null) states[roomId] = state;
    if (name != null) names[roomId] = name;
    return _room(roomId);
  }
}

Future<WidgetRef> _pump(WidgetTester tester, _FakeRepo repo) async {
  late WidgetRef ref;
  await tester.pumpWidget(ProviderScope(
    overrides: [
      roomPersistenceProvider.overrideWith((r) => _FakePersistence(r)),
      apartmentRepositoryProvider.overrideWithValue(repo),
    ],
    child: Consumer(builder: (context, r, _) {
      ref = r;
      return const SizedBox();
    }),
  ));
  return ref;
}

void main() {
  final drafts = [box(4, 3), box(3, 3, ox: 4.1)];

  testWidgets('creates every room in the same apartment', (tester) async {
    final repo = _FakeRepo();
    final ref = await _pump(tester, repo);
    final ids = await handoffScannedFlat(ref, drafts,
        names: ['Zal', 'Yotoqxona'], ceilings: [2.7, 2.7]);
    expect(ids, ['r1', 'r2']);
    expect(repo.created, ['a1']);
    expect(repo.names, {'r1': 'Zal', 'r2': 'Yotoqxona'});
  });

  testWidgets('writes layoutPos', (tester) async {
    final repo = _FakeRepo();
    final ref = await _pump(tester, repo);
    await handoffScannedFlat(ref, drafts, names: ['A', 'B'], ceilings: [2.7, 2.7]);
    final a = repo.states['r1']!['layoutPos'] as Map;
    final b = repo.states['r2']!['layoutPos'] as Map;
    expect(a['x'], closeTo(2.0, 1e-6));
    expect(a['z'], closeTo(1.5, 1e-6));
    expect(b['x'], closeTo(5.6, 1e-6));
    expect(b['z'], closeTo(1.5, 1e-6));
  });

  testWidgets('one room still gets a layoutPos', (tester) async {
    final repo = _FakeRepo();
    final ref = await _pump(tester, repo);
    final ids = await handoffScannedFlat(ref, [box(4, 3, ox: 9)],
        names: ['A'], ceilings: [2.7]);
    expect(ids, ['r1']);
    expect((repo.states['r1']!['layoutPos'] as Map)['x'], closeTo(2.0, 1e-6));
  });

  testWidgets('a failed createRoom for room 2 keeps room 1', (tester) async {
    final repo = _FakeRepo(failOn: 2);
    final ref = await _pump(tester, repo);
    await expectLater(
      handoffScannedFlat(ref, drafts, names: ['A', 'B'], ceilings: [2.7, 2.7]),
      throwsA(isA<FlatHandoffException>()
          .having((e) => e.createdIds, 'createdIds', ['r1'])),
    );
  });

  testWidgets("the flat is placed past the project's rooms already there",
      (tester) async {
    final repo = _FakeRepo(existing: [
      RoomOut(
        id: 'old',
        apartmentId: 'a1',
        name: 'Oshxona',
        updatedAt: DateTime(2026),
        geometry: {
          'walls': [],
          'vertices': [
            [0, 0],
            [4, 0],
            [4, 3],
            [0, 3],
          ],
        },
        state: {
          'layoutPos': {'x': 2.0, 'z': 1.5},
        },
      ),
    ]);
    final ref = await _pump(tester, repo);
    await handoffScannedFlat(ref, drafts, names: ['A', 'B'], ceilings: [2.7, 2.7]);
    // Old room's right edge 4 m + 1 m gap = 5 m shift.
    expect((repo.states['r1']!['layoutPos'] as Map)['x'], closeTo(7.0, 1e-6));
    expect((repo.states['r2']!['layoutPos'] as Map)['x'], closeTo(10.6, 1e-6));
    expect((repo.states['r1']!['layoutPos'] as Map)['z'], closeTo(1.5, 1e-6));
  });
}
