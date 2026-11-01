// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Uzbek (`uz`).
class AppLocalizationsUz extends AppLocalizations {
  AppLocalizationsUz([String locale = 'uz']) : super(locale);

  @override
  String get appTitle => 'Andoza AI';

  @override
  String get actionRetry => 'Qayta urinish';

  @override
  String get actionBack => 'Orqaga';

  @override
  String get actionNext => 'Keyingi';

  @override
  String get actionContinue => 'Davom etish';

  @override
  String get actionCancel => 'Bekor qilish';

  @override
  String get actionSave => 'Saqlash';

  @override
  String get actionClose => 'Yopish';

  @override
  String get actionDone => 'Tayyor';

  @override
  String get actionFinish => 'Yakunlash';

  @override
  String get navHome => 'Uy';

  @override
  String get navShop => 'Do\'kon';

  @override
  String get navMasters => 'Ustalar';

  @override
  String get navProfile => 'Profil';

  @override
  String get loginEmailHint => 'Email';

  @override
  String get loginPasswordHint => 'Parol';

  @override
  String get loginShowPassword => 'Parolni ko\'rsatish';

  @override
  String get loginHidePassword => 'Parolni yashirish';

  @override
  String get loginButton => 'Kirish';

  @override
  String get loginEmptyFields => 'Barcha maydonlarni to\'ldiring';

  @override
  String get b1Question => 'Xonangiz hozir qaysi holatda?';

  @override
  String get b1DontKnowDifference => 'Farqini bilmayapsizmi? →';

  @override
  String get b1FloorCeilingDifferent => 'Pol yoki shift boshqacha bo\'lsa →';

  @override
  String get b1EnterRoom => 'Xonaga kirish';

  @override
  String get brandName => 'AndozaAI';

  @override
  String get navAddProject => 'Yangi loyiha qo\'shish';

  @override
  String get loginPhoneLabel => 'Telefon raqam';

  @override
  String get loginPhoneSubtitle => 'Kirish uchun telefon raqamingizni kiriting';

  @override
  String get loginPhoneHint => '90 123 45 67';

  @override
  String get loginPhoneSmsHint => 'Sms kod shu raqamga yuboriladi';

  @override
  String get loginSendOtp => 'OTP Yuborish';

  @override
  String get loginOtpInfoBox =>
      'Siz kiritgan raqamga 6 xonali kod yuboriladi. Agar SMS kelmaydigan bo\'lsa, 2-3 minutdan keyin qayta urinib ko\'ring.';

  @override
  String get loginWithUsername => 'Login va parol bilan kirish';

  @override
  String get loginCodeSentTitle => '✓ Kod yuborildi';

  @override
  String get loginCodeSentSuffix => ' raqamiga 6 xonali kod yuboramiz';

  @override
  String get loginVerify => 'Tasdiqlash';

  @override
  String get loginResend => 'Qayta yuborish';

  @override
  String loginResendCountdown(int seconds) {
    return 'Qayta yuborish ($seconds s)';
  }

  @override
  String get loginBackArrow => '← Orqaga';

  @override
  String get loginSignIn => 'Kirish';

  @override
  String get loginUsernameHint => 'Login';

  @override
  String get loginPasswordLabel => 'Parol';

  @override
  String get loginNoAccount => 'Akkauntingiz yo\'qmi? ';

  @override
  String get loginRegister => 'Ro\'yxatdan o\'tish';

  @override
  String get loginNameHint => 'Ism (ixtiyoriy)';

  @override
  String get loginConfirmPasswordHint => 'Parolni tasdiqlang';

  @override
  String get loginHaveAccount => 'Allaqachon akkauntingiz bormi? ';

  @override
  String get loginWithGoogle => 'Google bilan kirish';

  @override
  String get loginGoogleFailed =>
      'Google orqali kirib bo\'lmadi. Qayta urinib ko\'ring.';

  @override
  String get loginOr => 'yoki';

  @override
  String get loginTagline => 'Ta\'mir va interyer loyihalaringiz bir joyda';

  @override
  String get loginVersion => 'AndozaAI v1.0.0';

  @override
  String get loginErrorInvalidPhone =>
      'Telefon raqam noto\'g\'ri. Masalan: 90 123 45 67';

  @override
  String get loginErrorServer => 'Serverda xatolik. Qayta urinib ko\'ring.';

  @override
  String get loginErrorInvalidCode => 'Kod noto\'g\'ri yoki eskirgan.';

  @override
  String get loginErrorCredentialsRequired => 'Login va parol majburiy.';

  @override
  String get loginErrorWrongCredentials => 'Login yoki parol noto\'g\'ri.';

  @override
  String get loginErrorUsernameShort =>
      'Login kamida 3 ta belgidan iborat bo\'lishi kerak.';

  @override
  String get loginErrorUsernameLong => 'Login 50 ta belgidan oshmasin.';

  @override
  String get loginErrorPasswordShort =>
      'Parol kamida 6 ta belgidan iborat bo\'lishi kerak.';

  @override
  String get loginErrorPasswordMismatch => 'Parollar mos kelmadi.';

  @override
  String get loginErrorUsernameTaken => 'Bu login allaqachon band.';

  @override
  String get loginErrorRegisterFailed =>
      'Ro\'yxatdan o\'tishda xato yuz berdi.';

  @override
  String get homeWelcome => 'Xush kelibsiz';

  @override
  String homeGreetingNamed(String name) {
    return 'Salom, $name! 👋';
  }

  @override
  String get homeGreeting => 'Salom! 👋';

  @override
  String get homeStoryHowItWorks => 'Qanday ishlaydi?';

  @override
  String get homeStoryDemoGuide => 'Demo qo\'llanma';

  @override
  String get homeStoryDemo => 'Demo';

  @override
  String get homeEmptyTitle => 'Birinchi xonangizni qo\'shing';

  @override
  String get homeEmptyMessage => 'Hali loyiha yo\'q — yangi loyiha boshlang';

  @override
  String get homeEmptyAction => '+ Loyiha qo\'shish';

  @override
  String get homeQuickActions => 'Tezkor amallar';

  @override
  String get homeQuickScan => 'Xonani skanlash';

  @override
  String get homeQuickEstimate => 'Smeta';

  @override
  String get homeQuickDealers => 'Dilerlar';

  @override
  String get homeProjectsLoadError => 'Loyihalarni yuklab bo\'lmadi';

  @override
  String get homeLoadMore => 'Yana ko\'rsatish';

  @override
  String get homeLegendExisting => 'Mavjud (hisoblanmaydi)';

  @override
  String get homeLegendNeeded => 'Kerak (delta)';

  @override
  String get homeResume => 'Davom etish';

  @override
  String get homeNoRoomYet => 'Bu loyihada hali xona yo\'q';

  @override
  String homeStageProgress(int current) {
    return 'Bosqich $current/8';
  }

  @override
  String homeStageProgressExcluded(int current, String names) {
    return 'Bosqich $current/8 · ✓ $names mavjud edi';
  }

  @override
  String homeStageProgressExcludedCount(int current, int count) {
    return 'Bosqich $current/8 · ✓ $count bosqich mavjud edi';
  }

  @override
  String get homeStagePickerTitle => 'Bosqichni tanlang';

  @override
  String homeStageOption(int index, String label) {
    return 'Bosqich $index/8 · $label';
  }

  @override
  String get homeStageSaveError => 'Bosqichni saqlab bo\'lmadi';

  @override
  String homeRoomCount(int count) {
    return '$count xona';
  }

  @override
  String get homeStatAreaLabel => 'Maydon';

  @override
  String get homeStatModelsLabel => '3D model';

  @override
  String get homeStatEstimateLabel => 'Smeta';

  @override
  String homeAreaValue(String area) {
    return '$area m²';
  }

  @override
  String homeEstimateMln(String amount) {
    return '$amount mln';
  }

  @override
  String get homeStatDash => '—';

  @override
  String get stageSuvoq => 'suvoq';

  @override
  String get stageShpaklovka => 'shpaklovka';

  @override
  String get stageBoyoqOboi => 'bo\'yoq/oboi';

  @override
  String get stagePol => 'pol';

  @override
  String get stageMebel => 'mebel';

  @override
  String get stageElektr => 'elektr';

  @override
  String get stageYoruglik => 'yorug\'lik';

  @override
  String get stageSantexnika => 'santexnika';

  @override
  String get commonYes => 'Ha';

  @override
  String get commonNo => 'Yo\'q';

  @override
  String get shopCartTooltip => 'Savatcha';

  @override
  String get shopSearchHint => 'Material qidirish...';

  @override
  String get shopFilterAll => 'Barchasi';

  @override
  String get shopInProjectTag => 'Loyihada';

  @override
  String get shopMaterialsTitle => 'Loyiha materiallari';

  @override
  String shopMaterialsAutoCalc(String area, int count) {
    return 'App loyihangiz asosida avtomatik hisobladi — $area m², $count bosqich';
  }

  @override
  String get shopAddAllToCart => 'Tanlanganlarni savatga';

  @override
  String get shopSelectRoomLabel => 'Qaysi xona uchun?';

