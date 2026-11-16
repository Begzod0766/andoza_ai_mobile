import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/geometry/room_geometry.dart';
import 'package:tamir_uy_mobile_flutter/models/api/room_create.dart';
import 'package:tamir_uy_mobile_flutter/models/room_plan.dart';
import 'package:tamir_uy_mobile_flutter/utils/room_geometry_mapper.dart';
import 'package:tamir_uy_mobile_flutter/utils/room_type_size.dart';

void main() {
  group('sizeForRoomType', () {
    RoomSize? pick(double length, double width, String? prev, String? next,
            {bool openings = false}) =>
        sizeForRoomType(
          length: length,
          width: width,
          hasOpenings: openings,
          prev: prev,
          next: next,
        );

    test('an untouched room with no type takes the picked type size', () {
      expect(pick(4.5, 3.2, null, 'hammom'), (length: 2.5, width: 2.0));
      expect(pick(4.5, 3.2, null, 'oshxona'), (length: 3.0, width: 3.0));
      expect(pick(4.5, 3.2, null, 'mehmonxona'), (length: 5.0, width: 4.0));
    });

    test('switching between types follows while the walls are untouched', () {
      expect(pick(2.5, 2.0, 'hammom', 'oshxona'), (length: 3.0, width: 3.0));
      expect(pick(3.0, 3.0, 'oshxona', null), (length: 4.5, width: 3.2));
    });

    test('walls the user set are never overwritten', () {
      expect(pick(2.7, 2.0, 'hammom', 'oshxona'), isNull);
      expect(pick(4.5, 3.0, null, 'hammom'), isNull);
    });

    test('a wall with a door or window keeps its size', () {
      expect(pick(4.5, 3.2, null, 'hammom', openings: true), isNull);
    });

    test('the same type is not a change', () {
      expect(pick(2.5, 2.0, 'hammom', 'hammom'), isNull);
    });

    test('every backend type has a size and the web table values', () {
      for (final t in kRoomTypes) {
        expect(kRoomTypeSizeM.containsKey(t), isTrue, reason: t);
      }
      expect(kRoomTypeSizeM['balkon'], (length: 3.0, width: 1.2));
      expect(kRoomTypeSizeM['kabinet'], (length: 3.0, width: 2.5));
      expect(kRoomTypeSizeM['yotoqxona'], (length: 4.0, width: 3.5));
      expect(kRoomTypeSizeM['bolalar'], (length: 3.5, width: 3.0));
    });
  });

  group('room_type on create', () {
    const geometry = RoomGeometryCreate(walls: [
      WallCreate(id: 'A', length: 2.5),
      WallCreate(id: 'B', length: 2.0),
      WallCreate(id: 'C', length: 2.5),
      WallCreate(id: 'D', length: 2.0),
    ]);

    test('is sent when picked', () {
      const body = RoomCreate(
          name: 'Xona', ceilingH: 2.7, geometry: geometry, roomType: 'hammom');
      expect(body.toJson()['room_type'], 'hammom');
    });

    test('is left out when not picked', () {
      const body = RoomCreate(name: 'Xona', ceilingH: 2.7, geometry: geometry);
      expect(body.toJson().containsKey('room_type'), isFalse);
    });

    test('a scanned polygon carries its type, walls unchanged', () {
      final plan = RoomPlan.fromCorners(
        const [Vec2(0, 0), Vec2(0, 3), Vec2(2, 3), Vec2(2, 1.5), Vec2(1, 1.5), Vec2(1, 0)],
        ceilingHeightM: 2.6,
        source: RoomSource.lidar,
      );
      final typed = RoomPlan(
        corners: plan.corners,
        walls: plan.walls,
        ceilingHeightM: plan.ceilingHeightM,
        source: plan.source,
        roomType: 'hammom',
      );
      final body = roomPlanToPolygonRoomCreate(typed);
      expect(body.roomType, 'hammom');
      expect(body.geometry.walls.map((w) => w.length),
          plan.walls.map((w) => closeTo(w.lengthM, 1e-9)));
    });
  });
}
