# Firebase Stage 1 (Crashlytics + Analytics) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** The mobile app reports crashes to Crashlytics and screen views plus six key events to Analytics, in release builds only, without personal data.

**Architecture:** `lib/services/firebase_setup.dart` initialises Firebase and wires error handlers (never throws). `lib/services/analytics_service.dart` wraps an injectable `AnalyticsSink` (Firebase in the app, a fake in tests) behind six typed methods. `lib/services/session_telemetry.dart` follows `authStateProvider` and sets/clears the user id on Crashlytics and Analytics. Call sites log events through `analyticsProvider`.

**Tech Stack:** Flutter, Riverpod, go_router, firebase_core, firebase_crashlytics, firebase_analytics, FlutterFire CLI.

**Spec:** `docs/superpowers/specs/2026-10-12-firebase-design.md` (section "1-bosqich")

## Global Constraints

- Repo/worktree: `/Users/mac/Projects/andoza_ai_mobile_firebase`, branch `feat/firebase`.
- Collection only in release: `setCrashlyticsCollectionEnabled(kReleaseMode)`, `setAnalyticsCollectionEnabled(kReleaseMode)`.
- No personal data: user identified only by `User.id`; no phone, email or name in any event or key.
- Firebase failure must never stop the app: init errors are caught and the app runs with telemetry off.
- Event names/params exactly: `login{method: password|google}`, `room_created{method: <RoomSource.name>}`, `scan_finished{kind: lidar|arcore}`, `estimate_viewed`, `order_placed{lines: int}`, `lead_sent`.
- Flutter: `export PATH=/Users/mac/development/flutter/bin:$PATH`. Android builds: `GRADLE_USER_HOME=/private/tmp/claude-501/-Users-mac-Projects-andoza-ai/c986d112-f740-4ce1-aee9-aded3695b70f/scratchpad/gradle-home` (shared `~/.gradle` cache is broken).
- Commits end with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.

## Review Focus

1. Firebase not configured / `initializeApp` throws (e.g. a test or a flavor without config) → app still starts → Task 1 test.
2. Logout or forced 401 teardown must clear the telemetry user id, or the next account's crashes are attributed to the previous user → Task 2 test (AuthInitial after Authenticated clears).
3. Analytics in debug/test runs must not reach Firebase (pollutes data) → Task 1 test on the enabled flag.
4. `room_created` must fire once per saved room, not on every retry of a failed save → Task 3 test (only after a successful handoff).
5. An event parameter must never carry user text (lead message, address) → Task 2 tests assert exact param maps.

---

### Task 0 (user-assisted): Firebase project and config files

Not code; the executor guides the user and waits.

- [ ] **Step 1:** User, in Firebase Console: "Add project" → choose existing Google Cloud project `andoza-ai`; enable Google Analytics (default account).
- [ ] **Step 2:** User runs in a terminal (needs their Google login):
  ```bash
  dart pub global activate flutterfire_cli
  ```
  ```bash
  firebase login
  ```
- [ ] **Step 3:** Executor runs in the worktree: `flutterfire configure --project=andoza-ai --platforms=android,ios --android-package-name=andozaai.com --ios-bundle-id=com.tamiruy.tamirUyMobileFlutter --yes`
  Expected: creates `lib/firebase_options.dart`, `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`.
- [ ] **Step 4: Commit** the three files — `chore(firebase): add Firebase project config (andoza-ai)`.

### Task 1: Firebase init + Crashlytics

**Files:**
- Modify: `pubspec.yaml` (add `firebase_core`, `firebase_crashlytics`, `firebase_analytics` — latest stable compatible versions via `flutter pub add`)
- Modify: `android/settings.gradle(.kts)`, `android/app/build.gradle(.kts)` — `com.google.gms.google-services` and `com.google.firebase.crashlytics` plugins (versions FlutterFire docs pin)
- Create: `lib/services/firebase_setup.dart`
- Modify: `lib/main.dart`
- Test: `test/unit/firebase_setup_test.dart`

