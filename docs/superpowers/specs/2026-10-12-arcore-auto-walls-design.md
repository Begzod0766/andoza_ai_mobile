# ARCore skaner: devorlarni avtomatik topish va burchakka yopishish — dizayn

Sana: 2026-10-12. Holat: tasdiqlangan dizayn.
Asos: `2026-10-11-arcore-room-scan-design.md` (A bosqich) — shu skanerning
"burchaklar" qadami o'zgaradi, qolgani o'sha hujjatdagidek.

## Muammo

Telefonda sinov: pol va burchaklar topiladi, lekin ARPlan 3D'ga nisbatan juda
ko'p qo'lda ish — har burchakka nishonni aniq keltirib tugma bosish kerak.
Foydalanuvchi ARPlan'da ikki narsani osonroq deb topdi:
- **A** — burchak tugmasiz, nishon burchakka "yopishib" qo'yiladi;
- **B** — devorlar telefonni aylantirganda o'zi topiladi.

## Maqsad

Burchaklar qadamida tugma bosish deyarli kerak bo'lmasin: devorlar avtomatik
ko'rinadi, ularning kesishgan joylari burchak bo'lib o'zi qo'shiladi; devor
topilmagan joyda nishonni ushlab turish kifoya. Natija (`corners + height`),
kanal formati, Dart to'g'rilash va ko'rib chiqish ekrani o'zgarmaydi.

Muvaffaqiyat: naqshli devorli to'rtburchak xonada burchaklar qadami tugma
bosmasdan tugaydi; oq devorli xonada eski usuldan sekin emas; S25 Ultra va
A54'da aniqlik A bosqich mezonida (perimetr ≤ 3%, balandlik ≤ 5 sm).

## Foydalanuvchi oqimi

Qadamlar o'zgarmaydi: **pol → burchaklar → balandlik**.

