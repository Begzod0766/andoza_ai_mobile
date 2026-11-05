# AR Scanner In-Scan Guidance Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** guide the user through the Android AR scan with four things:
- a pre-scan guide;
- a step indicator;
- an arrow to the first corner;
- a "step closer" hint and a ceiling arrow.

**Architecture:**
- Pure logic lives in Kotlin and is unit-tested:
  - `ScanFlow.progress()` and the far-aim hint in `ScanFlow.ui`;
  - `WallGeometry.locate`.
- `ArScanActivity` feeds the results into `OverlayState`.
- `ArOverlayView` draws the ring, the arrow and the ceiling arrow.
- `ArScanChrome` shows the step indicator.
- The guide is a Flutter view inside `ArScanScreen`, gated by a Riverpod-provided prefs helper.

**Tech Stack:** Kotlin (ARCore, Android Views, JUnit 4), Flutter (Riverpod, shared_preferences, gen-l10n).

**Spec:** `docs/superpowers/specs/2026-11-05-ar-scanner-guidance-design.md`

## Global Constraints

- The far-aim threshold is `FAR_AIM_M = 3.0f`, the horizontal distance from the camera to the reticle.
- There are 5 steps:

  | Steps | Index | Key |
  |---|---|---|
  | FIND_FLOOR | 1 | `arScanStepFloor` |
  | BASE | 2 | `arScanStepBase` |
  | HEIGHT | 3 | `arScanStepHeight` |
  | WALLS, DONE | 4 | `arScanStepWalls` |
  | OPENINGS | 5 | `arScanStepOpenings` |

- Hint priority, highest first:
  1. tracking lost;
  2. settling;
  3. snap to the first corner;
  4. far aim (`arScanStepCloser`);
  5. the step's normal hint.

  The far aim never disables the main button.
- The arrow shows only in WALLS with `corners.size >= 3`.
- The prefs key is `ar_scan_guide_seen`.
- Every user-facing string goes through ARB (uz with an `@` description, plus ru and en).
- Native keys are passed in `_strings` and get a Kotlin `fallback` entry.
- No `dart format` of whole files. Edit only the lines you change.

## Review Focus

- **Target directly behind the camera** (the user turned around): the arrow points down (turn around). It must not divide by zero → `locate` test.
- **Target just outside the viewport margin**: the arrow is pinned to the inset border and never drawn off-screen → `locate` test asserts the edge point is inside the bounds.
- **Far aim while snapping to the first corner**: the snap hint wins, because closing must stay obvious → `ScanFlow` test.
- **Guide "?" pressed while a scan result screen shows**: the guide opens. "Boshlash" there starts a fresh scan → widget test.
- **Prefs read failure** (the plugin throws): treat it as seen and start the scan, never block the scan → widget test with a throwing fake.

---

### Task 1: Step progress and far-aim hint (Kotlin)

**Files:**
- Modify: `android/app/src/main/kotlin/com/tamir_uy/tamir_uy_mobile_flutter/arscan/ScanFlow.kt`
- Test: `android/app/src/test/kotlin/com/tamir_uy/tamir_uy_mobile_flutter/arscan/ScanFlowTest.kt`

**Interfaces:**
- Produces:
  - `data class ScanProgress(val index: Int, val total: Int, val labelKey: String)`;
  - `fun ScanFlow.progress(): ScanProgress`;
  - `ScanFlow.ui(tracking, reticle, liveHeight, lostHintKey = "arScanTrackingLost", settling = false, aimDistM: Float? = null)`;
  - `companion object { const val FAR_AIM_M = 3.0f }` on `ScanFlow`.

- [ ] **Step 1: Write failing tests**

  - `progress follows the five steps`:
    - a fresh flow → `ScanProgress(1, 5, "arScanStepFloor")`;
    - after `floorFound()` → index 2, key `"arScanStepBase"`;
    - after `placeBase` → 3, `"arScanStepHeight"`;
    - after `confirmHeight` → 4, `"arScanStepWalls"`;
    - closed (DONE) → 4;
    - `startOpenings()` → 5, `"arScanStepOpenings"`.
  - `far aim asks to step closer without disabling` uses `walls()`, `ui(true, Vec3(2f,0f,2f), null, aimDistM = 3.5f)`:
    - `hintKey == "arScanStepCloser"`;
    - `mainEnabled` is true;
    - with `aimDistM = 2.5f` the hint is `"arScanCornersHint"`.
  - `far aim in the base step` uses `ScanFlow().apply { floorFound() }.ui(true, Vec3(1f,0f,1f), null, aimDistM = 4f).hintKey == "arScanStepCloser"`.
  - `snap beats far aim` uses three corners and a reticle within 0.35 m of the first, `aimDistM = 3.5f` → `"arScanSnapToFirst"`.
  - `settling and lost beat far aim`:
    - `settling = true, aimDistM = 4f` → `"arScanTrackingSettling"`;
    - `tracking = false` → the lost key.

- [ ] **Step 2: Run, expect failures**

  Run: `cd android && ./gradlew :app:testReleaseUnitTest --tests '*ScanFlowTest*' --offline`

  Expected: compile errors (`progress`, `aimDistM`), then assertion failures.

