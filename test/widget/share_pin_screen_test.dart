import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tamir_uy_mobile_flutter/l10n/app_localizations.dart';
import 'package:tamir_uy_mobile_flutter/models/api/api.dart';
import 'package:tamir_uy_mobile_flutter/providers/apartment_provider.dart';
import 'package:tamir_uy_mobile_flutter/screens/share/share_pin_screen.dart';

const _share = 'Check out this Pin! https://pin.it/AbCd12';

Apartment _flat(List<RoomOut> rooms) => Apartment(
      id: 'a1',
      userId: 'u1',
      name: 'Mening uyim',
      createdAt: DateTime(2026),
      rooms: rooms,
    );

RoomOut _room(String id, String name) => RoomOut(
      id: id,
      apartmentId: 'a1',
      name: name,
      floorArea: 14.4,
      updatedAt: DateTime(2026),
    );

/// The share screen under a router whose studio route records where it went.
Future<List<Uri>> _pump(
  WidgetTester tester, {
  required String text,
  List<Apartment> flats = const [],
}) async {
  final opened = <Uri>[];
  final router = GoRouter(
    initialLocation: '/share',
    routes: [
      GoRoute(
        path: '/share',
        builder: (_, _) => SharePinScreen(text: text),
      ),
      GoRoute(
        path: '/studio/:roomId',
        builder: (_, state) {
          opened.add(state.uri);
          return const Scaffold(body: Text('studio'));
        },
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [apartmentsProvider.overrideWith((ref) async => flats)],
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('uz'),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return opened;
}

void main() {
  testWidgets('text with no pin says so and offers no rooms', (tester) async {
    await _pump(tester, text: 'just some text https://example.com');
    expect(find.text('Bu Pinterest pin havolasi emas'), findsOneWidget);
    expect(find.text("Qaysi xonaga qo'llaymiz?"), findsNothing);
  });

  testWidgets('picking a room opens its studio with the pin', (tester) async {
    final opened = await _pump(
      tester,
      text: _share,
      flats: [_flat([_room('r1', 'Mehmonxona'), _room('r2', 'Yotoqxona')])],
    );
    expect(find.text("Qaysi xonaga qo'llaymiz?"), findsOneWidget);
    expect(find.text('https://pin.it/AbCd12'), findsOneWidget);

    await tester.tap(find.text('Yotoqxona'));
    await tester.pumpAndSettle();
    expect(find.text('studio'), findsOneWidget);
    expect(opened.single.path, '/studio/r2');
    expect(opened.single.queryParameters['ai_pin'], 'https://pin.it/AbCd12');
  });

  testWidgets('with no rooms yet it says to add one', (tester) async {
    await _pump(tester, text: _share, flats: [_flat(const [])]);
    expect(find.textContaining('Hali xona yo\'q'), findsOneWidget);
  });

  testWidgets('opened alone (a share at launch) it can be closed to home',
      (tester) async {
    await _pump(tester, text: _share, flats: [_flat(const [])]);
    expect(find.byTooltip('Yopish'), findsOneWidget);
  });
}