  @override
  String shopSelectedCount(int count) {
    return '$count ta tanlandi';
  }

  @override
  String get shopOfficialDealer => '✓ Rasmiy diler';

  @override
  String shopProjectNeed(String quantity, String unit) {
    return 'Loyihangiz uchun ~$quantity $unit kerak';
  }

  @override
  String get shopQuantityLabel => 'Miqdor:';

  @override
  String get shopSpecCoverage => 'Qoplama';

  @override
  String get shopSpecDryingTime => 'Quriish vaqti';

  @override
  String get shopSpecWashable => 'Yuvilishi';

  @override
  String shopWhereToBuy(String name) {
    return 'Qayerdan olish — $name';
  }

  @override
  String shopPriceFromDealer(String dealer) {
    return '$dealer narxi';
  }

  @override
  String get shopAddedToCart => 'Savatga qo\'shildi';

  @override
  String shopAddToCartPrice(String price) {
    return 'Savatga qo\'shish · $price';
  }

  @override
  String get shopDealerCompareTitle => 'Diler taqqoslash';

  @override
  String get shopFilterCheapest => 'Eng arzon';

  @override
  String get shopFilterOfficial => 'Rasmiy diler';

  @override
  String get shopFilterFastest => 'Eng tez';

  @override
  String get shopBestRibbon => 'ENG YAXSHI';

  @override
  String shopDeliveryDays(String district, int days) {
    return '$district · $days kunda yetkazish';
  }

  @override
  String get shopSelect => 'Tanlash';

  @override
  String get shopCartTitle => 'Savat';

  @override
  String get shopCartEmpty => 'Savat bo\'sh';

  @override
  String get shopMaterials => 'Materiallar';

  @override
  String get shopDelivery => 'Yetkazish';

  @override
  String get shopGrandTotal => 'Umumiy summa';

  @override
  String get shopCheckout => 'Buyurtmani rasmiylashtirish';

  @override
  String get shopCheckoutTitle => 'To\'lov';

  @override
  String get shopDeliveryAddress => 'Yetkazish manzili';

  @override
  String get shopAddressHint => 'Manzil';

  @override
  String get shopPhoneHint => 'Telefon raqami';

  @override
  String get shopPaymentMethod => 'To\'lov usuli';

  @override
  String get shopOrderSummary => 'Buyurtma xulosasi';

  @override
  String get shopAmountDue => 'To\'lanadi';

  @override
  String get shopPay => 'To\'lash';

  @override
  String shopOrderSaveError(String error) {
    return 'Buyurtmani serverga saqlashda xatolik: $error';
  }

  @override
  String get shopOrderStatusTitle => 'Buyurtma holati';

  @override
  String get shopOrderContents => 'Buyurtma tarkibi';

  @override
  String get shopTotal => 'Jami';

  @override
  String get shopMasterNotified => 'Usta xabardor qilindi';

  @override
  String get shopHandToMaster => 'Ustaga topshirish';

  @override
  String get shopBackToShop => 'Do\'konga qaytish';

  @override
  String get mastersNotFound => 'Usta topilmadi';

  @override
  String get unsavedChangesTitle => 'Saqlanmagan o\'zgarishlar';

  @override
  String get unsavedChangesBody => 'Chiqsangiz, kiritganlaringiz yo\'qoladi.';

  @override
  String get unsavedChangesLeave => 'Chiqish';

  @override
  String get unsavedChangesStay => 'Qolish';

  @override
  String get roomSaveFailed =>
      'Xona serverga saqlanmadi. Internetni tekshirib, qayta urinib ko\'ring.';

  @override
  String get newProjectArScanTitle => 'Kamera bilan o\'lchash';

  @override
  String get newProjectArScanDesc =>
      'Telefon kamerasi bilan pol burchaklarini belgilab, xona rejasini oling';

  @override
  String get arScanFindFloor => 'Telefonni polga qaratib sekin aylantiring';

  @override
  String get arScanCornersHint =>
      'Nishonni pol burchagiga keltirib, burchak qo\'shing';

  @override
  String get arScanAddCorner => 'Burchak qo\'shish';

  @override
  String get arScanUndo => 'Bekor qilish';

  @override
  String get arScanFinish => 'Tayyor';

  @override
  String get arScanSnapToFirst =>
      'Birinchi burchakka yaqinlashing — kontur yopiladi';

  @override
  String get arScanAimCeiling =>
      'Birinchi burchak ustidagi shift chizig\'iga qarating';

  @override
  String get arScanConfirm => 'Tasdiqlash';

  @override
  String get arScanEnterManually => 'Qo\'lda kiritish';

  @override
  String get arScanExit => 'Chiqish';

  @override
  String get arScanExitConfirm =>
      'O\'lchovni to\'xtatasizmi? Belgilangan burchaklar yo\'qoladi.';

  @override
  String get arScanTrackingLost =>
      'Yorug\'lik kam yoki telefon tez harakatlandi';

  @override
  String get arScanFloorHint =>
      'Yorug\'roq joyda, gilam yoki naqshli polga qarating';

  @override
  String get arScanCornersLost =>
      'Ba\'zi burchaklar yo\'qoldi — ularni qayta belgilang';

  @override
  String get arScanNoFloorHere => 'Avval polni skaner qiling';

  @override
  String get arScanKeepMeasuring => 'O\'lchashni davom ettirish';

  @override
  String get arScanStepFloor => '1/3 — pol';

  @override
  String get arScanStepCorners => '2/3 — burchaklar';

  @override
  String get arScanStepHeight => '3/3 — balandlik';

  @override
  String get arScanRescan => 'Qayta o\'lchash';

  @override
  String get arScanNotInstalled =>
      'Kamera bilan o\'lchash uchun \"Google Play Services for AR\" kerak';

  @override
  String get arScanInstall => 'O\'rnatish';

  @override
  String get arScanCameraDenied =>
      'Xonani o\'lchash uchun kameraga ruxsat bering';

  @override
  String get arScanOpenSettings => 'Sozlamalarni ochish';

  @override
  String get arScanUnsupported =>
      'Bu telefonda kamera bilan o\'lchab bo\'lmaydi. Xonani chizib yoki o\'lchamlarini kiritib qo\'shing.';

  @override
  String get arScanFailed => 'O\'lchab bo\'lmadi. Qayta urinib ko\'ring.';

  @override
  String get arScanRejected_too_few_corners => 'Kamida 3 ta burchak kerak';

  @override
  String get arScanRejected_self_intersecting =>
      'Devorlar bir-birini kesib o\'tdi — burchaklarni tartib bilan belgilang';

  @override
  String get arScanRejected_wall_too_long =>
      'Bitta devor 30 m dan uzun chiqdi — burchak noto\'g\'ri joyga tushgan';

  @override
  String get scanReviewArcoreAccuracy =>
      'Kamera o\'lchovi: ±3–5% xato bo\'lishi mumkin, muhim devorlarni ruletka bilan tekshiring';

  @override
  String get shopNoResults => 'Hech narsa topilmadi';

  @override
  String get shopSearchResultsTitle => 'Qidiruv natijalari';

  @override
  String get shopFilterForProject => 'Loyihamga mos';

  @override
  String get shopFilterRating => 'Reyting';

  @override
  String shopResultCount(int count) {
    return '$count ta natija';
  }

  @override
  String get commonVerifiedBadge => '✓ Tasdiqlangan';

  @override
  String get mastersSearchHint => 'Qanday usta kerak?';

  @override
  String mastersRatingReviews(String rating, int count) {
    return '$rating ($count sharh)';
  }

  @override
  String mastersAreaDistance(String area, String distance) {
    return '$area · ~$distance km';
  }

  @override
  String get mastersViewProfile => 'Profilni ko\'rish';

  @override
  String get mastersStatRating => 'reyting';

  @override
  String get mastersStatReviews => 'sharh';

  @override
  String get mastersStatJobs => 'ishlar';

  @override
  String get mastersPortfolio => 'Portfolio';

  @override
  String get mastersPortfolioEmpty => 'Hali portfolio surat qo\'shilmagan';

  @override
  String get mastersServices => 'Xizmatlar';

  @override
  String mastersServiceTrade(String trade) {
    return '$trade ishlari';
  }

  @override
  String get mastersServiceConsultation => 'Konsultatsiya';

  @override
  String get mastersLocation => 'Joylashuv';

  @override
  String get mastersSendEstimate => 'Smetani yuborish';

  @override
  String get mastersSendMessage => 'Xabar yozish';

  @override
  String mastersSendConfirmTitle(String name) {
    return 'Loyihangizni $name akaga yuborasizmi?';
  }

  @override
  String get mastersProjectSummaryTitle => 'Mehmonxona ta\'miri';

  @override
  String mastersProjectSummaryValue(String area, String price) {
    return '$area m² · $price';
  }

  @override
  String get mastersCommentHint => 'Izoh (ixtiyoriy)';

  @override
  String get phoneErrorInvalid =>
      'Telefon raqami noto\'g\'ri. Masalan: +998 90 123 45 67';

  @override
  String get mastersPhoneLabel => 'Telefon raqamingiz';

  @override
  String get mastersEstimateNote =>
      'Usta smetani ko\'rib, o\'z narxini taklif qiladi';

