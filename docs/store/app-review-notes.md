# App Review: answer to Guideline 2.1 (Information Needed), 1.0.0 (32)

Apple rejected 1.0.0 (32) on 2026-11-12 with "Guideline 2.1 – Information Needed – New App
Submission" and asked for six things in the **Notes** field of *App Review Information*,
then a resubmission. Section A is the text to paste there (English, under Apple's
4000-character limit). Section B is the shot list the recording was planned from; section C
is what the recording actually shows.

## A. Notes text (paste into App Review Information → Notes)

```
Hello, thank you for the review. Answers to the six points:

1. SCREEN RECORDING (physical iPhone): https://drive.google.com/file/d/11sPGWGcnR-uddY3e4KeP625_D_60K1eB/view?usp=sharing
It starts at app launch and shows:
0:00 launch, language switch, sign-out
0:24 creating a new account with Sign in with Apple
0:44 adding a room: LiDAR scan (0:47-1:41, iPhone with LiDAR), then drawing a room by hand
1:50 the 3D Studio: ready-made design styles, furniture, camera views, a realistic render
3:50 the shop and reporting a product
4:10 a craftsman profile, sending a project to the craftsman, reporting the craftsman, the craftsmen map, blocking the craftsman
4:50 adding the project's materials to the cart, checkout, My orders
5:35 Profile with the Delete account button, then sign-out

2. PURPOSE AND AUDIENCE
Andoza AI helps homeowners in Uzbekistan plan a renovation before spending money. The user enters room dimensions (or scans the room with LiDAR on supported iPhones), designs it in a 3D Studio (floor, walls, wallpaper, tiles, ceiling, doors, windows, lights, furniture, plumbing) and gets an itemised estimate of materials and labour, which can be saved as a PDF. Users can then buy materials from local shops and contact local craftsmen (electricians, plumbers, tilers and others). Shop owners and craftsmen can register to list products or services; their profiles are reviewed by our moderators before they are published. The app is free; there are no in-app purchases or paid features.

3. HOW TO ACCESS THE MAIN FEATURES
- Sign in with the demo account in the Sign-In Information section (username and password, no SMS code needed), or create an account with Sign in with Apple.
- Home > "Continue" on a project opens the 3D Studio. The corner button (arrow) opens categories (Furniture, Plumbing, Color, Lights). The menu (three dots) > Estimate shows the estimate; "Download PDF" exports it.
- Shop tab: materials and furniture from shops. Masters tab: craftsmen map and list. On a craftsman profile, "Report" and "Block" are available; on a product, "Report".
- Account deletion: Profile > Delete account (at the bottom of the Profile screen). It asks for confirmation and then deletes the account and its data.
- Other sign-in options on the login screen: SMS code to a phone number, Sign in with Apple, Google.
- LiDAR room scanning (the "+" button > scan) works only on iPhones with LiDAR; all other features work without it.
- Language: Uzbek, Russian, English (Profile > Language).

4. EXTERNAL SERVICES
- Our own backend at andozaai.uz (accounts, projects, estimates, shops, craftsmen).
- Sign in with Apple and Google Sign-In (authentication).
- Eskiz / Playmobile (SMS sign-in codes, Uzbekistan).
- OpenAI and Google Gemini (AI designer suggestions from a short text prompt).
- Tripo (3D models generated from product photos).
- OpenStreetMap (map tiles for the craftsmen map).
- Google Firebase: Crashlytics, Analytics, Cloud Messaging (crash reports, usage statistics, notifications).
- Apple RoomPlan / ARKit on device (LiDAR scanning).

5. REGIONAL DIFFERENCES
The app works the same in every region where it is available. Its content (shops, craftsmen, product prices in UZS) is focused on Uzbekistan, mainly Tashkent, so outside Uzbekistan there are fewer local shops and craftsmen; the 3D Studio and estimate work everywhere. SMS sign-in codes are sent to Uzbek phone numbers; elsewhere users can sign in with Apple, Google or a username and password.

6. REGULATED INDUSTRY / THIRD-PARTY MATERIAL
The app does not operate in a regulated industry. Product photos and descriptions are supplied by the shops that list them; craftsmen supply their own profiles. Both are moderated, and users can report content and block craftsmen.
```

## B. Screen recording shot list (physical iPhone)

Record with iOS Control Center → Screen Recording on a physical iPhone (TestFlight or a direct install). Keep it to 3–5 minutes, no sound needed. Upload it as an unlisted YouTube video or a public Google Drive link and put the link in the Notes text.

1. Launch the app from the home screen (the recording must start here).
2. Login screen: tap **Sign up**, show the form (a new test account may be created, or just show the screen). Go back.
3. Sign in with the **demo account** (the same one written in Sign-In Information).
4. Home: tap **Continue** on "Hammom namunasi" → 3D Studio opens. Rotate the room with a finger.
5. Corner button → **Plumbing** → open the panel, show the points, tick **Show pipe runs**, close.
6. Three dots → **Estimate**: scroll the breakdown, open Plumbing, tap **Download PDF** → the share sheet opens. Close it.
7. Back to Home → **Shop** tab: scroll, open one product, tap **Report**, pick a reason, **Send**.
8. **Masters** tab: open one craftsman from the list or the map → **Report** (send) → **Block** → confirm.
9. **Profile** → **Language**: switch to English (if not already).
10. **Profile → Settings → Delete account**: show the confirmation dialog. With a throw-away account, confirm to show the deletion working. Do not delete the demo account.
11. Stop the recording.

If a throw-away account is used for steps 2 and 10, sign up with it at step 2, run steps 4–9 with the demo account, then sign in with the throw-away account again and delete it at step 10.

## C. The recording as uploaded (2026-11-13)

`andoza-ai-obzor-skaner.mp4`, 5:44, 880 × 1920, recorded on an iPhone in English. It is the
owner's 4:50 walkthrough (recorded 2026-11-12) with the LiDAR part of `IMG_9562.MP4`
(2026-10-31, an iPhone with LiDAR) cut in after the "New project" sheet at 0:47, where the
walkthrough itself goes on with "Draw it yourself". Joined with ffmpeg; nothing else edited.
Shared on Google Drive as "anyone with the link".

Compared with section B:
- shown: launch, account creation (Sign in with Apple), LiDAR scan, 3D Studio, render, shop,
  product report, craftsman report and block, cart and checkout;
- not shown: the estimate PDF, the plumbing panel, and **account deletion is not carried out**:
  the Delete account button is visible at 5:35, then the user signs out;
- personal data visible in the recording: an Apple ID e-mail (Sign in with Apple sheet, 0:24)
  and a phone number typed into "Send your project" (4:15). The link is public.
