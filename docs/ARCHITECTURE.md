# andoza.ai mobil ilovasi: arxitektura

andoza.ai'ning Android va iOS ilovasi (Flutter). Backend va veb-studiya alohida
repoda: [`andoza_ai`](https://github.com/Begzod10/andoza_ai) (FastAPI + React).
Bu ilova o'sha backend'ning mobil klienti. 3D studiya esa ilova ichida
WebView orqali veb-studiyadan ochiladi.

Tegishli hujjatlar:
- [API.md](API.md) — ilova chaqiradigan backend endpoint'lari, tokenlar.
- [BUILD_AND_RELEASE.md](BUILD_AND_RELEASE.md) — sozlamalar, build, imzolash, CI, testlar.
- [mobile/IOS_BUILD.md](mobile/IOS_BUILD.md) — iOS build va TestFlight batafsil.
- [RELEASE_SIGNING.md](RELEASE_SIGNING.md) — Android imzolash kaliti.
- [room_sketch_geometry.md](room_sketch_geometry.md) — "xonani chizish" geometriyasi.
- [../LOCALIZATION.md](../LOCALIZATION.md) — tillar (uz, ru, en).

## Stek

| Qism | Paket | Nima uchun |
|---|---|---|
| Til va SDK | Dart `^3.13.0`, Flutter 3.47.5 (CI'da) | |
| Holat | `flutter_riverpod` 2.x | Provider, StateNotifier, Notifier |
| Navigatsiya | `go_router` 12.x | Yo'llar va autentifikatsiya yo'naltirishi |
| HTTP | `dio` 5.x | API klient. AI quruvchi uchun SSE: `services/sse_client.dart` |
| Saqlash | `flutter_secure_storage`, `shared_preferences` | Tokenlar (xavfsiz); til va tugallanmagan skaner |
| Modellar | `freezed`, `json_serializable` | Kod generatsiyasi (`build_runner`) |
| 3D studiya | `webview_flutter` | Veb-studiyani ilova ichida ochish |
| Xarita | `flutter_map`, `flutter_map_marker_cluster`, `latlong2` | Ustalar xaritasi |
| Boshqalar | `image_picker`, `share_plus`, `path_provider`, `url_launcher`, `cached_network_image`, `package_info_plus`, `intl` | Rasmlar, smeta PDF ulashish, havolalar, versiya |

Ilovada 3D paket yo'q: 3D ish to'liq veb-studiyada bajariladi. Shrift — Inter (`assets/fonts`).

## Papkalar (`lib/`)

| Papka | Vazifasi |
|---|---|
| `main.dart` | `ProviderScope` → `MaterialApp.router`: tema (`AndozaTheme.lightTheme()`, faqat yorug'), til, router. |
| `config/` | `app_config.dart` (`--dart-define` sozlamalari), `design_tokens.dart` (ranglar, shrift, oraliqlar), `router.dart` (yo'llar). |
| `screens/` | Ekranlar, bo'limlar bo'yicha: auth, home, room_setup, scanning, studio, estimation, shop, masters, profile, settings, onboarding, business va boshqalar. `app_shell.dart` — pastki menyu. |
| `providers/` | Riverpod provayderlari (21 ta): auth, kvartiralar, xona saqlash, smeta, savat, buyurtmalar, ustalar, biznes, til va boshqalar. |
| `repositories/` | Backend bilan ishlash (12 ta): har bir mavzu uchun bitta fayl. Qarang: [API.md](API.md). |
| `services/` | `api_client.dart`, `secure_storage.dart`, `sse_client.dart`, `room_plan_handoff.dart`, `pdf_share_service.dart`, `lidar_service.dart` (eski, ishlatilmaydi). |
| `features/room_scan/` | LiDAR skaner: native ko'prik, ma'lumotni o'girish, tugallanmagan skanerni saqlash. |
| `geometry/` | "Xonani chizish" uchun ko'pburchak geometriyasi. |
| `models/` | Ma'lumot modellari (freezed/json). |
| `l10n/` | Tarjima fayllari (`app_uz.arb`, `app_ru.arb`, `app_en.arb`) va generatsiya qilingan `AppLocalizations`. |
| `utils/`, `widgets/` | Yordamchi funksiyalar va umumiy widget'lar. |

Native kod: `ios/Runner/RoomScan/` (RoomPlan skaner, Swift), `android/` (Kotlin).

## Ekranlar va navigatsiya

`lib/config/router.dart` da 62 ta yo'l. Ilova `/splash` dan ochiladi.
**Login qilmagan foydalanuvchi** `/login` ga yo'naltiriladi. Login qilgan
foydalanuvchi `/login` ga kirsa, bosh sahifaga qaytariladi. `/splash` va
`/login` dan boshqa hamma yo'llar login talab qiladi.

**Pastki menyu** (`AppShell`): Uy `/` · Do'kon `/shop/s1` · "+" (yangi loyiha
oynasi) · Ustalar `/masters/u1` · Profil `/profile`. Tugallanmagan skaner bo'lsa,
menyu uni davom ettirishni taklif qiladi.

| Bo'lim | Yo'llar | Izoh |
|---|---|---|
| Kirish | `/splash`, `/login` | Standart holatda login va parol bilan kirish va ro'yxatdan o'tish. SMS kod bilan kirish `SMS_LOGIN_ENABLED=true` bilan yoqiladi. |
| Uy va loyihalar | `/`, `/profile/e5`, `/profile/e11` | Loyihalar ro'yxati, saqlangan dizaynlar |
| Xonani kiritish | `/wizard`, `/setup/draw`, `/setup/dimensions`, `/setup/wall-measurements`, `/setup/summary` | Native o'lchash ustasi, xonani chizish, qo'lda o'lchamlar |
| Skaner | `/scanning/roomplan`, `/scanning/roomplan/review`, `/scanning/photo` | LiDAR skaner (iPhone Pro), natijani ko'rish, foto rejimi |
| 3D studiya | `/studio/:roomId` | WebView, pastda batafsil. `/design/*`, `/interior/*`, `/electrical/*` — studiyaga yo'naltiradigan eski yo'llar. |
| Smeta | `/estimation/e1`, `/e2`, `/e3` | Jami, bosqichlar bo'yicha, sifat darajalari |
| Do'kon | `/shop/s1`…`/shop/s7`, `/shop/search`, `/shop/store/:storeId`, `/shop/furniture/:id` | Katalog (materiallar va do'konlar mebeli), mahsulot, narxlarni solishtirish, savat, rasmiylashtirish, buyurtma holati; do'konning ochiq sahifasi va mebel sahifasi ("Xonamga qo'yish" xonani Studio'da `?place=<mebel id>` bilan ochadi, mebel xonaga o'zi qo'yiladi) |
| Buyurtmalar | `/profile/e6`, `/history` | Buyurtmalar tarixi |
| Ustalar | `/masters/u1`, `/u3`, `/u4`, `/u5` | Xarita, ro'yxat, profil, ustaga smeta yuborish |
| Profil | `/profile`, `/profile/settings`, `/onboarding/e7`, `/onboarding/e8` | Til, versiya, maxfiylik, hisobni o'chirish |
| Mebel ustaxonasi | `/mebel` | WebView, pastda batafsil |
| Biznes (do'kon yoki usta egasi) | `/business` va `/business/*` | Murojaatlar, buyurtmalar, statistika, portfolio, mahsulotlar, ariza |

## 3D studiya (WebView)

`screens/studio/studio_webview_screen.dart` veb-studiyani
`${STUDIO_BASE_URL}/studio/<roomId>` manzilida, `app=1` parametri bilan ochadi.
Frontend shu parametrga qarab o'zining "orqaga" tugmasini yashiradi.
`lang=` parametri ilovada tanlangan tilni uzatadi (`localeProvider`). Studio shu
tilda ochiladi va uni akkauntga saqlaydi.

**Autentifikatsiya ko'prigi:**
1. `WebViewCookieManager` `token` cookie'siga ilovaning access token'ini yozadi.
   `refresh_token` cookie'si `.../auth/refresh` yo'liga yoziladi.
2. Studiya origin'ining ildizi ochiladi va JS bilan `localStorage['uy-tamir-auth']`
   to'ldiriladi (frontend login holatini shu yerdan o'qiydi).
3. Keyin kerakli studiya sahifasiga o'tiladi.

**Qoidalar:**
- Boshqa domenlarga o'tish bloklanadi.
- Studiya `/studio/*` dan chiqsa (masalan `/projects` yoki `/login` ga), ekran yopiladi va ilovaga qaytiladi.
- "Orqaga" bosilganda ilova `window.__captureRoomThumbnail?.()` ni chaqiradi (xona rasmini saqlash) va 150 ms dan keyin yopiladi.
- JS'dan ilovaga xabar kanali yo'q.
- **Fayl yuklash (`<input type="file">`).** Studiyadagi rasm yuklashlar (rasmdan AI dizayn, pol teksturasi, mebel fotosi) iOS'da WKWebView'ning o'z oynasi orqali ishlaydi. Android WebView esa ilova javob bermaguncha bu tugmalarni e'tiborsiz qoldiradi. Shuning uchun Android'da `AndroidWebViewController.setOnShowFileSelector` ulangan (`screens/studio/webview_file_chooser.dart`): foydalanuvchi kamera yoki galereyani tanlaydi, `image_picker` rasmni 2048 px gacha kichraytirib, JPEG qilib beradi. Faqat rasm qabul qiladigan input'larga javob beriladi.

## Mebel ustaxonasi (WebView)

`screens/mebel/mebel_webview_screen.dart` web'dagi `/mebel` bo'limini
`?app=1&lang=<ilova tili>` bilan ochadi. Kirish nuqtasi Profil ekranidagi
"Mebel ishlab chiqarish" qatori. Detallar, raskroy va chizmalarni web sahifa
hisoblaydi, ilova ularni qayta yozmaydi.

- **Sessiya:** Studio'dagidek uzatiladi (`screens/studio/studio_session.dart`:
  token cookie'lari va `uy-tamir-auth`). Studiya origin'idan tashqariga o'tish
  bloklanadi, `/mebel` dan chiqish (masalan sessiya tugab `/login`) ekranni yopadi.
- **Orqaga:** WebView'da orqaga yo'l bo'lsa sahifa orqaga qaytadi (loyiha →
  ro'yxat), bo'lmasa ekran yopiladi. Sahifa o'zi saqlaydi, so'ralmaydi.
- **PDF va CSV** (`mebel_bridge.dart`): WebView `window.print()` va
  `<a download href="blob:…">` ni bajarmaydi. Har sahifa yuklanganda JS ularni
  ushlaydi. Chop etish HTML'i `printing` paketi orqali tizimning chop etish
  oynasiga ("PDF sifatida saqlash" bor) A4 albom formatida beriladi. CSV
  vaqtinchalik faylga yozilib, "Ulashish" oynasiga beriladi. Blob'ni o'qishda
  BOM tushib qoladi, shuning uchun u qayta qo'shiladi (Excel kirillni shu bilan
  o'qiydi). iOS 26 ulashish oynasini `sharePositionOrigin` siz ochmaydi.

## "Share → Andoza AI" (Pinterest pin)

Pinterest ilovasida pin ulashilganda (masalan `"Check out this Pin! https://pin.it/AbCd12"`), matn ilovaga ikki yo'l bilan keladi va keyingi qadamlar ikkala platformada bir xil:

1. Matn `andoza/share` kanali orqali Dart'ga beriladi. Ilova ishga tushganda kelgan share Dart `take` chaqirguncha kutib turadi. Ilova ochiq paytda kelgani esa darhol `shared` bilan yuboriladi.
   - **Android:** `MainActivity` `ACTION_SEND` / `text/plain` intent'ni qabul qiladi va `ShareChannel.kt` orqali uzatadi.
   - **iOS:** `ios/ShareExtension` (`ShareViewController`) ulashilgan havola yoki matnni o'qiydi va ilovani `andozaai-share://pin?text=…` bilan ochadi. Extension `UIApplication.shared`ni chaqira olmaydi, shuning uchun ilova obyekti responder zanjiri orqali topiladi. `SceneDelegate` URL'ni `ShareChannel.swift`ga beradi. `Info.plist`da `FlutterDeepLinkingEnabled = false`: URL bilan ochilgan ilova splash'ni o'tkazib yubormasligi kerak, aks holda sessiya tiklanmay login ekrani chiqadi.
2. `services/share_intent.dart` share'ni `/share/pin?text=…` sahifasiga yo'naltiradi. Foydalanuvchi login qilmagan bo'lsa, sahifa kirgandan keyin ochiladi. Bunda push bilan bir xil mexanizm ishlatiladi: `pendingPushRouteProvider`.
3. `screens/share/share_pin_screen.dart` matndan pin havolasini ajratadi (web'dagi `findPinUrl` bilan bir xil qoida) va qaysi xonaga qo'llashni so'raydi.
4. Tanlangan xona Studio'da `/studio/<id>?ai_pin=<havola>` bilan ochiladi. Web Studio AI dizaynerni shu pin bilan ochadi, reja web'dagidek tuziladi va qo'llanadi.

## LiDAR skaner (iOS RoomPlan)

**Kanal:** `andoza/roomscan` (`ios/Runner/RoomScan/RoomScanPlugin.swift`).
Metodlar:
- `isSupported` → `{supported, reason, multiRoom}`, `reason` qiymati `no_lidar` yoki `ios_too_old`; `multiRoom` faqat LiDAR va iOS 17+ da `true`;
- `scanRoom` → `{json, usdzPath, version: "roomplan-1"}`, bekor qilinsa `null`;
- `scanRooms` (iOS 17+, argument `{labels}`) → `{rooms: [{json, usdzPath}], version, partial}`, bekor qilinsa `null` (`MultiRoomScanViewController.swift`);
- `scanObject` → `{usdzPath}` (iOS 17 Object Capture, hozircha hech qaysi ekran chaqirmaydi).

**Oqim:**
1. `/scanning/roomplan` qurilmani tekshiradi. LiDAR bo'lmasa, foto rejimi yoki xonani chizishni taklif qiladi.
2. Skaner tugagach, natija `PendingScanStore` ga saqlanadi: USDZ fayl Documents'ga, JSON `SharedPreferences` ga. Ilova yopilib qolsa ham skaner yo'qolmaydi.
3. Ko'rish sahifasida `handoffRoomPlan` (`services/room_plan_handoff.dart`) ishlaydi:
   - kvartira yo'q bo'lsa, "Mening uyim" yaratiladi;
   - `POST /apartments/{id}/rooms` bilan xona yaratiladi.
4. Tugallanmagan skaner o'chiriladi.
5. `POST /rooms/{id}/room-scan` (`usdz` va `room_json`) va `POST /rooms/{id}/thumbnail` yuboriladi. Bu qadam xato bersa ham oqim to'xtamaydi.
6. Xona 3D studiyada ochiladi: `/studio/{id}?focus=1`.

Server skanerni o'zi qayta o'giradi va xona geometriyasini yangilaydi.
Xuddi shu xona 30 daqiqa ichida qayta skanerlansa, server oldingi tegilmagan
nusxani olib tashlaydi (`andoza_ai` backend, `room_scan_dedupe`).

**Ko'p xonali skaner** (`multiRoom == true` bo'lsa, skaner ekrani "Bitta xona" / "Bir nechta xona" tanlovini ko'rsatadi, aks holda tanlov yo'q):
1. Bitta ARSession ichida xonalar ketma-ket skanerlanadi ("Keyingi xona", "Tugatish"), shuning uchun hammasi bitta dunyo koordinatasida. Oxirida `StructureBuilder` ularni birga tozalaydi; xato bersa, olingan xonalar o'zi ishlatiladi. Ilova fonga o'tsa, tugagan xonalar saqlanadi (`partial`).
2. Har bir xona odatdagidek o'giriladi; `RoomScanDraft.worldOrigin` xonaning dunyodagi o'rnini saqlaydi, `flatLayoutPositions` (`features/room_scan/flat_layout.dart`) undan `state.layoutPos` ni (xona markazi, metr) hisoblaydi — web studiya xonalarni shu bo'yicha joylaydi.
3. Natija `PendingScanStore.saveFlat` ga saqlanadi va `/scanning/roomplan/review-flat` (`FlatScanReviewPage`) ochiladi: xonalar rejada, har biriga nom.
4. `handoffScannedFlat` (`services/flat_scan_handoff.dart`) hamma xonani bitta kvartirada yaratadi va `layoutPos` ni yozadi; skanerlar bitta `scan_group` bilan yuklanadi (backend ularni bir-birining nusxasi deb o'chirmaydi); studiya butun kvartira bilan ochiladi (`/studio/{birinchi id}`, `focus` siz).

**Android:** `andoza/roomscan` u yerda yo'q, shuning uchun foydalanuvchiga foto
rejimi yoki xonani chizish taklif qilinadi.

**Eski kod:** `com.tamir_uy/lidar` kanali (`LidarMethodChannel.swift`, Android
ARCore `DepthScanActivity.kt`) va uning Dart qismi (`services/lidar_service.dart`,
`providers/lidar_provider.dart`) hech qaysi ekrandan chaqirilmaydi.

## Tillar va tema

- **Tillar:** o'zbek (standart), rus va ingliz, har birida 702 ta kalit.
  - Tanlov `SharedPreferences` dagi `app_locale` kalitida saqlanadi.
  - Til sozlamalar ekranida o'zgartiriladi.
  - Batafsil: [../LOCALIZATION.md](../LOCALIZATION.md).
- **Tema:** `config/design_tokens.dart`.
  - Asosiy ko'k `#2850D0`, urg'u to'q sariq `#F97316`.
  - Inter shrifti, 4–48 px oraliqlar.
  - Faqat yorug' tema.
