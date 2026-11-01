# Multi-room LiDAR scan Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** On iPhones that support it, scan several rooms in one go and land them in one apartment, already placed next to each other in the 3D Studio. Every other device keeps today's single-room scan unchanged.

**Architecture:**
- **Native capture.** A new native method `scanRooms` keeps one ARSession alive across rooms. Each room is a separate `RoomCaptureSession` run inside the same `RoomCaptureView`, so all rooms share one world frame. At the end, iOS 17's `StructureBuilder` refines them into a `CapturedStructure`. The method returns one RoomPlan JSON and one USDZ per room.
- **Dart side.** It converts each room as today, but keeps the world origin that the converter throws away now. From that origin it derives `state.layoutPos`, the per-room centre in metres in a shared flat frame that the web Studio already reads. It then creates all rooms in one apartment.
- **Backend.** The backend learns a `scan_group`, so that its 30-minute duplicate-scan cleanup does not delete same-size rooms from one multi-room session.

**Tech Stack:** Swift / RoomPlan (iOS 17 `StructureBuilder`, `RoomCaptureView(frame:arSession:)`), Flutter / Riverpod / go_router, FastAPI (andoza_ai backend), pytest, flutter_test.

**Spec:** the user's requests in the session of 2026-10-26:
1. "bir nechta xonalarni ketma-ket skanerlash" (scan several rooms one after another, merged with correct relative positions).
2. "ko'p xonali skaner qo'llab-quvvatlashi bor iPhone versiyada chiqsin, yoki bitta xonali skaner qolsin" (offer multi-room only where the iPhone supports it, otherwise keep single-room).

The current code was surveyed on 2026-10-26; the findings are summarised in **Context** below.

## Context (current code, verified 2026-10-26)

**iOS**
- Channel `andoza/roomscan` lives in `ios/Runner/RoomScan/RoomScanPlugin.swift`.
- `isSupported` returns `{supported, reason}` with iOS 16 + `RoomCaptureSession.isSupported`.
- `scanRoom` presents `RoomScanViewController`: one `RoomCaptureView`, one run, then `stop()`.
- It returns `{json, usdzPath, version: "roomplan-1"}`. Cancel returns `nil`; errors are `busy` or `scan_failed`.
- Deployment target is iOS 15.0.

**Dart**
- `RoomScanService` (`lib/features/room_scan/room_scan_service.dart`) has `checkSupport()`, `scan()` and `upload(roomId, ScanResult)`.
  - `upload` posts to `POST /rooms/{id}/room-scan` with fields `usdz` and `room_json`.
- `RoomScanConverter.toRoomDraft` (`room_scan_converter.dart`):
  - maps world `(m[12], m[14])` to plane `(x, y)` in metres;
  - straightens corners to ±3° of the world axes;
  - then subtracts `origin = _minCorner(corners)` and **discards it**.
- `PendingScanStore` holds one slot.
- `handoffRoomPlan` (`lib/services/room_plan_handoff.dart`) creates one room via `roomPersistenceProvider.ensurePersisted`, which picks the newest apartment.
- `RoomScanReviewPage` uploads the scan and thumbnail, then opens `/studio/{id}?focus=1`.
- Routes `/scanning/roomplan` and `/scanning/roomplan/review` are root-navigator routes in `lib/config/router.dart`.

**Backend and web**
- Room placement in a flat is `room.state.layoutPos = {x, z}`:
  - metres, room centre (vertex mean for polygon rooms);
  - API vertex `[x, y]` maps to flat `[x, z]` with no axis flip;
  - no rotation is stored.
- `RoomCreate` has no `state`. `PATCH /rooms/{id}` replaces `state` wholesale.
- `POST /rooms/{id}/room-scan` recentres the geometry the same way the Dart converter does.
- It then calls `retire_earlier_scans(db, room, *, now=None)` in `backend/app/services/room_scan_dedupe.py`. That function soft-deletes earlier untouched LiDAR scans in the same apartment if they are within 30 min, within 15% floor area and within 0.10 m ceiling.
  - `layoutPos` counts as "untouched".

## Global Constraints

