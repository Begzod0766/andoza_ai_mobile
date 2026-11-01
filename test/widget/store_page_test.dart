import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tamir_uy_mobile_flutter/l10n/app_localizations.dart';
import 'package:tamir_uy_mobile_flutter/models/api/api.dart';
import 'package:tamir_uy_mobile_flutter/models/shop_model.dart';
import 'package:tamir_uy_mobile_flutter/providers/apartment_provider.dart';
import 'package:tamir_uy_mobile_flutter/providers/cart_provider.dart';
import 'package:tamir_uy_mobile_flutter/providers/catalog_provider.dart';
import 'package:tamir_uy_mobile_flutter/providers/shop_provider.dart';
import 'package:tamir_uy_mobile_flutter/screens/shop/furniture_detail_screen.dart';
import 'package:tamir_uy_mobile_flutter/screens/shop/s1_shop_home_screen.dart';
import 'package:tamir_uy_mobile_flutter/screens/shop/store_page_screen.dart';

/// The queries sent to the furniture search, in order.
final searches = <String>[];

const _store = Store(
  id: 's1',
  name: 'Mebel Plus',
  district: 'Chilonzor',
  phone: '+998 90 123 45 67',
  telegram: '@mebelplus',
  logoColor: '#123456',
  partnerTier: 'gold',
);

const _sofa = Furniture(
  id: 'f1',
  storeId: 's1',
  storeName: 'Mebel Plus',
  category: 'divan',
  nameUz: 'Burchak divan',
  priceUzs: 4500000,
  glbUrl: 'https://andozaai.uz/media/sofa.glb',
  footprintW: 220,
  footprintD: 90,
  heightCm: 80,
);

const _photoOnly = Furniture(
  id: 'f2',
  storeId: 's1',
  storeName: 'Mebel Plus',
  category: 'stol',
  nameUz: 'Jurnal stoli',
);

const _paint = Product(
  id: 'm1',
  name: "Oq bo'yoq",
  brand: 'Mebel Plus',
  category: ShopCategory.boyoq,
  pricePerUnit: 85000,
  unit: 'litr',
  isOfficialDealer: true,
  storeId: 's1',
);

const _otherShopsPaint = Product(
  id: 'm2',
  name: "Ko'k bo'yoq",
  brand: 'Boshqa',
  category: ShopCategory.boyoq,
  pricePerUnit: 90000,
  unit: 'litr',
  isOfficialDealer: false,
  storeId: 's2',
);

Apartment _flat(List<RoomOut> rooms) => Apartment(
  id: 'a1',
  userId: 'u1',
  name: 'Mening uyim',
  createdAt: DateTime(2026),
  rooms: rooms,
);

RoomOut _room(String id, String name) =>
    RoomOut(id: id, apartmentId: 'a1', name: name, updatedAt: DateTime(2026));

