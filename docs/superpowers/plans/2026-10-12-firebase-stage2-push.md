# Firebase Stage 2 (Push Notifications) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Users get a push when their AI render is ready, when a shop/admin moves their order, and when an usta views or will contact them about their request; tapping it opens the right screen (Android now; iOS code-ready).

**Architecture:** Backend stores FCM tokens per user (`device_tokens`), and `notify()` enqueues a Celery task that sends localized messages with `firebase-admin`, deleting dead tokens. Three existing code paths call `notify()`. The app registers its token with the backend while signed in, unregisters on logout, shows foreground messages via `flutter_local_notifications`, and routes taps through a whitelist.

**Tech Stack:** FastAPI, SQLAlchemy async, Alembic, Celery, firebase-admin; Flutter, Riverpod, go_router, firebase_messaging, flutter_local_notifications.

**Spec:** `docs/superpowers/specs/2026-10-12-firebase-design.md` (section "2-bosqich")

**Depends on:** Stage 1 (Firebase project + `firebase_core` init) merged first.

## Global Constraints

- Backend repo: `/Users/mac/Projects/andoza_ai`, new worktree + branch `feat/push` from `master`. Tests: `docker exec andoza_ai-api-1 python -m pytest <file> -q` (source is bind-mounted; install the new dependency in the running container with `docker exec andoza_ai-api-1 pip install firebase-admin==<pinned>` for local tests).
- Mobile repo: `/Users/mac/Projects/andoza_ai_mobile_firebase`, branch `feat/firebase` (after stage 1).
- Migration revision `1786000035`, down_revision `1786000034`.
- `FIREBASE_CREDENTIALS_FILE` unset or missing → push disabled, everything else unchanged. The key file is never read, printed or committed by the agent.
- Kinds and routes exactly: `render_ready` → `/studio/{roomId}` (or `/` if no room); `order_status` → `/profile/e6`; `lead_status` → `/masters/u3`.
- Push only when something changed: no push for a repeated status, for buyer self-cancel, or for lead `closed`/`new`.
- App routes accepted from a push: `^/studio/[0-9a-f-]{36}$`, `/profile/e6`, `/masters/u3`; anything else → `/`.
- Android channel id `andoza_updates`, name from l10n, importance high.
- Commits end with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.

## Review Focus

1. Logging out must unregister the token **before** the auth token is cleared (the DELETE needs auth) → Task M1 test asserts call order.
2. The same physical device signing into a second account must stop receiving the first account's pushes → Task B1 test (token moves to the new user).
3. A push enqueued from a request that later fails is still sent (notify runs after `flush`, before commit). Ruling: accepted — every hook sits after the last validation in its handler; cost: a rare push for a change that rolled back.
4. A malicious/garbled `route` in a message must not navigate anywhere unexpected → Task M2 tests.
5. FCM partially failing (some tokens dead, one transient error) must delete only the dead ones and retry → Task B2 test.

---

## Backend (`andoza_ai`)

### Task B1: device_tokens table and /devices API

**Files:**
- Create: `backend/app/models/device_token.py` (register in `app/models/__init__.py`)
- Create: `backend/alembic/versions/1786000035_device_tokens.py`
- Create: `backend/app/routers/devices.py`; register in `app/main.py` with `prefix="/api/v1", tags=["devices"]`
- Create: `backend/app/schemas/device.py`
- Test: `backend/tests/test_devices.py` (follow the fake-session pattern in `tests/test_auth_google.py`)

**Interfaces:**
- Produces:
  ```python
  class DeviceToken(Base):  # __tablename__ = "device_tokens"
      id: uuid PK; user_id: uuid FK users.id ON DELETE CASCADE, indexed; token: str(4096) unique;
      platform: str(10) CHECK in ('android','ios'); locale: str(5) CHECK in ('uz','ru','en');
      created_at, last_seen_at: timestamptz default now()
  class DeviceRegister(BaseModel): token: str (1..4096); platform: Literal['android','ios']; locale: Literal['uz','ru','en'] = 'uz'
  class DeviceUnregister(BaseModel): token: str (1..4096)
  POST /api/v1/devices   (DeviceRegister) → 204
  DELETE /api/v1/devices (DeviceUnregister) → 204
  ```

- [ ] **Step 1: Failing tests:**
  - `test_register_new_token` → 204, one row for the caller with platform/locale.
  - `test_register_same_token_updates_locale` → second POST with `locale='ru'` keeps one row, locale `ru`.
  - `test_token_moves_to_new_account` → token owned by user A, POST by user B → row's `user_id == B`.
  - `test_unregister_own_token` → 204, row gone.
  - `test_unregister_someone_elses_token_keeps_it` → 204, A's row untouched when B deletes it.
  - `test_devices_require_auth` → 401 without token.
