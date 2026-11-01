import 'package:riverpod/riverpod.dart';
import '../l10n/app_localizations.dart';
import '../models/design_selection_model.dart';
import '../models/estimate_model.dart';
import '../utils/project_areas.dart';
import 'apartment_provider.dart';
import 'design_provider.dart';
import 'room_persistence_provider.dart';
import 'room_provider.dart';
import 'shop_provider.dart';

/// Smeta quality tiers (E3) — scales both material and labor uniformly.
/// Standart is the baseline; the multiplier is mock-but-plausible, not a
/// spec-given constant.
enum QualityTier { ekonom, standart, premium }

extension QualityTierInfo on QualityTier {
  String label(AppLocalizations l10n) => switch (this) {
    QualityTier.ekonom => l10n.qualityTierEkonom,
    QualityTier.standart => l10n.qualityTierStandart,
    QualityTier.premium => l10n.qualityTierPremium,
  };

  double get multiplier => switch (this) {
    QualityTier.ekonom => 0.75,
    QualityTier.standart => 1.0,
    QualityTier.premium => 1.4,
  };
}

final qualityTierProvider = StateProvider<QualityTier>(
  (ref) => QualityTier.standart,
);

/// "Ishchi kuchini qo'shmaslik" (DIY) toggle — excludes labor from the
/// charged total when true. Never affects [EstimateStage.counterfactualSubtotal],
/// since the savings banner answers "what would this stage have cost a
/// professional," independent of the user's own DIY choice.
final diyModeProvider = StateProvider<bool>((ref) => false);

class _StageCost {
  const _StageCost({required this.materialItems, required this.laborItems});
  final List<EstimateLineItem> materialItems;
  final List<EstimateLineItem> laborItems;
}

EstimateLineItem _line(String id, String desc, double qty, double unitPrice) {
  return EstimateLineItem(
    id: id,
    description: desc,
    quantity: qty,
    unitPrice: unitPrice,
    lineTotal: qty * unitPrice,
  );
}

/// Mock-but-plausible per-stage pricing, itemized into real qty × unit
/// price lines from the same project quantities Do'kon's catalog uses
/// (shop_provider.dart's areas/electrical need) so the Smeta and the shop
/// always agree on scope. Spec example figures (e.g. "Shpaklovka
/// 4 720 000") are a plausibility check only — never hardcoded as literal
/// output.
Map<RenovationStage, _StageCost> _stageCosts(
  ProjectAreas areas,
  ElectricalNeed electrical,
  int furnitureCount,
) {
  final wallArea = areas.wallArea;
  final floorArea = areas.floorArea;
  final furniture = furnitureCount > 0 ? furnitureCount : 5;

  return {
    RenovationStage.suvoq: _StageCost(
      materialItems: [_line('suvoq_mat', 'Suvoq aralashmasi', wallArea, 25000)],
      laborItems: [_line('suvoq_labor', 'Usta ishi', wallArea, 35000)],
    ),
    RenovationStage.shpaklovka: _StageCost(
      materialItems: [
        _line(
          'shpaklovka_mat',
          'Vetonit shpaklovka',
          (wallArea / 6).ceilToDouble(),
          68000,
        ),
      ],
      laborItems: [_line('shpaklovka_labor', 'Usta ishi', wallArea, 45000)],
    ),
    RenovationStage.boyoqOboi: _StageCost(
      materialItems: [
        _line(
          'oboi_mat',
          'Vinil devor qog\'ozi',
          (wallArea / 5).ceilToDouble(),
          145000,
        ),
        _line(
          'boyoq_mat',
          'Akril devor bo\'yog\'i',
          double.parse((wallArea * 0.2).toStringAsFixed(1)),
          45000,
        ),
      ],
      laborItems: [_line('boyoq_labor', 'Usta ishi', wallArea, 30000)],
    ),
    RenovationStage.pol: _StageCost(
      materialItems: [
        _line(
          'laminat_mat',
          'Laminat pol qoplamasi',
          double.parse((floorArea * 1.1).toStringAsFixed(1)),
          118000,
        ),
        _line('podloshka_mat', 'Podloshka', floorArea, 22000),
      ],
      laborItems: [_line('pol_labor', 'Usta ishi', floorArea, 40000)],
    ),
    RenovationStage.mebel: _StageCost(
      materialItems: [
        _line('mebel_mat', 'Mebel buyumlari', furniture.toDouble(), 1200000),
      ],
      laborItems: [
        _line('mebel_labor', 'O\'rnatish', furniture.toDouble(), 120000),
      ],
    ),
    RenovationStage.elektr: _StageCost(
      materialItems: [
        _line(
          'rozetka_mat',
          'Rozetka',
          electrical.outletCount.toDouble(),
          34000,
        ),
        _line(
          'kabel_mat',
          'Elektr kabeli',
          double.parse(electrical.wireMeters.toStringAsFixed(1)),
          9500,
        ),
      ],
      laborItems: [
        _line(
          'elektr_labor',
          'Montaj ishi',
          (electrical.outletCount + electrical.switchCount).toDouble(),
          95000,
        ),
      ],
    ),
    RenovationStage.yoruglik: _StageCost(
      materialItems: [
        _line(
          'yoruglik_mat',
          'Yoritish jihozi',
          electrical.lightCount.toDouble(),
          85000,
        ),
      ],
      laborItems: [
        _line(
          'yoruglik_labor',
          'O\'rnatish',
          electrical.lightCount.toDouble(),
          40000,
        ),
      ],
    ),
    RenovationStage.santexnika: _StageCost(
      materialItems: [
        _line(
          'santexnika_mat',
          'Santexnika jihozi',
          electrical.pipeCount.toDouble(),
          480000,
        ),
      ],
      laborItems: [
        _line(
          'santexnika_labor',
          'O\'rnatish',
          electrical.pipeCount.toDouble(),
          220000,
        ),
      ],
    ),
  };
}

