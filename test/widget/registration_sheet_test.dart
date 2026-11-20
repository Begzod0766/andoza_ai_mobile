import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tamir_uy_mobile_flutter/l10n/app_localizations.dart';
import 'package:tamir_uy_mobile_flutter/models/api/api.dart';
import 'package:tamir_uy_mobile_flutter/models/user_model.dart';
import 'package:tamir_uy_mobile_flutter/providers/ai_provider.dart';
import 'package:tamir_uy_mobile_flutter/providers/auth_provider.dart';
import 'package:tamir_uy_mobile_flutter/providers/business_provider.dart';
import 'package:tamir_uy_mobile_flutter/providers/masters_provider.dart';
import 'package:tamir_uy_mobile_flutter/repositories/ai_repository.dart';
import 'package:tamir_uy_mobile_flutter/repositories/auth_repository.dart';
import 'package:tamir_uy_mobile_flutter/repositories/business_repository.dart';
import 'package:tamir_uy_mobile_flutter/repositories/masters_repository.dart';
import 'package:tamir_uy_mobile_flutter/screens/masters/u5_booking_confirmation_screen.dart';
import 'package:tamir_uy_mobile_flutter/screens/studio/ai_builder_sheet.dart';
import 'package:tamir_uy_mobile_flutter/services/api_client.dart';
import 'package:tamir_uy_mobile_flutter/widgets/registration_required_sheet.dart';

class _NoRepo implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError();
}

class _Auth extends AuthNotifier {
  _Auth(AuthState s) : super(_NoRepo()) {
    state = s;
  }
  void set(AuthState s) => state = s;
}

const _guest = AuthAuthenticated(
  user: User(id: 'g1', isGuest: true),
  token: 'g',
);
const _registered = AuthAuthenticated(user: User(id: 'g1'), token: 'u');

class _FakeBusiness implements BusinessRepository {
  final sent = <String>[];

  @override
  Future<void> sendLead(
    String ustaId, {
    String? roomId,
    String? message,
    String? contactPhone,
  }) async {
    sent.add(ustaId);
  }

  @override
  dynamic noSuchMethod(Invocation i) =>
      throw UnimplementedError('${i.memberName}');
}

class _GateAi implements AiRepository {
  @override
  Stream<AiBuildEvent> build(String roomId, String prompt) =>
      Stream.error(ApiException(
        message: "Ro'yxatdan o'ting",
        statusCode: 403,
        code: 'registration_required',
        feature: 'ai_build',
      ));

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

const _master = MockMaster(
  master: Master(id: 'usta-1', name: 'Ali Valiyev'),
  trade: Trade.elektrik,
  areaName: '',
  experienceYears: 3,
  isOnline: true,
  isVerified: true,
);

/// An app whose `/signup` is a stub: "upgrade" flips the auth to registered
/// and pops true (like the real screen), "close" pops without signing in.
Future<_Auth> _pump(
  WidgetTester tester,
  Widget home, {
  AuthState auth = _guest,
  List<Override> overrides = const [],
}) async {
  final notifier = _Auth(auth);
  // [home] is pushed over a blank start, so a screen that pops on success
  // has somewhere to return to.
  final router = GoRouter(routes: [
    GoRoute(
      path: '/',
      builder: (context, _) => Scaffold(
        body: TextButton(
          onPressed: () => context.push('/home'),
          child: const Text('start'),
        ),
      ),
    ),
    GoRoute(path: '/home', builder: (_, _) => home),
    GoRoute(
      path: '/signup',
      builder: (context, _) => Scaffold(
        body: Column(children: [
          TextButton(
            onPressed: () {
              context.pop(true);
              notifier.set(_registered);
            },
            child: const Text('upgrade'),
          ),
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('close'),
          ),
        ]),
      ),
    ),
  ]);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      authStateProvider.overrideWith((ref) => notifier),
      ...overrides,
    ],
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('uz'),
    ),
  ));
  await tester.pumpAndSettle();
  await tester.tap(find.text('start'));
  await tester.pumpAndSettle();
  return notifier;
}

/// A button that runs the sheet for [feature] and shows what it returned.
class _Probe extends StatefulWidget {
  const _Probe(this.feature);
  final String feature;

  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  String result = '-';

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Column(children: [
          TextButton(
            onPressed: () async {
              final ok = await showRegistrationRequiredSheet(context,
                  feature: widget.feature);
              setState(() => result = '$ok');
            },
            child: const Text('gate'),
          ),
          Text('result: $result'),
        ]),
      );
}