- [ ] **Step 2: Run** `docker exec andoza_ai-api-1 python -m pytest tests/test_devices.py -q` → FAIL (import error).
- [ ] **Step 3: Implement** model, migration (upgrade + downgrade), schemas, router (upsert by `token`).
- [ ] **Step 4: Run** → PASS; `alembic upgrade head` then `downgrade -1` then `upgrade head` in the container → no errors; full suite `python -m pytest -q` green.
- [ ] **Step 5: Commit** — `Phones can register for push notifications`.

### Task B2: push sending

**Files:**
- Create: `backend/app/services/push_messages.py`, `backend/app/services/push.py`, `backend/app/tasks/push.py`
- Modify: `backend/celery_app.py` (`include=[..., "app.tasks.push"]`, route to queue `default`)
- Modify: `backend/app/config.py` (`FIREBASE_CREDENTIALS_FILE: str = ""`), `backend/.env.example`, `backend/requirements.txt` (`firebase-admin==<latest 6.x/7.x, pinned>`)
- Test: `backend/tests/test_push.py`

**Interfaces:**
- Produces:
  ```python
  # push_messages.py
  def build_message(kind: str, params: dict, locale: str) -> tuple[str, str, str]:  # (title, body, route)
  # push.py
  def notify(user_id: uuid.UUID | str, kind: str, params: dict | None = None) -> None   # only send_push.delay(...)
  # tasks/push.py
  @app.task(name="app.tasks.push.send_push", bind=True, max_retries=3, default_retry_delay=30, queue="default")
  def send_push(self, user_id: str, kind: str, params: dict) -> dict   # {"sent": n, "removed": m} or {"status": "disabled"}
  ```
  Copy (uz / ru / en):
  - `render_ready`: "Dizayningiz tayyor" / "Ваш дизайн готов" / "Your design is ready"; body "Xonangiz uchun AI dizayn tayyor — ko'rish uchun bosing" / "AI-дизайн вашей комнаты готов — нажмите, чтобы посмотреть" / "The AI design for your room is ready — tap to see it".
  - `order_status` (params `status`): title "Buyurtma holati" / "Статус заказа" / "Order status"; body "Buyurtmangiz: {label}" / "Ваш заказ: {label}" / "Your order: {label}"; labels gathering "yig'ilmoqda"/"собирается"/"being packed", on_the_way "yo'lda"/"в пути"/"on the way", delivered "yetkazildi"/"доставлен"/"delivered", cancelled "bekor qilindi"/"отменён"/"cancelled".
  - `lead_status` (params `status`): viewed → "Usta so'rovingizni ko'rdi" / "Мастер посмотрел вашу заявку" / "The usta has seen your request"; contacted → "Usta siz bilan bog'lanadi" / "Мастер свяжется с вами" / "The usta will contact you"; title "Ustalar" / "Мастера" / "Ustas".
  Message: `messaging.Message(token=..., notification=Notification(title, body), data={"kind": kind, "route": route}, android=AndroidConfig(priority="high", notification=AndroidNotification(channel_id="andoza_updates")))`, sent with `messaging.send_each`.

- [ ] **Step 1: Failing tests** (patch `firebase_admin.messaging.send_each` and the app initializer; fake session for tokens):
  - `test_messages_follow_locale` — `build_message('order_status', {'status': 'on_the_way'}, 'ru')` → `('Статус заказа', 'Ваш заказ: в пути', '/profile/e6')`; `render_ready` with `room_id='r1'` → route `/studio/r1`; without room → `/`.
  - `test_notify_only_enqueues` — `notify(...)` calls `send_push.delay` once with str user id, does no I/O.
  - `test_send_push_sends_one_message_per_token` — 2 tokens (uz, en) → `send_each` gets 2 messages with the right titles and `data.route`.
  - `test_dead_tokens_are_deleted` — responses: [success, UnregisteredError] → second token row deleted, result `{"sent": 1, "removed": 1}`.
  - `test_transient_error_retries` — `send_each` raises `firebase_admin.exceptions.UnavailableError` → `self.retry` called.
  - `test_disabled_without_credentials` — `FIREBASE_CREDENTIALS_FILE=''` → `{"status": "disabled"}`, `send_each` not called.
- [ ] **Step 2: Run** `pytest tests/test_push.py -q` → FAIL.
- [ ] **Step 3: Implement** (lazy `firebase_admin.initialize_app(credentials.Certificate(path))` once per worker process).
- [ ] **Step 4: Run** → PASS; full suite green.
- [ ] **Step 5: Commit** — `Send push notifications through Firebase`.

### Task B3: events call notify()