- [ ] **Step 3: Implement**

  - `progress()` is a `when(step)`.
  - In `ui`, apply the far-aim replacement only for BASE and WALLS and only when the step's hint is not `arScanSnapToFirst`. Do it before the existing lost/settling `when`, so those still override.

- [ ] **Step 4: Run, expect all Kotlin tests green**

  Run: `./gradlew :app:testReleaseUnitTest --offline`

  Expected: BUILD SUCCESSFUL.

- [ ] **Step 5: Commit**: `feat(ar-scan): step progress and a step-closer hint for far aims`

### Task 2: Where the first corner is on screen (Kotlin)

**Files:**
- Modify: `android/app/src/main/kotlin/com/tamir_uy/tamir_uy_mobile_flutter/arscan/WallGeometry.kt`
- Test: `android/app/src/test/kotlin/com/tamir_uy/tamir_uy_mobile_flutter/arscan/WallGeometryTest.kt`

**Interfaces:**
- Produces:
  - `sealed interface ScreenTarget { data class OnScreen(val at: Px); data class OffScreen(val at: Px, val angleRad: Float) }`;
  - `fun WallGeometry.locate(p: Vec3, marginPx: Float): ScreenTarget`.
- The angle is screen-space `atan2(dy, dx)`: x to the right, y down.

- [ ] **Step 1: Write failing tests** (use the existing `g`: identity view, 90° fov, 1000×1000; margin 50):

  - `point ahead is on screen`: `locate(Vec3(0f,0f,-2f), 50f)` is `OnScreen((500,500))`.
  - `point far right is off screen at the right edge`:
    - `locate(Vec3(10f,0f,-2f), 50f)` is `OffScreen` with `at.first == 950f` and `at.second ≈ 500f`;
    - the angle ≈ 0.
  - `point behind and to the left points left`: `locate(Vec3(-1f,0f,2f), 50f)` is `OffScreen` with `at.first == 50f` and `|angle| ≈ π`.
  - `point straight behind points down`: `locate(Vec3(0f,0f,2f), 50f)` is `OffScreen` with angle ≈ `π/2` and `at.second == 950f`.
  - `off-screen point is always inside the inset bounds`: for several targets around the camera, `at` lies within `[50, 950]` on both axes.

- [ ] **Step 2: Run, expect a compile failure**

  Run: `./gradlew :app:testReleaseUnitTest --tests '*WallGeometryTest*' --offline`

- [ ] **Step 3: Implement `locate`**

  1. `v = toView(p)`.
  2. If `visible(v)` and the screen point lies inside the inset rectangle → `OnScreen`.
  3. Otherwise take a direction `d`:
     - the screen offset from the centre when visible;
     - `(v.x, -v.y)` when behind;
     - `(0, 1)` when that is ≈ 0.
  4. Scale `d` by `s = min((w/2 - m)/|dx|, (h/2 - m)/|dy|)`, skipping a zero component, to get `at`.
  5. `angle = atan2(dy, dx)`.

- [ ] **Step 4: Run, expect green** (all Kotlin tests)

- [ ] **Step 5: Commit**: `feat(ar-scan): locate a world point on screen or at the screen edge`

### Task 3: Draw the guidance and wire the activity (native + copy)

**Files:**
- Modify: `.../arscan/ArRenderer.kt`:
  - `OverlayState` gains `firstCorner: ScreenTarget? = null`, `firstCornerLabel: String? = null`, `ceilingArrow: Boolean = false`;
  - drawing for each.
- Modify: `.../arscan/ArScanChrome.kt`: the step indicator (a `TextView` "3/5 · Balandlik" above the hint card plus 5 dots) and `bind(..., progress: ScanProgress, progressLabel: String)`.
- Modify: `.../arscan/ArScanActivity.kt`:
  - compute `aimDistM` (horizontal camera→reticle) and pass it to `flow.ui`;
  - build `firstCorner` via `geo.locate(corners[0], dp(56))` in WALLS with ≥3 corners;
  - the label is the camera→first-corner horizontal distance via `ArOverlayView.cm`;
  - `ceilingArrow = step == HEIGHT && liveHeight == null`;
  - add fallbacks for the new keys.
- Modify: `lib/l10n/app_{uz,ru,en}.arb`:
  - `arScanStepFloor`, `arScanStepBase`, `arScanStepHeight`, `arScanStepWalls`, `arScanStepOpenings`;
  - `arScanStepCloser`, `arScanFirstCorner`;
  - then run `flutter gen-l10n`.
- Modify: `lib/screens/scanning/ar_scan_screen.dart`: `_strings` adds those 7 keys.
- Test: `test/widget/ar_scan_screen_test.dart`: `passes the scanner its guidance copy` asserts all 7 keys.

**Interfaces:**
- Consumes: `ScanFlow.progress()`, `FAR_AIM_M`, `aimDistM` (Task 1); `WallGeometry.locate`, `ScreenTarget` (Task 2).

