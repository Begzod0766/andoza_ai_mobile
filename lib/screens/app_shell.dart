import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../config/design_tokens.dart';
import '../features/room_scan/pending_scan_store.dart';
import '../features/tour/startup_dialogs.dart';
import '../providers/business_provider.dart';
import '../l10n/app_localizations.dart';
import 'room_setup/new_project_sheet.dart';
import 'scanning/flat_scan_review_page.dart';
import 'scanning/room_scan_review_page.dart';

/// Shared app shell: the bottom navigation bar (Uy / Do'kon / Ustalar /
/// Profil) with a center orange "+" that opens the new-project sheet (A3) —
/// per spec, this is a shared nav-level element, not something any
/// individual screen renders itself. A plain flat bar: an earlier version
/// bumped the active tab and the "+" above the bar in raised circles with a
/// notch cut into the bar — reverted per explicit feedback that it read as
/// heavy/cluttered. The active tab is now just a rounded highlight filling
/// its own slot, in place, and the "+" is a same-height, same-row button
/// like the other four.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

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

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: _BottomNavWithFab(location: location),
    );
  }
}

class _BottomNavWithFab extends StatelessWidget {
  const _BottomNavWithFab({required this.location});

  final String location;

  static const _tabs = [
    _NavTab(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      route: '/',
    ),
    _NavTab(
      icon: Icons.storefront_outlined,
      activeIcon: Icons.storefront,
      route: '/shop/s1',
    ),
    _NavTab(
      icon: Icons.groups_outlined,
      activeIcon: Icons.groups,
      route: '/masters/u1',
    ),
    _NavTab(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      route: '/profile',
    ),
  ];

  /// Resolves a tab's localized name from its route — shown under the icon
  /// and used as the tab's Semantics name.
  static String _labelFor(AppLocalizations l10n, String route) => switch (route) {
        '/shop/s1' => l10n.navShop,
        '/masters/u1' => l10n.navMasters,
        '/profile' => l10n.navProfile,
        _ => l10n.navHome,
      };

  bool _isCurrent(_NavTab tab) {
    if (tab.route == '/') return location == '/';
    return location.startsWith(tab.route.split('/').take(2).join('/'));
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: DesignTokens.white,
        border: Border(
          top: BorderSide(color: Color(0xFFF0F1F4), width: 1),
        ),
        boxShadow: [DesignTokens.shadowNavBar],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              Expanded(child: _navItem(context, _tabs[0])),
              Expanded(child: _navItem(context, _tabs[1])),
              Expanded(child: _fabItem(context)),
              Expanded(child: _navItem(context, _tabs[2])),
              Expanded(child: _navItem(context, _tabs[3])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, _NavTab tab) {
    final l10n = AppLocalizations.of(context)!;
    final isCurrent = _isCurrent(tab);
    return Semantics(
      button: true,
      selected: isCurrent,
      // The tab's one accessible name; the visible text below is excluded
      // so screen readers don't read it twice.
      label: _labelFor(l10n, tab.route),
      child: InkWell(
        onTap: () => context.go(tab.route),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 52,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isCurrent ? DesignTokens.primaryBlue : Colors.transparent,
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              ),
              child: Icon(
                isCurrent ? tab.activeIcon : tab.icon,
                color: isCurrent ? DesignTokens.white : DesignTokens.textMuted,
                size: 22,
              ),
            ),
            const SizedBox(height: 2),
            // First-time users shouldn't have to guess the tabs. Capped so a
            // large system font can't push the label out of the 64 px bar.
            ExcludeSemantics(
              child: Text(
                _labelFor(l10n, tab.route),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textScaler: MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.2),
                style: DesignTokens.caption.copyWith(
                  fontSize: 11,
                  height: 1.2,
                  color: isCurrent ? DesignTokens.primaryBlue : DesignTokens.textGray,
                  fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fabItem(BuildContext context) {
    return Semantics(
      button: true,
      label: AppLocalizations.of(context)!.navAddProject,
      child: InkWell(
        onTap: () => showNewProjectSheet(context),
        child: Center(
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: DesignTokens.accentOrangeStrong,
            ),
            child: const Icon(Icons.add, color: DesignTokens.white, size: 22),
          ),
        ),
      ),
    );
  }
}

class _NavTab {
  const _NavTab({
    required this.icon,
    required this.activeIcon,
    required this.route,
  });

  final IconData icon;
  final IconData activeIcon;
  final String route;
}
