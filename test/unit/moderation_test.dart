import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tamir_uy_mobile_flutter/features/moderation/blocked_ustalar.dart';
import 'package:tamir_uy_mobile_flutter/features/moderation/report_repository.dart';
import 'package:tamir_uy_mobile_flutter/features/moderation/report_sheet.dart';
import 'package:tamir_uy_mobile_flutter/models/api/usta.dart';
import 'package:tamir_uy_mobile_flutter/providers/catalog_provider.dart';
import 'package:tamir_uy_mobile_flutter/providers/masters_provider.dart';
import 'package:tamir_uy_mobile_flutter/services/api_client.dart';

import '../support/localized_pump.dart';

class _Adapter implements HttpClientAdapter {
  RequestOptions? last;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    last = options;
    return ResponseBody.fromString(
      jsonEncode({'id': 'r1', 'status': 'open'}),
      201,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _FakeReports implements ReportRepository {
  final sent = <(ReportTarget, String, ReportReason, String?)>[];

  @override
  Future<void> report({
    required ReportTarget target,
    required String targetId,
    required ReportReason reason,
    String? details,
  }) async {
    sent.add((target, targetId, reason, details));
  }
}

const UstaFilter _allFilter = (category: null, district: null);

Usta _usta(String id) => Usta(
  id: id,
  name: 'Usta $id',
  category: 'malyar',
  phone: '998900000000',
  rating: 4.5,
  jobsCount: 0,
  verified: false,
);

void main() {
  test('report posts the wire names and trims the details', () async {
    final adapter = _Adapter();
    final client = ApiClient(baseUrl: 'http://test.local/api/v1');
    client.httpDioForTest.httpClientAdapter = adapter;

    await ReportRepository(client).report(
      target: ReportTarget.portfolioItem,
      targetId: 'p1',
      reason: ReportReason.inappropriate,
      details: '  rude  ',
    );

    expect(adapter.last!.path, endsWith('/reports'));
    expect(adapter.last!.data, {
      'target_type': 'portfolio_item',
      'target_id': 'p1',
      'reason': 'inappropriate',
      'details': 'rude',
    });
  });

  test('blocked ustalar are left out of the list and remembered', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer(
      overrides: [
        ustalarProvider(_allFilter)
            .overrideWith((ref) async => [_usta('a'), _usta('b')]),
      ],
    );
    addTearDown(container.dispose);
    final sub = container.listen(mockMastersProvider, (_, _) {});
    addTearDown(sub.close);
    await container.read(ustalarProvider(_allFilter).future);
    expect(container.read(mockMastersProvider).map((m) => m.master.id), [
      'a',
      'b',
    ]);

    await container.read(blockedUstalarProvider.notifier).block('a');

    expect(container.read(mockMastersProvider).map((m) => m.master.id), ['b']);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList(BlockedUstalarNotifier.prefsKey), ['a']);
  });

  test('a saved block list is loaded back', () async {
    SharedPreferences.setMockInitialValues({
      BlockedUstalarNotifier.prefsKey: ['x'],
    });
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(blockedUstalarProvider);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(blockedUstalarProvider), {'x'});
  });

  testWidgets('the sheet sends the chosen reason and closes', (tester) async {
    final reports = _FakeReports();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [reportRepositoryProvider.overrideWithValue(reports)],
        child: wrapLocalized(
          Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showReportSheet(
                  context,
                  target: ReportTarget.usta,
                  targetId: 'u9',
                ),
                child: const Text('open'),
              ),
            ),
          ),
          withProviderScope: false,
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // Nothing chosen yet: send is disabled.
    final send = find.widgetWithText(FilledButton, 'Yuborish');
    expect(tester.widget<FilledButton>(send).onPressed, isNull);

    await tester.tap(find.text('Firibgarlik'));
    await tester.pump();
    await tester.tap(send);
    await tester.pumpAndSettle();

    expect(reports.sent.single.$1, ReportTarget.usta);
    expect(reports.sent.single.$2, 'u9');
    expect(reports.sent.single.$3, ReportReason.fraud);
    expect(find.text('Rahmat! Shikoyatingiz yuborildi.'), findsOneWidget);
    expect(find.byType(ReportSheet), findsNothing);
  });
}