  @override
  String get mastersEstimateSent => 'Smeta yuborildi';

  @override
  String get mastersSend => 'Yuborish';

  @override
  String get profileDefaultName => 'Foydalanuvchi';

  @override
  String get profileComingSoon => 'Tez kunda';

  @override
  String get profileStatProjects => 'loyiha';

  @override
  String get profileStatOrders => 'buyurtma';

  @override
  String get profileStatSaved => 'tejaldi';

  @override
  String profileSavedMln(String amount) {
    return '$amount mln';
  }

  @override
  String get profileMenuProjects => 'Loyihalarim';

  @override
  String get profileMenuOrders => 'Buyurtmalarim';

  @override
  String get profileMenuSavedDesigns => 'Saqlangan dizaynlar';

  @override
  String get profileMenuAddresses => 'Manzillarim';

  @override
  String get profileMenuPaymentMethods => 'To\'lov usullari';

  @override
  String get profileMenuLanguage => 'Til';

  @override
  String get profileMenuSettings => 'Sozlamalar';

  @override
  String get profileMenuHelp => 'Yordam';

  @override
  String get profileMenuLogout => 'Chiqish';

  @override
  String get profileLanguageUzbek => 'O\'zbekcha';

  @override
  String get profileFilterOngoing => 'Davom etayotgan';

  @override
  String get profileFilterFinished => 'Tugagan';

  @override
  String get profileProjectsEmptyTitle => 'Hali loyiha yo\'q';

  @override
  String get profileProjectsEmptyMessage => 'Birinchi loyihangizni boshlang';

  @override
  String get profileProjectsEmptyAction => '+ Yangi loyiha';

  @override
  String profileProjectMeta(int count, String details) {
    return '$count xona · $details';
  }

  @override
  String get profileOrdersEmptyTitle => 'Buyurtma yo\'q';

  @override
  String get profileOrdersEmptyMessage =>
      'Do\'kondan xarid qilganingizda shu yerda ko\'rinadi';

  @override
  String get orderStepAccepted => 'Qabul qilindi';

  @override
  String get orderStepGathering => 'Yig\'ilmoqda';

  @override
  String get orderStepOnTheWay => 'Yo\'lda';

  @override
  String get orderStepDelivered => 'Yetkazildi';

  @override
  String get profileSavedDesignsEmptyTitle => 'Saqlangan dizayn yo\'q';

  @override
  String get profileSavedDesignsEmptyMessage =>
      'Yoqqan dizaynlaringizni shu yerda saqlab qo\'ying';

  @override
  String get onboardingSkip => 'O\'tkazib yuborish';

  @override
  String get onboardingStart => 'Boshlash';

  @override
  String get onboardingMeasureTitle => 'Xonangizni o\'lchang';

  @override
  String get onboardingMeasureBody =>
      'Telefon kamerasi yoki LiDAR yordamida xonangiz o\'lchamlarini aniq oling.';

  @override
  String get onboardingDeltaTitle => 'Hozirgi holatdan boshlaymiz';

  @override
  String get onboardingDeltaBody =>
      'Xonangizda allaqachon bor narsalar uchun to\'lamaysiz — faqat kerakli qismini hisoblaymiz.';

  @override
  String get onboardingDeltaCurrent => 'Hozirgi';

  @override
  String get onboardingDeltaPill => 'faqat FARQ hisoblanadi';

  @override
  String get onboardingDecorateTitle => '3D\'da bezang';

  @override
  String get onboardingDecorateBody =>
      'Materiallarni to\'g\'ridan-to\'g\'ri xonaning 3D ko\'rinishiga sudrab, natijani darhol ko\'ring.';

  @override
  String get onboardingPriceTitle => 'Narxni ko\'ring, materialni oling';

  @override
  String get onboardingPriceBody =>
      'Aniq smeta oling va kerakli materiallarni to\'g\'ridan-to\'g\'ri ilovadan xarid qiling.';

  @override
  String get onboardingPriceSaved => 'Tejaldingiz 4.2 mln';

  @override
  String get onboardingDemoTitle => 'Demo qo\'llanma';

  @override
  String get onboardingDemoStep1 =>
      'Xona qo\'shish — LiDAR, 360° yoki qo\'lda o\'lchash';

  @override
  String get onboardingDemoStep2 => 'Xonaning hozirgi holatini tanlash';

  @override
  String get onboardingDemoStep3 => 'Rail bilan devor, pol va mebelni bezash';

  @override
  String get onboardingDemoStep4 =>
      'Elektr va santexnikani oxirida rejalashtirish';

  @override
  String get onboardingDemoStep5 =>
      'Smetani ko\'rish va materiallarni sotib olish';

  @override
  String get onboardingDemoWatchVideo => 'Videoni ko\'rish';

  @override
  String get onboardingDemoTryMyself => 'O\'zim sinab ko\'raman';

  @override
  String get commonBackTo3d => '3D\'ga qaytish';

  @override
  String get designSurfaceFloorHeading => 'Pol';

  @override
  String get designSurfaceCeilingHeading => 'Shift';

  @override
  String get designFloorRaw => 'Xom beton';

  @override
  String get designFloorPlastered => 'Styajka';

  @override
  String get designFloorPuttied => 'Qoplama bor';

  @override
  String get designCeilingRaw => 'Xom';

  @override
  String get designCeilingPlastered => 'Suvoq';

  @override
  String get designCeilingPuttied => 'Tayyor';

  @override
  String designRoomEntryIntro(String condition) {
    return 'Xonangiz shu holatda — $condition. Endi bosqichma-bosqich bezaymiz.';
  }

  @override
  String get designConditionRaw => 'korobka holatida';

  @override
  String get designConditionPlastered => 'suvoq qilingan';

  @override
  String get designConditionPuttied => 'shpaklovka qilingan';

  @override
  String get designToastShpaklovkaAdded => '✓ Shpaklovka qo\'shildi';

  @override
  String get designStageBoyoqOboi => 'Bo\'yoq/Oboi bosqichi';

  @override
  String get designRailTabBoyoq => 'Bo\'yoq';

  @override
  String get designDragHint => 'Materialni barmog\'ingiz bilan devorga sudrang';

  @override
  String get designNextStage => 'Keyingi bosqich →';

  @override
  String get interiorToastFloorApplied => '✓ Polga qo\'llanildi';

  @override
  String get interiorStagePol => 'Pol bosqichi';

  @override
  String get interiorRailTabKafel => 'Kafel';

  @override
  String get interiorRailTabLaminat => 'Laminat';

  @override
  String get interiorRailTabParket => 'Parket';

  @override
  String get interiorRailTabBeton => 'Beton';

  @override
  String get interiorStageMebel => 'Mebel bosqichi';

  @override
  String get interiorRailTabMehmonxona => 'Mehmonxona';

  @override
  String get interiorRailTabOshxona => 'Oshxona';

  @override
  String get interiorRailTabYotoqxona => 'Yotoqxona';

  @override
  String get interiorRailTabVanna => 'Vanna';

  @override
  String get interiorWalkthroughHint =>
      'Polda yurish mumkin — barmoq bilan suring';

  @override
  String get interiorGoToPlan => 'Rejaga o\'tish →';

  @override
  String get interiorDecorationComplete => 'Bezash yakunlandi';

  @override
  String get interiorGoToElectrical => 'Elektrga o\'tish →';

  @override
  String get interiorWallpaperAdded => '✓ Oboy kutubxonaga qo\'shildi';

  @override
  String interiorUploadFailed(String error) {
    return 'Yuklab bo\'lmadi: $error';
  }

  @override
  String get interiorWallpaperLibrary => 'Oboy kutubxonasi';

  @override
  String get interiorUploading => 'Yuklanmoqda…';

  @override
  String get interiorUploadImage => 'Rasm yuklash';

  @override
  String get interiorNoWallpapers =>
      'Hali oboy yo\'q — birinchi bo\'lib rasm yuklang';

  @override
  String get electricalWireRouting => 'Sim yo\'nalishi';

  @override
  String get electricalView2d => '2D reja';

  @override
  String get electricalView3d => '3D';

  @override
  String get electricalViewBoth => 'Ikkalasi';

  @override
  String get electricalRecomputeRoute => 'Trassani qayta hisoblash';

  @override
  String get electricalNext => 'Keyingi →';

  @override
  String get electricalResult => 'Elektr natijasi';

  @override
  String get electricalFinish => 'Yakunlash →';

  @override
  String get electricalProjectReady => 'Loyihangiz tayyor';

  @override
  String get electricalViewEstimate => 'Smetani ko\'rish →';

  @override
  String get estimateTitlePrefix => 'Remont smetasi';

  @override
  String get estimateDefaultRoomName => 'Mehmonxona';

  @override
  String estimatePdfFailed(String error) {
    return 'PDF yuklab bo\'lmadi: $error';
  }

  @override
  String get estimateSomeWork => 'Ba\'zi ishlar';

  @override
  String get estimateStageFallback => 'Bosqich';

  @override
  String get estimateFloorUnpriced =>
      'Pol turi tanlangan, lekin mahsulot tanlanmagan — pol smetaga kirmadi.';

