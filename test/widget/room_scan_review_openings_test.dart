import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tamir_uy_mobile_flutter/features/room_scan/room_scan_converter.dart';
import 'package:tamir_uy_mobile_flutter/features/room_scan/room_scan_service.dart';
import 'package:tamir_uy_mobile_flutter/geometry/room_geometry.dart';
import 'package:tamir_uy_mobile_flutter/l10n/app_localizations.dart';
import 'package:tamir_uy_mobile_flutter/l10n/app_localizations_uz.dart';
import 'package:tamir_uy_mobile_flutter/models/api/api.dart';
import 'package:tamir_uy_mobile_flutter/models/room_plan.dart';
import 'package:tamir_uy_mobile_flutter/providers/room_persistence_provider.dart';
import 'package:tamir_uy_mobile_flutter/providers/room_provider.dart';
import 'package:tamir_uy_mobile_flutter/screens/scanning/room_scan_review_page.dart';
import 'package:tamir_uy_mobile_flutter/screens/scanning/scan_openings_editor.dart';

final l10n = AppLocalizationsUz();

class _FakePersistence extends RoomPersistenceNotifier {
  _FakePersistence(super.ref);

  @override
  Future<void> ensurePersisted({RoomCreate? override}) async {
    state = AsyncValue.data(PersistedRoom(
      clientRoomId: 'client-1',
      room: RoomOut(id: 'room-9', apartmentId: 'apt-1', name: 'Xona', updatedAt: DateTime(2026, 1, 1)),
    ));
  }
}

class _QuietScanService implements RoomScanService {
  @override
  Future<ScanSupport> checkSupport() async => const ScanSupport(true, null);
  @override
  Future<ScanResult?> scan({required Map<String, String> labels}) async => null;
  @override
  Future<String?> scanObject() async => null;
  @override
  Future<Map<String, dynamic>> uploadObject(String roomId, int objectIndex, String usdzPath) async => {};
  @override
  Future<MultiScanResult?> scanRooms({required Map<String, String> labels}) async => null;
  @override
  Future<Map<String, dynamic>> upload(String roomId, ScanResult scan, {String? scanGroup}) async => {};
  @override
  Future<Map<String, dynamic>> uploadThumbnail(String roomId, Uint8List png) async => {};
}

RoomPlan _plan() {
  const door = RoomOpening(type: 'door', width: 1.0, height: 2.0, position: 0.375);
  final base = RoomPlan.fromCorners(
    const [Vec2(0, 0), Vec2(4, 0), Vec2(4, 3), Vec2(0, 3)],
    ceilingHeightM: 2.7,
    source: RoomSource.arcore,
  );
  return withWallOpenings(base, 0, const [door]);
}

Future<ProviderContainer> _pump(WidgetTester tester) async {
  final router = GoRouter(
    initialLocation: '/review',
    routes: [
      GoRoute(
        path: '/review',
        builder: (_, _) => RoomScanReviewPage(
          args: RoomScanReviewArgs(draft: RoomScanDraft(plan: _plan(), objects: const []), scan: null),
        ),
      ),
      GoRoute(path: '/studio/:roomId', builder: (_, s) => Text('studio ${s.pathParameters['roomId']}')),
    ],
  );
  await tester.pumpWidget(ProviderScope(
    overrides: [
      roomPersistenceProvider.overrideWith((r) => _FakePersistence(r)),
      roomScanServiceProvider.overrideWithValue(_QuietScanService()),
    ],
    child: MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('uz'),
      routerConfig: router,
    ),
  ));
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(tester.element(find.byType(RoomScanReviewPage)));
}

Future<void> _tapVisible(WidgetTester tester, Finder f) async {
  await tester.scrollUntilVisible(f, 200, scrollable: find.byType(Scrollable).first);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

Finder get _row => find.byKey(const Key('scan-opening-0-0'));

void main() {
  test('withWallOpenings only touches that wall', () {
    final p = _plan();
    const w = RoomOpening(type: 'window', width: 1.2, height: 1.5, position: 0.5, sillHeight: 0.9);
    final q = withWallOpenings(p, 2, const [w]);
    expect(q.walls[2].openings.single.type, 'window');
    expect(q.walls[0].openings.single.type, 'door');
    expect([q.walls[1].openings, q.walls[3].openings], [isEmpty, isEmpty]);
    expect(q.corners, p.corners);
    expect([q.ceilingHeightM, q.source, q.name], [p.ceilingHeightM, p.source, p.name]);
    expect([for (final x in q.walls) x.lengthM], [for (final x in p.walls) x.lengthM]);
  });

  testWidgets('lists openings with their wall and size', (tester) async {
    await _pump(tester);
    await tester.scrollUntilVisible(_row, 200, scrollable: find.byType(Scrollable).first);
    expect(find.text(l10n.scanReviewOpeningsTitle), findsOneWidget);
    expect(find.descendant(of: _row, matching: find.text(l10n.scanReviewWall(1))), findsOneWidget);
    expect(find.descendant(of: _row, matching: find.text('${l10n.openingTypeDoor} · 1.00 × 2.00 m')), findsOneWidget);
  });

  testWidgets('editing changes the width', (tester) async {
    await _pump(tester);
    await _tapVisible(tester, _row);
    await tester.enterText(find.byKey(const Key('opening-width')), '90');
    await tester.pump();
    await tester.tap(find.text(l10n.openingSave));
    await tester.pumpAndSettle();
    expect(find.descendant(of: _row, matching: find.text('${l10n.openingTypeDoor} · 0.90 × 2.00 m')), findsOneWidget);
  });

  testWidgets('delete removes it', (tester) async {
    await _pump(tester);
    await _tapVisible(tester, _row);
    await tester.ensureVisible(find.text(l10n.openingDelete));
    await tester.tap(find.text(l10n.openingDelete));
    await tester.pumpAndSettle();
    expect(_row, findsNothing);
    expect(find.text(l10n.scanReviewOpeningsEmpty), findsOneWidget);
  });

  testWidgets('add puts a window on the picked wall with the default sill', (tester) async {
    final container = await _pump(tester);
    await _tapVisible(tester, find.text(l10n.scanReviewOpeningAdd));
    await tester.tap(find.descendant(of: find.byType(BottomSheet), matching: find.text(l10n.scanReviewWall(2))));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.openingTypeWindow));
    await tester.pump();
    await tester.ensureVisible(find.text(l10n.openingAddToWall));
    await tester.tap(find.text(l10n.openingAddToWall));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('scan-opening-1-0')), findsOneWidget);
    expect(container, isNotNull);
  });

  testWidgets('continue saves the edited openings', (tester) async {
    final container = await _pump(tester);
    await _tapVisible(tester, _row);
    await tester.enterText(find.byKey(const Key('opening-width')), '90');
    await tester.pump();
    await tester.tap(find.text(l10n.openingSave));
    await tester.pumpAndSettle();

    final continueButton = find.text('Davom etish');
    await tester.scrollUntilVisible(continueButton, 300, scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await tester.tap(continueButton);
      await Future<void>.delayed(const Duration(milliseconds: 500));
    });
    await tester.pumpAndSettle();

    final saved = container.read(activeRoomPlanProvider)!;
    expect(saved.walls[0].openings.single.width, closeTo(0.90, 1e-9));
    expect(find.text('studio room-9'), findsOneWidget);
  });
}
