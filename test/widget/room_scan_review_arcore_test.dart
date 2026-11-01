import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tamir_uy_mobile_flutter/features/room_scan/room_scan_converter.dart';
import 'package:tamir_uy_mobile_flutter/features/room_scan/room_scan_service.dart';
import 'package:tamir_uy_mobile_flutter/geometry/room_geometry.dart';
import 'package:tamir_uy_mobile_flutter/l10n/app_localizations.dart';
import 'package:tamir_uy_mobile_flutter/models/api/api.dart';
import 'package:tamir_uy_mobile_flutter/models/room_plan.dart';
import 'package:tamir_uy_mobile_flutter/providers/room_persistence_provider.dart';
import 'package:tamir_uy_mobile_flutter/screens/scanning/room_scan_review_page.dart';

class _FakePersistence extends RoomPersistenceNotifier {
  _FakePersistence(super.ref);
  @override
  Future<void> ensurePersisted({RoomCreate? override}) async {
    state = AsyncValue.data(PersistedRoom(
      clientRoomId: 'c',
      room: RoomOut(id: 'room-7', apartmentId: 'a', name: 'Xona', updatedAt: DateTime(2026)),
    ));
  }
}

/// Records what the review page asks of the LiDAR service; an ARCore room has
/// no scan payload, so `upload` must never be called.
class _RecordingScanService implements RoomScanService {
  final calls = <String>[];
  @override
  Future<Map<String, dynamic>> upload(String roomId, ScanResult scan, {String? scanGroup}) async {
    calls.add('upload');
    return {};
  }

  @override
  dynamic noSuchMethod(Invocation i) {
    calls.add(i.memberName.toString());
    return Future<Map<String, dynamic>>.value(<String, dynamic>{});
  }
}

RoomScanReviewArgs _args() => RoomScanReviewArgs(
      draft: RoomScanDraft(
        plan: RoomPlan.fromCorners(
          const [Vec2(0, 0), Vec2(4, 0), Vec2(4, 3), Vec2(0, 3)],
          ceilingHeightM: 2.7,
          source: RoomSource.arcore,
        ),
        objects: const [],
      ),
      scan: null,
    );

void main() {
  final l10n = lookupAppLocalizations(const Locale('uz'));

  Future<_RecordingScanService> pump(WidgetTester tester) async {
    final svc = _RecordingScanService();
    final router = GoRouter(initialLocation: '/review', routes: [
      GoRoute(path: '/review', builder: (_, _) => RoomScanReviewPage(args: _args())),
      GoRoute(path: '/studio/:id', builder: (_, s) => Text('studio ${s.pathParameters['id']}')),
    ]);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        roomPersistenceProvider.overrideWith((r) => _FakePersistence(r)),
        roomScanServiceProvider.overrideWithValue(svc),
      ],
      child: MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('uz'),
        routerConfig: router,
      ),
    ));
    await tester.pumpAndSettle();
    return svc;
  }

  testWidgets('review shows the accuracy note for arcore scans', (tester) async {
    await pump(tester);
    expect(find.text(l10n.scanReviewArcoreAccuracy), findsOneWidget);
    expect(find.text('Nimalar aniqlandi'), findsNothing);
  });

  testWidgets('review saves without a LiDAR scan payload', (tester) async {
    final svc = await pump(tester);
    final cont = find.text('Davom etish');
    await tester.scrollUntilVisible(cont, 300);
    await tester.runAsync(() async {
      await tester.tap(cont);
      await Future<void>.delayed(const Duration(milliseconds: 500));
    });
    await tester.pumpAndSettle();
    expect(find.text('studio room-7'), findsOneWidget);
    expect(svc.calls, isNot(contains('upload')));
  });
}
