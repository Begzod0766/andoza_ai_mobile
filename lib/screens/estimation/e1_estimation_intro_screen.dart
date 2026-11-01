import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/design_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../models/api/api.dart' show DeltaResponse, RoomStateValue;
import '../../utils/error_mapper.dart';
import '../../models/design_selection_model.dart';
import '../../models/estimate_model.dart';
import '../../providers/apartment_provider.dart';
import '../../providers/estimate_api_provider.dart';
import '../../providers/estimate_provider.dart';
import '../../providers/room_persistence_provider.dart';
import '../../providers/room_provider.dart';
import '../../services/pdf_share_service.dart';
import '../../utils/currency.dart';
import '../studio/ai_builder_sheet.dart';

/// E1: Remont smetasi — money appears for the first time here. Big blue
/// total card (Materiallar/Ishchi kuchi split), a green delta-savings
/// banner computed from actually-excluded stages (never hardcoded), and
/// a stage list where excluded stages render gray/struck-through/
/// "hisoblanmadi" — all driven by the real [estimateProvider].
class E1EstimationIntroScreen extends ConsumerStatefulWidget {
  const E1EstimationIntroScreen({super.key});

  @override
  ConsumerState<E1EstimationIntroScreen> createState() =>
      _E1EstimationIntroScreenState();
}

