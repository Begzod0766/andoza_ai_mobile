import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tamir_uy_mobile_flutter/l10n/app_localizations.dart';
import 'package:tamir_uy_mobile_flutter/models/api/api.dart';
import 'package:tamir_uy_mobile_flutter/providers/apartment_provider.dart';
import 'package:tamir_uy_mobile_flutter/providers/masters_provider.dart';
import 'package:tamir_uy_mobile_flutter/repositories/masters_repository.dart';
import 'package:tamir_uy_mobile_flutter/screens/masters/u4_review_rating_screen.dart';
import 'package:tamir_uy_mobile_flutter/screens/profile/e5_projects_screen.dart';
import 'package:tamir_uy_mobile_flutter/widgets/common/load_status.dart';

import '../support/localized_pump.dart';

/// A list that is still loading, or failed to load, must not read as "empty",
/// and screens opened without their data must not crash or show someone else's.
Apartment _apartment() => Apartment(
      id: 'apt-1',
      userId: 'u',
      name: 'Mening uyim',
      address: 'Chilonzor',
      createdAt: DateTime(2026, 1, 1),
      renovationStage: 1,
      rooms: [
        RoomOut(
          id: 'room-1',
          apartmentId: 'apt-1',
          name: 'Xona',
          updatedAt: DateTime(2026, 1, 1),
        ),
      ],
    );

Widget _projects(Override apartments) {
  final router = GoRouter(routes: [
    GoRoute(path: '/', builder: (_, _) => const E5ProjectsScreen()),
    GoRoute(
      path: '/studio/:id',
      builder: (_, s) => Text('studio ${s.pathParameters['id']}'),
    ),
  ]);
  return ProviderScope(
    overrides: [apartments],
    child: MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('uz'),
      routerConfig: router,
    ),
  );
}

void main() {
  final l10n = lookupAppLocalizations(const Locale('uz'));

  group('loadStatus', () {
    void retry() {}
    test('nothing to say once there is data', () {
      expect(loadStatus(isEmpty: false, loading: true, error: 'x', onRetry: retry), isNull);
    });
    test('spinner while loading, error with retry on failure', () {
      expect(loadStatus(isEmpty: true, loading: true, error: null, onRetry: retry), isNotNull);
      expect(loadStatus(isEmpty: true, loading: false, error: 'boom', onRetry: retry), isNotNull);
    });
    test('a successful empty result is left to the caller', () {
      expect(loadStatus(isEmpty: true, loading: false, error: null, onRetry: retry), isNull);
    });
  });

  testWidgets('Projects: loading is not "you have no projects"', (tester) async {
    final pending = Completer<List<Apartment>>();
    await tester.pumpWidget(_projects(apartmentsProvider.overrideWith((ref) => pending.future)));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text(l10n.profileProjectsEmptyTitle), findsNothing);
  });

  testWidgets('Projects: a failed load offers a retry, not the empty state', (tester) async {
    await tester.pumpWidget(_projects(apartmentsProvider.overrideWith((ref) async => throw Exception('offline'))));
    await tester.pumpAndSettle();
    expect(find.text(l10n.actionRetry), findsOneWidget);
    expect(find.text(l10n.profileProjectsEmptyTitle), findsNothing);
  });

  testWidgets('Projects: a card opens its own room in the Studio', (tester) async {
    await tester.pumpWidget(_projects(apartmentsProvider.overrideWith((ref) async => [_apartment()])));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mening uyim'));
    await tester.pumpAndSettle();
    expect(find.text('studio room-1'), findsOneWidget);
  });

  testWidgets('U4 opened without a craftsman says so instead of crashing', (tester) async {
    await pumpLocalized(tester, const U4ReviewRatingScreen());
    await tester.pumpAndSettle();
    expect(find.text(l10n.mastersNotFound), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('a blank craftsman name gives a "?" avatar, not a crash', () {
    const m = MockMaster(
      master: Master(id: '1', name: '  '),
      trade: Trade.elektrik,
      areaName: '',
      experienceYears: 1,
      isOnline: true,
      isVerified: false,
    );
    expect(m.initial, '?');
  });

  testWidgets('projects pull to refresh, empty or not', (tester) async {
    var calls = 0;
    await tester.pumpWidget(_projects(apartmentsProvider.overrideWith((ref) async {
      calls++;
      return [_apartment()];
    })));
    await tester.pumpAndSettle();
    expect(find.byType(RefreshIndicator), findsOneWidget);
    await tester.fling(find.byType(Scrollable).last, const Offset(0, 400), 1000);
    await tester.pumpAndSettle();
    expect(calls, 2);

    await tester.pumpWidget(_projects(apartmentsProvider.overrideWith((ref) async => const [])));
    await tester.pumpAndSettle();
    expect(find.byType(RefreshIndicator), findsOneWidget);
  });
}
