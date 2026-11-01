# Android Release Signing

This app ships a **release-signed** Android App Bundle (`.aab`) signed with a
dedicated **upload key**. Debug builds are unaffected and still work without any
keystore.

## The upload key

- Keystore file: `~/andoza-upload.jks` (RSA 2048, valid 10000 days)
- Alias: `andoza`
- The store and key passwords are the **same** value — this is a PKCS12
  keystore, and PKCS12 does not support a separate key password.

The keystore lives **outside the repo** and is referenced by
`android/key.properties`. Neither the keystore nor `key.properties` is ever
committed — both are git-ignored.

> **Play App Signing:** when you register the app in the Play Console, enroll in
> Play App Signing. Google then holds the real *app signing key* and re-signs
> every upload; this `andoza` key is only your *upload key*. If the upload key
> is ever lost, Google support can reset it — but only if you enrolled in Play
> App Signing. Back it up anyway (below).

## BACK UP THE KEYSTORE

If you are **not** on Play App Signing and you lose `~/andoza-upload.jks` or its
password, **you can never publish an update to the app again** — Google requires
every update to be signed with the same key. Back up now:

- Copy `~/andoza-upload.jks` to at least two safe offline locations
  (encrypted USB, a password manager's file vault, etc.).
- Store the store/key password in your password manager.
- Keep the base64 form used for CI (see below) in the same secure place.

## How gradle uses it

`android/app/build.gradle.kts` reads `android/key.properties` at build time:

- If `key.properties` exists **and** the `storeFile` it points at exists, a
  `release` signing config is created and the `release` build type uses it.
- Otherwise the `release` build type **falls back to the debug key**, so
  `flutter build` / `flutter run --release` still work on machines (and CI
  checkouts) that don't have the upload key.

`android/key.properties` format:

```properties
storeFile=/absolute/path/to/andoza-upload.jks
storePassword=<store password>
keyAlias=andoza
keyPassword=<same as store password>
```

## Build a signed AAB locally

```bash
# ANDROID_HOME and flutter on PATH as on your machine
flutter build appbundle --release \
  --dart-define=API_URL=https://andozaai.uz/api/v1 \
  --dart-define=API_BASE_URL=https://andozaai.uz \
  --dart-define=STUDIO_BASE_URL=https://andozaai.uz
```

Output: `build/app/outputs/bundle/release/app-release.aab`.

Verify it's signed with the upload key (Owner should be `CN=Andoza`, **not**
`CN=Android Debug`):

```bash
keytool -printcert -jarfile build/app/outputs/bundle/release/app-release.aab
```

## CI: GitHub Actions (`.github/workflows/release.yml`)

The workflow builds the signed AAB on a `v*` tag push or a manual dispatch and
uploads it as a workflow artifact. Set these **repository secrets**
(Settings -> Secrets and variables -> Actions):

| Secret | Value |
| --- | --- |
| `ANDROID_KEYSTORE_B64` | base64 of the keystore: `base64 -w0 ~/andoza-upload.jks` |
| `KEYSTORE_PASSWORD` | the store password |
| `KEY_PASSWORD` | the key password (same as store password) |
| `KEY_ALIAS` | `andoza` |
| `KEY_PROPERTIES` | *(optional)* the entire `key.properties` contents; if set, it replaces the three secrets above. The `storeFile=` line is overridden automatically to point at the decoded keystore on the runner. |

To produce the base64 secret:

```bash
base64 -w0 ~/andoza-upload.jks
```

Copy the single-line output into the `ANDROID_KEYSTORE_B64` secret.

## Publishing to Google Play (currently DISABLED)

The `release.yml` workflow contains a **commented-out** publish step using
`r0adkll/upload-google-play`. Before enabling it:

1. **Register the app** in the Google Play Console (create the app entry;
   `applicationId` is `andozaai.com`; the Kotlin namespace
   `com.tamir_uy.tamir_uy_mobile_flutter` is not the store id).
2. **Enroll in Play App Signing** (recommended default when you create the app).
3. Create a **Google Cloud service account**, enable the *Google Play Android
   Developer API*, grant the account release permission in the Play Console,
   download its JSON key, and store the JSON as the `PLAY_SERVICE_ACCOUNT_JSON`
   repository secret.
4. Do the **first upload manually** through the Play Console so Google finalizes
   Play App Signing for the app.
5. Uncomment the "Publish to Play internal track" step at the bottom of
   `release.yml`. It publishes to the **internal** track; change `track:` to
   `alpha` / `beta` / `production` when you're ready.
