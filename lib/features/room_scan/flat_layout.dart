import '../../geometry/room_geometry.dart';
import 'room_scan_converter.dart';

/// A room's place in its flat: the web studio's `state.layoutPos` — the room
/// centre (mean of its corners), metres, flat frame (x = plan x, z = plan y).
typedef LayoutPos = ({double x, double z});

/// The `layoutPos` of every room of one multi-room scan, in input order. All
/// rooms share the scan's world frame; it is shifted so the set's smallest
/// room corner is at (0, 0).
List<LayoutPos> flatLayoutPositions(List<RoomScanDraft> drafts) {
  if (drafts.isEmpty) return const [];
  final minX = drafts.map((d) => d.worldOrigin.x).reduce((a, b) => a < b ? a : b);
  final minY = drafts.map((d) => d.worldOrigin.y).reduce((a, b) => a < b ? a : b);
  return [
    for (final d in drafts) _centre(d, Vec2(minX, minY)),
  ];
}

LayoutPos _centre(RoomScanDraft d, Vec2 shift) {
  final corners = d.plan.corners;
  var sum = const Vec2(0, 0);
  for (final c in corners) {
    sum = sum + c;
  }
  final mean = corners.isEmpty ? const Vec2(0, 0) : sum * (1 / corners.length);
  final at = d.worldOrigin - shift + mean;
  return (x: at.x, z: at.y);
}