  @override
  String get estimateFloorPick => 'Polni tanlash';

  @override
  String get estimateAdjust => 'Smeta sozlash';

  @override
  String get estimateApproxTotal => 'Taxminiy umumiy narx';

  @override
  String get estimateLabor => 'Ishchi kuchi';

  @override
  String estimateSavingsBanner(String label, String amount) {
    return '$label allaqachon bor edi — $amount tejaldingiz';
  }

  @override
  String get estimateExcludedNote => 'sizda mavjud — hisoblanmadi';

  @override
  String get estimateZeroSom => '0 so\'m';

  @override
  String get estimatePreparingPdf => 'Tayyorlanmoqda…';

  @override
  String get estimateBuyFromShops => 'Do\'konlardan xarid qilish';

  @override
  String get estimateSendToMaster => 'Ustaga yuborish';

  @override
  String get estimateMaterialsTotal => 'Materiallar jami';

  @override
  String get estimateStageTotal => 'Bosqich jami';

  @override
  String get estimateAddMaterialsToCart => 'Materiallarni savatga';

  @override
  String get estimateQualityLevel => 'Sifat darajasi';

  @override
  String get estimateExcludeLabor => 'Ishchi kuchini qo\'shmaslik';

  @override
  String get estimateDiySubtitle =>
      'O\'zim bajaraman — faqat materiallar hisoblanadi';

  @override
  String estimateDeltaSavings(String stage) {
    return 'Delta tejash ($stage)';
  }

  @override
  String get estimateNewTotal => 'Yangi jami';

  @override
  String get estimateSaveEstimate => 'Smetani saqlash';

  @override
  String get studioAiDesignerInStudio => 'AI dizayner (3D Studio)';

  @override
  String get studioAiDesigner => 'AI dizayner';

  @override
  String get studioAiApplied => '✓ AI o\'zgarishlari qo\'llanildi';

  @override
  String studioApplyFailed(String error) {
    return 'Qo\'llab bo\'lmadi: $error';
  }

  @override
  String get studioAiHint =>
      'Masalan: \"Devorlarni iliq bej rangga bo\'ya va divan qo\'sh\"';

  @override
  String get studioAiStyleLabel => 'Uslub (ixtiyoriy)';

  @override
  String get studioGenerating => 'Ishlanmoqda…';

  @override
  String get studioGenerate => 'Yaratish';

  @override
  String studioActionLabel(String name) {
    return 'Amal: $name';
  }

  @override
  String studioDoneLabel(String name) {
    return 'Bajarildi: $name';
  }

  @override
  String studioAiNoResponse(String message) {
    return 'AI hozircha javob berolmadi.\n$message';
  }

  @override
  String studioChangeCeiling(String height) {
    return 'Shift balandligi: $height m';
  }

  @override
  String studioChangeSurfaces(int count) {
    return '$count ta yuza materiali';
  }

  @override
  String studioChangeWalls(int count) {
    return '$count ta devor o\'lchami';
  }

  @override
  String studioChangeFurniture(int count) {
    return '$count ta mebel';
  }

  @override
  String studioChangeLights(int count) {
    return '$count ta chiroq';
  }

  @override
  String get studioApply => 'Qo\'llash';

  @override
  String get studioLoginRequired => 'Studio ochish uchun tizimga kiring.';

  @override
  String studioLoadFailed(String error) {
    return 'Studio yuklanmadi: $error';
  }

  @override
  String get studioWebViewTitle => '3D Studio';

  @override
  String get actionAdd => 'Qo\'shish';

  @override
  String get actionPrev => 'Ortga';

  @override
  String get actionOk => 'OK';

  @override
  String get actionCancelShort => 'Bekor';

  @override
  String get roomDefaultName => 'Xona';

  @override
  String get ceilingHeightLabel => 'Shift balandligi';

  @override
  String get measureLength => 'Uzunlik';

  @override
  String get furnitureDelete => 'O\'chirish';

  @override
  String get furnitureRotate => 'Aylantirish';

  @override
  String get electricalTotalsTitle => 'Elektr hisoblandi';

  @override
  String get electricalTotalsWireLabel => 'jami sim';

  @override
  String get electricalTotalsDeviceLabel => 'ta qurilma';

  @override
  String electricalTotalsSocketWires(String meters) {
    return 'Rozetka simlari $meters m';
  }

  @override
  String electricalTotalsSwitchWires(String meters) {
    return 'Kalit simlari $meters m';
  }

  @override
  String electricalTotalsSwitchLightSummary(int switches, int lights) {
    return '$switches kalit · $lights yoritish';
  }

  @override
  String get electricalTotalsColDevice => 'Qurilma';

  @override
  String get electricalTotalsColWall => 'Devor';

  @override
  String get electricalTotalsColHeight => 'Balandlik';

  @override
  String get dimensionsTitle => 'Xona o\'lchamlari';

  @override
  String get dimensionsTabManual => 'Qo\'lda kiritish';

  @override
  String get dimensionsTabUpload => 'Plan yuklash';

  @override
  String dimensionsTotalSummary(int count, String area) {
    return 'Jami: $count xona · $area m²';
  }

  @override
  String get dimensionsNextMeasure => 'Keyingi: devorlarni o\'lchash';

  @override
  String get dimensionsConvert3d => '3D ga aylantirish';

  @override
  String get dimensionsAddRoom => '+ Xona qo\'shish';

  @override
  String dimensionsRoomDefaultName(int number) {
    return 'Xona $number';
  }

  @override
  String get dimensionsRoomNameLabel => 'Xona nomi';

  @override
  String get dimensionsLengthLabel => 'Uzunlik (m)';

  @override
  String get dimensionsWidthLabel => 'Kenglik (m)';

  @override
  String get dimensionsHeightLabel => 'Balandlik (m)';

  @override
  String get dimensionsUploadTitle => 'Floorplan rasmini yuklang';

  @override
  String get dimensionsUploadHint =>
      'PNG yoki JPG · maksimal 10 MB\nYoki bu yerga sudrab tashlang';

  @override
  String get dimensionsChooseFile => 'Fayl tanlash';

  @override
  String get dimensionsUploadNote =>
      'Aniq natija uchun o\'lchamlar ko\'rsatilgan plan yuklang';

  @override
  String get openingAddTitle => 'Eshik/Deraza qo\'shish';

  @override
  String get openingAddSpaced => 'Eshik / Deraza qo\'shish';

  @override
  String get openingTypeDoor => 'Eshik';

  @override
  String get openingTypeWindow => 'Deraza';

  @override
  String get openingTypeBalcony => 'Balkon eshigi';

  @override
  String get openingSizeLabel => 'O\'lcham (sm)';

  @override
  String get openingSizeOther => 'Boshqa o\'lcham…';

  @override
  String get openingPositionLabel => 'Devor bo\'ylab joylashuvi';

  @override
  String get openingAddToWall => 'Devorga qo\'shish';

  @override
  String get newProjectTitle => 'Yangi loyiha';

  @override
  String get newProjectSubtitle => 'Xonani qanday qo\'shmoqchisiz?';

  @override
  String get newProjectWizardTitle => '3D Master';

  @override
  String get newProjectWizardDesc =>
      'Interaktiv 3D ko\'rinishda xona o\'lchamlarini kiriting';

  @override
  String get newProjectLidarTitle => 'LiDAR skaner';

  @override
  String get newProjectLidarDesc =>
      'Xonani LiDAR yordamida skanerlang va avtomatik 3D model oling';

  @override
  String get newProjectPhotoTitle => '360° Foto skan';

  @override
  String get newProjectPhotoDesc =>
      'Xonani 360° rasmga oling — ilova nuqtalarni o\'zi belgilaydi';

  @override
  String get newProjectDrawTitle => 'O\'zingiz chizing';

  @override
  String get newProjectDrawDesc =>
      'Xonani barmog\'ingiz bilan chizing — o\'lchamlar chizganingizga qarab o\'zi hisoblanadi';

  @override
  String get summarySavedTitle => 'O\'lchamlar saqlandi!';

  @override
  String get summaryStatFloor => 'pol';

  @override
  String get summaryStatWallNet => 'devor (netto)';

  @override
  String get summaryStatPerimeter => 'perimetr';

  @override
  String get summaryStatOpenings => 'eshik/deraza';

  @override
  String summaryOpeningsCount(int count) {
    return '$count ta';
  }

  @override
  String get summaryOpeningsNote =>
      'Eshik/derazalar avtomatik ayirilgan (netto)';

  @override
  String get summaryAddRoom => '+ Yangi xona qo\'shish';

  @override
  String get roomSetupDefaultProjectName => 'Mehmonxona ta\'miri';

  @override
  String get roomSetupWallLabelA => 'Devor A';

  @override
  String get roomSetupWallLabelB => 'Devor B';

  @override
  String get roomSetupWallLabelC => 'Devor C';

  @override
  String get roomSetupWallLabelD => 'Devor D';

  @override
  String get roomSetupWallLabelFallback => 'Devor';

  @override
  String get wizardTitle => 'Yangi xona';

  @override
  String get wizardCeilingQuestion => 'Shiftning balandligi?';

