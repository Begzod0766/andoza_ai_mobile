import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/design_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../models/design_selection_model.dart';
import '../../models/room_model.dart';
import '../../models/room_plan.dart';
import '../../providers/design_provider.dart';
import '../../providers/room_persistence_provider.dart';
import '../../providers/room_provider.dart';
import '../../widgets/room/isometric_room_view.dart';
import '../home/home_empty_screen.dart';
import 'door_window_modal.dart';
import 'wall_measurements_screen.dart';
import '../../utils/opening_position.dart';

/// Native room-capture wizard: an isometric 3D room preview on top, and a
/// single flow of steps below — ceiling height → each wall's length + openings
/// → summary. Replaces the WebView `/wizard`, giving a fully native experience
/// (instant, offline, no web dependency) with the same shape as the web wizard.
class RoomWizardScreen extends ConsumerStatefulWidget {
  const RoomWizardScreen({super.key});

  @override
  ConsumerState<RoomWizardScreen> createState() => _RoomWizardScreenState();
}

class _RoomWizardScreenState extends ConsumerState<RoomWizardScreen> {
  // Step 0 = ceiling, steps 1..4 = walls A–D, step 5 = summary.
  int _step = 0;
  bool _openingStudio = false;
  final _ceilingController = TextEditingController();

  static const _ceilingPresets = [2.5, 2.7, 3.0, 3.2];

  // --- Authoritative data model: a 4-corner rectangle [RoomPlan] ------------
  // The wizard is a plain box, so the plan is fully described by its width
  // (walls B/D), length (walls A/C), ceiling height and per-wall openings. The
  // A/B/C/D wall letters below are display-only labels on the plan's 4 edges
  // (edge index i → wall kWallTypes[i], matching RoomPlan.rectangle /
  // toLegacyRoom). It no longer depends on wallMeasurementsProvider as its
  // source of truth — it only reads it once, in initState, for the seeded
  // defaults so behaviour is unchanged.
  late double _width; // walls B/D span
  late double _length; // walls A/C span
  late double _height;
  // Openings per wall, indexed 0=A, 1=B, 2=C, 3=D.
  final List<List<RoomOpening>> _openings = [[], [], [], []];

  @override
  void initState() {
    super.initState();
    // Seeded defaults (the historical wallMeasurementsProvider A/B seed). The
    // wizard owns its geometry outright now and no longer reads that provider.
    _length = 4.5; // walls A/C span
    _width = 3.2; // walls B/D span
    _height = 2.8;
    _ceilingController.text = _height.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _ceilingController.dispose();
    super.dispose();
  }

  int get _totalSteps => 6; // ceiling + 4 walls + summary

  /// The authoritative rectangle plan derived from the current dimensions and
  /// per-wall openings.
  RoomPlan get _plan => RoomPlan.rectangle(
        width: _width,
        length: _length,
        ceilingHeightM: _height,
        source: RoomSource.wizard,
        name: _roomName,
        wallOpenings: _openings,
      );

  String get _roomName =>
      AppLocalizations.of(context)!.roomSetupDefaultProjectName;

  /// The length of the plan edge for wall [index] (A/C = length, B/D = width).
  double _wallLengthFor(int index) =>
      (index == 0 || index == 2) ? _length : _width;

  /// An ephemeral [WallMeasurement] view of wall [index], so the existing
  /// [_WallStep] / [WallElevationPainter] render unchanged off the plan.
  WallMeasurement _wallMeasurement(int index) {
    final length = _wallLengthFor(index);
    var seq = 0;
    return WallMeasurement(
      type: kWallTypes[index],
      length: length,
      height: _height,
      openings: [
        for (final o in _openings[index])
          WallOpening(
            id: '${index}_${seq++}',
            type: o.type == 'window' ? OpeningType.dual : OpeningType.single,
            width: o.width,
            height: o.height,
            offset: centreFractionToLeftEdgeM(
              position: o.position,
              wallLengthM: length,
              widthM: o.width,
            ),
          ),
      ],
    );
  }

  /// The ceiling heights the wizard accepts (the API takes 1.8–6 m).
  static const _ceilingMin = 2.0;
  static const _ceilingMax = 5.0;

  /// False while the typed height is not a number in range: the field says
  /// why and "Keyingi" waits. It used to clamp silently, so 99 showed as 99
  /// but 5 m was used.
  bool _ceilingOk = true;

  void _setCeiling(double h) {
    setState(() {
      _height = h;
      _ceilingOk = true;
    });
  }

  void _setCeilingText(String raw) {
    final h = double.tryParse(raw.trim().replaceAll(',', '.'));
    if (h == null || h < _ceilingMin || h > _ceilingMax) {
      setState(() => _ceilingOk = false);
    } else {
      _setCeiling(h);
    }
  }

