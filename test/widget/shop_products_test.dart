import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/l10n/app_localizations.dart';
import 'package:tamir_uy_mobile_flutter/models/business_profile.dart';
import 'package:tamir_uy_mobile_flutter/providers/business_provider.dart';
import 'package:tamir_uy_mobile_flutter/repositories/business_repository.dart';
import 'package:tamir_uy_mobile_flutter/screens/business/shop_products_screen.dart';

class _FakeRepo implements BusinessRepository {
  final calls = <String>[];
  List<ShopProduct> items = const [
    ShopProduct(
        id: 'a', name: 'Divan Milano', category: 'divan', priceUzs: 4500000,
        status: ModerationStatus.approved, isActive: true),
    ShopProduct(
        id: 'b', name: 'Stol', category: 'stol',
        status: ModerationStatus.rejected, isActive: false, moderationNote: 'Sifatsiz'),
  ];

  @override
  Future<List<ShopProduct>> fetchProducts() async => items;

  @override
  Future<ShopProduct> updateProduct(
    String id, {
    String? name,
    int? priceUzs,
    bool? isActive,
    List<String>? styles,
  }) async {
    calls.add(styles == null ? 'update $id active=$isActive' : 'update $id styles=${styles.join(',')}');
    return items.first;
  }

  List<ShopWallpaper> wallpapers = [
    ShopWallpaper(
        id: 'w1', name: 'Gul oboy', url: '', status: 'pending', priceUzs: 85000,
        widthCm: 106, totalLengthM: 10, createdAt: DateTime(2026)),
    ShopWallpaper(
        id: 'w2', name: 'Chiziq', url: '', status: 'rejected', priceUzs: 90000,
        widthCm: 53, totalLengthM: 10.5, moderationNote: 'Xira rasm', createdAt: DateTime(2026)),
    ShopWallpaper(
        id: 'w3', name: 'Eski oboy', url: '', status: 'rejected', priceUzs: 70000,
        widthCm: 106, totalLengthM: 10, moderationNote: "Do'kon olib tashladi",
        createdAt: DateTime(2026)),
  ];

  @override
  Future<List<ShopWallpaper>> fetchWallpapers() async => wallpapers;

  @override
  Future<void> deleteWallpaper(String id) async => calls.add('delete $id');

  @override
  Future<ShopWallpaper> updateWallpaper(
    String id, {
    List<int>? bytes,
    String? filename,
    String? contentType,
    String? name,
    int? priceUzs,
    double? widthCm,
    double? totalLengthM,
  }) async {
    calls.add('update-wp $id name=$name');
    return wallpapers.first;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}

void main() {
  testWidgets('lists products with status; only approved ones have a visibility switch', (tester) async {
    final repo = _FakeRepo();
    await tester.pumpWidget(ProviderScope(
      overrides: [businessRepositoryProvider.overrideWithValue(repo)],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('uz'),
        home: ShopProductsScreen(),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Divan Milano'), findsOneWidget);
    expect(find.text('4 500 000 so\'m'), findsOneWidget);
    expect(find.text('Tasdiqlangan'), findsOneWidget);
    expect(find.byType(Switch), findsOneWidget);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(repo.calls, ['update a active=false']);
  });

  testWidgets('back button has a tooltip', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [businessRepositoryProvider.overrideWithValue(_FakeRepo())],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('uz'),
        home: ShopProductsScreen(),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Orqaga'), findsOneWidget);
  });

  testWidgets('editing a product sends the styles picked, in the API order', (tester) async {
    final repo = _FakeRepo();
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(ProviderScope(
      overrides: [businessRepositoryProvider.overrideWithValue(repo)],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('uz'),
        home: ShopProductsScreen(),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Divan Milano'));
    await tester.pumpAndSettle();
    expect(find.text('Hamma uslubga mos'), findsOneWidget);
    await tester.tap(find.text('Loft'));
    await tester.pump();
    await tester.tap(find.text('Zamonaviy'));
    await tester.pumpAndSettle();
    expect(find.text('Hamma uslubga mos'), findsNothing);

    await tester.tap(find.text('Saqlash'));
    await tester.pumpAndSettle();
    expect(repo.calls, ['update a styles=zamonaviy,loft']);
  });

  Future<void> openWallpapers(WidgetTester tester, _FakeRepo repo) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(ProviderScope(
      overrides: [businessRepositoryProvider.overrideWithValue(repo)],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('uz'),
        home: ShopProductsScreen(),
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Oboylar'));
    await tester.pumpAndSettle();
  }

  testWidgets('wallpapers tab: tiles with status, size, and the rejection reason', (tester) async {
    await openWallpapers(tester, _FakeRepo());
    expect(find.text('Gul oboy'), findsOneWidget);
    expect(find.text("85 000 so'm · 106 sm × 10 m"), findsOneWidget);
    expect(find.text("Ko'rib chiqilmoqda"), findsOneWidget);
    expect(find.text('Rad etilgan'), findsOneWidget);
    expect(find.text('Sabab: Xira rasm'), findsOneWidget);
    expect(find.textContaining('53 sm × 10.5 m'), findsOneWidget);
  });

  testWidgets('a shop-removed wallpaper shows "Olib tashlangan" and restores by name', (tester) async {
    final repo = _FakeRepo();
    await openWallpapers(tester, repo);
    expect(find.text('Olib tashlangan'), findsOneWidget);
    expect(find.text('Sabab: Do\'kon olib tashladi'), findsNothing);
    await tester.tap(find.text('Qaytarish'));
    await tester.pumpAndSettle();
    expect(repo.calls, ['update-wp w3 name=Eski oboy']);
  });

  testWidgets('deleting a wallpaper asks first, without promising permanent deletion', (tester) async {
    final repo = _FakeRepo();
    await openWallpapers(tester, repo);
    await tester.tap(find.byTooltip("O'chirish").first);
    await tester.pumpAndSettle();
    expect(find.text("Oboy Studio'dan olib tashlansinmi?"), findsOneWidget);
    expect(repo.calls, isEmpty);
    await tester.tap(find.descendant(
        of: find.byType(AlertDialog), matching: find.text("O'chirish")));
    await tester.pumpAndSettle();
    expect(repo.calls, ['delete w1']);
  });
}
