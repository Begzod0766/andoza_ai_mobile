import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/models/api/api.dart';
import 'package:tamir_uy_mobile_flutter/providers/apartment_provider.dart';

RoomOut _room({Map<String, dynamic>? design, Map<String, dynamic>? surfaces}) =>
    RoomOut(
      id: 'r',
      apartmentId: 'a',
      name: 'Xona',
      state: design == null ? null : {'designState': design},
      surfaces: surfaces,
      updatedAt: DateTime(2026),
    );

EstimateLine _line(String category) => EstimateLine(
      label: 'Laminat: o\'rtacha',
      formula: '',
      quantity: 14,
      unit: 'm²',
      unitPrice: 100,
      totalUzs: 1400,
      isApproximate: true,
      category: category,
    );

const _parket = {'floorConfigured': true, 'floorType': 'parket'};

// The web smeta's floorNote rule (handoff §7.2).
void main() {
  test('a floor type with no product priced from the median is a stand-in', () {
    expect(floorNote(_room(design: _parket), [_line('laminat')]), FloorNote.standIn);
    expect(floorNote(_room(design: _parket), [_line('plitka')]), FloorNote.standIn);
  });

  test('with no floor line in the smeta it is left out', () {
    expect(floorNote(_room(design: _parket), [_line('boyoq')]), FloorNote.leftOut);
    expect(floorNote(_room(design: _parket), null), FloorNote.leftOut);
  });

  test('nothing to say: a product chosen, no type, concrete, or untouched', () {
    expect(
      floorNote(_room(design: _parket, surfaces: {'floor': 'mat-1'}), null),
      isNull,
    );
    expect(floorNote(_room(design: {'floorConfigured': true}), null), isNull);
    expect(floorNote(_room(design: {'floorType': 'parket'}), null), isNull);
    expect(
      floorNote(_room(design: {'floorConfigured': true, 'floorType': 'concrete'}), null),
      isNull,
    );
    expect(floorNote(_room(), null), isNull);
  });
}
