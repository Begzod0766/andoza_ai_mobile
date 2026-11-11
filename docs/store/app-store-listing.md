# App Store listing — Andoza AI (iOS)

App Store Connect app record created 2026-11-11: bundle `uz.andozaai.app`, SKU
`andozaai-ios`, primary language **Russian** (App Store has no Uzbek localization).
The description follows the Google Play listing (Russian), with the iPhone-only
LiDAR scan added. Character limits are Apple's.

## Ruscha (asosiy til)

**Name** (≤30): `Andoza AI`

**Subtitle** (≤30): `Ремонт в 3D, смета и мастера`

**Promotional text** (≤170, can change without review):

> Спланируйте ремонт до первых трат: комната в 3D, точная смета материалов, товары
> магазинов и мастера — в одном приложении.

**Description** (≤4000):

```
Andoza AI помогает спланировать ремонт, прежде чем вы потратите первую сумму.

Задайте размеры комнаты или отсканируйте её камерой iPhone с LiDAR — можно сразу несколько комнат. Оформите комнату в 3D Studio: выберите пол, отделку стен, обои, плитку, потолок, двери, окна, светильники и мебель и сразу увидите результат в 3D. ИИ-дизайнер предложит мебель и освещение по короткому текстовому запросу.

Получите точную смету. Приложение рассчитывает материалы и их количество для стен, пола, потолка, сантехники и электрики по вашей комнате и показывает понятный итог. Смету можно скачать в PDF и отправить.

Покупайте нужное. Смотрите материалы и мебель магазинов, сравнивайте цены и оформляйте заказы в приложении.

Найдите мастера. Электрики, маляры, сантехники, плиточники, штукатуры и другие специалисты: отправьте мастеру свой проект со сметой.

Для магазинов и мастеров. Зарегистрируйтесь как владелец магазина или мастер, чтобы выставить товары или услуги, получать заявки клиентов и управлять заказами. Профили проверяются перед публикацией.

Ваши данные остаются вашими: аккаунт и данные можно удалить в любой момент в разделе «Профиль».

Доступно на узбекском, русском и английском языках.
```

**Keywords** (≤100 characters, now 72; comma-separated, no spaces after commas; the name and
category words are indexed anyway):

```
ремонт,смета,дизайн,интерьер,3D,квартира,обои,плитка,мастер,мебель,LiDAR
```

**URLs**

| Field | Value |
|---|---|
| Support URL | `https://andozaai.uz/privacy` (has the contact e-mail; a dedicated `/support` page on the web would be better) |
| Marketing URL | `https://andozaai.uz` |
| Privacy Policy URL | `https://andozaai.uz/privacy` |

**Other**

| Field | Value |
|---|---|
| Category | Primary: Lifestyle (Образ жизни). Secondary: Graphics & Design |
| Copyright | `2026 Begzod Jumaniyozov` |
| Age rating | 4+ expected (questionnaire in App Information; Play is 3+) |

## Screenshots

App Store Connect (2026-11) asks for one iPhone set, "iPhone with Dynamic Island
(medium display)": 1206 × 2622 (or 1179 × 2556) px. A 6.9" 1320 × 2868 set was
rejected as "invalid size". Ours are iPhone 17 Pro simulator shots at native size,
Russian UI, status bar 9:41.
JPEG (App Store rejects PNGs with an alpha channel). Files in
`docs/store/screenshots/iphone-6.3/`, in upload order:

1. `01-studio.jpg` — 3D Studio, the bathroom sample
2. `02-estimate.jpg` — estimate with the cost breakdown
3. `03-home.jpg` — home, project card
4. `04-shop.jpg` — shop (the lower material cards have no photos in the data yet)
5. `05-masters.jpg` — craftsmen map

Taken from a debug build with `debugShowCheckedModeBanner: false` set locally (not
committed). Seen while shooting: prices in the shop show `so'm` in the Russian UI,
and product names / room names stay in Uzbek (user data).

## App Privacy (entered in App Store Connect 2026-11-11, publish pending)

Source: `andozaai.uz/privacy`, `pubspec.yaml`, `lib/services/analytics_service.dart`,
`Info.plist`, the frameworks inside the IPA.

**Tracking: No.** No ATT prompt, no `NSUserTrackingUsageDescription`; nothing reads
the advertising identifier (no `ASIdentifierManager` / `ATTrackingManager` in the
binaries), no ads SDK. Firebase Analytics runs without IDFA.

Collected data, all **linked to the user**, none used for tracking:

| Apple category | Type | Why (Apple purpose) |
|---|---|---|
| Contact Info | Name (optional), Phone Number, Email Address (Apple/Google sign-in), Physical Address (delivery) | App Functionality |
| User Content | Photos or Videos (wallpaper, product, work photos, LiDAR scans), Other User Content (projects, rooms, messages to shops/craftsmen) | App Functionality |
| Purchases | Purchase History (orders) | App Functionality |
| Identifiers | User ID (internal account id, also set in Firebase), Device ID (Firebase instance id) | App Functionality, Analytics |
| Usage Data | Product Interaction (screens opened) | Analytics |
| Diagnostics | Crash Data (App Functionality), Other Diagnostic Data — device type, app version (App Functionality, Analytics) | |
| Environment | Environment Scanning (LiDAR / RoomPlan room scans uploaded as room geometry) | App Functionality |

Not collected: location (no GPS; the OpenStreetMap tile request exposes the IP to
OSM, which Apple does not count as the developer collecting it), contacts, health,
financial info (payment method is a choice only), browsing history, search history.

Age rating: expect **4+** (no violence, no mature content; user-generated content
exists — shop and craftsman profiles are moderated, with report/block per guideline
1.2).

Age rating questionnaire (saved by the owner 2026-11-11): only *User-generated
content* = Yes, everything else No/None; computed 4+, manually raised (option A)
because `/privacy` says the service is not meant for people under 16.

## Pricing and availability (set 2026-11-11)

- Price: free ($0.00, base country USA), all 175 storefronts priced.
- Availability: 148 countries/regions — everything except the 27 EU member states,
  until the owner files the DSA trader-status declaration (then add the EU back in
  Pricing and Availability → Availability → Manage).
- Not offered on Apple silicon Macs or Apple Vision Pro (iPhone only; LiDAR scan
  needs an iPhone).
- Distribution: public App Store.