**Files:**
- Modify: `backend/app/tasks/media.py` (`_render_room_image`, after `_save_render` succeeds)
- Modify: `backend/app/routers/seller.py` (`update order status`, after `changed` and `flush`), `backend/app/routers/admin_orders.py` (inside `if change_status(...)` after `flush`)
- Modify: `backend/app/routers/usta_profile.py` (`update_lead`: remember old status; notify only if changed and new in {viewed, contacted})
- Test: `backend/tests/test_push_events.py`

**Interfaces:**
- Consumes: `notify` (Task B2).
- Calls: `notify(user_id, "render_ready", {"room_id": room_id})`; `notify(order.user_id, "order_status", {"status": order.status})`; `notify(lead.user_id, "lead_status", {"status": lead.status})`.

- [ ] **Step 1: Failing tests** (patch `app.services.push.notify` where imported):
  - `test_render_success_notifies_owner` / `test_render_failure_does_not_notify`.
  - `test_seller_moving_order_notifies_buyer` (accepted→gathering) / `test_repeated_status_does_not_notify`.
  - `test_admin_cancel_notifies_buyer` / `test_buyer_cancel_does_not_notify` (`routers/orders.py` path unchanged).
  - `test_lead_viewed_and_contacted_notify_client` / `test_lead_closed_does_not_notify` / `test_same_lead_status_does_not_notify`.
- [ ] **Step 2: Run** → FAIL.
- [ ] **Step 3: Implement** the four call sites.
- [ ] **Step 4: Run** → PASS; full suite green.
- [ ] **Step 5: Commit** — `Render, order and usta updates send a push`.

### Task B4: production wiring

**Files:**
- Modify: `docker-compose.prod.yml` — `api` and `worker` services: env `FIREBASE_CREDENTIALS_FILE=/run/secrets/firebase.json` and volume `${FIREBASE_CREDENTIALS_HOST_PATH:-./secrets/firebase.json}:/run/secrets/firebase.json:ro`
- Modify: `.gitignore` (`secrets/`)

- [ ] **Step 1:** Apply; `docker compose -f docker-compose.prod.yml config >/dev/null` → exit 0.
- [ ] **Step 2:** Confirm a missing host file only disables push: the app's `send_push` treats a missing path as disabled (covered by B2 test) — note in the commit message that the user places the key at `secrets/firebase.json` on the server.
- [ ] **Step 3: Commit** — `Production containers can read the Firebase key`.

## Mobile (`andoza_ai_mobile`)

### Task M1: token registration lifecycle

**Files:**
- Modify: `pubspec.yaml` (`firebase_messaging`, `flutter_local_notifications`)
- Create: `lib/repositories/push_repository.dart`, `lib/services/push_service.dart`
- Modify: `lib/providers/auth_provider.dart` (`AuthNotifier` gets `Future<void> Function()? beforeLogout`, awaited at the start of `logout()`; the provider wires it to `pushService.unregister`)
- Test: `test/unit/push_service_test.dart`

**Interfaces:**
- Produces:
  ```dart
  abstract class MessagingClient {            // FirebaseMessaging in the app, fake in tests
    Future<String?> getToken();
    Stream<String> get onTokenRefresh;
    Future<void> deleteToken();
  }
  class PushRepository { Future<void> register(String token, String platform, String locale); Future<void> unregister(String token); }
  class PushService {
    PushService(this._messaging, this._repo, {required String Function() locale, required String platform});
    Future<void> registerCurrent();   // getToken → repo.register; errors swallowed (logged)
    void listenForRefresh();          // onTokenRefresh → repo.register
    Future<void> unregister();        // token → repo.unregister; then deleteToken; errors swallowed
  }
  final pushServiceProvider = Provider<PushService>(...);
  /// keep-alive: AuthAuthenticated → registerCurrent() + listenForRefresh()
  final pushRegistrationProvider = Provider<void>(...);
  ```
  `handleUnauthorized()` does not call the backend (session dead) — it only calls `deleteToken`.

- [ ] **Step 1: Failing tests** (fakes for MessagingClient and PushRepository; call log shared to assert order):
  - `signing in registers the token with platform and locale`.
  - `a refreshed token is registered again`.
  - `logout unregisters before the session is cleared` — order: `repo.unregister`, `messaging.deleteToken`, `authRepo.logout`.
  - `no token (iOS without APNs) is not an error` — `getToken` returns null → no register call, no throw.
  - `a backend error does not break sign-in` — `register` throws → `registerCurrent` completes normally.
- [ ] **Step 2: Run** `flutter test test/unit/push_service_test.dart` → FAIL.
- [ ] **Step 3: Implement**; read `pushRegistrationProvider` in `MyApp.build`.
- [ ] **Step 4: Run** → PASS; `flutter analyze` clean; full `flutter test` green.
- [ ] **Step 5: Commit** — `feat(push): register the phone for push while signed in`.

