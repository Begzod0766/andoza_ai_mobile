# Studio turi Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Telefon tartibidagi 3D Studio birinchi ochilganda o'zi chiqadigan, xira fonli, 7 qadamli qo'llanma va sarlavhadagi "?" tugmasi.

**Architecture:**
- Holat va qadamlar mantig'i `lib/studioTour.ts` da sof funksiyalar bo'ladi.
- Overlay `components/studio/StudioTour.tsx` da yoziladi, nishonlarni `[data-tour="…"]` atributi orqali topadi.
- Turni `StudioPage` boshqaradi, chunki ⋮, ↶ ↷ va "?" uning sarlavhasida turadi.
- `ThreeDPage` Outlet context orqali turga ikki narsani aytadi:
  - "tayyorman": telefon tartibi, jonli 3D va burchak menyusi ko'rinib turibdi;
  - tur boshlanganda ochiq doira menyu va tanlovlarni yopadi.
- Hozirgi `TapHint` turning 1-qadamiga qo'shiladi.

**Tech Stack:** React + TypeScript, react-i18next, Tailwind, vitest + @testing-library/react. Yangi kutubxona yo'q.

**Repo:** `andoza_ai` (`frontend/`). Ish worktree'da bo'ladi (`~/Projects/andoza_ai/.claude/worktrees/studio-tour`, `origin/master` dan), chunki boshqa sessiyalar ham shu checkout'dan foydalanadi. node `~/.local/node/bin` da.

