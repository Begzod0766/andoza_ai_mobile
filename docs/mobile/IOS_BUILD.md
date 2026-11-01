# iOS build & TestFlight from Linux (no Mac required)

This app is built for iOS entirely on GitHub Actions macOS runners and shipped to a
real iPhone via TestFlight. You never need Xcode or a Mac. Two workflows:

| Workflow | Trigger | What it does | Secrets |
|---|---|---|---|
| `.github/workflows/ios-check.yml` | every PR touching `lib/`, `ios/`, `pubspec.*` | `flutter build ios --no-codesign --simulator` — proves pods/plugins/Swift compile | none |
| `.github/workflows/ios.yml` | push to `main` (same paths) + manual `workflow_dispatch` | signed `flutter build ipa`; on `main`, uploads to TestFlight | all below |

- **iOS bundle id:** `uz.andozaai.app` (this differs from the Android
  `applicationId` `andozaai.com` on purpose — use the iOS one everywhere).
- **Never commit** `.p12`, `.p8`, `.mobileprovision`, `.cer`, or `.key` files. Only their
  **base64** goes into GitHub **secrets**. `.gitignore` already ignores them, but double-check.

---

## 0. One-time Apple setup (in the Apple Developer portal + App Store Connect)

You need an Apple Developer Program membership. In the portal:
1. **App ID** — Identifiers → register `uz.andozaai.app` (enable any
   capabilities the app uses; ARKit/camera need no special entitlement).
2. **App Store Connect app** — My Apps → create an app with that bundle id.
3. You'll create a **distribution certificate** (§1), an **App Store provisioning
   profile** (§2), and an **App Store Connect API key** (§3) below.

All of §1–§3 are doable from Linux; only the portal clicks use a browser.

---

## 1. Distribution certificate → `IOS_P12_BASE64` (+ `IOS_P12_PASSWORD`)

Apple issues certificates from a **CSR**. Generate the key + CSR with openssl:

```bash
# 1. Private key (KEEP THIS FILE — the cert is useless without it)
openssl genrsa -out ios_dist.key 2048

# 2. Certificate Signing Request
openssl req -new -key ios_dist.key -out ios_dist.csr \
  -subj "/emailAddress=you@example.com/CN=Andoza AI Distribution/C=UZ"
```

In the portal: **Certificates → +** → **Apple Distribution** (or *iOS Distribution*)
→ upload `ios_dist.csr` → download the issued `distribution.cer` (DER format).

Convert the DER cert to PEM and bundle it with the private key into a `.p12`:

```bash
# 3. DER -> PEM
openssl x509 -inform DER -in distribution.cer -out ios_dist.pem

# 4. Bundle key + cert into a password-protected .p12.
#    openssl 3 needs -legacy so macOS `security import` can read it.
openssl pkcs12 -export -legacy \
  -inkey ios_dist.key -in ios_dist.pem \
  -name "Apple Distribution" \
  -out ios_dist.p12 -passout pass:'CHOOSE_A_STRONG_PASSWORD'

# 5. base64 for the GitHub secret (single line, no wrapping)
base64 -w0 ios_dist.p12 > ios_dist.p12.b64
```

- `IOS_P12_BASE64` = contents of `ios_dist.p12.b64`
- `IOS_P12_PASSWORD` = the password from step 4

---

## 2. App Store provisioning profile → `IOS_PROFILE_BASE64` (+ `IOS_PROFILE_NAME`)

In the portal: **Profiles → +** → **App Store Connect** (distribution) → App ID
`uz.andozaai.app` → select the distribution certificate from §1 →
give it a **name** (remember it exactly) → download `AndozaAI_AppStore.mobileprovision`.

```bash
base64 -w0 AndozaAI_AppStore.mobileprovision > profile.b64
```