  @override
  String get wizardCeilingHint => 'Odatda 2.5–3.2 metr oralig\'ida';

  @override
  String get wizardExactValue => 'Aniq qiymat (m)';

  @override
  String wizardCeilingOutOfRange(String min, String max) {
    return 'Shift balandligi $min m dan $max m gacha bo\'lishi kerak';
  }

  @override
  String wizardWallTitle(String letter) {
    return '$letter devor';
  }

  @override
  String get wizardWallSubtitle => 'Uzunligini kiriting';

  @override
  String get wizardSummaryTitle => 'O\'lchamlar tayyor';

  @override
  String get wizardSummarySubtitle =>
      'Smeta yoki bezashni tanlang — xona shunda saqlanadi';

  @override
  String get wizardStatFloor => 'POL MAYDONI';

  @override
  String get wizardStatWallNet => 'DEVOR MAYDONI (NETTO)';

  @override
  String get wizardStatPerimeter => 'PERIMETR';

  @override
  String get wizardStatOpenings => 'ESHIK/DERAZALAR';

  @override
  String get wizardViewSmeta => 'Smeta ko\'rish';

  @override
  String get wizardOpening => 'Ochilmoqda…';

  @override
  String get wizardStartDesign => 'Bezashni boshlash';

  @override
  String get measureOpenings => 'Eshik / derazalar';

  @override
  String measureFromLeft(String offset) {
    return 'Chapdan $offset m';
  }

  @override
  String get lidarScanning => 'Skanerlanyapti...';

  @override
  String get lidarMoveHint => 'Telefonni sekin harakatlantiring';

  @override
  String get lidarLabelWall => 'devor';

  @override
  String get lidarLabelDoor => 'eshik';

  @override
  String get lidarLabelWindow => 'deraza';

  @override
  String photoPointsCount(int captured, int total) {
    return '$captured/$total nuqta';
  }

  @override
  String get photoTurnHint => 'Telefonni keyingi nuqtaga burang';

  @override
  String get photoCapture => 'Suratga olish';

  @override
  String get scanReviewTitle => 'Skan natijasi';

  @override
  String scanReviewDetected(String value) {
    return 'Aniqlangan: $value';
  }

  @override
  String scanReviewWalls(int count) {
    return 'Devorlar ($count)';
  }

  @override
  String scanReviewWall(int number) {
    return 'Devor $number';
  }

  @override
  String scanReviewObjects(int count) {
    return 'Topilgan buyumlar ($count)';
  }

  @override
  String get scanReviewNoObjects => 'Buyum topilmadi';

  @override
  String scanReviewObjectsDetectedNotice(int count) {
    return '$count ta buyum aniqlandi — Studio\'da \"Skan ko\'rinishi\"da ko\'rasiz';
  }

  @override
  String get scanReviewRescan => 'Qayta skanerlash';

  @override
  String get scanReviewSummaryTitle => 'Nimalar aniqlandi';

  @override
  String get scanReviewSummaryWalls => 'Devor';

  @override
  String get scanReviewSummaryDoors => 'Eshik';

  @override
  String get scanReviewSummaryWindows => 'Deraza';

  @override
  String get scanReviewSummaryObjects => 'Buyum';

  @override
  String scanReviewSummaryLowConfidence(int count) {
    return '$count ta element past aniqlikda o\'lchandi — o\'lchamlarni tekshiring.';
  }

  @override
  String get scanReviewSummaryNoOpenings =>
      'Eshik yoki deraza topilmadi. Shisha va ochiq eshiklar ko\'pincha aniqlanmaydi.';

  @override
  String get scanReviewSummaryRescanHint =>
      'Yaqinroqdan, sekinroq qayta skanerlang.';

  @override
  String get scanReviewSaveFailed =>
      'Xonani saqlab bo\'lmadi. Internetni tekshiring.';

  @override
  String scanReviewUploadFailed(String error) {
    return 'Skan fayllari yuklanmadi: $error Xona saqlandi, keyinroq qayta skanerlashingiz mumkin.';
  }

  @override
  String scanReviewThumbnailFailed(String error) {
    return 'Xona ko\'rinishi yuklanmadi: $error Loyiha kartasi rasmsiz ko\'rinadi.';
  }

  @override
  String scanReviewError(String error) {
    return 'Xatolik: $error';
  }

  @override
  String scanReviewCeilingHeightValue(String h) {
    return '$h m';
  }

  @override
  String get pendingScanTitle => 'Tugallanmagan skan topildi';

  @override
  String get pendingScanBody =>
      'Siz oldin xonani skanerlagansiz, lekin \"Davom etish\"ni bosmasdan chiqib ketgansiz. Davom ettiramizmi?';

  @override
  String get pendingScanResume => 'Davom etish';

  @override
  String get pendingScanDiscard => 'Bekor qilish';

  @override
  String get scanCategoryTable => 'Stol';

  @override
  String get scanCategoryChair => 'Stul';

  @override
  String get scanCategorySofa => 'Divan';

  @override
  String get scanCategoryBed => 'Karavot';

  @override
  String get scanCategoryStorage => 'Shkaf';

  @override
  String get scanCategoryRefrigerator => 'Muzlatgich';

  @override
  String get scanCategoryStove => 'Plita';

  @override
  String get scanCategorySink => 'Rakovina';

  @override
  String get scanCategoryToilet => 'Unitaz';

  @override
  String get scanCategoryBathtub => 'Vanna';

  @override
  String get scanCategoryWasher => 'Kir yuvish mashinasi';

  @override
  String get scanCategoryTelevision => 'Televizor';

  @override
  String get scanCategoryFireplace => 'Kamin';

  @override
  String get scanCategoryStairs => 'Zina';

  @override
  String get scanCategoryOther => 'Boshqa';

  @override
  String get scanBusy => 'Skaner allaqachon ishlayapti.';

  @override
  String get scanFailedRetry => 'Skanerlashda xatolik. Qayta urinib ko\'ring.';

  @override
  String scanErrorPrefixed(String message) {
    return 'Xatolik: $message';
  }

  @override
  String get scanNotDetected => 'Xona aniqlanmadi. Qayta urinib ko\'ring.';

  @override
  String get scanLidarUnavailableTitle => 'LiDAR mavjud emas';

  @override
  String get scanLidarUnavailableBody =>
      'LiDAR skaner faqat LiDAR\'li qurilmalarda ishlaydi: iPhone Pro (12 Pro va undan yangilari) yoki iPad Pro. Xonani boshqa usulda qo\'shing:';

  @override
  String get scanInProgress => 'Xona skanerlanmoqda…';

  @override
  String get drawTitle => 'Xonani chizing';

  @override
  String get drawModeManual => 'Qo\'lda';

  @override
  String get drawModeVisual => 'Vizual';

  @override
  String get drawHintRaw =>
      'Xom chizma. \"Toza\"ga qaytish uchun tugmani bosing.';

  @override
  String get drawHintShapeReady =>
      'Shakl tayyor! Burchaklarni surib o\'lchamni o\'zgartiring.';

  @override
  String get drawHintFreehand => 'Xona shaklini barmog\'ingiz bilan chizing.';

  @override
  String get drawHintMarkCorners =>
      'Xona burchaklarini belgilang (kamida 3 ta).';

  @override
  String drawHintMorePoints(int count) {
    return 'Yana $count ta nuqta qo\'ying.';
  }

  @override
  String get drawHintClose =>
      'Yopish uchun birinchi nuqtaga bosing yoki \"Yopish\".';

  @override
  String get drawToggleClean => 'Toza';

  @override
  String get drawToggleRaw => 'Xom';

  @override
  String get drawRedo => 'Oldinga';

  @override
  String get drawClear => 'Tozalash';

  @override
  String get drawWallLength => 'Devor uzunligi';

  @override
  String get drawAreaWarning => 'Diqqat: yuza odatiy oraliqdan tashqarida';

  @override
  String drawTitleRect(String width, String length, String height) {
    return 'Xona: $width × $length × $height m';
  }

  @override
  String drawTitlePolygon(int corners, String width, String length) {
    return 'Ko\'pburchak · $corners devor · $width×$length m';
  }

  @override
  String get a11yQuantityDecrease => 'Miqdorni kamaytirish';

  @override
  String get a11yQuantityIncrease => 'Miqdorni oshirish';

  @override
  String get a11yRemoveFromCart => 'Savatdan olib tashlash';

  @override
  String get a11yAddToCart => 'Savatga qo\'shish';

  @override
  String get a11yCallDealer => 'Qo\'ng\'iroq qilish';

  @override
  String get a11yMessageDealer => 'Xabar yuborish';

  @override
  String shopDealerPhoneUnavailable(String dealer) {
    return '$dealer: telefon raqami hali mavjud emas';
  }

  @override
  String shopDealerMessageUnavailable(String dealer) {
    return '$dealer bilan xabar almashish hali mavjud emas';
  }

  @override
  String get a11yEditProfile => 'Profilni tahrirlash';

  @override
  String get a11yMastersListView => 'Ro\'yxat ko\'rinishi';

  @override
  String get settingsScreenTitle => 'Sozlamalar';