### Task M2: showing and opening notifications

**Files:**
- Create: `lib/services/push_router.dart`, `lib/services/local_notifications.dart`
- Create: `android/app/src/main/res/drawable/ic_notification.xml` (white silhouette from `ic_launcher_monochrome.xml`, fill `#FFFFFFFF`)
- Modify: `android/app/src/main/AndroidManifest.xml` (`android.permission.POST_NOTIFICATIONS`; `com.google.firebase.messaging.default_notification_channel_id` = `andoza_updates`; default icon `@drawable/ic_notification`)
- Modify: `lib/main.dart` / `lib/config/router.dart` (pending route handled after auth)
- Test: `test/unit/push_router_test.dart`

**Interfaces:**
- Produces:
  ```dart
  /// The route to open for a push's data, or '/' if it isn't one we allow.
  String safePushRoute(Map<String, dynamic> data);
  final pendingPushRouteProvider = StateProvider<String?>((ref) => null);
  class PushTapHandler { void attach(GoRouter router, ProviderContainer/WidgetRef ref); }   // getInitialMessage + onMessageOpenedApp + local tap
  ```
  Flow: tap → `safePushRoute` → if authenticated `router.go(route)` else store in `pendingPushRouteProvider`; the router's redirect sends signed-in users from `/login` to the pending route (and clears it) instead of `/`. Foreground `onMessage` → `flutter_local_notifications.show` on channel `andoza_updates` with payload = route.

- [ ] **Step 1: Failing tests:**
  - `allowed routes pass` — `/studio/3626078d-a9b0-46a2-9789-5befa9f60684`, `/profile/e6`, `/masters/u3` returned unchanged.
  - `anything else goes home` — `/studio/../login`, `/business/orders`, `https://evil.example`, missing `route`, `''` → `/`.
  - `a pending route opens after sign-in` — router test: pending `/profile/e6`, auth flips to authenticated on `/login` → location `/profile/e6`, pending cleared.
- [ ] **Step 2: Run** → FAIL.
- [ ] **Step 3: Implement.**
- [ ] **Step 4: Run** → PASS; full suite green; `flutter build apk --release` (prod dart-defines, `GRADLE_USER_HOME` as in stage 1) → "Built".
- [ ] **Step 5: Commit** — `feat(push): show notifications and open the right screen`.

### Task M3: asking for permission

**Files:**
- Create: `lib/widgets/push_permission_prompt.dart`
- Modify: home screen (`lib/screens/home/` main screen) — show the prompt once after sign-in
- Modify: `lib/screens/onboarding/e9_preferences_settings_screen.dart` — "Bildirishnomalar" row (status + opens system settings via `AppSettings`/`openAppSettings` already used by the scanner channel, or `permission_handler` if present)
- Modify: `lib/l10n/app_{uz,ru,en}.arb` (+ `flutter gen-l10n`)
- Test: `test/widget/push_permission_prompt_test.dart`

Copy:
- `pushPromptTitle`: "Xabar beraylikmi?" / "Сообщать вам?" / "Shall we notify you?"
- `pushPromptBody`: "Dizayningiz tayyor bo'lganda yoki buyurtma holati o'zgarganda xabar beramiz." / "Сообщим, когда дизайн будет готов или изменится статус заказа." / "We'll tell you when your design is ready or your order status changes."
- `pushPromptYes`: "Ha" / "Да" / "Yes"; `pushPromptLater`: "Keyinroq" / "Позже" / "Later"
- `settingsNotificationsTitle`: "Bildirishnomalar" / "Уведомления" / "Notifications"; `settingsNotificationsOn`/`Off`: "Yoqilgan"/"O'chirilgan", "Включены"/"Выключены", "On"/"Off"
- `pushChannelName`: "Andoza yangiliklari" / "Новости Andoza" / "Andoza updates"

**Interfaces:**
- Produces: `Future<bool> shouldAskForPush(SharedPreferences)` (false once answered), key `push_prompt_answered`.

- [ ] **Step 1: Failing tests:**
  - `the prompt shows once` — first pump shows title; tap "Keyinroq"; re-pump → not shown.
  - `yes asks the system` — fake permission requester called once after "Ha".
- [ ] **Step 2: Run** → FAIL.
- [ ] **Step 3: Implement.**
- [ ] **Step 4: Run** → PASS; `flutter analyze` clean; full `flutter test` green.
- [ ] **Step 5: Commit** — `feat(push): ask once, and a notifications row in settings`.

Manual (user + agent, Android phone, release APK, after B4 deploy and the key placed on the server): Firebase Console test message arrives; a shop moving an order sends a push that opens the orders screen; a render-ready push opens the studio.
