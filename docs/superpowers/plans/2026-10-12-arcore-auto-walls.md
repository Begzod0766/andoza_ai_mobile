# ARCore Auto Walls + Snap-to-Corner Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** In the ARCore scan's corners step, walls are found automatically, their intersections become corners on their own, and holding the target still (~1 s) adds a corner — no button needed.

**Architecture:** Three ARCore-free Kotlin classes (JVM-tested) — `WallTracker` (vertical planes → floor-level wall segments → corner candidates with stability), `DwellDetector` (hold-still trigger) and additions to `FloorPlanCapture` (auto flag, adjacency rule, rejected spots). `ArScanActivity` wires them in `onDrawFrame` on the GL thread; `ArOverlayView` draws walls, candidates and a progress ring. Flutter side, channel and Dart geometry are unchanged except one hint string.

**Tech Stack:** Kotlin, ARCore 1.56.0, JUnit4 (JVM unit tests), Flutter ARB l10n.

**Spec:** `docs/superpowers/specs/2026-10-12-arcore-auto-walls-design.md`

## Global Constraints

- Package/dir: `android/app/src/main/kotlin/com/tamir_uy/tamir_uy_mobile_flutter/arscan/`; tests in `android/app/src/test/kotlin/com/tamir_uy/tamir_uy_mobile_flutter/arscan/`.
- New logic classes import nothing from `com.google.ar.*` or `android.*` (JVM-testable).
- All geometry is 2D on the floor (X, Z) in metres.
- Spec values: merge ≤ 5° and ≤ 8 cm; candidate angle ≥ 30°; intersection ≤ 50 cm from each wall's nearest end; stable = moved < 5 cm over 1000 ms and both walls ≥ 50 cm; snap radius 15 cm; dwell 1000 ms within 3 cm, re-arm after 15 cm; adjacency: last corner ≤ 15 cm from one of the candidate's two wall lines; rejected spot radius 20 cm; close-to-first 20 cm (existing).
- GL-thread state is never shared mutable with the UI: pass immutable snapshots (`OverlayState`) via `runOnUiThread`.
- Kotlin test command (the shared `~/.gradle` cache is broken on this Mac):
  `cd android && GRADLE_USER_HOME=/private/tmp/claude-501/-Users-mac-Projects-andoza-ai/c986d112-f740-4ce1-aee9-aded3695b70f/scratchpad/gradle-home ./gradlew -q :app:testDebugUnitTest`
  Results: `build/app/test-results/testDebugUnitTest/*.xml` (repo root `build/`).
- Commits end with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.

## Review Focus

1. A stable candidate sitting on an already-placed (non-first) corner must not be added again every frame → `acceptsAuto` rejects it (Task 3 test).
2. Same walls arriving in a different order / with a fresh plane id merged in must keep the same candidate key, or stability resets forever → Task 1 test.
3. Holding still after a dwell fires must not fire again → Task 2 test.
4. After Undo of an auto corner, the still-stable candidate must not come straight back, but snapping onto it must still work → Task 3 tests (auto rejected, `addCorner(auto=false)` allowed).
5. Furniture faces (< 50 cm) and parallel / far-apart walls must not yield auto corners → Task 1 tests.

---

### Task 1: WallTracker

**Files:**
- Create: `arscan/WallTracker.kt`
- Test: `arscan/WallTrackerTest.kt`

**Interfaces:**
- Consumes: `Vec3` (FloorPlanCapture.kt).
- Produces:
  ```kotlin
  data class WallObs(val id: Int, val cx: Float, val cz: Float, val dx: Float, val dz: Float, val halfLength: Float) // (dx,dz) unit
  data class WallSegment(val key: Int, val ax: Float, val az: Float, val bx: Float, val bz: Float) { val length: Float }
  data class CornerCandidate(val key: Long, val x: Float, val z: Float, val stable: Boolean, val wallA: WallSegment, val wallB: WallSegment)
  data class WallFrame(val walls: List<WallSegment>, val candidates: List<CornerCandidate>)
  /** World polygon of a vertical plane → floor segment; null if `normal` is not ~horizontal (|normal.y| > 0.3) or < 2 points. */
  fun wallObsFrom(id: Int, center: Vec3, normal: Vec3, polygonWorld: List<Vec3>): WallObs?
  class WallTracker { fun update(walls: List<WallObs>, nowMs: Long): WallFrame }
  ```
  `WallSegment.key` = smallest `WallObs.id` merged into it. `CornerCandidate.key` = `(min(keyA,keyB).toLong() shl 32) or max(keyA,keyB).toLong()`.

