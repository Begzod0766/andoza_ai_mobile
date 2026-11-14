# Ilova ichidagi qo'llanma (tutorial): dizayn

Sana: 2026-11-14. Holat: tasdiq kutilmoqda.

## Maqsad va sabab

Foydalanuvchilar ilovani qanday ishlatishni tushunmayapti (egasining kuzatuvi). Qo'llanma ekranning o'zida ishlaydi:
- ekran xiralashadi (blur);
- bitta joy ajratib ko'rsatiladi;
- yonida shu joy nima ekani va qanday ishlatilishi yoziladi.

Qadamlar ketma-ket o'tadi. Qo'llanma **birinchi ochilishda o'zi chiqadi**. Keyin uni **"?" belgisi** orqali qayta ko'rish mumkin.

Muvaffaqiyat: yangi foydalanuvchi yordamsiz loyiha ochadi, Studio'da asboblarni topadi va smetani ko'radi.

## Qamrov (egasi tanlagan: ikkalasi)

Ikkita mustaqil tur bo'ladi:
1. **Ilova turi** (Flutter, `andoza_ai_mobile`). Ilovaning o'z ekranlari uchun.
2. **Studio turi** (React, `andoza_ai/frontend`). 3D Studio uchun, u ilova ichida WebView'da ochiladi.

Ikkinchisi web kodida qilinadi, chunki ilova WebView ichidagi tugmalarning joyini bilmaydi. Loyiha qoidasi ham shunday: "Studio behaviour — andoza_ai frontend'da".

### Maqsadlar
- Birinchi ochilishda o'zi boshlanadi. Har qadamda "Keyingi" va "O'tkazib yuborish" tugmalari bo'ladi.
- Tugagan yoki o'tkazib yuborilgan tur qayta o'zi chiqmaydi.
- "?" belgisi turni istalgan payt qaytadan boshlaydi.
- Matnlar uch tilda: uz, ru, en.

