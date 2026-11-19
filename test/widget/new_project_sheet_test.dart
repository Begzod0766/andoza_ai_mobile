import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tamir_uy_mobile_flutter/features/new_project/new_project_sheet_state.dart';
import 'package:tamir_uy_mobile_flutter/l10n/app_localizations.dart';
import 'package:tamir_uy_mobile_flutter/l10n/app_localizations_uz.dart';
import 'package:tamir_uy_mobile_flutter/providers/room_persistence_provider.dart';
import 'package:tamir_uy_mobile_flutter/screens/room_setup/new_project_sheet.dart';

final l10n = AppLocalizationsUz();

// flutter_test runs as Android by default; the LiDAR title is the iPhone one.
final _iOS = TargetPlatformVariant.only(TargetPlatform.iOS);

class _RecordingPersistence extends RoomPersistenceNotifier {
  _RecordingPersistence(super.ref, this.calls);
  final List<String> calls;
  @override
  void startNewProject() => calls.add('start');
  @override
  void continueCurrentProject() => calls.add('continue');
}

Future<(ProviderContainer, List<String>)> _pump(
  WidgetTester tester, {
  bool disableAnimations = true,
}) async {
  final calls = <String>[];
  final container = ProviderContainer(
    overrides: [
      roomPersistenceProvider.overrideWith(
        (ref) => _RecordingPersistence(ref, calls),
      ),
    ],
  );
  addTearDown(container.dispose);
  container.read(newProjectSheetOpenProvider.notifier).state = true;
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(body: NewProjectSheet()),
      ),
      for (final p in ['/wizard', '/scanning/roomplan', '/setup/draw'])
        GoRoute(path: p, builder: (_, _) => Text('ROUTE $p')),
    ],
  );
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('uz'),
        routerConfig: router,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(disableAnimations: disableAnimations),
          child: child!,
        ),
      ),
    ),
  );
  if (disableAnimations) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
  return (container, calls);
}

void main() {
  testWidgets('each card shows its title and a short caption', (tester) async {
    await _pump(tester);
    for (final (title, caption) in [
      (l10n.newProjectWizardTitle, l10n.newProjectWizardCaption),
      (l10n.newProjectLidarTitle, l10n.newProjectLidarCaption),
      (l10n.newProjectDrawTitle, l10n.newProjectDrawCaption),
    ]) {
      expect(find.text(title), findsOneWidget, reason: title);
      expect(find.text(caption), findsOneWidget, reason: caption);
      expect(
        caption.split(' ').length,
        inInclusiveRange(2, 5),
        reason: caption,
      );
    }
  }, variant: _iOS);

  testWidgets('a card reads as one button: title and caption', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pump(tester);
    expect(
      find.bySemanticsLabel(
        RegExp(
          '${RegExp.escape(l10n.newProjectDrawTitle)}.*'
          '${RegExp.escape(l10n.newProjectDrawCaption)}',
          dotAll: true,
        ),
      ),
      findsOneWidget,
    );
    semantics.dispose();
  });

  for (final (name, title, route, call) in [
    ('wizard', l10n.newProjectWizardTitle, '/wizard', 'start'),
    ('scan', l10n.newProjectLidarTitle, '/scanning/roomplan', 'continue'),
    ('draw', l10n.newProjectDrawTitle, '/setup/draw', 'start'),
  ]) {
    testWidgets('the $name card does $call and opens $route', (tester) async {
      final (container, calls) = await _pump(tester);
      await tester.ensureVisible(find.text(title));
      await tester.tap(find.text(title));
      await tester.pumpAndSettle();
      expect(calls, [call]);
      expect(find.text('ROUTE $route'), findsOneWidget);
      expect(container.read(newProjectSheetOpenProvider), isFalse);
    }, variant: _iOS);
  }

  testWidgets('with disableAnimations nothing keeps ticking', (tester) async {
    await _pump(tester);
    await tester.pumpAndSettle();
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('with animations on, the cards keep animating', (tester) async {
    await _pump(tester, disableAnimations: false);
    await tester.pump(const Duration(milliseconds: 1200));
    expect(tester.binding.hasScheduledFrame, isTrue);
    await tester.pump(const Duration(milliseconds: 1700));
    expect(tester.binding.hasScheduledFrame, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('on Android the scan card is the camera measure', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    try {
      await _pump(tester);
      expect(find.text(l10n.newProjectArScanTitle), findsOneWidget);
      expect(find.text(l10n.newProjectArScanCaption), findsOneWidget);
      expect(find.text(l10n.newProjectLidarTitle), findsNothing);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
