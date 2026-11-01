# Firebase: Crashlytics, Analytics va push bildirishnomalar — dizayn

Sana: 2026-10-12. Holat: tasdiqlangan dizayn.
Repolar: `andoza_ai_mobile` (Flutter) va `andoza_ai` (FastAPI backend, Celery).

## Maqsad

- Ilova yiqilsa sababini bilish (Crashlytics).
- Qaysi ekran va funksiyalar ishlatilishini ko'rish (Analytics).
- Foydalanuvchiga muhim voqealarda push yuborish: AI render tayyor, buyurtma
  holati o'zgardi, usta so'rovga javob berdi.

Doiradan tashqarida: App Distribution, Remote Config, admin qo'lda yuboradigan
xabarlar, do'kon so'rovlari bo'yicha push, ustaga "yangi so'rov" pushi.

## Bosqichlar

1. **Firebase asosi + Crashlytics + Analytics** — faqat mobil.
2. **Push (FCM)** — backend + mobil.

Har bosqich alohida reja va alohida branch bilan bajariladi.

## Cheklovlar

- iOS push uchun pullik Apple Developer hisobi (APNs kaliti) kerak; iOS hozir
  Personal Team bilan imzolanadi. Shuning uchun push Android'da to'liq, iOS'da
  kod tayyor, lekin APNs entitlement qo'shilmaydi (aks holda build buziladi).
  Crashlytics/Analytics iOS'da ham ishlaydi.
- Firebase loyihasi — mavjud `andoza-ai` Google Cloud loyihasiga qo'shiladi.
  Android: `andozaai.com`; iOS: `com.tamiruy.tamirUyMobileFlutter`.
- Backend service account kaliti maxfiy: uni foydalanuvchi serverga qo'yadi,
  repoga ham, agentga ham ko'rsatilmaydi.
- Shaxsiy ma'lumot (telefon, email, ism) Crashlytics/Analytics'ga yuborilmaydi;
  foydalanuvchi faqat ichki ID bilan belgilanadi.

## 1-bosqich: Firebase asosi, Crashlytics, Analytics (mobil)

- `flutterfire configure` → `lib/firebase_options.dart`,
  `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`
  (maxfiy emas, commit qilinadi).
- Paketlar: `firebase_core`, `firebase_crashlytics`, `firebase_analytics`.
- `main.dart`: `Firebase.initializeApp`; release build'da
  `FlutterError.onError` va `PlatformDispatcher.instance.onError`
  Crashlytics'ga; debug'da yig'ish o'chiq
  (`setCrashlyticsCollectionEnabled(kReleaseMode)`,
  `setAnalyticsCollectionEnabled(kReleaseMode)`).
- Login/logout'da `setUserIdentifier(userId)` / bo'shatish.
- Analytics: go_router'ga `FirebaseAnalyticsObserver` (ekranlar avtomatik);
  `AnalyticsService` orqali 6 voqea:
  - `login` {method: password|google}
  - `room_created` {method: wizard|draw|lidar|arcore|photo}
  - `scan_finished` {kind: lidar|arcore}
  - `estimate_viewed`
  - `order_placed` {lines: int}
  - `lead_sent`
- Maxfiylik sahifasi (`/privacy`, web repo): Firebase orqali xatolar va anonim
  foydalanish statistikasi to'planishi haqida band.

## 2-bosqich: push

### Backend (`andoza_ai`)

**Jadval `device_tokens`** (migration `1786000035`, down `1786000034`):
`id`, `user_id` (FK users, ON DELETE CASCADE, index), `token` (unique),
`platform` (`android`|`ios`), `locale` (`uz`|`ru`|`en`), `created_at`,
`last_seen_at`.

**API** (autentifikatsiya talab qilinadi):
- `POST /api/v1/devices {token, platform, locale}` → 204. Bor token
  yangilanadi (`locale`, `last_seen_at`); boshqa foydalanuvchiniki bo'lsa joriy
  foydalanuvchiga o'tkaziladi.
- `DELETE /api/v1/devices {token}` → 204 (faqat o'z tokeni; yo'q bo'lsa ham 204).

**Yuborish:**
- `app/services/push.py`: `notify(user_id, kind, params)` — Celery task
  `app.tasks.push.send_push` ga navbat qo'yadi (queue `default`), boshqa ish
  qilmaydi.
- `send_push`: foydalanuvchi tokenlari → har biriga o'z tilida sarlavha/matn
  (`app/services/push_messages.py`, uz/ru/en) → `firebase_admin.messaging`
  `send_each` (Android: kanal `andoza_updates`, priority high).
  Ma'lumot: `{"kind": ..., "route": ...}`.
- Javobda `UNREGISTERED` / `INVALID_ARGUMENT` (token) → token o'chiriladi.
  Vaqtinchalik xato → task qayta urinadi (3 marta, 30 s).
- `FIREBASE_CREDENTIALS_FILE` (env) bo'lmasa yoki fayl yo'q bo'lsa — push
  o'chiq: `send_push` bir marta ogohlantirish yozadi va hech narsa yubormaydi.
- `docker-compose.prod.yml`: kalit fayli `api` va `worker` ga read-only ulanadi.

**Voqealar:**

| kind | Qachon | Kimga | Matn (uz) | route |
|---|---|---|---|---|
| `render_ready` | `render_room_image` muvaffaqiyatli tugadi | xona egasi | "Dizayningiz tayyor" / "Xonangiz uchun AI dizayn tayyor — ko'rish uchun bosing" | `/studio/{roomId}` |
| `order_status` | `change_status` holatni o'zgartirdi va `by` ≠ buyer | xaridor | "Buyurtma holati" / "Buyurtmangiz: {holat}" | `/profile/e6` |
| `lead_status` | usta lead holatini `viewed` yoki `contacted` ga o'zgartirdi | so'rov egasi | "Usta so'rovingizni ko'rdi" / "Usta siz bilan bog'lanadi" | `/masters/u3` |

Holat o'zgarmagan (takroriy so'rov) bo'lsa push yo'q; lead `closed` va
xaridorning o'zi bekor qilishi — push yo'q.