**Interfaces:**
- Produces:
  ```dart
  /// Initialises Firebase and error reporting. Returns false (and leaves telemetry off) on any failure; never throws.
  Future<bool> initFirebase({Future<void> Function()? initializeApp, bool release = kReleaseMode});
  /// Whether Crashlytics/Analytics collect in this build.
  bool telemetryEnabled({bool release = kReleaseMode});
  ```
  `main()` becomes `async`: `WidgetsFlutterBinding.ensureInitialized(); await initFirebase(); runApp(...)`. When init succeeded and `release`: `FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError`; `PlatformDispatcher.instance.onError = (e, s) { FirebaseCrashlytics.instance.recordError(e, s, fatal: true); return true; }`. Always call `setCrashlyticsCollectionEnabled(telemetryEnabled())` and `FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(telemetryEnabled())` after a successful init.

- [ ] **Step 1: Failing tests:**
  - `initFirebase returns false when initializeApp throws` — `initializeApp: () async => throw Exception('no config')` → `false`, no exception escapes.
  - `telemetry is off outside release` — `telemetryEnabled(release: false)` is `false`; `telemetryEnabled(release: true)` is `true`.
- [ ] **Step 2: Run** `flutter test test/unit/firebase_setup_test.dart` — Expected: FAIL (file/function missing).
- [ ] **Step 3: Implement** as in Interfaces (default `initializeApp` = `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`; when injected, skip the Crashlytics/Analytics calls if it threw).
- [ ] **Step 4: Run** the test → PASS; `flutter analyze` → "No issues found!"; `flutter test` → all pass.
- [ ] **Step 5: Commit** — `feat(firebase): init Firebase and report crashes in release builds`.

### Task 2: AnalyticsService + session user id

**Files:**
- Create: `lib/services/analytics_service.dart`, `lib/services/session_telemetry.dart`
- Test: `test/unit/analytics_service_test.dart`, `test/providers/session_telemetry_test.dart`

**Interfaces:**
- Produces:
  ```dart
  abstract class AnalyticsSink {
    Future<void> logEvent(String name, [Map<String, Object>? params]);
    Future<void> setUserId(String? id);           // analytics + crashlytics
  }
  class FirebaseAnalyticsSink implements AnalyticsSink { ... }   // no-op when Firebase isn't initialised
  class AnalyticsService {
    AnalyticsService(this._sink);
    Future<void> login(String method);            // 'password' | 'google'
    Future<void> roomCreated(RoomSource source);  // method: source.name
    Future<void> scanFinished(String kind);       // 'lidar' | 'arcore'
    Future<void> estimateViewed();
    Future<void> orderPlaced(int lines);
    Future<void> leadSent();
  }
  final analyticsSinkProvider = Provider<AnalyticsSink>((ref) => FirebaseAnalyticsSink());
  final analyticsProvider = Provider<AnalyticsService>((ref) => AnalyticsService(ref.watch(analyticsSinkProvider)));
  /// Keep-alive provider: listens to authStateProvider; AuthAuthenticated → setUserId(user.id); any other state after that → setUserId(null).
  final sessionTelemetryProvider = Provider<void>(...);
  ```
  `sessionTelemetryProvider` is read once in `MyApp.build` (`ref.watch(sessionTelemetryProvider)`).

- [ ] **Step 1: Failing tests** (`FakeSink` records calls):
  - `each event has its exact name and params` — `login('google')` → `('login', {'method': 'google'})`; `roomCreated(RoomSource.arcore)` → `('room_created', {'method': 'arcore'})`; `scanFinished('lidar')` → `('scan_finished', {'kind': 'lidar'})`; `estimateViewed()` → `('estimate_viewed', null)`; `orderPlaced(3)` → `('order_placed', {'lines': 3})`; `leadSent()` → `('lead_sent', null)`.
  - `session id follows login and logout` — ProviderContainer with overridden `analyticsSinkProvider` and a controllable `authStateProvider`: Authenticated(user id 'u1') → `setUserId('u1')`; then `AuthInitial` → `setUserId(null)`.
- [ ] **Step 2: Run** both files → FAIL (missing).
- [ ] **Step 3: Implement.**
- [ ] **Step 4: Run** → PASS; full `flutter test` green; `flutter analyze` clean.
- [ ] **Step 5: Commit** — `feat(analytics): typed analytics events and session user id`.

