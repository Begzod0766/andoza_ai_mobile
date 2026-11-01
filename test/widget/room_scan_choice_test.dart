import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tamir_uy_mobile_flutter/features/room_scan/room_scan_service.dart';
import 'package:tamir_uy_mobile_flutter/l10n/app_localizations.dart';
import 'package:tamir_uy_mobile_flutter/screens/scanning/room_scan_screen.dart';

class _FakeScan implements RoomScanService {
  _FakeScan(this.support);
  final ScanSupport support;
  int scans = 0;
  Map<String, String>? flatLabels;

  @override
  Future<ScanSupport> checkSupport() async => support;
  @override
  Future<ScanResult?> scan({required Map<String, String> labels}) async {
    scans++;
    return null; // cancelled
  }

  @override
  Future<MultiScanResult?> scanRooms({required Map<String, String> labels}) async {
    flatLabels = labels;
    return null; // cancelled
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _open(WidgetTester tester, _FakeScan fake) async {
  final router = GoRouter(initialLocation: '/', routes: [
    GoRoute(path: '/', builder: (_, _) => const Scaffold(body: Text('home'))),
    GoRoute(path: '/scan', builder: (_, _) => const RoomScanScreen()),
  ]);
  await tester.pumpWidget(ProviderScope(
    overrides: [roomScanServiceProvider.overrideWithValue(fake)],
    child: MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('uz'),
      routerConfig: router,
    ),
  ));
  router.push('/scan');
  // A spinner runs behind the choice sheet, so settle by time, not by idle.
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

/// The scanner path only runs on iOS (Android goes to ARCore).
void testIos(String name, Future<void> Function(WidgetTester) body) {
  testWidgets(name, (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      await body(tester);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}

void main() {
  testIos('no choice when multiRoom is false', (tester) async {
    final fake = _FakeScan(const ScanSupport(true, null));
    await _open(tester, fake);
    expect(find.text('Nimani skanerlaymiz?'), findsNothing);
    expect(fake.scans, 1);
    expect(find.text('home'), findsOneWidget);
  });

  testIos('choice shown when multiRoom is true: one room', (tester) async {
    final fake = _FakeScan(const ScanSupport(true, null, multiRoom: true));
    await _open(tester, fake);
    expect(find.text('Nimani skanerlaymiz?'), findsOneWidget);
    await tester.tap(find.text('Bitta xona'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(fake.scans, 1);
    expect(fake.flatLabels, isNull);
  });

  testIos('choice shown when multiRoom is true: several rooms', (tester) async {
    final fake = _FakeScan(const ScanSupport(true, null, multiRoom: true));
    await _open(tester, fake);
    await tester.tap(find.text('Bir nechta xona (kvartira)'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(fake.scans, 0);
    expect(fake.flatLabels, containsPair('nextRoom', 'Keyingi xona'));
    expect(fake.flatLabels, containsPair('finish', 'Tugatish'));
    expect(fake.flatLabels, containsPair('cancel', 'Bekor qilish'));
    expect(fake.flatLabels, containsPair('roomN', '{n}-xona'));
    expect(fake.flatLabels, containsPair('good', "Zo'r ketyapti — xonani shu tezlikda aylanib chiqing"));
  });
}