/// Builds the real [Estimate] for the active project: excluded stages
/// (per the delta mechanic) are charged 0 but keep their real
/// [EstimateStage.counterfactualSubtotal] so the savings banner can sum
/// them, DIY mode zeroes labor on charged stages only, and the quality
/// tier scales both material and labor (and the counterfactual, so the
/// savings figure always reflects the user's chosen tier).
Estimate buildEstimate({
  required String roomId,
  required ProjectAreas areas,
  required ElectricalNeed electrical,
  required int furnitureCount,
  required Set<RenovationStage> excludedStages,
  required QualityTier tier,
  required bool diy,
}) {
  final costs = _stageCosts(areas, electrical, furnitureCount);
  // [kRenovationStages] excludes RenovationStage.unknown (a deserialization
  // fallback with no cost entry) so it is never priced.
  final stages = kRenovationStages.map((stage) {
    final cost = costs[stage]!;
    final scaledMaterial = cost.materialItems
        .map(
          (i) => i.copyWith(
            unitPrice: i.unitPrice * tier.multiplier,
            lineTotal: i.lineTotal * tier.multiplier,
          ),
        )
        .toList();
    final scaledLabor = cost.laborItems
        .map(
          (i) => i.copyWith(
            unitPrice: i.unitPrice * tier.multiplier,
            lineTotal: i.lineTotal * tier.multiplier,
          ),
        )
        .toList();
    final materialTotal = scaledMaterial.fold<double>(
      0,
      (sum, i) => sum + i.lineTotal,
    );
    final laborTotal = scaledLabor.fold<double>(
      0,
      (sum, i) => sum + i.lineTotal,
    );
    final isExcluded = excludedStages.contains(stage);
    final chargedLabor = diy ? 0.0 : laborTotal;
    final subtotal = isExcluded ? 0.0 : materialTotal + chargedLabor;
    return EstimateStage(
      name: stage,
      lineItems: [...scaledMaterial, if (!diy) ...scaledLabor],
      subtotal: subtotal,
      isExcluded: isExcluded,
      counterfactualSubtotal: materialTotal + laborTotal,
    );
  }).toList();

  final total = stages.fold<double>(0, (sum, s) => sum + s.subtotal);

  return Estimate(
    id: '${roomId}_estimate',
    roomId: roomId,
    roomArea: areas.floorArea,
    stages: stages,
    totalPrice: total,
    currency: 'UZS',
    createdAt: DateTime.now(),
  );
}

