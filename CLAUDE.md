# andoza_ai_mobile — working notes

Flutter client (Android + iOS) of andoza.ai. Backend and the web 3D Studio live in
the separate `andoza_ai` repo (FastAPI + React); this app calls that backend and
embeds the Studio in a WebView.

Read first:
- `docs/ARCHITECTURE.md` — stack, `lib/` layout, the 59 routes, the Studio WebView
  bridge, the LiDAR/RoomPlan flow.
- `docs/API.md` — every backend endpoint the app calls, tokens and refresh.
- `docs/BUILD_AND_RELEASE.md` — `--dart-define` config, ids, signing, CI, tests.
- `LOCALIZATION.md` — strings in three languages.

## Commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # after changing freezed/json models
flutter gen-l10n                                            # after changing an .arb file
flutter analyze
flutter test
```

Run against production: `--dart-define=API_URL=https://andozaai.uz/api/v1`
plus `API_BASE_URL` and `STUDIO_BASE_URL` (see `docs/BUILD_AND_RELEASE.md`).
The defaults (`10.0.2.2`) only reach a backend on the host from the Android emulator.

## Rules that came from real bugs

- **User-facing text goes through `AppLocalizations`** — add the key to
  `lib/l10n/app_uz.arb` (with a `@key` description), `app_ru.arb` and `app_en.arb`
  together; no hard-coded strings in screens.
- **Full-screen routes use the root navigator.** Routes that must cover the bottom
  bar (onboarding, Studio, wizard, business editors) set `parentNavigatorKey` to the
  root key in `lib/config/router.dart`; otherwise `context.push` lands on the
  `ShellRoute`'s own navigator, the nav bar shows through, and back leaves the app.
- **No `extendBody: true` on `AppShell`'s `Scaffold`** — it let bottom sheets extend
  under the nav bar, which then swallowed their taps.
- **Impeller is off on Android only** (`EnableImpeller=false` in the manifest; it
  crashed emulators). Do not copy that flag to iOS.
- **The Studio is web.** 3D editing, design and electrical screens are thin
  redirects to `/studio/:roomId`; change Studio behaviour in the `andoza_ai`
  frontend, not here.
- **Tokens only in `flutter_secure_storage`**; never log request or response bodies.

## Conventions

- Version: bump `version:` in `pubspec.yaml` (`1.0.0+N`), commit as
  `chore: 1.0.0+N (<what changed>)`.
- Never commit signing material (`.jks`, `.p12`, `.p8`, `.mobileprovision`,
  `key.properties`) or real passwords; CI reads them from GitHub secrets.
- Keep `docs/` in step with the code it describes; old plans and status reports
  are in `docs/archive/`.
