import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/room_scan/flat_layout.dart';
import '../features/room_scan/room_scan_converter.dart';
import '../models/room_plan.dart';
import '../providers/apartment_provider.dart';
import '../repositories/apartment_repository.dart';
import '../providers/room_persistence_provider.dart';
import '../utils/room_geometry_mapper.dart';
import 'room_plan_handoff.dart';

/// Room creation stopped part-way; [createdIds] are the rooms already saved.
class FlatHandoffException implements Exception {
  const FlatHandoffException(this.createdIds, this.cause);
  final List<String> createdIds;
  final Object cause;

  @override
  String toString() => 'FlatHandoffException(created: $createdIds, cause: $cause)';
}

/// Saves the rooms of one multi-room scan into one apartment, each at its
/// place in the flat (`state.layoutPos`, which the web studio reads), and
/// returns their backend ids in input order.
///
/// The first room goes through [handoffRoomPlan], so the apartment is picked
/// (or created) exactly as for a single scanned room; the others are created
/// in that apartment.
Future<List<String>> handoffScannedFlat(
  WidgetRef ref,
  List<RoomScanDraft> drafts, {
  required List<String> names,
  required List<double> ceilings,
}) async {
  final positions = flatLayoutPositions(drafts);
  final repo = ref.read(apartmentRepositoryProvider);
  final ids = <String>[];
  try {
    for (var i = 0; i < drafts.length; i++) {
      final p = drafts[i].plan;
      final plan = RoomPlan(
        corners: p.corners,
        walls: p.walls,
        ceilingHeightM: ceilings[i],
        source: p.source,
        name: names[i],
      );
      if (i == 0) {
        final first = await handoffRoomPlan(ref, plan);
        if (first == null) throw StateError('the first room was not saved');
        ids.add(first);
      } else {
        final aptId = ref.read(roomPersistenceProvider).valueOrNull!.room.apartmentId;
        ids.add((await repo.createRoom(aptId, roomPlanToPolygonRoomCreate(plan, name: names[i]))).id);
      }
    }
    final aptId = ref.read(roomPersistenceProvider).valueOrNull!.room.apartmentId;
    final shiftX = await _rightOfExistingRooms(repo, aptId, ids.toSet());
    for (var i = 0; i < ids.length; i++) {
      await repo.updateRoom(ids[i], name: names[i], state: {
        'layoutPos': {'x': positions[i].x + shiftX, 'z': positions[i].z},
      });
    }
  } catch (e) {
    throw FlatHandoffException(List.unmodifiable(ids), e);
  }
  return ids;
}

/// Gap left between the project's rooms already placed and a scanned flat.
const _flatGapM = 1.0;

/// How far right to move a scanned flat (whose frame starts at 0) so it does
/// not land on the rooms the apartment already has at stored places: past the
/// right edge of the rightmost one, plus [_flatGapM]. 0 when there are none,
/// or when they cannot be read (best-effort). Rooms with no stored place are
/// laid out by the studio after the placed ones, so they cannot collide.
Future<double> _rightOfExistingRooms(
    ApartmentRepository repo, String aptId, Set<String> newIds) async {
  try {
    double? right;
    for (final room in await repo.listRooms(aptId)) {
      if (newIds.contains(room.id)) continue;
      final pos = room.state?['layoutPos'];
      if (pos is! Map || pos['x'] is! num) continue;
      final edge = (pos['x'] as num).toDouble() + _halfWidth(room.geometry);
      right = right == null || edge > right ? edge : right;
    }
    return right == null ? 0 : right + _flatGapM;
  } catch (_) {
    return 0;
  }
}

/// Half the room's width along x (metres), from its vertices or wall A; 2 m
/// when the geometry says neither (the studio's 4 m default).
double _halfWidth(Map<String, dynamic>? geometry) {
  final vertices = geometry?['vertices'];
  if (vertices is List && vertices.isNotEmpty) {
    final xs = [for (final v in vertices) if (v is List && v.isNotEmpty) (v[0] as num).toDouble()];
    if (xs.isNotEmpty) {
      return (xs.reduce((a, b) => a > b ? a : b) - xs.reduce((a, b) => a < b ? a : b)) / 2;
    }
  }
  for (final w in (geometry?['walls'] as List? ?? const [])) {
    if (w is Map && w['id'] == 'A' && w['length'] is num) return (w['length'] as num) / 2;
  }
  return 2.0;
}
