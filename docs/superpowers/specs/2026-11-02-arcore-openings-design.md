# ARCore skaner: eshik va derazalarni belgilash (B bosqich) — dizayn

Sana: 2026-11-02. Holat: dizayn chatda tasdiqlangan, spec ko'rib chiqishda.
Asos: `2026-10-11-arcore-room-scan-design.md` (A bosqich) va
`2026-10-12-arcore-auto-walls-design.md` (#37). Shu ish `feat/arcore-auto-walls`
ustiga quriladi (branch `feat/arcore-openings`).

## Muammo

Android skaneri faqat burchaklar va balandlikni qaytaradi; har devorning
`openings` ro'yxati bo'sh. Natijada Studio'da eshik/deraza yo'q, smeta esa
devor maydonidan ularni ayirmaydi. ARPlan 3D'da eshik/deraza skanerda
belgilanadi.

## Maqsad

Skanerda eshik va derazalar kam qo'l mehnati bilan rejaga tushsin; noto'g'ri
yoki o'tkazib yuborilganini ko'rib chiqish ekranida tuzatish mumkin bo'lsin.
Saqlash, backend, Studio va smeta o'zgarmaydi — ular `RoomOpening`'ni
allaqachon o'qiydi.

Muvaffaqiyat: to'rtburchak xonada 1 eshik + 1 deraza skanerda 4 bosishda
qo'shiladi; devordagi joyi (markaz) ruletka bilan o'lchanganidan ≤ 10 sm, eni
≤ 5 sm farq qiladi (S25 Ultra yoki A54).

## Foydalanuvchi oqimi (kamera)

Qadamlar: **pol → burchaklar → balandlik → eshik va derazalar** (yangi).

- Balandlik o'lchangach (yoki "o'tkazib yuborilgach") skaner tugamaydi —
  `OPENINGS` qadamiga o'tadi. Polda yopilgan kontur ko'rinadi.
- Yuqorida tur tanlagich: **Eshik** (standart) / **Deraza**.
- Nishon konturning eng yaqin devor chizig'iga yopishadi (≤ 30 sm). Devordan
  uzoq bo'lsa nishon kulrang, "Chet qo'shish" tugmasi o'chiq.
- Birinchi bosish — **chap chet**, ikkinchisi — **o'ng chet** (tartib muhim
  emas, ikkalasi saralanadi). Ikkinchi bosishdan keyin devorda rangli kesma:
  eshik yashil, deraza ko'k. Birinchi chet qo'yilgach, nishondan shu chetgacha
  jonli kesma va eni (m) ko'rsatiladi.
- Bu qadamda **dwell (ushlab turish) yo'q** — faqat tugma; avtomatik burchak
  ham ishlamaydi.
- **Bekor qilish:** yarim qo'yilgan chet bo'lsa uni, aks holda oxirgi
  eshik/derazani o'chiradi; hech narsa bo'lmasa balandlik qadamiga qaytaradi.
- **Tayyor** — skanerni yakunlaydi (0 ta eshik bilan ham).
- Bo'yi standart: eshik 2.00 m, sill 0; deraza 1.50 m, sill 0.90 m. Agar
  balandlik o'lchangan bo'lsa va standart sig'masa (eshik bo'yi ≥ shift − 5 sm),
  bo'yi `shift − 0.10` gacha qisqartiriladi; deraza uchun `sill + bo'yi ≤ shift − 0.10`.

## Ko'rib chiqish ekrani (iOS va Android uchun umumiy)

`room_scan_review_page.dart`dagi `ScanDetectionSummary` (son) ostiga
**"Eshik va derazalar"** ro'yxati qo'shiladi: har qatorda tur belgisi, devor
nomi (A, B, C…), eni × bo'yi.

- Qatorni bosish → `DoorWindowModal` tahrir rejimida (tur, eni, bo'yi, deraza
  uchun sill), pastda **O'chirish**.
- **+ Qo'shish** → avval devor tanlanadi (A, B, C… chiplari), keyin shu oyna
  bo'sh holatda; joyi "chapdan" (m) maydoni bilan (`opening_position.dart`
  orqali markaz ulushiga o'giriladi).
- O'zgarish `RoomScanDraft.plan` ni yangilaydi (yangi `RoomPlan` nusxa); 2D
  chizma va sonlar shu zahoti yangilanadi. Saqlash oqimi o'zgarmaydi.
- `DoorWindowModal` kengaytiriladi: ixtiyoriy `initial` (mavjud qiymatlar),
  `showSill` va `onDelete`. Qo'lda o'lchash ustasidagi hozirgi chaqiruvlar
  o'zgarmaydi (hammasi ixtiyoriy parametrlar). "Balkon" turi bu ekranda
  `door` sifatida saqlanadi — ustadagidek.

## Ma'lumot oqimi

### Kotlin (`arscan/`)

Yangi ARCore'siz sinf **`OpeningCapture`** (JVM-test qilinadi):

- Kirish: joriy kontur burchaklari (`FloorPlanCapture.corners`, anchorlar bilan
  yangilanadi) va nishon nuqtasi.
- `snap(p): EdgeHit?` — eng yaqin kontur qirrasi `edge` (burchak i → i+1),
  qirra bo'ylab ulush `t` (0..1, uchlarga qisiladi) va masofa; > 30 sm → null.
- `addEdge(hit, type): OpeningAddResult` — `PENDING` (birinchi chet),
  `ADDED`, `REJECTED_OTHER_WALL`, `REJECTED_TOO_NARROW` (< 0.30 m),
  `REJECTED_OVERLAP` (shu devordagi boshqa opening bilan kesishadi).
- `undo(): Boolean`, `openings: List<CapturedOpening>`.
- `CapturedOpening(type, edge, t0, t1)` — `t0 < t1`. Ulush saqlanadi,
  koordinata emas: anchorlar siljisa ham opening devorga bog'liq qoladi.
  Eni = `(t1 − t0) × qirra uzunligi` (oxirgi kadrdagi).

`FloorPlanCapture.toResult` natijasiga qo'shiladi:

```
"openings": [ {"type": "door"|"window", "edge": Int, "t0": Double, "t1": Double}, ... ]
```

Kanal nomi va qolgan maydonlar o'zgarmaydi; eski Dart (maydonsiz) ham ishlaydi.

### Dart

- `ArScanRaw` ga `openings: List<ArRawOpening>` (yo'q bo'lsa bo'sh).
- `buildArcorePlan` qirralarni kuzatadi. Har bosqich (closure tarqatish,
  `mergeCloseVertices`, `_square`, `removeCollinearVertices`) uchun har
  qolgan cho'qqining **xom indeksi** saqlanadi (geometriya funksiyalarining
  indeks qaytaradigan varianti yoki yonma-yon ro'yxat). Natijada har yakuniy
  devor = xom qirralarning ketma-ket oralig'i `[s, e)`.
- Opening joylash: xom qirra `edge` qaysi yakuniy devorga tushsa, o'sha devor.
  Devor boshidan masofa = oraliqdagi oldingi xom qirralar uzunligi +
  `t × xom qirra uzunligi`, keyin `yakuniy uzunlik / xom yig'indi` ga
  masshtablanadi. Eni xuddi shu nisbatda masshtablanadi.
  `position = (chap + eni/2) / devor uzunligi` (markaz ulushi).