- [ ] **Step 1: Write the failing widget test** (the 7 keys equal the uz l10n values)
- [ ] **Step 2: Run it, expect a FAIL** (`flutter test test/widget/ar_scan_screen_test.dart`)
- [ ] **Step 3: Add the ARB keys and run gen-l10n; add the `_strings` entries**
  - **uz:**
    - Pol
    - Boshlang'ich burchak
    - Balandlik
    - Devorlar
    - Eshik/deraza
    - Burchakka yaqinroq boring — uzoqdan aniqlik pasayadi
    - Boshlang'ich nuqta
  - **ru:**
    - Пол
    - Начальный угол
    - Высота
    - Стены
    - Двери/окна
    - Подойдите ближе к углу — издалека точность падает
    - Начальная точка
  - **en:**
    - Floor
    - Starting corner
    - Height
    - Walls
    - Doors/windows
    - Step closer to the corner — accuracy drops from far away
    - Starting point
- [ ] **Step 4: Native drawing**
  - `OnScreen`: two rings, pulsing via `SystemClock.uptimeMillis()` with `invalidate()` already per frame, and a label chip "Boshlang'ich nuqta".
  - `OffScreen`: a filled triangle arrow at `at`, rotated by `angleRad`, with the distance chip offset toward the centre.
  - `ceilingArrow`: a chevron above the centre whose y oscillates by 12 dp.
  - Then the chrome indicator and the activity wiring.
- [ ] **Step 5: Run all tests**
  - `./gradlew :app:testReleaseUnitTest --offline` is green.
  - `flutter analyze` reports no issues.
  - `flutter test` passes.
- [ ] **Step 6: Commit**: `feat(ar-scan): step indicator, arrow to the first corner, ceiling arrow`

### Task 4: Pre-scan guide (Flutter)

**Files:**
- Create: `lib/features/ar_scan/ar_scan_guide_prefs.dart`:
  - `abstract class ArScanGuidePrefs { Future<bool> seen(); Future<void> markSeen(); }`;
  - `SharedPrefsArScanGuidePrefs` using the key `ar_scan_guide_seen`;
  - `final arScanGuidePrefsProvider = Provider<ArScanGuidePrefs>((_) => SharedPrefsArScanGuidePrefs());`.
- Modify: `lib/screens/scanning/ar_scan_screen.dart`:
  - a `_guide` bool state;
  - `initState` → `_maybeGuide()`, which reads `seen()`; on false (or false after a throw is treated as seen=true) it shows the guide, otherwise `_start()`;
  - the guide view (title, 4 `ListTile`-style rows with icons `Icons.smartphone`, `Icons.lightbulb_outline`, `Icons.directions_walk`, `Icons.near_me`, and an `ElevatedButton` `arScanGuideStart` that calls `markSeen()` then `_start()`);
  - AppBar action `IconButton(Icons.help_outline, tooltip: arScanGuideHelp)` shown when not busy, which sets `_guide = true`.
- Modify: ARB, adding:
  - `arScanGuideTitle` (uz "Yaxshi o'lchash uchun");
  - `arScanGuideHold` ("Telefonni ko'krak balandligida, polga qiya qilib ushlang");
  - `arScanGuideLight` ("Xona yorug' bo'lsin; mebel yoki naqshli joylarga qarating, bo'sh devorga emas");
  - `arScanGuideWalk` ("Devor bo'ylab sekin yuring, burchaklarni ketma-ket belgilang");
  - `arScanGuideClose` ("Har bir burchakka 2 m dan yaqinroq boring");
  - `arScanGuideStart` ("Boshlash");
  - `arScanGuideHelp` ("Qo'llanma").
  - ru and en are translations of the same.
- Test: `test/widget/ar_scan_screen_test.dart`:
  - `_pump` takes `ArScanGuidePrefs guide` (a default fake with `seen=true`) and overrides `arScanGuidePrefsProvider`.

- [ ] **Step 1: Write failing widget tests**
  - `first run shows the guide, Boshlash starts the scan`:
    - with a fake `seen=false`, the guide title is visible and `fake.checks == 0`;
    - tapping `arScanGuideStart` sets `markSeen` called, and `checks == 1`.
  - `seen guide goes straight to the scan`: with `seen=true`, `checks == 1` and no title.
  - `help reopens the guide`: on the rejected screen, tapping the help icon shows the title.
  - `prefs failure never blocks the scan`: when `seen()` throws, `checks == 1`.
- [ ] **Step 2: Run them, expect FAIL**
- [ ] **Step 3: Implement** the prefs helper, ARB plus gen-l10n, and the screen
- [ ] **Step 4: Run** `flutter analyze` and `flutter test`; expect everything green
- [ ] **Step 5: Commit**: `feat(ar-scan): a short guide before the first scan`

### Task 5: Verify on the phone

- [ ] Build a debug APK with the production `--dart-define`s (see `docs/BUILD_AND_RELEASE.md`) and install it with `adb install -r` when the phone is connected. Also copy it to `~/Downloads/andoza-1.0.0+29-scanner-guidance.apk`.
- [ ] The user scans a room. Check the guide, the indicator, the arrow, the step-closer hint and the ceiling arrow.
- [ ] Push `fix/scanner-tracking` and `feat/scanner-guidance`, and open the PRs only after the phone check (stacked on #50).
