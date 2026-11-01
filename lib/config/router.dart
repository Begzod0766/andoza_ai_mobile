import '../widgets/push_permission_prompt.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod/riverpod.dart';

import '../providers/auth_provider.dart';
import '../services/analytics_service.dart';
import '../services/push_router.dart';
import '../screens/app_shell.dart';
import '../screens/auth/login_screen.dart';
import '../screens/room_setup/room_wizard_screen.dart';
import '../screens/room_setup/draw_room_screen.dart';
import '../screens/studio/studio_webview_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/home/home_with_projects_screen.dart';
import '../screens/room_setup/dimensions_entry_screen.dart';
import '../screens/room_setup/wall_measurements_screen.dart';
import '../screens/room_setup/room_summary_screen.dart';
import '../screens/share/share_pin_screen.dart';
import '../screens/scanning/ar_scan_screen.dart';
import '../screens/scanning/photo_scanning_screen.dart';
import '../screens/scanning/room_scan_screen.dart';
import '../screens/scanning/flat_scan_review_page.dart';
import '../screens/scanning/room_scan_review_page.dart';
import '../screens/design/b1_room_intro_screen.dart';
import '../screens/design/b2_room_entry_screen.dart';
import '../screens/design/b3_decoration_rail_screen.dart';
import '../screens/interior/c1_paint_wallpaper_screen.dart';
import '../screens/interior/c4_floor_selection_screen.dart';
import '../screens/interior/c5_furniture_placement_screen.dart';
import '../screens/interior/c7_walkthrough_screen.dart';
import '../screens/interior/c8_topdown_plan_screen.dart';
import '../screens/interior/c9_decoration_complete_screen.dart';
import '../screens/electrical/d1_electrical_intro_screen.dart';
import '../screens/electrical/d8_electrical_summary_screen.dart';
import '../screens/electrical/d9_cost_estimate_screen.dart';
import '../screens/electrical/d10_final_confirmation_screen.dart';
import '../models/api/api.dart' show Furniture;
import '../models/estimate_model.dart';
import '../screens/estimation/e1_estimation_intro_screen.dart';
import '../screens/estimation/e2_material_costs_screen.dart';
import '../screens/estimation/e3_labor_costs_screen.dart';
import '../models/shop_model.dart';
import '../providers/business_provider.dart' show BusinessKind;
import '../screens/business/business_apply_screen.dart';
import '../screens/business/business_screen.dart';
import '../screens/business/add_product_screen.dart';
import '../screens/business/edit_shop_screen.dart';
import '../screens/business/edit_usta_screen.dart';
import '../screens/business/shop_inquiries_screen.dart';
import '../screens/business/shop_stats_screen.dart';
import '../screens/business/usta_leads_screen.dart';
import '../screens/business/shop_products_screen.dart';
import '../screens/business/usta_portfolio_screen.dart';
import '../screens/shop/e10_search_results_screen.dart';
import '../screens/shop/s1_shop_home_screen.dart';
import '../screens/shop/s2_project_materials_screen.dart';
import '../screens/shop/s3_product_detail_screen.dart';
import '../screens/shop/s4_dealer_comparison_screen.dart';
import '../screens/shop/s5_shopping_cart_screen.dart';
import '../screens/shop/s6_checkout_screen.dart';
import '../screens/business/shop_orders_screen.dart';
import '../screens/shop/s7_order_confirmation_screen.dart';
import '../screens/shop/furniture_detail_screen.dart';
import '../screens/shop/store_page_screen.dart';
import '../providers/masters_provider.dart';
import '../screens/masters/u1_masters_intro_screen.dart';
import '../screens/masters/u3_request_booking_screen.dart';
import '../screens/masters/u4_review_rating_screen.dart';
import '../screens/masters/u5_booking_confirmation_screen.dart';
import '../screens/profile/e4_profile_settings_screen.dart';
import '../screens/profile/e5_projects_screen.dart';
import '../screens/profile/e6_orders_screen.dart';
import '../screens/profile/e11_saved_designs_screen.dart';
import '../screens/mebel/mebel_webview_screen.dart';
import '../screens/onboarding/e7_onboarding_welcome_screen.dart';
import '../screens/onboarding/e8_tutorial_tour_screen.dart';
import '../screens/onboarding/e9_preferences_settings_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _GoRouterRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);
  final newScreenViewObserver = ref.read(screenViewObserverFactoryProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: refreshNotifier,
    // Screen views go to Analytics only in a release build whose Firebase
    // came up; otherwise there is no observer at all.
    observers: newScreenViewObserver == null ? null : [newScreenViewObserver()],
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final isAuthenticated = authState is AuthAuthenticated;
      final isLoginRoute = state.matchedLocation == '/login';
      final isSplash = state.matchedLocation == '/splash';

      // Allow splash screen
      if (isSplash) {
        return null;
      }

      // Redirect unauthenticated users to login
      if (!isAuthenticated && !isLoginRoute) {
        return '/login';
      }

      // A push tapped while signed out (or during splash) opens once the
      // user lands: after sign-in on /login, or splash's hand-off to '/'.
      final pending = ref.read(pendingPushRouteProvider);
      if (isAuthenticated &&
          pending != null &&
          (isLoginRoute || state.matchedLocation == '/')) {
        // Clear after routing, not during it: writing a provider inside the
        // redirect can trip Riverpod's "modified during build" assertion.
        Future.microtask(
          () => ref.read(pendingPushRouteProvider.notifier).state = null,
        );
        return pending == state.matchedLocation ? null : pending;
      }

      // Redirect authenticated users away from login
      if (isAuthenticated && isLoginRoute) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      ShellRoute(
        // The shell has its own navigator, so it needs its own observer
        // instance or its tab/inner screens never reach Analytics.
        observers: newScreenViewObserver == null
            ? null
            : [newScreenViewObserver()],
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            // NoTransitionPage: bottom-nav tabs are a swap, not a push — no
            // slide in either direction (the default MaterialPage transition
            // always slides in from the right, even on the way "back" to a
            // tab positioned left of the previous one).
            pageBuilder: (context, state) => NoTransitionPage(
              name: state.path,
              child: const PushPermissionPrompt(
                child: HomeWithProjectsScreen(),
              ),
            ),
          ),
          // No separate "history" concept in the spec — orders are the
          // only history this app tracks, so /history shows the same
          // real E6 order list as /profile/e6.
          GoRoute(
            path: '/history',
            builder: (context, state) => const E6OrdersScreen(),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => NoTransitionPage(
              name: state.path,
              child: const E4ProfileSettingsScreen(),
            ),
          ),
          GoRoute(
            path: '/setup/dimensions',
            builder: (context, state) => const DimensionsEntryScreen(),
          ),
          GoRoute(
            path: '/setup/wall-measurements',
            builder: (context, state) => const WallMeasurementsScreen(),
          ),
          // A8 (Eshik/Deraza qo'shish) has no standalone route — it's only
          // ever shown as a modal sheet with a real onAdd callback, from A7
          // (wall_measurements_screen.dart's _showAddOpeningSheet).
          GoRoute(
            path: '/setup/summary',
            builder: (context, state) => const RoomSummaryScreen(),
          ),
          // Batch B Routes (Room state & entering the 3D room) — B1 kept
          // (matches spec), B1-alt/B2/B3 are genuinely missing and get
          // built fresh in Step 5. B2-B4 route paths retired here since
          // design/b2-b4_*.dart don't correspond to real spec screens
          // (see plans/screen-mapping.md) — they remain as unrouted
          // reference files for Step 9's in-3D rail screens to consult.
          GoRoute(
            path: '/design/b1',
            builder: (context, state) => const B1RoomIntroScreen(),
          ),
          GoRoute(
            path: '/design/b2',
            builder: (context, state) => const B2RoomEntryScreen(),
          ),
          GoRoute(
            path: '/design/b3',
            builder: (context, state) => const B3DecorationRailScreen(),
          ),
          // Batch C Routes (decoration inside the 3D room) — C1-C3, C5-C6
          // are each one continuous interactive screen (see
          // c1_paint_wallpaper_screen.dart's doc comment for why).
          GoRoute(
            path: '/interior/c1',
            builder: (context, state) => const C1PaintWallpaperScreen(),
          ),
          GoRoute(
            path: '/interior/c4',
            builder: (context, state) => const C4FloorSelectionScreen(),
          ),
          GoRoute(
            path: '/interior/c5',
            builder: (context, state) => const C5FurniturePlacementScreen(),
          ),
          GoRoute(
            path: '/interior/c7',
            builder: (context, state) => const C7WalkthroughScreen(),
          ),
          GoRoute(
            path: '/interior/c8',
            builder: (context, state) => const C8TopdownPlanScreen(),
          ),
          GoRoute(
            path: '/interior/c9',
            builder: (context, state) => const C9DecorationCompleteScreen(),
          ),
          // Electrical System Routes — D1-D7 consolidated into one
          // continuous drag-to-place screen (see
          // d1_electrical_intro_screen.dart's doc comment for why).
          GoRoute(
            path: '/electrical/d1',
            builder: (context, state) => const D1ElectricalIntroScreen(),
          ),
          GoRoute(
            path: '/electrical/d8',
            builder: (context, state) => const D8ElectricalSummaryScreen(),
          ),
          GoRoute(
            path: '/electrical/d9',
            builder: (context, state) => const D9CostEstimateScreen(),
          ),
          GoRoute(
            path: '/electrical/d10',
            builder: (context, state) => const D10FinalConfirmationScreen(),
          ),
          // Estimation Routes (E1-E3)
          GoRoute(
            path: '/estimation/e1',
            builder: (context, state) => const E1EstimationIntroScreen(),
          ),
          GoRoute(
            path: '/estimation/e2',
            builder: (context, state) =>
                E2MaterialCostsScreen(stage: state.extra as EstimateStage),
          ),
          GoRoute(
            path: '/estimation/e3',
            builder: (context, state) => const E3LaborCostsScreen(),
          ),
          // Shop Routes (S1-S7)
          GoRoute(
            path: '/shop/s1',
            pageBuilder: (context, state) => NoTransitionPage(
              name: state.path,
              child: const S1ShopHomeScreen(),
            ),
          ),
          // E10 (Qidiruv natijalari) is a Do'kon search-results screen,
          // not an estimate screen — the old /estimation/e10 path/file was
          // a numbering collision with an unrelated "final estimate
          // export" screen (see Step 8 in
          // plans/andozaai-design-rebuild.md), retired in favor of this.
          GoRoute(
            path: '/shop/search',
            builder: (context, state) => E10SearchResultsScreen(
              initialQuery: state.extra as String? ?? '',
            ),
          ),
          GoRoute(
            path: '/shop/s2',
            builder: (context, state) => const S2ProjectMaterialsScreen(),
          ),
          GoRoute(
            path: '/shop/s3',
            builder: (context, state) =>
                S3ProductDetailScreen(product: state.extra as Product),
          ),
          GoRoute(
            path: '/shop/s4',
            builder: (context, state) =>
                S4DealerComparisonScreen(product: state.extra as Product),
          ),
          // A shop's public page, and one of its pieces of furniture.
          GoRoute(
            path: '/shop/store/:storeId',
            builder: (context, state) =>
                StorePageScreen(storeId: state.pathParameters['storeId']!),
          ),
          GoRoute(
            path: '/shop/furniture/:id',
            builder: (context, state) => FurnitureDetailScreen(
              id: state.pathParameters['id']!,
              initial: state.extra as Furniture?,
            ),
          ),
          GoRoute(
            path: '/shop/s5',
            builder: (context, state) => const S5ShoppingCartScreen(),
          ),
          GoRoute(
            path: '/shop/s6',
            builder: (context, state) => const S6CheckoutScreen(),
          ),
          GoRoute(
            path: '/shop/s7',
            builder: (context, state) =>
                S7OrderConfirmationScreen(order: state.extra as ShopOrder?),
          ),
          // Masters Routes — U2 has no standalone route, it's a bottom
          // sheet shown from U1 (see u1_masters_intro_screen.dart's
          // _PinSheet).
          GoRoute(
            path: '/masters/u1',
            pageBuilder: (context, state) => NoTransitionPage(
              name: state.path,
              child: const U1MastersIntroScreen(),
            ),
          ),
          GoRoute(
            path: '/masters/u3',
            builder: (context, state) => const U3RequestBookingScreen(),
          ),
          GoRoute(
            path: '/masters/u4',
            builder: (context, state) =>
                U4ReviewRatingScreen(master: state.extra as MockMaster?),
          ),
          GoRoute(
            path: '/masters/u5',
            builder: (context, state) =>
                U5BookingConfirmationScreen(master: state.extra as MockMaster?),
          ),
          // Profile Routes (E5-E6, E11 — E4 lives at the shell's /profile
          // root, no separate /profile/e4 alias needed)
          GoRoute(
            path: '/profile/e5',
            builder: (context, state) => const E5ProjectsScreen(),
          ),
          GoRoute(
            path: '/profile/e6',
            builder: (context, state) => const E6OrdersScreen(),
          ),
          GoRoute(
            path: '/profile/e11',
            builder: (context, state) => const E11SavedDesignsScreen(),
          ),
          // Spec has no separate E9, see plans/screen-mapping.md; the
          // existing E9 settings screen moves to /profile/settings,
          // reachable from E4's menu, wired in Step 8.
          GoRoute(
            path: '/profile/settings',
            builder: (context, state) => const E9PreferencesSettingsScreen(),
          ),
          GoRoute(
            path: '/business',
            builder: (context, state) => const BusinessScreen(),
          ),
          GoRoute(
            path: '/business/leads',
            builder: (context, state) => const UstaLeadsScreen(),
          ),
          GoRoute(
            path: '/business/inquiries',
            builder: (context, state) => const ShopInquiriesScreen(),
          ),
          GoRoute(
            path: '/business/orders',
            builder: (context, state) => const ShopOrdersScreen(),
          ),
          GoRoute(
            path: '/business/stats',
            builder: (context, state) => const ShopStatsScreen(),
          ),
          GoRoute(
            path: '/business/portfolio',
            builder: (context, state) => const UstaPortfolioScreen(),
          ),
          GoRoute(
            path: '/business/products',
            builder: (context, state) => const ShopProductsScreen(),
          ),
        ],
      ),
      // Scanners are full screen (camera / native capture): outside the shell
      // so the bottom bar does not show through them.
      GoRoute(
        path: '/scanning/photo',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PhotoScanningScreen(),
      ),
      // RoomPlan (LiDAR) capture — the parametric flow behind the "LiDAR
      // skaner" entry. Probes support, presents the native scanner, and
      // reviews the converted room.
      GoRoute(
        path: '/scanning/roomplan',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const RoomScanScreen(),
      ),
      GoRoute(
        // Android camera measurement (ARCore) — see ArScanScreen.
        path: '/scanning/arcore',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ArScanScreen(),
      ),
      GoRoute(
        path: '/scanning/roomplan/review',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            RoomScanReviewPage(args: state.extra! as RoomScanReviewArgs),
      ),
      GoRoute(
        path: '/scanning/roomplan/review-flat',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            FlatScanReviewPage(args: state.extra! as FlatScanReviewArgs),
      ),
      // The web mebel workshop, full screen like the Studio.
      GoRoute(
        path: '/mebel',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MebelWebViewScreen(),
      ),
      // The shop / usta application is a full-screen form, outside the shell
      // like the other takeovers (see the E7/E8 note below).
      GoRoute(
        path: '/business/usta/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const EditUstaScreen(),
      ),
      GoRoute(
        path: '/business/shop/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const EditShopScreen(),
      ),
      GoRoute(
        path: '/business/products/new',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddProductScreen(),
      ),
      GoRoute(
        path: '/business/apply/:kind',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => BusinessApplyScreen(
          kind: state.pathParameters['kind'] == 'usta'
              ? BusinessKind.usta
              : BusinessKind.shop,
        ),
      ),
      // E7/E8 are full-screen dark onboarding takeovers per spec — kept
      // outside the ShellRoute so AppShell's bottom nav/FAB don't bleed
      // through underneath them, with a real back-stack entry (reached
      // via push, not go) so the system back button returns to the
      // caller instead of exiting the app. parentNavigatorKey is required
      // here: without it, a push() from a screen inside the ShellRoute's
      // branch still resolves onto the shell's own nested Navigator
      // (AppShell keeps rendering underneath) instead of the root one,
      // regardless of this route being declared outside the ShellRoute.
      GoRoute(
        path: '/onboarding/e7',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const E7OnboardingWelcomeScreen(),
      ),
      GoRoute(
        path: '/onboarding/e8',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const E8TutorialTourScreen(),
      ),
      // WebView screens must be full-screen (outside the ShellRoute) so the
      // AppShell bottom nav/FAB don't paint over — and steal taps from — the
      // web page's own bottom buttons. parentNavigatorKey routes the push to
      // the root Navigator (see the E7/E8 note above).
      GoRoute(
        path: '/studio/:roomId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => StudioWebViewScreen.studio(
          roomId: state.pathParameters['roomId']!,
          // `?focus=1`: open this room alone (used right after a scan).
          focus: state.uri.queryParameters['focus'] == '1',
          aiPin: state.uri.queryParameters['ai_pin'],
          // `?place=<furniture id>`: put a shop's model into the room.
          place: state.uri.queryParameters['place'],
        ),
      ),
      // "Share → Andoza AI" from the Pinterest app: pick the room, then the
      // studio opens its AI designer with the pin (lib/services/share_intent.dart).
      GoRoute(
        path: '/share/pin',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => SharePinScreen(
          text: state.uri.queryParameters['text'] ?? '',
        ),
      ),
      // Native room-capture wizard (full-screen, outside the ShellRoute so the
      // bottom nav doesn't overlap its buttons). Replaced the WebView wizard.
      GoRoute(
        path: '/wizard',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const RoomWizardScreen(),
      ),
      // "Draw your own" — sketch the room by dragging a rectangle with live
      // dimensions. Full-screen (outside the shell) so the drag has the whole
      // canvas.
      GoRoute(
        path: '/setup/draw',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const DrawRoomScreen(),
      ),
    ],
  );
});

/// Bridges Riverpod's [authStateProvider] to GoRouter's [Listenable]-based
/// refresh mechanism, so an auth change re-runs `redirect` without
/// rebuilding the GoRouter instance (which would reset navigation to
/// `initialLocation` and remount the whole shell).
class _GoRouterRefreshNotifier extends ChangeNotifier {
  _GoRouterRefreshNotifier(Ref ref) {
    _subscription = ref.listen<AuthState>(
      authStateProvider,
      (previous, next) => notifyListeners(),
    );
  }

  late final ProviderSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}