  /// Edit wall [index]'s length. A/C set the length dimension, B/D the width —
  /// both parallel edges move so the plan stays a plain axis rectangle (the
  /// same box the persistence path expects; a single-corner move would turn it
  /// into a trapezoid and change what gets persisted).
  void _setWallLength(int index, double v) {
    setState(() {
      if (index == 0 || index == 2) {
        _length = v;
      } else {
        _width = v;
      }
    });
  }

  void _addOpening(int index, OpeningType type, double width, double height,
      double offset) {
    final length = _wallLengthFor(index);
    setState(() {
      _openings[index] = [
        ..._openings[index],
        RoomOpening(
          type: type == OpeningType.dual ? 'window' : 'door',
          width: width,
          height: height,
          position: length == 0 ? 0.0 : (offset / length).clamp(0.0, 1.0),
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final plan = _plan;

    // The wall being edited on wall steps (1..4); index 0=A … 3=D.
    final activeIndex = (_step >= 1 && _step <= 4) ? _step - 1 : null;
    final activeWall =
        activeIndex != null ? _wallMeasurement(activeIndex) : null;
    // With the keyboard up the 240 pt preview left the field and its error
    // a sliver of screen; the preview steps aside while typing.
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return PopScope(
      // System back / iOS swipe goes one step back, like the AppBar arrow,
      // instead of dropping every wall entered so far.
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
      backgroundColor: DesignTokens.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: DesignTokens.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: DesignTokens.textDark),
          tooltip: l10n.actionBack,
          onPressed: _back,
        ),
        title: Text(l10n.wizardTitle, style: DesignTokens.heading3),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Isometric room preview (hidden on the summary step, which has its
          // own celebratory header).
          if (_step < _totalSteps - 1 && !keyboardOpen)
            SizedBox(
              height: 240,
              width: double.infinity,
              child: IsometricRoomView.polygon(
                floorCornersM: [
                  for (final c in plan.corners) Offset(c.x, c.y),
                ],
                heightM: _height,
                showEdgeLengths: false,
                fixedLabels: const ['A', 'B', 'C', 'D'],
                activeEdge: activeIndex,
              ),
            ),
          // Progress bar.
          if (_step < _totalSteps - 1)
            LinearProgressIndicator(
              value: (_step + 1) / (_totalSteps - 1),
              minHeight: 3,
              backgroundColor: DesignTokens.borderGray,
              color: DesignTokens.primaryBlue,
            ),
          Expanded(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.all(DesignTokens.screenPaddingHorizontal),
              child: _step == 0
                  ? _CeilingStep(
                      controller: _ceilingController,
                      presets: _ceilingPresets,
                      current: _height,
                      onPick: (h) {
                        _ceilingController.text = h.toStringAsFixed(2);
                        _setCeiling(h);
                      },
                      onExact: _setCeilingText,
                      error: _ceilingOk
                          ? null
                          : l10n.wizardCeilingOutOfRange(
                              _ceilingMin.toStringAsFixed(0),
                              _ceilingMax.toStringAsFixed(0),
                            ),
                    )
                  : (_step <= 4
                      ? _WallStep(
                          wall: activeWall!,
                          onLength: (v) => _setWallLength(activeIndex!, v),
                          onAddOpening: () => _showAddOpeningSheet(activeIndex!),
                        )
                      : _SummaryStep(
                          plan: plan,
                          openingStudio: _openingStudio,
                          onViewSmeta: _goSmeta,
                          onStartDesign: _goStudio,
                        )),
            ),
          ),
          // Bottom nav (not on the summary step — it has its own CTAs).
          if (_step < _totalSteps - 1)
            SafeArea(
              top: false,
              child: Padding(
                padding:
                    const EdgeInsets.all(DesignTokens.screenPaddingHorizontal),
                child: Row(
                  children: [
                    if (_step > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _back,
                          child: Text(l10n.actionPrev),
                        ),
                      ),
                    if (_step > 0)
                      const SizedBox(width: DesignTokens.spacingMd),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: DesignTokens.buttonHeightLarge,
                        child: ElevatedButton(
                          onPressed: _step == 0 && !_ceilingOk
                              ? null
                              : () => setState(() => _step++),
                          child: Text(l10n.actionNext),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ));
  }

  void _showSaveFailed() {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.roomSaveFailed),
        duration: const Duration(seconds: 8),
        action: SnackBarAction(label: l10n.actionRetry, onPressed: _goStudio),
      ),
    );
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _showAddOpeningSheet(int index) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => DoorWindowModal(
        onAdd: (type, width, height, offset) {
          _addOpening(index, type, width, height, offset);
          Navigator.of(sheetContext).pop();
        },
      ),
    );
  }

  /// "Smeta ko'rish" — set up the room and show the smeta (E1 persists it and
  /// computes the estimate).
  void _goSmeta() {
    _setupRoom();
    context.go('/estimation/e1');
  }

  /// "Bezashni boshlash" — like the web wizard, open the 3D Studio. That needs a
  /// real backend room id, so persist the room first, then navigate to
  /// /studio/{id}. If the save fails the user is told and can retry; it used to
  /// slip into the old design flow as if the room had been saved.
  Future<void> _goStudio() async {
    _setupRoom();
    setState(() => _openingStudio = true);
    try {
      final notifier = ref.read(roomPersistenceProvider.notifier);
      await notifier.ensurePersisted();
      final persisted = ref.read(roomPersistenceProvider).valueOrNull;
      if (!mounted) return;
      if (persisted != null) {
        context.go('/studio/${persisted.roomId}');
      } else {
        _showSaveFailed();
      }
    } catch (_) {
      if (mounted) _showSaveFailed();
    } finally {
      if (mounted) setState(() => _openingStudio = false);
    }
  }

  /// Sets the rectangle plan as the in-app source of truth and registers the
  /// design/home project. The mirrored legacy [Room] (via [RoomPlan.toLegacyRoom]
  /// pushed into [activeRoomProvider] by [setPlan]) keeps every downstream
  /// display consumer working. Persistence for this plain axis rectangle is the
  /// unchanged legacy A–D bounding path (see [_goStudio]'s [ensurePersisted]).
  void _setupRoom() {
    final roomId = DateTime.now().microsecondsSinceEpoch.toString();
    ref.read(activeRoomPlanProvider.notifier).setPlan(
          _plan,
          legacyRoomId: roomId,
          legacyName: _roomName,
        );
    ref.read(activeDesignProvider.notifier).setLocal(
          DesignSelection(
            id: '${roomId}_design',
            roomId: roomId,
            stage: DesignStage.floor,
            renovationStage: RenovationStage.suvoq,
          ),
        );
    ref.read(homeStateProvider.notifier).addProject(
          ProjectItem(
            id: roomId,
            name: _roomName,
            location: '',
            roomCount: 1,
            createdAt: DateTime.now(),
          ),
        );
  }
}

// ---------------------------------------------------------------------------
// Steps
// ---------------------------------------------------------------------------

class _CeilingStep extends StatelessWidget {
  const _CeilingStep({
    required this.controller,
    required this.presets,
    required this.current,
    required this.onPick,
    required this.onExact,
    this.error,
  });

