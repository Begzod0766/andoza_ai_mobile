import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/room_scan/pending_scan_store.dart';
import '../features/tour/home_tour_keys.dart';
import '../features/tour/home_tour_steps.dart';
import '../features/tour/startup_dialogs.dart';
import '../providers/business_provider.dart';
import '../l10n/app_localizations.dart';
import '../widgets/nav/magic_nav_bar.dart';
import '../features/new_project/new_project_sheet_state.dart';
import 'room_setup/new_project_sheet.dart';
import 'room_setup/new_project_sheet_layer.dart';
import 'scanning/flat_scan_review_page.dart';
import 'scanning/room_scan_review_page.dart';

/// Shared app shell: the bottom menu (Uy / Do'kon / "+" / Ustalar / Profil) —
/// a shared nav-level element, not something any individual screen renders
/// itself. [MagicNavBar] draws five equal slots; the active one's icon sits
/// in a blue circle raised over a notch and slides to the tapped slot (owner
/// design of 2026-11-20, replacing the flat bar with a separate "+" button).
/// The "+" slot opens the new-project sheet (A3).
class AppShell extends ConsumerStatefulWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  /// The menu slot a shell [location] belongs to: Uy 0, Do'kon 1, Ustalar 3,
  /// Profil 4 (slot 2 is the "+"); null for a route that is no tab.
  static int? tabIndexFor(String location) {
    if (location == '/') return 0;
    final head = location.split('/').take(2).join('/');
    return switch (head) {
      '/shop' => 1,
      '/masters' => 3,
      '/profile' => 4,
      _ => null,
    };
  }

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  // Token restore happens at app bootstrap (SplashScreen) — before the auth
  // guard runs — not here: the shell only ever mounts once already
  // authenticated, so restoring here was dead code.

  @override
  void initState() {
    super.initState();
    // The shell mounts exactly once per authenticated session (see the
    // comment above), which makes it the one place to ask, at most once per
    // app open, whether a LiDAR scan interrupted before "Davom etish" (app
    // backgrounded, call came in, low-memory kill) should be resumed — see
    // PendingScanStore for why that scan survives at all.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Someone who registered as a shop owner or an usta goes straight to
      // that application; the interrupted-scan prompt is for everyone else.
      final kind = ref.read(pendingBusinessSetupProvider);
      if (kind != null) {
        ref.read(pendingBusinessSetupProvider.notifier).state = null;
        ref.read(startupDialogShownProvider.notifier).state = true;
        context.push(kind == BusinessKind.usta ? '/business/apply/usta' : '/business/apply/shop');
        return;
      }
      _offerPendingScan();
    });
  }

  Future<void> _offerPendingScan() async {
    final flat = await PendingScanStore.hasPendingFlat();
    if (!flat && !await PendingScanStore.hasPending()) return;
    if (!mounted) return;
    if (ref.read(homeTourRunningProvider)) return;
    ref.read(startupDialogShownProvider.notifier).state = true;
    final l10n = AppLocalizations.of(context)!;
    final resume = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.pendingScanTitle),
        content: Text(l10n.pendingScanBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.pendingScanDiscard),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.pendingScanResume),
          ),
        ],
      ),
    );
    if (resume != true) {
      await PendingScanStore.clear();
      await PendingScanStore.clearFlat();
      return;
    }
    if (flat) {
      final loadedFlat = await PendingScanStore.loadFlat();
      if (loadedFlat == null || !mounted) return;
      GoRouter.of(context).push(
        '/scanning/roomplan/review-flat',
        extra: FlatScanReviewArgs(drafts: loadedFlat.drafts, scans: loadedFlat.scans),
      );
      return;
    }
    final loaded = await PendingScanStore.load();
    if (loaded == null || !mounted) return;
    GoRouter.of(context).push(
      '/scanning/roomplan/review',
      extra: RoomScanReviewArgs(draft: loaded.draft, scan: loaded.scan),
    );
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    if (location == '/login') {
      return Scaffold(body: widget.child);
    }

    final sheetOpen = ref.watch(newProjectSheetOpenProvider);
    // No extendBody (see CLAUDE.md): the new-project sheet is stacked in the
    // body, above the menu, so the menu stays visible and tappable.
    return AppShellScope(
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(child: widget.child),
            const Positioned.fill(child: NewProjectSheetLayer()),
          ],
        ),
        bottomNavigationBar: _ShellNavBar(
          location: location,
          sheetOpen: sheetOpen,
          tourKeys: ref.watch(homeTourKeysProvider),
        ),
      ),
    );
  }
}

class _ShellNavBar extends ConsumerWidget {
  const _ShellNavBar({
    required this.location,
    required this.sheetOpen,
    required this.tourKeys,
  });

  final String location;
  final bool sheetOpen;
  final HomeTourKeys tourKeys;

  /// Tab routes by slot; slot 2 is the "+" (new project), not a route.
  static const _routes = ['/', '/shop/s1', null, '/masters/u1', '/profile'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return MagicNavBar(
      // While the sheet is open the circle sits on "+"; closing it brings the
      // circle back to the tab of the current route.
      selectedIndex: sheetOpen ? 2 : AppShell.tabIndexFor(location),
      raisedBackground: sheetOpen,
      onTap: (i) {
        final route = _routes[i];
        if (route == null) {
          if (sheetOpen) {
            ref.read(newProjectSheetOpenProvider.notifier).state = false;
          } else {
            showNewProjectSheet(context);
          }
          return;
        }
        ref.read(newProjectSheetOpenProvider.notifier).state = false;
        context.go(route);
      },
      items: [
        MagicNavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: l10n.navHome),
        MagicNavItem(
          icon: Icons.storefront_outlined,
          activeIcon: Icons.storefront,
          label: l10n.navShop,
          key: tourKeys.of(HomeTourTarget.shop),
        ),
        MagicNavItem(
          icon: Icons.add,
          activeIcon: Icons.add,
          // Short under the icon; the full "add a new project" is read out.
          label: l10n.newProjectTitle,
          semanticLabel: l10n.navAddProject,
          key: tourKeys.of(HomeTourTarget.newProject),
        ),
        MagicNavItem(
          icon: Icons.groups_outlined,
          activeIcon: Icons.groups,
          label: l10n.navMasters,
          key: tourKeys.of(HomeTourTarget.masters),
        ),
        MagicNavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: l10n.navProfile),
      ],
    );
  }
}