- **Multi-room availability:** offered only when `RoomCaptureSession.isSupported` (LiDAR) **and** iOS ≥ 17.0. Everywhere else the existing single-room flow is the only path, with no new UI.
- **Single-room flow:** `scanRoom` and `RoomScanReviewPage` keep their behaviour and tests unchanged.
- **Deployment target:** stays iOS 15.0. Every iOS 17 API is behind `@available(iOS 17.0, *)` / `#available`.
- **Channel contract:**
  - `scanRooms` returns `{rooms: [{json, usdzPath}], version: "roomplan-1"}`, at least 1 room;
  - cancel returns `nil`;
  - errors `busy` and `scan_failed` keep the same meaning as for `scanRoom`.
- **Layout position:** `state.layoutPos` is `{x, z}` in metres, the room centre (vertex mean), in one frame per scan session.
- **User-facing text:** Dart text goes through `AppLocalizations` (keys in `app_uz.arb` with `@key`, `app_ru.arb`, `app_en.arb`). Native button labels for `scanRooms` are passed in from Dart as method arguments.
- **Version bump:** `pubspec.yaml` `1.0.0+N`, commit as `chore: 1.0.0+N (...)`.
- **Backend change:** goes to `~/Projects/andoza_ai` through a git **worktree** (the checkout is shared) and its own PR, merged and deployed **before** the mobile release.

## Review Focus

1. **Two rooms of the same size in one session** (two equal bedrooms). Both must survive the backend's duplicate-scan cleanup. Pinned in Task 1.
2. **App goes to the background or the user cancels after rooms are done.** Background finishes with the rooms captured so far, not "cancelled". Cancel asks nothing and discards all. Pinned in Task 3 (manual check list) and Task 4 (`scanRooms` with `partial: true` still parses).
3. **`StructureBuilder` throws.** Fall back to the per-room `CapturedRoom`s, which share the world frame anyway. Still return success. Pinned in Task 3's manual list and Task 5's converter test using unmerged rooms.
4. **Only one room scanned in multi mode.** It goes through the flat review with one room, gets `layoutPos` `{x: centre, z: centre}`, and opens the Studio normally. Pinned in Task 7.
5. **A room the converter rejects** (fewer than 3 corners, invalid plan) inside a set. It is dropped with a message, and the others are kept. Pinned in Task 7.

---

### Task 1: Backend — `scan_group` exempts rooms of one session from duplicate cleanup

**Repo:** `~/Projects/andoza_ai`. Run `git worktree add -b feat/room-scan-group ~/Projects/andoza_ai_wt_scangroup origin/master`.

**Files:**
- Modify: `backend/app/routers/rooms.py`, the `POST /rooms/{room_id}/room-scan` handler (~L105-199)
- Modify: `backend/app/services/room_scan_dedupe.py` (`is_same_scan`, `retire_earlier_scans`)
- Test: `backend/tests/test_room_scan_dedupe.py`
- Docs: `docs/MOBILE_QA_HANDOFF.md` (one line under §9 or a new §10: "`scan_group` form field")

**Interfaces:**
- Produces: the multipart form field `scan_group: str | None` (≤ 64 chars) on `POST /rooms/{id}/room-scan`, stored as `room.room_scan["scan_group"]`.
- Produces: `retire_earlier_scans(db, room, *, now=None)`. Its signature is unchanged; it reads the group from `room.room_scan`.

- [ ] **Step 1: Write failing tests** in `test_room_scan_dedupe.py`:
  - `test_same_group_rooms_are_not_retired`: two untouched LiDAR rooms in one apartment, 4.0×3.0, 5 minutes apart, both with `room_scan.scan_group == "g1"`. After `retire_earlier_scans` on the second, both are still not `deleted`.
  - `test_other_group_still_retired`: the same pair with groups `"g1"` and `"g2"`. The earlier one is retired, as today.
  - `test_no_group_still_retired`: the same pair with no group on either. The earlier one is retired, as today.
- [ ] **Step 2: Run** `cd backend && pytest tests/test_room_scan_dedupe.py -v`. Expected: the first test FAILS (earlier room deleted).
- [ ] **Step 3: Implement.**
  - `is_same_scan(new, old, now)` returns `False` when both rooms carry the same non-empty `room_scan.get("scan_group")`.
  - The endpoint adds `scan_group: str | None = Form(None, max_length=64)` and writes it into the `room_scan` dict it builds.
- [ ] **Step 4: Run** the same tests plus `pytest tests/test_room_scan*.py -v`. Expected: PASS.
- [ ] **Step 5: Commit, PR, merge after CI, wait for deploy.** Check with `curl -s https://andozaai.uz/openapi.json | jq '.paths["/api/v1/rooms/{room_id}/room-scan"]'`: `scan_group` must be in the form schema.

