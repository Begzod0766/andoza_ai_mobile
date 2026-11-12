# App Review: answer to Guideline 2.1 (Information Needed), 1.0.0 (32)

Apple rejected 1.0.0 (32) on 2026-11-12 with "Guideline 2.1 – Information Needed – New App
Submission" and asked for six things in the **Notes** field of *App Review Information*,
then a resubmission. Section A is the text to paste there (English, under Apple's
4000-character limit); replace `<VIDEO LINK>` first. Section B is the shot list for the
screen recording, which Apple wants **from a physical iPhone**.

## A. Notes text (paste into App Review Information → Notes)

```
Hello, thank you for the review. Answers to the six points:

1. SCREEN RECORDING (physical iPhone, latest iOS): <VIDEO LINK>
It starts at app launch and shows: sign-up and sign-in, a room in the 3D Studio, the estimate and its PDF, the shop, the craftsmen map, reporting and blocking a craftsman, reporting a product, and account deletion (Profile > Settings > Delete account).

2. PURPOSE AND AUDIENCE
Andoza AI helps homeowners in Uzbekistan plan a renovation before spending money. The user enters room dimensions (or scans the room with LiDAR on supported iPhones), designs it in a 3D Studio (floor, walls, wallpaper, tiles, ceiling, doors, windows, lights, furniture, plumbing) and gets an itemised estimate of materials and labour, which can be saved as a PDF. Users can then buy materials from local shops and contact local craftsmen (electricians, plumbers, tilers and others). Shop owners and craftsmen can register to list products or services; their profiles are reviewed by our moderators before they are published. The app is free; there are no in-app purchases or paid features.

3. HOW TO ACCESS THE MAIN FEATURES
- Sign in with the demo account in the Sign-In Information section (username and password, no SMS code needed). The account already has a sample project "Hammom namunasi" with a bathroom.
- Home > "Continue" on a project opens the 3D Studio. The corner button (arrow) opens categories (Furniture, Plumbing, Color, Lights). The menu (three dots) > Estimate shows the estimate; "Download PDF" exports it.
- Shop tab: materials and furniture from shops. Masters tab: craftsmen map and list. On a craftsman profile, "Report" and "Block" are available; on a product, "Report".
- Account deletion: Profile > Settings > Delete account (password field can be left empty for phone, Google or Apple accounts).
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

Record with iOS Control Center → Screen Recording. Install build 1.0.0 (32) through TestFlight. Keep it to 3–5 minutes, no sound needed. Upload it as an unlisted YouTube video or a public Google Drive link and put the link in the Notes text.

1. Launch the app from the home screen (the recording must start here).
2. Login screen: tap **Sign up**, show the form (a new test account may be created, or just show the screen). Go back.
3. Sign in with the **demo account** (the same one written in Sign-In Information).
4. Home: tap **Continue** on "Hammom namunasi" → 3D Studio opens. Rotate the room with a finger.
5. Corner button → **Plumbing** → open the panel, show the points, tick **Show pipe runs**, close.
6. Three dots → **Estimate**: scroll the breakdown, open Plumbing, tap **Download PDF** → the share sheet opens. Close it.
7. Back to Home → **Shop** tab: scroll, open one product, tap **Report**, pick a reason, **Send**.
8. **Masters** tab: open the map, open one craftsman → **Report** (send) → **Block** → confirm.
9. **Profile** → **Language**: switch to English (if not already).
10. **Profile → Settings → Delete account**: show the confirmation dialog. With a throw-away account, confirm to show the deletion working. Do not delete the demo account.
11. Stop the recording.

If a throw-away account is used for steps 2 and 10, sign up with it at step 2, run steps 4–9 with the demo account, then sign in with the throw-away account again and delete it at step 10.
