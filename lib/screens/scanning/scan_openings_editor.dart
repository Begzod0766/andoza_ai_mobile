import 'package:flutter/material.dart';

import '../../config/design_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../models/room_model.dart' show OpeningType;
import '../../models/room_plan.dart';
import '../../utils/opening_position.dart';
import '../room_setup/door_window_modal.dart';

/// [plan] with wall [wall]'s openings replaced by [openings]; everything else as is.
RoomPlan withWallOpenings(RoomPlan plan, int wall, List<RoomOpening> openings) => RoomPlan(
      corners: plan.corners,
      walls: List.unmodifiable([
        for (var i = 0; i < plan.walls.length; i++)
          i == wall
              ? RoomWall(plan.walls[i].a, plan.walls[i].b, plan.walls[i].lengthM,
                  openings: List.unmodifiable(openings))
              : plan.walls[i],
      ]),
      ceilingHeightM: plan.ceilingHeightM,
      source: plan.source,
      name: plan.name,
    );

/// Scan review: the plan's doors and windows, each editable or removable in
/// the door/window sheet, plus "+ Qo'shish" for ones the scan missed. Changes
/// come back through [onChanged] as a new plan; nothing is saved here.
class ScanOpeningsEditor extends StatelessWidget {
  const ScanOpeningsEditor({required this.plan, required this.onChanged, super.key});

  final RoomPlan plan;
  final ValueChanged<RoomPlan> onChanged;

  static bool _isWindow(RoomOpening o) => o.type == 'window';

  RoomOpening _fromSheet(int wall, OpeningType type, double width, double height, double offset, double sill) {
    final window = type == OpeningType.dual;
    return RoomOpening(
      type: window ? 'window' : 'door',
      width: width,
      height: height,
      position: leftEdgeToCentreFraction(offsetM: offset, wallLengthM: plan.walls[wall].lengthM, widthM: width),
      sillHeight: window ? sill : 0,
    );
  }

  Future<void> _edit(BuildContext context, int wall, int index) {
    final w = plan.walls[wall];
    final o = w.openings[index];
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheet) => DoorWindowModal(
        initial: DoorWindowInitial(
          type: _isWindow(o) ? OpeningType.dual : OpeningType.single,
          width: o.width,
          height: o.height,
          offset: centreFractionToLeftEdgeM(position: o.position, wallLengthM: w.lengthM, widthM: o.width),
          sill: o.sillHeight,
        ),
        showSill: true,
        maxOffset: w.lengthM,
        onAdd: (type, width, height, offset, sill) {
          final list = List.of(w.openings)..[index] = _fromSheet(wall, type, width, height, offset, sill);
          onChanged(withWallOpenings(plan, wall, list));
          Navigator.of(sheet).pop();
        },
        onDelete: () {
          onChanged(withWallOpenings(plan, wall, List.of(w.openings)..removeAt(index)));
          Navigator.of(sheet).pop();
        },
      ),
    );
  }

  Future<void> _add(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final wall = await showModalBottomSheet<int>(
      context: context,
      builder: (sheet) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.all(DesignTokens.spacingMd),
              child: Text(l10n.scanReviewPickWall, style: DesignTokens.subtitle2),
            ),
            for (var i = 0; i < plan.walls.length; i++)
              ListTile(
                title: Text(l10n.scanReviewWall(i + 1)),
                trailing: Text('${plan.walls[i].lengthM.toStringAsFixed(2)} m'),
                onTap: () => Navigator.of(sheet).pop(i),
              ),
          ],
        ),
      ),
    );
    if (wall == null || !context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheet) => DoorWindowModal(
        showSill: true,
        maxOffset: plan.walls[wall].lengthM,
        onAdd: (type, width, height, offset, sill) {
          final list = [...plan.walls[wall].openings, _fromSheet(wall, type, width, height, offset, sill)];
          onChanged(withWallOpenings(plan, wall, list));
          Navigator.of(sheet).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rows = <Widget>[
      for (var i = 0; i < plan.walls.length; i++)
        for (var k = 0; k < plan.walls[i].openings.length; k++)
          _row(context, l10n, i, k, plan.walls[i].openings[k]),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.scanReviewOpeningsTitle, style: DesignTokens.subtitle2),
        const SizedBox(height: DesignTokens.spacingXs),
        if (rows.isEmpty)
          Text(l10n.scanReviewOpeningsEmpty, style: DesignTokens.body2.copyWith(color: DesignTokens.textGray))
        else
          ...rows,
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(onPressed: () => _add(context), child: Text(l10n.scanReviewOpeningAdd)),
        ),
      ],
    );
  }

  Widget _row(BuildContext context, AppLocalizations l10n, int wall, int index, RoomOpening o) {
    final window = _isWindow(o);
    final type = window ? l10n.openingTypeWindow : l10n.openingTypeDoor;
    return ListTile(
      key: Key('scan-opening-$wall-$index'),
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        window ? Icons.window_outlined : Icons.door_front_door_outlined,
        // Same colours as the plan preview: door green, window blue.
        color: window ? DesignTokens.primaryBlue : DesignTokens.success,
      ),
      title: Text(l10n.scanReviewWall(wall + 1), style: DesignTokens.body2),
      subtitle: Text('$type · ${o.width.toStringAsFixed(2)} × ${o.height.toStringAsFixed(2)} m',
          style: DesignTokens.caption.copyWith(color: DesignTokens.textGray)),
      trailing: const Icon(Icons.edit_outlined, size: 18),
      onTap: () => _edit(context, wall, index),
    );
  }
}
