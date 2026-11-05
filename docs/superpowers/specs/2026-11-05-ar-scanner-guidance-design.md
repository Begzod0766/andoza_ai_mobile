# Android AR scanner — in-scan guidance

Date: 2026-11-05 · Branch: `feat/scanner-guidance` (on `fix/scanner-tracking`)

## Why

On a phone test the scanner worked, but the user found closing the room
awkward (the first corner was out of view and had drifted) and did not know
where they were in the flow. The diagnostics log showed the worst corners
were placed from 3–3.7 m away at grazing angles. Goal: guide the user during
the scan so they place corners from close, know the current step, and can
find the first corner to close the room.

Out of scope: voice prompts, a video tutorial, iOS (RoomPlan has its own UI).

## 1. Pre-scan guide (Flutter)

- `ArScanScreen` shows a guide page before it starts the native scanner when
  the `ar_scan_guide_seen` flag in `shared_preferences` is not set.
- Content: four tips with icons, then a "Boshlash" button that sets the flag
  and starts the scan.
  1. Hold the phone at chest height, tilted to the floor.
  2. Use a lit room; aim at furniture or patterns, not blank walls.
  3. Walk slowly along the walls and mark the corners in order.
  4. Step within 2 m of each corner.
- A "?" action in the app bar reopens the guide (the screen's problem and
  busy states).
- The flag is only read and written through a small `ArScanGuidePrefs`
  helper, so tests can fake it.

## 2. Step indicator (native)

- `ScanFlow.progress(): ScanProgress(index, total = 5, labelKey)`:

  | Steps | Progress |
  |---|---|
  | FIND_FLOOR | 1 Pol (`arScanStepFloor`) |
  | BASE | 2 Boshlang'ich burchak (`arScanStepBase`) |
  | HEIGHT | 3 Balandlik (`arScanStepHeight`) |
  | WALLS, DONE | 4 Devorlar (`arScanStepWalls`) |
  | OPENINGS | 5 Eshik/deraza (`arScanStepOpenings`) |

- `ArScanChrome` shows "3/5 · Balandlik" and five dots at the top. Dots up to
  the current index are filled.

## 3. Arrow to the first corner (native)

- Shown in WALLS once there are at least 3 corners (closing is possible).
- `WallGeometry.locate(p): ScreenTarget`:
  - `OnScreen(px)` when `p` projects in front of the camera inside the
    viewport (minus a margin);
  - otherwise `OffScreen(edgePx, angleRad)`: the point where the ray from the
    screen centre toward the target meets the inset screen border, and the
    arrow angle. A target behind the camera has its direction flipped, so the
    arrow still points the way to turn.
- `OverlayState` gains `firstCorner: ScreenTarget?` and `firstCornerLabel`
  (the distance from the camera, "1,2 m").
  - On screen: a pulsing ring with "Boshlang'ich nuqta".
  - Off screen: an arrow at `edgePx` rotated to `angleRad`, with the distance
    next to it.

## 4. Accuracy hints (native)

- `ScanFlow.ui(..., aimDistM: Float?)`: in BASE and WALLS, when
  `aimDistM > FAR_AIM_M` (3.0 m), the hint becomes `arScanStepCloser`.
  - Higher-priority hints still win: tracking lost, settling, and snap to the
    first corner.
  - The main button stays enabled.
- `aimDistM` is the horizontal distance from the camera to the reticle,
  computed in the activity.
- HEIGHT with no live height: `OverlayState.ceilingArrow = true` draws an
  animated up arrow above the centre.

## Copy (uz / ru / en)

- **Step labels:** `arScanStepFloor`, `arScanStepBase`, `arScanStepHeight`,
  `arScanStepWalls`, `arScanStepOpenings`.
- **In-scan hints:** `arScanStepCloser`, `arScanFirstCorner`.
- **Pre-scan guide:**
  - `arScanGuideTitle`;
  - `arScanGuideHold`, `arScanGuideLight`, `arScanGuideWalk`, `arScanGuideClose`;
  - `arScanGuideStart`, `arScanGuideHelp`.
- The native keys are passed in `_strings`, each with a Kotlin fallback.

## Testing

- **Kotlin:** `ScanFlow.progress` for every step; the far-aim hint and its
  priority; `WallGeometry.locate` for on-screen, off-screen to the left or
  right, and behind the camera.
- **Flutter:**
  - The guide shows on the first run, and "Boshlash" sets the flag and starts
    the scan.
  - The guide is skipped when the flag is set.
  - "?" reopens the guide.
  - The native copy map carries the new keys.
- **Phone:** check every item with a real scan.
