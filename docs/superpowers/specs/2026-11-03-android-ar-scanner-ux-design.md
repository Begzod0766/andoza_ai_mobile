# Android AR skaner: qulay oqim (dizayn)

Sana: 2026-11-03. Holat: tasdiqlangan dizayn, reja yozilmagan.

## Muammo

Android'dagi ARCore skaner (`android/.../arscan/`, kanal `andoza/arscan`)
foydalanuvchi uchun noqulay va natijasi past sifatli:

- Nuqta faqat ARCore aniqlagan pol bo'lagi **ichiga** tushsa qabul qilinadi
  (`Plane.isPoseInPolygon`). Devor yonidagi va mebel ortidagi burchaklarda
  "Avval polni skaner qiling" chiqadi.
- Ekranda faqat 2D chiziq va nuqtalar: devorlar ko'rinmaydi, nishon polda
  yotmaydi, oxirgi burchakdan nishongacha jonli chiziq va uzunlik yo'q.
- Balandlik oxirida, shift chizig'iga aniq qaratib o'lchanadi.
- Uchta bir xil tugma qatori; boshida yo'riqnoma animatsiyasi yo'q.

Namuna: foydalanuvchi ko'rsatgan boshqa ilova — bazaviy nuqta devor-pol
tutashgan joyga, balandlik yuqoriga tortiladi, keyin har burchakda yarim
shaffof 3D devor o'sadi, ustida sm dagi o'lcham.

## Maqsad va mezonlar

- Oqim namunadagidek: pol → bazaviy nuqta → balandlik → devorlar → yakun.
- Foydalanuvchi xonaning 3D devorlarini real vaqtda ko'radi.
- Burchakni devor yonida va mebel ortida ham qo'yish mumkin.
- Flutter tomoni (`arcore_plan.dart`, review sahifasi, studiyaga uzatish)
  o'zgarmaydi.
- Qo'lda tekshiruv: bitta xonani qayta o'lchash, namunadagi ilova bergan
  o'lchamlarga (331 / 494 sm, 2.5 m) yaqinlik.

## Qamrovdan tashqari

Eshik/deraza belgilash (keyingi bosqich), AR ichida burchak/devorni sudrab
tahrirlash, iOS LiDAR skaneri, devorni mebel ortiga yashirish (occlusion).

## Oqim va ekran

Ekran: yuqori chapda ✕ (chiqishni tasdiqlash — hozirgidek), yuqori o'ngda ↶,
tepada markazda bitta maslahat kartochkasi, pastda markazda bitta asosiy
tugma. Burchak qo'shilganda va kontur yopilganda qisqa titrash.