### Task 2: Capability — `isSupported` reports `multiRoom`

**Files:**
- Modify: `ios/Runner/RoomScan/RoomScanPlugin.swift` (`isSupported`, L50-63)
- Modify: `lib/features/room_scan/room_scan_service.dart` (`ScanSupport`, `checkSupport`)
- Test: `test/features/room_scan/room_scan_service_test.dart`

**Interfaces:**
- Produces: `isSupported` → `{supported, reason, multiRoom: Bool}`. `multiRoom` is true only if supported and `#available(iOS 17.0, *)`.
- Produces: `ScanSupport({required bool supported, String? reason, bool multiRoom = false})`. A missing key reads as `false`, so old builds and the Android path still parse.

- [ ] **Step 1: Write failing tests:**
  - `checkSupport reads multiRoom`: the channel returns `{supported: true, reason: null, multiRoom: true}`, and `support.multiRoom == true`.
  - `checkSupport defaults multiRoom to false`: no `multiRoom` key gives `false`.
- [ ] **Step 2: Run** `flutter test test/features/room_scan/room_scan_service_test.dart`. Expected: FAIL.
- [ ] **Step 3: Implement** both sides.
- [ ] **Step 4: Run** the tests. Expected: PASS. Run `flutter analyze`. Expected: clean.
- [ ] **Step 5: Commit** `feat(scan): report multi-room support (iOS 17 + LiDAR)`.

### Task 3: Native — `scanRooms`, one AR session, several rooms, merged

**Files:**
- Create: `ios/Runner/RoomScan/MultiRoomScanViewController.swift`
- Modify: `ios/Runner/RoomScan/RoomScanPlugin.swift` (new `case "scanRooms"`)
- Modify: `ios/Runner.xcodeproj/project.pbxproj` (add the new file to the Runner target)

**Interfaces:**
- Consumes: the method arguments `{labels: {nextRoom, finish, cancel, roomN}}`.
  - `roomN` is a template with `{n}`, e.g. "{n}-xona". It comes from Dart (Task 8), so the strings are localized.
- Produces: `scanRooms` → `{rooms: [{json: String, usdzPath: String}], version: "roomplan-1", partial: Bool}`. Cancel returns `nil`. Errors: `busy`, `scan_failed`, and `ios_too_old` for iOS < 17.

**Design decisions:**
- **View and session.** `@available(iOS 17.0, *) final class MultiRoomScanViewController`. It owns `let arSession = ARSession()` and `RoomCaptureView(frame:, arSession:)`.
  - Each room is `captureSession.run(configuration:)`.
  - "Keyingi xona" calls `captureSession.stop(pauseARSession: false)`. The `CapturedRoom` arrives in `captureView(didPresent:)` and is appended. When it arrives, the next `run` starts.
  - "Tugatish" stops the last room with `stop()`, then merges.
- **Merge.** `let structure = try await StructureBuilder(options: [.beautifyObjects]).capturedStructure(from: rooms)`, then use `structure.rooms`.
  - If it throws, use `rooms` as captured. They already share the frame because of the single ARSession.
  - Export each room's USDZ with `.parametric` and JSON with `JSONEncoder`, exactly as `RoomScanViewController` does.
- **Background.** `didEnterBackgroundNotification` finishes with the rooms done so far (`partial: true`). With 0 rooms it cancels.
- **Cancel.** It discards all rooms and returns `nil`.
- **Chrome.** It reuses `RoomScanViewController.uzbekInstruction` for the coaching text and shows a counter label built from `roomN`.
- **Plugin routing.** It checks `#available(iOS 17.0, *)` before presenting. On iOS < 17 it returns `FlutterError(code: "ios_too_old")`.

- [ ] **Step 1: Implement** the view controller and the plugin case as above.
- [ ] **Step 2: Build** `flutter build ios --simulator --debug`. Expected: builds. The simulator has no LiDAR, so `scanRooms` is not callable there.
- [ ] **Step 3: Manual device check** on "iPhone (2)" (iPhone 15 Pro Max, iOS 27) after Task 8 wires the UI. Record the results in the PR:
  - scan 2 rooms, then "Tugatish": 2 rooms are returned;
  - scan 1 room, then "Tugatish": 1 room;
  - scan 2 rooms, then send the app to the background: `partial: true` with 2 rooms;
  - "Bekor qilish" after 1 room: `nil`.
- [ ] **Step 4: Commit** `feat(scan): native multi-room capture (iOS 17 StructureBuilder)`.