### Maqsad emas
- Video qo'llanma, animatsiyali personaj, interaktiv mashq (masalan, "endi o'zingiz bosing, keyin davom etadi").
- Kim qaysi qadamda chiqib ketganini analitikada kuzatish (keyinroq qo'shilishi mumkin).
- Studio'ning katta ekrandagi (desktop web) ko'rinishi uchun tur.
- Boshqa ekranlar uchun tur: biznes, mebel, skaner ichi.

### Bo'lmasligi kerak (anti-maqsad)
- Tur foydalanuvchini tutib qolmasin. "O'tkazib yuborish" doim ko'rinib tursin, tur birinchi kirishdan keyin bir martadan ko'p o'zi chiqmasin.
- Tur yo'q tugmani ko'rsatmasin, masalan loyiha bo'lmaganda loyiha kartasini. Bunday qadam o'tkazib yuboriladi.
- Studio turi ochiq doira menyu, tanlangan buyum yoki panel bilan to'qnashmasin.

## Yondashuv

Ko'rib chiqilganlar:

| Qism | Variant | Afzallik | Kamchilik |
|---|---|---|---|
| Ilova | **1a. `tutorial_coach_mark` kutubxonasi** (tanlandi) | Ajratish, blur, matn joylashuvi tayyor; ko'p sinalgan | Yangi kutubxona; ko'rinish uning imkoniyati bilan cheklangan |
| Ilova | 1b. O'zimiz yozamiz | Dizaynga to'liq mos, yangi kutubxona yo'q | Taxminan 2× ish (joylashuv, aylantirish) |
| Studio | **2a. Mavjud `TapHint` usulida o'zimiz yozamiz** (tanlandi) | Kutubxonasiz; ko'p holatli sahnani (doira menyu, qulf) o'zimiz boshqaramiz | Ajratish va joylashuvni o'zimiz yozamiz |
| Studio | 2b. `driver.js` | Tez | Yangi kutubxona; 3D sahna, doira menyu va qatlamlarga moslash kerak |

Egasi **1a + 2a** ni tanladi.

## Dizayn

### Umumiy ko'rinish (ikkala turda bir xil)

```
┌───────────────────────────┐
│░░░░░░░░░░░░░░░░░░░░░[ ? ]│
│░░ xira fon ░░░░░░░░░░░░░░░│
│░░░░░░░░░┌─────────┐░░░░░░│
│░░░░░░░░░│  [ + ]  │░░░░░░│  ← ajratilgan joy (atrofida yorug' chegara)
│░░░░░░░░░└─────────┘░░░░░░│
│░░┌─────────────────────┐░│
│░░│ Sarlavha            │░│
│░░│ 1–2 qatorlik izoh   │░│
│░░│ 1/6  O'tkazish  ▶   │░│
│░░└─────────────────────┘░│
└───────────────────────────┘
```

- Fon xiralashadi (blur) va qorayadi. Ajratilgan joy aniq ko'rinib turadi.
- Izoh kartasida: sarlavha, 1–2 qatorlik izoh, qadam raqami ("1/6"), "O'tkazib yuborish" va "Keyingi" tugmalari. Oxirgi qadamda "Keyingi" o'rniga "Tushunarli" yoziladi.
- Xira fonga bosish qadamni o'zgartirmaydi. Tasodifiy bosish turni yopib yubormasligi kerak.
- **Ajratilgan joyga bosish "Keyingi" bilan teng bo'ladi. Asl tugma ishlamaydi** (mening qarorim). Aks holda "+" yoki "Davom etish" tur o'rtasida boshqa ekranni ochib yuboradi. `tutorial_coach_mark` da nishonga bosish asl vidjetga o'tkazilmaydi. Web qatlami nishon ustidagi bosishni ushlab qoladi.

### Kim ko'radi (egasi tanlagan: A)

**Hamma bir marta ko'radi**: yangi foydalanuvchilar ham, hozirgilar ham.
- Ilova turi ilova yangilangandan keyin uy sahifasi birinchi ochilganda chiqadi.
- Studio turi web chiqqandan keyin Studio birinchi ochilganda chiqadi. Hozirgi `TapHint` ni allaqachon yopganlarga ham chiqadi.

### Ilova turi (Flutter)

**Qachon boshlanadi:** uy sahifasi (`/`) birinchi marta to'liq yuklanganda. Kirish va onboarding'dan keyin, loyihalar ro'yxati kelgach boshlanadi.

**Boshqa oynalar bilan tartib** (mening qarorim). Uy sahifasining birinchi ochilishida boshqa narsalar ham chiqadi:
- bildirishnoma ruxsati so'rovi (`PushPermissionPrompt`, `/` marshrutini o'raydi);
- AppShell'ning "uzilgan skanerni davom ettirish" oynasi;
- biznes arizasiga yo'naltirish.

Tur ulardan keyin boshlanadi. Shu ochilishda ulardan biri ko'rsatilgan bo'lsa, tur keyingi ochilishga qoladi. Tur hech qachon boshqa oyna ostida qolmasligi kerak.

**Qadamlar.** Kalitlar va matnlar ARB'da bo'ladi, quyidagilar matn ma'nosi:

| # | Ajratiladi | Izoh (uz) | Shart |
|---|---|---|---|
| 1 | Pastki paneldagi **"+"** | Yangi loyiha: xonani LiDAR bilan skanerlang yoki o'lchamini o'zingiz kiriting | doim |
| 2 | Birinchi loyiha kartasining **"Davom etish"** tugmasi | 3D Studio'ni ochadi: pol, devor, mebel, santexnika va boshqalarni shu yerda tanlaysiz | loyiha bo'lsa |
| 3 | Kartadagi **Smeta** raqami | Ta'mir taxminan qanchaga tushishi. Batafsil smeta Studio'da | loyiha bo'lsa |
| 4 | Pastki paneldagi **Do'kon** | Materiallar va mebel, do'konlardan | doim |
| 5 | Pastki paneldagi **Ustalar** | Elektrik, santexnik, plitkachi va boshqa ustalar, xaritada va ro'yxatda | doim |
| 6 | Uy sahifasi tepasidagi **"?"** | Bu qo'llanmani istalgan payt shu yerdan qayta ko'ring | doim |

