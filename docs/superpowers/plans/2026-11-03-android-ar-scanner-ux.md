# Android AR skaner: qulay oqim — amalga oshirish rejasi

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Android ARCore skanerini namunadagidek oqimga o'tkazish: pol → bazaviy nuqta → balandlik → 3D devorlar → yakun.

**Architecture:** Mantiq ARCore turlarisiz, toza Kotlin bo'laklarida yoziladi va JVM'da test qilinadi: `FloorPlanCapture`, `FloorRay`, `WallGeometry`, `ScanFlow`. `ArScanActivity` faqat ARCore sessiyasi va anchorlarni yuritadi, `ArOverlayView` esa tayyor ekran ko'pburchaklarini Canvas'ga chizadi. Flutter'ga qaytadigan JSON o'zgarmaydi.

**Tech Stack:** Kotlin, ARCore (`com.google.ar.core`), Android Canvas/GLES20, JUnit 4; Flutter (gen-l10n, widget test).

**Spec:** `docs/superpowers/specs/2026-11-03-android-ar-scanner-ux-design.md`

## Global Constraints

- Kotlin paketi: `com.tamir_uy.tamir_uy_mobile_flutter.arscan`. Kod `android/app/src/main/kotlin/com/tamir_uy/tamir_uy_mobile_flutter/arscan/` da, testlar `android/app/src/test/kotlin/com/tamir_uy/tamir_uy_mobile_flutter/arscan/` da.
- JVM testlardagi kod `android.*` ni ishlatmaydi, `android.opengl.Matrix` ham bundan mustasno emas: unit testlarda u stub. Matritsa ko'paytmasi qo'lda yoziladi (column-major, OpenGL tartibi).
- Natija JSON kalitlari o'zgarmaydi: `corners`, `height`, `heightMeasured`, `closed`, `trackingLossCount`, `durationSec`. `lib/features/ar_scan/arcore_plan.dart`, `RoomScanReviewPage` va handoff'ga tegilmaydi.
- Ip qoidasi: ARCore, `FloorPlanCapture` va `ScanFlow` GL ipida yashaydi. UI'dan GL ipiga `surface.queueEvent` (hozirgi `onGl`), GL ipidan UI'ga `runOnUiThread` orqali o'tiladi.
- Raqamlar: snap 0.20 m (`snapDistanceM`), balandlik 1.8–4.5 m (`MIN_HEIGHT_M`/`MAX_HEIGHT_M`), chiplar 2.5 / 2.7 / 2.8 / 3.0 m, nur chegarasi 8 m, pol bo'lagi tolerantligi ±0.25 m, to'r qadami 0.5 m, nishon radiusi 0.15 m, near plane 0.05 m, takroriy bosish chegarasi 0.05 m.
- Ranglar: devor to'ldirish `argb(70, 110, 100, 230)`, devor qirrasi oq 3dp, to'r `argb(60, 255, 255, 255)`, uzunlik chipi oq fon + matn `rgb(64, 56, 160)`, ellips to'ldirish `argb(150, 110, 100, 230)` + oq qirra, asosiy tugma `rgb(64, 56, 160)`.
- Uzunlik yorlig'i: `"${round(m*100)} ${unitCm}"`. Yakun: perimetr `%.1f`, maydon `%.1f`, hajm `%.1f`, hammasi `Locale.US` da. Birliklar `unitM`, `unitM²`, `unitM³`.
- Foydalanuvchiga ko'rinadigan har bir matn `app_uz.arb` (`@key` tavsifi bilan), `app_ru.arb` va `app_en.arb` ga birga qo'shiladi. Native'ga `EXTRA_STRINGS` orqali uzatiladi.
- Versiya: `pubspec.yaml` `1.0.0+28` → `1.0.0+29`, commit `chore: 1.0.0+29 (clearer Android AR scanner)`.
- Har commit oxirida: `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.

## Review Focus

1. **Stol yoki divan ustiga qaratilgan nishon.** Nishon ostida pol emas, undan baland gorizontal tekislik bo'lsa, burchak o'sha tekislikka emas, pol tekisligiga (nur orqali) tushishi kerak. Test: Task 2, `pick ignores a table top`.
2. **Telefon devor ichida yoki devor kamera ortida.** Foydalanuvchi aylanganda kamera orqasidagi devor ekranni kesib o'tadigan cheksiz chiziq bo'lib chiqmasligi kerak. Test: Task 3, `wall through the camera is clipped to the near plane` va `wall behind the camera is null`.
3. **"Burchak qo'shish" ikki marta tez bosilsa.** Bir joyda ikkita burchak paydo bo'lmasligi kerak. Test: Task 1, `rejects a corner within 5 cm of the last`.
4. **Balandlik o'lchanmagan paytda yoki 1.8–4.5 m dan tashqarida tasdiqlansa.** Tugma o'chiq turadi, `confirmHeight` rad etadi. Test: Task 4, `height outside 1_8 to 4_5 m is refused`.
5. **Anchorlar yo'qolsa (kuzatuv uzildi), yakun yoki devorlar qadamida.** `DONE` holati `WALLS` ga, baza ham yo'qolsa `BASE` ga qaytadi. Test: Task 4, `losing corners in DONE reopens` va `losing the base returns to BASE`.

---

## Fayllar

| Fayl | Holat | Vazifasi |
|---|---|---|
| `arscan/FloorPlanCapture.kt` | o'zgaradi | `close()`, `summary()`, takroriy bosishni rad etish |
| `arscan/FloorRay.kt` | yangi | Nur ∩ pol tekisligi, haqiqiy pol urilishi bilan nurdan birini tanlash |
| `arscan/WallGeometry.kt` | yangi | View/proj matritsalari, near-plane kesish, devor va to'r, ellips |
| `arscan/ScanFlow.kt` | yangi | Qadamlar mashinasi va har kadrdagi UI holati (`FlowUi`) |
| `arscan/ArRenderer.kt` | qayta yoziladi | `ArOverlayView`: devorlar, chiplar, ellips, animatsiya. `ScreenProjector` o'chiriladi |
| `arscan/ArScanChrome.kt` | yangi | ✕, ↶, maslahat, asosiy tugma, "Xonani yopish", chiplar |
| `arscan/ArScanActivity.kt` | qayta yoziladi | Sessiya, kadr sikli, anchorlar, `ScanFlow` ga topshirish |
| `lib/l10n/app_{uz,ru,en}.arb` | o'zgaradi | Yangi va o'zgargan kalitlar |
| `lib/screens/scanning/ar_scan_screen.dart` | o'zgaradi | Native'ga beriladigan `strings` xaritasi |
| `test/widget/ar_scan_screen_test.dart` | o'zgaradi | Yangi kalitlarni tekshiradi |
| `docs/ARCHITECTURE.md`, `pubspec.yaml` | o'zgaradi | Android skaner bo'limi, versiya |

---

### Task 1: `FloorPlanCapture` — yopish, yakun, takroriy bosish

**Files:**
- Modify: `android/app/src/main/kotlin/com/tamir_uy/tamir_uy_mobile_flutter/arscan/FloorPlanCapture.kt`
- Test: `android/app/src/test/kotlin/com/tamir_uy/tamir_uy_mobile_flutter/arscan/FloorPlanCaptureTest.kt`

**Interfaces:**
- Produces:
  - `enum class AddResult { ADDED, CLOSED, REJECTED_CLOSED, REJECTED_DUPLICATE }`
  - `fun FloorPlanCapture.close(): Boolean`. Agar burchaklar ≥3 va kontur yopiq bo'lmasa, oxiriga `points[0]` nusxasini qo'shadi, `isClosed = true` qiladi va `true` qaytaradi. Boshqa holatda `false` qaytaradi va hech narsani o'zgartirmaydi.
  - `data class RoomSummary(val perimeterM: Float, val areaM2: Float, val volumeM3: Float)`
  - `fun FloorPlanCapture.summary(height: Float): RoomSummary`. Yopiq konturda oxirgi (yopuvchi) nuqta tashlab yuboriladi. Perimetr yopiq ko'pburchak bo'yicha (oxirgi→birinchi qirra ham kiradi) hisoblanadi, maydon shoelace formulasi bilan |·|, hajm esa `area * height`.
  - `const val DUPLICATE_M = 0.05f` (companion)

- [ ] **Step 1: Failing testlarni yozing** (hozirgi `square()` yordamchisidan foydalaning)

```kotlin
@Test fun `close appends a copy of the first corner`() {
    val c = FloorPlanCapture(); square(c)
    assertTrue(c.close())
    assertTrue(c.isClosed)
    assertEquals(5, c.corners.size)
    assertEquals(c.corners[0], c.corners[4])
    assertFalse(c.close())
}
@Test fun `close needs three corners`() {
    val c = FloorPlanCapture()
    c.addCorner(Vec3(0f, 0f, 0f)); c.addCorner(Vec3(4f, 0f, 0f))
    assertFalse(c.close()); assertFalse(c.isClosed)
}
@Test fun `reopen after close drops the copy`() {
    val c = FloorPlanCapture(); square(c); c.close()
    assertTrue(c.reopen()); assertEquals(4, c.corners.size); assertFalse(c.isClosed)
}
@Test fun `summary of a 4 by 3 room at 2_5 m`() {
    val c = FloorPlanCapture(); square(c); c.close()
    val s = c.summary(2.5f)
    assertEquals(14f, s.perimeterM, 1e-4f)
    assertEquals(12f, s.areaM2, 1e-4f)
    assertEquals(30f, s.volumeM3, 1e-4f)
}
@Test fun `rejects a corner within 5 cm of the last`() {
    val c = FloorPlanCapture()
    c.addCorner(Vec3(0f, 0f, 0f)); c.addCorner(Vec3(4f, 0f, 0f))
    assertEquals(AddResult.REJECTED_DUPLICATE, c.addCorner(Vec3(4.03f, 0f, 0.02f)))
    assertEquals(2, c.corners.size)
}
```

- [ ] **Step 2: Fail bo'lishini tekshiring**

Run: `cd android && ./gradlew :app:testDebugUnitTest --tests '*FloorPlanCaptureTest*'`
Expected: kompilyatsiya xatosi (`close`, `summary`, `REJECTED_DUPLICATE` yo'q).

- [ ] **Step 3: Kodni yozing.** `addCorner` da takroriy bosish tekshiruvi `isClosed` tekshiruvidan keyin, snap tekshiruvidan oldin turadi. Masofa XZ bo'yicha `hypot` bilan o'lchanadi. `points` ro'yxati hozirgidek butunligicha almashtiriladi (`@Volatile` qoidasi).

- [ ] **Step 4: Testlar o'tishini tekshiring.** Hozirgi testlar ham o'tishi kerak.

Run: `cd android && ./gradlew :app:testDebugUnitTest --tests '*FloorPlanCaptureTest*'`
Expected: `BUILD SUCCESSFUL`.

- [ ] **Step 5: Commit** — `feat(ar-scan): close the outline by button, room summary, ignore double taps`

---

### Task 2: `FloorRay` — nishon pol tekisligida

**Files:**
- Create: `.../arscan/FloorRay.kt`
- Test: `.../arscan/FloorRayTest.kt`

**Interfaces:**
- Produces:
  - `object FloorRay { const val MAX_DISTANCE_M = 8f; const val PLANE_TOLERANCE_M = 0.25f }`
  - `fun FloorRay.hit(origin: Vec3, dir: Vec3, floorY: Float): Vec3?`. Agar `dir.y >= -1e-4f` bo'lsa (nur pastga qaramasa) yoki nuqta `origin` dan `MAX_DISTANCE_M` dan uzoq bo'lsa, `null` qaytaradi. `dir` normallashtirilmagan bo'lishi mumkin.
  - `fun FloorRay.pick(planeHit: Vec3?, rayHit: Vec3?, floorY: Float?): Vec3?`. `floorY == null` bo'lsa `planeHit` qaytadi. Aks holda `planeHit` faqat `|planeHit.y - floorY| < PLANE_TOLERANCE_M` bo'lsa olinadi, bo'lmasa `rayHit` olinadi. Natijaning `y` qiymati doim `floorY` ga tenglanadi.

- [ ] **Step 1: Failing testlar**

```kotlin
@Test fun `looking down hits the floor`() {
    val p = FloorRay.hit(Vec3(0f, 1.5f, 0f), Vec3(0f, -1f, -1f), 0f)!!
    assertEquals(0f, p.x, 1e-5f); assertEquals(0f, p.y, 1e-5f); assertEquals(-1.5f, p.z, 1e-5f)
}
@Test fun `looking up or level misses`() {
    assertNull(FloorRay.hit(Vec3(0f, 1.5f, 0f), Vec3(0f, 0.2f, -1f), 0f))
    assertNull(FloorRay.hit(Vec3(0f, 1.5f, 0f), Vec3(0f, 0f, -1f), 0f))
}
@Test fun `farther than 8 m misses`() {
    assertNull(FloorRay.hit(Vec3(0f, 1.5f, 0f), Vec3(0f, -0.1f, -1f), 0f)) // ~15 m
}
@Test fun `pick ignores a table top`() {
    val table = Vec3(1f, 0.75f, -1f); val ray = Vec3(1.2f, 0f, -1.4f)
    assertEquals(ray, FloorRay.pick(table, ray, 0f))
}
@Test fun `pick prefers a real floor hit and pins it to floorY`() {
    val p = FloorRay.pick(Vec3(1f, 0.04f, -1f), Vec3(1.1f, 0f, -1f), 0f)!!
    assertEquals(1f, p.x, 1e-6f); assertEquals(0f, p.y, 1e-6f)
}
@Test fun `pick before the floor is known uses the plane hit`() {
    val h = Vec3(1f, -1.3f, -1f)
    assertEquals(h, FloorRay.pick(h, null, null))
}
```

- [ ] **Step 2: Fail.** Run: `cd android && ./gradlew :app:testDebugUnitTest --tests '*FloorRayTest*'`. Expected: kompilyatsiya xatosi.
- [ ] **Step 3: `FloorRay.kt` ni yozing.**
- [ ] **Step 4: O'tadi.** Xuddi shu buyruq, natija `BUILD SUCCESSFUL`.
- [ ] **Step 5: Commit** — `feat(ar-scan): floor ray so corners land next to walls and behind furniture`

---

### Task 3: `WallGeometry` — 3D devorlarni ekranga chiqarish

**Files:**
- Create: `.../arscan/WallGeometry.kt`
- Test: `.../arscan/WallGeometryTest.kt`

**Interfaces:**
- Consumes: `Vec3`.
- Produces:
  - `typealias Px = Pair<Float, Float>` — ekran pikseli.
  - `data class Segment(val a: Px, val b: Px)`
  - `data class WallShape(val outline: List<Px>, val grid: List<Segment>, val labelAt: Px?)`. `labelAt` — pastki qirra o'rtasining proyeksiyasi. U kamera ortida bo'lsa, `null`.
  - `class WallGeometry(view: FloatArray, proj: FloatArray, width: Int, height: Int, near: Float = 0.05f)`:
    - `fun point(p: Vec3): Px?` — kamera ortida bo'lsa `null`.
    - `fun segment(a: Vec3, b: Vec3): Segment?` — near plane bo'yicha kesilgan, to'liq ortda bo'lsa `null`.
    - `fun wall(a: Vec3, b: Vec3, height: Float, gridStep: Float = 0.5f): WallShape?` — to'liq ortda bo'lsa `null`.
    - `fun floorEllipse(center: Vec3, radius: Float = 0.15f, steps: Int = 32): List<Px>?`

**Algoritm (signatura buni belgilamaydi):**
1. Nuqtani view-space'ga o'tkazish: `v = view · (x, y, z, 1)`.
2. Ko'pburchakni `z <= -near` yarim-fazoga Sutherland–Hodgman usulida kesish. Qirra chegarani kesib o'tsa, kesishish nuqtasi `t = (-near - z0) / (z1 - z0)` bo'yicha chiziqli interpolyatsiya bilan topiladi.
3. Har bir nuqtani `proj · v` bilan proyeksiya qilish, keyin `w` ga bo'lish va pikselga o'tkazish: `((nx+1)/2·W, (1-ny)/2·H)`.
4. Segmentlar ham xuddi shunday, ikki uchli ko'pburchak sifatida kesiladi.
5. To'r: devor bo'ylab har `gridStep` metrda vertikal chiziq, pol+`gridStep` dan boshlab har qatlamda gorizontal chiziq. Har biri `segment()` orqali o'tadi.

4×4 ko'paytma qo'lda yoziladi (column-major), `android.opengl.Matrix` ishlatilmaydi.

- [ ] **Step 1: Failing testlar.** Testda view matritsasi birlik (identity), proj esa fovy 90°, aspect 1, near 0.05, far 100, ekran 1000×1000 bo'ladi:

```kotlin
private val identity = floatArrayOf(1f,0f,0f,0f, 0f,1f,0f,0f, 0f,0f,1f,0f, 0f,0f,0f,1f)
private fun persp(n: Float = 0.05f, f: Float = 100f) =
    floatArrayOf(1f,0f,0f,0f, 0f,1f,0f,0f, 0f,0f,(f+n)/(n-f),-1f, 0f,0f,2*f*n/(n-f),0f)