  @override
  String get settingsNotificationsSectionTitle => 'Bildirishnomalar';

  @override
  String get settingsPushNotificationsTitle => 'Push-bildirishnomalar';

  @override
  String get settingsPushNotificationsSubtitle =>
      'Loyihalar va pudratchilar haqida yangiliklarni oling';

  @override
  String get settingsEmailDigestTitle => 'Elektron pochta xulosasi';

  @override
  String get settingsEmailDigestSubtitle =>
      'Loyihalaringiz bo\'yicha haftalik xulosa';

  @override
  String get settingsMarketingEmailsTitle => 'Reklama xabarlari';

  @override
  String get settingsMarketingEmailsSubtitle =>
      'Yangi imkoniyatlar va takliflar haqida xabarlar';

  @override
  String get settingsUnitsDisplaySectionTitle => 'O\'lchov birliklari va ekran';

  @override
  String get settingsMeasurementUnitsTitle => 'O\'lchov birliklari';

  @override
  String get settingsUnitMetric => 'Metrik (m²)';

  @override
  String get settingsUnitImperial => 'Imperial (ft²)';

  @override
  String get settingsThemeTitle => 'Mavzu';

  @override
  String get settingsThemeLight => 'Yorug\'';

  @override
  String get settingsThemeDark => 'Qorong\'i';

  @override
  String get settingsThemeSystem => 'Tizim';

  @override
  String get settingsLargeTextTitle => 'Katta matn';

  @override
  String get settingsLargeTextSubtitle =>
      'O\'qishni qulaylashtirish uchun matn hajmini kattalashtiring';

  @override
  String get settingsProjectSettingsSectionTitle => 'Loyiha sozlamalari';

  @override
  String get settingsAutoSaveTitle => 'Loyihalarni avtomatik saqlash';

  @override
  String get settingsAutoSaveSubtitle =>
      'Ishingiz jarayonida avtomatik ravishda saqlanadi';

  @override
  String get settingsCloudSyncTitle => 'Bulutli sinxronizatsiya';

  @override
  String get settingsCloudSyncSubtitle =>
      'Loyihalarni barcha qurilmalaringizda sinxronlang';

  @override
  String get settingsCloudSyncEnabledMessage => 'Cloud sync yoqildi';

  @override
  String get settingsCloudSyncDisabledMessage => 'Cloud sync o\'chirildi';

  @override
  String get settingsClearCacheTitle => 'Keshni tozalash';

  @override
  String get settingsClearCacheSubtitle =>
      'Xotiradagi bo\'sh joyni ko\'paytiring';

  @override
  String get settingsClearingCacheInProgress => 'Tozalanmoqda...';

  @override
  String get settingsCacheClearedMessage => 'Kesh tozalandi';

  @override
  String settingsCacheClearFailedMessage(String error) {
    return 'Keshni tozalab bo\'lmadi: $error';
  }

  @override
  String get settingsPrivacySecuritySectionTitle => 'Maxfiylik va xavfsizlik';

  @override
  String get settingsPrivacyPolicyTitle => 'Maxfiylik siyosati';

  @override
  String get settingsPrivacyPolicySubtitle =>
      'Maxfiylik siyosatimiz bilan tanishing';

  @override
  String get settingsTermsOfServiceTitle => 'Foydalanish shartlari';

  @override
  String get settingsTermsOfServiceSubtitle =>
      'Shartlar va qoidalarni ko\'rib chiqing';

  @override
  String settingsLinkOpenFailedMessage(String url) {
    return 'Havolani ochib bo\'lmadi: $url';
  }

  @override
  String get settingsAboutSectionTitle => 'Ilova haqida';

  @override
  String get settingsAppVersionLabel => 'Ilova versiyasi';

  @override
  String get settingsBuildNumberLabel => 'Build raqami';

  @override
  String get settingsCheckForUpdatesButton => 'Yangilanishlarni tekshirish';

  @override
  String get settingsUpdatesDialogTitle => 'Yangilanishlar';

  @override
  String get settingsUpdatesDialogBody =>
      'Siz ilovaning eng so\'nggi versiyasidasiz.';

  @override
  String get settingsUpdatesDialogOk => 'OK';

  @override
  String get registerRoleTitle => 'Siz kimsiz?';

  @override
  String get roleUser => 'Foydalanuvchi';

  @override
  String get roleUserDesc => 'O\'z ta\'mir va dizayn loyihalarim uchun';

  @override
  String get roleShop => 'Do\'kon egasi';

  @override
  String get roleShopDesc => 'Mebel va materiallarimni sotaman';

  @override
  String get roleUsta => 'Usta';

  @override
  String get roleUstaDesc => 'Ta\'mir xizmatlarini taklif qilaman';

  @override
  String get businessApplyShopTitle => 'Do\'kon arizasi';

  @override
  String get businessApplyUstaTitle => 'Usta arizasi';

  @override
  String get businessApplyIntro =>
      'Ma\'lumotlaringizni kiriting. Adminlar ko\'rib chiqib, tasdiqlagach ro\'yxatda ko\'rinasiz.';

  @override
  String get businessFieldShopName => 'Do\'kon nomi';

  @override
  String get businessFieldUstaName => 'Ismingiz yoki jamoa nomi';

  @override
  String get businessFieldTrade => 'Kasbingiz';

  @override
  String get businessFieldDistrict => 'Tuman';

  @override
  String get businessFieldPhone => 'Telefon (+998...)';

  @override
  String get businessFieldTelegram => 'Telegram (ixtiyoriy)';

  @override
  String get businessFieldPriceMin => 'Dan';

  @override
  String get businessFieldPriceMax => 'Gacha';

  @override
  String get businessFieldPriceTitle => 'Narx (so\'m)';

  @override
  String get businessSubmit => 'Arizani yuborish';

  @override
  String get businessSkip => 'Keyinroq';

  @override
  String get businessErrorName => 'Nomni kiriting';

  @override
  String get businessErrorPhone => 'Telefonni +998 bilan to\'liq kiriting';

  @override
  String get businessErrorPrice => 'Maksimal narx minimaldan kam bo\'lmasin';

  @override
  String get businessErrorExists => 'Sizda allaqachon bunday ariza bor';

  @override
  String get businessErrorFailed =>
      'Arizani yuborib bo\'lmadi. Qayta urinib ko\'ring.';

  @override
  String get businessTitle => 'Biznesim';

  @override
  String get businessShopSection => 'Do\'kon';

  @override
  String get businessUstaSection => 'Usta profilim';

  @override
  String get businessStatusPending => 'Ko\'rib chiqilmoqda';

  @override
  String get businessStatusApproved => 'Tasdiqlangan';

  @override
  String get businessStatusRejected => 'Rad etilgan';

  @override
  String get businessPendingHint =>
      'Ariza adminlar tomonidan ko\'rib chiqilmoqda. Tasdiqlangach ro\'yxatda ko\'rinasiz.';

  @override
  String get businessApprovedHint => 'Profilingiz ro\'yxatda ko\'rinadi.';

  @override
  String get businessResubmit => 'Qayta yuborish';

  @override
  String get businessComingProducts => 'Mahsulotlar boshqaruvi tez kunda';

  @override
  String get businessComingRequests => 'Mijoz so\'rovlari tez kunda';

  @override
  String get businessLoadFailed => 'Ma\'lumotni yuklab bo\'lmadi';

  @override
  String get profileMenuBusiness => 'Biznesim';

  @override
  String get profileMenuBecomePartner =>
      'Do\'kon yoki usta sifatida qo\'shilish';

  @override
  String get tradeElektrik => 'Elektrik';

  @override
  String get tradeElektrikLoyihachi => 'Elektr loyihachi';

  @override
  String get tradeSantexnik => 'Santexnik';

  @override
  String get tradeMalyar => 'Malyar';

  @override
  String get tradeOboy => 'Oboy ustasi';

  @override
  String get tradeLaminat => 'Laminat ustasi';

  @override
  String get tradeBrigada => 'Brigada';

  @override
  String businessRejectedReason(String note) {
    return 'Sabab: $note';
  }

  @override
  String get shopProductsTitle => 'Mahsulotlarim';

  @override
  String get shopProductsEmpty =>
      'Hali mahsulot yo\'q. Rasm olib, birinchi mahsulotni qo\'shing.';

  @override
  String get shopProductsOpen => 'Mahsulotlarni boshqarish';

  @override
  String get shopProductVisible => 'Katalogda ko\'rinadi';

  @override
  String get shopProductEdit => 'Tahrirlash';

  @override
  String get shopProductName => 'Nomi';

  @override
  String get shopProductPrice => 'Narxi (so\'m)';

  @override
  String get shopProductSave => 'Saqlash';

  @override
  String get shopProductDelete => 'O\'chirish';

  @override
  String get shopProductDeleteConfirm =>
      'Mahsulot o\'chirilsin? Buni qaytarib bo\'lmaydi.';

  @override
  String get shopProductCancel => 'Bekor qilish';

  @override
  String get shopProductFailed =>
      'Amalni bajarib bo\'lmadi. Qayta urinib ko\'ring.';

  @override
  String get shopProductNoPrice => 'Narx ko\'rsatilmagan';