| Qadam | Ekranda | Asosiy tugma | ↶ |
|---|---|---|---|
| `FIND_FLOOR` | Telefon pol ustida aylanayotgan animatsiya; 20 s dan keyin "yorug'roq joy" maslahati | yo'q | yashirin |
| `BASE` | Polda yotgan binafsha ellips nishon; "devor va pol tutashgan burchakka qo'ying" | "Boshlash" | yashirin |
| `HEIGHT` | Bazaviy nuqtadan vertikal chiziq, "H = 250 sm"; chiplar 2.5 / 2.7 / 2.8 / 3.0 m | "Tasdiqlash" (balandlik bo'lsa) | → `BASE` |
| `WALLS` | Qo'yilgan devorlar yarim shaffof to'rli, har birida uzunlik; oxirgi burchakdan nishongacha jonli devor va uzunlik; birinchi burchakka yaqinlashganda nishon ajraladi | "Burchak qo'shish"; ≥3 burchakda qo'shimcha "Xonani yopish" | oxirgi burchakni o'chiradi; birinchi burchak bo'lsa → `HEIGHT` |
| `DONE` | Butun xona 3D quti; perimetr (m), pol maydoni (m²), hajm (m³) | "Rejani yaratish" → natija Flutter'ga | yopishni bekor qiladi → `WALLS` |

- Birinchi burchak = bazaviy nuqta. Birinchi burchakka yaqin (20 sm) qo'yilgan
  burchak konturni yopadi (hozirgi `snapDistanceM`).
- Chip tanlansa balandlik qotadi va `WALLS` ga o'tiladi (`heightMeasured=false`).
- Kuzatuv yo'qolsa: hozirgi ogohlantirish, asosiy tugma o'chadi.
- Nur polga tushmasa (yuqoriga qaragan yoki 8 m dan uzoq): ellips xira,
  asosiy tugma o'chadi.

## Komponentlar (`android/app/src/main/kotlin/.../arscan/`)

ARCore turlarisiz bo'laklar JVM'da test qilinadi.

- **`FloorPlanCapture`** (kengaytiriladi) — burchaklar, `heightFromRay`
  (hozir bor), yangi `close()` (oxiriga birinchi burchak nusxasini qo'shadi,
  `isClosed=true`), yangi `summary(height)` → perimetr, maydon (shoelace),
  hajm. Balandlik endi devorlardan oldin olinadi va capture'da saqlanadi.
- **`ScanFlow`** (yangi) — qadamlar mashinasi (jadvaldagi o'tishlar). Har
  qadam uchun: maslahat kaliti, asosiy tugma matni/yoqilganligi, ↶ va
  "Xonani yopish" ko'rinishi, chiplar. Activity faqat shu holatni chizadi.
- **`FloorRay`** (yangi) — kamera nurini `y = floorY` tekisligi bilan
  kesishtiradi; nur yuqoriga qaragan yoki nuqta 8 m dan uzoq bo'lsa `null`.
- **`WallGeometry`** (yangi) — devor to'rtburchagi (pol → pol+H), 0.5 m
  qadamli to'r chiziqlari, nishon ellipsi (polda 15 sm radiusli doira).
  Ko'rinish fazosida near-plane bo'yicha kesadi, ekran ko'pburchaklariga
  proyeksiya qiladi (hozirgi `ScreenProjector` asosida).
- **`ArOverlayView`** (qayta yoziladi) — faqat chizadi: yarim shaffof binafsha
  devorlar va to'r, oq yumaloq uzunlik chiplari, ellips, balandlik chizig'i,
  `FIND_FLOOR` animatsiyasi.
- **`ArScanChrome`** (yangi) — ✕, ↶, maslahat kartochkasi, asosiy tugma,
  "Xonani yopish", balandlik chiplari.
- **`ArScanActivity`** (soddalashadi) — ARCore sessiyasi, kadr sikli,
  anchorlar; qarorlarni `ScanFlow` va `FloorPlanCapture` ga topshiradi.
  Ip qoidasi o'zgarmaydi: ARCore va holat GL ipida, UI `runOnUiThread`.

### Pol va nuqtalar

- `floorY`: nishon ostidagi birinchi `HORIZONTAL_UPWARD_FACING` tekislik
  urilishidan; bazaviy nuqta qo'yilganda qotadi.
- Har kadrda nishon: avval haqiqiy pol bo'lagiga hit-test (`floorY` dan
  ±5 sm — ko'rpacha yoki to'shak pol hisoblanmaydi), bo'lmasa `FloorRay`. Pol bo'lagi ichidagi cheklov olib tashlanadi.
- Har burchak ARCore anchoriga bog'lanadi; nurdan topilgan nuqta uchun
  `session.createAnchor(pose)`. Anchor `STOPPED` bo'lsa — hozirgi mantiq
  (`updatePositions`): u va keyingi burchaklar olib tashlanadi.
- Devor geometriyasi har kadrda GL ipida hisoblanadi, overlay'ga tayyor
  ko'pburchaklar beriladi.

## Flutter bilan aloqa

Natija JSON o'zgarmaydi: `corners`, `height`, `heightMeasured`, `closed`,
`trackingLossCount`, `durationSec`. "Xonani yopish" birinchi burchak
nusxasini qo'shgani uchun `ArScanRaw` qoidasi ("yopilganda oxirgi nuqta —
yopuvchi bosish") bajariladi; `arcore_plan.dart`, `RoomScanReviewPage` va
handoff o'zgarmaydi.

## Matnlar

Yangi kalitlar `app_uz.arb` (`@key` tavsifi bilan), `app_ru.arb`,
`app_en.arb` ga; `ar_scan_service.dart` ularni `EXTRA_STRINGS` bilan
uzatadi; Kotlin `fallback` faqat zaxira. Kerak bo'ladiganlar: bazaviy nuqta
maslahati, "Boshlash", balandlik maslahati, devorlar maslahati, "Xonani
yopish", "Rejani yaratish", yakun yorliqlari (perimetr/maydon/hajm), uzunlik
birligi (sm / см / cm), nur polga tushmaganda maslahat. Ishlatilmay qolgan
kalitlar (`arScanStep*`, `arScanEnterManually`, `arScanFinish` va h.k.)
uchala fayldan olib tashlanadi.

## Test

- JVM (`android/app/src/test/.../arscan/`): `FloorPlanCapture` (`close`,
  `summary`, eski testlar), `ScanFlow` (har o'tish va ↶), `FloorRay`,
  `WallGeometry` (kesish, kamera ortidagi devor, proyeksiya).
- `./gradlew testDebugUnitTest`, `flutter analyze`, `flutter test`.
- Qo'lda: Samsung telefonda bitta xona — oqim, mebel ortidagi burchak,
  "Xonani yopish", chiplar, ↶ har qadamda, review va studiyagacha.

## Hujjat va versiya

`docs/ARCHITECTURE.md` dagi Android skaner bo'limi yangilanadi; `pubspec.yaml`
versiyasi oshiriladi (`chore: 1.0.0+N (...)`).