- `IOS_PROFILE_BASE64` = contents of `profile.b64`
- `IOS_PROFILE_NAME` = the exact profile name you typed
- `IOS_BUNDLE_ID` = `uz.andozaai.app`
- `IOS_TEAM_ID` = your 10-char Team ID (portal → Membership, or the profile's team)

Inspect a profile locally if unsure of the name/team:
```bash
openssl smime -inform DER -verify -noverify -in AndozaAI_AppStore.mobileprovision \
  | plutil -p - 2>/dev/null | grep -E 'Name|TeamIdentifier'
```

---

## 3. App Store Connect API key → `ASC_KEY_BASE64`, `ASC_KEY_ID`, `ASC_ISSUER_ID`

App Store Connect → **Users and Access → Integrations → App Store Connect API** →
**+** → role **App Manager** → **Generate**. Download `AuthKey_XXXXXXXXXX.p8`
**(only downloadable once)**. Note the **Key ID** (the `XXXXXXXXXX`) and the **Issuer
ID** (a UUID at the top of the page).

```bash
base64 -w0 AuthKey_XXXXXXXXXX.p8 > asc_key.b64
```

- `ASC_KEY_BASE64` = contents of `asc_key.b64`
- `ASC_KEY_ID` = the Key ID
- `ASC_ISSUER_ID` = the Issuer ID

---

## 4. The full GitHub secrets list

Add under **Settings → Secrets and variables → Actions** (or via `gh` below):

| Secret | Source |
|---|---|
| `IOS_P12_BASE64` | §1 step 5 |
| `IOS_P12_PASSWORD` | §1 step 4 |
| `IOS_PROFILE_BASE64` | §2 |
| `IOS_PROFILE_NAME` | §2 (exact profile name) |
| `IOS_BUNDLE_ID` | `uz.andozaai.app` |
| `IOS_TEAM_ID` | §2 (10-char team id) |
| `ASC_KEY_BASE64` | §3 |
| `ASC_KEY_ID` | §3 |
| `ASC_ISSUER_ID` | §3 |
| `API_URL_PROD` | prod API base, e.g. `https://andozaai.uz/api/v1` |
| `API_BASE_URL_PROD` | *(optional but recommended)* prod API host, e.g. `https://andozaai.uz` |
| `STUDIO_BASE_URL_PROD` | *(optional but recommended)* prod web-studio origin, e.g. `https://andozaai.uz` |

> Why the two optional ones: the app reads `API_BASE_URL` and `STUDIO_BASE_URL` too
> (the studio WebView URL). If you omit them the build still succeeds but the studio
> WebView falls back to the emulator default `http://10.0.2.2:5173`, which won't work
> on a real device. Set them for a functional TestFlight build.

Set them fast with the GitHub CLI from Linux:

```bash
gh secret set IOS_P12_BASE64        < ios_dist.p12.b64
gh secret set IOS_P12_PASSWORD      --body 'CHOOSE_A_STRONG_PASSWORD'
gh secret set IOS_PROFILE_BASE64    < profile.b64
gh secret set IOS_PROFILE_NAME      --body 'AndozaAI AppStore'
gh secret set IOS_BUNDLE_ID         --body 'uz.andozaai.app'
gh secret set IOS_TEAM_ID           --body 'ABCDE12345'
gh secret set ASC_KEY_BASE64        < asc_key.b64
gh secret set ASC_KEY_ID            --body 'XXXXXXXXXX'
gh secret set ASC_ISSUER_ID         --body '69a6de00-...'
gh secret set API_URL_PROD          --body 'https://andozaai.uz/api/v1'
gh secret set API_BASE_URL_PROD     --body 'https://andozaai.uz'
gh secret set STUDIO_BASE_URL_PROD  --body 'https://andozaai.uz'
```

Then delete every local `.key/.csr/.cer/.pem/.p12/.p8/.mobileprovision/*.b64` file —
they must never reach git.

---

## 5. Running a build

- **Automatic:** push to `main` → `ios.yml` builds and uploads to TestFlight.
- **Manual / branch test:** Actions → *iOS Build & TestFlight* → **Run workflow**.
  From a non-`main` branch it **builds and uploads the `.ipa` artifact but skips the
  TestFlight upload** (that step is `if: github.ref == 'refs/heads/main'`), so you can
  validate signing without publishing.
- **PRs:** `ios-check.yml` runs the no-signing simulator build automatically.

---

## 6. Reading a failed run from Linux

```bash
# Watch the latest run
gh run watch

# List recent runs, grab an id
gh run list --workflow ios.yml --limit 5

# Download this run's artifacts (ipa + xcodebuild.log; on failure, Manifest.lock)
gh run download <run-id>
```

Artifacts produced:
- `ios-ipa-and-log` — the `.ipa` (when built) and `xcodebuild.log`.
- `ios-failure-debug` (on failure) — `xcodebuild.log` + `ios/Pods/Manifest.lock`.

What to look for in `xcodebuild.log`:
- `No profiles for 'uz.andozaai.app' were found` → `IOS_PROFILE_BASE64`
  / `IOS_BUNDLE_ID` mismatch, or the profile doesn't include the §1 cert.
- `Code Signing Error … requires a provisioning profile` → profile not installed /
  wrong name in `ExportOptions.plist` (`IOS_PROFILE_NAME`).
- `The specified item could not be found in the keychain` → `IOS_P12_PASSWORD` wrong or
  the `.p12` was exported without `-legacy` (openssl 3).
- Pod errors → compare `ios/Pods/Manifest.lock` vs `ios/Podfile.lock`; a plugin bump
  usually needs `pod repo update` (the workflow reinstalls pods each run, so this is
  rare).

---

## 7. Notes

- App-wide minimum iOS is **15.0** (`IPHONEOS_DEPLOYMENT_TARGET` and `platform :ios` in
  the `Podfile`); LiDAR/RoomPlan (iOS 16+) and Object Capture (iOS 17+) are gated at
  runtime, so iOS 15 devices still install and run the app without the scan features.
  Keep the Podfile and the Xcode target on the same value.
- Impeller stays at its iOS default (on). The Android-only `EnableImpeller=false` flag
  must not be copied to iOS.
- **iPhone only** (`TARGETED_DEVICE_FAMILY = 1` on Runner and ShareExtension): App
  Store review then needs no iPad screenshots and does not test on iPad.
- App Store review items already in the project: Sign in with Apple next to Google on
  the login screen (`services/apple_sign_in_service.dart`, backend `POST /auth/apple`);
  "Shikoyat qilish" / "Bloklash" on a craftsman profile and "Shikoyat qilish" on a
  product (guideline 1.2, `features/moderation/`); camera/photo permission texts in
  `Runner/{en,ru,uz}.lproj/InfoPlist.strings` (the English one is also the fallback in
  `Info.plist`); `Runner/PrivacyInfo.xcprivacy`; `ITSAppUsesNonExemptEncryption = false`.
- **Bundle id moved to `uz.andozaai.app`** (2026-10-28; was
  `com.tamiruy.tamirUyMobileFlutter`, never published). Firebase has an iOS app for it
  ("Andoza AI iOS", `GoogleService-Info.plist` and `lib/firebase_options.dart`), and the
  Google Sign-In iOS OAuth client ("iOS upload", `632412937266-nb16…`) now carries this
  bundle id, so its client id is unchanged. The old Firebase iOS app is still listed
  and unused.
- **`Runner/Runner.entitlements` is not wired yet.** It holds Sign in with Apple and
  `aps-environment` (push), which the free personal team `24GC58FD74` cannot sign. Once
  the paid Apple Developer team signs the app: enable *Sign in with Apple* and *Push
  Notifications* on the App ID, set `CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements`
  on the Runner target (all three configurations), upload an APNs key to Firebase, and
  set the backend's `APPLE_CLIENT_IDS` to the bundle id. Until then the Apple button
  shows on iOS but its sheet fails.

---

## 8. Runtime config on a real device (`--dart-define`)

The app reads every backend/studio URL from `String.fromEnvironment` in
`lib/config/app_config.dart` — `API_URL`, `API_BASE_URL`, and **`STUDIO_BASE_URL`**.
The defaults target the **Android emulator loopback** (`10.0.2.2`), so on a real iPhone
you **must** override them via `--dart-define` (or the CI secrets in §4 for TestFlight):

```bash
flutter run -d <ios-device> \
  --dart-define=API_URL=https://andozaai.uz/api/v1 \
  --dart-define=API_BASE_URL=https://andozaai.uz \
  --dart-define=STUDIO_BASE_URL=https://andozaai.uz
```

- **`STUDIO_BASE_URL` in particular**: its default is the emulator's
  `http://10.0.2.2:5173`, which is unreachable from a physical device. Without an
  override the embedded 3D-Studio WebView (`StudioWebViewScreen`) fails to load. Point
  it at a host the device can actually reach (the prod studio origin, or your dev
  machine's LAN IP while iterating).
- **App Transport Security**: the prod API and studio are served over **HTTPS**
  (`https://andozaai.uz`), and `ios/Runner/Info.plist` has **no** ATS exception
  (the old `189.74.96.11` cleartext exception was removed). A plain-HTTP host — a dev
  machine's LAN IP, for example — is therefore blocked on a real iPhone; serve it over
  HTTPS or add a narrowly scoped `NSExceptionDomains` entry for local testing only and
  never ship it.