  @override
  String get addProductTitle => 'Yangi mahsulot';

  @override
  String get addProductPhotoHint =>
      'Mebelning aniq rasmini oling (toza fon yaxshi). 3D modelni o\'zimiz yaratamiz.';

  @override
  String get addProductGallery => 'Galereyadan';

  @override
  String get addProductCamera => 'Kameradan';

  @override
  String get addProductCategory => 'Turi';

  @override
  String get addProductRoom => 'Xona';

  @override
  String get addProductRoomAll => 'Barcha xonalar';

  @override
  String get addProductPlacement => 'Joylashuvi';

  @override
  String get addProductSubmit => '3D model yaratish va qo\'shish';

  @override
  String get addProductBuilding =>
      '3D model yaratilmoqda… taxminan 1–2 daqiqa, ilovani yopmang';

  @override
  String get addProductUploading => 'Mahsulot do\'konga qo\'shilmoqda…';

  @override
  String get addProductDone =>
      'Mahsulot qo\'shildi. Admin tasdiqlagach katalogda ko\'rinadi.';

  @override
  String get addProductNeedPhoto => 'Avval rasm tanlang';

  @override
  String get addProductNeedName => 'Nomini kiriting';

  @override
  String get addProductFailed =>
      '3D modelni yaratib bo\'lmadi. Boshqa rasm bilan urinib ko\'ring.';

  @override
  String get addProductUnavailable => '3D model xizmati hozir mavjud emas';

  @override
  String get addProductLimit =>
      'Bugungi limit tugadi. Ertaga qayta urinib ko\'ring.';

  @override
  String get addProductTooMany =>
      'Tasdiqlanmagan mahsulotlar ko\'p. Ular ko\'rib chiqilishini kuting.';

  @override
  String get categoryDivan => 'Divan';

  @override
  String get categoryStol => 'Stol';

  @override
  String get categoryStul => 'Stul';

  @override
  String get categoryKaravot => 'Karavot';

  @override
  String get categoryShkaf => 'Shkaf';

  @override
  String get categoryLampa => 'Lampa';

  @override
  String get categoryBoshqa => 'Boshqa';

  @override
  String get roomMehmonxona => 'Mehmonxona';

  @override
  String get roomOshxona => 'Oshxona';

  @override
  String get roomYotoqxona => 'Yotoqxona';

  @override
  String get roomHammom => 'Hammom';

  @override
  String get roomBalkon => 'Balkon';

  @override
  String get placementPol => 'Polda';

  @override
  String get placementDevor => 'Devorda';

  @override
  String get placementShift => 'Shiftda';

  @override
  String get ustaLeadsTitle => 'Mijoz so\'rovlari';

  @override
  String get ustaLeadsOpen => 'Mijoz so\'rovlari';

  @override
  String get ustaLeadsEmpty =>
      'Hali so\'rov yo\'q. Mijozlar sizga smeta bilan murojaat qilganda shu yerda ko\'rinadi.';

  @override
  String get ustaLeadCall => 'Qo\'ng\'iroq qilish';

  @override
  String get ustaLeadNoPhone => 'Telefon ko\'rsatilmagan';

  @override
  String get ustaLeadClient => 'Mijoz';

  @override
  String ustaLeadEstimate(String total, int lines) {
    return 'Smeta: $total ($lines ta qator)';
  }

  @override
  String get leadStatusNew => 'Yangi';

  @override
  String get leadStatusViewed => 'Ko\'rildi';

  @override
  String get leadStatusContacted => 'Bog\'lanildi';

  @override
  String get leadStatusClosed => 'Yopildi';

  @override
  String get ustaLeadMarkViewed => 'Ko\'rildi';

  @override
  String get ustaLeadMarkContacted => 'Bog\'lanildi';

  @override
  String get ustaLeadMarkClosed => 'Yopish';

  @override
  String get ustaEditOpen => 'Profilni tahrirlash';

  @override
  String get ustaEditTitle => 'Usta profilim';

  @override
  String get ustaEditSave => 'Saqlash';

  @override
  String get ustaEditFailed => 'Saqlab bo\'lmadi. Qayta urinib ko\'ring.';

  @override
  String get shopEditTitle => 'Do\'kon profili';

  @override
  String get addProductMoreAngles => 'Boshqa burchaklar (ixtiyoriy)';

  @override
  String get addProductMoreAnglesHint =>
      'Chap, orqa va o\'ng tomondan suratlar 3D modelni aniqroq qiladi.';

  @override
  String get addProductAngleLeft => 'Chap';

  @override
  String get addProductAngleBack => 'Orqa';

  @override
  String get addProductAngleRight => 'O\'ng';

  @override
  String get addProductAngleRemove => 'O\'chirish';

  @override
  String get shopInquiriesTitle => 'Mijoz murojaatlari';

  @override
  String get shopInquiriesOpen => 'Murojaatlar';

  @override
  String shopInquiriesOpenWithNew(int count) {
    return 'Murojaatlar ($count yangi)';
  }

  @override
  String get shopInquiriesEmpty =>
      'Hali murojaat yo\'q. Mijozlar mahsulotingiz haqida so\'rasa, shu yerda ko\'rinadi.';

  @override
  String shopInquiryProduct(String name) {
    return 'Mahsulot: $name';
  }

  @override
  String get shopStatsOpen => 'Statistika';

  @override
  String get shopStatsTitle => 'Do\'kon statistikasi';

  @override
  String get shopStatsProducts => 'Mahsulotlar';

  @override
  String get shopStatsApproved => 'Tasdiqlangan';

  @override
  String get shopStatsPending => 'Ko\'rib chiqilmoqda';

  @override
  String get shopStatsRejected => 'Rad etilgan';

  @override
  String get shopStatsVisible => 'Katalogda ko\'rinadi';

  @override
  String get shopStatsInquiries => 'Murojaatlar';

  @override
  String get shopStatsNewInquiries => 'Yangi murojaatlar';

  @override
  String get shopStatsPlacements => 'Xonalarga joylashtirilgan';

  @override
  String get shopStatsTop => 'Eng ko\'p tanlangan mahsulotlar';

  @override
  String get shopStatsTopEmpty => 'Hali ma\'lumot yo\'q.';

  @override
  String get mastersSendFailed => 'Yuborib bo\'lmadi. Qayta urinib ko\'ring.';

  @override
  String shopCheckoutUnlinkedLines(String names) {
    return 'Savatdagi ba\'zi mahsulotlar do\'kon katalogiga bog\'lanmagan, shuning uchun buyurtma berib bo\'lmaydi: $names. Ularni savatdan olib tashlang.';
  }

  @override
  String shopOrderPartial(String dealer, String error) {
    return '$dealer buyurtmasi qabul qilinmadi: $error Qolgan buyurtmalar yuborildi.';
  }

  @override
  String get shopOrdersTitle => 'Buyurtmalar';

  @override
  String get shopOrdersOpen => 'Buyurtmalar';

  @override
  String get shopOrdersEmpty =>
      'Hali buyurtma yo\'q. Mijozlar buyurtma bersa, shu yerda ko\'rinadi.';

  @override
  String get shopOrderMarkGathering => 'Yig\'ilmoqda deb belgilash';

  @override
  String get shopOrderMarkOnTheWay => 'Yo\'lda deb belgilash';

  @override
  String get shopOrderMarkDelivered => 'Yetkazildi deb belgilash';

  @override
  String shopOrderAddressLine(String value) {
    return 'Manzil: $value';
  }

  @override
  String shopOrderPaymentLine(String value) {
    return 'To\'lov: $value';
  }

  @override
  String get shopOrderPayCash => 'Naqd';

  @override
  String get shopOrderPayCard => 'Karta';

  @override
  String get tradePlitkachi => 'Plitkachi';

  @override
  String get tradeShtukatur => 'Shtukatur';

  @override
  String get tradeGipsokartonchi => 'Gipsokartonchi';

  @override
  String get tradeEshikOyna => 'Eshik-oyna ustasi';

  @override
  String get tradeIsitishKonditsioner => 'Isitish va konditsioner ustasi';

  @override
  String get tradeDemontaj => 'Demontajchi';

  @override
  String get ustaPortfolioOpen => 'Portfolio';

  @override
  String get ustaPortfolioTitle => 'Mening portfolioim';

  @override
  String get ustaPortfolioEmpty =>
      'Hali ish rasmlari yo\'q. Bajargan ishlaringizni qo\'shing.';

  @override
  String get ustaPortfolioAdd => 'Rasm qo\'shish';

  @override
  String get ustaPortfolioCaption => 'Izoh (ixtiyoriy)';

  @override
  String get ustaPortfolioUpload => 'Yuklash';

  @override
  String get ustaPortfolioDeleteConfirm =>
      'Rasm o\'chirilsin? Buni qaytarib bo\'lmaydi.';

  @override
  String get ustaPortfolioLoadFailed => 'Portfolioni yuklab bo\'lmadi.';

  @override
  String ustaLeadMessage(String message) {
    return 'Mijoz xabari: $message';
  }

  @override
  String get profileMenuDeleteAccount => 'Hisobni o\'chirish';

