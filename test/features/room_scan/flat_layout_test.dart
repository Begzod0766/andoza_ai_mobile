import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/features/room_scan/flat_layout.dart';
import 'package:tamir_uy_mobile_flutter/features/room_scan/models/captured_room.dart';
import 'package:tamir_uy_mobile_flutter/features/room_scan/room_scan_converter.dart';

ScanSurface _wall(double cx, double cz, double angleDeg, double length) {
  final a = angleDeg * math.pi / 180;
  final c = math.cos(a), s = math.sin(a);
  return ScanSurface(
    dimensions: Vec3(length, 2.7, 0.1),
    transform: ScanTransform(<double>[
      c, 0, s, 0, //
      0, 1, 0, 0, //
      -s, 0, c, 0, //
      cx, 1.35, cz, 1, //
    ]),
  );
}

/// A [w] × [d] m room whose min corner is at world (x = [ox], z = [oz]).
RoomScanDraft box(double w, double d, {double ox = 0, double oz = 0}) =>
    RoomScanConverter.toRoomDraft(CapturedRoom(walls: [
      _wall(ox + w / 2, oz, 0, w),
      _wall(ox + w, oz + d / 2, 90, d),
      _wall(ox + w / 2, oz + d, 0, w),
      _wall(ox, oz + d / 2, 90, d),
    ]));

void main() {
  test('toRoomDraft keeps the world origin', () {
    final here = box(4, 3);
    final moved = box(4, 3, ox: 10, oz: 5);
    expect(moved.plan.corners.length, here.plan.corners.length);
    for (var i = 0; i < here.plan.corners.length; i++) {
      expect(moved.plan.corners[i].x, closeTo(here.plan.corners[i].x, 1e-6));
      expect(moved.plan.corners[i].y, closeTo(here.plan.corners[i].y, 1e-6));
    }
    expect(moved.worldOrigin.x - here.worldOrigin.x, closeTo(10, 1e-6));
    expect(moved.worldOrigin.y - here.worldOrigin.y, closeTo(5, 1e-6));
  });

  test('flatLayoutPositions places side-by-side rooms', () {
    final pos = flatLayoutPositions([box(4, 3), box(3, 3, ox: 4.1)]);
    expect(pos[0].x, closeTo(2.0, 1e-6));
    expect(pos[0].z, closeTo(1.5, 1e-6));
    expect(pos[1].x, closeTo(5.6, 1e-6));
    expect(pos[1].z, closeTo(1.5, 1e-6));
  });

  test("flatLayoutPositions shifts to the set's min corner", () {
    final pos = flatLayoutPositions(
        [box(4, 3, ox: -7, oz: 20), box(3, 3, ox: -2.9, oz: 20)]);
    expect(pos[0].x, closeTo(2.0, 1e-6));
    expect(pos[0].z, closeTo(1.5, 1e-6));
    expect(pos[1].x, closeTo(5.6, 1e-6));
    expect(pos[1].z, closeTo(1.5, 1e-6));
  });

  test('flatLayoutPositions single room', () {
    final pos = flatLayoutPositions([box(4, 3, ox: 3, oz: -1)]);
    expect(pos.single.x, closeTo(2.0, 1e-6));
    expect(pos.single.z, closeTo(1.5, 1e-6));
  });
}