Loyiha bo'lmasa (bo'sh uy sahifasi), 2- va 3-qadamlar o'tkazib yuboriladi va raqamlash 1/4 dan boshlanadi.

**"?" belgisi:**
- Uy sahifasining tepasida, filtr tugmalari qatorining o'ng chetida turadi.
- Bo'sh uy sahifasida xuddi shu joyda turadi.
- Bosilganda turni 1-qadamdan boshlaydi.

**E8 "Demo qo'llanma"** (mening qarorim):
- Bo'sh uy sahifasidagi ikkala doiracha (`homeStoryDemoGuide`, `homeStoryDemo`) va Profildagi qator endi statik E8 ekrani o'rniga turni ishga tushiradi.
- Profildan bosilganda avval uy sahifasiga (`/`) o'tiladi, keyin tur 1-qadamdan boshlanadi.
- E8 ekranining o'zi kodda qoladi, lekin unga hech qayerdan o'tilmaydi.

**"Ko'rildi" belgisi:**
- `shared_preferences` dagi `tour.home.v1.done = true`.
- Qurilmaga bog'liq, akkauntga emas.
- Tur tugaganda ham, o'tkazib yuborilganda ham qo'yiladi.
- Kalitda versiya bor: qadamlar jiddiy o'zgarsa, `v2` ga oshirib, turni qayta ko'rsatish mumkin.

**Texnik:**
- `tutorial_coach_mark` paketi ishlatiladi. Har bir nishon vidjetga `GlobalKey` beriladi.
- Blur uchun paketning `imageFilter` parametri ishlatiladi.
- Nishon ekranda ko'rinmasa yoki hali chizilmagan bo'lsa, o'sha qadam o'tkazib yuboriladi.

### Studio turi (web, `andoza_ai/frontend`)

**Qachon boshlanadi:**
- Studio'ning 3D ko'rinishi telefon tartibida (`useCompactStudio()` true) birinchi marta ochilganda.
- Ilovadagi WebView ham shu tartibda ochiladi.
- **Faqat jonli 3D tahrir ko'rinishida boshlanadi** (mening qarorim), ya'ni burchak menyusi ko'rinib turganda (`showsEditingCorners`). Panorama, kamera stansiyasi yoki 2D plan ochiq bo'lsa, tur kutib turadi va "ko'rildi" deb belgilanmaydi.
- **Kodning joylashuvi:** tur va uning holati `StudioPage` darajasida turadi, chunki ⋮, ↶ ↷ va "?" sarlavhada, ya'ni `StudioPage` da. 3D nishonlar (sahna, burchak menyusi, qulf, kamera) esa `ThreeDPage` da. Ikkalasi bir xil `data-tour` atributlari orqali topiladi.

**Qadamlar:**

