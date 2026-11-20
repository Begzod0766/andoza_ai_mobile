import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/models/api/api.dart';

/// Fixtures are REAL responses captured from the running backend on
/// 2026-08-05 (a room with a paint material assigned to all walls), so these
/// verify the Phase 3 estimate models against the actual smeta wire format.
void main() {
  group('Estimate (preview payload)', () {
    final json = {
      'id': 'bf4e3f1f-1e40-4cbb-918a-bbc67bd47393',
      'room_id': 'ad739348-d884-4810-96ab-5395120a4909',
      'lines': [
        {
          'label': "Bo'yoq: Tikkurila Euro 3 Oq",
          'formula': '45.4 m² × 2 qatlam ÷ 9.0 m²/litr = 11 litr',
          'quantity': 11.0,
          'unit': 'litr',
          'unit_price': 45000,
          'total_uzs': 495000,
          'is_approximate': false,
          'store_id': null,
          'category': 'boyoq',
        },
        {
          'label': 'Elektr kabel (taxminiy)',
          'formula': '8 nuqta × 8.0 m × 1.15 (zaxira) = 74 m',
          'quantity': 74.0,
          'unit': 'm',
          'unit_price': 10000,
          'total_uzs': 740000,
          'is_approximate': true,
          'store_id': null,
          'category': 'elektr',
        },
      ],
      'total_uzs': 840000,
      'total_min': 756000,
      'total_max': 924000,
      'currency': 'UZS',
      'status': 'draft',
      'created_at': '2026-08-05T18:40:22.663613Z',
      'has_electrical': false,
    };

    test('parses totals, status, and lines', () {
      final est = Estimate.fromJson(json);
      expect(est.totalUzs, 840000);
      expect(est.totalMin, 756000);
      expect(est.totalMax, 924000);
      expect(est.currency, 'UZS');
      expect(est.status, 'draft');
      expect(est.lines, hasLength(2));
    });

    test('maps a real priced paint line', () {
      final line = Estimate.fromJson(json).lines.first;
      expect(line.label, "Bo'yoq: Tikkurila Euro 3 Oq");
      expect(line.quantity, 11.0);
      expect(line.unit, 'litr');
      expect(line.unitPrice, 45000);
      expect(line.totalUzs, 495000);
      expect(line.isApproximate, isFalse);
      expect(line.category, 'boyoq');
    });

    test('flags the approximate electrical line', () {
      final elec = Estimate.fromJson(json).lines.last;
      expect(elec.isApproximate, isTrue);
      expect(elec.category, 'elektr');
    });

    test('parses the guest prices flag', () {
      expect(
        Estimate.fromJson({...json, 'prices_approximate_for_guest': true})
            .pricesApproximateForGuest,
        isTrue,
      );
      expect(Estimate.fromJson(json).pricesApproximateForGuest, isFalse);
    });
  });

  group('Estimate (exact/approximate split)', () {
    // The split, the per-line warning and the USD conversion are newer fields:
    // the payload above predates them, so these check both that they parse and
    // that an older payload without them still deserialises.
    final json = {
      'id': 'bf4e3f1f-1e40-4cbb-918a-bbc67bd47393',
      'room_id': 'ad739348-d884-4810-96ab-5395120a4909',
      'lines': [
        {
          'label': 'Elektr kabel (taxminiy)',
          'formula': '8 nuqta x 8.0 m x 1.15 (zaxira) = 74 m',
          'quantity': 74.0,
          'unit': 'm',
          'unit_price': 10000,
          'total_uzs': 740000,
          'is_approximate': true,
          'category': 'elektr',
          'warning': 'Nuqtalar soni taxminiy hisoblandi',
        },
      ],
      'total_uzs': 840000,
      'total_exact_uzs': 100000,
      'total_approx_uzs': 740000,
      'total_min': 756000,
      'total_max': 924000,
      'created_at': '2026-08-05T18:40:22.663613Z',
      'has_electrical': true,
      'electrical_confirmed': true,
      'usd_rate': 12600.0,
      'total_usd': 67,
    };

    test('parses the totals split, the USD conversion and the line warning',
        () {
      final est = Estimate.fromJson(json);
      expect(est.totalExactUzs, 100000);
      expect(est.totalApproxUzs, 740000);
      expect(est.electricalConfirmed, isTrue);
      expect(est.usdRate, 12600.0);
      expect(est.totalUsd, 67);
      expect(est.lines.single.warning, 'Nuqtalar soni taxminiy hisoblandi');
    });

    test('defaults the new fields when an older payload omits them', () {
      final old = Map<String, dynamic>.from(json)
        ..remove('total_exact_uzs')
        ..remove('total_approx_uzs')
        ..remove('electrical_confirmed')
        ..remove('usd_rate')
        ..remove('total_usd');
      final est = Estimate.fromJson(old);
      expect(est.totalExactUzs, 0);
      expect(est.totalApproxUzs, 0);
      expect(est.electricalConfirmed, isFalse);
      expect(est.usdRate, 0.0);
      expect(est.totalUsd, 0);
    });

    test('writes the new fields back out under their wire names', () {
      final out = Estimate.fromJson(json).toJson();
      expect(out['total_exact_uzs'], 100000);
      expect(out['total_approx_uzs'], 740000);
      expect(out['electrical_confirmed'], isTrue);
      expect(out['usd_rate'], 12600.0);
      expect(out['total_usd'], 67);
    });
  });

  group('PaginatedEstimates (history)', () {
    test('parses a real history envelope', () {
      final page = PaginatedEstimates.fromJson({
        'items': [
          {
            'id': '47101c4c-cb1e-4273-b2ed-6b5e58edb6de',
            'room_id': 'ad739348-d884-4810-96ab-5395120a4909',
            'total_uzs': 840000,
            'currency': 'UZS',
            'status': 'final',
            'created_at': '2026-08-05T18:41:36.249770Z',
          },
        ],
        'total': 1,
        'limit': 20,
        'offset': 0,
      });

      expect(page.total, 1);
      expect(page.items.single.status, 'final');
      expect(page.items.single.totalUzs, 840000);
    });
  });
}
