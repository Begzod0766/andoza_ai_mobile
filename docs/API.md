# Backend bilan aloqa

Ilova `andoza_ai` backend'iga (FastAPI) ulanadi. Productionda:
`https://andozaai.uz/api/v1`. Manzillar build vaqtida
`--dart-define` orqali beriladi, qarang: [BUILD_AND_RELEASE.md](BUILD_AND_RELEASE.md).
Backend tomonidagi hujjatlar: `andoza_ai/docs/` (ARCHITECTURE, DATA_MODEL, INTEGRATIONS).

Eski `andoza.jumaniyozov.uz` (1.0.0+24 gacha) API va media uchun hali ishlaydi, lekin
uning sahifalari 301 bilan `andozaai.uz` ga yo'naltiriladi. Studio WebView faqat
`STUDIO_BASE_URL` domeniga o'tishga ruxsat beradi, shuning uchun eski domenli build'larda
Studio "Frame load interrupted" bilan ochilmaydi (handoff §9.1).

## Klient (`lib/services/api_client.dart`)

- **Asos:** Dio. Ulanish timeout'i 10 s, javob kutish 30 s.
- **Sarlavhalar:**
  - har so'rovda `X-Client-Type: mobile` — backend tokenlarni cookie'da emas, javob tanasida qaytaradi;
  - login qilingan bo'lsa, `Authorization: Bearer <access token>`.