### Mobil (`andoza_ai_mobile`)

- Paketlar: `firebase_messaging`, `flutter_local_notifications`.
- **`PushService`**:
  - ilova ochilganda (login bo'lsa), login'dan keyin va `onTokenRefresh` da
    `POST /devices` (til — ilovaning joriy tili);
  - logout'da `DELETE /devices`, keyin `FirebaseMessaging.deleteToken()`;
  - iOS'da token olinmasa xato yutiladi.
- **Ruxsat:** birinchi ochilishda so'ralmaydi. Login'dan keyin bosh ekranda bir
  marta yumshoq oyna ("Dizayningiz tayyor bo'lganda yoki buyurtma holati
  o'zgarganda xabar beraylikmi?" — Ha / Keyinroq); "Ha" → tizim ruxsati.
  Javob saqlanadi, oyna qayta chiqmaydi. Sozlamalarda "Bildirishnomalar"
  qatori — holatini ko'rsatadi, bosilsa tizim sozlamalarini ochadi.
- **Android:** kanal `andoza_updates` ("Andoza yangiliklari", high);
  bildirishnoma ikonasi `ic_notification` (oq siluet, launcher monochrome
  chizmasidan); `POST_NOTIFICATIONS` ruxsati manifestda.
- **Bosish:** `getInitialMessage`, `onMessageOpenedApp`, lokal bildirishnoma
  bosilishi → `route`. Faqat ruxsat etilganlar: `/studio/<uuid>`,
  `/profile/e6`, `/masters/u3`; boshqasi → `/`. Login yo'q bo'lsa — login'dan
  keyin shu route.
- **Ilova ochiq paytda:** FCM xabari `flutter_local_notifications` bilan
  ko'rsatiladi.
- l10n (uz/ru/en): yumshoq oyna, sozlamalar qatori, kanal nomi.

## Xatolar va chekka holatlar

| Holat | Xatti-harakat |
|---|---|
| Server kaliti yo'q | Push o'chiq, API va voqealar odatdagidek ishlaydi |
| Token eskirgan | FCM javobidan keyin bazadan o'chadi |
| Telefonda hisob almashtirildi | Token yangi hisobga o'tadi; eski hisob xabar olmaydi |
| Ruxsat berilmagan | Token baribir ro'yxatdan o'tadi; tizim ko'rsatmaydi; ilova odatdagidek |
| Noma'lum route | Bosh ekran |
| iOS (APNs yo'q) | Token yo'q, push yo'q, xato yo'q |
| Firebase init xatosi | Ilova ishlashda davom etadi, Crashlytics/Analytics o'chiq |

## Test qilish

**Backend (pytest, FCM mock):** device upsert, hisob almashganda tokenni
o'tkazish, delete; har voqeada `notify` chaqirilishi va chaqirilmasligi
(takroriy holat, buyer cancel, lead closed); til bo'yicha matn; yaroqsiz token
o'chishi; kalitsiz rejim.

**Mobil (flutter test):** route whitelist; token oqimi (login → register,
refresh → register, logout → delete) soxta repository bilan; yumshoq oyna bir
marta; `AnalyticsService` voqealari soxta backend bilan; release'dan boshqa
rejimda yig'ish o'chiq.

**Qo'lda (Android telefon):** sinov yiqilishi Crashlytics'da; voqealar
DebugView'da; Firebase Console'dan sinov push; do'kon buyurtma holatini
o'zgartirganda push keladi va bosilganda buyurtmalar ochiladi.

## Foydalanuvchi qiladigan ishlar

1. Firebase Console: `andoza-ai` loyihasiga Firebase qo'shish; Android va iOS
   ilovalarini ro'yxatdan o'tkazish (agent qadamlarni ko'rsatadi);
   `flutterfire configure` uchun `firebase login`.
2. Android ilovaga SHA-1 kalitlarini qo'shish (debug, upload, Play App Signing).
3. Service account kalitini yuklab olib serverga qo'yish va `.env` ga
   `FIREBASE_CREDENTIALS_FILE` yozish.
4. Play Console Data safety formasini yangilash (crash va foydalanish
   ma'lumotlari).

## Tayyorlik mezoni

- Barcha avtomatik testlar yashil, `flutter analyze` toza.
- Release APK'da sinov yiqilishi Crashlytics'da ko'rinadi.
- Android telefonda uchala voqea pushi keladi va to'g'ri ekranni ochadi.
