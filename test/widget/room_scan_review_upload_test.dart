import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tamir_uy_mobile_flutter/features/room_scan/models/captured_room.dart';
import 'package:tamir_uy_mobile_flutter/features/room_scan/room_scan_converter.dart';
import 'package:tamir_uy_mobile_flutter/features/room_scan/room_scan_service.dart';
import 'package:tamir_uy_mobile_flutter/geometry/room_geometry.dart';
import 'package:tamir_uy_mobile_flutter/l10n/app_localizations.dart';
import 'package:tamir_uy_mobile_flutter/models/api/api.dart';
import 'package:tamir_uy_mobile_flutter/models/room_plan.dart';
import 'package:tamir_uy_mobile_flutter/providers/room_persistence_provider.dart';
import 'package:tamir_uy_mobile_flutter/screens/scanning/room_scan_review_page.dart';
import 'package:tamir_uy_mobile_flutter/utils/error_mapper.dart';

/// Persists nothing but reports a server room id, so the review page's handoff
/// succeeds and the flow reaches the artifact upload.
class _FakePersistence extends RoomPersistenceNotifier {
  _FakePersistence(super.ref);

  @override
  Future<void> ensurePersisted({RoomCreate? override}) async {
    state = AsyncValue.data(
      PersistedRoom(
        clientRoomId: 'client-1',
        room: RoomOut(
          id: 'room-9',
          apartmentId: 'apt-1',
          name: 'Xona',
          updatedAt: DateTime(2026, 1, 1),
        ),
      ),
    );
  }
}

/// Reproduces the backend bug this guard exists for: every artifact upload
/// fails, while the room itself is already created.
class _FailingScanService implements RoomScanService {
  @override
  Future<ScanSupport> checkSupport() async => const ScanSupport(true, null);

  @override
  Future<ScanResult?> scan({required Map<String, String> labels}) async => null;

  @override
  Future<String?> scanObject() async => null;

  @override
  Future<Map<String, dynamic>> uploadObject(
          String roomId, int objectIndex, String usdzPath) async =>
      throw const RoomScanException('upload_failed', 'boom');

  @override
  Future<MultiScanResult?> scanRooms({required Map<String, String> labels}) async => null;

  @override
  Future<Map<String, dynamic>> upload(String roomId, ScanResult scan, {String? scanGroup}) async =>
      throw const RoomScanException('upload_failed', 'HTTP 500');

  @override
  Future<Map<String, dynamic>> uploadThumbnail(String roomId, Uint8List png) async =>
      throw const RoomScanException('upload_failed', 'HTTP 500');
}

RoomScanReviewArgs _args() {
  final plan = RoomPlan.fromCorners(
    const [Vec2(0, 0), Vec2(4, 0), Vec2(4, 3), Vec2(0, 3)],
    ceilingHeightM: 2.8,
    source: RoomSource.lidar,
  );
  return RoomScanReviewArgs(
    draft: RoomScanDraft(plan: plan, objects: const []),
    scan: const ScanResult(
      room: CapturedRoom(),
      rawJson: '{}',
      usdzPath: '/tmp/scan.usdz',
      version: 'roomplan-1',
    ),
  );
}

void main() {
  testWidgets(
    'a failed artifact upload still opens the studio but warns the user',
    (tester) async {
      final router = GoRouter(
        initialLocation: '/review',
        routes: [
          GoRoute(
            path: '/review',
            builder: (_, _) => RoomScanReviewPage(args: _args()),
          ),
          GoRoute(
            path: '/studio/:roomId',
            builder: (_, state) => Scaffold(
              body: Text('studio ${state.pathParameters['roomId']}'),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            roomPersistenceProvider.overrideWith((r) => _FakePersistence(r)),
            roomScanServiceProvider.overrideWithValue(_FailingScanService()),
          ],
          child: MaterialApp.router(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('uz'),
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final continueButton = find.text('Davom etish');
      await tester.scrollUntilVisible(continueButton, 300);
      await tester.pumpAndSettle();
      // runAsync: the thumbnail step rasterises off-screen via
      // `Picture.toImage`, which only completes on the real event loop.
      await tester.runAsync(() async {
        await tester.tap(continueButton);
        await Future<void>.delayed(const Duration(milliseconds: 500));
      });
      await tester.pumpAndSettle();

      // Non-blocking: the room is valid, so the studio still opens…
      expect(find.text('studio room-9'), findsOneWidget);
      // …but the lost mesh is no longer silent.
      expect(
        find.textContaining('Skan fayllari yuklanmadi'),
        findsOneWidget,
      );
      expect(find.textContaining(errorGeneric), findsOneWidget);
    },
  );
}