void main() {
  late AppLocalizations l10n;
  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('uz'));
  });

  testWidgets('guest booking opens the sheet and sends no lead',
      (tester) async {
    final repo = _FakeBusiness();
    await _pump(
      tester,
      const U5BookingConfirmationScreen(master: _master),
      overrides: [businessRepositoryProvider.overrideWithValue(repo)],
    );
    await tester.enterText(find.byType(TextField).first, '+998 90 123-45-67');
    await tester.tap(find.text(l10n.mastersSend));
    await tester.pumpAndSettle();
    expect(find.text(l10n.guestSheetTitle), findsOneWidget);
    expect(find.text("Usta yoki do'kon bilan bog'lanish"), findsOneWidget);
    await tester.tap(find.text(l10n.guestSheetLater));
    await tester.pumpAndSettle();
    expect(repo.sent, isEmpty);
  });

  testWidgets('registered booking sends the lead', (tester) async {
    final repo = _FakeBusiness();
    await _pump(
      tester,
      const U5BookingConfirmationScreen(master: _master),
      auth: _registered,
      overrides: [businessRepositoryProvider.overrideWithValue(repo)],
    );
    await tester.enterText(find.byType(TextField).first, '+998 90 123-45-67');
    await tester.tap(find.text(l10n.mastersSend));
    await tester.pumpAndSettle();
    expect(find.text(l10n.guestSheetTitle), findsNothing);
    expect(repo.sent, ['usta-1']);
  });

  testWidgets('a guest who signs up from booking gets the lead sent',
      (tester) async {
    final repo = _FakeBusiness();
    await _pump(
      tester,
      const U5BookingConfirmationScreen(master: _master),
      overrides: [businessRepositoryProvider.overrideWithValue(repo)],
    );
    await tester.enterText(find.byType(TextField).first, '+998 90 123-45-67');
    await tester.tap(find.text(l10n.mastersSend));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.guestSheetSignUp));
    await tester.pumpAndSettle();
    await tester.tap(find.text('upgrade'));
    await tester.pumpAndSettle();
    expect(repo.sent, ['usta-1']);
  });

  testWidgets('Later returns false', (tester) async {
    await _pump(tester, const _Probe('render'));
    await tester.tap(find.text('gate'));
    await tester.pumpAndSettle();
    expect(find.text('Fotoreal render'), findsOneWidget);
    expect(find.text(l10n.guestSheetBody), findsOneWidget);
    await tester.tap(find.text(l10n.guestSheetLater));
    await tester.pumpAndSettle();
    expect(find.text('result: false'), findsOneWidget);
  });

  testWidgets('sign up returns true after upgrade', (tester) async {
    await _pump(tester, const _Probe('render'));
    await tester.tap(find.text('gate'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.guestSheetSignUp));
    await tester.pumpAndSettle();
    await tester.tap(find.text('upgrade'));
    await tester.pumpAndSettle();
    expect(find.text('result: true'), findsOneWidget);
  });

  testWidgets('closing sign-up returns false', (tester) async {
    await _pump(tester, const _Probe('render'));
    await tester.tap(find.text('gate'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.guestSheetSignUp));
    await tester.pumpAndSettle();
    await tester.tap(find.text('close'));
    await tester.pumpAndSettle();
    expect(find.text('result: false'), findsOneWidget);
  });

  testWidgets('ai builder 403 opens the sheet', (tester) async {
    // A registered session whose server still says "guest" (stale state):
    // the 403 itself opens the sheet.
    await _pump(
      tester,
      const Scaffold(body: AiBuilderSheet(roomId: 'r1')),
      auth: _registered,
      overrides: [aiRepositoryProvider.overrideWithValue(_GateAi())],
    );
    await tester.enterText(find.byType(TextField), 'divan');
    await tester.tap(find.byIcon(Icons.auto_awesome).last);
    await tester.pumpAndSettle();
    expect(find.text(l10n.guestSheetTitle), findsOneWidget);
    expect(find.text('AI quruvchi'), findsOneWidget);
  });

  testWidgets('a guest ai builder request is not sent', (tester) async {
    final ai = _CountingAi();
    await _pump(
      tester,
      const Scaffold(body: AiBuilderSheet(roomId: 'r1')),
      overrides: [aiRepositoryProvider.overrideWithValue(ai)],
    );
    await tester.enterText(find.byType(TextField), 'divan');
    await tester.tap(find.byIcon(Icons.auto_awesome).last);
    await tester.pumpAndSettle();
    expect(find.text('AI quruvchi'), findsOneWidget);
    await tester.tap(find.text(l10n.guestSheetLater));
    await tester.pumpAndSettle();
    expect(ai.calls, 0);
  });

  test('every feature key has a label', () {
    for (final f in [
      'ai_design',
      'ai_build',
      'smeta_ask',
      'render',
      'photo_model',
      'mebel_ai',
      'contact',
      'order',
      'workshop_link',
      'business',
      'market_prices',
    ]) {
      expect(guestFeatureLabel(l10n, f), isNot(l10n.guestSheetTitle),
          reason: f);
    }
    expect(guestFeatureLabel(l10n, 'something_new'), l10n.guestSheetTitle);
  });
}

class _CountingAi implements AiRepository {
  int calls = 0;

  @override
  Stream<AiBuildEvent> build(String roomId, String prompt) {
    calls++;
    return const Stream.empty();
  }

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}