### Task 4: Dart bridge — `RoomScanService.scanRooms()`

**Files:**
- Modify: `lib/features/room_scan/room_scan_service.dart`
- Test: `test/features/room_scan/room_scan_service_test.dart`

**Interfaces:**
- Consumes: the `scanRooms` channel contract (Task 3).
- Produces: `class MultiScanResult { final List<ScanResult> rooms; final bool partial; }`.
- Produces: `Future<MultiScanResult?> scanRooms({required Map<String, String> labels})`. It returns null on cancel and throws `RoomScanException(code, message)` on platform errors, with the same mapping as `scan()`.
- Produces: `Future<Map<String, dynamic>> upload(String roomId, ScanResult scan, {String? scanGroup})`. It adds `scan_group` to `fields` when it is non-null.

- [ ] **Step 1: Write failing tests:**
  - `scanRooms parses every room`: the fixture JSON appears twice in `rooms`, giving `result.rooms.length == 2`, `partial == false` and `rooms[0].version == 'roomplan-1'`.
  - `scanRooms returns null on cancel`.
  - `scanRooms keeps partial`: `partial: true` gives `result.partial == true`.
  - `scanRooms maps busy`: it throws `RoomScanException` with `code == 'busy'`.
  - `upload sends scan_group`: the mocked `ApiClient` multipart call receives `fields['scan_group'] == 'g1'`.
  - `upload omits scan_group when null`.
- [ ] **Step 2: Run.** Expected: FAIL.
- [ ] **Step 3: Implement.**
- [ ] **Step 4: Run.** Expected: PASS.
- [ ] **Step 5: Commit** `feat(scan): scanRooms bridge and scan_group upload`.

### Task 5: Converter keeps the world origin; flat positions

**Files:**
- Modify: `lib/features/room_scan/room_scan_converter.dart` (`RoomScanDraft`, `toRoomDraft`)
- Create: `lib/features/room_scan/flat_layout.dart`
- Test: `test/features/room_scan/room_scan_converter_test.dart`, `test/features/room_scan/flat_layout_test.dart`

**Interfaces:**
- Produces: `RoomScanDraft` gains `final Vec2 worldOrigin`.
  - It is the subtracted min corner, in plane metres (world X → x, world Z → y).
  - The default `Vec2(0, 0)` keeps the existing constructors valid.
- Produces: `typedef LayoutPos = ({double x, double z});`
- Produces: `List<LayoutPos> flatLayoutPositions(List<RoomScanDraft> drafts)`.
  - For each draft: `worldOrigin + mean(plan corners)`.
  - Then shift all of them by the same amount, so that the smallest room min-corner over the set is at `(0, 0)`.
  - Result order equals input order.

- [ ] **Step 1: Write failing tests:**
  - `toRoomDraft keeps the world origin`: take the 4×3 fixture with every transform translated by world `(+10, 0, +5)` (add to `m[12]` and `m[14]`). The draft's `plan` is identical to the untranslated one, and `worldOrigin` is `(10, 5)` within 1e-6 more than the untranslated draft's `worldOrigin`.
  - `flatLayoutPositions places side-by-side rooms`:
    - draft A is 4×3 with origin `(0, 0)`; draft B is 3×3 with origin `(4.1, 0)`;
    - the result is A `(2.0, 1.5)` and B `(5.6, 1.5)`, within 1e-6.
  - `flatLayoutPositions shifts to the set's min corner`: the same pair with both origins plus `(-7, 20)` gives the same result.
  - `flatLayoutPositions single room`: one 4×3 draft gives `(2.0, 1.5)`.
- [ ] **Step 2: Run.** Expected: FAIL.
- [ ] **Step 3: Implement.** In `toRoomDraft`, return the existing `origin` as `worldOrigin`.
- [ ] **Step 4: Run** these and the whole `test/features/room_scan/` folder. Expected: PASS. The existing converter tests must be unchanged.
- [ ] **Step 5: Commit** `feat(scan): keep the scan's world origin and derive flat positions`.

### Task 6: Pending store for a multi-room scan

**Files:**
- Modify: `lib/features/room_scan/pending_scan_store.dart`
- Test: `test/features/room_scan/pending_scan_store_test.dart` (new; uses `SharedPreferences.setMockInitialValues` and a temp `Documents` override)