/// [initial] under a router whose other screens record where they were sent.
Future<List<Uri>> _pump(
  WidgetTester tester,
  String initial, {
  List<Furniture> storeFurniture = const [_sofa, _photoOnly],
  List<Furniture> allFurniture = const [_sofa],
  List<Product> materials = const [_paint, _otherShopsPaint],
  List<Apartment> flats = const [],
  Object? storeError,
}) async {
  // A phone-sized screen, so a page's lower rows are laid out.
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  final opened = <Uri>[];
  Widget record(GoRouterState state) {
    opened.add(state.uri);
    return Scaffold(body: Text('opened ${state.uri}'));
  }

  final router = GoRouter(
    initialLocation: initial,
    routes: [
      GoRoute(path: '/shop/s1', builder: (_, _) => const S1ShopHomeScreen()),
      GoRoute(
        path: '/shop/store/:storeId',
        builder: (_, state) =>
            StorePageScreen(storeId: state.pathParameters['storeId']!),
      ),
      GoRoute(
        path: '/shop/furniture/:id',
        builder: (_, state) => FurnitureDetailScreen(
          id: state.pathParameters['id']!,
          initial: state.extra as Furniture?,
        ),
      ),
      GoRoute(path: '/shop/s3', builder: (_, state) => record(state)),
      GoRoute(path: '/studio/:roomId', builder: (_, state) => record(state)),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        storeProvider.overrideWith((ref, id) async {
          if (storeError != null) throw storeError;
          return _store;
        }),
        storeFurnitureProvider.overrideWith((ref, id) async => storeFurniture),
        furnitureProvider.overrideWith((ref, category) async => allFurniture),
        // The server's `q`: a name search over the whole catalog.
        furnitureSearchProvider.overrideWith((ref, query) async {
          searches.add(query);
          return allFurniture.where((f) => f.nameUz.toLowerCase().contains(query.toLowerCase())).toList();
        }),
        shopSearchProvider.overrideWith(
          (ref, query) => AsyncValue.data(
            materials.where((p) => p.name.toLowerCase().contains(query.toLowerCase())).toList(),
          ),
        ),
        furnitureItemProvider.overrideWith(
          (ref, id) async => storeFurniture.firstWhere((f) => f.id == id),
        ),
        shopCatalogProvider.overrideWithValue(materials),
        shopCatalogLoadingProvider.overrideWithValue(false),
        shopCatalogErrorProvider.overrideWithValue(null),
        cartLineCountProvider.overrideWithValue(0),
        apartmentsProvider.overrideWith((ref) async => flats),
      ],
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
  group('store page', () {
    testWidgets('shows the shop, its contacts and only its own products', (
      tester,
    ) async {
      await _pump(tester, '/shop/store/s1');
      expect(find.text('Mebel Plus'), findsWidgets);
      expect(find.text('Chilonzor'), findsOneWidget);
      expect(find.text('✓ Rasmiy diler'), findsOneWidget);
      expect(find.text("Qo'ng'iroq"), findsOneWidget);
      expect(find.text('Telegram'), findsOneWidget);

      expect(find.text('Mebel'), findsOneWidget);
      expect(find.text('Burchak divan'), findsOneWidget);
      expect(find.text('Jurnal stoli'), findsOneWidget);
      expect(find.text('Narxi kelishiladi'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text("Oq bo'yoq"),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text("Oq bo'yoq"), findsOneWidget);
      expect(find.text("Ko'k bo'yoq"), findsNothing);
    });

    testWidgets('a shop with nothing for sale says so', (tester) async {
      await _pump(
        tester,
        '/shop/store/s1',
        storeFurniture: const [],
        materials: const [_otherShopsPaint],
      );
      expect(find.text("Bu do'konda hozircha mahsulot yo'q"), findsOneWidget);
    });

    testWidgets('a closed shop shows the error with a retry', (tester) async {
      await _pump(tester, '/shop/store/s1', storeError: Exception('404'));
      expect(find.text("Do'konni ochib bo'lmadi"), findsOneWidget);
      expect(find.text('Mebel'), findsNothing);
    });

    testWidgets('a material opens the usual product page', (tester) async {
      final opened = await _pump(tester, '/shop/store/s1');
      await tester.scrollUntilVisible(
        find.text("Oq bo'yoq"),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text("Oq bo'yoq"));
      await tester.pumpAndSettle();
      expect(opened.single.path, '/shop/s3');
    });

    testWidgets('the menu offers to report the shop', (tester) async {
      await _pump(tester, '/shop/store/s1');
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      expect(find.text("Do'kon haqida shikoyat"), findsOneWidget);
    });
  });

  group('furniture page', () {
    testWidgets('shows price, size and the shop; opens the shop', (
      tester,
    ) async {
      await _pump(tester, '/shop/store/s1');
      await tester.tap(find.text('Burchak divan'));
      await tester.pumpAndSettle();

      expect(find.text("4 500 000 so'm"), findsOneWidget);
      expect(find.text('220 × 90 × 80 sm'), findsOneWidget);
      expect(find.text("Xonamga qo'yish"), findsOneWidget);

      await tester.tap(find.text("Mebel Plus do'koni"));
      await tester.pumpAndSettle();
      expect(find.text('Chilonzor'), findsOneWidget);
    });

    testWidgets('places the model in the picked room', (tester) async {
      final opened = await _pump(
        tester,
        '/shop/furniture/f1',
        flats: [
          _flat([_room('r1', 'Mehmonxona'), _room('r2', 'Yotoqxona')]),
        ],
      );
      await tester.tap(find.text("Xonamga qo'yish"));
      await tester.pumpAndSettle();
      expect(find.text('Qaysi xonaga qo\'yamiz?'), findsOneWidget);

      await tester.tap(find.text('Yotoqxona'));
      await tester.pumpAndSettle();
      expect(opened.single.path, '/studio/r2');
      expect(opened.single.queryParameters, {'place': 'f1'});
    });

    testWidgets('without rooms it says to make one first', (tester) async {
      final opened = await _pump(tester, '/shop/furniture/f1');
      await tester.tap(find.text("Xonamga qo'yish"));
      await tester.pumpAndSettle();
      expect(find.text('Avval xona yarating yoki skanerlang'), findsOneWidget);
      expect(opened, isEmpty);
    });

    testWidgets('a photo-only listing cannot be placed', (tester) async {
      await _pump(tester, '/shop/furniture/f2');
      expect(find.text("Xonamga qo'yish"), findsNothing);
      expect(
        find.text(
          "Bu mahsulotning 3D modeli yo'q, uni xonaga qo'yib bo'lmaydi",
        ),
        findsOneWidget,
      );
      // No footprint known: no size row.
      expect(find.text("O'lchami"), findsNothing);
    });
  });

  group('shop home', () {
    testWidgets("lists the shops' furniture above the materials", (
      tester,
    ) async {
      await _pump(tester, '/shop/s1');
      expect(find.text('Mebel'), findsOneWidget);
      expect(find.text('Burchak divan'), findsOneWidget);
      expect(find.text('Materiallar'), findsOneWidget);

      await tester.tap(find.text('Burchak divan'));
      await tester.pumpAndSettle();
      expect(find.text("Xonamga qo'yish"), findsOneWidget);
    });

    testWidgets('the search asks the server once typing pauses', (tester) async {
      searches.clear();
      await _pump(tester, '/shop/s1');
      await tester.enterText(find.byType(TextField), 'st');
      await tester.enterText(find.byType(TextField), ' stol ');
      await tester.pump(const Duration(milliseconds: 400)); // the debounce
      await tester.pumpAndSettle();
      expect(searches, ['stol']);
      expect(find.text('Burchak divan'), findsNothing);
      expect(find.text('Mebel'), findsNothing);
    });

    testWidgets('no furniture, no section', (tester) async {
      await _pump(tester, '/shop/s1', allFurniture: const []);
      expect(find.text('Mebel'), findsNothing);
    });
  });
}
