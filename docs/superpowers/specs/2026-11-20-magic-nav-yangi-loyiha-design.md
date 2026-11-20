# Sehrli pastki menyu va «Yangi loyiha» oynasi — dizayn

Sana: 2026-11-20 · Egasi tasdiqlagan.

## Maqsad

1. **Pastki menyu** (`AppShell`) — 5 ta teng element: Uy, Do'kon, «+», Ustalar,
   Profil. «+» endi alohida qizil tugma emas, oddiy 5-element.
   Faol elementning ikonkasi menyu ustidan ko'tarilgan ko'k doira ichida turadi
   (oq ikonka), oq menyuda doira ostida botiq o'yiq bor. Boshqa element
   tanlansa, doira va o'yiq unga ~300 ms davomida silliq siljiydi. Faol bo'lmagan
   elementlar ostida mavjud tarjima qilingan nomlar qoladi. Ranglar —
   `DesignTokens` (primaryBlue, white). Yangi paket yo'q: `CustomPainter` +
   `TweenAnimationBuilder`.
2. **«Yangi loyiha» oynasi** menyu USTIDA, butun balandlikda. «+» bosilganda doira
   «+» ga o'tadi va oyna pastdan ko'tariladi. Oyna `Scaffold` body qismida
   (Stack ichida) yashaydi — menyu ostida ham, ustida ham emas, shuning uchun
   menyu ko'rinadi va bosiladi (`extendBody: true` ishlatilmaydi — CLAUDE.md).
   Yopish: boshqa element bosilsa — oyna yopiladi va doira o'sha elementga
   o'tadi; pastga surish, «+» ni yana bosish yoki tizim «Orqaga» tugmasi —
   oyna yopiladi, doira oldingi bo'limga qaytadi.
3. **Yagona kirish nuqtasi:** `showNewProjectSheet(context)` qoladi, lekin endi
   Riverpod `newProjectSheetOpenProvider` ni yoqadi. Chaqiruvchi shell
   tashqarisida bo'lsa (`/setup/summary`, `/onboarding/e8` — root navigator),
   o'sha mazmun shu ekran ustida modal oyna bo'lib ochiladi — yopilganda yoki
   kartadan ochilgan oqimdan «Orqaga» bosilganda foydalanuvchi o'z joyiga
   qaytadi (nazoratchi qarori, 2026-11-20). Kirish/chiqishda va boshqa yo'lga
   o'tilganda (deep link, push) oyna yopiladi.
4. **Uchta animatsiyali karta** uzun tavsiflar o'rniga: tepada animatsiya,
   keyin sarlavha, keyin 3–5 so'zli qisqa izoh (ekran o'quvchi uchun ham).
   - **3D Master:** wizardning izometrik qutisi (`IsometricRoomView`); barmoq
     burchakni tortadi, devorlar cho'ziladi, «3.0 m × 2.5 m» → «4.0 m × 3.0 m».
   - **LiDAR skaner** (Androidda — «Kamera bilan o'lchash», `_isAndroid` mantiqi
     saqlanadi): telefon belgisi reja atrofida aylanadi, devorlar birma-bir
     paydo bo'ladi, oxirida 3D quti chiqadi.
   - **O'zingiz chizing:** barmoq bo'sh kanvasda xona konturini chizadi, chiziq
     yopiladi va tomonlarda metr raqamlari chiqadi.
   - Har biri 3–4 s da takrorlanadi; animatsiya ichida faqat raqamlar.
     `MediaQuery.disableAnimations` yoqilgan bo'lsa — bitta statik kadr.
   - Bosish amallari o'zgarmaydi: `startNewProject` / `continueCurrentProject`,
     keyin `/wizard`, `/scanning/roomplan`, `/setup/draw`.
5. **l10n:** yangi izohlar uz/ru/en `.arb` fayllariga; endi ishlatilmaydigan
   `*Desc` kalitlari o'chiriladi.

## Yondashuvlar

- **A — Flutterda chizish (tanlandi).** `CustomPainter` va oddiy animatsiyalar:
  yangi paket yo'q, ranglar va raqamlar tilga/tokenlarga bog'liq, hajm kichik,
  `disableAnimations` ga oson moslashadi.
- **B — video.** Og'ir, tarjima qilinmaydi, ekran o'quvchiga yopiq — rad etildi.
- **C — Lottie.** Yangi paket va dizayner fayllari kerak — rad etildi.
- «+» ni 5-element qilish va oynani menyu ustida to'liq balandlikda ochish —
  egasining tanlovi.

## Chegaradan tashqari

Yangi paketlar, video, ovoz, versiya oshirish.
