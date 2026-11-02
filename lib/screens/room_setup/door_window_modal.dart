import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../config/design_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../models/room_model.dart';

/// A preset door/window size pill, e.g. "90×205".
class _SizePreset {
  const _SizePreset(this.width, this.height);
  final double width;
  final double height;
  String get label =>
      '${(width * 100).toStringAsFixed(0)}×${(height * 100).toStringAsFixed(0)}';
}

const _presets = [
  _SizePreset(0.90, 2.05),
  _SizePreset(0.80, 2.05),
  _SizePreset(0.70, 2.00),
  _SizePreset(1.65, 1.80),
  _SizePreset(1.20, 1.40),
];

/// Values an existing opening opens the sheet with (metres).
class DoorWindowInitial {
  const DoorWindowInitial({
    required this.type,
    required this.width,
    required this.height,
    required this.offset,
    this.sill = 0,
  });
  final OpeningType type;
  final double width;
  final double height;
  final double offset;
  final double sill;
}

/// A8: Eshik/Deraza qo'shish sheet — type chips, preset size pills, and a
/// position-on-wall slider. Reuses [OpeningType] (single/dual/sliding) to
/// represent Eshik/Deraza/Balkon eshigi; the enum's mechanism-oriented
/// naming predates this reuse but avoids forking a near-duplicate type.
class DoorWindowModal extends StatefulWidget {
  const DoorWindowModal({
    required this.onAdd,
    this.initial,
    this.showSill = false,
    this.maxOffset,
    this.onDelete,
    super.key,
  });

  /// Called with (type, width, height, offsetFromWallStart, sill) when the
  /// user taps "Devorga qo'shish" / "Saqlash". [sill] is 0 unless [showSill]
  /// and the type is a window.
  final void Function(
    OpeningType type,
    double width,
    double height,
    double offset,
    double sill,
  )
  onAdd;

  /// Editing an existing opening: its values are filled in and the button
  /// reads "Saqlash".
  final DoorWindowInitial? initial;

  /// Offer the window sill height (the scan review needs it).
  final bool showSill;

  /// Right end of the position slider in metres (the wall length); 8 if null.
  final double? maxOffset;

  /// Shows "O'chirish" when given.
  final VoidCallback? onDelete;

  @override
  State<DoorWindowModal> createState() => _DoorWindowModalState();
}