class _E1EstimationIntroScreenState
    extends ConsumerState<E1EstimationIntroScreen> {
  bool _downloadingPdf = false;

  @override
  void initState() {
    super.initState();
    // Persist the captured room to the backend so "tejaldingiz" can reflect the
    // real server delta. Fire-and-forget: the UI shows the local estimate while
    // this runs and falls back to it if the backend is unreachable.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(roomPersistenceProvider.notifier).ensurePersisted();
    });
  }

  /// Downloads the server-generated smeta PDF for the persisted room and opens
  /// the share sheet, pointing from the PDF button ([buttonContext]). Requires
  /// the room to be persisted (Phase 2 bridge).
  Future<void> _downloadPdf(
    BuildContext buttonContext,
    String roomId,
    String roomName,
  ) async {
    final origin = _shareOrigin(buttonContext);
    setState(() => _downloadingPdf = true);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;
    try {
      final bytes = await ref
          .read(estimateRepositoryProvider)
          .downloadPdf(roomId);
      await sharePdfBytes(
        bytes,
        fileName: 'smeta_${roomName.replaceAll(' ', '_')}',
        shareText: 'AndozaAI smeta — $roomName',
        origin: origin,
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.estimatePdfFailed(mapErrorToMessage(e)))),
      );
    } finally {
      if (mounted) setState(() => _downloadingPdf = false);
    }
  }

  /// The widget's area in global coordinates, for the share sheet to point
  /// from; iOS 26 refuses a zero-sized origin.
  Rect _shareOrigin(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return const Rect.fromLTWH(0, 0, 1, 1);
    return box.localToGlobal(Offset.zero) & box.size;
  }

  /// The stage label to show in the savings banner when using the backend
  /// delta — the first completed stage beyond raw (korobka).
  String _backendSavingsLabel(DeltaResponse delta, AppLocalizations l10n) {
    final done = delta.completedStages
        .where((s) => s.stage != RoomStateValue.xom)
        .toList();
    return done.isNotEmpty ? done.first.labelUz : l10n.estimateSomeWork;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final estimate = ref.watch(estimateProvider);
    final room = ref.watch(activeRoomProvider);
    final materials = estimateMaterialsTotal(estimate);
    final labor = estimateLaborTotal(estimate);
    final localSavings = estimateSavingsTotal(estimate);
    final savingsStage = estimate.stages.firstWhere(
      (s) => s.isExcluded,
      orElse: () => estimate.stages.first,
    );

    // Prefer the backend's authoritative delta once the room is persisted;
    // otherwise fall back to the local computation.
    final persisted = ref.watch(roomPersistenceProvider).valueOrNull;
    final roomId = persisted?.roomId;
    final backendDelta = roomId == null
        ? null
        : ref.watch(roomDeltaProvider(roomId)).valueOrNull;
    final backendSavings = backendDelta?.deltaSavingsUzs;
    final useBackend = backendSavings != null && backendSavings > 0;
    final savings = useBackend ? backendSavings.toDouble() : localSavings;
    final savingsLabel = useBackend
        ? _backendSavingsLabel(backendDelta!, l10n)
        : (stageLabel(savingsStage.name) ?? l10n.estimateStageFallback);

    // The header is the whole-renovation estimate: materials + labour, the
    // same figure as the stage list below and the usta's summary in U5. The
    // server preview used to replace it once the room was saved, but that
    // prices only what was picked in the Studio and has no labour, so the
    // card read "703 000" over a 14 + 7 million split. The server smeta still
    // backs the PDF and the snapshot an usta receives.
    final displayTotal = estimate.totalPrice;
    final serverRoom = roomId == null
        ? null
        : ref.watch(serverRoomProvider(roomId)).valueOrNull;
    // The server smeta prices a floor type picked without a product from the
    // median shop product; the note says whether it did.
    final serverLines = roomId == null
        ? null
        : ref.watch(estimatePreviewProvider(roomId)).valueOrNull?.lines;
    final floor = serverRoom == null
        ? null
        : floorNote(serverRoom, serverLines);

    return Scaffold(
      backgroundColor: DesignTokens.backgroundLight,
      appBar: AppBar(
        backgroundColor: DesignTokens.backgroundLight,
        elevation: 0,
        title: Text(
          '${l10n.estimateTitlePrefix} · ${room?.name ?? l10n.estimateDefaultRoomName}'
          '${room != null ? ' · ${room.dimensions.width.toStringAsFixed(1)} × ${room.dimensions.length.toStringAsFixed(1)} m' : ''}',
          style: DesignTokens.subtitle2,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: l10n.estimateAdjust,
            onPressed: () => context.push('/estimation/e3'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(
                DesignTokens.screenPaddingHorizontal,
              ),
              children: [
                if (floor != null) ...[
                  _FloorNoteBanner(
                    note: floor,
                    onPick: () => context.push('/studio/$roomId'),
                  ),
                  const SizedBox(height: DesignTokens.spacingMd),
                ],
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(DesignTokens.spacingLg),
                  decoration: BoxDecoration(
                    color: DesignTokens.primaryBlue,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                    boxShadow: const [DesignTokens.shadowElevated],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.estimateApproxTotal,
                        style: DesignTokens.body2.copyWith(
                          color: DesignTokens.white.withValues(alpha: 0.75),
                        ),
                      ),
                      Text(
                        formatSom(displayTotal.round()),
                        style: DesignTokens.heading1.copyWith(
                          color: DesignTokens.white,
                        ),
                      ),
                      const SizedBox(height: DesignTokens.spacingMd),
                      Row(
                        children: [
                          Expanded(
                            child: _TotalColumn(
                              label: l10n.shopMaterials,
                              value: formatSom(materials.round()),
                            ),
                          ),
                          Expanded(
                            child: _TotalColumn(
                              label: l10n.estimateLabor,
                              value: formatSom(labor.round()),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (savings > 0) ...[
                  const SizedBox(height: DesignTokens.spacingMd),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(DesignTokens.spacingMd),
                    decoration: BoxDecoration(
                      color: DesignTokens.successGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        DesignTokens.radiusMd,
                      ),
                      border: Border.all(
                        color: DesignTokens.successGreen.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.savings_outlined,
                          color: DesignTokens.successGreen,
                        ),
                        const SizedBox(width: DesignTokens.spacingSm),
                        Expanded(
                          child: Text(
                            l10n.estimateSavingsBanner(
                              savingsLabel,
                              formatSom(savings.round()),
                            ),
                            style: DesignTokens.body2.copyWith(
                              color: DesignTokens.successGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: DesignTokens.spacingLg),
                for (final stage in estimate.stages) ...[
                  _StageRow(
                    stage: stage,
                    onTap: stage.isExcluded
                        ? null
                        : () => context.push('/estimation/e2', extra: stage),
                  ),
                  const SizedBox(height: DesignTokens.spacingSm),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(DesignTokens.spacingMd),
            decoration: const BoxDecoration(
              color: DesignTokens.white,
              boxShadow: [DesignTokens.shadowNavBar],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  if (roomId != null) ...[
                    Row(
                      children: [
                        Expanded(
                          child: Builder(
                            builder: (buttonContext) => OutlinedButton.icon(
                              onPressed: _downloadingPdf
                                  ? null
                                  : () => _downloadPdf(
                                      buttonContext,
                                      roomId,
                                      room?.name ?? 'Xona',
                                    ),
                              icon: _downloadingPdf
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.picture_as_pdf_outlined),
                              label: Text(
                                _downloadingPdf
                                    ? l10n.estimatePreparingPdf
                                    : 'PDF',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: DesignTokens.spacingSm),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => context.push('/studio/$roomId'),
                            icon: const Icon(Icons.view_in_ar_outlined),
                            label: Text(l10n.estimateOpen3dStudio),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: DesignTokens.spacingSm),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => AiBuilderSheet.show(context, roomId),
                        icon: const Icon(Icons.auto_awesome),
                        label: Text(l10n.studioAiDesigner),
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spacingSm),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        // The new whole-room AI designer lives in the web
                        // Studio's tools drawer (no deep link to open it).
                        onPressed: () => context.push('/studio/$roomId'),
                        icon: const Icon(Icons.auto_awesome_outlined),
                        label: Text(l10n.studioAiDesignerInStudio),
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spacingSm),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: DesignTokens.buttonHeightLarge,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignTokens.accentOrange,
                      ),
                      onPressed: () => context.push('/shop/s5'),
                      child: Text(l10n.estimateBuyFromShops),
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacingSm),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => context.push('/masters/u1'),
                      child: Text(l10n.estimateSendToMaster),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalColumn extends StatelessWidget {
  const _TotalColumn({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: DesignTokens.caption.copyWith(
            color: DesignTokens.white.withValues(alpha: 0.7),
          ),
        ),
        Text(
          value,
          style: DesignTokens.subtitle2.copyWith(color: DesignTokens.white),
        ),
      ],
    );
  }
}

class _StageRow extends StatelessWidget {
  const _StageRow({required this.stage, required this.onTap});

  final EstimateStage stage;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final label = stageLabel(stage.name) ?? stage.name.name;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(DesignTokens.spacingMd),
        decoration: BoxDecoration(
          color: DesignTokens.white,
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          border: Border.all(color: DesignTokens.borderGray),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: DesignTokens.body2.copyWith(
                  color: stage.isExcluded
                      ? DesignTokens.textMuted
                      : DesignTokens.textDark,
                ),
              ),
            ),
            if (stage.isExcluded)
              Text(
                l10n.estimateExcludedNote,
                style: DesignTokens.caption.copyWith(
                  color: DesignTokens.textMuted,
                ),
              )
            else
              const Icon(Icons.chevron_right, color: DesignTokens.textMuted),
            const SizedBox(width: DesignTokens.spacingSm),
            Text(
              stage.isExcluded
                  ? l10n.estimateZeroSom
                  : formatSom(stage.subtotal.round()),
              style: DesignTokens.subtitle2.copyWith(
                color: stage.isExcluded
                    ? DesignTokens.textMuted
                    : DesignTokens.primaryBlue,
                decoration: stage.isExcluded
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown when the Studio has a floor type but no floor product: the server
/// either priced it from the median shop product (approximate) or left it out.
/// Either way it leads back to the Studio to pick one.
class _FloorNoteBanner extends StatelessWidget {
  const _FloorNoteBanner({required this.note, required this.onPick});

  final FloorNote note;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacingMd),
      decoration: BoxDecoration(
        color: DesignTokens.accentOrange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        border: Border.all(color: DesignTokens.accentOrange),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: DesignTokens.accentOrange,
          ),
          const SizedBox(width: DesignTokens.spacingSm),
          Expanded(
            child: Text(
              note == FloorNote.standIn
                  ? l10n.estimateFloorStandIn
                  : l10n.estimateFloorUnpriced,
              style: DesignTokens.body2,
            ),
          ),
          TextButton(onPressed: onPick, child: Text(l10n.estimateFloorPick)),
        ],
      ),
    );
  }
}
