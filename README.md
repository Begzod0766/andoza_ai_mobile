# andoza.ai — mobil ilova

O'zbekistonda uy ta'miri uchun andoza.ai platformasining Android va iOS ilovasi
(Flutter). Foydalanuvchi:
- xonani o'lchaydi: o'lchash ustasi, chizish yoki iPhone LiDAR skaneri bilan;
- 3D studiyada dizayn qiladi (veb-studiya ilova ichida ochiladi);
- smeta oladi, do'kondan buyurtma beradi va usta topadi.

Do'kon va usta egalari uchun alohida biznes bo'limi ham bor.

Backend va veb-studiya: [`andoza_ai`](https://github.com/Begzod10/andoza_ai) reposi.

## Tez boshlash

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run \
  --dart-define=API_URL=https://andozaai.uz/api/v1 \
  --dart-define=API_BASE_URL=https://andozaai.uz \
  --dart-define=STUDIO_BASE_URL=https://andozaai.uz
```

`--dart-define` berilmasa, ilova Android emulyatoridagi lokal backend'ga (`10.0.2.2`) ulanadi.

Testlar: `flutter test`.

## Hujjatlar

| Hujjat | Mazmuni |
|---|---|
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Stek, papkalar, ekranlar xaritasi, 3D studiya WebView'i, LiDAR skaner oqimi |
| [docs/API.md](docs/API.md) | Backend endpoint'lari, tokenlar va yangilash |
| [docs/BUILD_AND_RELEASE.md](docs/BUILD_AND_RELEASE.md) | Sozlamalar, identifikatorlar, imzolash, CI, versiya, testlar |
| [docs/mobile/IOS_BUILD.md](docs/mobile/IOS_BUILD.md) | iOS build va TestFlight batafsil |
| [docs/RELEASE_SIGNING.md](docs/RELEASE_SIGNING.md) | Android imzolash kaliti va Play |
| [LOCALIZATION.md](LOCALIZATION.md) | Tillar: o'zbek, rus, ingliz |
| [docs/room_sketch_geometry.md](docs/room_sketch_geometry.md) | "Xonani chizish" geometriyasi |
| `docs/archive/` | 2026-yil iyul–sentabrdagi eski rejalar va hisobotlar |