**Interfaces:**
- Produces:
  - `static Future<void> saveFlat(MultiScanResult)`: USDZs go to `Documents/pending_flat_<i>.usdz`; the prefs key `pending_flat_json` holds a JSON list of raw room JSON strings.
  - `static Future<bool> hasPendingFlat()`
  - `static Future<({List<RoomScanDraft> drafts, List<ScanResult> scans})?> loadFlat()`. Rooms the converter rejects are dropped.
  - `static Future<void> clearFlat()`
- The single-slot API is unchanged.

- [ ] **Step 1: Write failing tests:**
  - save two rooms, then load: you get 2 drafts and 2 scans, and `hasPendingFlat()` is true;
  - after `clearFlat()`, `hasPendingFlat()` is false and the usdz files are gone;
  - a saved set with one invalid room loads with 1 draft.
- [ ] **Step 2: Run.** Expected: FAIL.
- [ ] **Step 3: Implement.** Make the documents directory injectable for tests in the same way the file already uses `path_provider`. If it has no seam, add `@visibleForTesting static Future<Directory> Function() documentsDir`.
- [ ] **Step 4: Run.** Expected: PASS.
- [ ] **Step 5: Commit** `feat(scan): keep an unfinished multi-room scan`.

### Task 7: Hand-off — create the rooms in one apartment with positions

**Files:**
- Create: `lib/services/flat_scan_handoff.dart`
- Test: `test/widget/flat_scan_handoff_test.dart` (same fakes style as `test/widget/room_plan_handoff_test.dart`)

**Interfaces:**
- Consumes: `flatLayoutPositions` (Task 5), `roomPlanToPolygonRoomCreate` (`lib/utils/room_geometry_mapper.dart`), `ApartmentRepository.createRoom` and `ApartmentRepository.updateRoom(roomId, {state})`, and `roomPersistenceProvider`'s apartment choice.
- Produces: `Future<List<String>> handoffScannedFlat(WidgetRef ref, List<RoomScanDraft> drafts, {required List<String> names, required List<double> ceilings})`.
  - It returns the backend room ids in input order.
  - The first room goes through `handoffRoomPlan`, which picks or creates the apartment exactly as single-room does.
  - The remaining rooms use `createRoom(<that apartment id>, ...)`.
  - It then calls `updateRoom(id, state: {'layoutPos': {'x': .., 'z': ..}})` for every room.

- [ ] **Step 1: Write failing tests:**
  - `creates every room in the same apartment`: 2 drafts give 2 `createRoom` calls with one apartment id.
  - `writes layoutPos`: the fixture pair from Task 5 gives `updateRoom` state `{'layoutPos': {'x': 2.0, 'z': 1.5}}` and `{'layoutPos': {'x': 5.6, 'z': 1.5}}`.
  - `one room still gets a layoutPos`.
  - `a failed createRoom for room 2`: it throws after room 1 is created, and room 1's id is still returned through the exception's `createdIds`. This is a `FlatHandoffException(List<String> createdIds, Object cause)`.
- [ ] **Step 2: Run.** Expected: FAIL.
- [ ] **Step 3: Implement.** To reach the apartment id after the first room, read `roomPersistenceProvider`'s persisted `room.apartmentId`.
- [ ] **Step 4: Run.** Expected: PASS.
- [ ] **Step 5: Commit** `feat(scan): create a scanned flat's rooms with their positions`.

### Task 8: UI — choice, flat review, resume, l10n

**Files:**
- Modify: `lib/screens/scanning/room_scan_screen.dart` (`_start`, `_scan`)
- Create: `lib/screens/scanning/flat_scan_review_page.dart`
- Modify: `lib/config/router.dart` (new root-navigator route `/scanning/roomplan/review-flat`, `extra: FlatScanReviewArgs`)
- Modify: `lib/screens/app_shell.dart` (`_offerPendingScan`: also offer `hasPendingFlat`)
- Modify: `lib/l10n/app_uz.arb`, `app_ru.arb`, `app_en.arb`, then `flutter gen-l10n` and `dart format lib/l10n/app_localizations*.dart`
- Test: `test/widget/room_scan_choice_test.dart`, `test/widget/flat_scan_review_test.dart`

