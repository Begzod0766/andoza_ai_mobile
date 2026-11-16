import '../l10n/app_localizations.dart';

/// The backend's room types (`RoomType` in the web `app/schemas/room.py`), in
/// the order the web wizard shows them.
const kRoomTypes = [
  'mehmonxona',
  'yotoqxona',
  'bolalar',
  'oshxona',
  'kabinet',
  'hammom',
  'balkon',
];

/// A room's starting walls: [length] is walls A/C, [width] walls B/D (metres).
typedef RoomSize = ({double length, double width});

/// A new room's usual size by type — the same table as the web wizard
/// (`frontend/src/lib/roomTypeSize.ts`, wall A × wall B).
const Map<String, RoomSize> kRoomTypeSizeM = {
  'hammom': (length: 2.5, width: 2.0),
  'oshxona': (length: 3.0, width: 3.0),
  'yotoqxona': (length: 4.0, width: 3.5),
  'bolalar': (length: 3.5, width: 3.0),
  'mehmonxona': (length: 5.0, width: 4.0),
  'kabinet': (length: 3.0, width: 2.5),
  'balkon': (length: 3.0, width: 1.2),
};

/// The app wizard's size for a room with no type (unchanged from before types).
const RoomSize kNoTypeSizeM = (length: 4.5, width: 3.2);

RoomSize _sizeOf(String? type) => kRoomTypeSizeM[type] ?? kNoTypeSizeM;

bool _same(double a, double b) => (a - b).abs() < 1e-6;

/// The walls a room should take when its type changes from [prev] to [next],
/// or null to leave them. Only an untouched room changes: no doors or windows
/// yet ([hasOpenings] false) and still at the size [prev] gave it. Walls the
/// user has set are never overwritten.
RoomSize? sizeForRoomType({
  required double length,
  required double width,
  required bool hasOpenings,
  required String? prev,
  required String? next,
}) {
  if (hasOpenings || prev == next) return null;
  final from = _sizeOf(prev);
  if (!_same(length, from.length) || !_same(width, from.width)) return null;
  final to = _sizeOf(next);
  if (_same(to.length, length) && _same(to.width, width)) return null;
  return to;
}

/// The label for room [type] in the app's language.
String roomTypeLabel(AppLocalizations l10n, String type) => switch (type) {
      'mehmonxona' => l10n.roomMehmonxona,
      'yotoqxona' => l10n.roomYotoqxona,
      'bolalar' => l10n.roomBolalar,
      'oshxona' => l10n.roomOshxona,
      'kabinet' => l10n.roomKabinet,
      'hammom' => l10n.roomHammom,
      'balkon' => l10n.roomBalkon,
      _ => type,
    };
