import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('uz'),
  ];

  /// Product name. Shown as the login screen heading and used as the app's brand label.
  ///
  /// In uz, this message translates to:
  /// **'Andoza AI'**
  String get appTitle;

  /// Retry. Button on error views that re-attempts the failed action.
  ///
  /// In uz, this message translates to:
  /// **'Qayta urinish'**
  String get actionRetry;

  /// Back. Navigates to the previous screen/step.
  ///
  /// In uz, this message translates to:
  /// **'Orqaga'**
  String get actionBack;

  /// Next. Advances to the next screen/step.
  ///
  /// In uz, this message translates to:
  /// **'Keyingi'**
  String get actionNext;

  /// Continue. Proceeds with the current flow.
  ///
  /// In uz, this message translates to:
  /// **'Davom etish'**
  String get actionContinue;

  /// Cancel. Dismisses a dialog/sheet without applying changes.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilish'**
  String get actionCancel;

  /// Save. Persists the current changes/selection.
  ///
  /// In uz, this message translates to:
  /// **'Saqlash'**
  String get actionSave;

  /// Close. Dismisses a sheet, dialog or overlay.
  ///
  /// In uz, this message translates to:
  /// **'Yopish'**
  String get actionClose;

  /// Done. Confirms completion of a step/action.
  ///
  /// In uz, this message translates to:
  /// **'Tayyor'**
  String get actionDone;

  /// Finish. Completes a multi-step flow.
  ///
  /// In uz, this message translates to:
  /// **'Yakunlash'**
  String get actionFinish;

  /// Bottom navigation tab: Home.
  ///
  /// In uz, this message translates to:
  /// **'Uy'**
  String get navHome;

  /// Bottom navigation tab: Shop (materials marketplace).
  ///
  /// In uz, this message translates to:
  /// **'Do\'kon'**
  String get navShop;

  /// Bottom navigation tab: Masters (craftsman marketplace).
  ///
  /// In uz, this message translates to:
  /// **'Ustalar'**
  String get navMasters;

  /// Bottom navigation tab: Profile.
  ///
  /// In uz, this message translates to:
  /// **'Profil'**
  String get navProfile;

  /// Login screen: hint text for the email/username field.
  ///
  /// In uz, this message translates to:
  /// **'Email'**
  String get loginEmailHint;

  /// Login screen: hint text for the password field.
  ///
  /// In uz, this message translates to:
  /// **'Parol'**
  String get loginPasswordHint;

  /// Login screen: tooltip on the eye icon that reveals the password.
  ///
  /// In uz, this message translates to:
  /// **'Parolni ko\'rsatish'**
  String get loginShowPassword;

  /// Login screen: tooltip on the eye icon that masks the password.
  ///
  /// In uz, this message translates to:
  /// **'Parolni yashirish'**
  String get loginHidePassword;

  /// Login screen: submit button label.
  ///
  /// In uz, this message translates to:
  /// **'Kirish'**
  String get loginButton;

  /// Login screen: snackbar shown when the user submits with an empty email or password.
  ///
  /// In uz, this message translates to:
  /// **'Barcha maydonlarni to\'ldiring'**
  String get loginEmptyFields;

  /// B1 room-condition step: the single question asking the room's current baseline surface condition.
  ///
  /// In uz, this message translates to:
  /// **'Xonangiz hozir qaysi holatda?'**
  String get b1Question;

  /// B1 room-condition step: link opening the floor/ceiling help sheet for users unsure of the difference.
  ///
  /// In uz, this message translates to:
  /// **'Farqini bilmayapsizmi? →'**
  String get b1DontKnowDifference;

  /// B1 room-condition step: link to override floor/ceiling condition when they differ from the walls.
  ///
  /// In uz, this message translates to:
  /// **'Pol yoki shift boshqacha bo\'lsa →'**
  String get b1FloorCeilingDifferent;

  /// B1 room-condition step: primary button that saves the condition and enters the room designer.
  ///
  /// In uz, this message translates to:
  /// **'Xonaga kirish'**
  String get b1EnterRoom;

  /// Brand wordmark (no space). Shown on the splash screen and the Home status pill.
  ///
  /// In uz, this message translates to:
  /// **'AndozaAI'**
  String get brandName;

  /// Accessibility label for the center orange FAB in the bottom nav that opens the new-project sheet.
  ///
  /// In uz, this message translates to:
  /// **'Yangi loyiha qo\'shish'**
  String get navAddProject;

  /// Login (phone-OTP step): heading and the phone-number field label.
  ///
  /// In uz, this message translates to:
  /// **'Telefon raqam'**
  String get loginPhoneLabel;

  /// Login (phone-OTP step): subtitle under the heading explaining a phone number is required to log in.
  ///
  /// In uz, this message translates to:
  /// **'Kirish uchun telefon raqamingizni kiriting'**
  String get loginPhoneSubtitle;

  /// Login (phone-OTP step): placeholder text inside the phone-number input.
  ///
  /// In uz, this message translates to:
  /// **'90 123 45 67'**
  String get loginPhoneHint;

  /// Login (phone-OTP step): helper note that the SMS code goes to the entered number.
  ///
  /// In uz, this message translates to:
  /// **'Sms kod shu raqamga yuboriladi'**
  String get loginPhoneSmsHint;

  /// Login (phone-OTP step): primary button that requests the OTP code.
  ///
  /// In uz, this message translates to:
  /// **'OTP Yuborish'**
  String get loginSendOtp;

  /// Login (phone-OTP step): informational tip box about the 6-digit code and retrying if SMS is delayed.
  ///
  /// In uz, this message translates to:
  /// **'Siz kiritgan raqamga 6 xonali kod yuboriladi. Agar SMS kelmaydigan bo\'lsa, 2-3 minutdan keyin qayta urinib ko\'ring.'**
  String get loginOtpInfoBox;

  /// Login (phone-OTP step): outlined button switching to the username/password login form.
  ///
  /// In uz, this message translates to:
  /// **'Login va parol bilan kirish'**
  String get loginWithUsername;

  /// Login (OTP code step): heading confirming the code was sent.
  ///
  /// In uz, this message translates to:
  /// **'✓ Kod yuborildi'**
  String get loginCodeSentTitle;

  /// Login (OTP code step): sentence fragment following the phone number ('... we will send a 6-digit code to <number>').
  ///
  /// In uz, this message translates to:
  /// **' raqamiga 6 xonali kod yuboramiz'**
  String get loginCodeSentSuffix;

  /// Login (OTP code step): primary button that verifies the entered code.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlash'**
  String get loginVerify;

  /// Login (OTP code step): button to resend the code once the cooldown elapses.
  ///
  /// In uz, this message translates to:
  /// **'Qayta yuborish'**
  String get loginResend;

  /// Login (OTP code step): resend button label during the cooldown, showing remaining seconds.
  ///
  /// In uz, this message translates to:
  /// **'Qayta yuborish ({seconds} s)'**
  String loginResendCountdown(int seconds);

  /// Login (OTP code step): text button with a left arrow returning to the phone-entry step.
  ///
  /// In uz, this message translates to:
  /// **'← Orqaga'**
  String get loginBackArrow;

  /// Login (username step): heading and submit button label ('Sign in').
  ///
  /// In uz, this message translates to:
  /// **'Kirish'**
  String get loginSignIn;

  /// Login/register: placeholder text for the username field.
  ///
  /// In uz, this message translates to:
  /// **'Login'**
  String get loginUsernameHint;

  /// Login/register: placeholder text for the password field.
  ///
  /// In uz, this message translates to:
  /// **'Parol'**
  String get loginPasswordLabel;

  /// Login (username step): prompt preceding the register link ('No account? ').
  ///
  /// In uz, this message translates to:
  /// **'Akkauntingiz yo\'qmi? '**
  String get loginNoAccount;

  /// Register: link, heading and submit button label ('Sign up').
  ///
  /// In uz, this message translates to:
  /// **'Ro\'yxatdan o\'tish'**
  String get loginRegister;

  /// Register: placeholder for the optional name field.
  ///
  /// In uz, this message translates to:
  /// **'Ism (ixtiyoriy)'**
  String get loginNameHint;

  /// Register: placeholder for the confirm-password field.
  ///
  /// In uz, this message translates to:
  /// **'Parolni tasdiqlang'**
  String get loginConfirmPasswordHint;

  /// Register: prompt preceding the sign-in link ('Already have an account? ').
  ///
  /// In uz, this message translates to:
  /// **'Allaqachon akkauntingiz bormi? '**
  String get loginHaveAccount;

  /// Login: outlined button that signs in with a Google account.
  ///
  /// In uz, this message translates to:
  /// **'Google bilan kirish'**
  String get loginWithGoogle;

  /// Login error: Google sign-in failed (invalid token or Google error).
  ///
  /// In uz, this message translates to:
  /// **'Google orqali kirib bo\'lmadi. Qayta urinib ko\'ring.'**
  String get loginGoogleFailed;

  /// Login: 'or' divider between the OTP and username entry points.
  ///
  /// In uz, this message translates to:
  /// **'yoki'**
  String get loginOr;

  /// Login: tagline under the brand name above the auth card.
  ///
  /// In uz, this message translates to:
  /// **'Ta\'mir va interyer loyihalaringiz bir joyda'**
  String get loginTagline;

  /// Login: app-version footnote below the auth card.
  ///
  /// In uz, this message translates to:
  /// **'AndozaAI v1.0.0'**
  String get loginVersion;

  /// Login error: the entered phone number is invalid, with an example format.
  ///
  /// In uz, this message translates to:
  /// **'Telefon raqam noto\'g\'ri. Masalan: 90 123 45 67'**
  String get loginErrorInvalidPhone;

  /// Login error: a generic server failure, asking the user to retry.
  ///
  /// In uz, this message translates to:
  /// **'Serverda xatolik. Qayta urinib ko\'ring.'**
  String get loginErrorServer;

  /// Login error: the entered OTP code is wrong or expired.
  ///
  /// In uz, this message translates to:
  /// **'Kod noto\'g\'ri yoki eskirgan.'**
  String get loginErrorInvalidCode;

  /// Login error: username and password are both required.
  ///
  /// In uz, this message translates to:
  /// **'Login va parol majburiy.'**
  String get loginErrorCredentialsRequired;

  /// Login error: the username or password is incorrect.
  ///
  /// In uz, this message translates to:
  /// **'Login yoki parol noto\'g\'ri.'**
  String get loginErrorWrongCredentials;

  /// Register error: username must be at least 3 characters.
  ///
  /// In uz, this message translates to:
  /// **'Login kamida 3 ta belgidan iborat bo\'lishi kerak.'**
  String get loginErrorUsernameShort;

  /// Register error: username is longer than the 50 characters the server accepts.
  ///
  /// In uz, this message translates to:
  /// **'Login 50 ta belgidan oshmasin.'**
  String get loginErrorUsernameLong;

  /// Register error: password must be at least 6 characters.
  ///
  /// In uz, this message translates to:
  /// **'Parol kamida 6 ta belgidan iborat bo\'lishi kerak.'**
  String get loginErrorPasswordShort;

  /// Register error: the two passwords do not match.
  ///
  /// In uz, this message translates to:
  /// **'Parollar mos kelmadi.'**
  String get loginErrorPasswordMismatch;

  /// Register error: the chosen username is already taken.
  ///
  /// In uz, this message translates to:
  /// **'Bu login allaqachon band.'**
  String get loginErrorUsernameTaken;

  /// Register error: a generic registration failure.
  ///
  /// In uz, this message translates to:
  /// **'Ro\'yxatdan o\'tishda xato yuz berdi.'**
  String get loginErrorRegisterFailed;

  /// Home header: small 'Welcome' label above the user's name.
  ///
  /// In uz, this message translates to:
  /// **'Xush kelibsiz'**
  String get homeWelcome;

  /// Home header: personalized greeting when the user's name is known.
  ///
  /// In uz, this message translates to:
  /// **'Salom, {name}! 👋'**
  String homeGreetingNamed(String name);

  /// Home header: greeting fallback when the user's name is unknown.
  ///
  /// In uz, this message translates to:
  /// **'Salom! 👋'**
  String get homeGreeting;

  /// Home: onboarding story-circle label opening the 'how it works' guide.
  ///
  /// In uz, this message translates to:
  /// **'Qanday ishlaydi?'**
  String get homeStoryHowItWorks;

  /// Home: onboarding story-circle label opening the demo guide.
  ///
  /// In uz, this message translates to:
  /// **'Demo qo\'llanma'**
  String get homeStoryDemoGuide;

  /// Home: onboarding story-circle label opening the demo.
  ///
  /// In uz, this message translates to:
  /// **'Demo'**
  String get homeStoryDemo;

  /// Home empty state: title prompting the user to add their first room.
  ///
  /// In uz, this message translates to:
  /// **'Birinchi xonangizni qo\'shing'**
  String get homeEmptyTitle;

  /// Home empty state: message noting there are no projects yet.
  ///
  /// In uz, this message translates to:
  /// **'Hali loyiha yo\'q — yangi loyiha boshlang'**
  String get homeEmptyMessage;

  /// Home empty state: button that starts a new project.
  ///
  /// In uz, this message translates to:
  /// **'+ Loyiha qo\'shish'**
  String get homeEmptyAction;

  /// Home: section title above the quick-action grid.
  ///
  /// In uz, this message translates to:
  /// **'Tezkor amallar'**
  String get homeQuickActions;

  /// Home quick action: scan a room.
  ///
  /// In uz, this message translates to:
  /// **'Xonani skanlash'**
  String get homeQuickScan;

  /// Home quick action: cost estimate.
  ///
  /// In uz, this message translates to:
  /// **'Smeta'**
  String get homeQuickEstimate;

  /// Home quick action: dealers/shops.
  ///
  /// In uz, this message translates to:
  /// **'Dilerlar'**
  String get homeQuickDealers;

  /// Home (with projects): error-view title when the project list fails to load.
  ///
  /// In uz, this message translates to:
  /// **'Loyihalarni yuklab bo\'lmadi'**
  String get homeProjectsLoadError;

  /// Home (with projects): button revealing the next page of project cards.
  ///
  /// In uz, this message translates to:
  /// **'Yana ko\'rsatish'**
  String get homeLoadMore;

  /// Home (with projects): progress legend for stages that already existed and are not counted.
  ///
  /// In uz, this message translates to:
  /// **'Mavjud (hisoblanmaydi)'**
  String get homeLegendExisting;

  /// Home (with projects): progress legend for stages still needed (the delta).
  ///
  /// In uz, this message translates to:
  /// **'Kerak (delta)'**
  String get homeLegendNeeded;

  /// Home (with projects): resume CTA that continues the active project in the 3D Studio.
  ///
  /// In uz, this message translates to:
  /// **'Davom etish'**
  String get homeResume;

  /// Home (with projects): snackbar shown when resuming a project that has no room yet.
  ///
  /// In uz, this message translates to:
  /// **'Bu loyihada hali xona yo\'q'**
  String get homeNoRoomYet;

  /// Home (with projects): renovation stage progress label ('Stage N/8').
  ///
  /// In uz, this message translates to:
  /// **'Bosqich {current}/8'**
  String homeStageProgress(int current);

  /// Home (with projects): stage label noting which named stages already existed.
  ///
  /// In uz, this message translates to:
  /// **'Bosqich {current}/8 · ✓ {names} mavjud edi'**
  String homeStageProgressExcluded(int current, String names);

  /// Home (with projects): compact stage label noting how many stages already existed.
  ///
  /// In uz, this message translates to:
  /// **'Bosqich {current}/8 · ✓ {count} bosqich mavjud edi'**
  String homeStageProgressExcludedCount(int current, int count);

  /// Home (with projects): title of the stage-picker bottom sheet ('Choose a stage').
  ///
  /// In uz, this message translates to:
  /// **'Bosqichni tanlang'**
  String get homeStagePickerTitle;

  /// Home (with projects): a single stage option row in the stage picker.
  ///
  /// In uz, this message translates to:
  /// **'Bosqich {index}/8 · {label}'**
  String homeStageOption(int index, String label);

  /// Home (with projects): snackbar shown when saving the selected stage fails.
  ///
  /// In uz, this message translates to:
  /// **'Bosqichni saqlab bo\'lmadi'**
  String get homeStageSaveError;

  /// Home (with projects): room count shown under a project's name (hero card and list rows).
  ///
  /// In uz, this message translates to:
  /// **'{count} xona'**
  String homeRoomCount(int count);

  /// Home (with projects): stat-chip label for the room's floor area.
  ///
  /// In uz, this message translates to:
  /// **'Maydon'**
  String get homeStatAreaLabel;

  /// Home (with projects): stat-chip label for the count of placed 3D furniture models.
  ///
  /// In uz, this message translates to:
  /// **'3D model'**
  String get homeStatModelsLabel;

  /// Home (with projects): stat-chip label for the room's cost estimate.
  ///
  /// In uz, this message translates to:
  /// **'Smeta'**
  String get homeStatEstimateLabel;

  /// Home (with projects): floor-area stat-chip value, e.g. "24.5 m²".
  ///
  /// In uz, this message translates to:
  /// **'{area} m²'**
  String homeAreaValue(String area);

  /// Home (with projects): estimate stat-chip value in millions of UZS, e.g. "12.4 mln".
  ///
  /// In uz, this message translates to:
  /// **'{amount} mln'**
  String homeEstimateMln(String amount);

  /// Home (with projects): stat-chip value shown when the room has no data for that stat yet.
  ///
  /// In uz, this message translates to:
  /// **'—'**
  String get homeStatDash;

  /// Renovation stage name: plastering (suvoq).
  ///
  /// In uz, this message translates to:
  /// **'suvoq'**
  String get stageSuvoq;

  /// Renovation stage name: putty/finishing (shpaklovka).
  ///
  /// In uz, this message translates to:
  /// **'shpaklovka'**
  String get stageShpaklovka;

  /// Renovation stage name: paint/wallpaper (bo'yoq/oboi).
  ///
  /// In uz, this message translates to:
  /// **'bo\'yoq/oboi'**
  String get stageBoyoqOboi;

  /// Renovation stage name: flooring (pol).
  ///
  /// In uz, this message translates to:
  /// **'pol'**
  String get stagePol;

  /// Renovation stage name: furniture (mebel).
  ///
  /// In uz, this message translates to:
  /// **'mebel'**
  String get stageMebel;

  /// Renovation stage name: electrical (elektr).
  ///
  /// In uz, this message translates to:
  /// **'elektr'**
  String get stageElektr;

  /// Renovation stage name: lighting (yorug'lik).
  ///
  /// In uz, this message translates to:
  /// **'yorug\'lik'**
  String get stageYoruglik;

  /// Renovation stage name: plumbing (santexnika).
  ///
  /// In uz, this message translates to:
  /// **'santexnika'**
  String get stageSantexnika;

  /// Generic affirmative ('Yes'). Used for boolean spec values.
  ///
  /// In uz, this message translates to:
  /// **'Ha'**
  String get commonYes;

  /// Generic negative ('No'). Used for boolean spec values.
  ///
  /// In uz, this message translates to:
  /// **'Yo\'q'**
  String get commonNo;

  /// S1 shop home: tooltip on the cart icon button in the app bar.
  ///
  /// In uz, this message translates to:
  /// **'Savatcha'**
  String get shopCartTooltip;

  /// Shop: placeholder text in the material search field (S1 and E10).
  ///
  /// In uz, this message translates to:
  /// **'Material qidirish...'**
  String get shopSearchHint;

  /// Shop: filter/category chip for 'All' (S1 categories, S4 and E10 filters).
  ///
  /// In uz, this message translates to:
  /// **'Barchasi'**
  String get shopFilterAll;

  /// Shop: small tag on product cards/rows marking an item the active project needs (S1 and E10).
  ///
  /// In uz, this message translates to:
  /// **'Loyihada'**
  String get shopInProjectTag;

  /// S2 project materials: app bar title ('Project materials').
  ///
  /// In uz, this message translates to:
  /// **'Loyiha materiallari'**
  String get shopMaterialsTitle;

  /// S2 project materials: green banner stating the app auto-computed area and stage count from the project.
  ///
  /// In uz, this message translates to:
  /// **'App loyihangiz asosida avtomatik hisobladi — {area} m², {count} bosqich'**
  String shopMaterialsAutoCalc(String area, int count);

  /// S2 project materials: sticky button that adds every checked material to the cart.
  ///
  /// In uz, this message translates to:
  /// **'Tanlanganlarni savatga'**
  String get shopAddAllToCart;

  /// S2 project materials: label above the room picker chips.
  ///
  /// In uz, this message translates to:
  /// **'Qaysi xona uchun?'**
  String get shopSelectRoomLabel;

  /// S2 project materials: count of checked materials shown in the totals bar.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta tanlandi'**
  String shopSelectedCount(int count);

  /// S3 product detail: badge shown when the product is sold by an official dealer.
  ///
  /// In uz, this message translates to:
  /// **'✓ Rasmiy diler'**
  String get shopOfficialDealer;

  /// S3 product detail: recommendation line stating the computed quantity the project needs; a coverage note may be appended.
  ///
  /// In uz, this message translates to:
  /// **'Loyihangiz uchun ~{quantity} {unit} kerak'**
  String shopProjectNeed(String quantity, String unit);

  /// S3 product detail: label preceding the quantity stepper ('Quantity:').
  ///
  /// In uz, this message translates to:
  /// **'Miqdor:'**
  String get shopQuantityLabel;

  /// S3 product detail: spec row label for coverage.
  ///
  /// In uz, this message translates to:
  /// **'Qoplama'**
  String get shopSpecCoverage;

  /// S3 product detail: spec row label for drying time.
  ///
  /// In uz, this message translates to:
  /// **'Quriish vaqti'**
  String get shopSpecDryingTime;

  /// S3 product detail: spec row label for whether the product is washable.
  ///
  /// In uz, this message translates to:
  /// **'Yuvilishi'**
  String get shopSpecWashable;

  /// S3 product detail: row opening the dealer comparison, naming the default dealer.
  ///
  /// In uz, this message translates to:
  /// **'Qayerdan olish — {name}'**
  String shopWhereToBuy(String name);

  /// S3 product detail: small caption under the headline price, naming which dealer that price is from (the auto-selected cheapest dealer, not necessarily the product's catalog brand).
  ///
  /// In uz, this message translates to:
  /// **'{dealer} narxi'**
  String shopPriceFromDealer(String dealer);

  /// Shop: snackbar confirming an item was added to the cart (S3, S4, E10).
  ///
  /// In uz, this message translates to:
  /// **'Savatga qo\'shildi'**
  String get shopAddedToCart;

  /// S3 product detail: add-to-cart button label with the computed line price.
  ///
  /// In uz, this message translates to:
  /// **'Savatga qo\'shish · {price}'**
  String shopAddToCartPrice(String price);

  /// S4 dealer comparison: app bar title ('Compare dealers').
  ///
  /// In uz, this message translates to:
  /// **'Diler taqqoslash'**
  String get shopDealerCompareTitle;

  /// Shop: filter chip for cheapest offers (S4 and E10).
  ///
  /// In uz, this message translates to:
  /// **'Eng arzon'**
  String get shopFilterCheapest;

  /// S4 dealer comparison: filter chip for official dealers only.
  ///
  /// In uz, this message translates to:
  /// **'Rasmiy diler'**
  String get shopFilterOfficial;

  /// S4 dealer comparison: filter chip for fastest delivery.
  ///
  /// In uz, this message translates to:
  /// **'Eng tez'**
  String get shopFilterFastest;

  /// S4 dealer comparison: green ribbon marking the best (cheapest) dealer offer ('BEST').
  ///
  /// In uz, this message translates to:
  /// **'ENG YAXSHI'**
  String get shopBestRibbon;

  /// S4 dealer comparison: dealer subtitle showing district and delivery time in days.
  ///
  /// In uz, this message translates to:
  /// **'{district} · {days} kunda yetkazish'**
  String shopDeliveryDays(String district, int days);

  /// S4 dealer comparison: button that selects a dealer offer and adds it to the cart.
  ///
  /// In uz, this message translates to:
  /// **'Tanlash'**
  String get shopSelect;

  /// S5 cart: app bar title ('Cart').
  ///
  /// In uz, this message translates to:
  /// **'Savat'**
  String get shopCartTitle;

  /// S5 cart: empty-state message when the cart has no items.
  ///
  /// In uz, this message translates to:
  /// **'Savat bo\'sh'**
  String get shopCartEmpty;

  /// Shop: summary row label for the materials subtotal (S5 and S6).
  ///
  /// In uz, this message translates to:
  /// **'Materiallar'**
  String get shopMaterials;

  /// Shop: summary/row label for the delivery fee (S5 dealer block, S5 and S6 summaries).
  ///
  /// In uz, this message translates to:
  /// **'Yetkazish'**
  String get shopDelivery;

  /// S5 cart: grand-total label in the footer ('Total').
  ///
  /// In uz, this message translates to:
  /// **'Umumiy summa'**
  String get shopGrandTotal;

  /// S5 cart: primary button proceeding to checkout ('Place order').
  ///
  /// In uz, this message translates to:
  /// **'Buyurtmani rasmiylashtirish'**
  String get shopCheckout;

  /// S6 checkout: app bar title ('Payment').
  ///
  /// In uz, this message translates to:
  /// **'To\'lov'**
  String get shopCheckoutTitle;

  /// S6 checkout: section title above the delivery-address fields.
  ///
  /// In uz, this message translates to:
  /// **'Yetkazish manzili'**
  String get shopDeliveryAddress;

  /// S6 checkout: hint text in the address field.
  ///
  /// In uz, this message translates to:
  /// **'Manzil'**
  String get shopAddressHint;

  /// S6 checkout: hint text in the phone-number field.
  ///
  /// In uz, this message translates to:
  /// **'Telefon raqami'**
  String get shopPhoneHint;

  /// S6 checkout: section title above the payment-method tiles.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov usuli'**
  String get shopPaymentMethod;

  /// S6 checkout: section title above the order summary.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtma xulosasi'**
  String get shopOrderSummary;

  /// S6 checkout: label for the total amount due in the sticky footer.
  ///
  /// In uz, this message translates to:
  /// **'To\'lanadi'**
  String get shopAmountDue;

  /// S6 checkout: primary button that places the order ('Pay').
  ///
  /// In uz, this message translates to:
  /// **'To\'lash'**
  String get shopPay;

  /// S6 checkout: snackbar shown when persisting the placed order to the server fails.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtmani serverga saqlashda xatolik: {error}'**
  String shopOrderSaveError(String error);

  /// S7 order confirmation: app bar title ('Order status').
  ///
  /// In uz, this message translates to:
  /// **'Buyurtma holati'**
  String get shopOrderStatusTitle;

  /// S7 order confirmation: section title above the ordered items list.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtma tarkibi'**
  String get shopOrderContents;

  /// S7 order confirmation: total label ('Total').
  ///
  /// In uz, this message translates to:
  /// **'Jami'**
  String get shopTotal;

  /// S7 order confirmation: snackbar confirming the craftsman was notified.
  ///
  /// In uz, this message translates to:
  /// **'Usta xabardor qilindi'**
  String get shopMasterNotified;

  /// S7 order confirmation: secondary button that notifies the craftsman the materials arrived.
  ///
  /// In uz, this message translates to:
  /// **'Ustaga topshirish'**
  String get shopHandToMaster;

  /// S7 order confirmation: text button returning to the shop home ('Back to shop').
  ///
  /// In uz, this message translates to:
  /// **'Do\'konga qaytish'**
  String get shopBackToShop;

  /// U4/U5 opened without a craftsman (deep link / restored route)
  ///
  /// In uz, this message translates to:
  /// **'Usta topilmadi'**
  String get mastersNotFound;

  /// Back from a screen with unsaved edits: confirm dialog
  ///
  /// In uz, this message translates to:
  /// **'Saqlanmagan o\'zgarishlar'**
  String get unsavedChangesTitle;

  /// Back from a screen with unsaved edits: confirm dialog
  ///
  /// In uz, this message translates to:
  /// **'Chiqsangiz, kiritganlaringiz yo\'qoladi.'**
  String get unsavedChangesBody;

  /// Back from a screen with unsaved edits: confirm dialog
  ///
  /// In uz, this message translates to:
  /// **'Chiqish'**
  String get unsavedChangesLeave;

  /// Back from a screen with unsaved edits: confirm dialog
  ///
  /// In uz, this message translates to:
  /// **'Qolish'**
  String get unsavedChangesStay;

  /// Wizard: creating the room on the server failed; offered with a retry
  ///
  /// In uz, this message translates to:
  /// **'Xona serverga saqlanmadi. Internetni tekshirib, qayta urinib ko\'ring.'**
  String get roomSaveFailed;

  /// Android ARCore floor-plan scanner
  ///
  /// In uz, this message translates to:
  /// **'Kamera bilan o\'lchash'**
  String get newProjectArScanTitle;

  /// Android ARCore floor-plan scanner
  ///
  /// In uz, this message translates to:
  /// **'Telefon kamerasi bilan pol burchaklarini belgilab, xona rejasini oling'**
  String get newProjectArScanDesc;

  /// Android ARCore floor-plan scanner
  ///
  /// In uz, this message translates to:
  /// **'Telefonni polga qaratib sekin aylantiring'**
  String get arScanFindFloor;

  /// Android ARCore floor-plan scanner
  ///
  /// In uz, this message translates to:
  /// **'Nishonni pol burchagiga keltirib, burchak qo\'shing'**
  String get arScanCornersHint;

  /// Android ARCore floor-plan scanner
  ///
  /// In uz, this message translates to:
  /// **'Burchak qo\'shish'**
  String get arScanAddCorner;

  /// Android ARCore floor-plan scanner
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilish'**
  String get arScanUndo;

  /// Android ARCore floor-plan scanner
  ///
  /// In uz, this message translates to:
  /// **'Tayyor'**
  String get arScanFinish;

  /// Android ARCore floor-plan scanner
  ///
  /// In uz, this message translates to:
  /// **'Birinchi burchakka yaqinlashing — kontur yopiladi'**
  String get arScanSnapToFirst;

  /// Android ARCore floor-plan scanner
  ///
  /// In uz, this message translates to:
  /// **'Birinchi burchak ustidagi shift chizig\'iga qarating'**
  String get arScanAimCeiling;

  /// Android ARCore floor-plan scanner
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlash'**
  String get arScanConfirm;

  /// Android ARCore floor-plan scanner
  ///
  /// In uz, this message translates to:
  /// **'Qo\'lda kiritish'**
  String get arScanEnterManually;

  /// Android ARCore floor-plan scanner
  ///
  /// In uz, this message translates to:
  /// **'Chiqish'**
  String get arScanExit;

  /// Android ARCore floor-plan scanner
  ///
  /// In uz, this message translates to:
  /// **'O\'lchovni to\'xtatasizmi? Belgilangan burchaklar yo\'qoladi.'**
  String get arScanExitConfirm;

  /// Android ARCore floor-plan scanner
  ///
  /// In uz, this message translates to:
  /// **'Yorug\'lik kam yoki telefon tez harakatlandi'**
  String get arScanTrackingLost;

  /// Android ARCore floor-plan scanner
  ///
  /// In uz, this message translates to:
  /// **'Yorug\'roq joyda, gilam yoki naqshli polga qarating'**
  String get arScanFloorHint;

  /// Android ARCore floor-plan scanner
  ///
  /// In uz, this message translates to:
  /// **'Ba\'zi burchaklar yo\'qoldi — ularni qayta belgilang'**
  String get arScanCornersLost;

  /// Android ARCore floor-plan scanner: 'Add corner' tapped with no floor under the reticle
  ///
  /// In uz, this message translates to:
  /// **'Avval polni skaner qiling'**
  String get arScanNoFloorHere;

  /// Android ARCore floor-plan scanner: cancel button of the exit confirmation
  ///
  /// In uz, this message translates to:
  /// **'O\'lchashni davom ettirish'**
  String get arScanKeepMeasuring;

  /// Android ARCore floor-plan scanner: step indicator, finding the floor
  ///
  /// In uz, this message translates to:
  /// **'1/3 — pol'**
  String get arScanStepFloor;

  /// Android ARCore floor-plan scanner: step indicator, marking corners
  ///
  /// In uz, this message translates to:
  /// **'2/3 — burchaklar'**
  String get arScanStepCorners;

  /// Android ARCore floor-plan scanner: step indicator, measuring the height
  ///
  /// In uz, this message translates to:
  /// **'3/3 — balandlik'**
  String get arScanStepHeight;

  /// Android ARCore floor-plan scanner
  ///
  /// In uz, this message translates to:
  /// **'Qayta o\'lchash'**
  String get arScanRescan;

  /// Android ARCore floor-plan scanner
  ///
  /// In uz, this message translates to:
  /// **'Kamera bilan o\'lchash uchun \"Google Play Services for AR\" kerak'**
  String get arScanNotInstalled;

  /// Android ARCore floor-plan scanner
  ///
  /// In uz, this message translates to:
  /// **'O\'rnatish'**
  String get arScanInstall;

  /// Android ARCore floor-plan scanner
  ///
  /// In uz, this message translates to:
  /// **'Xonani o\'lchash uchun kameraga ruxsat bering'**
  String get arScanCameraDenied;

  /// Android ARCore floor-plan scanner
  ///
  /// In uz, this message translates to:
  /// **'Sozlamalarni ochish'**
  String get arScanOpenSettings;

  /// Android ARCore floor-plan scanner
  ///
  /// In uz, this message translates to:
  /// **'Bu telefonda kamera bilan o\'lchab bo\'lmaydi. Xonani chizib yoki o\'lchamlarini kiritib qo\'shing.'**
  String get arScanUnsupported;

  /// Android ARCore floor-plan scanner
  ///
  /// In uz, this message translates to:
  /// **'O\'lchab bo\'lmadi. Qayta urinib ko\'ring.'**
  String get arScanFailed;

  /// Android ARCore floor-plan scanner
  ///
  /// In uz, this message translates to:
  /// **'Kamida 3 ta burchak kerak'**
  String get arScanRejected_too_few_corners;

  /// Android ARCore floor-plan scanner
  ///
  /// In uz, this message translates to:
  /// **'Devorlar bir-birini kesib o\'tdi — burchaklarni tartib bilan belgilang'**
  String get arScanRejected_self_intersecting;

  /// Android ARCore floor-plan scanner
  ///
  /// In uz, this message translates to:
  /// **'Bitta devor 30 m dan uzun chiqdi — burchak noto\'g\'ri joyga tushgan'**
  String get arScanRejected_wall_too_long;

  /// Android ARCore floor-plan scanner
  ///
  /// In uz, this message translates to:
  /// **'Kamera o\'lchovi: ±3–5% xato bo\'lishi mumkin, muhim devorlarni ruletka bilan tekshiring'**
  String get scanReviewArcoreAccuracy;

  /// Shop list: loaded fine, but nothing matches
  ///
  /// In uz, this message translates to:
  /// **'Hech narsa topilmadi'**
  String get shopNoResults;

  /// E10 search results: app bar title ('Search results').
  ///
  /// In uz, this message translates to:
  /// **'Qidiruv natijalari'**
  String get shopSearchResultsTitle;

  /// E10 search results: filter chip limiting results to items matching the active project.
  ///
  /// In uz, this message translates to:
  /// **'Loyihamga mos'**
  String get shopFilterForProject;

  /// E10 search results: filter chip sorting by rating.
  ///
  /// In uz, this message translates to:
  /// **'Reyting'**
  String get shopFilterRating;

  /// E10 search results: count of matching results.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta natija'**
  String shopResultCount(int count);

  /// Verified badge label shown on a master profile (U4) and the user profile (E4).
  ///
  /// In uz, this message translates to:
  /// **'✓ Tasdiqlangan'**
  String get commonVerifiedBadge;

  /// U1 masters map: search field hint ('What kind of master do you need?').
  ///
  /// In uz, this message translates to:
  /// **'Qanday usta kerak?'**
  String get mastersSearchHint;

  /// U1/U2 master pin sheet: rating followed by review count.
  ///
  /// In uz, this message translates to:
  /// **'{rating} ({count} sharh)'**
  String mastersRatingReviews(String rating, int count);

  /// Masters: approximate area name plus distance in km.
  ///
  /// In uz, this message translates to:
  /// **'{area} · ~{distance} km'**
  String mastersAreaDistance(String area, String distance);

  /// U1/U2 master pin sheet: button to open the full master profile.
  ///
  /// In uz, this message translates to:
  /// **'Profilni ko\'rish'**
  String get mastersViewProfile;

  /// U4 master profile: stat card label for rating.
  ///
  /// In uz, this message translates to:
  /// **'reyting'**
  String get mastersStatRating;

  /// U4 master profile: stat card label for reviews.
  ///
  /// In uz, this message translates to:
  /// **'sharh'**
  String get mastersStatReviews;

  /// U4 master profile: stat card label for completed jobs.
  ///
  /// In uz, this message translates to:
  /// **'ishlar'**
  String get mastersStatJobs;

  /// U4 master profile: portfolio section title.
  ///
  /// In uz, this message translates to:
  /// **'Portfolio'**
  String get mastersPortfolio;

  /// U4 master profile: empty state shown when the master has no portfolio photos.
  ///
  /// In uz, this message translates to:
  /// **'Hali portfolio surat qo\'shilmagan'**
  String get mastersPortfolioEmpty;

  /// U4 master profile: services section title.
  ///
  /// In uz, this message translates to:
  /// **'Xizmatlar'**
  String get mastersServices;

  /// U4 master profile: service row naming the master's trade works.
  ///
  /// In uz, this message translates to:
  /// **'{trade} ishlari'**
  String mastersServiceTrade(String trade);

  /// U4 master profile: consultation service row.
  ///
  /// In uz, this message translates to:
  /// **'Konsultatsiya'**
  String get mastersServiceConsultation;

  /// U4 master profile: location section title.
  ///
  /// In uz, this message translates to:
  /// **'Joylashuv'**
  String get mastersLocation;

  /// U4 master profile: primary button to send the estimate to the master.
  ///
  /// In uz, this message translates to:
  /// **'Smetani yuborish'**
  String get mastersSendEstimate;

  /// U4 master profile: secondary button to write a message.
  ///
  /// In uz, this message translates to:
  /// **'Xabar yozish'**
  String get mastersSendMessage;

  /// U5 send-smeta sheet: personalized confirmation title.
  ///
  /// In uz, this message translates to:
  /// **'Loyihangizni {name} akaga yuborasizmi?'**
  String mastersSendConfirmTitle(String name);

  /// U5 send-smeta sheet: project summary card title.
  ///
  /// In uz, this message translates to:
  /// **'Mehmonxona ta\'miri'**
  String get mastersProjectSummaryTitle;

  /// U5 send-smeta sheet: project summary area and price.
  ///
  /// In uz, this message translates to:
  /// **'{area} m² · {price}'**
  String mastersProjectSummaryValue(String area, String price);

  /// U5 send-smeta sheet: optional comment field hint.
  ///
  /// In uz, this message translates to:
  /// **'Izoh (ixtiyoriy)'**
  String get mastersCommentHint;

  /// Shared form error (checkout, call-an-usta, shop/usta forms): the phone is not an Uzbek number; same text as the web app.
  ///
  /// In uz, this message translates to:
  /// **'Telefon raqami noto\'g\'ri. Masalan: +998 90 123 45 67'**
  String get phoneErrorInvalid;

  /// U5 send-to-usta screen: label of the phone field the usta calls back on.
  ///
  /// In uz, this message translates to:
  /// **'Telefon raqamingiz'**
  String get mastersPhoneLabel;

  /// U5 send-smeta sheet: note explaining the master will review and propose a price.
  ///
  /// In uz, this message translates to:
  /// **'Usta smetani ko\'rib, o\'z narxini taklif qiladi'**
  String get mastersEstimateNote;

  /// U5 send-smeta sheet: snackbar shown after the estimate is sent.
  ///
  /// In uz, this message translates to:
  /// **'Smeta yuborildi'**
  String get mastersEstimateSent;

  /// U5 send-smeta sheet: primary send button.
  ///
  /// In uz, this message translates to:
  /// **'Yuborish'**
  String get mastersSend;

  /// E4 profile: fallback display name when the user has no name ('User').
  ///
  /// In uz, this message translates to:
  /// **'Foydalanuvchi'**
  String get profileDefaultName;

  /// E4 profile: snackbar for not-yet-available features ('Coming soon').
  ///
  /// In uz, this message translates to:
  /// **'Tez kunda'**
  String get profileComingSoon;

  /// E4 profile: stat card label for project count.
  ///
  /// In uz, this message translates to:
  /// **'loyiha'**
  String get profileStatProjects;

  /// E4 profile: stat card label for order count.
  ///
  /// In uz, this message translates to:
  /// **'buyurtma'**
  String get profileStatOrders;

  /// E4 profile: stat card label for total money saved.
  ///
  /// In uz, this message translates to:
  /// **'tejaldi'**
  String get profileStatSaved;

  /// E4 profile: saved amount in millions of som.
  ///
  /// In uz, this message translates to:
  /// **'{amount} mln'**
  String profileSavedMln(String amount);

  /// E4 profile menu / E5 title: 'My projects'.
  ///
  /// In uz, this message translates to:
  /// **'Loyihalarim'**
  String get profileMenuProjects;

  /// E4 profile menu / E6 title: 'My orders'.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtmalarim'**
  String get profileMenuOrders;

  /// E4 profile menu / E11 title: 'Saved designs'.
  ///
  /// In uz, this message translates to:
  /// **'Saqlangan dizaynlar'**
  String get profileMenuSavedDesigns;

  /// E4 profile menu: 'My addresses'.
  ///
  /// In uz, this message translates to:
  /// **'Manzillarim'**
  String get profileMenuAddresses;

  /// E4 profile menu: 'Payment methods'.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov usullari'**
  String get profileMenuPaymentMethods;

  /// E4 profile menu: 'Language'.
  ///
  /// In uz, this message translates to:
  /// **'Til'**
  String get profileMenuLanguage;

  /// E4 profile menu: 'Settings'.
  ///
  /// In uz, this message translates to:
  /// **'Sozlamalar'**
  String get profileMenuSettings;

  /// E4 profile menu: 'Help'.
  ///
  /// In uz, this message translates to:
  /// **'Yordam'**
  String get profileMenuHelp;

  /// E4 profile menu: 'Log out'.
  ///
  /// In uz, this message translates to:
  /// **'Chiqish'**
  String get profileMenuLogout;

  /// E4 profile: snackbar showing the current language ('Uzbek').
  ///
  /// In uz, this message translates to:
  /// **'O\'zbekcha'**
  String get profileLanguageUzbek;

  /// E5 projects: filter chip / status badge for ongoing projects.
  ///
  /// In uz, this message translates to:
  /// **'Davom etayotgan'**
  String get profileFilterOngoing;

  /// E5 projects: filter chip / status badge for finished projects.
  ///
  /// In uz, this message translates to:
  /// **'Tugagan'**
  String get profileFilterFinished;

  /// E5 projects: empty state title ('No projects yet').
  ///
  /// In uz, this message translates to:
  /// **'Hali loyiha yo\'q'**
  String get profileProjectsEmptyTitle;

  /// E5 projects: empty state message ('Start your first project').
  ///
  /// In uz, this message translates to:
  /// **'Birinchi loyihangizni boshlang'**
  String get profileProjectsEmptyMessage;

  /// E5 projects: empty state action button ('+ New project').
  ///
  /// In uz, this message translates to:
  /// **'+ Yangi loyiha'**
  String get profileProjectsEmptyAction;

  /// E5 projects: project card metadata line: rooms, then 'location · date' (or just the date when there is no address).
  ///
  /// In uz, this message translates to:
  /// **'{count} xona · {details}'**
  String profileProjectMeta(int count, String details);

  /// E6 orders: empty state title ('No orders').
  ///
  /// In uz, this message translates to:
  /// **'Buyurtma yo\'q'**
  String get profileOrdersEmptyTitle;

  /// E6 orders: empty state message ('Your shop purchases appear here').
  ///
  /// In uz, this message translates to:
  /// **'Do\'kondan xarid qilganingizda shu yerda ko\'rinadi'**
  String get profileOrdersEmptyMessage;

  /// Order status: order accepted.
  ///
  /// In uz, this message translates to:
  /// **'Qabul qilindi'**
  String get orderStepAccepted;

  /// Order status: items being gathered.
  ///
  /// In uz, this message translates to:
  /// **'Yig\'ilmoqda'**
  String get orderStepGathering;

  /// Order status: order out for delivery.
  ///
  /// In uz, this message translates to:
  /// **'Yo\'lda'**
  String get orderStepOnTheWay;

  /// Order status: order delivered.
  ///
  /// In uz, this message translates to:
  /// **'Yetkazildi'**
  String get orderStepDelivered;

  /// E11 saved designs: empty state title ('No saved designs').
  ///
  /// In uz, this message translates to:
  /// **'Saqlangan dizayn yo\'q'**
  String get profileSavedDesignsEmptyTitle;

  /// E11 saved designs: empty state message ('Save designs you like here').
  ///
  /// In uz, this message translates to:
  /// **'Yoqqan dizaynlaringizni shu yerda saqlab qo\'ying'**
  String get profileSavedDesignsEmptyMessage;

  /// E7 onboarding: skip button ('Skip').
  ///
  /// In uz, this message translates to:
  /// **'O\'tkazib yuborish'**
  String get onboardingSkip;

  /// E7 onboarding: final-slide start button ('Get started').
  ///
  /// In uz, this message translates to:
  /// **'Boshlash'**
  String get onboardingStart;

  /// E7 onboarding slide 1 title ('Measure your room').
  ///
  /// In uz, this message translates to:
  /// **'Xonangizni o\'lchang'**
  String get onboardingMeasureTitle;

  /// E7 onboarding slide 1 body.
  ///
  /// In uz, this message translates to:
  /// **'Telefon kamerasi yoki LiDAR yordamida xonangiz o\'lchamlarini aniq oling.'**
  String get onboardingMeasureBody;

  /// E7 onboarding slide 2 title ('We start from the current state').
  ///
  /// In uz, this message translates to:
  /// **'Hozirgi holatdan boshlaymiz'**
  String get onboardingDeltaTitle;

  /// E7 onboarding slide 2 body.
  ///
  /// In uz, this message translates to:
  /// **'Xonangizda allaqachon bor narsalar uchun to\'lamaysiz — faqat kerakli qismini hisoblaymiz.'**
  String get onboardingDeltaBody;

  /// E7 onboarding slide 2: 'Current' state swatch label.
  ///
  /// In uz, this message translates to:
  /// **'Hozirgi'**
  String get onboardingDeltaCurrent;

  /// E7 onboarding slide 2: pill emphasizing only the difference is charged.
  ///
  /// In uz, this message translates to:
  /// **'faqat FARQ hisoblanadi'**
  String get onboardingDeltaPill;

  /// E7 onboarding slide 3 title ('Decorate in 3D').
  ///
  /// In uz, this message translates to:
  /// **'3D\'da bezang'**
  String get onboardingDecorateTitle;

  /// E7 onboarding slide 3 body.
  ///
  /// In uz, this message translates to:
  /// **'Materiallarni to\'g\'ridan-to\'g\'ri xonaning 3D ko\'rinishiga sudrab, natijani darhol ko\'ring.'**
  String get onboardingDecorateBody;

  /// E7 onboarding slide 4 title ('See the price, get the materials').
  ///
  /// In uz, this message translates to:
  /// **'Narxni ko\'ring, materialni oling'**
  String get onboardingPriceTitle;

  /// E7 onboarding slide 4 body.
  ///
  /// In uz, this message translates to:
  /// **'Aniq smeta oling va kerakli materiallarni to\'g\'ridan-to\'g\'ri ilovadan xarid qiling.'**
  String get onboardingPriceBody;

  /// E7 onboarding slide 4: example savings figure.
  ///
  /// In uz, this message translates to:
  /// **'Tejaldingiz 4.2 mln'**
  String get onboardingPriceSaved;

  /// E8 tutorial: app bar title ('Demo guide').
  ///
  /// In uz, this message translates to:
  /// **'Demo qo\'llanma'**
  String get onboardingDemoTitle;

  /// E8 tutorial: step 1.
  ///
  /// In uz, this message translates to:
  /// **'Xona qo\'shish — LiDAR, 360° yoki qo\'lda o\'lchash'**
  String get onboardingDemoStep1;

  /// E8 tutorial: step 2.
  ///
  /// In uz, this message translates to:
  /// **'Xonaning hozirgi holatini tanlash'**
  String get onboardingDemoStep2;

  /// E8 tutorial: step 3.
  ///
  /// In uz, this message translates to:
  /// **'Rail bilan devor, pol va mebelni bezash'**
  String get onboardingDemoStep3;

  /// E8 tutorial: step 4.
  ///
  /// In uz, this message translates to:
  /// **'Elektr va santexnikani oxirida rejalashtirish'**
  String get onboardingDemoStep4;

  /// E8 tutorial: step 5.
  ///
  /// In uz, this message translates to:
  /// **'Smetani ko\'rish va materiallarni sotib olish'**
  String get onboardingDemoStep5;

  /// E8 tutorial: video placeholder caption ('Watch the video').
  ///
  /// In uz, this message translates to:
  /// **'Videoni ko\'rish'**
  String get onboardingDemoWatchVideo;

  /// E8 tutorial: button to try the app directly ('I'll try it myself').
  ///
  /// In uz, this message translates to:
  /// **'O\'zim sinab ko\'raman'**
  String get onboardingDemoTryMyself;

  /// Secondary button returning to the 3D view (C9 decoration-complete and D10 final-confirmation).
  ///
  /// In uz, this message translates to:
  /// **'3D\'ga qaytish'**
  String get commonBackTo3d;

  /// B1-alt surface sheet: heading above the floor condition options.
  ///
  /// In uz, this message translates to:
  /// **'Pol'**
  String get designSurfaceFloorHeading;

  /// B1-alt surface sheet: heading above the ceiling condition options.
  ///
  /// In uz, this message translates to:
  /// **'Shift'**
  String get designSurfaceCeilingHeading;

  /// B1-alt surface sheet: floor option for raw concrete.
  ///
  /// In uz, this message translates to:
  /// **'Xom beton'**
  String get designFloorRaw;

  /// B1-alt surface sheet: floor option for screed (styajka).
  ///
  /// In uz, this message translates to:
  /// **'Styajka'**
  String get designFloorPlastered;

  /// B1-alt surface sheet: floor option meaning a covering already exists.
  ///
  /// In uz, this message translates to:
  /// **'Qoplama bor'**
  String get designFloorPuttied;

  /// B1-alt surface sheet: ceiling option for raw/bare.
  ///
  /// In uz, this message translates to:
  /// **'Xom'**
  String get designCeilingRaw;

  /// B1-alt surface sheet: ceiling option for plastered (suvoq).
  ///
  /// In uz, this message translates to:
  /// **'Suvoq'**
  String get designCeilingPlastered;

  /// B1-alt surface sheet: ceiling option for finished/ready.
  ///
  /// In uz, this message translates to:
  /// **'Tayyor'**
  String get designCeilingPuttied;

  /// B2 room entry: intro card stating the room's current baseline condition and that decoration proceeds step by step.
  ///
  /// In uz, this message translates to:
  /// **'Xonangiz shu holatda — {condition}. Endi bosqichma-bosqich bezaymiz.'**
  String designRoomEntryIntro(String condition);

  /// B2 room entry: wall condition label for the raw/bare-shell state, used inside designRoomEntryIntro.
  ///
  /// In uz, this message translates to:
  /// **'korobka holatida'**
  String get designConditionRaw;

  /// B2 room entry: wall condition label for the plastered state, used inside designRoomEntryIntro.
  ///
  /// In uz, this message translates to:
  /// **'suvoq qilingan'**
  String get designConditionPlastered;

  /// B2 room entry: wall condition label for the puttied state, used inside designRoomEntryIntro.
  ///
  /// In uz, this message translates to:
  /// **'shpaklovka qilingan'**
  String get designConditionPuttied;

  /// B3 decoration rail: success toast after applying a paint/putty swatch to the wall.
  ///
  /// In uz, this message translates to:
  /// **'✓ Shpaklovka qo\'shildi'**
  String get designToastShpaklovkaAdded;

  /// B3 decoration rail: stage-progress label for the paint/wallpaper stage.
  ///
  /// In uz, this message translates to:
  /// **'Bo\'yoq/Oboi bosqichi'**
  String get designStageBoyoqOboi;

  /// B3 decoration rail: rail tab label for paint swatches.
  ///
  /// In uz, this message translates to:
  /// **'Bo\'yoq'**
  String get designRailTabBoyoq;

  /// B3 decoration rail: one-time onboarding hint to drag a material onto the wall with your finger.
  ///
  /// In uz, this message translates to:
  /// **'Materialni barmog\'ingiz bilan devorga sudrang'**
  String get designDragHint;

  /// Decoration flow: primary button advancing to the next renovation stage (B3, C4, C5).
  ///
  /// In uz, this message translates to:
  /// **'Keyingi bosqich →'**
  String get designNextStage;

  /// C4 floor selection: success toast after applying a floor material.
  ///
  /// In uz, this message translates to:
  /// **'✓ Polga qo\'llanildi'**
  String get interiorToastFloorApplied;

  /// C4 floor selection: stage-progress label for the flooring stage.
  ///
  /// In uz, this message translates to:
  /// **'Pol bosqichi'**
  String get interiorStagePol;

  /// C4 floor selection: rail tab label for tile (kafel) floors.
  ///
  /// In uz, this message translates to:
  /// **'Kafel'**
  String get interiorRailTabKafel;

  /// C4 floor selection: rail tab label for laminate floors.
  ///
  /// In uz, this message translates to:
  /// **'Laminat'**
  String get interiorRailTabLaminat;

  /// C4 floor selection: rail tab label for parquet floors.
  ///
  /// In uz, this message translates to:
  /// **'Parket'**
  String get interiorRailTabParket;

  /// C4 floor selection: rail tab label for concrete (beton) floors.
  ///
  /// In uz, this message translates to:
  /// **'Beton'**
  String get interiorRailTabBeton;

  /// C5 furniture placement: stage label for the furniture stage.
  ///
  /// In uz, this message translates to:
  /// **'Mebel bosqichi'**
  String get interiorStageMebel;

  /// C5 furniture placement: room rail tab for the living room.
  ///
  /// In uz, this message translates to:
  /// **'Mehmonxona'**
  String get interiorRailTabMehmonxona;

  /// C5 furniture placement: room rail tab for the kitchen.
  ///
  /// In uz, this message translates to:
  /// **'Oshxona'**
  String get interiorRailTabOshxona;

  /// C5 furniture placement: room rail tab for the bedroom.
  ///
  /// In uz, this message translates to:
  /// **'Yotoqxona'**
  String get interiorRailTabYotoqxona;

  /// C5 furniture placement: room rail tab for the bathroom.
  ///
  /// In uz, this message translates to:
  /// **'Vanna'**
  String get interiorRailTabVanna;

  /// C7 walkthrough: hint pill explaining you can walk on the floor by dragging with a finger.
  ///
  /// In uz, this message translates to:
  /// **'Polda yurish mumkin — barmoq bilan suring'**
  String get interiorWalkthroughHint;

  /// C7 walkthrough: button switching to the top-down plan view.
  ///
  /// In uz, this message translates to:
  /// **'Rejaga o\'tish →'**
  String get interiorGoToPlan;

  /// C9 decoration complete: success title ('Decoration finished').
  ///
  /// In uz, this message translates to:
  /// **'Bezash yakunlandi'**
  String get interiorDecorationComplete;

  /// C9 decoration complete: primary button moving on to the electrical stage.
  ///
  /// In uz, this message translates to:
  /// **'Elektrga o\'tish →'**
  String get interiorGoToElectrical;

  /// Wallpaper library sheet: snackbar confirming an uploaded wallpaper was added to the library.
  ///
  /// In uz, this message translates to:
  /// **'✓ Oboy kutubxonaga qo\'shildi'**
  String get interiorWallpaperAdded;

  /// Wallpaper library sheet: snackbar shown when the wallpaper upload fails.
  ///
  /// In uz, this message translates to:
  /// **'Yuklab bo\'lmadi: {error}'**
  String interiorUploadFailed(String error);

  /// Wallpaper library sheet: title ('Wallpaper library').
  ///
  /// In uz, this message translates to:
  /// **'Oboy kutubxonasi'**
  String get interiorWallpaperLibrary;

  /// Wallpaper library sheet: upload button label while an image is uploading.
  ///
  /// In uz, this message translates to:
  /// **'Yuklanmoqda…'**
  String get interiorUploading;

  /// Wallpaper library sheet: upload button label ('Upload image').
  ///
  /// In uz, this message translates to:
  /// **'Rasm yuklash'**
  String get interiorUploadImage;

  /// Wallpaper library sheet: empty-state message inviting the user to upload the first wallpaper.
  ///
  /// In uz, this message translates to:
  /// **'Hali oboy yo\'q — birinchi bo\'lib rasm yuklang'**
  String get interiorNoWallpapers;

  /// D8 electrical summary: app bar title ('Wire routing').
  ///
  /// In uz, this message translates to:
  /// **'Sim yo\'nalishi'**
  String get electricalWireRouting;

  /// D8 electrical summary: view-toggle chip for the 2D plan.
  ///
  /// In uz, this message translates to:
  /// **'2D reja'**
  String get electricalView2d;

  /// D8 electrical summary: view-toggle chip for the 3D view.
  ///
  /// In uz, this message translates to:
  /// **'3D'**
  String get electricalView3d;

  /// D8 electrical summary: view-toggle chip showing both 2D and 3D ('Both').
  ///
  /// In uz, this message translates to:
  /// **'Ikkalasi'**
  String get electricalViewBoth;

  /// D8 electrical summary: button to recompute the wire routing.
  ///
  /// In uz, this message translates to:
  /// **'Trassani qayta hisoblash'**
  String get electricalRecomputeRoute;

  /// D8 electrical summary: primary button advancing to the electrical result (D9).
  ///
  /// In uz, this message translates to:
  /// **'Keyingi →'**
  String get electricalNext;

  /// D9 electrical result: app bar title ('Electrical result').
  ///
  /// In uz, this message translates to:
  /// **'Elektr natijasi'**
  String get electricalResult;

  /// D9 electrical result: primary button finishing the electrical flow (to D10).
  ///
  /// In uz, this message translates to:
  /// **'Yakunlash →'**
  String get electricalFinish;

  /// D10 final confirmation: success title ('Your project is ready').
  ///
  /// In uz, this message translates to:
  /// **'Loyihangiz tayyor'**
  String get electricalProjectReady;

  /// D10 final confirmation: primary button opening the cost estimate (E1).
  ///
  /// In uz, this message translates to:
  /// **'Smetani ko\'rish →'**
  String get electricalViewEstimate;

  /// E1 estimation: app bar title prefix, followed by the room name and dimensions ('Renovation estimate').
  ///
  /// In uz, this message translates to:
  /// **'Remont smetasi'**
  String get estimateTitlePrefix;

  /// E1 estimation: fallback room name shown in the title when the room has none ('Living room').
  ///
  /// In uz, this message translates to:
  /// **'Mehmonxona'**
  String get estimateDefaultRoomName;

  /// E1 estimation: snackbar shown when downloading the smeta PDF fails.
  ///
  /// In uz, this message translates to:
  /// **'PDF yuklab bo\'lmadi: {error}'**
  String estimatePdfFailed(String error);

  /// E1 estimation: fallback label in the savings banner for already-done work ('Some work').
  ///
  /// In uz, this message translates to:
  /// **'Ba\'zi ishlar'**
  String get estimateSomeWork;

  /// E1 estimation: generic fallback stage label in the savings banner ('Stage').
  ///
  /// In uz, this message translates to:
  /// **'Bosqich'**
  String get estimateStageFallback;

  /// E1 smeta: warning banner when the Studio has a floor type but no floor product, so the floor is missing from the estimate.
  ///
  /// In uz, this message translates to:
  /// **'Pol turi tanlangan, lekin mahsulot tanlanmagan — pol smetaga kirmadi.'**
  String get estimateFloorUnpriced;

  /// E1 smeta: button on the floor warning that opens the Studio to pick a floor product.
  ///
  /// In uz, this message translates to:
  /// **'Polni tanlash'**
  String get estimateFloorPick;

  /// Estimate adjust: E1 tooltip and E3 app bar title ('Adjust estimate').
  ///
  /// In uz, this message translates to:
  /// **'Smeta sozlash'**
  String get estimateAdjust;

  /// E1 estimation: label above the big total price card ('Approximate total price').
  ///
  /// In uz, this message translates to:
  /// **'Taxminiy umumiy narx'**
  String get estimateApproxTotal;

  /// Estimate: labour cost column/summary label ('Labour') (E1, E2, E3).
  ///
  /// In uz, this message translates to:
  /// **'Ishchi kuchi'**
  String get estimateLabor;

  /// E1 estimation: green savings banner stating a stage already existed and how much was saved.
  ///
  /// In uz, this message translates to:
  /// **'{label} allaqachon bor edi — {amount} tejaldingiz'**
  String estimateSavingsBanner(String label, String amount);

  /// E1 estimation: note on an excluded stage row ('you already have it — not counted').
  ///
  /// In uz, this message translates to:
  /// **'sizda mavjud — hisoblanmadi'**
  String get estimateExcludedNote;

  /// E1 estimation: struck-through price shown for excluded stages ('0 som').
  ///
  /// In uz, this message translates to:
  /// **'0 so\'m'**
  String get estimateZeroSom;

  /// E1 estimation: PDF button label while the PDF is being prepared.
  ///
  /// In uz, this message translates to:
  /// **'Tayyorlanmoqda…'**
  String get estimatePreparingPdf;

  /// E1 estimation: primary button to buy materials from shops.
  ///
  /// In uz, this message translates to:
  /// **'Do\'konlardan xarid qilish'**
  String get estimateBuyFromShops;

  /// E1 estimation: secondary button to send the estimate to a craftsman.
  ///
  /// In uz, this message translates to:
  /// **'Ustaga yuborish'**
  String get estimateSendToMaster;

  /// E2 material costs: materials subtotal row label ('Materials total').
  ///
  /// In uz, this message translates to:
  /// **'Materiallar jami'**
  String get estimateMaterialsTotal;

  /// E2 material costs: sticky stage total label ('Stage total').
  ///
  /// In uz, this message translates to:
  /// **'Bosqich jami'**
  String get estimateStageTotal;

  /// E2 material costs: button adding this stage's materials to the cart.
  ///
  /// In uz, this message translates to:
  /// **'Materiallarni savatga'**
  String get estimateAddMaterialsToCart;

  /// E3 labor costs: section title above the quality-tier options ('Quality level').
  ///
  /// In uz, this message translates to:
  /// **'Sifat darajasi'**
  String get estimateQualityLevel;

  /// E3 labor costs: DIY switch title ('Don't include labour').
  ///
  /// In uz, this message translates to:
  /// **'Ishchi kuchini qo\'shmaslik'**
  String get estimateExcludeLabor;

  /// E3 labor costs: DIY switch subtitle ('I'll do it myself — only materials are counted').
  ///
  /// In uz, this message translates to:
  /// **'O\'zim bajaraman — faqat materiallar hisoblanadi'**
  String get estimateDiySubtitle;

  /// E3 labor costs: summary row for the delta savings from an excluded stage.
  ///
  /// In uz, this message translates to:
  /// **'Delta tejash ({stage})'**
  String estimateDeltaSavings(String stage);

  /// E3 labor costs: sticky new total label ('New total').
  ///
  /// In uz, this message translates to:
  /// **'Yangi jami'**
  String get estimateNewTotal;

  /// E3 labor costs: primary button saving the estimate and returning to E1.
  ///
  /// In uz, this message translates to:
  /// **'Smetani saqlash'**
  String get estimateSaveEstimate;

  /// E1 button that opens the 3D Studio, where the new web AI designer lives.
  ///
  /// In uz, this message translates to:
  /// **'AI dizayner (3D Studio)'**
  String get studioAiDesignerInStudio;

  /// AI designer: E1 button and AI builder sheet header ('AI designer').
  ///
  /// In uz, this message translates to:
  /// **'AI dizayner'**
  String get studioAiDesigner;

  /// AI builder sheet: snackbar confirming the AI's changes were applied.
  ///
  /// In uz, this message translates to:
  /// **'✓ AI o\'zgarishlari qo\'llanildi'**
  String get studioAiApplied;

  /// AI builder sheet: snackbar shown when applying the AI patch fails.
  ///
  /// In uz, this message translates to:
  /// **'Qo\'llab bo\'lmadi: {error}'**
  String studioApplyFailed(String error);

  /// AI builder sheet: example prompt hint in the request text field.
  ///
  /// In uz, this message translates to:
  /// **'Masalan: \"Devorlarni iliq bej rangga bo\'ya va divan qo\'sh\"'**
  String get studioAiHint;

  /// AI builder sheet: heading over the optional furniture style chips; the chosen style is put in front of the request.
  ///
  /// In uz, this message translates to:
  /// **'Uslub (ixtiyoriy)'**
  String get studioAiStyleLabel;

  /// AI builder sheet: generate button label while the AI is working.
  ///
  /// In uz, this message translates to:
  /// **'Ishlanmoqda…'**
  String get studioGenerating;

  /// AI builder sheet: generate button label ('Generate').
  ///
  /// In uz, this message translates to:
  /// **'Yaratish'**
  String get studioGenerate;

  /// AI builder sheet: streamed event row for a tool call the agent made.
  ///
  /// In uz, this message translates to:
  /// **'Amal: {name}'**
  String studioActionLabel(String name);

  /// AI builder sheet: streamed event row for a completed tool result.
  ///
  /// In uz, this message translates to:
  /// **'Bajarildi: {name}'**
  String studioDoneLabel(String name);

  /// AI builder sheet: error tile shown when the AI could not respond, followed by the error detail.
  ///
  /// In uz, this message translates to:
  /// **'AI hozircha javob berolmadi.\n{message}'**
  String studioAiNoResponse(String message);

  /// AI builder sheet: proposed change line for the new ceiling height in meters.
  ///
  /// In uz, this message translates to:
  /// **'Shift balandligi: {height} m'**
  String studioChangeCeiling(String height);

  /// AI builder sheet: proposed change line for how many surface materials changed.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta yuza materiali'**
  String studioChangeSurfaces(int count);

  /// AI builder sheet: proposed change line for how many wall dimensions changed.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta devor o\'lchami'**
  String studioChangeWalls(int count);

  /// AI builder sheet: proposed change line for how many furniture items changed.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta mebel'**
  String studioChangeFurniture(int count);

  /// AI builder sheet: proposed change line for how many lights changed.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta chiroq'**
  String studioChangeLights(int count);

  /// AI builder sheet: button applying the AI's proposed changes ('Apply').
  ///
  /// In uz, this message translates to:
  /// **'Qo\'llash'**
  String get studioApply;

  /// Studio WebView: error shown when opening the studio while unauthenticated ('Log in to open the studio').
  ///
  /// In uz, this message translates to:
  /// **'Studio ochish uchun tizimga kiring.'**
  String get studioLoginRequired;

  /// Studio WebView: error shown when the studio page fails to load.
  ///
  /// In uz, this message translates to:
  /// **'Studio yuklanmadi: {error}'**
  String studioLoadFailed(String error);

  /// Studio WebView: default app-bar title when no room-specific title is given.
  ///
  /// In uz, this message translates to:
  /// **'3D Studio'**
  String get studioWebViewTitle;

  /// Generic 'Add' button label used in the add-room dialog.
  ///
  /// In uz, this message translates to:
  /// **'Qo\'shish'**
  String get actionAdd;

  /// Previous-step button label ('Back') in the wall-measurement and 3D wizard step navigation.
  ///
  /// In uz, this message translates to:
  /// **'Ortga'**
  String get actionPrev;

  /// Generic OK confirmation button in the draw-room wall-length dialog.
  ///
  /// In uz, this message translates to:
  /// **'OK'**
  String get actionOk;

  /// Short cancel button ('Cancel') in the draw-room wall-length dialog.
  ///
  /// In uz, this message translates to:
  /// **'Bekor'**
  String get actionCancelShort;

  /// Fallback room name used when the user leaves the room-name field empty.
  ///
  /// In uz, this message translates to:
  /// **'Xona'**
  String get roomDefaultName;

  /// Label above the ceiling-height control on the scan-review and draw-room screens.
  ///
  /// In uz, this message translates to:
  /// **'Shift balandligi'**
  String get ceilingHeightLabel;

  /// Label for the wall-length value/slider on the wall-measurement and 3D wizard steps.
  ///
  /// In uz, this message translates to:
  /// **'Uzunlik'**
  String get measureLength;

  /// Furniture edit card: button that removes the furniture item.
  ///
  /// In uz, this message translates to:
  /// **'O\'chirish'**
  String get furnitureDelete;

  /// Furniture edit card: button that rotates the furniture item 90 degrees.
  ///
  /// In uz, this message translates to:
  /// **'Aylantirish'**
  String get furnitureRotate;

  /// Electrical totals card heading ('Electrical computed').
  ///
  /// In uz, this message translates to:
  /// **'Elektr hisoblandi'**
  String get electricalTotalsTitle;

  /// Electrical totals card stat label: total wire length.
  ///
  /// In uz, this message translates to:
  /// **'jami sim'**
  String get electricalTotalsWireLabel;

  /// Electrical totals card stat label: device count.
  ///
  /// In uz, this message translates to:
  /// **'ta qurilma'**
  String get electricalTotalsDeviceLabel;

  /// Electrical totals chip: socket wire length in metres.
  ///
  /// In uz, this message translates to:
  /// **'Rozetka simlari {meters} m'**
  String electricalTotalsSocketWires(String meters);

  /// Electrical totals chip: switch wire length in metres.
  ///
  /// In uz, this message translates to:
  /// **'Kalit simlari {meters} m'**
  String electricalTotalsSwitchWires(String meters);

  /// Electrical totals chip summarising switch and light counts.
  ///
  /// In uz, this message translates to:
  /// **'{switches} kalit · {lights} yoritish'**
  String electricalTotalsSwitchLightSummary(int switches, int lights);

  /// Electrical totals table column header: device.
  ///
  /// In uz, this message translates to:
  /// **'Qurilma'**
  String get electricalTotalsColDevice;

  /// Electrical totals table column header: wall.
  ///
  /// In uz, this message translates to:
  /// **'Devor'**
  String get electricalTotalsColWall;

  /// Electrical totals table column header: height.
  ///
  /// In uz, this message translates to:
  /// **'Balandlik'**
  String get electricalTotalsColHeight;

  /// Dimensions-entry screen app bar title ('Room dimensions').
  ///
  /// In uz, this message translates to:
  /// **'Xona o\'lchamlari'**
  String get dimensionsTitle;

  /// Dimensions-entry segmented tab: manual entry.
  ///
  /// In uz, this message translates to:
  /// **'Qo\'lda kiritish'**
  String get dimensionsTabManual;

  /// Dimensions-entry segmented tab: floorplan upload.
  ///
  /// In uz, this message translates to:
  /// **'Plan yuklash'**
  String get dimensionsTabUpload;

  /// Dimensions-entry footer summarising total rooms and area.
  ///
  /// In uz, this message translates to:
  /// **'Jami: {count} xona · {area} m²'**
  String dimensionsTotalSummary(int count, String area);

  /// Dimensions-entry primary CTA in manual mode ('Next: measure walls').
  ///
  /// In uz, this message translates to:
  /// **'Keyingi: devorlarni o\'lchash'**
  String get dimensionsNextMeasure;

  /// Dimensions-entry primary CTA in upload mode ('Convert to 3D').
  ///
  /// In uz, this message translates to:
  /// **'3D ga aylantirish'**
  String get dimensionsConvert3d;

  /// Dimensions-entry add-room tile label.
  ///
  /// In uz, this message translates to:
  /// **'+ Xona qo\'shish'**
  String get dimensionsAddRoom;

  /// Default pre-filled name for a newly added room in the dimensions dialog.
  ///
  /// In uz, this message translates to:
  /// **'Xona {number}'**
  String dimensionsRoomDefaultName(int number);

  /// Add-room dialog: room name field label.
  ///
  /// In uz, this message translates to:
  /// **'Xona nomi'**
  String get dimensionsRoomNameLabel;

  /// Add-room dialog: length field label.
  ///
  /// In uz, this message translates to:
  /// **'Uzunlik (m)'**
  String get dimensionsLengthLabel;

  /// Add-room dialog: width field label.
  ///
  /// In uz, this message translates to:
  /// **'Kenglik (m)'**
  String get dimensionsWidthLabel;

  /// Add-room dialog: height field label.
  ///
  /// In uz, this message translates to:
  /// **'Balandlik (m)'**
  String get dimensionsHeightLabel;

  /// Floorplan upload tab: upload area heading.
  ///
  /// In uz, this message translates to:
  /// **'Floorplan rasmini yuklang'**
  String get dimensionsUploadTitle;

  /// Floorplan upload tab: file-format and drag hint.
  ///
  /// In uz, this message translates to:
  /// **'PNG yoki JPG · maksimal 10 MB\nYoki bu yerga sudrab tashlang'**
  String get dimensionsUploadHint;

  /// Floorplan upload tab: choose-file button.
  ///
  /// In uz, this message translates to:
  /// **'Fayl tanlash'**
  String get dimensionsChooseFile;

  /// Floorplan upload tab: note advising a dimensioned plan for accuracy.
  ///
  /// In uz, this message translates to:
  /// **'Aniq natija uchun o\'lchamlar ko\'rsatilgan plan yuklang'**
  String get dimensionsUploadNote;

  /// Door/window sheet title and the wall-measurement add-opening button ('Add door/window').
  ///
  /// In uz, this message translates to:
  /// **'Eshik/Deraza qo\'shish'**
  String get openingAddTitle;

  /// Add door/window button label on the 3D wizard wall step (spaced variant).
  ///
  /// In uz, this message translates to:
  /// **'Eshik / Deraza qo\'shish'**
  String get openingAddSpaced;

  /// Door/window sheet type chip: door.
  ///
  /// In uz, this message translates to:
  /// **'Eshik'**
  String get openingTypeDoor;

  /// Door/window sheet type chip: window.
  ///
  /// In uz, this message translates to:
  /// **'Deraza'**
  String get openingTypeWindow;

  /// Door/window sheet type chip: balcony door.
  ///
  /// In uz, this message translates to:
  /// **'Balkon eshigi'**
  String get openingTypeBalcony;

  /// Door/window sheet: size (cm) section label.
  ///
  /// In uz, this message translates to:
  /// **'O\'lcham (sm)'**
  String get openingSizeLabel;

  /// Door/window sheet: custom-size chip ('Other size…').
  ///
  /// In uz, this message translates to:
  /// **'Boshqa o\'lcham…'**
  String get openingSizeOther;

  /// Door/window sheet: position-along-wall slider label.
  ///
  /// In uz, this message translates to:
  /// **'Devor bo\'ylab joylashuvi'**
  String get openingPositionLabel;

  /// Door/window sheet: confirm button that adds the opening to the wall.
  ///
  /// In uz, this message translates to:
  /// **'Devorga qo\'shish'**
  String get openingAddToWall;

  /// New-project bottom sheet title.
  ///
  /// In uz, this message translates to:
  /// **'Yangi loyiha'**
  String get newProjectTitle;

  /// New-project bottom sheet subtitle ('How do you want to add the room?').
  ///
  /// In uz, this message translates to:
  /// **'Xonani qanday qo\'shmoqchisiz?'**
  String get newProjectSubtitle;

  /// New-project entry: 3D wizard title.
  ///
  /// In uz, this message translates to:
  /// **'3D Master'**
  String get newProjectWizardTitle;

  /// New-project entry: 3D wizard description.
  ///
  /// In uz, this message translates to:
  /// **'Interaktiv 3D ko\'rinishda xona o\'lchamlarini kiriting'**
  String get newProjectWizardDesc;

  /// New-project entry and scan screen app bar: LiDAR scanner title.
  ///
  /// In uz, this message translates to:
  /// **'LiDAR skaner'**
  String get newProjectLidarTitle;

  /// New-project entry: LiDAR scanner description.
  ///
  /// In uz, this message translates to:
  /// **'Xonani LiDAR yordamida skanerlang va avtomatik 3D model oling'**
  String get newProjectLidarDesc;

  /// New-project entry and unsupported-LiDAR fallback: 360° photo scan title.
  ///
  /// In uz, this message translates to:
  /// **'360° Foto skan'**
  String get newProjectPhotoTitle;

  /// New-project entry: 360° photo scan description.
  ///
  /// In uz, this message translates to:
  /// **'Xonani 360° rasmga oling — ilova nuqtalarni o\'zi belgilaydi'**
  String get newProjectPhotoDesc;

  /// New-project entry and unsupported-LiDAR fallback: draw-it-yourself title.
  ///
  /// In uz, this message translates to:
  /// **'O\'zingiz chizing'**
  String get newProjectDrawTitle;

  /// New-project entry: draw-it-yourself description.
  ///
  /// In uz, this message translates to:
  /// **'Xonani barmog\'ingiz bilan chizing — o\'lchamlar chizganingizga qarab o\'zi hisoblanadi'**
  String get newProjectDrawDesc;

  /// Room summary / wizard summary celebratory heading ('Dimensions saved!').
  ///
  /// In uz, this message translates to:
  /// **'O\'lchamlar saqlandi!'**
  String get summarySavedTitle;

  /// Room summary stat card label: floor area.
  ///
  /// In uz, this message translates to:
  /// **'pol'**
  String get summaryStatFloor;

  /// Room summary stat card label: net wall area.
  ///
  /// In uz, this message translates to:
  /// **'devor (netto)'**
  String get summaryStatWallNet;

  /// Room summary stat card label: perimeter.
  ///
  /// In uz, this message translates to:
  /// **'perimetr'**
  String get summaryStatPerimeter;

  /// Room summary stat card label: openings (doors/windows).
  ///
  /// In uz, this message translates to:
  /// **'eshik/deraza'**
  String get summaryStatOpenings;

  /// Room summary / wizard openings count value (e.g. '3 ta').
  ///
  /// In uz, this message translates to:
  /// **'{count} ta'**
  String summaryOpeningsCount(int count);

  /// Room summary note explaining openings are auto-subtracted (net).
  ///
  /// In uz, this message translates to:
  /// **'Eshik/derazalar avtomatik ayirilgan (netto)'**
  String get summaryOpeningsNote;

  /// Room summary: secondary action to add another room.
  ///
  /// In uz, this message translates to:
  /// **'+ Yangi xona qo\'shish'**
  String get summaryAddRoom;

  /// Default name given to a newly measured room/project, used until the user renames it.
  ///
  /// In uz, this message translates to:
  /// **'Mehmonxona ta\'miri'**
  String get roomSetupDefaultProjectName;

  /// Wall measurements screen: app-bar title for wall A.
  ///
  /// In uz, this message translates to:
  /// **'Devor A'**
  String get roomSetupWallLabelA;

  /// Wall measurements screen: app-bar title for wall B.
  ///
  /// In uz, this message translates to:
  /// **'Devor B'**
  String get roomSetupWallLabelB;

  /// Wall measurements screen: app-bar title for wall C.
  ///
  /// In uz, this message translates to:
  /// **'Devor C'**
  String get roomSetupWallLabelC;

  /// Wall measurements screen: app-bar title for wall D.
  ///
  /// In uz, this message translates to:
  /// **'Devor D'**
  String get roomSetupWallLabelD;

  /// Wall measurements screen: generic app-bar title fallback for an unknown wall type.
  ///
  /// In uz, this message translates to:
  /// **'Devor'**
  String get roomSetupWallLabelFallback;

  /// 3D room wizard app bar title ('New room').
  ///
  /// In uz, this message translates to:
  /// **'Yangi xona'**
  String get wizardTitle;

  /// 3D wizard ceiling step question ('Ceiling height?').
  ///
  /// In uz, this message translates to:
  /// **'Shiftning balandligi?'**
  String get wizardCeilingQuestion;

  /// 3D wizard ceiling step hint ('Usually between 2.5–3.2 metres').
  ///
  /// In uz, this message translates to:
  /// **'Odatda 2.5–3.2 metr oralig\'ida'**
  String get wizardCeilingHint;

  /// 3D wizard ceiling step: exact-value field label.
  ///
  /// In uz, this message translates to:
  /// **'Aniq qiymat (m)'**
  String get wizardExactValue;

  /// Room wizard, ceiling step: the typed height is not a number in the accepted range; Next stays disabled.
  ///
  /// In uz, this message translates to:
  /// **'Shift balandligi {min} m dan {max} m gacha bo\'lishi kerak'**
  String wizardCeilingOutOfRange(String min, String max);

  /// 3D wizard wall step heading, e.g. 'A devor'.
  ///
  /// In uz, this message translates to:
  /// **'{letter} devor'**
  String wizardWallTitle(String letter);

  /// 3D wizard wall step subtitle ('Enter its length').
  ///
  /// In uz, this message translates to:
  /// **'Uzunligini kiriting'**
  String get wizardWallSubtitle;

  /// Wizard last step: dimensions entered but not yet saved (saved by the buttons below)
  ///
  /// In uz, this message translates to:
  /// **'O\'lchamlar tayyor'**
  String get wizardSummaryTitle;

  /// 3D wizard summary subtitle confirming the room parameters were recorded.
  ///
  /// In uz, this message translates to:
  /// **'Smeta yoki bezashni tanlang — xona shunda saqlanadi'**
  String get wizardSummarySubtitle;

  /// 3D wizard summary stat: floor area (uppercase).
  ///
  /// In uz, this message translates to:
  /// **'POL MAYDONI'**
  String get wizardStatFloor;

  /// 3D wizard summary stat: net wall area (uppercase).
  ///
  /// In uz, this message translates to:
  /// **'DEVOR MAYDONI (NETTO)'**
  String get wizardStatWallNet;

  /// 3D wizard summary stat: perimeter (uppercase).
  ///
  /// In uz, this message translates to:
  /// **'PERIMETR'**
  String get wizardStatPerimeter;

  /// 3D wizard summary stat: openings (uppercase).
  ///
  /// In uz, this message translates to:
  /// **'ESHIK/DERAZALAR'**
  String get wizardStatOpenings;

  /// 3D wizard summary primary CTA ('View estimate').
  ///
  /// In uz, this message translates to:
  /// **'Smeta ko\'rish'**
  String get wizardViewSmeta;

  /// 3D wizard summary: loading label while the studio is opening.
  ///
  /// In uz, this message translates to:
  /// **'Ochilmoqda…'**
  String get wizardOpening;

  /// 3D wizard summary secondary CTA ('Start decorating').
  ///
  /// In uz, this message translates to:
  /// **'Bezashni boshlash'**
  String get wizardStartDesign;

  /// Wall-measurement screen: openings list section label.
  ///
  /// In uz, this message translates to:
  /// **'Eshik / derazalar'**
  String get measureOpenings;

  /// Wall-measurement opening row: offset from the wall's left edge.
  ///
  /// In uz, this message translates to:
  /// **'Chapdan {offset} m'**
  String measureFromLeft(String offset);

  /// LiDAR scanning screen: 'Scanning...' status.
  ///
  /// In uz, this message translates to:
  /// **'Skanerlanyapti...'**
  String get lidarScanning;

  /// LiDAR scanning screen hint: 'Move the phone slowly'.
  ///
  /// In uz, this message translates to:
  /// **'Telefonni sekin harakatlantiring'**
  String get lidarMoveHint;

  /// LiDAR scanning found-stat label: wall (used as '{count} devor').
  ///
  /// In uz, this message translates to:
  /// **'devor'**
  String get lidarLabelWall;

  /// LiDAR scanning found-stat label: door.
  ///
  /// In uz, this message translates to:
  /// **'eshik'**
  String get lidarLabelDoor;

  /// LiDAR scanning found-stat label: window.
  ///
  /// In uz, this message translates to:
  /// **'deraza'**
  String get lidarLabelWindow;

  /// 360° photo scan: captured / total points counter.
  ///
  /// In uz, this message translates to:
  /// **'{captured}/{total} nuqta'**
  String photoPointsCount(int captured, int total);

  /// 360° photo scan hint: 'Turn the phone to the next point'.
  ///
  /// In uz, this message translates to:
  /// **'Telefonni keyingi nuqtaga burang'**
  String get photoTurnHint;

  /// 360° photo scan: capture button ('Take photo').
  ///
  /// In uz, this message translates to:
  /// **'Suratga olish'**
  String get photoCapture;

  /// Room-scan review page app bar title ('Scan result').
  ///
  /// In uz, this message translates to:
  /// **'Skan natijasi'**
  String get scanReviewTitle;

  /// Room-scan review: detected ceiling height.
  ///
  /// In uz, this message translates to:
  /// **'Aniqlangan: {value}'**
  String scanReviewDetected(String value);

  /// Room-scan review: walls section header with count.
  ///
  /// In uz, this message translates to:
  /// **'Devorlar ({count})'**
  String scanReviewWalls(int count);

  /// Room-scan review: per-wall row label, e.g. 'Devor 1'.
  ///
  /// In uz, this message translates to:
  /// **'Devor {number}'**
  String scanReviewWall(int number);

  /// Room-scan review: detected-objects section header with count.
  ///
  /// In uz, this message translates to:
  /// **'Topilgan buyumlar ({count})'**
  String scanReviewObjects(int count);

  /// Room-scan review: shown when no objects were detected.
  ///
  /// In uz, this message translates to:
  /// **'Buyum topilmadi'**
  String get scanReviewNoObjects;

  /// Room-scan review: snackbar shown right after continuing to the studio, when the scan detected at least one object, pointing the user at the studio's scan-overlay toggle so the detection isn't missed.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta buyum aniqlandi — Studio\'da \"Skan ko\'rinishi\"da ko\'rasiz'**
  String scanReviewObjectsDetectedNotice(int count);

  /// Room-scan review: re-scan button.
  ///
  /// In uz, this message translates to:
  /// **'Qayta skanerlash'**
  String get scanReviewRescan;

  /// Room-scan review: header of the compact 'what we detected' summary shown under the 2-D preview.
  ///
  /// In uz, this message translates to:
  /// **'Nimalar aniqlandi'**
  String get scanReviewSummaryTitle;

  /// Room-scan review summary chip label: walls.
  ///
  /// In uz, this message translates to:
  /// **'Devor'**
  String get scanReviewSummaryWalls;

  /// Room-scan review summary chip label: doors.
  ///
  /// In uz, this message translates to:
  /// **'Eshik'**
  String get scanReviewSummaryDoors;

  /// Room-scan review summary chip label: windows.
  ///
  /// In uz, this message translates to:
  /// **'Deraza'**
  String get scanReviewSummaryWindows;

  /// Room-scan review summary chip label: detected objects.
  ///
  /// In uz, this message translates to:
  /// **'Buyum'**
  String get scanReviewSummaryObjects;

  /// Room-scan review summary: warning that some detected items carry a low RoomPlan confidence.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta element past aniqlikda o\'lchandi — o\'lchamlarni tekshiring.'**
  String scanReviewSummaryLowConfidence(int count);

  /// Room-scan review summary hint shown when zero doors or zero windows were detected.
  ///
  /// In uz, this message translates to:
  /// **'Eshik yoki deraza topilmadi. Shisha va ochiq eshiklar ko\'pincha aniqlanmaydi.'**
  String get scanReviewSummaryNoOpenings;

  /// Room-scan review summary hint: second line telling the user how to improve the scan.
  ///
  /// In uz, this message translates to:
  /// **'Yaqinroqdan, sekinroq qayta skanerlang.'**
  String get scanReviewSummaryRescanHint;

  /// Room-scan review: snackbar when the room could not be saved.
  ///
  /// In uz, this message translates to:
  /// **'Xonani saqlab bo\'lmadi. Internetni tekshiring.'**
  String get scanReviewSaveFailed;

  /// Room-scan review: snackbar shown in the studio when the scan artifact (mesh/USDZ) upload failed; the room itself was still created.
  ///
  /// In uz, this message translates to:
  /// **'Skan fayllari yuklanmadi: {error} Xona saqlandi, keyinroq qayta skanerlashingiz mumkin.'**
  String scanReviewUploadFailed(String error);

  /// Room-scan review: snackbar shown in the studio when uploading the generated floor-plan thumbnail failed; the room itself was still created and only its project-card preview stays empty.
  ///
  /// In uz, this message translates to:
  /// **'Xona ko\'rinishi yuklanmadi: {error} Loyiha kartasi rasmsiz ko\'rinadi.'**
  String scanReviewThumbnailFailed(String error);

  /// Room-scan review: generic error snackbar with detail.
  ///
  /// In uz, this message translates to:
  /// **'Xatolik: {error}'**
  String scanReviewError(String error);

  /// Room-scan review: ceiling-height choice chip label, e.g. '2.7 m'.
  ///
  /// In uz, this message translates to:
  /// **'{h} m'**
  String scanReviewCeilingHeightValue(String h);

  /// Dialog title offered at app start when a LiDAR scan was interrupted before being saved.
  ///
  /// In uz, this message translates to:
  /// **'Tugallanmagan skan topildi'**
  String get pendingScanTitle;

  /// Dialog body for the resume-interrupted-scan prompt.
  ///
  /// In uz, this message translates to:
  /// **'Siz oldin xonani skanerlagansiz, lekin \"Davom etish\"ni bosmasdan chiqib ketgansiz. Davom ettiramizmi?'**
  String get pendingScanBody;

  /// Resume-interrupted-scan dialog: button to go back to the review screen.
  ///
  /// In uz, this message translates to:
  /// **'Davom etish'**
  String get pendingScanResume;

  /// Resume-interrupted-scan dialog: button to discard the saved scan.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilish'**
  String get pendingScanDiscard;

  /// Detected-object category label: table.
  ///
  /// In uz, this message translates to:
  /// **'Stol'**
  String get scanCategoryTable;

  /// Detected-object category label: chair.
  ///
  /// In uz, this message translates to:
  /// **'Stul'**
  String get scanCategoryChair;

  /// Detected-object category label: sofa.
  ///
  /// In uz, this message translates to:
  /// **'Divan'**
  String get scanCategorySofa;

  /// Detected-object category label: bed.
  ///
  /// In uz, this message translates to:
  /// **'Karavot'**
  String get scanCategoryBed;

  /// Detected-object category label: storage (cabinet/wardrobe).
  ///
  /// In uz, this message translates to:
  /// **'Shkaf'**
  String get scanCategoryStorage;

  /// Detected-object category label: refrigerator.
  ///
  /// In uz, this message translates to:
  /// **'Muzlatgich'**
  String get scanCategoryRefrigerator;

  /// Detected-object category label: stove.
  ///
  /// In uz, this message translates to:
  /// **'Plita'**
  String get scanCategoryStove;

  /// Detected-object category label: sink.
  ///
  /// In uz, this message translates to:
  /// **'Rakovina'**
  String get scanCategorySink;

  /// Detected-object category label: toilet.
  ///
  /// In uz, this message translates to:
  /// **'Unitaz'**
  String get scanCategoryToilet;

  /// Detected-object category label: bathtub.
  ///
  /// In uz, this message translates to:
  /// **'Vanna'**
  String get scanCategoryBathtub;

  /// Detected-object category label: washing machine.
  ///
  /// In uz, this message translates to:
  /// **'Kir yuvish mashinasi'**
  String get scanCategoryWasher;

  /// Detected-object category label: television.
  ///
  /// In uz, this message translates to:
  /// **'Televizor'**
  String get scanCategoryTelevision;

  /// Detected-object category label: fireplace.
  ///
  /// In uz, this message translates to:
  /// **'Kamin'**
  String get scanCategoryFireplace;

  /// Detected-object category label: stairs.
  ///
  /// In uz, this message translates to:
  /// **'Zina'**
  String get scanCategoryStairs;

  /// Detected-object category label: fallback for an unrecognized category.
  ///
  /// In uz, this message translates to:
  /// **'Boshqa'**
  String get scanCategoryOther;

  /// Room-scan screen error: a scan is already running.
  ///
  /// In uz, this message translates to:
  /// **'Skaner allaqachon ishlayapti.'**
  String get scanBusy;

  /// Room-scan screen error: scanning failed, try again.
  ///
  /// In uz, this message translates to:
  /// **'Skanerlashda xatolik. Qayta urinib ko\'ring.'**
  String get scanFailedRetry;

  /// Room-scan screen error with underlying message.
  ///
  /// In uz, this message translates to:
  /// **'Xatolik: {message}'**
  String scanErrorPrefixed(String message);

  /// Room-scan screen error: no valid room detected.
  ///
  /// In uz, this message translates to:
  /// **'Xona aniqlanmadi. Qayta urinib ko\'ring.'**
  String get scanNotDetected;

  /// Unsupported-device sheet title ('LiDAR not available').
  ///
  /// In uz, this message translates to:
  /// **'LiDAR mavjud emas'**
  String get scanLidarUnavailableTitle;

  /// Unsupported-device sheet body explaining LiDAR requirements and offering alternatives.
  ///
  /// In uz, this message translates to:
  /// **'LiDAR skaner faqat LiDAR\'li qurilmalarda ishlaydi: iPhone Pro (12 Pro va undan yangilari) yoki iPad Pro. Xonani boshqa usulda qo\'shing:'**
  String get scanLidarUnavailableBody;

  /// Room-scan screen: 'Scanning the room…' progress label.
  ///
  /// In uz, this message translates to:
  /// **'Xona skanerlanmoqda…'**
  String get scanInProgress;

  /// Draw-room screen app bar title and the finish button's disabled fallback ('Draw the room').
  ///
  /// In uz, this message translates to:
  /// **'Xonani chizing'**
  String get drawTitle;

  /// Draw-room mode chip: freehand ('By hand').
  ///
  /// In uz, this message translates to:
  /// **'Qo\'lda'**
  String get drawModeManual;

  /// Draw-room mode chip: polygon ('Visual').
  ///
  /// In uz, this message translates to:
  /// **'Vizual'**
  String get drawModeVisual;

  /// Draw-room hint shown while viewing the raw (unsmoothed) sketch.
  ///
  /// In uz, this message translates to:
  /// **'Xom chizma. \"Toza\"ga qaytish uchun tugmani bosing.'**
  String get drawHintRaw;

  /// Draw-room hint once the shape is closed.
  ///
  /// In uz, this message translates to:
  /// **'Shakl tayyor! Burchaklarni surib o\'lchamni o\'zgartiring.'**
  String get drawHintShapeReady;

  /// Draw-room hint in freehand mode.
  ///
  /// In uz, this message translates to:
  /// **'Xona shaklini barmog\'ingiz bilan chizing.'**
  String get drawHintFreehand;

  /// Draw-room hint in polygon mode before any corners are placed.
  ///
  /// In uz, this message translates to:
  /// **'Xona burchaklarini belgilang (kamida 3 ta).'**
  String get drawHintMarkCorners;

  /// Draw-room hint prompting for more corner points.
  ///
  /// In uz, this message translates to:
  /// **'Yana {count} ta nuqta qo\'ying.'**
  String drawHintMorePoints(int count);

  /// Draw-room hint on how to close the polygon.
  ///
  /// In uz, this message translates to:
  /// **'Yopish uchun birinchi nuqtaga bosing yoki \"Yopish\".'**
  String get drawHintClose;

  /// Draw-room hint bar toggle: show cleaned/smoothed shape ('Clean').
  ///
  /// In uz, this message translates to:
  /// **'Toza'**
  String get drawToggleClean;

  /// Draw-room hint bar toggle: show raw shape ('Raw').
  ///
  /// In uz, this message translates to:
  /// **'Xom'**
  String get drawToggleRaw;

  /// Draw-room hint bar redo button tooltip ('Redo').
  ///
  /// In uz, this message translates to:
  /// **'Oldinga'**
  String get drawRedo;

  /// Draw-room hint bar clear button tooltip ('Clear').
  ///
  /// In uz, this message translates to:
  /// **'Tozalash'**
  String get drawClear;

  /// Draw-room wall-length dialog title.
  ///
  /// In uz, this message translates to:
  /// **'Devor uzunligi'**
  String get drawWallLength;

  /// Draw-room bottom panel warning when the area is outside the usual range.
  ///
  /// In uz, this message translates to:
  /// **'Diqqat: yuza odatiy oraliqdan tashqarida'**
  String get drawAreaWarning;

  /// Draw-room bottom panel title for a rectangle-like room.
  ///
  /// In uz, this message translates to:
  /// **'Xona: {width} × {length} × {height} m'**
  String drawTitleRect(String width, String length, String height);

  /// Draw-room bottom panel title for a polygonal room.
  ///
  /// In uz, this message translates to:
  /// **'Ko\'pburchak · {corners} devor · {width}×{length} m'**
  String drawTitlePolygon(int corners, String width, String length);

  /// Accessibility label for the icon-only button that decreases an item quantity.
  ///
  /// In uz, this message translates to:
  /// **'Miqdorni kamaytirish'**
  String get a11yQuantityDecrease;

  /// Accessibility label for the icon-only button that increases an item quantity.
  ///
  /// In uz, this message translates to:
  /// **'Miqdorni oshirish'**
  String get a11yQuantityIncrease;

  /// Accessibility label for the icon-only button that removes a line item from the cart.
  ///
  /// In uz, this message translates to:
  /// **'Savatdan olib tashlash'**
  String get a11yRemoveFromCart;

  /// Accessibility label for the icon-only button that adds a product to the cart.
  ///
  /// In uz, this message translates to:
  /// **'Savatga qo\'shish'**
  String get a11yAddToCart;

  /// Accessibility label for the icon-only call button in the order status screen.
  ///
  /// In uz, this message translates to:
  /// **'Qo\'ng\'iroq qilish'**
  String get a11yCallDealer;

  /// Accessibility label for the icon-only message button in the order status screen.
  ///
  /// In uz, this message translates to:
  /// **'Xabar yuborish'**
  String get a11yMessageDealer;

  /// S7 order confirmation: snackbar shown when tapping the dealer's call button before it's wired up.
  ///
  /// In uz, this message translates to:
  /// **'{dealer}: telefon raqami hali mavjud emas'**
  String shopDealerPhoneUnavailable(String dealer);

  /// S7 order confirmation: snackbar shown when tapping the dealer's message button before it's wired up.
  ///
  /// In uz, this message translates to:
  /// **'{dealer} bilan xabar almashish hali mavjud emas'**
  String shopDealerMessageUnavailable(String dealer);

  /// Accessibility label for the icon-only edit button next to the profile name.
  ///
  /// In uz, this message translates to:
  /// **'Profilni tahrirlash'**
  String get a11yEditProfile;

  /// Accessibility label for the button that switches the masters map to the list view.
  ///
  /// In uz, this message translates to:
  /// **'Ro\'yxat ko\'rinishi'**
  String get a11yMastersListView;

  /// E9 preferences screen: AppBar title.
  ///
  /// In uz, this message translates to:
  /// **'Sozlamalar'**
  String get settingsScreenTitle;

  /// E9 preferences screen: 'Notifications' section header.
  ///
  /// In uz, this message translates to:
  /// **'Bildirishnomalar'**
  String get settingsNotificationsSectionTitle;

  /// E9 preferences screen: push notifications toggle title.
  ///
  /// In uz, this message translates to:
  /// **'Push-bildirishnomalar'**
  String get settingsPushNotificationsTitle;

  /// E9 preferences screen: push notifications toggle subtitle.
  ///
  /// In uz, this message translates to:
  /// **'Loyihalar va pudratchilar haqida yangiliklarni oling'**
  String get settingsPushNotificationsSubtitle;

  /// E9 preferences screen: email digest toggle title.
  ///
  /// In uz, this message translates to:
  /// **'Elektron pochta xulosasi'**
  String get settingsEmailDigestTitle;

  /// E9 preferences screen: email digest toggle subtitle.
  ///
  /// In uz, this message translates to:
  /// **'Loyihalaringiz bo\'yicha haftalik xulosa'**
  String get settingsEmailDigestSubtitle;

  /// E9 preferences screen: marketing emails toggle title.
  ///
  /// In uz, this message translates to:
  /// **'Reklama xabarlari'**
  String get settingsMarketingEmailsTitle;

  /// E9 preferences screen: marketing emails toggle subtitle.
  ///
  /// In uz, this message translates to:
  /// **'Yangi imkoniyatlar va takliflar haqida xabarlar'**
  String get settingsMarketingEmailsSubtitle;

  /// E9 preferences screen: 'Units & Display' section header.
  ///
  /// In uz, this message translates to:
  /// **'O\'lchov birliklari va ekran'**
  String get settingsUnitsDisplaySectionTitle;

  /// E9 preferences screen: measurement units dropdown label.
  ///
  /// In uz, this message translates to:
  /// **'O\'lchov birliklari'**
  String get settingsMeasurementUnitsTitle;

  /// E9 preferences screen: metric unit system dropdown option.
  ///
  /// In uz, this message translates to:
  /// **'Metrik (m²)'**
  String get settingsUnitMetric;

  /// E9 preferences screen: imperial unit system dropdown option.
  ///
  /// In uz, this message translates to:
  /// **'Imperial (ft²)'**
  String get settingsUnitImperial;

  /// E9 preferences screen: theme dropdown label.
  ///
  /// In uz, this message translates to:
  /// **'Mavzu'**
  String get settingsThemeTitle;

  /// E9 preferences screen: light theme dropdown option.
  ///
  /// In uz, this message translates to:
  /// **'Yorug\''**
  String get settingsThemeLight;

  /// E9 preferences screen: dark theme dropdown option.
  ///
  /// In uz, this message translates to:
  /// **'Qorong\'i'**
  String get settingsThemeDark;

  /// E9 preferences screen: system theme dropdown option.
  ///
  /// In uz, this message translates to:
  /// **'Tizim'**
  String get settingsThemeSystem;

  /// E9 preferences screen: large text toggle title.
  ///
  /// In uz, this message translates to:
  /// **'Katta matn'**
  String get settingsLargeTextTitle;

  /// E9 preferences screen: large text toggle subtitle.
  ///
  /// In uz, this message translates to:
  /// **'O\'qishni qulaylashtirish uchun matn hajmini kattalashtiring'**
  String get settingsLargeTextSubtitle;

  /// E9 preferences screen: 'Project Settings' section header.
  ///
  /// In uz, this message translates to:
  /// **'Loyiha sozlamalari'**
  String get settingsProjectSettingsSectionTitle;

  /// E9 preferences screen: auto-save toggle title.
  ///
  /// In uz, this message translates to:
  /// **'Loyihalarni avtomatik saqlash'**
  String get settingsAutoSaveTitle;

  /// E9 preferences screen: auto-save toggle subtitle.
  ///
  /// In uz, this message translates to:
  /// **'Ishingiz jarayonida avtomatik ravishda saqlanadi'**
  String get settingsAutoSaveSubtitle;

  /// E9 preferences screen: cloud sync toggle title.
  ///
  /// In uz, this message translates to:
  /// **'Bulutli sinxronizatsiya'**
  String get settingsCloudSyncTitle;

  /// E9 preferences screen: cloud sync toggle subtitle.
  ///
  /// In uz, this message translates to:
  /// **'Loyihalarni barcha qurilmalaringizda sinxronlang'**
  String get settingsCloudSyncSubtitle;

  /// E9 preferences screen: snackbar shown after turning cloud sync on.
  ///
  /// In uz, this message translates to:
  /// **'Cloud sync yoqildi'**
  String get settingsCloudSyncEnabledMessage;

  /// E9 preferences screen: snackbar shown after turning cloud sync off.
  ///
  /// In uz, this message translates to:
  /// **'Cloud sync o\'chirildi'**
  String get settingsCloudSyncDisabledMessage;

  /// E9 preferences screen: clear cache action tile title.
  ///
  /// In uz, this message translates to:
  /// **'Keshni tozalash'**
  String get settingsClearCacheTitle;

  /// E9 preferences screen: clear cache action tile subtitle.
  ///
  /// In uz, this message translates to:
  /// **'Xotiradagi bo\'sh joyni ko\'paytiring'**
  String get settingsClearCacheSubtitle;

  /// E9 preferences screen: clear cache action tile subtitle while the cache clear is in progress.
  ///
  /// In uz, this message translates to:
  /// **'Tozalanmoqda...'**
  String get settingsClearingCacheInProgress;

  /// E9 preferences screen: snackbar shown after cache is cleared successfully.
  ///
  /// In uz, this message translates to:
  /// **'Kesh tozalandi'**
  String get settingsCacheClearedMessage;

  /// E9 preferences screen: snackbar shown when clearing the cache fails.
  ///
  /// In uz, this message translates to:
  /// **'Keshni tozalab bo\'lmadi: {error}'**
  String settingsCacheClearFailedMessage(String error);

  /// E9 preferences screen: 'Privacy & Security' section header.
  ///
  /// In uz, this message translates to:
  /// **'Maxfiylik va xavfsizlik'**
  String get settingsPrivacySecuritySectionTitle;

  /// E9 preferences screen: privacy policy action tile title.
  ///
  /// In uz, this message translates to:
  /// **'Maxfiylik siyosati'**
  String get settingsPrivacyPolicyTitle;

  /// E9 preferences screen: privacy policy action tile subtitle.
  ///
  /// In uz, this message translates to:
  /// **'Maxfiylik siyosatimiz bilan tanishing'**
  String get settingsPrivacyPolicySubtitle;

  /// E9 preferences screen: terms of service action tile title.
  ///
  /// In uz, this message translates to:
  /// **'Foydalanish shartlari'**
  String get settingsTermsOfServiceTitle;

  /// E9 preferences screen: terms of service action tile subtitle.
  ///
  /// In uz, this message translates to:
  /// **'Shartlar va qoidalarni ko\'rib chiqing'**
  String get settingsTermsOfServiceSubtitle;

  /// E9 preferences screen: snackbar shown when a privacy/terms link fails to open.
  ///
  /// In uz, this message translates to:
  /// **'Havolani ochib bo\'lmadi: {url}'**
  String settingsLinkOpenFailedMessage(String url);

  /// E9 preferences screen: 'About' section header.
  ///
  /// In uz, this message translates to:
  /// **'Ilova haqida'**
  String get settingsAboutSectionTitle;

  /// E9 preferences screen: app version row label.
  ///
  /// In uz, this message translates to:
  /// **'Ilova versiyasi'**
  String get settingsAppVersionLabel;

  /// E9 preferences screen: build number row label.
  ///
  /// In uz, this message translates to:
  /// **'Build raqami'**
  String get settingsBuildNumberLabel;

  /// E9 preferences screen: 'Check for Updates' button.
  ///
  /// In uz, this message translates to:
  /// **'Yangilanishlarni tekshirish'**
  String get settingsCheckForUpdatesButton;

  /// E9 preferences screen: check-for-updates dialog title.
  ///
  /// In uz, this message translates to:
  /// **'Yangilanishlar'**
  String get settingsUpdatesDialogTitle;

  /// E9 preferences screen: check-for-updates dialog body.
  ///
  /// In uz, this message translates to:
  /// **'Siz ilovaning eng so\'nggi versiyasidasiz.'**
  String get settingsUpdatesDialogBody;

  /// E9 preferences screen: check-for-updates dialog dismiss button.
  ///
  /// In uz, this message translates to:
  /// **'OK'**
  String get settingsUpdatesDialogOk;

  /// No description provided for @registerRoleTitle.
  ///
  /// In uz, this message translates to:
  /// **'Siz kimsiz?'**
  String get registerRoleTitle;

  /// No description provided for @roleUser.
  ///
  /// In uz, this message translates to:
  /// **'Foydalanuvchi'**
  String get roleUser;

  /// No description provided for @roleUserDesc.
  ///
  /// In uz, this message translates to:
  /// **'O\'z ta\'mir va dizayn loyihalarim uchun'**
  String get roleUserDesc;

  /// No description provided for @roleShop.
  ///
  /// In uz, this message translates to:
  /// **'Do\'kon egasi'**
  String get roleShop;

  /// No description provided for @roleShopDesc.
  ///
  /// In uz, this message translates to:
  /// **'Mebel va materiallarimni sotaman'**
  String get roleShopDesc;

  /// No description provided for @roleUsta.
  ///
  /// In uz, this message translates to:
  /// **'Usta'**
  String get roleUsta;

  /// No description provided for @roleUstaDesc.
  ///
  /// In uz, this message translates to:
  /// **'Ta\'mir xizmatlarini taklif qilaman'**
  String get roleUstaDesc;

  /// No description provided for @businessApplyShopTitle.
  ///
  /// In uz, this message translates to:
  /// **'Do\'kon arizasi'**
  String get businessApplyShopTitle;

  /// No description provided for @businessApplyUstaTitle.
  ///
  /// In uz, this message translates to:
  /// **'Usta arizasi'**
  String get businessApplyUstaTitle;

  /// No description provided for @businessApplyIntro.
  ///
  /// In uz, this message translates to:
  /// **'Ma\'lumotlaringizni kiriting. Adminlar ko\'rib chiqib, tasdiqlagach ro\'yxatda ko\'rinasiz.'**
  String get businessApplyIntro;

  /// No description provided for @businessFieldShopName.
  ///
  /// In uz, this message translates to:
  /// **'Do\'kon nomi'**
  String get businessFieldShopName;

  /// No description provided for @businessFieldUstaName.
  ///
  /// In uz, this message translates to:
  /// **'Ismingiz yoki jamoa nomi'**
  String get businessFieldUstaName;

  /// No description provided for @businessFieldTrade.
  ///
  /// In uz, this message translates to:
  /// **'Kasbingiz'**
  String get businessFieldTrade;

  /// No description provided for @businessFieldDistrict.
  ///
  /// In uz, this message translates to:
  /// **'Tuman'**
  String get businessFieldDistrict;

  /// No description provided for @businessFieldPhone.
  ///
  /// In uz, this message translates to:
  /// **'Telefon (+998...)'**
  String get businessFieldPhone;

  /// No description provided for @businessFieldTelegram.
  ///
  /// In uz, this message translates to:
  /// **'Telegram (ixtiyoriy)'**
  String get businessFieldTelegram;

  /// No description provided for @businessFieldPriceMin.
  ///
  /// In uz, this message translates to:
  /// **'Dan'**
  String get businessFieldPriceMin;

  /// No description provided for @businessFieldPriceMax.
  ///
  /// In uz, this message translates to:
  /// **'Gacha'**
  String get businessFieldPriceMax;

  /// Usta apply/edit forms: heading above the two price fields (from / up to), so the fields themselves can carry short labels that fit half the width.
  ///
  /// In uz, this message translates to:
  /// **'Narx (so\'m)'**
  String get businessFieldPriceTitle;

  /// No description provided for @businessSubmit.
  ///
  /// In uz, this message translates to:
  /// **'Arizani yuborish'**
  String get businessSubmit;

  /// No description provided for @businessSkip.
  ///
  /// In uz, this message translates to:
  /// **'Keyinroq'**
  String get businessSkip;

  /// No description provided for @businessErrorName.
  ///
  /// In uz, this message translates to:
  /// **'Nomni kiriting'**
  String get businessErrorName;

  /// No description provided for @businessErrorPhone.
  ///
  /// In uz, this message translates to:
  /// **'Telefonni +998 bilan to\'liq kiriting'**
  String get businessErrorPhone;

  /// No description provided for @businessErrorPrice.
  ///
  /// In uz, this message translates to:
  /// **'Maksimal narx minimaldan kam bo\'lmasin'**
  String get businessErrorPrice;

  /// No description provided for @businessErrorExists.
  ///
  /// In uz, this message translates to:
  /// **'Sizda allaqachon bunday ariza bor'**
  String get businessErrorExists;

  /// No description provided for @businessErrorFailed.
  ///
  /// In uz, this message translates to:
  /// **'Arizani yuborib bo\'lmadi. Qayta urinib ko\'ring.'**
  String get businessErrorFailed;

  /// No description provided for @businessTitle.
  ///
  /// In uz, this message translates to:
  /// **'Biznesim'**
  String get businessTitle;

  /// No description provided for @businessShopSection.
  ///
  /// In uz, this message translates to:
  /// **'Do\'kon'**
  String get businessShopSection;

  /// No description provided for @businessUstaSection.
  ///
  /// In uz, this message translates to:
  /// **'Usta profilim'**
  String get businessUstaSection;

  /// No description provided for @businessStatusPending.
  ///
  /// In uz, this message translates to:
  /// **'Ko\'rib chiqilmoqda'**
  String get businessStatusPending;

  /// No description provided for @businessStatusApproved.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlangan'**
  String get businessStatusApproved;

  /// No description provided for @businessStatusRejected.
  ///
  /// In uz, this message translates to:
  /// **'Rad etilgan'**
  String get businessStatusRejected;

  /// No description provided for @businessPendingHint.
  ///
  /// In uz, this message translates to:
  /// **'Ariza adminlar tomonidan ko\'rib chiqilmoqda. Tasdiqlangach ro\'yxatda ko\'rinasiz.'**
  String get businessPendingHint;

  /// No description provided for @businessApprovedHint.
  ///
  /// In uz, this message translates to:
  /// **'Profilingiz ro\'yxatda ko\'rinadi.'**
  String get businessApprovedHint;

  /// No description provided for @businessResubmit.
  ///
  /// In uz, this message translates to:
  /// **'Qayta yuborish'**
  String get businessResubmit;

  /// No description provided for @businessComingProducts.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulotlar boshqaruvi tez kunda'**
  String get businessComingProducts;

  /// No description provided for @businessComingRequests.
  ///
  /// In uz, this message translates to:
  /// **'Mijoz so\'rovlari tez kunda'**
  String get businessComingRequests;

  /// No description provided for @businessLoadFailed.
  ///
  /// In uz, this message translates to:
  /// **'Ma\'lumotni yuklab bo\'lmadi'**
  String get businessLoadFailed;

  /// No description provided for @profileMenuBusiness.
  ///
  /// In uz, this message translates to:
  /// **'Biznesim'**
  String get profileMenuBusiness;

  /// No description provided for @profileMenuBecomePartner.
  ///
  /// In uz, this message translates to:
  /// **'Do\'kon yoki usta sifatida qo\'shilish'**
  String get profileMenuBecomePartner;

  /// No description provided for @tradeElektrik.
  ///
  /// In uz, this message translates to:
  /// **'Elektrik'**
  String get tradeElektrik;

  /// No description provided for @tradeElektrikLoyihachi.
  ///
  /// In uz, this message translates to:
  /// **'Elektr loyihachi'**
  String get tradeElektrikLoyihachi;

  /// No description provided for @tradeSantexnik.
  ///
  /// In uz, this message translates to:
  /// **'Santexnik'**
  String get tradeSantexnik;

  /// No description provided for @tradeMalyar.
  ///
  /// In uz, this message translates to:
  /// **'Malyar'**
  String get tradeMalyar;

  /// No description provided for @tradeOboy.
  ///
  /// In uz, this message translates to:
  /// **'Oboy ustasi'**
  String get tradeOboy;

  /// No description provided for @tradeLaminat.
  ///
  /// In uz, this message translates to:
  /// **'Laminat ustasi'**
  String get tradeLaminat;

  /// No description provided for @tradeBrigada.
  ///
  /// In uz, this message translates to:
  /// **'Brigada'**
  String get tradeBrigada;

  /// No description provided for @businessRejectedReason.
  ///
  /// In uz, this message translates to:
  /// **'Sabab: {note}'**
  String businessRejectedReason(String note);

  /// No description provided for @shopProductsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulotlarim'**
  String get shopProductsTitle;

  /// No description provided for @shopProductsEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Hali mahsulot yo\'q. Rasm olib, birinchi mahsulotni qo\'shing.'**
  String get shopProductsEmpty;

  /// No description provided for @shopProductsOpen.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulotlarni boshqarish'**
  String get shopProductsOpen;

  /// No description provided for @shopProductVisible.
  ///
  /// In uz, this message translates to:
  /// **'Katalogda ko\'rinadi'**
  String get shopProductVisible;

  /// No description provided for @shopProductEdit.
  ///
  /// In uz, this message translates to:
  /// **'Tahrirlash'**
  String get shopProductEdit;

  /// No description provided for @shopProductName.
  ///
  /// In uz, this message translates to:
  /// **'Nomi'**
  String get shopProductName;

  /// No description provided for @shopProductPrice.
  ///
  /// In uz, this message translates to:
  /// **'Narxi (so\'m)'**
  String get shopProductPrice;

  /// No description provided for @shopProductSave.
  ///
  /// In uz, this message translates to:
  /// **'Saqlash'**
  String get shopProductSave;

  /// No description provided for @shopProductDelete.
  ///
  /// In uz, this message translates to:
  /// **'O\'chirish'**
  String get shopProductDelete;

  /// No description provided for @shopProductDeleteConfirm.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulot o\'chirilsin? Buni qaytarib bo\'lmaydi.'**
  String get shopProductDeleteConfirm;

  /// No description provided for @shopProductCancel.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilish'**
  String get shopProductCancel;

  /// No description provided for @shopProductFailed.
  ///
  /// In uz, this message translates to:
  /// **'Amalni bajarib bo\'lmadi. Qayta urinib ko\'ring.'**
  String get shopProductFailed;

  /// No description provided for @shopProductNoPrice.
  ///
  /// In uz, this message translates to:
  /// **'Narx ko\'rsatilmagan'**
  String get shopProductNoPrice;

  /// No description provided for @addProductTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yangi mahsulot'**
  String get addProductTitle;

  /// No description provided for @addProductPhotoHint.
  ///
  /// In uz, this message translates to:
  /// **'Mebelning aniq rasmini oling (toza fon yaxshi). 3D modelni o\'zimiz yaratamiz.'**
  String get addProductPhotoHint;

  /// No description provided for @addProductGallery.
  ///
  /// In uz, this message translates to:
  /// **'Galereyadan'**
  String get addProductGallery;

  /// No description provided for @addProductCamera.
  ///
  /// In uz, this message translates to:
  /// **'Kameradan'**
  String get addProductCamera;

  /// No description provided for @addProductCategory.
  ///
  /// In uz, this message translates to:
  /// **'Turi'**
  String get addProductCategory;

  /// No description provided for @addProductRoom.
  ///
  /// In uz, this message translates to:
  /// **'Xona'**
  String get addProductRoom;

  /// No description provided for @addProductRoomAll.
  ///
  /// In uz, this message translates to:
  /// **'Barcha xonalar'**
  String get addProductRoomAll;

  /// No description provided for @addProductPlacement.
  ///
  /// In uz, this message translates to:
  /// **'Joylashuvi'**
  String get addProductPlacement;

  /// No description provided for @addProductSubmit.
  ///
  /// In uz, this message translates to:
  /// **'3D model yaratish va qo\'shish'**
  String get addProductSubmit;

  /// No description provided for @addProductBuilding.
  ///
  /// In uz, this message translates to:
  /// **'3D model yaratilmoqda… taxminan 1–2 daqiqa, ilovani yopmang'**
  String get addProductBuilding;

  /// No description provided for @addProductUploading.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulot do\'konga qo\'shilmoqda…'**
  String get addProductUploading;

  /// No description provided for @addProductDone.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulot qo\'shildi. Admin tasdiqlagach katalogda ko\'rinadi.'**
  String get addProductDone;

  /// No description provided for @addProductNeedPhoto.
  ///
  /// In uz, this message translates to:
  /// **'Avval rasm tanlang'**
  String get addProductNeedPhoto;

  /// No description provided for @addProductNeedName.
  ///
  /// In uz, this message translates to:
  /// **'Nomini kiriting'**
  String get addProductNeedName;

  /// No description provided for @addProductFailed.
  ///
  /// In uz, this message translates to:
  /// **'3D modelni yaratib bo\'lmadi. Boshqa rasm bilan urinib ko\'ring.'**
  String get addProductFailed;

  /// No description provided for @addProductUnavailable.
  ///
  /// In uz, this message translates to:
  /// **'3D model xizmati hozir mavjud emas'**
  String get addProductUnavailable;

  /// No description provided for @addProductLimit.
  ///
  /// In uz, this message translates to:
  /// **'Bugungi limit tugadi. Ertaga qayta urinib ko\'ring.'**
  String get addProductLimit;

  /// No description provided for @addProductTooMany.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlanmagan mahsulotlar ko\'p. Ular ko\'rib chiqilishini kuting.'**
  String get addProductTooMany;

  /// No description provided for @categoryDivan.
  ///
  /// In uz, this message translates to:
  /// **'Divan'**
  String get categoryDivan;

  /// No description provided for @categoryStol.
  ///
  /// In uz, this message translates to:
  /// **'Stol'**
  String get categoryStol;

  /// No description provided for @categoryStul.
  ///
  /// In uz, this message translates to:
  /// **'Stul'**
  String get categoryStul;

  /// No description provided for @categoryKaravot.
  ///
  /// In uz, this message translates to:
  /// **'Karavot'**
  String get categoryKaravot;

  /// No description provided for @categoryShkaf.
  ///
  /// In uz, this message translates to:
  /// **'Shkaf'**
  String get categoryShkaf;

  /// No description provided for @categoryLampa.
  ///
  /// In uz, this message translates to:
  /// **'Lampa'**
  String get categoryLampa;

  /// No description provided for @categoryBoshqa.
  ///
  /// In uz, this message translates to:
  /// **'Boshqa'**
  String get categoryBoshqa;

  /// No description provided for @roomMehmonxona.
  ///
  /// In uz, this message translates to:
  /// **'Mehmonxona'**
  String get roomMehmonxona;

  /// No description provided for @roomOshxona.
  ///
  /// In uz, this message translates to:
  /// **'Oshxona'**
  String get roomOshxona;

  /// No description provided for @roomYotoqxona.
  ///
  /// In uz, this message translates to:
  /// **'Yotoqxona'**
  String get roomYotoqxona;

  /// No description provided for @roomHammom.
  ///
  /// In uz, this message translates to:
  /// **'Hammom'**
  String get roomHammom;

  /// No description provided for @roomBalkon.
  ///
  /// In uz, this message translates to:
  /// **'Balkon'**
  String get roomBalkon;

  /// No description provided for @placementPol.
  ///
  /// In uz, this message translates to:
  /// **'Polda'**
  String get placementPol;

  /// No description provided for @placementDevor.
  ///
  /// In uz, this message translates to:
  /// **'Devorda'**
  String get placementDevor;

  /// No description provided for @placementShift.
  ///
  /// In uz, this message translates to:
  /// **'Shiftda'**
  String get placementShift;

  /// No description provided for @ustaLeadsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Mijoz so\'rovlari'**
  String get ustaLeadsTitle;

  /// No description provided for @ustaLeadsOpen.
  ///
  /// In uz, this message translates to:
  /// **'Mijoz so\'rovlari'**
  String get ustaLeadsOpen;

  /// No description provided for @ustaLeadsEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Hali so\'rov yo\'q. Mijozlar sizga smeta bilan murojaat qilganda shu yerda ko\'rinadi.'**
  String get ustaLeadsEmpty;

  /// No description provided for @ustaLeadCall.
  ///
  /// In uz, this message translates to:
  /// **'Qo\'ng\'iroq qilish'**
  String get ustaLeadCall;

  /// No description provided for @ustaLeadNoPhone.
  ///
  /// In uz, this message translates to:
  /// **'Telefon ko\'rsatilmagan'**
  String get ustaLeadNoPhone;

  /// No description provided for @ustaLeadClient.
  ///
  /// In uz, this message translates to:
  /// **'Mijoz'**
  String get ustaLeadClient;

  /// No description provided for @ustaLeadEstimate.
  ///
  /// In uz, this message translates to:
  /// **'Smeta: {total} ({lines} ta qator)'**
  String ustaLeadEstimate(String total, int lines);

  /// No description provided for @leadStatusNew.
  ///
  /// In uz, this message translates to:
  /// **'Yangi'**
  String get leadStatusNew;

  /// No description provided for @leadStatusViewed.
  ///
  /// In uz, this message translates to:
  /// **'Ko\'rildi'**
  String get leadStatusViewed;

  /// No description provided for @leadStatusContacted.
  ///
  /// In uz, this message translates to:
  /// **'Bog\'lanildi'**
  String get leadStatusContacted;

  /// No description provided for @leadStatusClosed.
  ///
  /// In uz, this message translates to:
  /// **'Yopildi'**
  String get leadStatusClosed;

  /// No description provided for @ustaLeadMarkViewed.
  ///
  /// In uz, this message translates to:
  /// **'Ko\'rildi'**
  String get ustaLeadMarkViewed;

  /// No description provided for @ustaLeadMarkContacted.
  ///
  /// In uz, this message translates to:
  /// **'Bog\'lanildi'**
  String get ustaLeadMarkContacted;

  /// No description provided for @ustaLeadMarkClosed.
  ///
  /// In uz, this message translates to:
  /// **'Yopish'**
  String get ustaLeadMarkClosed;

  /// No description provided for @ustaEditOpen.
  ///
  /// In uz, this message translates to:
  /// **'Profilni tahrirlash'**
  String get ustaEditOpen;

  /// No description provided for @ustaEditTitle.
  ///
  /// In uz, this message translates to:
  /// **'Usta profilim'**
  String get ustaEditTitle;

  /// No description provided for @ustaEditSave.
  ///
  /// In uz, this message translates to:
  /// **'Saqlash'**
  String get ustaEditSave;

  /// No description provided for @ustaEditFailed.
  ///
  /// In uz, this message translates to:
  /// **'Saqlab bo\'lmadi. Qayta urinib ko\'ring.'**
  String get ustaEditFailed;

  /// No description provided for @shopEditTitle.
  ///
  /// In uz, this message translates to:
  /// **'Do\'kon profili'**
  String get shopEditTitle;

  /// No description provided for @addProductMoreAngles.
  ///
  /// In uz, this message translates to:
  /// **'Boshqa burchaklar (ixtiyoriy)'**
  String get addProductMoreAngles;

  /// No description provided for @addProductMoreAnglesHint.
  ///
  /// In uz, this message translates to:
  /// **'Chap, orqa va o\'ng tomondan suratlar 3D modelni aniqroq qiladi.'**
  String get addProductMoreAnglesHint;

  /// No description provided for @addProductAngleLeft.
  ///
  /// In uz, this message translates to:
  /// **'Chap'**
  String get addProductAngleLeft;

  /// No description provided for @addProductAngleBack.
  ///
  /// In uz, this message translates to:
  /// **'Orqa'**
  String get addProductAngleBack;

  /// No description provided for @addProductAngleRight.
  ///
  /// In uz, this message translates to:
  /// **'O\'ng'**
  String get addProductAngleRight;

  /// No description provided for @addProductAngleRemove.
  ///
  /// In uz, this message translates to:
  /// **'O\'chirish'**
  String get addProductAngleRemove;

  /// No description provided for @shopInquiriesTitle.
  ///
  /// In uz, this message translates to:
  /// **'Mijoz murojaatlari'**
  String get shopInquiriesTitle;

  /// No description provided for @shopInquiriesOpen.
  ///
  /// In uz, this message translates to:
  /// **'Murojaatlar'**
  String get shopInquiriesOpen;

  /// No description provided for @shopInquiriesOpenWithNew.
  ///
  /// In uz, this message translates to:
  /// **'Murojaatlar ({count} yangi)'**
  String shopInquiriesOpenWithNew(int count);

  /// No description provided for @shopInquiriesEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Hali murojaat yo\'q. Mijozlar mahsulotingiz haqida so\'rasa, shu yerda ko\'rinadi.'**
  String get shopInquiriesEmpty;

  /// No description provided for @shopInquiryProduct.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulot: {name}'**
  String shopInquiryProduct(String name);

  /// No description provided for @shopStatsOpen.
  ///
  /// In uz, this message translates to:
  /// **'Statistika'**
  String get shopStatsOpen;

  /// No description provided for @shopStatsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Do\'kon statistikasi'**
  String get shopStatsTitle;

  /// No description provided for @shopStatsProducts.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulotlar'**
  String get shopStatsProducts;

  /// No description provided for @shopStatsApproved.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlangan'**
  String get shopStatsApproved;

  /// No description provided for @shopStatsPending.
  ///
  /// In uz, this message translates to:
  /// **'Ko\'rib chiqilmoqda'**
  String get shopStatsPending;

  /// No description provided for @shopStatsRejected.
  ///
  /// In uz, this message translates to:
  /// **'Rad etilgan'**
  String get shopStatsRejected;

  /// No description provided for @shopStatsVisible.
  ///
  /// In uz, this message translates to:
  /// **'Katalogda ko\'rinadi'**
  String get shopStatsVisible;

  /// No description provided for @shopStatsInquiries.
  ///
  /// In uz, this message translates to:
  /// **'Murojaatlar'**
  String get shopStatsInquiries;

  /// No description provided for @shopStatsNewInquiries.
  ///
  /// In uz, this message translates to:
  /// **'Yangi murojaatlar'**
  String get shopStatsNewInquiries;

  /// No description provided for @shopStatsPlacements.
  ///
  /// In uz, this message translates to:
  /// **'Xonalarga joylashtirilgan'**
  String get shopStatsPlacements;

  /// No description provided for @shopStatsTop.
  ///
  /// In uz, this message translates to:
  /// **'Eng ko\'p tanlangan mahsulotlar'**
  String get shopStatsTop;

  /// No description provided for @shopStatsTopEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Hali ma\'lumot yo\'q.'**
  String get shopStatsTopEmpty;

  /// No description provided for @mastersSendFailed.
  ///
  /// In uz, this message translates to:
  /// **'Yuborib bo\'lmadi. Qayta urinib ko\'ring.'**
  String get mastersSendFailed;

  /// No description provided for @shopCheckoutUnlinkedLines.
  ///
  /// In uz, this message translates to:
  /// **'Savatdagi ba\'zi mahsulotlar do\'kon katalogiga bog\'lanmagan, shuning uchun buyurtma berib bo\'lmaydi: {names}. Ularni savatdan olib tashlang.'**
  String shopCheckoutUnlinkedLines(String names);

  /// No description provided for @shopOrderPartial.
  ///
  /// In uz, this message translates to:
  /// **'{dealer} buyurtmasi qabul qilinmadi: {error} Qolgan buyurtmalar yuborildi.'**
  String shopOrderPartial(String dealer, String error);

  /// No description provided for @shopOrdersTitle.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtmalar'**
  String get shopOrdersTitle;

  /// No description provided for @shopOrdersOpen.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtmalar'**
  String get shopOrdersOpen;

  /// No description provided for @shopOrdersEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Hali buyurtma yo\'q. Mijozlar buyurtma bersa, shu yerda ko\'rinadi.'**
  String get shopOrdersEmpty;

  /// No description provided for @shopOrderMarkGathering.
  ///
  /// In uz, this message translates to:
  /// **'Yig\'ilmoqda deb belgilash'**
  String get shopOrderMarkGathering;

  /// No description provided for @shopOrderMarkOnTheWay.
  ///
  /// In uz, this message translates to:
  /// **'Yo\'lda deb belgilash'**
  String get shopOrderMarkOnTheWay;

  /// No description provided for @shopOrderMarkDelivered.
  ///
  /// In uz, this message translates to:
  /// **'Yetkazildi deb belgilash'**
  String get shopOrderMarkDelivered;

  /// No description provided for @shopOrderAddressLine.
  ///
  /// In uz, this message translates to:
  /// **'Manzil: {value}'**
  String shopOrderAddressLine(String value);

  /// No description provided for @shopOrderPaymentLine.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov: {value}'**
  String shopOrderPaymentLine(String value);

  /// No description provided for @shopOrderPayCash.
  ///
  /// In uz, this message translates to:
  /// **'Naqd'**
  String get shopOrderPayCash;

  /// No description provided for @shopOrderPayCard.
  ///
  /// In uz, this message translates to:
  /// **'Karta'**
  String get shopOrderPayCard;

  /// No description provided for @tradePlitkachi.
  ///
  /// In uz, this message translates to:
  /// **'Plitkachi'**
  String get tradePlitkachi;

  /// No description provided for @tradeShtukatur.
  ///
  /// In uz, this message translates to:
  /// **'Shtukatur'**
  String get tradeShtukatur;

  /// No description provided for @tradeGipsokartonchi.
  ///
  /// In uz, this message translates to:
  /// **'Gipsokartonchi'**
  String get tradeGipsokartonchi;

  /// No description provided for @tradeEshikOyna.
  ///
  /// In uz, this message translates to:
  /// **'Eshik-oyna ustasi'**
  String get tradeEshikOyna;

  /// No description provided for @tradeIsitishKonditsioner.
  ///
  /// In uz, this message translates to:
  /// **'Isitish va konditsioner ustasi'**
  String get tradeIsitishKonditsioner;

  /// No description provided for @tradeDemontaj.
  ///
  /// In uz, this message translates to:
  /// **'Demontajchi'**
  String get tradeDemontaj;

  /// No description provided for @ustaPortfolioOpen.
  ///
  /// In uz, this message translates to:
  /// **'Portfolio'**
  String get ustaPortfolioOpen;

  /// No description provided for @ustaPortfolioTitle.
  ///
  /// In uz, this message translates to:
  /// **'Mening portfolioim'**
  String get ustaPortfolioTitle;

  /// No description provided for @ustaPortfolioEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Hali ish rasmlari yo\'q. Bajargan ishlaringizni qo\'shing.'**
  String get ustaPortfolioEmpty;

  /// No description provided for @ustaPortfolioAdd.
  ///
  /// In uz, this message translates to:
  /// **'Rasm qo\'shish'**
  String get ustaPortfolioAdd;

  /// No description provided for @ustaPortfolioCaption.
  ///
  /// In uz, this message translates to:
  /// **'Izoh (ixtiyoriy)'**
  String get ustaPortfolioCaption;

  /// No description provided for @ustaPortfolioUpload.
  ///
  /// In uz, this message translates to:
  /// **'Yuklash'**
  String get ustaPortfolioUpload;

  /// No description provided for @ustaPortfolioDeleteConfirm.
  ///
  /// In uz, this message translates to:
  /// **'Rasm o\'chirilsin? Buni qaytarib bo\'lmaydi.'**
  String get ustaPortfolioDeleteConfirm;

  /// No description provided for @ustaPortfolioLoadFailed.
  ///
  /// In uz, this message translates to:
  /// **'Portfolioni yuklab bo\'lmadi.'**
  String get ustaPortfolioLoadFailed;

  /// No description provided for @ustaLeadMessage.
  ///
  /// In uz, this message translates to:
  /// **'Mijoz xabari: {message}'**
  String ustaLeadMessage(String message);

  /// No description provided for @profileMenuDeleteAccount.
  ///
  /// In uz, this message translates to:
  /// **'Hisobni o\'chirish'**
  String get profileMenuDeleteAccount;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In uz, this message translates to:
  /// **'Hisobni o\'chirasizmi?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountBody.
  ///
  /// In uz, this message translates to:
  /// **'Hisobingiz bilan birga barcha loyihalaringiz, rasmlaringiz, buyurtmalaringiz hamda do\'koningiz yoki usta profilingiz o\'chiriladi. Bu doimiy va uni qaytarib bo\'lmaydi.'**
  String get deleteAccountBody;

  /// No description provided for @deleteAccountPasswordLabel.
  ///
  /// In uz, this message translates to:
  /// **'Parol'**
  String get deleteAccountPasswordLabel;

  /// No description provided for @deleteAccountPasswordHint.
  ///
  /// In uz, this message translates to:
  /// **'Telefon kodi bilan kirgan bo\'lsangiz, bo\'sh qoldiring'**
  String get deleteAccountPasswordHint;

  /// No description provided for @deleteAccountDone.
  ///
  /// In uz, this message translates to:
  /// **'Hisobingiz o\'chirildi'**
  String get deleteAccountDone;

  /// No description provided for @scanFailedReason.
  ///
  /// In uz, this message translates to:
  /// **'Sabab: {reason}'**
  String scanFailedReason(String reason);

  /// No description provided for @shopCategoryBoyoq.
  ///
  /// In uz, this message translates to:
  /// **'Bo\'yoq'**
  String get shopCategoryBoyoq;

  /// No description provided for @shopCategoryOboy.
  ///
  /// In uz, this message translates to:
  /// **'Oboy'**
  String get shopCategoryOboy;

  /// No description provided for @shopCategoryLaminat.
  ///
  /// In uz, this message translates to:
  /// **'Laminat'**
  String get shopCategoryLaminat;

  /// No description provided for @shopCategoryKafel.
  ///
  /// In uz, this message translates to:
  /// **'Kafel'**
  String get shopCategoryKafel;

  /// No description provided for @shopCategoryParket.
  ///
  /// In uz, this message translates to:
  /// **'Parket'**
  String get shopCategoryParket;

  /// No description provided for @shopCategoryGips.
  ///
  /// In uz, this message translates to:
  /// **'Gips'**
  String get shopCategoryGips;

  /// No description provided for @shopCategorySement.
  ///
  /// In uz, this message translates to:
  /// **'Sement'**
  String get shopCategorySement;

  /// No description provided for @shopCategorySantexnika.
  ///
  /// In uz, this message translates to:
  /// **'Santexnika'**
  String get shopCategorySantexnika;

  /// No description provided for @shopCategoryElektr.
  ///
  /// In uz, this message translates to:
  /// **'Elektr'**
  String get shopCategoryElektr;

  /// Shop category chip/label: doors (server category `eshik`).
  ///
  /// In uz, this message translates to:
  /// **'Eshik'**
  String get shopCategoryEshik;

  /// Shop category chip/label: windows (server category `deraza`).
  ///
  /// In uz, this message translates to:
  /// **'Deraza'**
  String get shopCategoryDeraza;

  /// No description provided for @tradeBoshqa.
  ///
  /// In uz, this message translates to:
  /// **'Boshqa usta'**
  String get tradeBoshqa;

  /// No description provided for @qualityTierEkonom.
  ///
  /// In uz, this message translates to:
  /// **'Ekonom'**
  String get qualityTierEkonom;

  /// No description provided for @qualityTierStandart.
  ///
  /// In uz, this message translates to:
  /// **'Standart'**
  String get qualityTierStandart;

  /// No description provided for @qualityTierPremium.
  ///
  /// In uz, this message translates to:
  /// **'Premium'**
  String get qualityTierPremium;

  /// No description provided for @estimateOpen3dStudio.
  ///
  /// In uz, this message translates to:
  /// **'3D Studio'**
  String get estimateOpen3dStudio;

  /// No description provided for @actionDelete.
  ///
  /// In uz, this message translates to:
  /// **'O\'chirish'**
  String get actionDelete;

  /// No description provided for @mapAttribution.
  ///
  /// In uz, this message translates to:
  /// **'© OpenStreetMap hissadorlari'**
  String get mapAttribution;

  /// Title of the one-time dialog asking whether to send push notifications.
  ///
  /// In uz, this message translates to:
  /// **'Xabar beraylikmi?'**
  String get pushPromptTitle;

  /// Body of the one-time push notification dialog.
  ///
  /// In uz, this message translates to:
  /// **'Dizayningiz tayyor bo\'lganda yoki buyurtma holati o\'zgarganda xabar beramiz.'**
  String get pushPromptBody;

  /// Confirm button of the push notification dialog; triggers the system permission request.
  ///
  /// In uz, this message translates to:
  /// **'Ha'**
  String get pushPromptYes;

  /// Dismiss button of the push notification dialog.
  ///
  /// In uz, this message translates to:
  /// **'Keyinroq'**
  String get pushPromptLater;

  /// Settings screen: notifications row title; opens system settings.
  ///
  /// In uz, this message translates to:
  /// **'Bildirishnomalar'**
  String get settingsNotificationsTitle;

  /// Settings screen: notifications row subtitle when permission is granted.
  ///
  /// In uz, this message translates to:
  /// **'Yoqilgan'**
  String get settingsNotificationsOn;

  /// Settings screen: notifications row subtitle when permission is not granted.
  ///
  /// In uz, this message translates to:
  /// **'O\'chirilgan'**
  String get settingsNotificationsOff;

  /// Android notification channel name shown in system settings.
  ///
  /// In uz, this message translates to:
  /// **'Andoza yangiliklari'**
  String get pushChannelName;

  /// Share screen (a pin shared from the Pinterest app): app-bar title.
  ///
  /// In uz, this message translates to:
  /// **'Pinterest pin'**
  String get sharePinTitle;

  /// Share screen: heading above the list of the user's rooms.
  ///
  /// In uz, this message translates to:
  /// **'Qaysi xonaga qo\'llaymiz?'**
  String get sharePinChooseRoom;

  /// Share screen: what happens after a room is picked.
  ///
  /// In uz, this message translates to:
  /// **'Studio\'dagi AI dizayner shu pin bilan ochiladi.'**
  String get sharePinHint;

  /// Share screen: shown when the user has no rooms to apply the pin to.
  ///
  /// In uz, this message translates to:
  /// **'Hali xona yo\'q. Avval \"+\" orqali xona qo\'shing.'**
  String get sharePinNoRooms;

  /// Share screen: the shared text has no Pinterest pin link (same wording as the API's 422).
  ///
  /// In uz, this message translates to:
  /// **'Bu Pinterest pin havolasi emas'**
  String get sharePinNotPin;

  /// Share screen: how to share a pin, under the not-a-pin message.
  ///
  /// In uz, this message translates to:
  /// **'Pinterest ilovasida pinni oching va \"Ulashish\" → Andoza AI ni tanlang.'**
  String get sharePinNotPinHint;

  /// Seller product forms: heading above the furniture style chips.
  ///
  /// In uz, this message translates to:
  /// **'Uslublar'**
  String get furnitureStylesLabel;

  /// Seller product forms: shown under the style chips when none is picked.
  ///
  /// In uz, this message translates to:
  /// **'Hamma uslubga mos'**
  String get furnitureStylesAll;

  /// Furniture style chip (API id neoklassika).
  ///
  /// In uz, this message translates to:
  /// **'Neoklassika'**
  String get furnitureStyleNeoklassika;

  /// Furniture style chip (API id klassik).
  ///
  /// In uz, this message translates to:
  /// **'Klassik'**
  String get furnitureStyleKlassik;

  /// Furniture style chip (API id zamonaviy).
  ///
  /// In uz, this message translates to:
  /// **'Zamonaviy'**
  String get furnitureStyleZamonaviy;

  /// Furniture style chip (API id hitech).
  ///
  /// In uz, this message translates to:
  /// **'Hi-Tech'**
  String get furnitureStyleHitech;

  /// Furniture style chip (API id minimalist).
  ///
  /// In uz, this message translates to:
  /// **'Minimalist'**
  String get furnitureStyleMinimalist;

  /// Furniture style chip (API id skandinav).
  ///
  /// In uz, this message translates to:
  /// **'Skandinav'**
  String get furnitureStyleSkandinav;

  /// Furniture style chip (API id loft).
  ///
  /// In uz, this message translates to:
  /// **'Loft'**
  String get furnitureStyleLoft;

  /// Furniture style chip (API id milliy).
  ///
  /// In uz, this message translates to:
  /// **'Milliy'**
  String get furnitureStyleMilliy;

  /// E1 smeta: floor type chosen without a product; the server priced it from the median shop product.
  ///
  /// In uz, this message translates to:
  /// **'Pol mahsuloti tanlanmagan — narx do\'kondagi o\'rtacha poldan olindi (taxminiy).'**
  String get estimateFloorStandIn;

  /// Scan screen: title of the sheet choosing one room or several rooms (iPhones that support it).
  ///
  /// In uz, this message translates to:
  /// **'Nimani skanerlaymiz?'**
  String get scanChoiceTitle;

  /// Scan choice sheet: option to scan a single room.
  ///
  /// In uz, this message translates to:
  /// **'Bitta xona'**
  String get scanChoiceOneRoom;

  /// Scan choice sheet: option to scan several rooms in one session.
  ///
  /// In uz, this message translates to:
  /// **'Bir nechta xona (kvartira)'**
  String get scanChoiceFlat;

  /// Scan choice sheet: hint under the several-rooms option.
  ///
  /// In uz, this message translates to:
  /// **'Xonalarni ketma-ket skanerlang — ular rejada o\'z joyiga tushadi'**
  String get scanChoiceFlatHint;

  /// Multi-room scanner button: finish this room and start the next.
  ///
  /// In uz, this message translates to:
  /// **'Keyingi xona'**
  String get scanNextRoom;

  /// Multi-room scanner button: end the session.
  ///
  /// In uz, this message translates to:
  /// **'Tugatish'**
  String get scanFinish;

  /// Multi-room scanner: the current room's number, and the default name of scanned room n.
  ///
  /// In uz, this message translates to:
  /// **'{n}-xona'**
  String scanRoomN(int n);

  /// Title of the review page after a multi-room scan.
  ///
  /// In uz, this message translates to:
  /// **'Skanerlangan xonalar'**
  String get flatReviewTitle;

  /// Multi-room review: label of a room's name field.
  ///
  /// In uz, this message translates to:
  /// **'Xona nomi'**
  String get flatReviewRoomName;

  /// Multi-room review: button that saves the rooms and opens the 3D studio.
  ///
  /// In uz, this message translates to:
  /// **'Studiyada ochish'**
  String get flatReviewContinue;

  /// Multi-room review: the session ended early (app went to the background); n rooms were kept.
  ///
  /// In uz, this message translates to:
  /// **'Skaner to\'xtadi — {n} ta xona saqlandi'**
  String flatReviewPartial(int n);

  /// Multi-room review: n scanned rooms could not be converted into a plan.
  ///
  /// In uz, this message translates to:
  /// **'{n} ta xona o\'qilmadi va qo\'shilmadi'**
  String flatReviewDropped(int n);

  /// Multi-room review: saving stopped part-way; only some rooms were saved (the rest are lost and must be scanned again).
  ///
  /// In uz, this message translates to:
  /// **'{total} ta xonadan {saved} tasi saqlandi — qolganlarini qayta skanerlang'**
  String flatReviewSavedSome(int saved, int total);

  /// Login: black button (iOS only) that signs in with an Apple ID.
  ///
  /// In uz, this message translates to:
  /// **'Apple bilan kirish'**
  String get loginWithApple;

  /// Login error: Sign in with Apple failed (invalid token or Apple error).
  ///
  /// In uz, this message translates to:
  /// **'Apple orqali kirib bo\'lmadi. Qayta urinib ko\'ring.'**
  String get loginAppleFailed;

  /// Menu item on a craftsman profile / product: opens the report sheet.
  ///
  /// In uz, this message translates to:
  /// **'Shikoyat qilish'**
  String get reportAction;

  /// Report sheet: title.
  ///
  /// In uz, this message translates to:
  /// **'Shikoyat'**
  String get reportTitle;

  /// Report sheet: one-line explanation under the title.
  ///
  /// In uz, this message translates to:
  /// **'Nima noto\'g\'ri? Shikoyatingizni moderatorlar ko\'rib chiqadi.'**
  String get reportHint;

  /// Report reason option.
  ///
  /// In uz, this message translates to:
  /// **'Spam yoki reklama'**
  String get reportReasonSpam;

  /// Report reason option: offensive or objectionable material.
  ///
  /// In uz, this message translates to:
  /// **'Nomaqbul kontent'**
  String get reportReasonInappropriate;

  /// Report reason option.
  ///
  /// In uz, this message translates to:
  /// **'Firibgarlik'**
  String get reportReasonFraud;

  /// Report reason option.
  ///
  /// In uz, this message translates to:
  /// **'Boshqa'**
  String get reportReasonOther;

  /// Report sheet: label of the optional free-text field.
  ///
  /// In uz, this message translates to:
  /// **'Izoh (ixtiyoriy)'**
  String get reportDetails;

  /// Report sheet: submit button.
  ///
  /// In uz, this message translates to:
  /// **'Yuborish'**
  String get reportSend;

  /// Snackbar after a report was sent.
  ///
  /// In uz, this message translates to:
  /// **'Rahmat! Shikoyatingiz yuborildi.'**
  String get reportSent;

  /// Menu item on a craftsman profile: hide this craftsman.
  ///
  /// In uz, this message translates to:
  /// **'Bloklash'**
  String get blockUstaAction;

  /// Block confirmation dialog: title.
  ///
  /// In uz, this message translates to:
  /// **'Ustani bloklaysizmi?'**
  String get blockUstaTitle;

  /// Block confirmation dialog: what blocking does.
  ///
  /// In uz, this message translates to:
  /// **'U endi xaritada va ro\'yxatda sizga ko\'rinmaydi.'**
  String get blockUstaBody;

  /// Block confirmation dialog: confirm button.
  ///
  /// In uz, this message translates to:
  /// **'Bloklash'**
  String get blockUstaConfirm;

  /// Snackbar after blocking a craftsman.
  ///
  /// In uz, this message translates to:
  /// **'Usta bloklandi'**
  String get blockUstaDone;

  /// Heading of the shops' furniture (3D models) section on the shop home and a shop's page.
  ///
  /// In uz, this message translates to:
  /// **'Mebel'**
  String get shopFurnitureSection;

  /// Furniture card/page when the shop set no price.
  ///
  /// In uz, this message translates to:
  /// **'Narxi kelishiladi'**
  String get shopFurnitureNoPrice;

  /// Row on a product page that opens the page of the shop selling it.
  ///
  /// In uz, this message translates to:
  /// **'{name} do\'koni'**
  String storePageOpen(String name);

  /// A shop's page could not load, or the shop is closed.
  ///
  /// In uz, this message translates to:
  /// **'Do\'konni ochib bo\'lmadi'**
  String get storeLoadFailed;

  /// Call button on a shop's page.
  ///
  /// In uz, this message translates to:
  /// **'Qo\'ng\'iroq'**
  String get storeCall;

  /// Telegram button on a shop's page.
  ///
  /// In uz, this message translates to:
  /// **'Telegram'**
  String get storeTelegram;

  /// A shop's page with no products.
  ///
  /// In uz, this message translates to:
  /// **'Bu do\'konda hozircha mahsulot yo\'q'**
  String get storeNoProducts;

  /// Menu item on a shop's page that reports the shop.
  ///
  /// In uz, this message translates to:
  /// **'Do\'kon haqida shikoyat'**
  String get storeReport;

  /// Label of the size row on a furniture page.
  ///
  /// In uz, this message translates to:
  /// **'O\'lchami'**
  String get furnitureSize;

  /// A furniture size, e.g. "220 × 90 × 80 cm".
  ///
  /// In uz, this message translates to:
  /// **'{size} sm'**
  String furnitureSizeValue(String size);

  /// Button that opens one of the user's rooms in the Studio with this furniture placed in it.
  ///
  /// In uz, this message translates to:
  /// **'Xonamga qo\'yish'**
  String get furniturePlaceInRoom;

  /// Title of the room picker before placing furniture.
  ///
  /// In uz, this message translates to:
  /// **'Qaysi xonaga qo\'yamiz?'**
  String get furniturePickRoom;

  /// Shown when the user has no room to place furniture in.
  ///
  /// In uz, this message translates to:
  /// **'Avval xona yarating yoki skanerlang'**
  String get furnitureNoRooms;

  /// Furniture page of a photo-only listing.
  ///
  /// In uz, this message translates to:
  /// **'Bu mahsulotning 3D modeli yo\'q, uni xonaga qo\'yib bo\'lmaydi'**
  String get furnitureNoModel;

  /// A furniture page could not load, or the item is off sale.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulotni ochib bo\'lmadi'**
  String get furnitureLoadFailed;

  /// Profile menu: opens the web furniture workshop (cabinet parts, cut lists, price) in a WebView. Same text as the web's profile.mebel.
  ///
  /// In uz, this message translates to:
  /// **'Mebel ishlab chiqarish'**
  String get profileMenuMebel;

  /// Profile menu: line under the furniture-workshop entry. Same text as the web's profile.mebel_izoh.
  ///
  /// In uz, this message translates to:
  /// **'Ustaxonalar uchun: shkaf detallari, kromka va narx'**
  String get profileMenuMebelHint;

  /// Furniture workshop: the PDF or CSV export could not be opened or shared.
  ///
  /// In uz, this message translates to:
  /// **'Faylni ochib bo\'lmadi'**
  String get mebelExportFailed;

  /// LiDAR scanner: hint at the bottom when the scan starts.
  ///
  /// In uz, this message translates to:
  /// **'Xonani sekin aylanib skanerlang'**
  String get scanHintStart;

  /// LiDAR scanner coaching: the phone is too far from the wall.
  ///
  /// In uz, this message translates to:
  /// **'Telefonni devorga yaqinroq tuting'**
  String get scanCoachMoveCloser;

  /// LiDAR scanner coaching: the phone is too close to the wall.
  ///
  /// In uz, this message translates to:
  /// **'Telefonni devordan birozroq uzoqlashtiring'**
  String get scanCoachMoveAway;

  /// LiDAR scanner coaching: the phone moves too fast.
  ///
  /// In uz, this message translates to:
  /// **'Juda tez harakatlanyapsiz — sekinroq aylaning'**
  String get scanCoachSlowDown;

  /// LiDAR scanner coaching: not enough light.
  ///
  /// In uz, this message translates to:
  /// **'Xona qorong\'i — yorug\'likni yoqing'**
  String get scanCoachTurnOnLight;

  /// LiDAR scanner coaching: the surface has too little texture to track.
  ///
  /// In uz, this message translates to:
  /// **'Bu yuza silliq/bir xil — kamerani boshqa tomonga burang'**
  String get scanCoachLowTexture;

  /// LiDAR scanner coaching: everything is fine, keep going.
  ///
  /// In uz, this message translates to:
  /// **'Zo\'r ketyapti — xonani shu tezlikda aylanib chiqing'**
  String get scanCoachGood;

  /// LiDAR scanner coaching: fallback for an instruction the app does not know.
  ///
  /// In uz, this message translates to:
  /// **'Skanerlashda davom eting'**
  String get scanCoachKeepGoing;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