- Devordan chiqib ketsa: eni devor uzunligidan katta bo'lsa — devor
  uzunligiga tenglashtiriladi; chetlari 0..uzunlik ichiga suriladi.
- Yakuniy rejada kesishib qolgan ikki opening — ikkalasi ham qoladi (tahrir
  ekranida ko'rinadi); faqat kamera qadamida ustma-ust qo'yish taqiqlanadi.
- Natija `RoomWall(..., openings: [RoomOpening(type, width, height,
  position, sillHeight)])`, qiymatlar 1 sm gacha yaxlitlanadi.

## Xatolar va chekka holatlar

| Holat | Xatti-harakat |
|---|---|
| Ikki chet turli devorda | Qo'shilmaydi; "Ikkala chet bitta devorda bo'lsin" |
| Eni < 30 sm | Qo'shilmaydi; "Juda tor — chetlarni qayta belgilang" |
| Boshqa opening ustiga tushadi | Qo'shilmaydi; "Bu joyda allaqachon eshik/deraza bor" |
| Nishon devordan > 30 sm | Tugma o'chiq; "Nishonni devor tagiga olib boring" |
| Kuzatuv yo'qoldi | Mavjud ko'rsatma; tugma o'chiq |
| To'g'rilashdan keyin devor ikkiga bo'linmaydi, lekin collinear birlashdi | Xom oraliq orqali to'g'ri devorga tushadi |
| Bekor qilish bilan burchaklarga qaytish | Faqat barcha eshik/derazalar o'chirilgandan keyin mumkin (undo tartibi), shuning uchun kontur o'zgarganda eski `edge` indekslari qolmaydi |

## Tarjimalar

Yangi kalitlar (uz/ru/en, `@key` tavsifi bilan): qadam nomi, ko'rsatma,
"Chet qo'shish", "Tayyor", tur tanlagich, uchta rad xabari, "devor tagiga olib
boring", ko'rib chiqish ekranidagi ro'yxat sarlavhasi, "+ Qo'shish", "O'chirish",
"Deraza tagi", devor tanlash. Kotlin matnlarni hozirgidek `s("…")` orqali
Dart'dan oladi.

## Test

- Kotlin `OpeningCaptureTest`: yopishish va 30 sm chegarasi, uchlarga qisish,
  ikki chet saralanishi, boshqa devor, tor, ustma-ust, undo (yarim/to'liq),
  `toResult` formati.
- Dart `arcore_plan_test`: to'rtburchak va L-shakl; closure xatosi va
  to'g'rilashdan keyin opening to'g'ri devorda, markaz ±1 sm; collinear
  birlashgan devorda; chiqib ketishni qisish; maydonsiz eski natija.
- Widget test: ko'rib chiqish ekranida ro'yxat, tahrir, o'chirish, qo'shish;
  `DoorWindowModal` eski chaqiruvlari o'zgarmagan.
- Telefonda: haqiqiy xona, ruletka bilan solishtirish.

## Doiradan tashqarida

- Eshik/deraza bo'yini kamerada o'lchash (devor tekisligi kerak; oq devorlarda
  ishonchsiz) — standart + tahrir yetarli.
- Avtomatik eshik/deraza topish (ML).
- Bir nechta xona, Depth/RANSAC devorlar.