private val g = WallGeometry(identity, persp(), 1000, 1000)

@Test fun `point straight ahead is the screen centre`() {
    val p = g.point(Vec3(0f, 0f, -2f))!!
    assertEquals(500f, p.first, 0.01f); assertEquals(500f, p.second, 0.01f)
}
@Test fun `point behind the camera is null`() { assertNull(g.point(Vec3(0f, 0f, 2f))) }
@Test fun `wall in front has four corners and a label`() {
    val w = g.wall(Vec3(-1f, -1.5f, -3f), Vec3(1f, -1.5f, -3f), 2.5f)!!
    assertEquals(4, w.outline.size); assertNotNull(w.labelAt)
    assertEquals(3 + 4, w.grid.size) // 3 vertical (x=-0.5,0,0.5) + 4 horizontal (0.5..2.0)
}
@Test fun `wall behind the camera is null`() {
    assertNull(g.wall(Vec3(-1f, -1.5f, 3f), Vec3(1f, -1.5f, 3f), 2.5f))
}
@Test fun `wall through the camera is clipped to the near plane`() {
    val w = g.wall(Vec3(0.5f, -1.5f, 2f), Vec3(0.5f, -1.5f, -2f), 2.5f)!!
    assertTrue(w.outline.all { it.first.isFinite() && it.second.isFinite() })
    assertTrue(w.outline.all { abs(it.first) < 1e5f && abs(it.second) < 1e5f })
    assertNull(w.labelAt) // the bottom edge's midpoint is at z=0, behind the near plane
}
@Test fun `floor ellipse in front has all its points`() {
    assertEquals(32, g.floorEllipse(Vec3(0f, -1.5f, -2f))!!.size)
}
```

Eslatma: grid soni (3+4) qirralarni hisobga olmaydi. Vertikal chiziqlar devor uzunligi bo'ylab `gridStep` qadamda, uchlardan qat'iy ichkarida joylashadi. Gorizontal chiziqlar balandlik bo'ylab xuddi shu qoida bilan chiziladi: 2.5 m ichida 0.5, 1.0, 1.5 va 2.0 m. Pastki va yuqori qirralar to'rga kirmaydi, ular kontur sifatida chiziladi.

- [ ] **Step 2: Fail.** Run: `cd android && ./gradlew :app:testDebugUnitTest --tests '*WallGeometryTest*'`
- [ ] **Step 3: `WallGeometry.kt` ni yozing.**
- [ ] **Step 4: O'tadi.**
- [ ] **Step 5: Commit** — `feat(ar-scan): project and near-clip 3D walls, grid and floor reticle`

---

### Task 4: `ScanFlow` — qadamlar mashinasi

**Files:**
- Create: `.../arscan/ScanFlow.kt`
- Test: `.../arscan/ScanFlowTest.kt`

**Interfaces:**
- Consumes: `FloorPlanCapture` (Task 1: `addCorner`, `close`, `reopen`, `undo`, `corners`, `isClosed`, `wouldSnap`), `AddResult`, `FloorPlanCapture.MIN_HEIGHT_M/MAX_HEIGHT_M`.
- Produces:
  - `enum class ScanStep { FIND_FLOOR, BASE, HEIGHT, WALLS, DONE }`
  - `data class FlowUi(val hintKey: String, val mainKey: String?, val mainEnabled: Boolean, val undoVisible: Boolean, val closeVisible: Boolean, val chipsVisible: Boolean)`
  - `class ScanFlow(val capture: FloorPlanCapture = FloorPlanCapture())`:
    - `var step: ScanStep` (private set), `var height: Float?` (private set), `var heightMeasured: Boolean` (private set)
    - `fun floorFound()`: `FIND_FLOOR` → `BASE`, boshqa qadamlarda hech narsa qilmaydi.
    - `fun placeBase(p: Vec3): Boolean`: faqat `BASE` da ishlaydi. `capture.addCorner(p)` ni chaqiradi va `HEIGHT` ga o'tadi.
    - `fun confirmHeight(h: Float, measured: Boolean): Boolean`: faqat `HEIGHT` da va `h ∈ [MIN_HEIGHT_M, MAX_HEIGHT_M]` bo'lsa ishlaydi. `WALLS` ga o'tadi.
    - `fun addCorner(p: Vec3): AddResult`: faqat `WALLS` da ishlaydi, boshqa qadamda `REJECTED_CLOSED` qaytaradi. `CLOSED` bo'lsa `DONE` ga o'tadi.
    - `fun closeRoom(): Boolean`: faqat `WALLS` da, `capture.close()` orqali ishlaydi. `true` bo'lsa `DONE` ga o'tadi.
    - `fun undo(): Int`. Qaytaradigan qiymati — activity nechta oxirgi anchorni `detach` qilishi kerakligi:
      - `HEIGHT` → `capture.undo()` chaqiriladi, `BASE` ga o'tiladi, `1` qaytadi.
      - `WALLS` da 1 burchak bo'lsa → `height = null`, `HEIGHT` ga o'tiladi, `0` qaytadi.
      - `WALLS` da >1 burchak bo'lsa → `capture.undo()`, `1` qaytadi.
      - `DONE` → `capture.reopen()`, `WALLS` ga o'tiladi, `1` qaytadi.
      - `FIND_FLOOR` va `BASE` da `0` qaytadi.
    - `fun cornersLost()`. `capture.updatePositions` burchak tashlagandan keyin chaqiriladi. Burchak qolmagan bo'lsa `height = null` va `BASE` ga o'tiladi. Aks holda `DONE` dan `WALLS` ga o'tiladi, boshqa qadam o'zgarmaydi.
    - `fun ui(tracking: Boolean, reticle: Vec3?, liveHeight: Float?): FlowUi`

**`ui()` jadvali** (kalitlar Task 5 dagi nomlar; `ok = tracking && reticle != null`):

| step | hintKey | mainKey | mainEnabled | undo | close | chips |
|---|---|---|---|---|---|---|
| FIND_FLOOR | `arScanFindFloor` | null | false | false | false | false |
| BASE | `arScanBaseHint` (agar `reticle == null` bo'lsa `arScanNoFloorHere`) | `arScanStart` | ok | false | false | false |
| HEIGHT | `arScanAimCeiling` | `arScanConfirm` | `tracking && liveHeight != null` | true | false | true |
| WALLS | `reticle != null && capture.wouldSnap(reticle)` bo'lsa `arScanSnapToFirst`, aks holda `arScanCornersHint` | `arScanAddCorner` | ok | true | `corners.size >= 3` | false |
| DONE | `arScanDoneHint` | `arScanCreatePlan` | true | true | false | false |

`tracking == false` bo'lsa, `hintKey` har qanday qadamda (DONE dan tashqari) `arScanTrackingLost` bo'ladi. `FIND_FLOOR` dagi 20 s maslahatini (`arScanFloorHint`) activity o'zi almashtiradi.

- [ ] **Step 1: Failing testlar**

```kotlin
private fun walls(): ScanFlow = ScanFlow().apply {
    floorFound(); placeBase(Vec3(0f, 0f, 0f)); confirmHeight(2.5f, measured = true)
}
@Test fun `happy path to DONE by snapping`() {
    val f = walls()
    f.addCorner(Vec3(4f, 0f, 0f)); f.addCorner(Vec3(4f, 0f, 3f)); f.addCorner(Vec3(0f, 0f, 3f))
    assertEquals(AddResult.CLOSED, f.addCorner(Vec3(0.1f, 0f, 0.1f)))
    assertEquals(ScanStep.DONE, f.step)
}
@Test fun `close room button needs three corners`() {
    val f = walls(); f.addCorner(Vec3(4f, 0f, 0f))
    assertFalse(f.ui(true, Vec3(4f, 0f, 3f), null).closeVisible)
    assertFalse(f.closeRoom())
    f.addCorner(Vec3(4f, 0f, 3f))
    assertTrue(f.ui(true, Vec3(0f, 0f, 3f), null).closeVisible)
    assertTrue(f.closeRoom()); assertEquals(ScanStep.DONE, f.step)
}
@Test fun `height outside 1_8 to 4_5 m is refused`() {
    val f = ScanFlow().apply { floorFound(); placeBase(Vec3(0f, 0f, 0f)) }
    assertFalse(f.confirmHeight(1.2f, true)); assertFalse(f.confirmHeight(5f, true))
    assertEquals(ScanStep.HEIGHT, f.step)
    assertFalse(f.ui(true, null, null).mainEnabled)
}
@Test fun `undo walks back one step at a time`() {
    val f = walls(); f.addCorner(Vec3(4f, 0f, 0f))
    assertEquals(1, f.undo()); assertEquals(ScanStep.WALLS, f.step)
    assertEquals(0, f.undo()); assertEquals(ScanStep.HEIGHT, f.step); assertNull(f.height)
    assertEquals(1, f.undo()); assertEquals(ScanStep.BASE, f.step); assertTrue(f.capture.corners.isEmpty())
}
@Test fun `undo in DONE reopens`() {
    val f = walls(); f.addCorner(Vec3(4f, 0f, 0f)); f.addCorner(Vec3(4f, 0f, 3f)); f.closeRoom()
    assertEquals(1, f.undo()); assertEquals(ScanStep.WALLS, f.step); assertFalse(f.capture.isClosed)
}
@Test fun `losing corners in DONE reopens`() {
    val f = walls(); f.addCorner(Vec3(4f, 0f, 0f)); f.addCorner(Vec3(4f, 0f, 3f)); f.closeRoom()
    f.capture.updatePositions(listOf(Vec3(0f, 0f, 0f), Vec3(4f, 0f, 0f), null, null))
    f.cornersLost(); assertEquals(ScanStep.WALLS, f.step)
}
@Test fun `losing the base returns to BASE`() {
    val f = walls(); f.addCorner(Vec3(4f, 0f, 0f))
    f.capture.updatePositions(listOf(null, null))
    f.cornersLost(); assertEquals(ScanStep.BASE, f.step); assertNull(f.height)
}
@Test fun `no reticle disables the main button`() {
    val f = walls()
    assertFalse(f.ui(true, null, null).mainEnabled)
    assertFalse(f.ui(false, Vec3(1f, 0f, 1f), null).mainEnabled)
    assertEquals("arScanTrackingLost", f.ui(false, Vec3(1f, 0f, 1f), null).hintKey)
}
```

- [ ] **Step 2: Fail.** Run: `cd android && ./gradlew :app:testDebugUnitTest --tests '*ScanFlowTest*'`
- [ ] **Step 3: `ScanFlow.kt` ni yozing.**
- [ ] **Step 4: O'tadi.** Butun JVM to'plami ham o'tishi kerak: `./gradlew :app:testDebugUnitTest`.
- [ ] **Step 5: Commit** — `feat(ar-scan): scanner step machine (base, height, walls, done)`

---

### Task 5: Matnlar (uz/ru/en) va Flutter xaritasi

**Files:**
- Modify: `lib/l10n/app_uz.arb`, `lib/l10n/app_ru.arb`, `lib/l10n/app_en.arb`
- Modify: `lib/screens/scanning/ar_scan_screen.dart:59-77` (`strings` xaritasi)
- Test: `test/widget/ar_scan_screen_test.dart`

**Interfaces:**
- Produces: native'ga beriladigan kalitlar. Task 4 va Task 6 aynan shu nomlarni ishlatadi:
  - **Qoladi (qiymati o'zgarmaydi):** `arScanFindFloor`, `arScanFloorHint`, `arScanAddCorner`, `arScanUndo`, `arScanConfirm`, `arScanExit`, `arScanExitConfirm`, `arScanKeepMeasuring`, `arScanTrackingLost`, `arScanCornersLost`, `arScanSnapToFirst`.
  - **Qoladi, qiymati o'zgaradi:** `arScanCornersHint`, `arScanAimCeiling`, `arScanNoFloorHere`.
  - **Yangi:** `arScanBaseHint`, `arScanStart`, `arScanCloseRoom`, `arScanCreatePlan`, `arScanDoneHint`, `arScanPerimeter`, `arScanArea`, `arScanVolume`, `arScanUnitCm`, `arScanUnitM`.
  - **O'chiriladi** (uchala `.arb` dan va xaritadan): `arScanFinish`, `arScanEnterManually`, `arScanStepFloor`, `arScanStepCorners`, `arScanStepHeight`.

**Matnlar (spec bo'yicha qat'iy):**

| Kalit | uz | ru | en |
|---|---|---|---|
| `arScanBaseHint` | Nishonni devor va pol tutashgan burchakka qo'ying | Наведите прицел на угол, где стена встречается с полом | Aim at a corner where the wall meets the floor |
| `arScanStart` | Boshlash | Начать | Start |
| `arScanAimCeiling` | Telefonni yuqoriga burib, chiziqni shiftgacha torting | Наклоните телефон вверх и дотяните линию до потолка | Tilt the phone up to pull the line to the ceiling |
| `arScanCornersHint` | Nishonni keyingi burchakka qo'yib, burchak qo'shing | Наведите прицел на следующий угол и добавьте его | Aim at the next corner and add it |
| `arScanNoFloorHere` | Nishon polga tushmayapti — telefonni pastroq qarating | Прицел не на полу — наклоните телефон ниже | The aim is off the floor — tilt the phone down |
| `arScanCloseRoom` | Xonani yopish | Замкнуть комнату | Close the room |
| `arScanCreatePlan` | Rejani yaratish | Создать план | Create plan |
| `arScanDoneHint` | Xona tayyor. Xato bo'lsa, ↶ bilan qayting | Комната готова. Если есть ошибка, вернитесь кнопкой ↶ | Room is ready. Use ↶ to fix a mistake |
| `arScanPerimeter` | Perimetr | Периметр | Perimeter |
| `arScanArea` | Maydon | Площадь | Area |
| `arScanVolume` | Hajm | Объём | Volume |
| `arScanUnitCm` | sm | см | cm |
| `arScanUnitM` | m | м | m |

- [ ] **Step 1: Widget testni yangilang.** Birinchi testni yangi kalitlarni tekshiradigan qiling:

```dart
testWidgets('passes the scanner its flow copy', (tester) async {
  final fake = _FakeArScan(raw: _scan([[0, 0], [4, 0], [4, 3], [0, 3]]));
  await _pump(tester, fake);
  final s = fake.lastStrings!;
  for (final e in {
    'arScanBaseHint': l10n.arScanBaseHint, 'arScanStart': l10n.arScanStart,
    'arScanCloseRoom': l10n.arScanCloseRoom, 'arScanCreatePlan': l10n.arScanCreatePlan,
    'arScanDoneHint': l10n.arScanDoneHint, 'arScanPerimeter': l10n.arScanPerimeter,
    'arScanArea': l10n.arScanArea, 'arScanVolume': l10n.arScanVolume,
    'arScanUnitCm': l10n.arScanUnitCm, 'arScanUnitM': l10n.arScanUnitM,
    'arScanNoFloorHere': l10n.arScanNoFloorHere, 'arScanKeepMeasuring': l10n.arScanKeepMeasuring,
  }.entries) {
    expect(s[e.key], e.value, reason: e.key);
  }
  expect(s.containsKey('arScanStepFloor'), isFalse);
});
```

- [ ] **Step 2: Fail.** Run: `flutter test test/widget/ar_scan_screen_test.dart`. Expected: getter'lar yo'qligi sababli kompilyatsiya xatosi.
- [ ] **Step 3: `.arb` larni yangilang.** `app_uz.arb` dagi har bir yangi kalitga `@key` tavsifi qo'shiladi. Keyin `flutter gen-l10n` ishga tushiriladi va `ar_scan_screen.dart` dagi xarita yangilanadi.
- [ ] **Step 4: O'tadi.** Run: `flutter gen-l10n && flutter test test/widget/ar_scan_screen_test.dart && flutter analyze`. Expected: testlar o'tadi, `No issues found!`.
- [ ] **Step 5: Commit** — `feat(ar-scan): copy for the new scanner flow in uz/ru/en`

---

### Task 6: Overlay, chrome va activity

**Files:**
- Rewrite: `.../arscan/ArRenderer.kt` (`ArOverlayView`; `ScreenProjector` o'chiriladi)
- Create: `.../arscan/ArScanChrome.kt`
- Rewrite: `.../arscan/ArScanActivity.kt`

**Interfaces:**
- Consumes: Task 1–4 dagi hamma narsa, Task 5 kalitlari.
- Produces (shu task ichida):
  - `data class OverlayState(val walls: List<WallShape>, val liveWall: WallShape?, val heightAxis: Segment?, val heightLabel: Pair<Px, String>?, val reticle: List<Px>?, val reticleSnapping: Boolean, val labels: List<Pair<Px, String>>, val onboarding: Boolean)`
  - `class ArOverlayView(context: Context) : View` — `var state: OverlayState`.
  - `class ArScanChrome(activity: Activity, s: (String) -> String)`:
    - `val root: View`
    - `fun bind(ui: FlowUi, hint: String, summary: String?)`
    - Callback'lar: `onExit`, `onUndo`, `onMain`, `onCloseRoom`, `onChip: (Float) -> Unit`.

**Activity'dagi kadr sikli (GL ipi):**
1. `tracking` hisoblanadi, `trackingLossCount` hozirgidek yuritiladi.
2. Anchor pozitsiyalari `capture.updatePositions` orqali yangilanadi. Burchak tashlangan bo'lsa: ortiqcha anchorlar `detach` qilinadi, `flow.cornersLost()` chaqiriladi va `cornersLost = true` qo'yiladi (hozirgidek, "Ba'zi burchaklar yo'qoldi" maslahati uchun).
3. Ekran markazida hit-test qilinadi. Birinchi `HORIZONTAL_UPWARD_FACING` `Plane` urilishi olinadi, `isPoseInPolygon` cheklovi **olib tashlanadi**. Natija `planeHit` (`Vec3` va `HitResult`).
4. `floorY`: baza qo'yilgunicha `planeHit?.y` dan olinadi va oxirgi qiymat yangilanib turadi. Baza qo'yilgandan keyin `capture.floorY` ishlatiladi. Birinchi `planeHit` kelganda `flow.floorFound()` chaqiriladi.
5. `rayHit = FloorRay.hit(cameraPos, -camera.pose.zAxis, floorY)`, `reticle = FloorRay.pick(planeHit, rayHit, floorY)`.
6. `HEIGHT` qadamida `liveHeight = capture.heightFromRay(...)` (hozirgidek) hisoblanadi.
7. `WallGeometry(view, proj, w, h)` quriladi:
   - qo'yilgan devorlar: ketma-ket burchaklar orasida, yopiq bo'lsa oxirgi qirra ham, balandligi `flow.height`;
   - `WALLS` da `liveWall` oxirgi burchakdan `reticle` gacha;
   - `HEIGHT` da `heightAxis` bazadan `base + (0, liveHeight ?: 0, 0)` gacha;
   - `reticle` uchun `floorEllipse`.
8. Uzunlik yorliqlari `"${round(len*100)} ${s("arScanUnitCm")}"` ko'rinishida, `labelAt` nuqtasida chiqadi. `liveWall` ning yorlig'i ham shunday.
9. `runOnUiThread { overlay.state = …; chrome.bind(flow.ui(...), hint, summary) }`. `summary` faqat `DONE` da beriladi: `"${s("arScanPerimeter")} 16.5 $m · ${s("arScanArea")} 16.3 $m² · ${s("arScanVolume")} 40.8 $m³"` (`m = s("arScanUnitM")`; `heightLabel` ham `"H = ${round(h*100)} ${s("arScanUnitCm")}"`), raqamlar `capture.summary(height)` dan.

**Tugmalar (UI → `onGl`):**
- `BASE` + asosiy tugma: `reticle` dan anchor yaratiladi. `planeHit` tanlangan bo'lsa `hit.createAnchor()`, aks holda `session.createAnchor(Pose.makeTranslation(x, y, z))`. Keyin `flow.placeBase(anchor.pose → Vec3)` chaqiriladi.
- `HEIGHT` + asosiy tugma: `flow.confirmHeight(liveHeight, measured = true)`. Chip bosilsa: `flow.confirmHeight(h, measured = false)`.
- `WALLS` + asosiy tugma: anchor yaratiladi va `flow.addCorner` chaqiriladi. `ADDED`/`CLOSED` bo'lsa anchor ro'yxatga qo'shiladi, aks holda `detach` qilinadi.
- "Xonani yopish": `flow.closeRoom()` `true` qaytarsa, `session.createAnchor(anchors[0].pose)` ro'yxatga qo'shiladi. Shunda anchorlar soni `capture.corners` soniga teng qoladi.
- ↶: `repeat(flow.undo()) { anchors.removeLastOrNull()?.detach() }`.
- `DONE` + asosiy tugma: `finishWith(flow.height!!, flow.heightMeasured)` (hozirgi `finishWith`).
- Titrash: burchak qo'shilganda `HapticFeedbackConstants.VIRTUAL_KEY`, yopilganda `LONG_PRESS` (UI ipida, `overlay.performHapticFeedback`).

**Chizish (`ArOverlayView.onDraw`)** Global Constraints'dagi ranglar bilan quyidagi tartibda bajariladi:
1. Devorlar: `outline` → `Path` fill + qirra, keyin `grid` chiziqlari.
2. `liveWall` ham xuddi shunday chiziladi, fill alfa 40.
3. `heightAxis` oq chiziq bo'ladi, `heightLabel` chip ichida `"H = 250 sm"` ko'rinishida chiqadi.
4. Ellips `reticleSnapping` holatida to'liq oq to'ldiriladi. `reticle == null` bo'lsa, ekran markazida xira halqa chiziladi.
5. Chiplar: oq dumaloq to'rtburchak, matn `rgb(64,56,160)`, 13sp.
6. `onboarding`: perspektivadagi pol trapetsiyasi va telefon ko'rinishidagi yumaloq to'rtburchak. Telefon `sin(t)` bilan chap-o'ngga suriladi. Bu holatda overlay `postInvalidateOnAnimation()` bilan uzluksiz qayta chiziladi.

**Chrome:**
- Yuqori chapda ✕ ikonka (`confirmExit`, hozirgidek).
- Yuqori o'ngda ↶ ikonka, `contentDescription = s("arScanUndo")`, `undoVisible` bo'yicha ko'rinadi.
- Markazda maslahat kartochkasi: `argb(150,0,0,0)`, radius 16dp, maksimal kenglik 300dp.
- "Xonani yopish" kichik pill tugma, kartochka ostida.
- Pastda markazda asosiy tugma: `rgb(64,56,160)`, balandlik 56dp, gorizontal padding 32dp.
- Chiplar qatori asosiy tugma ustida: "2.5 m" … "3.0 m".

- [ ] **Step 1: `ArRenderer.kt` va `ArScanChrome.kt` ni yozing**, keyin `ArScanActivity.kt` ni yuqoridagi sikl bo'yicha qayta yozing. Kotlin `fallback` xaritasi Task 5 dagi kalitlar ro'yxatiga (uz qiymatlari bilan) moslanadi. Sessiya va hayot sikli kodi (`createSession`, `onResume`/`onPause`, ruxsat, `fail`/`cancel`, `finishWith` dagi JSON) o'zgarmaydi.
- [ ] **Step 2: Yig'ilishini tekshiring.** Run: `flutter build apk --debug --dart-define=API_URL=https://andozaai.uz/api/v1`. Expected: `✓ Built build/app/outputs/flutter-apk/app-debug.apk`.
- [ ] **Step 3: JVM testlar.** Run: `cd android && ./gradlew :app:testDebugUnitTest`. Expected: `BUILD SUCCESSFUL`.
- [ ] **Step 4: Commit** — `feat(ar-scan): 3D walls, height-first flow and a single main button on Android`