### Task 3: Wire screens and events

**Files:**
- Modify: `lib/config/router.dart` (`observers: [FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance)]` only when `telemetryEnabled()` and Firebase initialised — pass via a provider `firebaseReadyProvider` set from `main` with `ProviderScope(overrides: ...)`)
- Modify: `lib/screens/auth/login_screen.dart` (after each `setSession`: `login('password')` for password/OTP/register paths, `login('google')` for Google)
- Modify: `lib/services/room_plan_handoff.dart` (`roomCreated(plan.source)` after the room is saved successfully)
- Modify: the wizard's room save (`RoomPersistenceNotifier` save path used by `room_wizard_screen.dart`) — `roomCreated(RoomSource.wizard)` after success
- Modify: `lib/screens/scanning/ar_scan_screen.dart` (`scanFinished('arcore')` when a non-null result returns), `lib/screens/scanning/room_scan_screen.dart` (`scanFinished('lidar')` on a captured room)
- Modify: `lib/screens/estimation/e2_material_costs_screen.dart` (`estimateViewed()` once in `initState`)
- Modify: `lib/screens/shop/s6_checkout_screen.dart` (`orderPlaced(lines)` after `createOrder` succeeds)
- Modify: `lib/screens/masters/u5_booking_confirmation_screen.dart` (`leadSent()` after `sendLead` succeeds)
- Test: `test/widget/analytics_wiring_test.dart`

**Interfaces:**
- Consumes: `analyticsProvider`, `analyticsSinkProvider` (Task 2), `telemetryEnabled()` (Task 1).
- Produces: `final firebaseReadyProvider = Provider<bool>((ref) => false);` overridden in `main` with the result of `initFirebase()`.

- [ ] **Step 1: Failing tests** (override `analyticsSinkProvider` with `FakeSink`, existing fakes/overrides for repositories as in `test/widget/`):
  - `a sent lead logs lead_sent` — pump u5 confirmation with a fake business repository whose `sendLead` succeeds → tap confirm → sink has `('lead_sent', null)`.
  - `a failed lead logs nothing` — `sendLead` throws → sink empty.
  - `a saved room logs room_created once` — call `handoffRoomPlan` with a fake repository that fails once then succeeds on retry → exactly one `room_created`.
- [ ] **Step 2: Run** → FAIL (events not logged).
- [ ] **Step 3: Implement** all call sites listed above (log only on success; never pass user-entered text).
- [ ] **Step 4: Run** → PASS; full `flutter test` green; `flutter analyze` clean; `flutter build apk --release` with prod dart-defines → "Built".
- [ ] **Step 5: Commit** — `feat(analytics): log screen views and key events`.

### Task 4: Privacy page (web repo)

**Files:**
- Modify: `/Users/mac/Projects/andoza_ai/frontend/src/pages/PrivacyPage.tsx` — new section (uz copy below)
- Test: `/Users/mac/Projects/andoza_ai/frontend/src/pages/PrivacyPage.test.tsx`

Copy (uz): heading `Ilova statistikasi va xatolar`; text `Mobil ilova Google Firebase (Crashlytics va Analytics) orqali ilova xatolari va anonim foydalanish statistikasini yig'adi: qaysi ekranlar ochilgani, qurilma turi va ilova versiyasi. Ism, telefon raqami yoki elektron pochta bu xizmatlarga yuborilmaydi.`

- [ ] **Step 1: Failing test** `mentions Firebase crash and usage data` — renders the page; `getByText(/Firebase/)` present.
- [ ] **Step 2: Run** `npx vitest run src/pages/PrivacyPage.test.tsx` (PATH `$HOME/.local/node/bin`) → FAIL.
- [ ] **Step 3: Add the section** in the page's existing section style.
- [ ] **Step 4: Run** → PASS; `npx tsc --noEmit -p .` clean.
- [ ] **Step 5: Commit** on a web branch `feat/privacy-firebase` — `Privacy page says the app collects crash reports and usage stats`.

Manual (user, release APK on an Android phone): a test crash appears in Crashlytics; events appear in Analytics DebugView (`adb shell setprop debug.firebase.analytics.app andozaai.com`).