  final TextEditingController controller;
  final List<double> presets;
  final double current;
  final ValueChanged<double> onPick;
  final ValueChanged<String> onExact;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.wizardCeilingQuestion, style: DesignTokens.heading2),
        const SizedBox(height: DesignTokens.spacingXs),
        Text(
          l10n.wizardCeilingHint,
          style: DesignTokens.body2.copyWith(color: DesignTokens.textGray),
        ),
        const SizedBox(height: DesignTokens.spacingLg),
        Wrap(
          spacing: DesignTokens.spacingSm,
          children: [
            for (final p in presets)
              ChoiceChip(
                label: Text('${p.toStringAsFixed(1)} m'),
                selected: (current - p).abs() < 0.001,
                onSelected: (_) => onPick(p),
                selectedColor: DesignTokens.primaryBlue,
                labelStyle: TextStyle(
                  color: (current - p).abs() < 0.001
                      ? DesignTokens.white
                      : DesignTokens.textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: DesignTokens.spacingLg),
        Text(l10n.wizardExactValue, style: DesignTokens.subtitle2),
        const SizedBox(height: DesignTokens.spacingSm),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            errorText: error,
          ),
          onChanged: onExact,
        ),
      ],
    );
  }
}

class _WallStep extends StatelessWidget {
  const _WallStep({
    required this.wall,
    required this.onLength,
    required this.onAddOpening,
  });