| # | Ajratiladi | Izoh (uz) |
|---|---|---|
| 1 | 3D sahna (devor/pol) | Devor yoki polga bosing: shu joy uchun asboblar chiqadi (rang, plitka, oboy va boshqalar) |
| 2 | Burchakdagi menyu tugmasi (↖, `QuarterArcMenu`) | Bo'limlar: Mebel, Santexnika, Rang, Chiroq |
| 3 | ⋮ tugmasi (faqat tugmaning o'zi, menyu ochilmaydi; mening qarorim) | "⋮ → Smeta": narxlar, material va ish ro'yxati, PDF |
| 4 | ↶ ↷ tugmalari | Oxirgi amalni bekor qilish va qaytarish |
| 5 | Qulf tugmasi | Kamerani qotiradi: ekranni surganda xona aylanmaydi |
| 6 | Kamera tugmasi (`CameraBar`) | Tayyor kameralar va realistik render |
| 7 | Tepadagi **"?"** | Qo'llanmani istalgan payt qayta ko'ring |

**Hozirgi `TapHint`:**
- Telefonda bir marta chiqadigan "yuzaga bosing" maslahati turning 1-qadamiga aylanadi.
- Tur ko'rsatilganda `TapHint` alohida chiqmaydi.
- Uning `studio.tapHint.seen` kaliti ham tur tugaganda qo'yiladi.

**Tur boshlanishidan oldin:**
- ochiq doira menyu yopiladi;
- tanlangan buyum bekor qilinadi;
- qulf yoqilgan bo'lsa, tur baribir ko'rsatiladi.

Qadam nishoni ko'rinmasa (masalan, kamera tugmasi shu xonada yo'q), qadam o'tkazib yuboriladi.

**"?" belgisi:**
- Studio sarlavhasida, ⋮ yonida turadi.
- Telefon tartibida ko'rinadi.
- Bosilganda turni 1-qadamdan boshlaydi.

**"Ko'rildi" belgisi:**
- `localStorage` dagi `studio.tour.v1.done = "1"`. `TapHint` qanday yozsa, shunday: xotira ishlamasa yoki xato bersa, tur keyingi safar yana chiqadi.
- WebView'ning `localStorage` i ilova o'chirilmaguncha saqlanadi.

**Texnik:**
- Yangi kutubxonasiz `StudioTour` komponenti yoziladi.
- Nishonlar `data-tour="..."` atributi bilan belgilanadi. Ajratilgan joy `getBoundingClientRect` orqali olinadi.
- Fon `backdrop-filter: blur()` bilan xiralashadi. Ajratilgan joy fonda "teshik" bo'lib ochiladi (masalan, katta `box-shadow` yoki SVG niqob).
- Matnlar `react-i18next` locales'da: `uz.json`, `ru.json`, `en.json`.

## Cheklovlar

- Ilovada foydalanuvchiga ko'rinadigan matn faqat `AppLocalizations` orqali yoziladi. Kalitlar `app_uz.arb` (`@key` tavsifi bilan), `app_ru.arb` va `app_en.arb` ga birga qo'shiladi.
- Ilovaga yangi paket qo'shiladi: `tutorial_coach_mark`. Web'ga yangi kutubxona qo'shilmaydi.
- Studio o'zgarishlari `andoza_ai` da, worktree'da qilinadi. Ular web deploy orqali chiqadi va ilova yangilanishini kutmaydi.
- Ilova turi do'konlarga yangi build orqali chiqadi: iOS'da 1.0.2 va undan keyingi, Play'da yangi build.
- Ikkala tur ham ekran o'lchami va aylantirishga moslashishi kerak. Tekshiruv iPhone 17 Pro simulyatorida va Android emulyatorida.

## Quruvchiga qoldirilganlar

- Izoh kartasining aniq rangi va o'lchami. Ilova dizayn tokenlari (`DesignTokens`) va Studio mavzusi (kun/tun) ichida bo'ladi.
- Blur kuchi va fon qoraligi. Matn o'qiladigan, ajratilgan joy aniq ko'rinadigan darajada.
- Matnlarning yakuniy tahriri (yuqoridagi ma'no saqlansin), ru va en tarjimalari.
- Testlar: ilova tomonda "ko'rildi" belgisi va qadamlarni tanlash mantig'i uchun unit test, nishonsiz qadam o'tkazib yuborilishi uchun vidjet test. Web tomonda tur holati va kalit uchun vitest.
- Yetkazib berish tartibi: avval web Studio turi (tezroq chiqadi), keyin ilova turi. Yoki parallel.
