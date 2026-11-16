import 'package:flutter/material.dart';

import '../../config/design_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/room_type_size.dart';

/// The room types as chips. Tapping the picked chip again clears the pick
/// ([onChanged] gets null), so "no type" stays reachable.
class RoomTypePicker extends StatelessWidget {
  const RoomTypePicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Wrap(
      spacing: DesignTokens.spacingSm,
      runSpacing: DesignTokens.spacingXs,
      children: [
        for (final type in kRoomTypes)
          ChoiceChip(
            key: ValueKey('roomType_$type'),
            label: Text(roomTypeLabel(l10n, type)),
            selected: value == type,
            onSelected: (_) => onChanged(value == type ? null : type),
            selectedColor: DesignTokens.primaryBlue,
            labelStyle: TextStyle(
              color: value == type ? DesignTokens.white : DesignTokens.textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}