  final WallMeasurement wall;
  final ValueChanged<double> onLength;
  final VoidCallback onAddOpening;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.wizardWallTitle(_letter(wall.type)),
          style: DesignTokens.heading2,
        ),
        const SizedBox(height: DesignTokens.spacingXs),
        Text(
          l10n.wizardWallSubtitle,
          style: DesignTokens.body2.copyWith(color: DesignTokens.textGray),
        ),
        const SizedBox(height: DesignTokens.spacingMd),
        // Wall elevation diagram (reused painter).
        AspectRatio(
          aspectRatio: 1.6,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: DesignTokens.backgroundLight,
              borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
              border: Border.all(color: DesignTokens.borderGray),
            ),
            child: CustomPaint(painter: WallElevationPainter(wall: wall)),
          ),
        ),
        const SizedBox(height: DesignTokens.spacingMd),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.measureLength, style: DesignTokens.body2),
            Text(
              '${wall.length.toStringAsFixed(1)} m',
              style: DesignTokens.subtitle2
                  .copyWith(color: DesignTokens.primaryBlue),
            ),
          ],
        ),
        Slider(
          value: wall.length.clamp(1.0, 10.0),
          min: 1,
          max: 10,
          divisions: 90,
          activeColor: DesignTokens.primaryBlue,
          onChanged: onLength,
        ),
        if (wall.openings.isNotEmpty) ...[
          const SizedBox(height: DesignTokens.spacingSm),
          for (final o in wall.openings)
            Padding(
              padding: const EdgeInsets.only(bottom: DesignTokens.spacingXs),
              child: Row(
                children: [
                  Icon(
                    o.type == OpeningType.dual
                        ? Icons.window_outlined
                        : Icons.door_front_door_outlined,
                    size: DesignTokens.iconSm,
                    color: DesignTokens.textGray,
                  ),
                  const SizedBox(width: DesignTokens.spacingSm),
                  Text(
                    '${(o.width * 100).toStringAsFixed(0)}×${(o.height * 100).toStringAsFixed(0)} sm',
                    style: DesignTokens.caption,
                  ),
                ],
              ),
            ),
        ],
        const SizedBox(height: DesignTokens.spacingSm),
        OutlinedButton.icon(
          onPressed: onAddOpening,
          icon: const Icon(Icons.add),
          label: Text(l10n.openingAddSpaced),
        ),
      ],
    );
  }

  String _letter(WallType t) => switch (t) {
        WallType.wallA => 'A',
        WallType.wallB => 'B',
        WallType.wallC => 'C',
        WallType.wallD => 'D',
        WallType.unknown => '',
      };
}

class _SummaryStep extends StatelessWidget {
  const _SummaryStep({
    required this.plan,
    required this.openingStudio,
    required this.onViewSmeta,
    required this.onStartDesign,
  });

  final RoomPlan plan;
  final bool openingStudio;
  final VoidCallback onViewSmeta;
  final VoidCallback onStartDesign;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final floorArea = plan.areaM2;
    final perimeter = plan.perimeterM;
    final nettoWall = plan.netWallAreaM2;
    final openingCount =
        plan.walls.fold<int>(0, (s, w) => s + w.openings.length);

    return Column(
      children: [
        const SizedBox(height: DesignTokens.spacingLg),
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: DesignTokens.successGreen,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: DesignTokens.white, size: 36),
        ),
        const SizedBox(height: DesignTokens.spacingMd),
        Text(l10n.wizardSummaryTitle,
            style: DesignTokens.heading2, textAlign: TextAlign.center),
        Text(
          l10n.wizardSummarySubtitle,
          style: DesignTokens.body2.copyWith(color: DesignTokens.textGray),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: DesignTokens.spacingXl),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: DesignTokens.spacingMd,
          mainAxisSpacing: DesignTokens.spacingMd,
          childAspectRatio: 1.5,
          children: [
            _Stat(
                value: '${floorArea.toStringAsFixed(1)} m²',
                label: l10n.wizardStatFloor),
            _Stat(
                value: '${nettoWall.toStringAsFixed(1)} m²',
                label: l10n.wizardStatWallNet),
            _Stat(
                value: '${perimeter.toStringAsFixed(1)} m',
                label: l10n.wizardStatPerimeter),
            _Stat(
                value: l10n.summaryOpeningsCount(openingCount),
                label: l10n.wizardStatOpenings),
          ],
        ),
        const SizedBox(height: DesignTokens.spacingXl),
        SizedBox(
          width: double.infinity,
          height: DesignTokens.buttonHeightLarge,
          child: ElevatedButton(
            onPressed: openingStudio ? null : onViewSmeta,
            child: Text(l10n.wizardViewSmeta),
          ),
        ),
        const SizedBox(height: DesignTokens.spacingSm),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: openingStudio ? null : onStartDesign,
            icon: openingStudio
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.view_in_ar_outlined),
            label: Text(
                openingStudio ? l10n.wizardOpening : l10n.wizardStartDesign),
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacingMd),
      decoration: BoxDecoration(
        color: DesignTokens.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(color: DesignTokens.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value,
              style: DesignTokens.heading3.copyWith(color: DesignTokens.primaryBlue)),
          const SizedBox(height: DesignTokens.spacingXs),
          Text(label,
              style: DesignTokens.caption.copyWith(color: DesignTokens.textGray)),
        ],
      ),
    );
  }
}