---

### Task 7: Hujjat, versiya, to'liq tekshiruv

**Files:**
- Modify: `docs/ARCHITECTURE.md` — "**Android:**" paragrafi, `## LiDAR skaner` bo'limidan keyin. Unda yozilishi kerak: Android'da `andoza/arscan` (ARCore) skaneri bor; qadamlari pol → baza → balandlik → devorlar → yakun; mantiq `ScanFlow`/`FloorPlanCapture`/`FloorRay`/`WallGeometry` da (JVM testli); natija `arcore_plan.dart` → review. Hozirgi "foto rejimi yoki xonani chizish taklif qilinadi" jumlasi faqat ARCore yo'q qurilmalar uchun qoladi.
- Modify: `pubspec.yaml` — `version: 1.0.0+29`.

- [ ] **Step 1: Hujjat va versiyani yangilang.**
- [ ] **Step 2: To'liq tekshiruv.** Run: `flutter analyze && flutter test && (cd android && ./gradlew :app:testDebugUnitTest)`. Expected: `No issues found!`, `All tests passed!`, `BUILD SUCCESSFUL`.
- [ ] **Step 3: Commit** — `chore: 1.0.0+29 (clearer Android AR scanner)`
- [ ] **Step 4: Qo'lda tekshiruv (foydalanuvchining Samsung telefoni).** Ilova `flutter run --release --dart-define=API_URL=https://andozaai.uz/api/v1 --dart-define=API_BASE_URL=… --dart-define=STUDIO_BASE_URL=…` bilan ishga tushiriladi (`docs/BUILD_AND_RELEASE.md` dagi qiymatlar). Bitta xonada quyidagilar tekshiriladi:
  - animatsiya → baza;
  - balandlik o'lchash va chip tanlash;
  - mebel ortidagi burchak;
  - stol ustiga qaratganda nishon polda qolishi;
  - "Xonani yopish";
  - har qadamda ↶;
  - yakun raqamlari;
  - review → studiya.

  O'lchamlar namunadagi ilova bilan solishtiriladi: 331 / 494 sm, 2.5 m. Natija foydalanuvchiga xabar qilinadi.
