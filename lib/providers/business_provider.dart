import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/business_profile.dart';
import '../repositories/business_repository.dart';
import 'auth_provider.dart';

final businessRepositoryProvider = Provider<BusinessRepository>((ref) {
  return BusinessRepository(ref.watch(apiClientProvider));
});

/// The account's roles. Re-fetched whenever the signed-in user changes (a new
/// login, a logout), so one person's roles never show for the next; falls back
/// to "ordinary user" when it cannot be fetched, which is what everyone is at
/// the least — a failed roles call must never lock someone out of the app.
final accountRolesProvider = FutureProvider<AccountRoles>((ref) async {
  final auth = ref.watch(authStateProvider);
  if (auth is! AuthAuthenticated) return AccountRoles.plainUser;
  try {
    return await ref.watch(businessRepositoryProvider).fetchRoles();
  } catch (_) {
    return AccountRoles.plainUser;
  }
});

/// The caller's own shop (null: none) and usta profile (null: none).
final myShopProvider = FutureProvider.autoDispose<ShopProfile?>((ref) {
  return ref.watch(businessRepositoryProvider).fetchShop();
});

final myProductsProvider = FutureProvider.autoDispose<List<ShopProduct>>((ref) {
  return ref.watch(businessRepositoryProvider).fetchProducts();
});

final shopWallpapersProvider = FutureProvider.autoDispose<List<ShopWallpaper>>((ref) {
  return ref.watch(businessRepositoryProvider).fetchWallpapers();
});

final myLeadsProvider = FutureProvider.autoDispose<List<UstaLead>>((ref) {
  return ref.watch(businessRepositoryProvider).fetchLeads();
});

final myPortfolioProvider = FutureProvider.autoDispose<List<PortfolioItem>>((ref) {
  return ref.watch(businessRepositoryProvider).fetchPortfolio();
});

/// A usta's public portfolio, for the customer-facing profile.
final ustaPortfolioProvider = FutureProvider.autoDispose.family<List<PortfolioItem>, String>((ref, ustaId) {
  return ref.watch(businessRepositoryProvider).fetchUstaPortfolio(ustaId);
});

final myInquiriesProvider = FutureProvider.autoDispose<List<ShopInquiry>>((ref) {
  return ref.watch(businessRepositoryProvider).fetchInquiries();
});

final myStatsProvider = FutureProvider.autoDispose<SellerStats>((ref) {
  return ref.watch(businessRepositoryProvider).fetchStats();
});

final myUstaProvider = FutureProvider.autoDispose<UstaProfile?>((ref) {
  return ref.watch(businessRepositoryProvider).fetchUsta();
});

/// Which business application a person asked for while registering. Read once
/// by the app shell, which then opens that application form straight away.
final pendingBusinessSetupProvider = StateProvider<BusinessKind?>((ref) => null);

enum BusinessKind { shop, usta }

final mySellerOrdersProvider = FutureProvider.autoDispose<List<SellerOrder>>((ref) {
  return ref.watch(businessRepositoryProvider).fetchSellerOrders();
});
