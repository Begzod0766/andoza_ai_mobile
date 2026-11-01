import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tamir_uy_mobile_flutter/l10n/app_localizations.dart';
import 'package:tamir_uy_mobile_flutter/models/business_profile.dart';
import 'package:tamir_uy_mobile_flutter/providers/business_provider.dart';
import 'package:tamir_uy_mobile_flutter/repositories/business_repository.dart';
import 'package:tamir_uy_mobile_flutter/screens/business/business_apply_screen.dart';
import 'package:tamir_uy_mobile_flutter/services/api_client.dart';

class _FakeRepo implements BusinessRepository {
  Map<String, Object?>? usta;
  Map<String, Object?>? shop;
  Object? failWith;

  @override
  Future<UstaProfile> applyUsta({
    required String name,
    required UstaTrade trade,
    required String phone,
    String? district,
    String? telegram,
    int? priceMin,
    int? priceMax,
  }) async {
    if (failWith != null) throw failWith!;
    usta = {'name': name, 'trade': trade, 'phone': phone, 'priceMin': priceMin, 'priceMax': priceMax};
    return UstaProfile(id: 'u', name: name, status: ModerationStatus.pending);
  }

  @override
  Future<ShopProfile> applyShop({required String name, String? district, String? phone, String? telegram}) async {
    shop = {'name': name, 'phone': phone};
    return ShopProfile(id: 's', name: name, status: ModerationStatus.pending);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}

Widget _app(BusinessKind kind, _FakeRepo repo) {
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => BusinessApplyScreen(kind: kind)),
      GoRoute(path: '/business', builder: (_, _) => const Scaffold(body: Text('biznes sahifasi'))),
    ],
  );
  return ProviderScope(
    overrides: [businessRepositoryProvider.overrideWithValue(repo)],
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('uz'),
    ),
  );
}

/// The form is taller than the default 800×600 test surface, which would leave
/// the submit button off-screen and untappable.
void _tall(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('an usta application needs a name and a full phone before anything is sent', (tester) async {
    _tall(tester);
    final repo = _FakeRepo();
    await tester.pumpWidget(_app(BusinessKind.usta, repo));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Arizani yuborish'));
    await tester.pumpAndSettle();
    expect(find.text('Nomni kiriting'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Ismingiz yoki jamoa nomi'), 'Aziz usta');
    await tester.tap(find.text('Arizani yuborish'));
    await tester.pumpAndSettle();
    expect(find.textContaining("Telefon raqami noto'g'ri"), findsOneWidget);
    expect(repo.usta, isNull);
  });

  testWidgets('a good usta application is sent with its trade and goes to the business page', (tester) async {
    _tall(tester);
    final repo = _FakeRepo();
    await tester.pumpWidget(_app(BusinessKind.usta, repo));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Ismingiz yoki jamoa nomi'), 'Aziz usta');
    await tester.enterText(find.widgetWithText(TextField, 'Telefon (+998...)'), '+998901234567');
    await tester.tap(find.text('Arizani yuborish'));
    await tester.pumpAndSettle();

    expect(repo.usta, {
      'name': 'Aziz usta',
      'trade': UstaTrade.elektrik,
      'phone': '+998901234567',
      'priceMin': null,
      'priceMax': null,
    });
    expect(find.text('biznes sahifasi'), findsOneWidget);
  });

  testWidgets('an inverted price range is refused before sending', (tester) async {
    _tall(tester);
    final repo = _FakeRepo();
    await tester.pumpWidget(_app(BusinessKind.usta, repo));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Ismingiz yoki jamoa nomi'), 'Aziz usta');
    await tester.enterText(find.widgetWithText(TextField, 'Telefon (+998...)'), '+998901234567');
    await tester.enterText(find.widgetWithText(TextField, 'Dan'), '500000');
    await tester.enterText(find.widgetWithText(TextField, 'Gacha'), '100000');
    await tester.tap(find.text('Arizani yuborish'));
    await tester.pumpAndSettle();

    expect(find.text("Maksimal narx minimaldan kam bo'lmasin"), findsOneWidget);
    expect(repo.usta, isNull);
  });

  testWidgets('a 409 says the application already exists and stays on the form', (tester) async {
    _tall(tester);
    final repo = _FakeRepo()..failWith = ApiException(message: 'conflict', statusCode: 409);
    await tester.pumpWidget(_app(BusinessKind.usta, repo));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Ismingiz yoki jamoa nomi'), 'Aziz usta');
    await tester.enterText(find.widgetWithText(TextField, 'Telefon (+998...)'), '+998901234567');
    await tester.tap(find.text('Arizani yuborish'));
    await tester.pumpAndSettle();

    expect(find.text('Sizda allaqachon bunday ariza bor'), findsOneWidget);
    expect(find.text('biznes sahifasi'), findsNothing);
  });

  testWidgets('a shop application asks only for the shop name and sends it', (tester) async {
    _tall(tester);
    final repo = _FakeRepo();
    await tester.pumpWidget(_app(BusinessKind.shop, repo));
    await tester.pumpAndSettle();

    expect(find.text('Kasbingiz'), findsNothing); // the trade picker is usta-only
    await tester.enterText(find.widgetWithText(TextField, "Do'kon nomi"), 'Mebel Plus');
    await tester.tap(find.text('Arizani yuborish'));
    await tester.pumpAndSettle();

    expect(repo.shop?['name'], 'Mebel Plus');
    expect(repo.shop?['phone'], isNull); // the bare "+998" prefix is no number
    expect(find.text('biznes sahifasi'), findsOneWidget);
  });

  testWidgets('a shop phone is optional, but a wrong one is refused, not dropped', (tester) async {
    _tall(tester);
    final repo = _FakeRepo();
    await tester.pumpWidget(_app(BusinessKind.shop, repo));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, "Do'kon nomi"), 'Mebel Plus');
    final phone = find.widgetWithText(TextField, 'Telefon (+998...)');
    await tester.enterText(phone, 'abc');
    await tester.tap(find.text('Arizani yuborish'));
    await tester.pumpAndSettle();
    expect(find.textContaining("Telefon raqami noto'g'ri"), findsOneWidget);
    expect(repo.shop, isNull);

    await tester.enterText(phone, '+998 90 123-45-67');
    await tester.tap(find.text('Arizani yuborish'));
    await tester.pumpAndSettle();
    expect(repo.shop?['phone'], '+998901234567');
  });

  testWidgets('an error goes away as soon as a field is edited', (tester) async {
    _tall(tester);
    final repo = _FakeRepo();
    await tester.pumpWidget(_app(BusinessKind.usta, repo));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Ismingiz yoki jamoa nomi'), 'Aziz usta');
    await tester.tap(find.text('Arizani yuborish'));
    await tester.pumpAndSettle();
    expect(find.textContaining("Telefon raqami noto'g'ri"), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Telefon (+998...)'), '+998901234567');
    await tester.pump();
    expect(find.textContaining("Telefon raqami noto'g'ri"), findsNothing);
  });

  testWidgets('a price longer than 12 digits cannot be typed', (tester) async {
    _tall(tester);
    await tester.pumpWidget(_app(BusinessKind.usta, _FakeRepo()));
    await tester.pumpAndSettle();

    final max = find.widgetWithText(TextField, 'Gacha');
    await tester.enterText(max, '1' * 20);
    await tester.pump();
    expect(tester.widget<TextField>(max).controller!.text, '1' * 12);
  });
}
