# Magic Nav + «Yangi loyiha» Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the flat bottom bar + FAB with a 5-item "magic" bar (sliding raised circle + notch) and turn the new-project modal into a full-height sheet above the bar with three animated cards.

**Architecture:** `MagicNavBar` is a stateless widget drawn with a `CustomPainter`; its circle x is animated by `TweenAnimationBuilder` (300 ms, easeInOut, zero when animations are disabled). The sheet's open state is a Riverpod `StateProvider<bool>`; `AppShell` stacks a `NewProjectSheetLayer` over its body and derives the circle index from `open ? 2 : tabIndexFor(location)`. Cards loop with one `AnimationController` each and paint with `CustomPainter`, reusing `IsometricRoomView`.

**Tech Stack:** Flutter, flutter_riverpod 2, go_router 12, flutter_test.

**Spec:** `docs/superpowers/specs/2026-11-20-magic-nav-yangi-loyiha-design.md` (plus the owner's brief of 2026-11-20).

## Global Constraints

- No new packages, no video/Lottie/sound, no version bump.
- No `extendBody: true` on `AppShell`'s `Scaffold`; the sheet lives in the body.
- Colours from `DesignTokens` only: circle `primaryBlue`, icon `white`, bar `white`.
- All user-facing text via `AppLocalizations`; new keys in uz (with `@key`), ru, en; `flutter gen-l10n`.
- Inside animations only numbers (units like "m" allowed), no words.
- `MediaQuery.disableAnimations` → static frame, no running ticker.
- Card taps keep today's actions: wizard/draw `startNewProject()`, scan `continueCurrentProject()`; then `/wizard`, `/scanning/roomplan`, `/setup/draw`.
- `dart format` only own lines.

## Review Focus

1. A shell route that matches no tab (e.g. `/history`, `/business`) — no circle shown (no false "active" tab), bar still tappable. Test in Task 1.
2. Large text scale (2.0) — labels capped, no overflow in the bar. Existing test kept in Task 1.
3. Sheet opened from a root-navigator screen (`/setup/summary`, `/onboarding/e8`) — lands on the shell with the sheet open, not a dead flag. Test in Task 2.
4. Tapping the scrim / dragging the sheet down a short distance — short drag snaps back open, long drag closes. Test in Task 2 (long drag closes).
5. Home tour target `HomeTourTarget.newProject` still keys the «+» item. Assert in Task 1.

---

### Task 1: MagicNavBar in AppShell

**Files:**
- Create: `lib/widgets/nav/magic_nav_bar.dart`
- Modify: `lib/screens/app_shell.dart` (replace `_BottomNavWithFab`/`_fabItem`)
- Test: `test/widget/app_shell_test.dart`

**Interfaces:**
- Produces: `class MagicNavItem { const MagicNavItem({required IconData icon, required IconData activeIcon, required String label, Key? key}); }`
- Produces: `class MagicNavBar extends StatelessWidget { const MagicNavBar({required List<MagicNavItem> items, required int? selectedIndex, required ValueChanged<int> onTap, bool raisedBackground = false}); }` — `selectedIndex == null` hides circle and notch. Circle widget has key `MagicNavBar.circleKey`.
- Produces: `int? AppShell.tabIndexFor(String location)` (static): `/`→0, `/shop…`→1, `/masters…`→3, `/profile…`→4, else null. Index 2 is «+».

- [ ] **Step 1: Write failing tests** in `app_shell_test.dart`:
  - `five equal items with their names` — `find.bySemanticsLabel` for Uy, Do'kon, `Yangi loyiha qo'shish`, Ustalar, Profil each `findsOneWidget`; the 5 slot widths are equal.
  - `tapping each item routes and the circle follows` — for each tab tap → body text, `MagicNavBar.selectedIndex` == expected, and after settle the circle's centre dx equals the tapped item's centre dx (±1).
  - `no circle on a shell route that matches no tab` — `/history` route → `selectedIndex == null`, `find.byKey(MagicNavBar.circleKey)` paints nothing (Opacity 0 / not found).
  - `«+» keeps the home-tour key` — `find.byKey(keys.of(HomeTourTarget.newProject))` finds the third slot.
  - Keep the large-text test.
- [ ] **Step 2:** `flutter test test/widget/app_shell_test.dart` — Expected: FAIL (MagicNavBar undefined).
- [ ] **Step 3: Implement.** Bar: overhang 20 px above a 64 px bar (+ bottom SafeArea); circle Ø48 centred at bar-top+4; notch = `Path.combine(difference, barRect, circle r=30 at (cx, 0))`, shadow via `canvas.drawShadow`; `TweenAnimationBuilder<double>` on the circle's fraction, `Duration(milliseconds: 300)` (`Duration.zero` when `MediaQuery.disableAnimationsOf`), `Curves.easeInOut`. Active label in blue below the notch; others muted under the icon, `textScaler` clamped to 1.2. Overhang painted `backgroundLight`, or `white` when `raisedBackground` (sheet open). Each slot: `Semantics(button, selected, label)` + `InkWell`; visible text in `ExcludeSemantics`.
- [ ] **Step 4:** run test file — Expected: PASS; `flutter analyze` — No issues.
- [ ] **Step 5: Commit** `feat(nav): magic bottom menu with a sliding circle and notch`

### Task 2: Sheet state, layer, entry point

**Files:**
- Create: `lib/features/new_project/new_project_sheet_state.dart`
- Create: `lib/screens/room_setup/new_project_sheet_layer.dart`
- Modify: `lib/screens/room_setup/new_project_sheet.dart` (`showNewProjectSheet`, card taps close via provider instead of `Navigator.pop`)
- Modify: `lib/screens/app_shell.dart` (body `Stack`, circle index, tab tap closes sheet, `AppShellScope` marker)
- Test: `test/widget/app_shell_test.dart`

**Interfaces:**
- Produces: `final newProjectSheetOpenProvider = StateProvider<bool>((ref) => false);`
- Produces: `void showNewProjectSheet(BuildContext context)` — if no `AppShellScope` ancestor, `GoRouter.of(context).go('/')`; then sets the provider true.
- Produces: `class AppShellScope extends InheritedWidget` with `static bool isInside(BuildContext)`.
- Produces: `class NewProjectSheetLayer extends ConsumerStatefulWidget` — slide-up (`AnimationController`, 300 ms; zero when animations disabled), scrim tap closes, vertical drag > 25 % height or fling > 700 px/s closes, `BackButtonListener` closes while open; renders nothing when fully closed.

- [ ] **Step 1: Failing tests** (shell harness with `disableAnimations` builder):
  - `«+» opens the sheet and the menu stays visible` — tap «+» → `find.byType(NewProjectSheet)` found, `selectedIndex == 2`, the sheet's bottom ≤ bar's top, tapping «Do'kon» still works.
  - `tapping a tab while open closes it and moves there` — open, tap Ustalar → no sheet, MASTERS BODY, `selectedIndex == 3`.
  - `tapping «+» again closes and returns the circle` — `selectedIndex == 0`.
  - `Back closes the sheet` — `await tester.binding.handlePopRoute()` → no sheet, HOME BODY still there, `selectedIndex == 0`.
  - `swipe down closes` — drag the handle by `Offset(0, 500)` → no sheet.
  - `a caller outside the shell lands on the shell with the sheet open` — root route `/outside` with a button calling `showNewProjectSheet` → after tap: HOME BODY and the sheet.
- [ ] **Step 2:** run — Expected: FAIL.
- [ ] **Step 3: Implement** per Interfaces.
- [ ] **Step 4:** run test file + `test/widget/ar_scan_screen_test.dart` — Expected: PASS.
- [ ] **Step 5: Commit** `feat(new-project): full-height sheet above the menu, one entry point`

### Task 3: Animated cards + l10n

**Files:**
- Create: `lib/widgets/new_project/new_project_animations.dart`
- Modify: `lib/screens/room_setup/new_project_sheet.dart` (cards replace `_EntryOption`)
- Modify: `lib/l10n/app_uz.arb`, `app_ru.arb`, `app_en.arb` (+ regenerated `lib/l10n/app_localizations*.dart`)
- Test: `test/widget/new_project_sheet_test.dart`, update `test/widget/ar_scan_screen_test.dart`

**Interfaces:**
- Produces: `class LoopingAnimation extends StatefulWidget { const LoopingAnimation({required Duration period, required double staticT, required Widget Function(BuildContext, double t) builder}); }` — no controller started when `MediaQuery.disableAnimationsOf(context)`; builds with `staticT`.
- Produces: `WizardBoxAnimation`, `LidarScanAnimation`, `DrawRoomAnimation` (const, no params). Periods 3.5 s, 3.6 s, 3.4 s.
- New l10n keys: `newProjectWizardCaption` («O'lchamlarni kiriting»), `newProjectLidarCaption` («Xonani skanerlang»), `newProjectArScanCaption` («Pol burchaklarini belgilang»), `newProjectDrawCaption` («Xonani barmoq bilan chizing»). Removed: `newProjectWizardDesc`, `newProjectLidarDesc`, `newProjectArScanDesc`, `newProjectDrawDesc` (only the sheet used them).

- [ ] **Step 1: Failing tests:**
  - `each card shows title and short caption` (uz strings).
  - `wizard card starts a new project and opens /wizard`; `scan card continues and opens /scanning/roomplan`; `draw card starts a new project and opens /setup/draw` — fake `RoomPersistenceNotifier` override is not needed if the route body text appears and the sheet provider is false; record the persistence call via an override of `roomPersistenceProvider`.
  - `with disableAnimations pumpAndSettle completes` — and `tester.hasRunningAnimations` is false.
  - `with animations on, frames advance` — pump 1 s twice without settle; no exception.
  - `Android title for the scan card` — `newProjectArScanTitle` + `newProjectArScanCaption`.
  - Card semantics: `bySemanticsLabel` contains title and caption.
- [ ] **Step 2:** run — Expected: FAIL.
- [ ] **Step 3: Implement** painters (wizard: `IsometricRoomView.polygon(showEdgeLengths: false)` + finger dot at the projected corner + readout `'${w.toStringAsFixed(1)} m × ${d.toStringAsFixed(1)} m'`; lidar: plan rectangle, phone glyph orbit, walls revealed by `t`, iso box fades in for t > 0.75; draw: polyline traced by `t`, closes at 0.7, side lengths fade in). l10n keys; `flutter gen-l10n`.
- [ ] **Step 4:** `flutter test` (full) — Expected: all pass; `flutter analyze` — No issues.
- [ ] **Step 5: Commit** `feat(new-project): three animated cards with short captions`

### Task 4: Docs + simulator check

- [ ] Update `docs/ARCHITECTURE.md` "Pastki menyu" paragraph.
- [ ] Build `flutter build ios --simulator --debug --dart-define=…`, `xcrun simctl install`, screenshot each tab, the sheet, each card mid-animation into the scratchpad `magicnav/` dir.
- [ ] Commit `docs: magic nav and the new-project sheet`.