**Spec:** `andoza_ai_mobile/docs/superpowers/specs/2026-11-14-in-app-tutorial-design.md` ("Studio turi" bo'limi va umumiy qismlar).

## Global Constraints

- Yangi npm kutubxona qo'shilmaydi.
- Matnlar `frontend/src/i18n/locales/{uz,ru,en}.json` ga uchalasiga birga, `studio.tour.*` ostida qo'shiladi.
- "Ko'rildi" kaliti: `localStorage['studio.tour.v1.done'] = "1"`. `TapHint` qanday ishlasa, shunday ishlaydi: xotira yo'q bo'lsa yoki xato bersa, tur keyingi safar yana chiqadi.
- Tur tugaganda ham, o'tkazib yuborilganda ham `studio.tour.v1.done` va `studio.tapHint.seen` qo'yiladi.
- Turni hamma bir marta ko'radi (A). `studio.tapHint.seen` qo'yilgan bo'lsa ham tur chiqadi.
- Tur faqat `useCompactStudio()` true va jonli 3D tahrirda boshlanadi: `showsEditingCorners`, panorama emas, kamera stansiyasi emas. Aks holda kutib turadi va belgi qo'yilmaydi.
- Xira fonga bosish hech narsa qilmaydi. Ajratilgan joyga bosish "Keyingi" bilan teng, asl tugma ishlamaydi.
- Smeta qadamida faqat ⋮ tugmasi ajratiladi, menyu ochilmaydi.
- Nishon DOM'da yo'q yoki o'lchami 0 bo'lsa, qadam tushib qoladi.
- `npm run test -- --run` yashil, `npx tsc --noEmit` va `npm run lint` toza bo'lishi shart.

## Review Focus

1. `localStorage` xato bersa (masalan, WebView'da xususiy rejim): tur ko'rinadi va ilova yiqilmaydi. Task 1 testida tekshiriladi.
2. Ekran aylantirilsa yoki o'lchami o'zgarsa: ajratilgan joy nishonga qayta moslashadi. Task 2 testida `resize` hodisasi bilan tekshiriladi.
3. Tur boshlanganda doira menyu ochiq bo'lsa: menyu yopiladi, tur uning ustida qolmaydi. Task 3 testida tekshiriladi.
4. Qulf yoqilgan bo'lsa: tur baribir boshlanadi. Hozir `TapHint` qulfda yashirinadi, tur yashirinmasligi kerak. Task 3 testida tekshiriladi.
5. Panorama yoki kamera stansiyasida ochilsa: tur boshlanmaydi va belgi qo'yilmaydi, jonli 3D'ga qaytilganda boshlanadi. Task 3 testida tekshiriladi.

---

### Task 1: Tur holati va qadamlar

**Files:**
- Create: `frontend/src/lib/studioTour.ts`
- Test: `frontend/src/lib/studioTour.test.ts`

**Interfaces:**
- Produces:
  - `export type StudioTourTarget = 'scene' | 'arc' | 'menu' | 'undo' | 'lock' | 'camera' | 'help';`
  - `export const STUDIO_TOUR_STEPS: readonly StudioTourTarget[] = ['scene','arc','menu','undo','lock','camera','help'];`
  - `export const STUDIO_TOUR_KEY = 'studio.tour.v1.done';`
  - `export function isStudioTourDone(storage?: Storage | null): boolean`
  - `export function markStudioTourDone(storage?: Storage | null): void`. U `STUDIO_TOUR_KEY` va `studio.tapHint.seen` ga "1" yozadi, xatolarni yutadi.
  - `export function presentSteps(steps: readonly StudioTourTarget[], isPresent: (t: StudioTourTarget) => boolean): StudioTourTarget[]`
  - `export function shouldStartStudioTour(o: { done: boolean; compact: boolean; editingView: boolean }): boolean`. U `!done && compact && editingView` qaytaradi.

- [ ] **Step 1: Failing test.** Quyidagilar tekshiriladi:
  - bo'sh storage → `isStudioTourDone` false;
  - `markStudioTourDone` dan keyin ikkala kalit "1";
  - `getItem` xato beradigan storage bilan `isStudioTourDone` false qaytaradi va `markStudioTourDone` xato bermaydi;
  - `presentSteps(STUDIO_TOUR_STEPS, t => t !== 'camera')` natijasida 'camera' yo'q;
  - `shouldStartStudioTour` uchun to'rt kombinatsiya.
- [ ] **Step 2: `npx vitest run src/lib/studioTour.test.ts`.** Kutilgan natija: FAIL.
- [ ] **Step 3: Yozish.**
- [ ] **Step 4: Test.** Kutilgan natija: PASS.
- [ ] **Step 5: Commit.** `feat(studio-tour): tour state and step list`

### Task 2: `StudioTour` overlay komponenti

**Files:**
- Create: `frontend/src/components/studio/StudioTour.tsx`
- Modify: `frontend/src/i18n/locales/uz.json`, `ru.json`, `en.json`
- Test: `frontend/src/components/studio/StudioTour.test.tsx`

**Interfaces:**
- Consumes: `StudioTourTarget`, `presentSteps` (Task 1).
- Produces: `export function StudioTour(props: { steps: readonly StudioTourTarget[]; onFinish: () => void }): JSX.Element | null`.
  - Komponent ochilganda `document.querySelector('[data-tour="<id>"]')` orqali mavjud va o'lchami 0 dan katta nishonlarni oladi.
  - Nishon bo'lmasa, darhol `onFinish` chaqiriladi va `null` qaytariladi.
- Ko'rinish:
  - Nishon atrofida to'rtta to'rtburchak bo'ladi: `fixed`, `bg-black/55`, `backdrop-blur-sm`. Ular nishon atrofida "teshik" hosil qiladi, teshik atrofida 8 px bo'shliq va yorug' halqa (`ring-2`) bo'ladi.
  - Teshik ustida shaffof `<button aria-label={t('studio.tour.next')}>` turadi. U "Keyingi" ni bajaradi va asl elementga bosish o'tmaydi.
  - Fon to'rtburchaklari bosishni yutadi va hech narsa qilmaydi.
  - Karta nishonning ostida yoki ustida turadi, qayerda joy ko'p bo'lsa. Kartada sarlavha, matn, "{{current}}/{{total}}", O'tkazib yuborish, Keyingi yoki oxirgi qadamda Tushunarli bo'ladi. `role="dialog"`, `bg-card text-ink` (mavzu tokenlari) ishlatiladi.
  - `resize` va `orientationchange` da nishon o'lchami qayta olinadi.
  - `z-index` doira menyu va sahna yorliqlaridan yuqori bo'ladi (`z-[300]`).
- i18n kalitlari:
  - `studio.tour.{scene,arc,menu,undo,lock,camera,help}.{title,body}`;
  - `studio.tour.next`, `studio.tour.skip`, `studio.tour.done`, `studio.tour.step_of` (`"{{current}}/{{total}}"`), `studio.tour.help_btn`.
- uz matnlar:
  - scene: "Devor yoki polga bosing: shu joy uchun asboblar chiqadi (rang, plitka, oboy va boshqalar)";
  - arc: "Bo'limlar: Mebel, Santexnika, Rang, Chiroq";
  - menu: "⋮ → Smeta: narxlar, material va ish ro'yxati, PDF";
  - undo: "Oxirgi amalni bekor qilish va qaytarish";
  - lock: "Kamerani qotiradi: ekranni surganda xona aylanmaydi";
  - camera: "Tayyor kameralar va realistik render";
  - help: "Qo'llanmani istalgan payt qayta ko'ring".

- [ ] **Step 1: Failing test.** `data-tour="scene"` va `data-tour="menu"` li ikki element render qilinadi. `getBoundingClientRect` mock qilinadi. Tekshiriladi:
  - "1/2" va scene sarlavhasi ko'rinadi;
  - teshik ustidagi tugma bosilganda "2/2" chiqadi va nishonning `onClick` i chaqirilmaydi;
  - fon to'rtburchagiga bosilsa, hech narsa o'zgarmaydi;
  - "Tushunarli" bosilganda `onFinish` bir marta chaqiriladi;
  - "skip" bosilganda ham `onFinish` chaqiriladi;
  - `window.dispatchEvent(new Event('resize'))` dan keyin teshik yangi o'lchamga mos keladi;
  - hech nishon yo'q bo'lsa, `onFinish` darhol chaqiriladi.
- [ ] **Step 2: Test.** Kutilgan natija: FAIL.
- [ ] **Step 3: Yozish va uch locale'ga kalitlarni qo'shish.**
- [ ] **Step 4: Test va `npx tsc --noEmit`.** Kutilgan natija: PASS va toza.
- [ ] **Step 5: Commit.** `feat(studio-tour): spotlight overlay with blurred backdrop`

### Task 3: `StudioPage` va `ThreeDPage` ga ulash

**Files:**
- Modify: `frontend/src/pages/studio/StudioPage.tsx`:
  - tur holati qo'shiladi;
  - sarlavhada `UndoRedoButtons` (~617) atrofiga `data-tour="undo"` qo'yiladi;
  - `StudioMenu` tugmasiga `data-tour="menu"` qo'yiladi;
  - telefon tartibida ⋮ yonida `data-tour="help"` li "?" tugmasi qo'shiladi;
  - Outlet context'ga `studioTourActive` va `setStudioTourReady` qo'shiladi.
- Modify: Outlet context turi e'lon qilingan joy (`setOverlayHeader` qayerda bo'lsa, o'sha yerda).
- Modify: `frontend/src/pages/studio/ThreeDPage.tsx`:
  - sahna konteyneri (~891, `onPointerDownCapture` li div) → `data-tour="scene"`;
  - `QuarterArcMenu` tugmasi → `data-tour="arc"`;
  - qulf tugmasi (`onToggleViewLock`) → `data-tour="lock"`;
  - `CameraBar` tugmasi → `data-tour="camera"`;
  - `setStudioTourReady(compact && showsEditingCorners(...) && !panorama && cameraStation == null)` qo'ng'irog'i qo'shiladi;
  - `studioTourActive` true bo'lganda `closeRadial(); clearAllSelections(); disarmOpening();` chaqiriladi;
  - `TapHint` faqat `isStudioTourDone()` bo'lganda ko'rsatiladi.
- Test: `frontend/src/pages/studio/__tests__/studioTourWiring.test.tsx`

**Interfaces:**
- Consumes: Task 1 (`isStudioTourDone`, `markStudioTourDone`, `shouldStartStudioTour`, `STUDIO_TOUR_STEPS`) va Task 2 (`StudioTour`).
- Produces: Outlet context maydonlari `studioTourActive: boolean` va `setStudioTourReady: (ready: boolean) => void`.
- Qoida:
  - `StudioPage` da `useEffect` bor: `shouldStartStudioTour({done, compact, editingView: tourReady})` true bo'lsa, `setTourOpen(true)`;
  - "?" bosilsa, `setTourOpen(true)`, "ko'rildi" belgisidan qat'i nazar;
  - `onFinish` ichida `markStudioTourDone()` va `setTourOpen(false)`.

- [ ] **Step 1: Failing test.** `StudioPage` va soddalashtirilgan Outlet bola bilan, `useCompactStudio` mock qilinadi:
  - (a) ready=true va done=false bo'lsa, tur kartasi chiqadi;
  - (b) ready=false bo'lsa (panorama yoki kamera), tur chiqmaydi va belgi qo'yilmaydi; ready true bo'lganda chiqadi;
  - (c) done=true bo'lsa chiqmaydi, "?" bosilsa chiqadi;
  - (d) qulf yoqilgan bo'lsa ham (a) bajariladi;
  - (e) tur boshlanganda bola komponentga `studioTourActive=true` keladi; `ThreeDPage` uchun alohida unit tekshiruvda `closeRadial` chaqiriladi;
  - (f) compact=false (desktop) bo'lsa, tur ham, "?" ham yo'q.
- [ ] **Step 2: Test.** Kutilgan natija: FAIL.
- [ ] **Step 3: Yozish.**
- [ ] **Step 4: `npm run test -- --run`, `npx tsc --noEmit`, `npm run lint`.** Kutilgan natija: hammasi yashil va toza. Mavjud `TapHint.test.tsx` ham yashil qolishi kerak.
- [ ] **Step 5: Commit.** `feat(studio-tour): start on first live 3D view; ? in the header replays it`

### Task 4: Brauzerda va ilova ichida tekshirish, PR

- [ ] **Step 1: Lokal tekshiruv.** `npm run dev`, Chrome DevTools'da iPhone o'lchami, `localStorage` tozalangan. Kutilgan natija:
  - Studio ochilganda tur chiqadi va 7/7 qadam o'tadi;
  - kamera tugmasi yo'q xonada 6 qadam;
  - panorama'da boshlanmaydi;
  - "?" qayta boshlaydi;
  - ru va en tillarida matnlar to'g'ri;
  - kun va tun mavzusida karta o'qiladi.
- [ ] **Step 2: PR ochish** (`origin/master` ga), 2–3 ta skrinshot bilan. Merge faqat egasi "merge" deganda.
- [ ] **Step 3: Deploy'dan keyin ilova ichida tekshirish.** iPhone 17 Pro simulyatori, production. Ilova WebView'ida tur chiqadi va ↶ ↷ hamda ⋮ to'g'ri ajratiladi.
