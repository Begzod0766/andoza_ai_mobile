import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tamir_uy_mobile_flutter/l10n/app_localizations.dart';
import 'package:tamir_uy_mobile_flutter/models/business_profile.dart';
import 'package:tamir_uy_mobile_flutter/providers/business_provider.dart';
import 'package:tamir_uy_mobile_flutter/repositories/business_repository.dart';
import 'package:tamir_uy_mobile_flutter/screens/business/add_product_screen.dart';
import 'package:tamir_uy_mobile_flutter/screens/business/add_wallpaper_screen.dart';
import 'package:tamir_uy_mobile_flutter/services/api_client.dart';

class _FakeRepo implements BusinessRepository {
  final calls = <String>[];
  Object? failWith;

  @override
  Future<ShopWallpaper> addWallpaper({
    required List<int> bytes,
    required String filename,
    required String contentType,
    required String name,
    required int priceUzs,
    required double widthCm,
    required double totalLengthM,
  }) async {
    if (failWith != null) throw failWith!;
    calls.add('add $name $priceUzs $widthCm $totalLengthM $filename');
    return ShopWallpaper(
        id: 'n', name: name, url: 'u', status: 'pending', createdAt: DateTime(2026));
  }

  @override
  Future<List<ShopWallpaper>> fetchWallpapers() async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}

final _png = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==');

Future<XFile?> _pick(ImageSource _) async => XFile.fromData(
      _png,
      name: 'a.jpg',
    );

Widget _app(_FakeRepo repo, Widget home, {Locale locale = const Locale('uz')}) => ProviderScope(
      overrides: [businessRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp.router(
        routerConfig: GoRouter(routes: [GoRoute(path: '/', builder: (_, _) => home)]),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: locale,
      ),
    );

Finder get _save => find.widgetWithText(FilledButton, 'Saqlash');
bool _saveEnabled(WidgetTester t) => t.widget<FilledButton>(_save).onPressed != null;

Future<void> _fill(WidgetTester t, {String name = 'Gul', String price = '85000', String w = '106', String l = '10'}) async {
  final f = find.byType(TextField);
  await t.enterText(f.at(0), name);
  await t.enterText(f.at(1), price);
  await t.enterText(f.at(2), w);
  await t.enterText(f.at(3), l);
  await t.pump();
}

void main() {
  setUp(() {});

  testWidgets('save stays disabled until a photo is chosen and the numbers are in range', (t) async {
    await t.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => t.binding.setSurfaceSize(null));
    final repo = _FakeRepo();
    await t.pumpWidget(_app(repo, const AddWallpaperScreen(pickImage: _pick)));

    expect(_saveEnabled(t), isFalse);
    await _fill(t); // valid values, still no photo
    expect(_saveEnabled(t), isFalse);

    await t.tap(find.text('Galereyadan'));
    await t.pumpAndSettle();
    expect(_saveEnabled(t), isTrue);

    for (final bad in [
      (price: '0', w: '106', l: '10'),
      (price: '85000', w: '29', l: '10'),
      (price: '85000', w: '151', l: '10'),
      (price: '85000', w: '106', l: '0.5'),
      (price: '85000', w: '106', l: '51'),
    ]) {
      await _fill(t, price: bad.price, w: bad.w, l: bad.l);
      expect(_saveEnabled(t), isFalse, reason: '$bad');
    }
    await _fill(t, w: '106.5', l: '10,5');
    expect(_saveEnabled(t), isTrue);
    await _fill(t, name: '  ');
    expect(_saveEnabled(t), isFalse);
  });

  testWidgets('valid form calls addWallpaper and shows the pending snackbar', (t) async {
    await t.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => t.binding.setSurfaceSize(null));
    final repo = _FakeRepo();
    await t.pumpWidget(_app(
      repo,
      Builder(
        builder: (ctx) => Scaffold(
          body: TextButton(
            onPressed: () => Navigator.of(ctx).push(MaterialPageRoute<void>(
                builder: (_) => const AddWallpaperScreen(pickImage: _pick))),
            child: const Text('open'),
          ),
        ),
      ),
    ));
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    await _fill(t, w: '106.5');
    await t.tap(find.text('Galereyadan'));
    await t.pumpAndSettle();
    await t.tap(_save);
    await t.pumpAndSettle();

    expect(repo.calls, ['add Gul 85000 106.5 10.0 wallpaper.jpg']);
    expect(find.text("Admin tasdiqlagach Studio'da ko'rinadi."), findsOneWidget);
  });

  testWidgets('the server detail of a 409 is shown', (t) async {
    await t.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => t.binding.setSurfaceSize(null));
    final repo = _FakeRepo()
      ..failWith = ApiException(
        message: 'Conflict',
        statusCode: 409,
        response: {'detail': "Bu oboy ro'yxatingizda bor, uni tahrirlang"},
      );
    await t.pumpWidget(_app(repo, const AddWallpaperScreen(pickImage: _pick)));
    await _fill(t);
    await t.tap(find.text('Galereyadan'));
    await t.pumpAndSettle();
    await t.tap(_save);
    await t.pumpAndSettle();
    expect(find.text("Bu oboy ro'yxatingizda bor, uni tahrirlang"), findsOneWidget);
  });

  testWidgets('editing an approved wallpaper hides the photo picker', (t) async {
    await t.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => t.binding.setSurfaceSize(null));
    final w = ShopWallpaper(
        id: 'a', name: 'Gul', url: '', status: 'approved', priceUzs: 1000, widthCm: 106, totalLengthM: 10,
        createdAt: DateTime(2026));
    await t.pumpWidget(_app(_FakeRepo(), AddWallpaperScreen(wallpaper: w, pickImage: _pick)));
    expect(find.text('Galereyadan'), findsNothing);
    expect(find.text('Oboyni tahrirlash'), findsOneWidget);
    expect(_saveEnabled(t), isTrue);
  });

  testWidgets('a pending wallpaper keeps the photo picker', (t) async {
    await t.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => t.binding.setSurfaceSize(null));
    final w = ShopWallpaper(
        id: 'a', name: 'Gul', url: '', status: 'pending', priceUzs: 1000, widthCm: 106, totalLengthM: 10,
        createdAt: DateTime(2026));
    await t.pumpWidget(_app(_FakeRepo(), AddWallpaperScreen(wallpaper: w, pickImage: _pick)));
    expect(find.text('Galereyadan'), findsOneWidget);
  });

  testWidgets('the title is translated in Russian', (t) async {
    await t.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(_app(_FakeRepo(), const AddWallpaperScreen(pickImage: _pick),
        locale: const Locale('ru')));
    expect(find.text('Добавить обои'), findsOneWidget);
  });

  testWidgets('add product screen links to the wallpaper form', (t) async {
    await t.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => t.binding.setSurfaceSize(null));
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, _) => const AddProductScreen()),
      GoRoute(path: '/business/add-wallpaper', builder: (_, _) => const Text('WALLPAPER FORM')),
    ]);
    await t.pumpWidget(ProviderScope(
      overrides: [businessRepositoryProvider.overrideWithValue(_FakeRepo())],
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('uz'),
      ),
    ));
    await t.pumpAndSettle();
    expect(find.text("Oboy qo'shmoqchimisiz?"), findsOneWidget);
    await t.tap(find.text("Oboy qo'shish"));
    await t.pumpAndSettle();
    expect(find.text('WALLPAPER FORM'), findsOneWidget);
  });
}