- [ ] **Step 1: Write the failing tests** (`WallTrackerTest`), with a helper `wall(id, ax, az, bx, bz)` building a `WallObs` from two endpoints:
  - `four walls of a 4x3 room give four corners` — walls (0,0)-(4,0), (4,0)-(4,3), (4,3)-(0,3), (0,3)-(0,0) → 4 candidates at the room corners (±1 cm).
  - `L-shaped room gives six corners` — 6 walls of an L (0,0)(4,0)(4,2)(2,2)(2,4)(0,4) → 6 candidates.
  - `parallel walls give no corner` — (0,0)-(4,0) and (0,3)-(4,3) → 0.
  - `walls far from each other give no corner` — (0,0)-(1,0) and (3,1)-(3,3) (intersection (3,0) is 2 m from the first wall's end) → 0.
  - `two pieces of one wall merge` — (0,0)-(1.5,0) id 1 and (2,0.03)-(4,0.03) id 2 → 1 wall, key 1, spanning x 0..4.
  - `a candidate becomes stable after a second of standing still` — square, update at t=0 → `stable=false`; t=999 → false; t=1000 → true.
  - `a moving candidate restarts its clock` — t=0, t=600 with one wall shifted 6 cm, t=1200 → false; t=1600 → true.
  - `short walls never make a stable corner` — square where one wall is 0.4 m long → that wall's candidates exist but `stable=false` at t=2000.
  - `wall order and a newly merged piece keep the candidate key` — same room, input order reversed and an extra collinear piece id 99 → same set of candidate keys.
  - `wallObsFrom turns a vertical plane polygon into a floor segment` — center (2,1,0), normal (0,0,1), polygon (0,0,0),(4,0,0),(4,2,0),(0,2,0) → cx 2, cz 0, |dx| 1, halfLength 2; normal (0,1,0) → null.

- [ ] **Step 2: Run, verify FAIL** — Kotlin test command; Expected: compilation failure "Unresolved reference: WallObs".

- [ ] **Step 3: Implement `WallTracker.kt`.** Merge greedily, longest first: an obs joins a cluster when angle ≤ 5° and the obs centre's perpendicular distance to the cluster line ≤ 8 cm; the merged segment lies on the longest member's line, endpoints = min/max projection of all members' endpoints. Candidate for each wall pair with angle ≥ 30°, line intersection P, and `min(|P−a|,|P−b|) ≤ 0.5` for both walls. Stability: per candidate key keep `(refX, refZ, sinceMs)`; reset ref when P moves > 5 cm from ref; `stable = now − since ≥ 1000 && both lengths ≥ 0.5`; forget keys not seen this frame.

- [ ] **Step 4: Run, verify PASS** — Expected: `WallTrackerTest` 10/10, `FloorPlanCaptureTest` still green.

- [ ] **Step 5: Commit** — `feat(arscan): find walls and their corners from vertical planes`

### Task 2: DwellDetector

**Files:**
- Create: `arscan/DwellDetector.kt`
- Test: `arscan/DwellDetectorTest.kt`

**Interfaces:**
- Produces:
  ```kotlin
  data class Dwell(val progress: Float, val fired: Boolean)   // progress 0..1
  class DwellDetector(holdMs: Long = 1000, radiusM: Float = 0.03f, rearmM: Float = 0.15f) {
      fun update(p: Vec3?, nowMs: Long): Dwell
      fun reset()
  }
  ```
  Distances in XZ only.

- [ ] **Step 1: Write the failing tests:**
  - `holding still for a second fires once` — same point at t=0, 500 (progress 0.5±0.01), 1000 → `fired=true`; t=1100 → `fired=false`.
  - `jitter above 3 cm restarts` — t=0 (0,0), t=600 (0.04,0), t=1000 → not fired; t=1600 → fired.
  - `holding still after firing does not fire again` — fire at t=1000, keep same point until t=5000 → no more fires, progress 0.
  - `moving 15 cm re-arms` — after a fire, move to (0.16,0) at t=1200, hold to t=2200 → fires.
  - `losing the target resets progress` — t=0 point, t=500 null → progress 0; t=600 point, t=1500 → not fired; t=1600 → fired.

- [ ] **Step 2: Run, verify FAIL** — Expected: "Unresolved reference: DwellDetector".
- [ ] **Step 3: Implement `DwellDetector.kt`** (state: hold anchor + start time; after a fire, the fire point; armed only once `p` is > rearmM from it).
- [ ] **Step 4: Run, verify PASS** — Expected: 5/5.
- [ ] **Step 5: Commit** — `feat(arscan): add a corner by holding the target still`

### Task 3: FloorPlanCapture — auto corners

**Files:**
- Modify: `arscan/FloorPlanCapture.kt`
- Test: `arscan/FloorPlanCaptureTest.kt` (add tests)

**Interfaces:**
- Consumes: `CornerCandidate`, `WallSegment` (Task 1).
- Produces:
  ```kotlin
  fun addCorner(p: Vec3, auto: Boolean = false): AddResult   // existing signature + default param
  fun acceptsAuto(c: CornerCandidate): Boolean
  ```
  `undo()`, `reopen()`, `updatePositions()` keep a per-corner auto flag list in step with `points` (swap whole lists, `@Volatile`, like `points`).

- [ ] **Step 1: Write the failing tests:**
  - `first auto corner is accepted` — empty capture, any candidate → true.
  - `auto corner must share a wall with the last corner` — corner at (0,0); candidate (4,0) with wallA (0,0)-(4,0) → true; candidate (4,3) with walls (4,0)-(4,3),(4,3)-(0,3) → false.
  - `a candidate on an existing corner is not added again` — corners (0,0),(4,0); candidate (4.05,0) sharing wall → false.
  - `a candidate on the first corner closes once there are three corners` — corners (0,0),(4,0),(4,3),(0,3); candidate (0.05,0) with wall (0,3)-(0,0) → true; with only 2 corners → false.
  - `undoing an auto corner rejects that spot for auto only` — `addCorner((0,0), auto=true)`, `undo()` → `acceptsAuto(candidate at (0.1,0))` false; `addCorner((0.1,0), auto=false)` → `ADDED`.
  - `undoing a manual corner rejects nothing` — `addCorner((0,0))`, `undo()` → candidate at (0,0) accepted.
  - `closed outline accepts nothing` — closed square → false.

- [ ] **Step 2: Run, verify FAIL** — Expected: "Unresolved reference: acceptsAuto".
- [ ] **Step 3: Implement.** `acceptsAuto`: false if closed; false within 20 cm of a rejected spot; false within 20 cm of any corner except the first (near the first: true only when size ≥ 3); true if empty; else true iff the last corner is ≤ 15 cm from the infinite line of `wallA` or `wallB`.
- [ ] **Step 4: Run, verify PASS** — Expected: all FloorPlanCapture tests green.
- [ ] **Step 5: Commit** — `feat(arscan): rules for taking a wall corner on its own`

### Task 4: Wire into the scan screen

**Files:**
- Modify: `arscan/ArScanActivity.kt` (`onDrawFrame`, `addCorner`, fallback strings)
- Modify: `arscan/ArRenderer.kt` (`OverlayState`, `ArOverlayView.onDraw`)
- Modify: `lib/l10n/app_uz.arb`, `app_ru.arb`, `app_en.arb` (value of `arScanCornersHint` only), regenerate with `flutter gen-l10n`

**Interfaces:**
- Consumes: Tasks 1–3.
- Produces: `OverlayState` gains `walls: List<Pair<Pair<Float,Float>,Pair<Float,Float>>>`, `candidates: List<Pair<Float,Float>>`, `dwell: Float`, `reticleAt: Pair<Float,Float>?` (snapped screen position; null = centre).

- [ ] **Step 1: Activity.** In `onDrawFrame`, while `step == CORNERS && tracking && !capture.isClosed`:
  1. Vertical planes (`VERTICAL`, `TRACKING`, `subsumedBy == null`) → `wallObsFrom(id, centerPose translation, centerPose.yAxis, polygon→world via centerPose.transformPoint)`; ids from a `HashMap<Plane, Int>` counter.
  2. `tracker.update(obs, elapsedRealtime)`.
  3. First candidate with `stable && capture.acceptsAuto(it)` → `addCornerAt(x, z, auto = true)`.
  4. Else: snap target = nearest candidate ≤ 15 cm from the reticle; `dwell.update(reticle, now)`; on `fired` → `addCornerAt(target, auto=false)` if snapped, else the existing hit-based `addCorner()`.
  Otherwise `dwell.reset()`. `addCornerAt` creates the anchor with `session.createAnchor(Pose.makeTranslation(x, floorY, z))` (`floorY` = `capture.floorY` or the last floor hit's y) and goes through `capture.addCorner(..., auto)` exactly like `addCorner()` (same `AddResult` handling). After any corner is added, `overlay.performHapticFeedback(HapticFeedbackConstants.CONFIRM)` on the UI thread (no permission needed).
- [ ] **Step 2: Overlay.** Walls: blue lines (`Color.rgb(59,130,246)`, 3 dp). Candidates: hollow white circles 9 dp. Reticle drawn at `reticleAt` when snapped, with a progress arc (`dwell` × 360°) in blue.
- [ ] **Step 3: Hint copy** — `arScanCornersHint` (also the Activity fallback):
  - uz: `Devorlarni sekin ko'rsating — burchaklar o'zi qo'shiladi. Yoki nishonni burchakda ushlab turing`
  - ru: `Медленно покажите стены — углы добавятся сами. Или задержите прицел на углу`
  - en: `Slowly show the walls — corners add themselves. Or hold the target on a corner`
- [ ] **Step 4: Verify.** `flutter gen-l10n && flutter analyze` → "No issues found!"; `flutter test` → all pass; Kotlin test command → all suites green; `flutter build apk --debug` (with the same `GRADLE_USER_HOME`) → "Built".
- [ ] **Step 5: Commit** — `feat(arscan): walls and corners appear on their own while scanning`

Device check (user, S25 Ultra + A54) follows the spec's manual list; not part of task completion.