/// The live-recomputing Smeta for the active room — reacts to room/design/
/// electrical state and to E3's tier/DIY toggles.
final estimateProvider = Provider<Estimate>((ref) {
  final room = ref.watch(activeRoomProvider);
  final plan = ref.watch(activeRoomPlanProvider);
  final design = ref.watch(activeDesignProvider);
  final areas = computeProjectAreas(room, plan: plan);
  final electrical = computeElectricalNeed(ref);
  final tier = ref.watch(qualityTierProvider);
  final diy = ref.watch(diyModeProvider);

  final condition = design?.roomCondition;
  final excluded = design == null || condition == null
      ? <RenovationStage>{}
      : {
          for (final stage in kRenovationStages)
            if (deriveStageStates(
                  condition: condition,
                  currentStage: design.renovationStage,
                )[stage.index] ==
                StageDisplayState.excluded)
              stage,
        };

  return buildEstimate(
    roomId: room?.id ?? 'mock_room',
    areas: areas,
    electrical: electrical,
    furnitureCount: design?.furniture.length ?? 0,
    excludedStages: excluded,
    tier: tier,
    diy: diy,
  );
});

/// The whole-renovation estimate for a saved room, as one number — what Home's
/// project card shows, so it agrees with E1's header. The open room uses
/// [estimateProvider] itself (it knows the room's condition, tier and DIY
/// choice). Any other room is priced the same way from the server's measured
/// areas, with the default tier and nothing excluded. The server's own
/// preview prices only what was picked in the Studio and has no labour, so it
/// read "0.7 mln" next to a 21 million smeta.
final roomEstimateTotalProvider =
    FutureProvider.autoDispose.family<double, String>((ref, roomId) async {
  final persisted = ref.watch(roomPersistenceProvider).valueOrNull;
  if (persisted?.roomId == roomId) {
    return ref.watch(estimateProvider).totalPrice;
  }
  final room = await ref.watch(serverRoomProvider(roomId).future);
  return buildEstimate(
    roomId: roomId,
    areas: computeProjectAreasFromRoomOut(room),
    electrical: const ElectricalNeed(
      outletCount: 8,
      wireMeters: 72.0,
      switchCount: 4,
      lightCount: 6,
      pipeCount: 4,
    ),
    furnitureCount: room.furnitureLayout?.length ?? 0,
    excludedStages: const {},
    tier: QualityTier.standart,
    diy: false,
  ).totalPrice;
});

/// Materials total (E1's "Materiallar" column) — sum of non-excluded
/// stages' material lines only. Material/labor lines are distinguished by
/// their `_line()`-assigned id suffix (see [_stageCosts]), not position,
/// so this stays correct regardless of how many lines a stage has.
double estimateMaterialsTotal(Estimate estimate) => estimate.stages
    .where((s) => !s.isExcluded)
    .expand((s) => s.lineItems)
    .where((i) => i.id.endsWith('_mat'))
    .fold<double>(0, (sum, i) => sum + i.lineTotal);

/// Labor total (E1's "Ishchi kuchi" column) — 0 for every stage when DIY
/// is on, since [buildEstimate] drops the labor line items entirely.
double estimateLaborTotal(Estimate estimate) => estimate.stages
    .where((s) => !s.isExcluded)
    .expand((s) => s.lineItems)
    .where((i) => i.id.endsWith('_labor'))
    .fold<double>(0, (sum, i) => sum + i.lineTotal);

/// Total "tejaldingiz" (you saved) figure — the sum of what every
/// already-excluded stage would have cost a professional, at the user's
/// chosen tier.
double estimateSavingsTotal(Estimate estimate) => estimate.stages
    .where((s) => s.isExcluded)
    .fold<double>(0, (sum, s) => sum + s.counterfactualSubtotal);