**Interfaces:**
- Consumes: Tasks 2, 4, 5, 6, 7. `renderRoomScanThumbnailPng` and `RoomScanPainter` come from `room_scan_review_page.dart`.
- Produces: `class FlatScanReviewArgs { final List<RoomScanDraft> drafts; final List<ScanResult> scans; }` and `class FlatScanReviewPage`.
- New l10n keys, with uz values (ru and en translated):

  | Key | uz |
  |---|---|
  | `scanChoiceTitle` | "Nimani skanerlaymiz?" |
  | `scanChoiceOneRoom` | "Bitta xona" |
  | `scanChoiceFlat` | "Bir nechta xona (kvartira)" |
  | `scanChoiceFlatHint` | "Xonalarni ketma-ket skanerlang — ular rejada o'z joyiga tushadi" |
  | `scanNextRoom` | "Keyingi xona" |
  | `scanFinish` | "Tugatish" |
  | `scanRoomN` | "{n}-xona" |
  | `flatReviewTitle` | "Skanerlangan xonalar" |
  | `flatReviewRoomName` | "Xona nomi" |
  | `flatReviewContinue` | "Studiyada ochish" |
  | `flatReviewPartial` | "Skaner to'xtadi — {n} ta xona saqlandi" |
  | `flatReviewDropped` | "{n} ta xona o'qilmadi va qo'shilmadi" |

- **Behaviour.**
  - If `support.multiRoom == false`, `_start` goes straight to `_scan` as today, with no choice shown.
  - If it is true, a bottom sheet offers the two options. "Bitta xona" leads to `_scan`. "Bir nechta xona" leads to `svc.scanRooms(labels: ...)`, then `toRoomDraft` per room (rejected rooms are dropped and counted), then `PendingScanStore.saveFlat`, then `pushReplacement('/scanning/roomplan/review-flat', extra: ...)`.
- **The review page shows:**
  - one canvas with every room at its `flatLayoutPositions` place (`RoomScanPainter` per room, offset);
  - a name field per room, defaulting to `scanRoomN`;
  - one ceiling per room, from the draft;
  - the `flatReviewPartial` and `flatReviewDropped` notices when they apply.
- **"Studiyada ochish":**
  1. `handoffScannedFlat`;
  2. `clearFlat`;
  3. for each room, `upload(roomId, scan, scanGroup: <one uuid v4 per session>)` and the thumbnail, best-effort, with a snackbar on error, as in the single page;
  4. `pushReplacement('/studio/<first id>')` without `focus`, so the Studio shows the whole flat.

- [ ] **Step 1: Write failing widget tests:**
  - `no choice when multiRoom is false`: a fake service with `ScanSupport(supported: true, multiRoom: false)` gives no `scanChoiceTitle`, and `scan()` is called once.
  - `choice shown when multiRoom is true`: both options are visible. Tapping "Bitta xona" calls `scan()`; tapping "Bir nechta xona" calls `scanRooms`.
  - `flat review lists every room and opens the studio on the first`: with 2 drafts, there are 2 name fields. Tapping continue calls the fake `handoffScannedFlat` once, uploads twice with the same non-null `scanGroup`, and the router lands on `/studio/r1` without `focus`.
  - `flat review shows the partial and dropped notices`.
- [ ] **Step 2: Run.** Expected: FAIL.
- [ ] **Step 3: Implement.** The page follows `RoomScanReviewPage`'s structure.
- [ ] **Step 4: Run** `flutter test`. Expected: all pass. Run `flutter analyze`. Expected: clean.
- [ ] **Step 5: Commit** `feat(scan): choose single or multi-room scan, review a scanned flat`.

### Task 9: Docs, version, device check

**Files:**
- Modify: `docs/ARCHITECTURE.md`, the "LiDAR skaner (iOS RoomPlan)" section: `scanRooms`, `multiRoom`, the flat review route, `layoutPos`, `scan_group`
- Modify: `docs/API.md` (`room-scan` field `scan_group`)
- Modify: `pubspec.yaml` (`1.0.0+N+1`)

- [ ] **Step 1: Update docs and bump the version.**
- [ ] **Step 2: Device run:**
  - `flutter build ios --release` with the `andozaai.uz` defines;
  - `xcrun devicectl device install app --device 00008130-001830540ED2001C build/ios/iphoneos/Runner.app`;
  - run Task 3's four manual checks;
  - then open the flat in the Studio: both rooms are visible, side by side, without overlapping, and the shared wall lines up within about 10 cm.
- [ ] **Step 3: Check the simulator** (no LiDAR): the scan screen shows the unsupported sheet as today, with no choice.
- [ ] **Step 4: Commit** `chore: 1.0.0+N (multi-room LiDAR scan)`, then push and open the PR. Its description includes the device results.