  @override
  String get deleteAccountTitle => 'Hisobni o\'chirasizmi?';

  @override
  String get deleteAccountBody =>
      'Hisobingiz bilan birga barcha loyihalaringiz, rasmlaringiz, buyurtmalaringiz hamda do\'koningiz yoki usta profilingiz o\'chiriladi. Bu doimiy va uni qaytarib bo\'lmaydi.';

  @override
  String get deleteAccountPasswordLabel => 'Parol';

  @override
  String get deleteAccountPasswordHint =>
      'Telefon kodi bilan kirgan bo\'lsangiz, bo\'sh qoldiring';

  @override
  String get deleteAccountDone => 'Hisobingiz o\'chirildi';

  @override
  String scanFailedReason(String reason) {
    return 'Sabab: $reason';
  }

  @override
  String get shopCategoryBoyoq => 'Bo\'yoq';

  @override
  String get shopCategoryOboy => 'Oboy';

  @override
  String get shopCategoryLaminat => 'Laminat';

  @override
  String get shopCategoryKafel => 'Kafel';

  @override
  String get shopCategoryParket => 'Parket';

  @override
  String get shopCategoryGips => 'Gips';

  @override
  String get shopCategorySement => 'Sement';

  @override
  String get shopCategorySantexnika => 'Santexnika';

  @override
  String get shopCategoryElektr => 'Elektr';

  @override
  String get shopCategoryEshik => 'Eshik';

  @override
  String get shopCategoryDeraza => 'Deraza';

  @override
  String get tradeBoshqa => 'Boshqa usta';

  @override
  String get qualityTierEkonom => 'Ekonom';

  @override
  String get qualityTierStandart => 'Standart';

  @override
  String get qualityTierPremium => 'Premium';

  @override
  String get estimateOpen3dStudio => '3D Studio';

  @override
  String get actionDelete => 'O\'chirish';

  @override
  String get mapAttribution => '© OpenStreetMap hissadorlari';

  @override
  String get pushPromptTitle => 'Xabar beraylikmi?';

  @override
  String get pushPromptBody =>
      'Dizayningiz tayyor bo\'lganda yoki buyurtma holati o\'zgarganda xabar beramiz.';

  @override
  String get pushPromptYes => 'Ha';

  @override
  String get pushPromptLater => 'Keyinroq';

  @override
  String get settingsNotificationsTitle => 'Bildirishnomalar';

  @override
  String get settingsNotificationsOn => 'Yoqilgan';

  @override
  String get settingsNotificationsOff => 'O\'chirilgan';

  @override
  String get pushChannelName => 'Andoza yangiliklari';

  @override
  String get sharePinTitle => 'Pinterest pin';

  @override
  String get sharePinChooseRoom => 'Qaysi xonaga qo\'llaymiz?';

  @override
  String get sharePinHint => 'Studio\'dagi AI dizayner shu pin bilan ochiladi.';

  @override
  String get sharePinNoRooms =>
      'Hali xona yo\'q. Avval \"+\" orqali xona qo\'shing.';

  @override
  String get sharePinNotPin => 'Bu Pinterest pin havolasi emas';

  @override
  String get sharePinNotPinHint =>
      'Pinterest ilovasida pinni oching va \"Ulashish\" → Andoza AI ni tanlang.';

  @override
  String get furnitureStylesLabel => 'Uslublar';

  @override
  String get furnitureStylesAll => 'Hamma uslubga mos';

  @override
  String get furnitureStyleNeoklassika => 'Neoklassika';

  @override
  String get furnitureStyleKlassik => 'Klassik';

  @override
  String get furnitureStyleZamonaviy => 'Zamonaviy';

  @override
  String get furnitureStyleHitech => 'Hi-Tech';

  @override
  String get furnitureStyleMinimalist => 'Minimalist';

  @override
  String get furnitureStyleSkandinav => 'Skandinav';

  @override
  String get furnitureStyleLoft => 'Loft';

  @override
  String get furnitureStyleMilliy => 'Milliy';

  @override
  String get estimateFloorStandIn =>
      'Pol mahsuloti tanlanmagan — narx do\'kondagi o\'rtacha poldan olindi (taxminiy).';

  @override
  String get scanChoiceTitle => 'Nimani skanerlaymiz?';

  @override
  String get scanChoiceOneRoom => 'Bitta xona';

  @override
  String get scanChoiceFlat => 'Bir nechta xona (kvartira)';

  @override
  String get scanChoiceFlatHint =>
      'Xonalarni ketma-ket skanerlang — ular rejada o\'z joyiga tushadi';

  @override
  String get scanNextRoom => 'Keyingi xona';

  @override
  String get scanFinish => 'Tugatish';

  @override
  String scanRoomN(int n) {
    return '$n-xona';
  }

  @override
  String get flatReviewTitle => 'Skanerlangan xonalar';

  @override
  String get flatReviewRoomName => 'Xona nomi';

  @override
  String get flatReviewContinue => 'Studiyada ochish';

  @override
  String flatReviewPartial(int n) {
    return 'Skaner to\'xtadi — $n ta xona saqlandi';
  }

  @override
  String flatReviewDropped(int n) {
    return '$n ta xona o\'qilmadi va qo\'shilmadi';
  }

  @override
  String flatReviewSavedSome(int saved, int total) {
    return '$total ta xonadan $saved tasi saqlandi — qolganlarini qayta skanerlang';
  }

  @override
  String get loginWithApple => 'Apple bilan kirish';

  @override
  String get loginAppleFailed =>
      'Apple orqali kirib bo\'lmadi. Qayta urinib ko\'ring.';

  @override
  String get reportAction => 'Shikoyat qilish';

  @override
  String get reportTitle => 'Shikoyat';

  @override
  String get reportHint =>
      'Nima noto\'g\'ri? Shikoyatingizni moderatorlar ko\'rib chiqadi.';

  @override
  String get reportReasonSpam => 'Spam yoki reklama';

  @override
  String get reportReasonInappropriate => 'Nomaqbul kontent';

  @override
  String get reportReasonFraud => 'Firibgarlik';

  @override
  String get reportReasonOther => 'Boshqa';

  @override
  String get reportDetails => 'Izoh (ixtiyoriy)';

  @override
  String get reportSend => 'Yuborish';

  @override
  String get reportSent => 'Rahmat! Shikoyatingiz yuborildi.';

  @override
  String get blockUstaAction => 'Bloklash';

  @override
  String get blockUstaTitle => 'Ustani bloklaysizmi?';

  @override
  String get blockUstaBody =>
      'U endi xaritada va ro\'yxatda sizga ko\'rinmaydi.';

  @override
  String get blockUstaConfirm => 'Bloklash';

  @override
  String get blockUstaDone => 'Usta bloklandi';

  @override
  String get shopFurnitureSection => 'Mebel';

  @override
  String get shopFurnitureNoPrice => 'Narxi kelishiladi';

  @override
  String storePageOpen(String name) {
    return '$name do\'koni';
  }

  @override
  String get storeLoadFailed => 'Do\'konni ochib bo\'lmadi';

  @override
  String get storeCall => 'Qo\'ng\'iroq';

  @override
  String get storeTelegram => 'Telegram';

  @override
  String get storeNoProducts => 'Bu do\'konda hozircha mahsulot yo\'q';

  @override
  String get storeReport => 'Do\'kon haqida shikoyat';

  @override
  String get furnitureSize => 'O\'lchami';

  @override
  String furnitureSizeValue(String size) {
    return '$size sm';
  }

  @override
  String get furniturePlaceInRoom => 'Xonamga qo\'yish';

  @override
  String get furniturePickRoom => 'Qaysi xonaga qo\'yamiz?';

  @override
  String get furnitureNoRooms => 'Avval xona yarating yoki skanerlang';

  @override
  String get furnitureNoModel =>
      'Bu mahsulotning 3D modeli yo\'q, uni xonaga qo\'yib bo\'lmaydi';

  @override
  String get furnitureLoadFailed => 'Mahsulotni ochib bo\'lmadi';

  @override
  String get profileMenuMebel => 'Mebel ishlab chiqarish';

  @override
  String get profileMenuMebelHint =>
      'Ustaxonalar uchun: shkaf detallari, kromka va narx';

  @override
  String get mebelExportFailed => 'Faylni ochib bo\'lmadi';

  @override
  String get scanHintStart => 'Xonani sekin aylanib skanerlang';

  @override
  String get scanCoachMoveCloser => 'Telefonni devorga yaqinroq tuting';

  @override
  String get scanCoachMoveAway => 'Telefonni devordan birozroq uzoqlashtiring';

  @override
  String get scanCoachSlowDown =>
      'Juda tez harakatlanyapsiz — sekinroq aylaning';

  @override
  String get scanCoachTurnOnLight => 'Xona qorong\'i — yorug\'likni yoqing';

  @override
  String get scanCoachLowTexture =>
      'Bu yuza silliq/bir xil — kamerani boshqa tomonga burang';

  @override
  String get scanCoachGood =>
      'Zo\'r ketyapti — xonani shu tezlikda aylanib chiqing';

  @override
  String get scanCoachKeepGoing => 'Skanerlashda davom eting';
}
