# ARCore eshik va derazalar (B bosqich) — amalga oshirish rejasi

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Android ARCore skanerida balandlikdan keyin eshik/derazalarni devor tagidagi ikki chet bilan belgilash va ko'rib chiqish ekranida (iOS + Android) ularni tahrirlash/qo'shish/o'chirish.

**Architecture:** Kotlin `OpeningCapture` har opening'ni xom kontur qirrasi indeksi + ulush (`edge, t0, t1`) sifatida yozadi va natijaga `openings` qo'shadi. Dart `buildArcorePlan` cho'qqilarning xom indekslarini merge/collinear bosqichlaridan o'tkazib, har opening'ni yakuniy devorga masshtab bilan joylaydi. Ko'rib chiqish ekrani rejaning nusxasini state'da saqlab, `DoorWindowModal` orqali tahrirlaydi.

**Tech Stack:** Kotlin (ARCore, JUnit4 JVM testlar), Flutter/Dart (Riverpod, gen-l10n), mavjud `andoza/arscan` MethodChannel.

**Spec:** `docs/superpowers/specs/2026-11-02-arcore-openings-design.md`

## Global Constraints

- Branch `feat/arcore-openings` (`feat/arcore-auto-walls` ustida), worktree `/Users/mac/Projects/andoza_ai_mobile_openings`.
- Foydalanuvchi matni faqat `AppLocalizations` orqali; kalit `app_uz.arb` (`@key` tavsifi bilan), `app_ru.arb`, `app_en.arb` uchalasiga birga; keyin `flutter gen-l10n`. Kotlin matnni `s("key")` orqali `ar_scan_screen.dart`dagi `_strings` xaritasidan oladi.
- Yopishish ≤ **0.30 m**; eng tor opening **0.30 m**; standart: eshik **2.00 m**, sill **0**; deraza **1.50 m**, sill **0.90 m**; shiftga sig'dirish: `shift − 0.10`.
- `RoomOpening.position` = **markaz** ulushi (0..1); chap chet ↔ markaz faqat `lib/utils/opening_position.dart` orqali.
- Qiymatlar 1 sm gacha yaxlitlanadi (`_cm`).
- Kanal format: eski natija (`openings` yo'q) ham ishlashi kerak.
- Commit xabarlari `feat(arscan): …` / `feat(scan-review): …` uslubida, oxirida `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- Kotlin testlari: `cd android && ./gradlew :app:testReleaseUnitTest --tests '*arscan*'` (debug varianti offline kesh yo'qligi sabab ishlamaydi); natija `build/app/test-results/testReleaseUnitTest/`.

## Review Focus

1. **Yopilgan konturning oxirgi qirrasi** (oxirgi burchakdan birinchiga qaytadigan devor) ga qo'yilgan eshik — Kotlin va Dart bir xil qirra indeksini ishlatishi kerak (yopuvchi tap tashlanadi). Test: Task 1 va Task 3.
2. **Yopilmagan kontur** ("Tayyor" bilan ≥3 burchakda balandlikka o'tilgan): qirralar `i → (i+1) % n`. Test: Task 1 va Task 3.
3. **Burchakka taqalgan opening** (`t0 = 0` yoki `t1 = 1`) — to'g'rilashdan keyin devordan chiqmasligi, manfiy chap chet bo'lmasligi. Test: Task 3.
4. **Ko'rib chiqish ekranida tahrirdan keyin "Davom etish"** — `_continue` rejani qayta yasaganda tahrirlangan openings yo'qolmasligi (hozir `_plan.walls`ni widget'dan oladi). Test: Task 5.
5. **Opening qadamida bo'sh holatda "Bekor qilish"** — balandlik qadamiga qaytadi, burchaklarga o'tib ketmaydi; opening bor paytda burchaklar o'zgarmaydi. Test: Task 1 (`undo` qaytaradigan qiymat) + Task 2 qo'lda tekshiruv.

---

### Task 1: Kotlin `OpeningCapture`

**Files:**
- Create: `android/app/src/main/kotlin/com/tamir_uy/tamir_uy_mobile_flutter/arscan/OpeningCapture.kt`
- Modify: `android/app/src/main/kotlin/com/tamir_uy/tamir_uy_mobile_flutter/arscan/FloorPlanCapture.kt` (`toResult`)
- Test: `android/app/src/test/kotlin/com/tamir_uy/tamir_uy_mobile_flutter/arscan/OpeningCaptureTest.kt`, `FloorPlanCaptureTest.kt`

**Interfaces:**
- Produces:
  - `enum class OpeningType(val wire: String) { DOOR("door"), WINDOW("window") }`
  - `data class EdgeHit(val edge: Int, val t: Float, val distance: Float, val x: Float, val z: Float)` — `x,z` = qirradagi yopishgan nuqta (chizish uchun).
  - `data class CapturedOpening(val type: OpeningType, val edge: Int, val t0: Float, val t1: Float)` (`t0 < t1`).
  - `enum class OpeningAddResult { PENDING, ADDED, REJECTED_OTHER_WALL, REJECTED_TOO_NARROW, REJECTED_OVERLAP }`
  - `class OpeningCapture(val snapM: Float = 0.30f, val minWidthM: Float = 0.30f)` with
    - `fun loop(corners: List<Vec3>, closed: Boolean): List<Vec3>` — yopilgan bo'lsa oxirgi nuqtasiz; qirra `i` = `loop[i] → loop[(i+1) % size]`.
    - `fun snap(p: Vec3, loop: List<Vec3>): EdgeHit?` — eng yaqin qirra, `t` 0..1 ga qisiladi, masofa > `snapM` → `null`.
    - `fun addEdge(hit: EdgeHit, type: OpeningType, loop: List<Vec3>): OpeningAddResult`
    - `val pending: EdgeHit?`, `val openings: List<CapturedOpening>`
    - `fun undo(): Boolean` — avval `pending`, keyin oxirgi opening; ikkalasi ham yo'q → `false`.
    - `fun widthM(o: CapturedOpening, loop: List<Vec3>): Float`
  - `FloorPlanCapture.toResult(height, heightMeasured, durationSec, openings: List<CapturedOpening> = emptyList())` — `"openings"` kaliti: `[{"type": "door", "edge": 0, "t0": 0.25, "t1": 0.5}]` (`List<Map<String, Any>>`, son `Double`).

- [ ] **Step 1: Write the failing tests** (`OpeningCaptureTest`, kvadrat kontur 4×3 m: `(0,0),(4,0),(4,3),(0,3)` Y=0)
  - `snapsToNearestEdgeWithin30cm`: `snap((2, 0, 0.25))` → `edge 0, t 0.5`; `snap((2, 0, 0.35))` → `null`.
  - `clampsTAtCorners`: `snap((-0.1, 0, 0.05))` → `edge 0, t 0f`.
  - `twoEdgesMakeSortedOpening`: `addEdge(t=0.5)` → `PENDING`, `addEdge(t=0.25)` → `ADDED`; `openings[0] == CapturedOpening(DOOR, 0, 0.25f, 0.5f)`; `widthM == 1.0f`.
  - `rejectsOtherWall`: chetlar 0- va 1-qirrada → `REJECTED_OTHER_WALL`, `pending == null`, `openings` bo'sh.
  - `rejectsTooNarrow`: 4 m qirrada `t` 0.50 va 0.57 (0.28 m) → `REJECTED_TOO_NARROW`.
  - `rejectsOverlap`: `[0.25,0.5]` bor, `[0.4,0.7]` → `REJECTED_OVERLAP`; `[0.5,0.7]` (faqat tegadi) → `ADDED`.
  - `closedLoopDropsClosingTap`: `loop(corners + (0.05,0,0.02), closed = true).size == 4`; yopuvchi qirra `(0,3) → (0,0)` bo'ylab `snap((0.1,0,1.5))` → `edge 3, t 0.5`.
  - `openLoopWrapsLastEdge`: `closed = false`, xuddi shu `snap((0.1,0,1.5))` → `edge 3`.
  - `undoOrder`: pending bor → `undo()` uni o'chiradi (`openings` o'zgarmaydi); keyin oxirgi opening; bo'sh → `false`.
- [ ] **Step 2:** `FloorPlanCaptureTest`ga `toResultIncludesOpenings` (yuqoridagi xarita shakli) va `toResultWithoutOpeningsHasEmptyList` qo'shing.
- [ ] **Step 3: Run** `cd android && ./gradlew :app:testReleaseUnitTest --tests '*arscan*'` → kompilyatsiya xatosi (sinf yo'q).
- [ ] **Step 4: Implement** `OpeningCapture.kt` (ARCore import'siz; overlap: shu `edge`dagi `(t0 < o.t1 && o.t0 < t1)`; eni = `(t1−t0) × qirra uzunligi` XZ tekisligida) va `toResult` parametri.
- [ ] **Step 5: Run** shu buyruq → `OpeningCaptureTest`, `FloorPlanCaptureTest`, `WallTrackerTest`, `DwellDetectorTest` — failures="0".
- [ ] **Step 6: Commit** `feat(arscan): capture doors and windows as two edges on a wall`

### Task 2: Kotlin skanerda `OPENINGS` qadami + matnlar

**Files:**
- Modify: `android/app/src/main/kotlin/com/tamir_uy/tamir_uy_mobile_flutter/arscan/ArScanActivity.kt` (`Step`, `render`/hint, `onMain`, `onLeft`, `onRight`, `finishWith`, fallback matnlar)
- Modify: `android/app/src/main/kotlin/com/tamir_uy/tamir_uy_mobile_flutter/arscan/ArRenderer.kt` (`OverlayState`, `ArOverlayView.onDraw`)
- Modify: `lib/screens/scanning/ar_scan_screen.dart` (`_strings`), `lib/l10n/app_uz.arb`, `app_ru.arb`, `app_en.arb`
- Test: `test/features/ar_scan/ar_scan_screen_test.dart`

**Interfaces:**
- Consumes: Task 1 `OpeningCapture`, `OpeningType`, `OpeningAddResult`, `toResult(..., openings)`.
- Produces: kanal natijasida `openings` (Task 3 o'qiydi). Yangi l10n kalitlari (aynan shu nomlar): `arScanStepOpenings`, `arScanOpeningsHint`, `arScanAddEdge`, `arScanDone`, `arScanDoor`, `arScanWindow`, `arScanOpeningOtherWall`, `arScanOpeningTooNarrow`, `arScanOpeningOverlap`, `arScanAimWallBase`.

Matn (uz): qadam "Eshik va derazalar"; ko'rsatma "Eshik yoki derazaning chap va o'ng cheti tagiga nishonni qo'yib, «Chet qo'shish»ni bosing"; "Chet qo'shish"; "Tayyor"; "Eshik"; "Deraza"; "Ikkala chet bitta devorda bo'lsin"; "Juda tor — chetlarni qayta belgilang"; "Bu joyda allaqachon eshik yoki deraza bor"; "Nishonni devor tagiga olib boring". ru/en — ma'nosi bir xil tarjima.

- [ ] **Step 1: Write the failing test** `ar_scan_screen_test.dart`: `scanFloorPlan` ga yuborilgan `strings` xaritasida yuqoridagi 10 kalit bor va bo'sh emas (mavjud fake service orqali argumentni ushlang).
- [ ] **Step 2: Run** `flutter test test/features/ar_scan/ar_scan_screen_test.dart` → FAIL.
- [ ] **Step 3:** arb'larga kalitlarni qo'shing, `flutter gen-l10n`, `_strings`ga qo'shing. Run → PASS.
- [ ] **Step 4: Activity.** `Step` ga `OPENINGS`; o'zgarishlar:
  - `Step.HEIGHT` dagi asosiy tugma va qo'lda balandlik tanlash endi `finishWith` emas, `height` ni saqlab `step = OPENINGS` qiladi (`chosenHeight: Float`, `heightMeasured: Boolean` maydonlari).
  - `OPENINGS`: chap tugma "Bekor qilish" → `openings.undo()`, `false` bo'lsa `step = HEIGHT`; asosiy tugma "Chet qo'shish" → har kadrdagi `EdgeHit` bilan `addEdge`; rad natijalari 2 s hint (`NOTICE_MS` mexanizmi); o'ng tugma "Tayyor" → `finishWith(chosenHeight, heightMeasured)`.
  - Tur tanlagich: hint ustidagi ikki `ToggleButton`/`Button` ("Eshik"/"Deraza"), standart Eshik.
  - Har kadr: `lastFloorHit` nuqtasidan `snap(...)`; null bo'lsa asosiy tugma o'chiq va hint `arScanAimWallBase`. Dwell va avtomatik burchak bu qadamda chaqirilmaydi.
  - `finishWith`: JSON'ga `openings` massivi (`type, edge, t0, t1`) qo'shiladi.
- [ ] **Step 5: Overlay.** `OverlayState` ga `openings: List<Triple<Pair<Float,Float>, Pair<Float,Float>, Boolean>>` (ekran nuqtalari, `true` = deraza) va `pendingEdge: Pair<Float,Float>?`; eshik yashil `Color.rgb(34,197,94)`, deraza ko'k `Color.rgb(59,130,246)`, 6dp qalin chiziq; `pendingEdge` dan nishongacha jonli chiziq va eni `ArOverlayView.metres(...)`. Nishon `EdgeHit.x,z` ga chiziladi (`reticleAt`).
- [ ] **Step 6: Build** `cd android && ./gradlew :app:compileReleaseKotlin` → BUILD SUCCESSFUL; Kotlin testlari yana o'tadi.
- [ ] **Step 7: Commit** `feat(arscan): doors and windows step after the ceiling height`

### Task 3: Dart — openings'ni yakuniy devorlarga joylash

**Files:**
- Modify: `lib/geometry/room_geometry.dart` (indeks variantlari)
- Modify: `lib/features/ar_scan/arcore_plan.dart`
- Test: `test/features/ar_scan/arcore_plan_test.dart`, `test/geometry/` dagi mavjud geometriya testi (agar `mergeCloseVertices` testi bo'lsa — o'zgarmasdan o'tishi kerak)

**Interfaces:**
- Produces:
  - `List<int> mergeCloseVertexIndices(List<Vec2> poly, [double minDist])` va `List<int> collinearKeepIndices(List<Vec2> poly, [double tolDeg])` — qoldirilgan cho'qqilar indekslari; `mergeCloseVertices`/`removeCollinearVertices` endi shular ustidagi o'ram (xatti-harakat o'zgarmaydi).
  - `class ArRawOpening { final String type; final int edge; final double t0, t1; }` + `ArScanRaw.openings` (`fromMap`da yo'q → `const []`).
  - `buildArcorePlan` imzosi o'zgarmaydi; `RoomWall.openings` endi to'ladi.

Algoritm (signatura belgilamaydigan qism):
1. `pts` = closure tarqatilgandan keyingi xom halqa (Kotlin `loop` bilan bir xil indekslar); `org = [0..n-1]`.
2. `mergeCloseVertexIndices` → `org` ni shu indekslar bilan filtrlang; `_square` 1:1; `collinearKeepIndices` → yana filtrlang.
3. Yakuniy devor `j` = xom qirralar `org[j], org[j]+1, …, org[j+1]−1` (siklik, `n` bo'yicha).
4. Opening (`edge, t0, t1`): `edge` ni o'z ichiga olgan `j`; `startRaw` = oraliqda `edge` dan oldingi xom qirralar uzunligi yig'indisi; `k = finalLen_j / rawSum_j`; `left = (startRaw + t0·rawLen_edge)·k`, `width = (t1−t0)·rawLen_edge·k`; `width = min(width, finalLen)`, `left = left.clamp(0, finalLen − width)`; `position = (left + width/2) / finalLen`.
5. Bo'yi/sill: Global Constraints standartlari; `raw.heightMeasured` bo'lsa eshik `height = min(2.0, raw.height − 0.10)`, deraza `height = min(1.5, raw.height − 0.10 − 0.9)`.

- [ ] **Step 1: Write the failing tests** (`arcore_plan_test.dart`):
  - `rawWithoutOpeningsParsesEmpty`: eski xarita → `openings` bo'sh, reja avvalgidek.
  - `doorOnRectangleWall`: 4×3 to'rtburchak, `door edge 0, t 0.25..0.5` → devor 0 da 1 ta `RoomOpening('door', width 1.00, height 2.00, position 0.375, sill 0)`.
  - `windowDefaults`: `window` → `height 1.50, sillHeight 0.90`.
  - `closingEdgeOpening` (Review Focus 1): yopilgan, closure xatoli (oxirgi nuqta `(0.05, 0.03)`) halqa, `edge 3, t 0.4..0.6` → yakuniy devor `(0,3)→(0,0)` ustida, markaz ±0.01.
  - `openLoopOpening` (Review Focus 2): `closed=false`, `edge 3` → o'sha devor.
  - `collinearMergedWall`: 5 burchakli (bir devor o'rtasida ortiqcha nuqta) halqa; ikkinchi yarmidagi eshik birlashgan devorda `position` to'g'ri (±0.01).
  - `cornerFlushOpeningStaysOnWall` (Review Focus 3): `t0 = 0` → `position − width/2/len >= 0`; `t1 = 1` → `position + width/2/len <= 1`.
  - `lowCeilingShrinksDefaults`: `heightMeasured, height 2.05` → eshik `1.95`, deraza `1.05`.
- [ ] **Step 2: Run** `flutter test test/features/ar_scan/arcore_plan_test.dart` → FAIL.
- [ ] **Step 3: Implement** geometriya indeks funksiyalari va `arcore_plan.dart` o'zgarishlari.
- [ ] **Step 4: Run** `flutter test test/features/ar_scan test/geometry` → PASS (eski testlar ham).
- [ ] **Step 5: Commit** `feat(arscan): place scanned doors and windows on the squared walls`

### Task 4: `DoorWindowModal` tahrir rejimi

**Files:**
- Modify: `lib/screens/room_setup/door_window_modal.dart`, uch arb
- Test: `test/widget/door_window_modal_test.dart` (yangi)

**Interfaces:**
- Produces:
  - `class DoorWindowInitial { final OpeningType type; final double width, height, offset, sill; }`
  - `DoorWindowModal({required onAdd, DoorWindowInitial? initial, bool showSill = false, double? maxOffset, VoidCallback? onDelete})`
  - `onAdd` endi `(OpeningType type, double width, double height, double offset, double sill)` — beshinchi parametr `sill` (`showSill == false` yoki eshik bo'lsa `initial?.sill ?? 0`); `room_wizard_screen.dart` chaqiruvi uni e'tiborsiz qoldiradi, ustaning xatti-harakati o'zgarmaydi.
  - l10n: `openingSill` ("Deraza tagi"), `openingSave` ("Saqlash"), `openingDelete` ("O'chirish").
- [ ] **Step 1: Write the failing tests:** `initial` berilsa tur/eni/bo'yi/offset oldindan tanlangan va tugma `openingSave`; `showSill` + deraza → sill maydoni bor, eshikda yo'q; `onDelete` berilsa "O'chirish" bor va chaqiriladi; `initial` siz — eski ko'rinish (tugma matni o'zgarmagan, sill yo'q).
- [ ] **Step 2: Run** `flutter test test/widget/door_window_modal_test.dart` → FAIL.
- [ ] **Step 3: Implement**; `room_wizard_screen.dart` dagi `onAdd` lambda'ga beshinchi parametr.
- [ ] **Step 4: Run** shu test + `flutter test test/widget` → PASS.
- [ ] **Step 5: Commit** `feat(room-setup): door/window sheet can edit an existing opening`

### Task 5: Ko'rib chiqish ekranida eshik/derazalar ro'yxati

**Files:**
- Modify: `lib/screens/scanning/room_scan_review_page.dart`, uch arb
- Create: `lib/screens/scanning/scan_openings_editor.dart` (ro'yxat + devor tanlash; sahifa faylini kattalashtirmaslik uchun)
- Test: `test/widget/room_scan_review_openings_test.dart` (yangi; `test/widget/room_scan_review_upload_test.dart` dagi fake'lardan foydalaning)

**Interfaces:**
- Consumes: Task 4 `DoorWindowModal`, `DoorWindowInitial`; `opening_position.dart` (`centreFractionToLeftEdgeM`, `leftEdgeToCentreFraction`).
- Produces:
  - `class ScanOpeningsEditor extends StatelessWidget { final RoomPlan plan; final ValueChanged<RoomPlan> onChanged; }`
  - `RoomPlan withWallOpenings(RoomPlan plan, int wall, List<RoomOpening> openings)` (shu faylda, top-level, test qilinadi).
  - Sahifada `late RoomPlan _plan` state (initState'da `widget.args.draft.plan`); `_continue` va chizma shu state'ni ishlatadi.
  - l10n: `scanReviewOpeningsTitle` ("Eshik va derazalar"), `scanReviewOpeningAdd` ("+ Qo'shish"), `scanReviewPickWall` ("Qaysi devorga?"), `scanReviewWallName` ("{name}-devor"), `scanReviewOpeningsEmpty` ("Hali eshik yoki deraza yo'q").
- Devor nomi: indeks → `A, B, C…` (`String.fromCharCode(65 + i)`; 26 dan ko'p bo'lsa `A1…`).
- Tur xaritasi: `OpeningType.dual` ↔ `'window'`, qolganlari `'door'` (ustadagidek).

- [ ] **Step 1: Write the failing tests:**
  - `listsOpeningsWithWallAndSize`: 1 eshik A-devorda → qator "A-devor", "1.00 × 2.00".
  - `editChangesWidth`: qatorni bosish → modal → eni 0.9 → Saqlash → qator "0.90 × 2.00", `ScanDetectionSummary` soni o'zgarmaydi.
  - `deleteRemoves`: O'chirish → ro'yxat bo'sh, eshik soni 0.
  - `addOnPickedWall`: + Qo'shish → "B-devor" → deraza → B-devorda paydo bo'ladi, sill 0.90.
  - `continueKeepsEditedOpenings` (Review Focus 4): tahrirdan keyin "Davom etish" → `handoffRoomPlan` ga ketgan rejada tahrirlangan opening bor (mavjud upload testidagi fake handoff bilan).
  - `withWallOpenings` unit: boshqa devorlar va `corners/ceiling/source/name` o'zgarmaydi.
- [ ] **Step 2: Run** `flutter test test/widget/room_scan_review_openings_test.dart` → FAIL.
- [ ] **Step 3: Implement** editor, state'ga o'tkazish, arb + `flutter gen-l10n`.
- [ ] **Step 4: Run** `flutter test test/widget` → PASS (eski review testlari ham).
- [ ] **Step 5: Commit** `feat(scan-review): edit, add and remove doors and windows before saving`

### Task 6: Hujjatlar va to'liq tekshiruv

**Files:**
- Modify: `docs/ARCHITECTURE.md` (LiDAR/ARCore oqimi bo'limi: `OPENINGS` qadami, `openings` kanal maydoni, ko'rib chiqish ekranida tahrir)

- [ ] **Step 1:** ARCHITECTURE.md ni yangilang (3–6 qator, mavjud uslubda).
- [ ] **Step 2: Run** `flutter analyze` → "No issues found!"; `flutter test` → "All tests passed!"; Kotlin testlari failures="0".
- [ ] **Step 3: Build** `flutter build apk --release --dart-define=API_URL=https://andozaai.uz/api/v1 --dart-define=API_BASE_URL=https://andozaai.uz --dart-define=STUDIO_BASE_URL=https://andozaai.uz` → APK yig'iladi.
- [ ] **Step 4: Commit** `docs: doors and windows in the Android scanner`
- [ ] **Step 5:** Telefon sinovi (foydalanuvchi bilan): haqiqiy xonada 1 eshik + 1 deraza; ruletka bilan markaz ≤ 10 sm, eni ≤ 5 sm; Review Focus 5 (bo'sh holatda Bekor qilish → balandlik).