Burchaklar qadamida ekranda:
- ARCore topgan har devor — polda ko'k chiziq;
- ikki devor kesishgan joyda — taklif qilingan burchak (bo'sh doira).

Burchak qo'shilishining uch yo'li:
1. **Avtomatik.** Taklif barqaror bo'lganda (quyida) o'zi qabul qilinadi —
   to'la nuqtaga aylanadi, qisqa tebranish.
2. **Yopishish (A).** Nishon taklifga ≤ 15 sm yaqinlashsa unga yopishadi;
   telefon ~1 s qimirlamasa qo'shiladi. Nishon atrofida to'lib boruvchi aylana.
3. **Qo'lda (zaxira).** Devor topilmagan joyda nishon ostidagi pol nuqtasi
   ~1 s qimirlamasa qo'shiladi. "Burchak qo'shish" tugmasi ham qoladi.

Tartib qoidalari:
- **Qo'shnilik:** avtomatik (1-yo'l) burchak faqat oxirgi qo'shilgan burchak
  shu taklifning ikki devoridan biri ustida (≤ 15 sm) yotsa olinadi; birinchi
  burchak uchun shart yo'q. Aks holda taklif bo'lib turadi — uni 2-yo'l bilan
  olish mumkin (yopishish ongli harakat, qoida unga qo'llanmaydi).
- **Yopilish:** birinchi burchakka (≤ 20 sm) qaytilganda kontur yopiladi —
  avvalgidek, qaysi yo'l bilan qaytilganidan qat'i nazar.
- **Bekor qilish** oxirgi burchakni o'chiradi. O'chirilgan avtomatik burchak
  joyi (20 sm radius) "rad etilgan" bo'ladi va 1-yo'l bilan qayta
  qo'shilmaydi; 2- va 3-yo'l bilan qo'shish mumkin.

Avtomatik rejimni o'chirish sozlamasi qilinmaydi (YAGNI).

## Devorlarni topish

Manba — ARCore vertikal tekisliklari (sessiyada `HORIZONTAL_AND_VERTICAL` va
Depth `AUTOMATIC` allaqachon yoqilgan). Har kadr: `Plane.Type.VERTICAL`,
`TrackingState.TRACKING`, `subsumedBy == null` bo'lgan tekisliklar olinadi.
Har biri pol ustidagi 2D (XZ) chiziq kesmasiga aylantiriladi: yo'nalish —
tekislik pozasining gorizontal o'qi; uchlar — tekislik poligonining shu o'qqa
proyeksiyasidagi eng chetki nuqtalar.

## Komponentlar

Yangi, ARCore'siz (JVM-test qilinadi), `arscan/` paketida:

**`WallTracker`**
- Kirish: `WallObs(id: Int, cx: Float, cz: Float, dx: Float, dz: Float,
  halfLength: Float)` ro'yxati va kadr vaqti (ms).
- Birlashtirish: yo'nalish farqi ≤ 5° va bir-biridan masofa ≤ 8 sm bo'lgan
  kesmalar bitta devor.
- Taklif: ikki devor orasidagi burchak ≥ 30° va kesishish nuqtasi har
  ikkalasining yaqin uchidan ≤ 50 sm bo'lsa.
- Har taklif devor juftligi bo'yicha kuzatiladi; 1000 ms davomida 5 sm dan kam
  siljigan va ikkala devorning ko'rinadigan uzunligi ≥ 50 sm bo'lsa — barqaror.
- Chiqish: devor kesmalari (chizish uchun) va takliflar
  (`CornerCandidate(key, x, z, stable, wallA, wallB)`).

**`DwellDetector`**
- Kirish: nishonning pol nuqtasi (yoki null) va kadr vaqti.
- 1000 ms davomida 3 sm radiusda qolsa — bir marta "fire"; nishon 15 sm
  uzoqlashmaguncha qayta ishlamaydi.
- Chiqish: `progress` 0–1 (aylana uchun) va `fired`.

**`FloorPlanCapture`** (mavjud) ga qo'shiladi:
- `acceptsAuto(c: CornerCandidate, walls): Boolean` — qo'shnilik qoidasi va
  rad etilgan joylar tekshiruvi;
- `undo()` o'chirgan burchak avtomatik qo'shilgan bo'lsa, uning joyini rad
  etilganlar ro'yxatiga yozadi.

**`ArScanActivity`** (GL oqimi, har kadr): tekisliklar → `WallTracker` →
barqaror va qabul qilinadigan taklif bo'lsa `addCorner` (anchor bilan);
aks holda nishon → yopishish (eng yaqin taklif ≤ 15 sm) → `DwellDetector` →
`addCorner`. UI'ga o'zgarmas snapshot uzatiladi (oldingi race tuzatishidagi
qoida). Tebranish — burchak qo'shilganda.

**`ArRenderer`**: devor chiziqlari (ko'k), takliflar (bo'sh doira), to'lish
aylanasi.

Flutter tomoni, `andoza/arscan` kanali, `arcore_plan.dart` o'zgarmaydi.

## Doiradan tashqarida

- Depth nuqtalaridan devor chizig'i yasash (RANSAC) — oq devorlarda vertikal
  tekislik chiqmasa; faqat telefon sinovi zarurligini ko'rsatsa, alohida.
- Eshik/derazalar (B bosqich), bir nechta xona.

## Xatolar va chekka holatlar

| Holat | Xatti-harakat |
|---|---|
| Devor topilmadi (oq devor) | Takliflar yo'q; 3-yo'l (ushlab turish) va tugma ishlaydi |
| Ikki parallel devor | Burchak taklifi chiqmaydi (≥ 30° sharti) |
| Xonaning narigi devorlari kesishadi | Taklif chiqmaydi (≤ 50 sm uchidan sharti) |
| Taklif titraydi | Barqaror bo'lmaguncha avtomatik olinmaydi |
| Avtomatik burchak noto'g'ri | Bekor qilish; o'sha joy qayta avtomatik qo'shilmaydi |
| Kuzatuv yo'qoldi | Avvalgidek: qo'shish to'xtaydi, ushlab turish hisoblagichi nolga tushadi |

## Test qilish

**Avtomatik (Kotlin JVM):**
- `WallTracker`: to'g'ri burchakli xona → 4 taklif; L-shakl → 6; parallel
  devorlar → 0; bir devorning ikki bo'lagi → bitta devor; uzoq devorlar → 0;
  barqarorlik vaqti va siljish chegarasi.
- `DwellDetector`: 1 s ushlab turish → bitta fire; titrash (> 3 sm) → yo'q;
  fire'dan keyin 15 sm uzoqlashmaguncha qayta yo'q; null nishon → nolga.
- `FloorPlanCapture`: qo'shnilik qoidasi; birinchi burchak; rad etilgan joy.

**Qo'lda (S25 Ultra va A54):** naqshli va oq devorli xona; burchaklar qadami
vaqti va tugma bosishlar soni eski versiya bilan solishtiriladi; A bosqichning
5 tekshiruvi qayta o'tadi.

## Tayyorlik mezoni

- Avtomatik testlar yashil, `flutter analyze` toza, `flutter test` yashil.
- Naqshli devorli xonada burchaklar qadami tugma bosmasdan tugaydi.
- Aniqlik A bosqich mezonida.