- **Token yangilash:**
  - 401 kelsa (auth yo'llaridan boshqa joyda), klient `POST /auth/refresh` ni `Cookie: refresh_token=…` bilan chaqiradi.
  - Ikkala tokenni yangilab, so'rovni bir marta qaytaradi.
  - Bir vaqtda kelgan bir nechta 401 bitta yangilashga birlashadi.
  - Yangilash muvaffaqiyatsiz bo'lsa, tokenlar o'chiriladi va foydalanuvchi login sahifasiga qaytariladi.
- **Xatolar:** `ApiException` ga o'raladi. Foydalanuvchiga ko'rinadigan matnni `utils/error_mapper.dart` beradi.
- **Til:** har bir so'rov `Accept-Language: uz|ru|en` (ilova tili) bilan ketadi, shuning uchun server xato matnlarini shu tilda qaytaradi. Tanlangan til akkauntga `PATCH /auth/me {language}` bilan yoziladi.
- **Log:** faqat debug rejimida, faqat metod, yo'l va status. So'rov va javob tanasi log qilinmaydi.
- **Tokenlar:** `flutter_secure_storage` da (`services/secure_storage.dart`), kalitlar `auth_token`, `refresh_token`, `user_id`.
  - Android'da EncryptedSharedPreferences.
  - iOS'da Keychain, `first_unlock_this_device` rejimida.

## Endpoint'lar

Hammasi `/api/v1` ga nisbatan. Har bir mavzu uchun bitta repository fayli (`lib/repositories/`).

| Mavzu | So'rovlar | Fayl |
|---|---|---|
| Kirish | `POST /auth/login`, `/auth/register`, `/auth/otp/request`, `/auth/otp/verify`, `/auth/google` (`id_token`), `/auth/apple` (`identity_token`, `name` faqat birinchi kirishda; faqat iOS), `/auth/refresh`, `/auth/logout`, `/auth/delete-account`; `GET /auth/me`, `PATCH /auth/me` (`language`) | `auth_repository.dart`, `services/api_client.dart` |
| Kvartira va xonalar | `GET/POST /apartments`; `GET/PATCH/DELETE /apartments/{id}`; `GET/POST /apartments/{id}/rooms`; `GET/PATCH/DELETE /rooms/{id}` | `apartment_repository.dart` |
| Xona holati | `GET/POST/PATCH /rooms/{id}/state`; `GET /rooms/{id}/delta` | `room_state_repository.dart` |
| Bezak va elektr | `GET/PUT /rooms/{id}/decoration`; `GET/PUT /rooms/{id}/electrical` | `decoration_repository.dart`, `electrical_repository.dart` |
| Smeta | `POST /rooms/{id}/estimate/preview`, `POST /rooms/{id}/estimate`; `GET /rooms/{id}/estimates`, `GET /estimates/{id}`; `GET /rooms/{id}/estimate/pdf` | `estimate_repository.dart` |
| AI | `POST /rooms/{id}/ai-build` (SSE oqim; tanlangan uslub so'rov boshiga `"Hi-Tech uslubida. "` deb qo'shiladi, `styledPrompt`); `POST /rooms/{id}/smeta/ask` | `ai_repository.dart` |
| Skaner | `POST /rooms/{id}/room-scan` (multipart: `usdz`, `room_json`, ixtiyoriy `scan_group` — ko'p xonali sessiya); `POST /rooms/{id}/room-scan/objects`; `POST /rooms/{id}/thumbnail` | `features/room_scan/room_scan_service.dart` |
| Katalog | `GET /materials`, `/materials/{id}/offers`, `/furniture` (`?store=` bitta do'konniki), `/furniture/{id}`, `/stores`, `/stores/{id}`, `/ustalar`. Ro'yxatlar 100 talik sahifalar bo'yicha oxirigacha olinadi; do'kon qidiruvi serverda, `?q=` bilan (≤ 100 belgi) | `catalog_repository.dart` |
| Buyurtmalar | `GET/POST /orders` | `orders_repository.dart` |
| Oboylar | `GET /wallpapers`; `POST /wallpapers` (multipart) | `wallpaper_repository.dart` |
| Biznes: rollar | `GET /account/roles` | `business_repository.dart` |
| Biznes: do'kon | `GET/POST/PATCH /seller/store`, `POST /seller/store/resubmit`; `GET/POST /seller/furniture`, `PATCH/DELETE /seller/furniture/{id}`; `GET /seller/inquiries`, `PATCH /seller/inquiries/{id}`; `GET /seller/orders`, `PATCH /seller/orders/{id}/status`; `GET /seller/stats` | `business_repository.dart` |
| Biznes: rasmdan model | `POST /models/from-photo`; `GET /jobs/{id}`; `GET /models/from-photo/glb` | `business_repository.dart` |
| Biznes: usta | `GET/POST/PATCH /usta/profile`, `POST /usta/profile/resubmit`; `GET/POST /usta/portfolio`, `DELETE /usta/portfolio/{id}`; `GET /ustalar/{id}/portfolio`; `GET /usta/leads`, `PATCH /usta/leads/{id}`; `POST /leads` | `business_repository.dart` |
| Shikoyat | `POST /reports` (`target_type`: `usta` / `product` / `seller` / `portfolio_item` / `wallpaper`, `target_id`, `reason`: `spam` / `inappropriate` / `fraud` / `other`, `details?`). Ustani bloklash faqat qurilmada (`blocked_ustalar`, SharedPreferences) | `features/moderation/report_repository.dart` |

3D studiya WebView ichida veb-frontend orqali ishlaydi va o'z so'rovlarini
o'zi yuboradi. Ilova unga faqat tokenlarni beradi, qarang:
[ARCHITECTURE.md](ARCHITECTURE.md#3d-studiya-webview).

## Server rad etadigan qiymatlar

Server quyidagilarni **422** bilan qaytaradi. Ilova ularni yuborishdan oldin o'zi
tekshiradi, shunda forma nima noto'g'ri ekanini aytadi:

- **Telefon** (`/orders`, `/leads` `contact_phone`, `/seller/store`, `/usta/profile`):
  bo'sh joy, `-`, `(`, `)` olib tashlangach `^\+?998\d{9}$` bo'lishi kerak. Server uni
  `+998XXXXXXXXX` ko'rinishida saqlaydi. Tekshiruv `lib/utils/phone.dart`da
  (`normalizeUzPhone`), web'dagi nusxasi `frontend/src/lib/phone.ts`.
  Checkout va usta chaqirishda telefon majburiy, do'kon formalarida ixtiyoriy.
- **Buyurtma miqdori:** 0 dan katta va 100 000 gacha. Savat bu chegaradan oshirmaydi
  (`maxLineQuantity`).
- **Ro'yxatdan o'tish:** username 3–50 belgi (bo'sh joylarsiz), parol kamida 6 belgi.
- **Bo'sh nom:** faqat bo'sh joydan iborat do'kon yoki usta nomi.

422 javobidagi `detail` ikki xil bo'ladi. Pydantic ro'yxati (`[{loc, msg, type}]`)
inglizcha, shuning uchun foydalanuvchiga umumiy xabar ko'rsatiladi. Oddiy satr
(masalan, `"Noto'g'ri qiymat yuborildi."`) esa `mapErrorWithServerDetail` orqali
o'z holicha ko'rsatiladi.

`POST /leads`da `room_id` sifatida saqlangan xonaning server id'si yuboriladi
(`roomPersistenceProvider`). Server shu xonaning oxirgi saqlangan smetasini
biriktiradi.

**Mebel uslublari** (`styles`): `neoklassika`, `klassik`, `zamonaviy`, `hitech`,
`minimalist`, `skandinav`, `loft`, `milliy` (`furnitureStyles`). Hech biri
tanlanmasa, model hamma uslubga mos. `POST /seller/furniture` (multipart) ularni
vergul bilan bitta `styles` maydonida oladi; `PATCH /seller/furniture/{id}`
`styles: [...]` ro'yxatini oladi: `[]` tozalaydi, maydon yo'q bo'lsa o'zgarmaydi.

## Yangi endpoint qo'shish

1. Mos `lib/repositories/<mavzu>_repository.dart` ga metod qo'shing. `ApiClient` orqali chaqiring, to'g'ridan-to'g'ri Dio yaratmang.
2. Javob modeli `lib/models/` da (freezed bo'lsa, `dart run build_runner build --delete-conflicting-outputs`).
3. Ekranga provider orqali bering (`lib/providers/`).
4. Test: `test/` da repository yoki provider testi (`mocktail` bilan).
5. Shu jadvalga qator qo'shing.