class _DoorWindowModalState extends State<DoorWindowModal> {
  OpeningType _selectedType = OpeningType.single;
  _SizePreset? _selectedPreset = _presets.first;
  double _offset = 1.0;
  final _width = TextEditingController();
  final _height = TextEditingController();
  final _sill = TextEditingController();
  final _offsetCm = TextEditingController();

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    if (i != null) {
      _selectedType = i.type;
      _selectedPreset = null;
      _offset = i.offset;
      _width.text = _cmText(i.width);
      _height.text = _cmText(i.height);
      // A door has no sill; if it becomes a window, start from the usual one.
      _sill.text = i.type == OpeningType.dual ? _cmText(i.sill) : '90';
    } else {
      _sill.text = '90';
    }
    _offsetCm.text = _cmText(_offset);
  }

  @override
  void dispose() {
    _width.dispose();
    _height.dispose();
    _sill.dispose();
    _offsetCm.dispose();
    super.dispose();
  }

  static String _cmText(double m) => (m * 100).round().toString();

  /// Centimetres typed into [c] as metres; null when empty, not a number or ≤ 0.
  static double? _metres(TextEditingController c) {
    final v = double.tryParse(c.text.trim().replaceAll(',', '.'));
    return v == null || v <= 0 ? null : v / 100;
  }

  bool get _sillShown => widget.showSill && _selectedType == OpeningType.dual;

  double get _maxOffset => widget.maxOffset ?? 8;

  /// (width, height) the button would send, or null while they are invalid.
  (double, double)? get _size {
    final p = _selectedPreset;
    if (p != null) return (p.width, p.height);
    final w = _metres(_width), h = _metres(_height);
    return w == null || h == null ? null : (w, h);
  }

  void _submit() {
    final size = _size;
    if (size == null) return;
    final sill = _sillShown
        ? (double.tryParse(_sill.text.trim().replaceAll(',', '.')) ?? 0) / 100
        : 0.0;
    // With a known wall length the whole opening stays on the wall.
    final wall = widget.maxOffset;
    final offset = wall == null
        ? _offset.clamp(0.0, _maxOffset)
        : ((double.tryParse(_offsetCm.text.trim().replaceAll(',', '.')) ?? 0) /
                  100)
              .clamp(0.0, math.max(0.0, wall - size.$1))
              .toDouble();
    widget.onAdd(_selectedType, size.$1, size.$2, offset, sill);
  }

  Widget _cmField(Key key, TextEditingController c, String label) => TextField(
    key: key,
    controller: c,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(labelText: label, isDense: true),
    onChanged: (_) => setState(() {}),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(
        left: DesignTokens.screenPaddingHorizontal,
        right: DesignTokens.screenPaddingHorizontal,
        top: DesignTokens.spacingMd,
        bottom:
            MediaQuery.of(context).viewInsets.bottom + DesignTokens.spacingLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              margin: const EdgeInsets.only(bottom: DesignTokens.spacingLg),
              decoration: BoxDecoration(
                color: DesignTokens.borderGray,
                borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
              ),
            ),
          ),
          Wrap(
            spacing: DesignTokens.spacingSm,
            children: [
              _TypeChip(
                label: l10n.openingTypeDoor,
                selected: _selectedType == OpeningType.single,
                onTap: () => setState(() => _selectedType = OpeningType.single),
              ),
              _TypeChip(
                label: l10n.openingTypeWindow,
                selected: _selectedType == OpeningType.dual,
                onTap: () => setState(() => _selectedType = OpeningType.dual),
              ),
              _TypeChip(
                label: l10n.openingTypeBalcony,
                selected: _selectedType == OpeningType.sliding,
                onTap: () =>
                    setState(() => _selectedType = OpeningType.sliding),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacingLg),
          Text(l10n.openingSizeLabel, style: DesignTokens.subtitle2),
          const SizedBox(height: DesignTokens.spacingSm),
          Wrap(
            spacing: DesignTokens.spacingSm,
            runSpacing: DesignTokens.spacingSm,
            children: [
              for (final preset in _presets)
                _SizeChip(
                  label: preset.label,
                  selected: _selectedPreset == preset,
                  onTap: () => setState(() => _selectedPreset = preset),
                ),
              _SizeChip(
                label: l10n.openingSizeOther,
                selected: _selectedPreset == null,
                onTap: () => setState(() => _selectedPreset = null),
              ),
            ],
          ),
          if (_selectedPreset == null) ...[
            const SizedBox(height: DesignTokens.spacingMd),
            Row(
              children: [
                Expanded(
                  child: _cmField(
                    const Key('opening-width'),
                    _width,
                    l10n.openingWidthCm,
                  ),
                ),
                const SizedBox(width: DesignTokens.spacingSm),
                Expanded(
                  child: _cmField(
                    const Key('opening-height'),
                    _height,
                    l10n.openingHeightCm,
                  ),
                ),
              ],
            ),
          ],
          if (_sillShown) ...[
            const SizedBox(height: DesignTokens.spacingMd),
            _cmField(const Key('opening-sill'), _sill, l10n.openingSillCm),
          ],
          const SizedBox(height: DesignTokens.spacingLg),
          Text(l10n.openingPositionLabel, style: DesignTokens.subtitle2),
          if (widget.maxOffset != null) ...[
            const SizedBox(height: DesignTokens.spacingSm),
            _cmField(
              const Key('opening-offset'),
              _offsetCm,
              l10n.openingOffsetCm,
            ),
            const SizedBox(height: DesignTokens.spacingMd),
          ] else
            Slider(
              value: _offset.clamp(0.0, _maxOffset),
              min: 0,
              max: _maxOffset,
              activeColor: DesignTokens.primaryBlue,
              onChanged: (value) => setState(() => _offset = value),
            ),
          const SizedBox(height: DesignTokens.spacingSm),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _size == null ? null : _submit,
              child: Text(
                widget.initial != null
                    ? l10n.openingSave
                    : l10n.openingAddToWall,
              ),
            ),
          ),
          if (widget.onDelete != null)
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: widget.onDelete,
                style: TextButton.styleFrom(
                  foregroundColor: DesignTokens.error,
                ),
                child: Text(l10n.openingDelete),
              ),
            ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: DesignTokens.primaryTint,
      labelStyle: DesignTokens.body2.copyWith(
        color: selected ? DesignTokens.primaryBlue : DesignTokens.textGray,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
      ),
    );
  }
}

class _SizeChip extends StatelessWidget {
  const _SizeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacingMd,
          vertical: DesignTokens.spacingSm,
        ),
        decoration: BoxDecoration(
          color: selected ? DesignTokens.primaryTint : DesignTokens.white,
          border: Border.all(
            color: selected
                ? DesignTokens.primaryBlue
                : DesignTokens.borderGray,
          ),
          borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
        ),
        child: Text(
          label,
          style: DesignTokens.caption.copyWith(
            color: selected ? DesignTokens.primaryBlue : DesignTokens.textGray,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
