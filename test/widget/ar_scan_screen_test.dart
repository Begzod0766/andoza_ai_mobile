import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tamir_uy_mobile_flutter/features/ar_scan/ar_scan_guide_prefs.dart';
import 'package:tamir_uy_mobile_flutter/features/ar_scan/ar_scan_service.dart';
import 'package:tamir_uy_mobile_flutter/features/ar_scan/arcore_plan.dart';
import 'package:tamir_uy_mobile_flutter/l10n/app_localizations.dart';
import 'package:tamir_uy_mobile_flutter/models/room_plan.dart';
import 'package:tamir_uy_mobile_flutter/screens/room_setup/new_project_sheet.dart';
import 'package:tamir_uy_mobile_flutter/screens/scanning/ar_scan_screen.dart';
import 'package:tamir_uy_mobile_flutter/screens/scanning/room_scan_review_page.dart';

import '../support/localized_pump.dart';

class _FakeArScan implements ArScanService {
  _FakeArScan({this.support = const ArScanSupport(true, 'ok'), this.raw, this.error});
  ArScanSupport support;
  int checks = 0;
  final Map<String, dynamic>? raw;
  final ArScanException? error;
  Map<String, String>? lastStrings;

  @override
  Future<ArScanSupport> checkSupport() async {
    checks++;
    return support;
  }

  @override
  Future<void> openAppSettings() async {}

  @override
  Future<ArScanRaw?> scanFloorPlan(Map<String, String> strings) async {
    lastStrings = strings;
    if (error != null) throw error!;
    return raw == null ? null : ArScanRaw.fromMap(raw!);
  }
}

class _FakeGuide implements ArScanGuidePrefs {
  _FakeGuide({this.isSeen = true, this.fails = false});
  bool isSeen;
  final bool fails;
  int marks = 0;

  @override
  Future<bool> seen() async {
    if (fails) throw Exception('prefs unavailable');
    return isSeen;
  }

  @override
  Future<void> markSeen() async {
    marks++;
    isSeen = true;
  }
}

Map<String, dynamic> _scan(List<List<double>> corners) => {
      'corners': corners,
      'height': 2.7,
      'heightMeasured': true,
      'closed': false,
      'trackingLossCount': 0,
      'durationSec': 60,
    };

Future<void> _pump(WidgetTester tester, _FakeArScan fake, {ArScanGuidePrefs? guide}) async {
  final router = GoRouter(initialLocation: '/home', routes: [
    GoRoute(path: '/home', builder: (_, _) => const Text('home')),
    GoRoute(path: '/scan', builder: (_, _) => const ArScanScreen()),
    GoRoute(
      path: '/scanning/roomplan/review',
      builder: (_, s) => Text('review ${(s.extra! as RoomScanReviewArgs).draft.plan.source.name}'),
    ),
    GoRoute(path: '/setup/draw', builder: (_, _) => const Text('draw')),
  ]);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      arScanServiceProvider.overrideWithValue(fake),
      arScanGuidePrefsProvider.overrideWithValue(guide ?? _FakeGuide()),
    ],
    child: MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('uz'),
      routerConfig: router,
    ),
  ));
  router.push('/scan');
  await tester.pumpAndSettle();
}

