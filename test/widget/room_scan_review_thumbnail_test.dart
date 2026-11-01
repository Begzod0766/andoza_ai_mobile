import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tamir_uy_mobile_flutter/features/room_scan/models/captured_room.dart';
import 'package:tamir_uy_mobile_flutter/features/room_scan/room_scan_converter.dart';
import 'package:tamir_uy_mobile_flutter/features/room_scan/room_scan_service.dart';
import 'package:tamir_uy_mobile_flutter/l10n/app_localizations.dart';
import 'package:tamir_uy_mobile_flutter/models/api/api.dart';
import 'package:tamir_uy_mobile_flutter/providers/room_persistence_provider.dart';
import 'package:tamir_uy_mobile_flutter/screens/scanning/room_scan_review_page.dart';

import '../fixtures/scanned_room.dart';

/// The real measured scan (5 walls, one door, one window, 16 objects).
CapturedRoom _room() => CapturedRoom(
      walls: scanWalls(),
      doors: [scanDoor()],
      windows: [scanWindow()],
      objects: scanObjects(),
    );

/// Persists nothing but reports a server room id, so the handoff succeeds and
/// the flow reaches the thumbnail upload.
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

/// The artifact upload succeeds; only the thumbnail upload fails, so the test
/// isolates the new step's non-blocking contract.
class _ThumbnailFailingScanService implements RoomScanService {
  Uint8List? lastPng;

  @override
  Future<ScanSupport> checkSupport() async => const ScanSupport(true, null);

  @override
  Future<ScanResult?> scan({required Map<String, String> labels}) async => null;

  @override
  Future<String?> scanObject() async => null;

  @override
  Future<Map<String, dynamic>> uploadObject(
          String roomId, int objectIndex, String usdzPath) async =>
      const {};

  @override
  Future<MultiScanResult?> scanRooms({required Map<String, String> labels}) async => null;

  @override
  Future<Map<String, dynamic>> upload(String roomId, ScanResult scan, {String? scanGroup}) async =>
      const {};

  @override
  Future<Map<String, dynamic>> uploadThumbnail(
      String roomId, Uint8List png) async {
    lastPng = png;
    throw const RoomScanException('upload_failed', 'HTTP 500');
  }
}

void main() {
  testWidgets('the scan renders a real 512×512 PNG thumbnail off-screen',
      (tester) async {
    final draft = RoomScanConverter.toRoomDraft(_room());

    // `Picture.toImage` needs the real event loop, not the test binding's
    // fake async — hence runAsync here (and around the tap below).
    final png = (await tester.runAsync(() => renderRoomScanThumbnailPng(
          corners: draft.plan.corners,
          walls: draft.plan.walls,
        )))!;

    expect(png, isNotEmpty);
    // PNG magic bytes.
    expect(
      png.sublist(0, 8),
      orderedEquals(<int>[0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]),
    );
    // IHDR carries the pixel dimensions at bytes 16..23 (big-endian).
    final header = ByteData.sublistView(png, 16, 24);
    expect(header.getUint32(0), 512);
    expect(header.getUint32(4), 512);
    // A drawn plan, not a blank canvas: a 512×512 flat fill compresses to a
    // few hundred bytes, the floor/walls (no furniture — see
    // RoomScanConverter) to somewhat more.
    expect(png.length, greaterThan(500));
  });

  testWidgets('a failed thumbnail upload still opens the studio but warns',
      (tester) async {
    final service = _ThumbnailFailingScanService();
    final router = GoRouter(
      initialLocation: '/review',
      routes: [
        GoRoute(
          path: '/review',
          builder: (_, _) => RoomScanReviewPage(
            args: RoomScanReviewArgs(
              draft: RoomScanConverter.toRoomDraft(_room()),
              scan: ScanResult(
                room: _room(),
                rawJson: '{}',
                usdzPath: '/tmp/scan.usdz',
                version: 'roomplan-1',
              ),
            ),
          ),
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
          roomScanServiceProvider.overrideWithValue(service),
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
    await tester.runAsync(() async {
      await tester.tap(continueButton);
      // Let the off-screen rasterisation and the failing upload actually run.
      await Future<void>.delayed(const Duration(milliseconds: 500));
    });
    await tester.pumpAndSettle();

    // The upload was actually attempted, with real PNG bytes…
    expect(service.lastPng, isNotNull);
    expect(service.lastPng!.sublist(0, 4),
        orderedEquals(<int>[0x89, 0x50, 0x4E, 0x47]));
    // …it failed, and yet the studio opened anyway.
    expect(find.text('studio room-9'), findsOneWidget);
    // …and the blank project card is not silent.
    expect(find.textContaining('Xona ko\'rinishi yuklanmadi'), findsOneWidget);
  });
}
