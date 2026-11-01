import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/geometry/room_geometry.dart';
import 'package:tamir_uy_mobile_flutter/l10n/app_localizations.dart';
import 'package:tamir_uy_mobile_flutter/models/api/api.dart';
import 'package:tamir_uy_mobile_flutter/models/room_plan.dart';
import 'package:tamir_uy_mobile_flutter/providers/apartment_provider.dart';
import 'package:tamir_uy_mobile_flutter/providers/business_provider.dart';
import 'package:tamir_uy_mobile_flutter/providers/masters_provider.dart';
import 'package:tamir_uy_mobile_flutter/repositories/apartment_repository.dart';
import 'package:tamir_uy_mobile_flutter/repositories/business_repository.dart';
import 'package:tamir_uy_mobile_flutter/repositories/masters_repository.dart';
import 'package:tamir_uy_mobile_flutter/screens/masters/u5_booking_confirmation_screen.dart';
import 'package:tamir_uy_mobile_flutter/services/analytics_service.dart';
import 'package:tamir_uy_mobile_flutter/services/room_plan_handoff.dart';

import '../support/fake_analytics_sink.dart';

class _FakeBusiness implements BusinessRepository {
  _FakeBusiness({this.fail = false});
  final bool fail;
  final sent = <String?>[];
  final phones = <String?>[];

  @override
  Future<void> sendLead(
    String ustaId, {
    String? roomId,
    String? message,
    String? contactPhone,
  }) async {
    if (fail) throw Exception('offline');
    sent.add(message);
    phones.add(contactPhone);
  }

  @override
  dynamic noSuchMethod(Invocation i) =>
      throw UnimplementedError('${i.memberName}');
}

class _FlakyApartments implements ApartmentRepository {
  int failuresLeft = 1;
  int created = 0;

  @override
  Future<List<Apartment>> listApartments() async => [
    Apartment(id: 'apt', userId: 'u', name: 'Uy', createdAt: DateTime(2026)),
  ];

  @override
  Future<RoomOut> createRoom(String apartmentId, RoomCreate body) async {
    if (failuresLeft > 0) {
      failuresLeft--;
      throw Exception('offline');
    }
    created++;
    return RoomOut(
      id: 'room-$created',
      apartmentId: apartmentId,
      name: body.name,
      updatedAt: DateTime(2026),
    );
  }

  @override
  dynamic noSuchMethod(Invocation i) =>
      throw UnimplementedError('${i.memberName}');
}

const _master = MockMaster(
  master: Master(id: 'usta-1', name: 'Ali Valiyev'),
  trade: Trade.elektrik,
  areaName: '',
  experienceYears: 3,
  isOnline: true,
  isVerified: true,
);

/// Pumps U5 pushed over a blank home, so the success `pop` has a route to
/// return to.
Future<void> _pumpU5(
  WidgetTester tester,
  FakeSink sink,
  BusinessRepository repo,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        analyticsSinkProvider.overrideWithValue(sink),
        businessRepositoryProvider.overrideWithValue(repo),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('uz'),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    const U5BookingConfirmationScreen(master: _master),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

Future<void> _tapSend(
  WidgetTester tester, {
  String phone = '+998 90 123-45-67',
}) async {
  final l10n = await AppLocalizations.delegate.load(const Locale('uz'));
  // U5 has two fields: the phone the usta calls back on, then the comment.
  await tester.enterText(find.byType(TextField).first, phone);
  await tester.enterText(find.byType(TextField).last, 'Ertaga keling, manzil: X');
  await tester.tap(find.text(l10n.mastersSend));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a sent lead logs lead_sent', (tester) async {
    final sink = FakeSink();
    final repo = _FakeBusiness();
    await _pumpU5(tester, sink, repo);
    await _tapSend(tester);

    expect(repo.sent, hasLength(1));
    expect(repo.phones, ['+998901234567']);
    expect(sink.events, [('lead_sent', null)]);
  });

  testWidgets('a phone that is not Uzbek is refused before sending',
      (tester) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('uz'));
    final sink = FakeSink();
    final repo = _FakeBusiness();
    await _pumpU5(tester, sink, repo);
    await _tapSend(tester, phone: '123');

    expect(repo.sent, isEmpty);
    expect(find.text(l10n.phoneErrorInvalid), findsOneWidget);
    expect(sink.events, isEmpty);
  });

  testWidgets('a failed lead logs nothing', (tester) async {
    final sink = FakeSink();
    await _pumpU5(tester, sink, _FakeBusiness(fail: true));
    await _tapSend(tester);

    expect(sink.events, isEmpty);
  });

  testWidgets('a saved room logs room_created once', (tester) async {
    final sink = FakeSink();
    final repo = _FlakyApartments();
    late WidgetRef ref;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          analyticsSinkProvider.overrideWithValue(sink),
          apartmentRepositoryProvider.overrideWithValue(repo),
        ],
        child: Consumer(
          builder: (context, r, _) {
            ref = r;
            return const SizedBox();
          },
        ),
      ),
    );

    final plan = RoomPlan.fromCorners(
      const [Vec2(0, 0), Vec2(4, 0), Vec2(4, 3), Vec2(0, 3)],
      ceilingHeightM: 2.8,
      source: RoomSource.sketch,
    );

    // First attempt fails (offline): nothing is logged.
    expect(await handoffRoomPlan(ref, plan), isNull);
    expect(sink.events, isEmpty);

    // The retry saves the room: exactly one room_created.
    expect(await handoffRoomPlan(ref, plan), 'room-1');
    await tester.pump();
    expect(sink.events.map((e) => '${e.$1} ${e.$2}').toList(), [
      'room_created {method: draw}',
    ]);
  });
}