void main() {
  final l10n = lookupAppLocalizations(const Locale('uz'));

  testWidgets('first run shows the guide, Boshlash starts the scan', (tester) async {
    final fake = _FakeArScan();
    final guide = _FakeGuide(isSeen: false);
    await _pump(tester, fake, guide: guide);
    expect(find.text(l10n.arScanGuideTitle), findsOneWidget);
    expect(find.text(l10n.arScanGuideClose), findsOneWidget);
    expect(fake.checks, 0);
    await tester.tap(find.text(l10n.arScanGuideStart));
    await tester.pumpAndSettle();
    expect(guide.marks, 1);
    expect(fake.checks, 1);
  });

  testWidgets('a seen guide goes straight to the scan', (tester) async {
    final fake = _FakeArScan();
    await _pump(tester, fake);
    expect(fake.checks, 1);
    expect(find.text(l10n.arScanGuideTitle), findsNothing);
  });

  testWidgets('help reopens the guide', (tester) async {
    final fake = _FakeArScan(raw: _scan([[0, 0], [4, 3], [4, 0], [0, 3]]));
    await _pump(tester, fake);
    expect(find.text(l10n.arScanRejected_self_intersecting), findsOneWidget);
    await tester.tap(find.byTooltip(l10n.arScanGuideHelp));
    await tester.pumpAndSettle();
    expect(find.text(l10n.arScanGuideTitle), findsOneWidget);
    await tester.tap(find.text(l10n.arScanGuideStart));
    await tester.pumpAndSettle();
    expect(fake.checks, 2);
  });

  testWidgets('a scan started from the resume check closes the guide', (tester) async {
    final fake = _FakeArScan(support: const ArScanSupport(false, 'arcore_not_installed'));
    await _pump(tester, fake);
    await tester.tap(find.byTooltip(l10n.arScanGuideHelp));
    await tester.pumpAndSettle();
    expect(find.text(l10n.arScanGuideTitle), findsOneWidget);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(fake.checks, 2);
    expect(find.text(l10n.arScanGuideTitle), findsNothing);
  });

  testWidgets('a prefs failure never blocks the scan', (tester) async {
    final fake = _FakeArScan();
    await _pump(tester, fake, guide: _FakeGuide(fails: true));
    expect(fake.checks, 1);
  });

  testWidgets('passes the scanner its flow copy', (tester) async {
    final fake = _FakeArScan(raw: _scan([[0, 0], [4, 0], [4, 3], [0, 3]]));
    await _pump(tester, fake);
    final s = fake.lastStrings!;
    for (final e in {
      'arScanBaseHint': l10n.arScanBaseHint, 'arScanStart': l10n.arScanStart,
      'arScanCloseRoom': l10n.arScanCloseRoom, 'arScanCreatePlan': l10n.arScanCreatePlan,
      'arScanDoneHint': l10n.arScanDoneHint, 'arScanPerimeter': l10n.arScanPerimeter,
      'arScanArea': l10n.arScanArea, 'arScanVolume': l10n.arScanVolume,
      'arScanUnitCm': l10n.arScanUnitCm, 'arScanUnitM': l10n.arScanUnitM,
      'arScanNoFloorHere': l10n.arScanNoFloorHere, 'arScanKeepMeasuring': l10n.arScanKeepMeasuring,
    }.entries) {
      expect(s[e.key], e.value, reason: e.key);
    }
  });

  testWidgets('passes the scanner its tracking-trouble copy', (tester) async {
    final fake = _FakeArScan(raw: _scan([[0, 0], [4, 0], [4, 3], [0, 3]]));
    await _pump(tester, fake);
    final s = fake.lastStrings!;
    for (final e in {
      'arScanLostMotion': l10n.arScanLostMotion, 'arScanLostLight': l10n.arScanLostLight,
      'arScanLostFeatures': l10n.arScanLostFeatures, 'arScanTrackingSettling': l10n.arScanTrackingSettling,
    }.entries) {
      expect(s[e.key], e.value, reason: e.key);
    }
  });

  testWidgets('passes the scanner its guidance copy', (tester) async {
    final fake = _FakeArScan(raw: _scan([[0, 0], [4, 0], [4, 3], [0, 3]]));
    await _pump(tester, fake);
    final s = fake.lastStrings!;
    for (final e in {
      'arScanStepFloor': l10n.arScanStepFloor, 'arScanStepBase': l10n.arScanStepBase,
      'arScanStepHeight': l10n.arScanStepHeight, 'arScanStepWalls': l10n.arScanStepWalls,
      'arScanStepOpenings': l10n.arScanStepOpenings, 'arScanStepCloser': l10n.arScanStepCloser,
      'arScanFirstCorner': l10n.arScanFirstCorner,
    }.entries) {
      expect(s[e.key], e.value, reason: e.key);
    }
  });

  testWidgets('passes the scanner its doors-and-windows copy', (tester) async {
    final fake = _FakeArScan(raw: _scan([[0, 0], [4, 0], [4, 3], [0, 3]]));
    await _pump(tester, fake);
    final s = fake.lastStrings!;
    for (final e in {
      'arScanAddOpenings': l10n.arScanAddOpenings, 'arScanOpeningsDone': l10n.arScanOpeningsDone,
      'arScanOpeningsHint': l10n.arScanOpeningsHint, 'arScanAddEdge': l10n.arScanAddEdge,
      'arScanDoor': l10n.arScanDoor, 'arScanWindow': l10n.arScanWindow,
      'arScanOpeningOtherWall': l10n.arScanOpeningOtherWall,
      'arScanOpeningTooNarrow': l10n.arScanOpeningTooNarrow,
      'arScanOpeningOverlap': l10n.arScanOpeningOverlap, 'arScanAimWallBase': l10n.arScanAimWallBase,
    }.entries) {
      expect(s[e.key], e.value, reason: e.key);
      expect(e.value, isNotEmpty, reason: e.key);
    }
  });

  testWidgets('ok scan opens the review with an arcore plan', (tester) async {
    final fake = _FakeArScan(raw: _scan([[0, 0], [4, 0], [4, 3], [0, 3]]));
    await _pump(tester, fake);
    expect(find.text('review arcore'), findsOneWidget);
    expect(fake.lastStrings?['arScanAddCorner'], l10n.arScanAddCorner);
  });

  testWidgets('cancelled scan goes back', (tester) async {
    await _pump(tester, _FakeArScan());
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('rejected outline explains why and offers rescan or draw', (tester) async {
    await _pump(tester, _FakeArScan(raw: _scan([[0, 0], [4, 3], [4, 0], [0, 3]])));
    expect(find.text(l10n.arScanRejected_self_intersecting), findsOneWidget);
    expect(find.text(l10n.arScanRescan), findsOneWidget);
    await tester.tap(find.text(l10n.newProjectDrawTitle));
    await tester.pumpAndSettle();
    expect(find.text('draw'), findsOneWidget);
  });

  testWidgets('missing ARCore offers the install link', (tester) async {
    await _pump(tester, _FakeArScan(support: const ArScanSupport(false, 'arcore_not_installed')));
    expect(find.text(l10n.arScanNotInstalled), findsOneWidget);
    expect(find.text(l10n.arScanInstall), findsOneWidget);
  });

  testWidgets('unsupported device offers draw', (tester) async {
    await _pump(tester, _FakeArScan(support: const ArScanSupport(false, 'unsupported_device')));
    expect(find.text(l10n.newProjectDrawTitle), findsOneWidget);
  });

  testWidgets('camera permission refused explains and offers settings', (tester) async {
    await _pump(tester, _FakeArScan(error: const ArScanException('camera_denied', 'no')));
    expect(find.text(l10n.arScanCameraDenied), findsOneWidget);
    expect(find.text(l10n.arScanOpenSettings), findsOneWidget);
  });

  testWidgets('Android sheet shows the camera-measure entry', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    try {
      await pumpLocalized(tester, const Scaffold(body: NewProjectSheet()));
      await tester.pumpAndSettle();
      expect(find.text(l10n.newProjectArScanTitle), findsOneWidget);
      expect(find.text(l10n.newProjectLidarTitle), findsNothing);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  test('every rejection reason has copy', () {
    for (final r in ['too_few_corners', 'self_intersecting', 'wall_too_long']) {
      expect(arScanRejectionText(l10n, r), isNot(r));
    }
    expect(RoomSource.values, contains(RoomSource.arcore));
  });

  testWidgets('an inconclusive ARCore check can be retried, not "unsupported"', (tester) async {
    await _pump(tester, _FakeArScan(support: const ArScanSupport(false, 'check_failed')));
    expect(find.text(l10n.arScanUnsupported), findsNothing);
    expect(find.text(l10n.arScanRescan), findsOneWidget);
  });

  testWidgets('coming back from installing ARCore checks again by itself', (tester) async {
    final fake = _FakeArScan(support: const ArScanSupport(false, 'arcore_not_installed'));
    await _pump(tester, fake);
    expect(fake.checks, 1);
    fake.support = const ArScanSupport(false, 'arcore_not_installed');
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(fake.checks, 2);
  });
}
