import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:tamir_uy_mobile_flutter/models/api/api.dart';
import 'package:tamir_uy_mobile_flutter/providers/apartment_provider.dart';
import 'package:tamir_uy_mobile_flutter/providers/estimate_provider.dart';
import 'package:tamir_uy_mobile_flutter/providers/shop_provider.dart';
import 'package:tamir_uy_mobile_flutter/utils/project_areas.dart';

RoomOut _room(String id) => RoomOut(
      id: id,
      apartmentId: 'a',
      name: 'Xona',
      floorArea: 14.4,
      netWallArea: 38.0,
      updatedAt: DateTime(2026),
    );

void main() {
  test("a saved room that is not open is priced like E1: materials and labour",
      () async {
    final room = _room('r1');
    final container = ProviderContainer(overrides: [
      serverRoomProvider('r1').overrideWith((ref) async => room),
    ]);
    addTearDown(container.dispose);

    final sub = container.listen(roomEstimateTotalProvider('r1'), (_, _) {});
    addTearDown(sub.close);
    final total = await container.read(roomEstimateTotalProvider('r1').future);

    final expected = buildEstimate(
      roomId: 'r1',
      areas: computeProjectAreasFromRoomOut(room),
      electrical: const ElectricalNeed(
        outletCount: 8,
        wireMeters: 72.0,
        switchCount: 4,
        lightCount: 6,
        pipeCount: 4,
      ),
      furnitureCount: 0,
      excludedStages: const {},
      tier: QualityTier.standart,
      diy: false,
    );
    expect(total, expected.totalPrice);
    // Millions, not the Studio-picks-only preview (hundreds of thousands).
    expect(total, greaterThan(5000000));
    expect(
      total,
      closeTo(
        estimateMaterialsTotal(expected) + estimateLaborTotal(expected),
        1,
      ),
    );
  });
}
