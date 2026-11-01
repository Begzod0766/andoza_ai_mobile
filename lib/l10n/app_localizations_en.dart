// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Andoza AI';

  @override
  String get actionRetry => 'Retry';

  @override
  String get actionBack => 'Back';

  @override
  String get actionNext => 'Next';

  @override
  String get actionContinue => 'Continue';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionSave => 'Save';

  @override
  String get actionClose => 'Close';

  @override
  String get actionDone => 'Done';

  @override
  String get actionFinish => 'Finish';

  @override
  String get navHome => 'Home';

  @override
  String get navShop => 'Shop';

  @override
  String get navMasters => 'Masters';

  @override
  String get navProfile => 'Profile';

  @override
  String get loginEmailHint => 'Email';

  @override
  String get loginPasswordHint => 'Password';

  @override
  String get loginShowPassword => 'Show password';

  @override
  String get loginHidePassword => 'Hide password';

  @override
  String get loginButton => 'Log in';

  @override
  String get loginEmptyFields => 'Please fill in all fields';

  @override
  String get b1Question => 'What condition is your room in right now?';

  @override
  String get b1DontKnowDifference => 'Not sure of the difference? →';

  @override
  String get b1FloorCeilingDifferent => 'If the floor or ceiling differs →';

  @override
  String get b1EnterRoom => 'Enter room';

  @override
  String get brandName => 'AndozaAI';

  @override
  String get navAddProject => 'Add new project';

  @override
  String get loginPhoneLabel => 'Phone number';

  @override
  String get loginPhoneSubtitle => 'A phone number is required to log in';

  @override
  String get loginPhoneHint => '90 123 45 67';

  @override
  String get loginPhoneSmsHint => 'An SMS code will be sent to this number';

  @override
  String get loginSendOtp => 'Send OTP';

  @override
  String get loginOtpInfoBox =>
      'A 6-digit code will be sent to the number you entered. If the SMS doesn\'t arrive, try again in 2-3 minutes.';

  @override
  String get loginWithUsername => 'Sign in with username';

  @override
  String get loginCodeSentTitle => '✓ Code sent';

  @override
  String get loginCodeSentSuffix =>
      ' — we\'ll send a 6-digit code to this number';

  @override
  String get loginVerify => 'Verify';

  @override
  String get loginResend => 'Resend';

  @override
  String loginResendCountdown(int seconds) {
    return 'Resend (${seconds}s)';
  }

  @override
  String get loginBackArrow => '← Back';

  @override
  String get loginSignIn => 'Sign in';

  @override
  String get loginUsernameHint => 'Username';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginNoAccount => 'Don\'t have an account? ';

  @override
  String get loginRegister => 'Sign up';

  @override
  String get loginNameHint => 'Name (optional)';

  @override
  String get loginConfirmPasswordHint => 'Confirm password';

  @override
  String get loginHaveAccount => 'Already have an account? ';

  @override
  String get loginWithGoogle => 'Continue with Google';

  @override
  String get loginGoogleFailed =>
      'Couldn\'t sign in with Google. Please try again.';

  @override
  String get loginOr => 'or';

  @override
  String get loginTagline =>
      'Your renovation and interior projects in one place';

  @override
  String get loginVersion => 'AndozaAI v1.0.0';

  @override
  String get loginErrorInvalidPhone =>
      'Invalid phone number. Example: 90 123 45 67';

  @override
  String get loginErrorServer => 'Server error. Please try again.';

  @override
  String get loginErrorInvalidCode => 'The code is incorrect or expired.';

  @override
  String get loginErrorCredentialsRequired =>
      'Username and password are required.';

  @override
  String get loginErrorWrongCredentials => 'Incorrect username or password.';

  @override
  String get loginErrorUsernameShort =>
      'Username must be at least 3 characters.';

  @override
  String get loginErrorUsernameLong =>
      'Username must be at most 50 characters.';

  @override
  String get loginErrorPasswordShort =>
      'Password must be at least 6 characters.';

  @override
  String get loginErrorPasswordMismatch => 'Passwords do not match.';

  @override
  String get loginErrorUsernameTaken => 'This username is already taken.';

  @override
  String get loginErrorRegisterFailed => 'Registration failed.';

  @override
  String get homeWelcome => 'Welcome';

  @override
  String homeGreetingNamed(String name) {
    return 'Hi, $name! 👋';
  }

  @override
  String get homeGreeting => 'Hi! 👋';

  @override
  String get homeStoryHowItWorks => 'How it works?';

  @override
  String get homeStoryDemoGuide => 'Demo guide';

  @override
  String get homeStoryDemo => 'Demo';

  @override
  String get homeEmptyTitle => 'Add your first room';

  @override
  String get homeEmptyMessage => 'No projects yet — start a new project';

  @override
  String get homeEmptyAction => '+ Add project';

  @override
  String get homeQuickActions => 'Quick actions';

  @override
  String get homeQuickScan => 'Scan room';

  @override
  String get homeQuickEstimate => 'Estimate';

  @override
  String get homeQuickDealers => 'Dealers';

  @override
  String get homeProjectsLoadError => 'Couldn\'t load projects';

  @override
  String get homeLoadMore => 'Show more';

  @override
  String get homeLegendExisting => 'Existing (not counted)';

  @override
  String get homeLegendNeeded => 'Needed (delta)';

  @override
  String get homeResume => 'Continue';

  @override
  String get homeNoRoomYet => 'This project has no room yet';

  @override
  String homeStageProgress(int current) {
    return 'Stage $current/8';
  }

  @override
  String homeStageProgressExcluded(int current, String names) {
    return 'Stage $current/8 · ✓ $names already existed';
  }

  @override
  String homeStageProgressExcludedCount(int current, int count) {
    return 'Stage $current/8 · ✓ $count stages already existed';
  }

  @override
  String get homeStagePickerTitle => 'Choose a stage';

  @override
  String homeStageOption(int index, String label) {
    return 'Stage $index/8 · $label';
  }

  @override
  String get homeStageSaveError => 'Couldn\'t save the stage';

  @override
  String homeRoomCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rooms',
      one: '$count room',
    );
    return '$_temp0';
  }

  @override
  String get homeStatAreaLabel => 'Area';

  @override
  String get homeStatModelsLabel => '3D models';

  @override
  String get homeStatEstimateLabel => 'Estimate';

  @override
  String homeAreaValue(String area) {
    return '$area m²';
  }

  @override
  String homeEstimateMln(String amount) {
    return '${amount}M';
  }

  @override
  String get homeStatDash => '—';

  @override
  String get stageSuvoq => 'plastering';

  @override
  String get stageShpaklovka => 'putty';

  @override
  String get stageBoyoqOboi => 'paint/wallpaper';

  @override
  String get stagePol => 'flooring';

  @override
  String get stageMebel => 'furniture';

  @override
  String get stageElektr => 'electrical';

  @override
  String get stageYoruglik => 'lighting';

  @override
  String get stageSantexnika => 'plumbing';

  @override
  String get commonYes => 'Yes';

  @override
  String get commonNo => 'No';

  @override
  String get shopCartTooltip => 'Cart';

  @override
  String get shopSearchHint => 'Search materials...';

  @override
  String get shopFilterAll => 'All';

  @override
  String get shopInProjectTag => 'In project';

  @override
  String get shopMaterialsTitle => 'Project materials';

  @override
  String shopMaterialsAutoCalc(String area, int count) {
    return 'The app auto-calculated based on your project — $area m², $count stages';
  }

  @override
  String get shopAddAllToCart => 'Add selected to cart';

  @override
  String get shopSelectRoomLabel => 'For which room?';

  @override
  String shopSelectedCount(int count) {
    return '$count selected';
  }

  @override
  String get shopOfficialDealer => '✓ Official dealer';

  @override
  String shopProjectNeed(String quantity, String unit) {
    return 'Your project needs ~$quantity $unit';
  }

  @override
  String get shopQuantityLabel => 'Quantity:';

  @override
  String get shopSpecCoverage => 'Coverage';

  @override
  String get shopSpecDryingTime => 'Drying time';

  @override
  String get shopSpecWashable => 'Washable';

  @override
  String shopWhereToBuy(String name) {
    return 'Where to buy — $name';
  }

  @override
  String shopPriceFromDealer(String dealer) {
    return 'Price from $dealer';
  }

  @override
  String get shopAddedToCart => 'Added to cart';

  @override
  String shopAddToCartPrice(String price) {
    return 'Add to cart · $price';
  }

  @override
  String get shopDealerCompareTitle => 'Compare dealers';

  @override
  String get shopFilterCheapest => 'Cheapest';

  @override
  String get shopFilterOfficial => 'Official dealer';

  @override
  String get shopFilterFastest => 'Fastest';

  @override
  String get shopBestRibbon => 'BEST';

  @override
  String shopDeliveryDays(String district, int days) {
    return '$district · delivery in $days days';
  }

  @override
  String get shopSelect => 'Select';

  @override
  String get shopCartTitle => 'Cart';

  @override
  String get shopCartEmpty => 'Cart is empty';

  @override
  String get shopMaterials => 'Materials';

  @override
  String get shopDelivery => 'Delivery';

  @override
  String get shopGrandTotal => 'Grand total';

  @override
  String get shopCheckout => 'Place order';

  @override
  String get shopCheckoutTitle => 'Payment';

  @override
  String get shopDeliveryAddress => 'Delivery address';

  @override
  String get shopAddressHint => 'Address';

  @override
  String get shopPhoneHint => 'Phone number';

  @override
  String get shopPaymentMethod => 'Payment method';

  @override
  String get shopOrderSummary => 'Order summary';

  @override
  String get shopAmountDue => 'Amount due';

  @override
  String get shopPay => 'Pay';

  @override
  String shopOrderSaveError(String error) {
    return 'Error saving order to server: $error';
  }

  @override
  String get shopOrderStatusTitle => 'Order status';

  @override
  String get shopOrderContents => 'Order contents';

  @override
  String get shopTotal => 'Total';

  @override
  String get shopMasterNotified => 'Master notified';

  @override
  String get shopHandToMaster => 'Hand to master';

  @override
  String get shopBackToShop => 'Back to shop';

  @override
  String get mastersNotFound => 'Craftsman not found';

  @override
  String get unsavedChangesTitle => 'Unsaved changes';

  @override
  String get unsavedChangesBody =>
      'If you leave now, what you entered will be lost.';

  @override
  String get unsavedChangesLeave => 'Leave';

  @override
  String get unsavedChangesStay => 'Stay';

  @override
  String get roomSaveFailed =>
      'The room wasn\'t saved to the server. Check your connection and try again.';

  @override
  String get newProjectArScanTitle => 'Measure with camera';

  @override
  String get newProjectArScanDesc =>
      'Mark the floor corners with your phone camera to get the room plan';

  @override
  String get arScanFindFloor =>
      'Point the phone at the floor and move it slowly';

  @override
  String get arScanCornersHint => 'Put the target on a floor corner and add it';

  @override
  String get arScanAddCorner => 'Add corner';

  @override
  String get arScanUndo => 'Undo';

  @override
  String get arScanFinish => 'Done';

  @override
  String get arScanSnapToFirst =>
      'Go back to the first corner to close the outline';

  @override
  String get arScanAimCeiling =>
      'Aim at the ceiling line above the first corner';

  @override
  String get arScanConfirm => 'Confirm';

  @override
  String get arScanEnterManually => 'Enter manually';

  @override
  String get arScanExit => 'Exit';

  @override
  String get arScanExitConfirm =>
      'Stop measuring? The corners you marked will be lost.';

  @override
  String get arScanTrackingLost =>
      'Too little light, or the phone moved too fast';

  @override
  String get arScanFloorHint =>
      'Try brighter light, and aim at a rug or a patterned floor';

  @override
  String get arScanCornersLost => 'Some corners were lost — mark them again';

  @override
  String get arScanNoFloorHere => 'Scan the floor first';

  @override
  String get arScanKeepMeasuring => 'Keep measuring';

  @override
  String get arScanStepFloor => '1/3 — floor';

  @override
  String get arScanStepCorners => '2/3 — corners';

  @override
  String get arScanStepHeight => '3/3 — height';

  @override
  String get arScanRescan => 'Measure again';

  @override
  String get arScanNotInstalled =>
      'Measuring with the camera needs \"Google Play Services for AR\"';

  @override
  String get arScanInstall => 'Install';

  @override
  String get arScanCameraDenied => 'Allow camera access to measure the room';

  @override
  String get arScanOpenSettings => 'Open settings';

  @override
  String get arScanUnsupported =>
      'This phone can\'t measure with the camera. Draw the room or enter its size instead.';

  @override
  String get arScanFailed => 'Couldn\'t measure. Please try again.';

  @override
  String get arScanRejected_too_few_corners => 'At least 3 corners are needed';

  @override
  String get arScanRejected_self_intersecting =>
      'The walls cross each other — mark the corners in order';

  @override
  String get arScanRejected_wall_too_long =>
      'One wall came out longer than 30 m — a corner landed in the wrong place';

  @override
  String get scanReviewArcoreAccuracy =>
      'Camera measurement: expect ±3–5% error, check important walls with a tape';

  @override
  String get shopNoResults => 'Nothing found';

  @override
  String get shopSearchResultsTitle => 'Search results';

  @override
  String get shopFilterForProject => 'Matches my project';

  @override
  String get shopFilterRating => 'Rating';

  @override
  String shopResultCount(int count) {
    return '$count results';
  }

  @override
  String get commonVerifiedBadge => '✓ Verified';

  @override
  String get mastersSearchHint => 'What kind of master do you need?';

  @override
  String mastersRatingReviews(String rating, int count) {
    return '$rating ($count reviews)';
  }

  @override
  String mastersAreaDistance(String area, String distance) {
    return '$area · ~$distance km';
  }

  @override
  String get mastersViewProfile => 'View profile';

  @override
  String get mastersStatRating => 'rating';

  @override
  String get mastersStatReviews => 'reviews';

  @override
  String get mastersStatJobs => 'jobs';

  @override
  String get mastersPortfolio => 'Portfolio';

  @override
  String get mastersPortfolioEmpty => 'No portfolio photos yet';

  @override
  String get mastersServices => 'Services';

  @override
  String mastersServiceTrade(String trade) {
    return '$trade work';
  }

  @override
  String get mastersServiceConsultation => 'Consultation';

  @override
  String get mastersLocation => 'Location';

  @override
  String get mastersSendEstimate => 'Send estimate';

  @override
  String get mastersSendMessage => 'Send message';

  @override
  String mastersSendConfirmTitle(String name) {
    return 'Send your project to $name?';
  }

  @override
  String get mastersProjectSummaryTitle => 'Living room renovation';

  @override
  String mastersProjectSummaryValue(String area, String price) {
    return '$area m² · $price';
  }

  @override
  String get mastersCommentHint => 'Comment (optional)';

  @override
  String get phoneErrorInvalid =>
      'Invalid phone number. Example: +998 90 123 45 67';

  @override
  String get mastersPhoneLabel => 'Your phone number';

  @override
  String get mastersEstimateNote =>
      'The master will review the estimate and propose their price';

  @override
  String get mastersEstimateSent => 'Estimate sent';

  @override
  String get mastersSend => 'Send';

  @override
  String get profileDefaultName => 'User';

  @override
  String get profileComingSoon => 'Coming soon';

  @override
  String get profileStatProjects => 'projects';

  @override
  String get profileStatOrders => 'orders';

  @override
  String get profileStatSaved => 'saved';

  @override
  String profileSavedMln(String amount) {
    return '${amount}M';
  }

  @override
  String get profileMenuProjects => 'My projects';

  @override
  String get profileMenuOrders => 'My orders';

  @override
  String get profileMenuSavedDesigns => 'Saved designs';

  @override
  String get profileMenuAddresses => 'My addresses';

  @override
  String get profileMenuPaymentMethods => 'Payment methods';

  @override
  String get profileMenuLanguage => 'Language';

  @override
  String get profileMenuSettings => 'Settings';

  @override
  String get profileMenuHelp => 'Help';

  @override
  String get profileMenuLogout => 'Log out';

  @override
  String get profileLanguageUzbek => 'Uzbek';

  @override
  String get profileFilterOngoing => 'Ongoing';

  @override
  String get profileFilterFinished => 'Finished';

  @override
  String get profileProjectsEmptyTitle => 'No projects yet';

  @override
  String get profileProjectsEmptyMessage => 'Start your first project';

  @override
  String get profileProjectsEmptyAction => '+ New project';

  @override
  String profileProjectMeta(int count, String details) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rooms',
      one: '$count room',
    );
    return '$_temp0 · $details';
  }

  @override
  String get profileOrdersEmptyTitle => 'No orders';

  @override
  String get profileOrdersEmptyMessage =>
      'Your shop purchases will appear here';

  @override
  String get orderStepAccepted => 'Accepted';

  @override
  String get orderStepGathering => 'Gathering';

  @override
  String get orderStepOnTheWay => 'On the way';

  @override
  String get orderStepDelivered => 'Delivered';

  @override
  String get profileSavedDesignsEmptyTitle => 'No saved designs';

  @override
  String get profileSavedDesignsEmptyMessage => 'Save designs you like here';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingStart => 'Get started';

  @override
  String get onboardingMeasureTitle => 'Measure your room';

  @override
  String get onboardingMeasureBody =>
      'Get accurate room measurements using your phone\'s camera or LiDAR.';

  @override
  String get onboardingDeltaTitle => 'We start from the current state';

  @override
  String get onboardingDeltaBody =>
      'You don\'t pay for what\'s already in your room — we only calculate what\'s needed.';

  @override
  String get onboardingDeltaCurrent => 'Current';

  @override
  String get onboardingDeltaPill => 'only the DIFFERENCE is counted';

  @override
  String get onboardingDecorateTitle => 'Decorate in 3D';

  @override
  String get onboardingDecorateBody =>
      'Drag materials directly onto the room\'s 3D view and see the result instantly.';

  @override
  String get onboardingPriceTitle => 'See the price, get the materials';

  @override
  String get onboardingPriceBody =>
      'Get an accurate estimate and buy the materials you need right from the app.';

  @override
  String get onboardingPriceSaved => 'You saved 4.2M';

  @override
  String get onboardingDemoTitle => 'Demo guide';

  @override
  String get onboardingDemoStep1 =>
      'Add a room — LiDAR, 360° or manual measurement';

  @override
  String get onboardingDemoStep2 => 'Choose the room\'s current condition';

  @override
  String get onboardingDemoStep3 =>
      'Decorate walls, floor and furniture with the rail';

  @override
  String get onboardingDemoStep4 => 'Plan electrical and plumbing at the end';

  @override
  String get onboardingDemoStep5 => 'View the estimate and buy materials';

  @override
  String get onboardingDemoWatchVideo => 'Watch the video';

  @override
  String get onboardingDemoTryMyself => 'I\'ll try it myself';

  @override
  String get commonBackTo3d => 'Back to 3D';

  @override
  String get designSurfaceFloorHeading => 'Floor';

  @override
  String get designSurfaceCeilingHeading => 'Ceiling';

  @override
  String get designFloorRaw => 'Raw concrete';

  @override
  String get designFloorPlastered => 'Screed';

  @override
  String get designFloorPuttied => 'Covering exists';

  @override
  String get designCeilingRaw => 'Raw';

  @override
  String get designCeilingPlastered => 'Plastered';

  @override
  String get designCeilingPuttied => 'Finished';

  @override
  String designRoomEntryIntro(String condition) {
    return 'Your room is in this condition — $condition. Now let\'s decorate it step by step.';
  }

  @override
  String get designConditionRaw => 'in shell condition';

  @override
  String get designConditionPlastered => 'plastered';

  @override
  String get designConditionPuttied => 'puttied';

  @override
  String get designToastShpaklovkaAdded => '✓ Putty added';

  @override
  String get designStageBoyoqOboi => 'Paint/wallpaper stage';

  @override
  String get designRailTabBoyoq => 'Paint';

  @override
  String get designDragHint =>
      'Drag the material onto the wall with your finger';

  @override
  String get designNextStage => 'Next stage →';

  @override
  String get interiorToastFloorApplied => '✓ Applied to floor';

  @override
  String get interiorStagePol => 'Flooring stage';

  @override
  String get interiorRailTabKafel => 'Tile';

  @override
  String get interiorRailTabLaminat => 'Laminate';

  @override
  String get interiorRailTabParket => 'Parquet';

  @override
  String get interiorRailTabBeton => 'Concrete';

  @override
  String get interiorStageMebel => 'Furniture stage';

  @override
  String get interiorRailTabMehmonxona => 'Living room';

  @override
  String get interiorRailTabOshxona => 'Kitchen';

  @override
  String get interiorRailTabYotoqxona => 'Bedroom';

  @override
  String get interiorRailTabVanna => 'Bathroom';

  @override
  String get interiorWalkthroughHint =>
      'You can walk on the floor — drag with your finger';

  @override
  String get interiorGoToPlan => 'Go to plan →';

  @override
  String get interiorDecorationComplete => 'Decoration finished';

  @override
  String get interiorGoToElectrical => 'Go to electrical →';

  @override
  String get interiorWallpaperAdded => '✓ Wallpaper added to library';

  @override
  String interiorUploadFailed(String error) {
    return 'Upload failed: $error';
  }

  @override
  String get interiorWallpaperLibrary => 'Wallpaper library';

  @override
  String get interiorUploading => 'Uploading…';

  @override
  String get interiorUploadImage => 'Upload image';

  @override
  String get interiorNoWallpapers =>
      'No wallpaper yet — upload the first image';

  @override
  String get electricalWireRouting => 'Wire routing';

  @override
  String get electricalView2d => '2D plan';

  @override
  String get electricalView3d => '3D';

  @override
  String get electricalViewBoth => 'Both';

  @override
  String get electricalRecomputeRoute => 'Recompute route';

  @override
  String get electricalNext => 'Next →';

  @override
  String get electricalResult => 'Electrical result';

  @override
  String get electricalFinish => 'Finish →';

  @override
  String get electricalProjectReady => 'Your project is ready';

  @override
  String get electricalViewEstimate => 'View estimate →';

  @override
  String get estimateTitlePrefix => 'Renovation estimate';

  @override
  String get estimateDefaultRoomName => 'Living room';

  @override
  String estimatePdfFailed(String error) {
    return 'Couldn\'t download PDF: $error';
  }

  @override
  String get estimateSomeWork => 'Some work';

  @override
  String get estimateStageFallback => 'Stage';

  @override
  String get estimateFloorUnpriced =>
      'A floor type is chosen but no product is, so the floor is not in this estimate.';

  @override
  String get estimateFloorPick => 'Pick a floor';

  @override
  String get estimateAdjust => 'Adjust estimate';

  @override
  String get estimateApproxTotal => 'Approximate total price';

  @override
  String get estimateLabor => 'Labour';

  @override
  String estimateSavingsBanner(String label, String amount) {
    return '$label already existed — you saved $amount';
  }

  @override
  String get estimateExcludedNote => 'you already have it — not counted';

  @override
  String get estimateZeroSom => '0 som';

  @override
  String get estimatePreparingPdf => 'Preparing…';

  @override
  String get estimateBuyFromShops => 'Buy from shops';

  @override
  String get estimateSendToMaster => 'Send to master';

  @override
  String get estimateMaterialsTotal => 'Materials total';

  @override
  String get estimateStageTotal => 'Stage total';

  @override
  String get estimateAddMaterialsToCart => 'Add materials to cart';

  @override
  String get estimateQualityLevel => 'Quality level';

  @override
  String get estimateExcludeLabor => 'Don\'t include labour';

  @override
  String get estimateDiySubtitle =>
      'I\'ll do it myself — only materials are counted';

  @override
  String estimateDeltaSavings(String stage) {
    return 'Delta savings ($stage)';
  }

  @override
  String get estimateNewTotal => 'New total';

  @override
  String get estimateSaveEstimate => 'Save estimate';

  @override
  String get studioAiDesignerInStudio => 'AI designer (3D Studio)';

  @override
  String get studioAiDesigner => 'AI designer';

  @override
  String get studioAiApplied => '✓ AI changes applied';

  @override
  String studioApplyFailed(String error) {
    return 'Couldn\'t apply: $error';
  }

  @override
  String get studioAiHint =>
      'For example: \"Paint the walls warm beige and add a sofa\"';

  @override
  String get studioAiStyleLabel => 'Style (optional)';

  @override
  String get studioGenerating => 'Generating…';

  @override
  String get studioGenerate => 'Generate';

  @override
  String studioActionLabel(String name) {
    return 'Action: $name';
  }

  @override
  String studioDoneLabel(String name) {
    return 'Done: $name';
  }

  @override
  String studioAiNoResponse(String message) {
    return 'The AI couldn\'t respond yet.\n$message';
  }

  @override
  String studioChangeCeiling(String height) {
    return 'Ceiling height: $height m';
  }

  @override
  String studioChangeSurfaces(int count) {
    return '$count surface materials';
  }

  @override
  String studioChangeWalls(int count) {
    return '$count wall dimensions';
  }

  @override
  String studioChangeFurniture(int count) {
    return '$count furniture items';
  }

  @override
  String studioChangeLights(int count) {
    return '$count lights';
  }

  @override
  String get studioApply => 'Apply';

  @override
  String get studioLoginRequired => 'Log in to open the studio.';

  @override
  String studioLoadFailed(String error) {
    return 'Studio failed to load: $error';
  }

  @override
  String get studioWebViewTitle => '3D Studio';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionPrev => 'Previous';

  @override
  String get actionOk => 'OK';

  @override
  String get actionCancelShort => 'Cancel';

  @override
  String get roomDefaultName => 'Room';

  @override
  String get ceilingHeightLabel => 'Ceiling height';

  @override
  String get measureLength => 'Length';

  @override
  String get furnitureDelete => 'Delete';

  @override
  String get furnitureRotate => 'Rotate';

  @override
  String get electricalTotalsTitle => 'Electrical calculated';

  @override
  String get electricalTotalsWireLabel => 'total wire';

  @override
  String get electricalTotalsDeviceLabel => 'devices';

  @override
  String electricalTotalsSocketWires(String meters) {
    return 'Socket wires $meters m';
  }

  @override
  String electricalTotalsSwitchWires(String meters) {
    return 'Switch wires $meters m';
  }

  @override
  String electricalTotalsSwitchLightSummary(int switches, int lights) {
    return '$switches switches · $lights lights';
  }

  @override
  String get electricalTotalsColDevice => 'Device';

  @override
  String get electricalTotalsColWall => 'Wall';

  @override
  String get electricalTotalsColHeight => 'Height';

  @override
  String get dimensionsTitle => 'Room dimensions';

  @override
  String get dimensionsTabManual => 'Manual entry';

  @override
  String get dimensionsTabUpload => 'Upload plan';

  @override
  String dimensionsTotalSummary(int count, String area) {
    return 'Total: $count rooms · $area m²';
  }

  @override
  String get dimensionsNextMeasure => 'Next: measure walls';

  @override
  String get dimensionsConvert3d => 'Convert to 3D';

  @override
  String get dimensionsAddRoom => '+ Add room';

  @override
  String dimensionsRoomDefaultName(int number) {
    return 'Room $number';
  }

  @override
  String get dimensionsRoomNameLabel => 'Room name';

  @override
  String get dimensionsLengthLabel => 'Length (m)';

  @override
  String get dimensionsWidthLabel => 'Width (m)';

  @override
  String get dimensionsHeightLabel => 'Height (m)';

  @override
  String get dimensionsUploadTitle => 'Upload a floorplan image';

  @override
  String get dimensionsUploadHint =>
      'PNG or JPG · max 10 MB\nOr drag and drop here';

  @override
  String get dimensionsChooseFile => 'Choose file';

  @override
  String get dimensionsUploadNote =>
      'For accurate results, upload a plan with dimensions shown';

  @override
  String get openingAddTitle => 'Add door/window';

  @override
  String get openingAddSpaced => 'Add Door / Window';

  @override
  String get openingTypeDoor => 'Door';

  @override
  String get openingTypeWindow => 'Window';

  @override
  String get openingTypeBalcony => 'Balcony door';

  @override
  String get openingSizeLabel => 'Size (cm)';

  @override
  String get openingSizeOther => 'Other size…';

  @override
  String get openingPositionLabel => 'Position along the wall';

  @override
  String get openingAddToWall => 'Add to wall';

  @override
  String get newProjectTitle => 'New project';

  @override
  String get newProjectSubtitle => 'How would you like to add a room?';

  @override
  String get newProjectWizardTitle => '3D Wizard';

  @override
  String get newProjectWizardDesc =>
      'Enter room dimensions in an interactive 3D view';

  @override
  String get newProjectLidarTitle => 'LiDAR scanner';

  @override
  String get newProjectLidarDesc =>
      'Scan the room with LiDAR and get an automatic 3D model';

  @override
  String get newProjectPhotoTitle => '360° Photo scan';

  @override
  String get newProjectPhotoDesc =>
      'Take a 360° photo of the room — the app detects the points automatically';

  @override
  String get newProjectDrawTitle => 'Draw it yourself';

  @override
  String get newProjectDrawDesc =>
      'Draw the room with your finger — dimensions are calculated automatically from your drawing';

  @override
  String get summarySavedTitle => 'Dimensions saved!';

  @override
  String get summaryStatFloor => 'floor';

  @override
  String get summaryStatWallNet => 'wall (net)';

  @override
  String get summaryStatPerimeter => 'perimeter';

  @override
  String get summaryStatOpenings => 'door/window';

  @override
  String summaryOpeningsCount(int count) {
    return '$count';
  }

  @override
  String get summaryOpeningsNote =>
      'Doors/windows automatically subtracted (net)';

  @override
  String get summaryAddRoom => '+ Add new room';

  @override
  String get roomSetupDefaultProjectName => 'Living room renovation';

  @override
  String get roomSetupWallLabelA => 'Wall A';

  @override
  String get roomSetupWallLabelB => 'Wall B';

  @override
  String get roomSetupWallLabelC => 'Wall C';

  @override
  String get roomSetupWallLabelD => 'Wall D';

  @override
  String get roomSetupWallLabelFallback => 'Wall';

  @override
  String get wizardTitle => 'New room';

  @override
  String get wizardCeilingQuestion => 'Ceiling height?';

  @override
  String get wizardCeilingHint => 'Usually between 2.5–3.2 meters';

  @override
  String get wizardExactValue => 'Exact value (m)';

  @override
  String wizardCeilingOutOfRange(String min, String max) {
    return 'Ceiling height must be between $min m and $max m';
  }

  @override
  String wizardWallTitle(String letter) {
    return 'Wall $letter';
  }

  @override
  String get wizardWallSubtitle => 'Enter the length';

  @override
  String get wizardSummaryTitle => 'Dimensions ready';

  @override
  String get wizardSummarySubtitle =>
      'Pick the estimate or start decorating — that\'s when the room is saved';

  @override
  String get wizardStatFloor => 'FLOOR AREA';

  @override
  String get wizardStatWallNet => 'WALL AREA (NET)';

  @override
  String get wizardStatPerimeter => 'PERIMETER';

  @override
  String get wizardStatOpenings => 'DOORS/WINDOWS';

  @override
  String get wizardViewSmeta => 'View estimate';

  @override
  String get wizardOpening => 'Opening…';

  @override
  String get wizardStartDesign => 'Start decorating';

  @override
  String get measureOpenings => 'Doors / windows';

  @override
  String measureFromLeft(String offset) {
    return '$offset m from left';
  }

  @override
  String get lidarScanning => 'Scanning...';

  @override
  String get lidarMoveHint => 'Move your phone slowly';

  @override
  String get lidarLabelWall => 'wall';

  @override
  String get lidarLabelDoor => 'door';

  @override
  String get lidarLabelWindow => 'window';

  @override
  String photoPointsCount(int captured, int total) {
    return '$captured/$total points';
  }

  @override
  String get photoTurnHint => 'Turn your phone to the next point';

  @override
  String get photoCapture => 'Capture';

  @override
  String get scanReviewTitle => 'Scan result';

  @override
  String scanReviewDetected(String value) {
    return 'Detected: $value';
  }

  @override
  String scanReviewWalls(int count) {
    return 'Walls ($count)';
  }

  @override
  String scanReviewWall(int number) {
    return 'Wall $number';
  }

  @override
  String scanReviewObjects(int count) {
    return 'Found objects ($count)';
  }

  @override
  String get scanReviewNoObjects => 'No objects found';

  @override
  String scanReviewObjectsDetectedNotice(int count) {
    return '$count objects detected — you\'ll see them in Studio under \"Scan view\"';
  }

  @override
  String get scanReviewRescan => 'Rescan';

  @override
  String get scanReviewSummaryTitle => 'What was detected';

  @override
  String get scanReviewSummaryWalls => 'Walls';

  @override
  String get scanReviewSummaryDoors => 'Doors';

  @override
  String get scanReviewSummaryWindows => 'Windows';

  @override
  String get scanReviewSummaryObjects => 'Objects';

  @override
  String scanReviewSummaryLowConfidence(int count) {
    return '$count items were measured with low confidence — please check the dimensions.';
  }

  @override
  String get scanReviewSummaryNoOpenings =>
      'No doors or windows found. Glass and open doors are often not detected.';

  @override
  String get scanReviewSummaryRescanHint => 'Rescan closer and slower.';

  @override
  String get scanReviewSaveFailed =>
      'Couldn\'t save the room. Check your internet connection.';

  @override
  String scanReviewUploadFailed(String error) {
    return 'Scan files failed to upload: $error The room was saved; you can rescan later.';
  }

  @override
  String scanReviewThumbnailFailed(String error) {
    return 'Room preview failed to upload: $error The project card will show without an image.';
  }

  @override
  String scanReviewError(String error) {
    return 'Error: $error';
  }

  @override
  String scanReviewCeilingHeightValue(String h) {
    return '$h m';
  }

  @override
  String get pendingScanTitle => 'Unfinished scan found';

  @override
  String get pendingScanBody =>
      'You scanned a room earlier but left before tapping \"Continue\". Resume it now?';

  @override
  String get pendingScanResume => 'Resume';

  @override
  String get pendingScanDiscard => 'Discard';

  @override
  String get scanCategoryTable => 'Table';

  @override
  String get scanCategoryChair => 'Chair';

  @override
  String get scanCategorySofa => 'Sofa';

  @override
  String get scanCategoryBed => 'Bed';

  @override
  String get scanCategoryStorage => 'Storage';

  @override
  String get scanCategoryRefrigerator => 'Refrigerator';

  @override
  String get scanCategoryStove => 'Stove';

  @override
  String get scanCategorySink => 'Sink';

  @override
  String get scanCategoryToilet => 'Toilet';

  @override
  String get scanCategoryBathtub => 'Bathtub';

  @override
  String get scanCategoryWasher => 'Washing machine';

  @override
  String get scanCategoryTelevision => 'Television';

  @override
  String get scanCategoryFireplace => 'Fireplace';

  @override
  String get scanCategoryStairs => 'Stairs';

  @override
  String get scanCategoryOther => 'Other';

  @override
  String get scanBusy => 'The scanner is already running.';

  @override
  String get scanFailedRetry => 'Scanning failed. Please try again.';

  @override
  String scanErrorPrefixed(String message) {
    return 'Error: $message';
  }

  @override
  String get scanNotDetected => 'Room not detected. Please try again.';

  @override
  String get scanLidarUnavailableTitle => 'LiDAR unavailable';

  @override
  String get scanLidarUnavailableBody =>
      'LiDAR scanning only works on devices with LiDAR: iPhone Pro (12 Pro or newer) or iPad Pro. Add the room another way:';

  @override
  String get scanInProgress => 'Scanning room…';

  @override
  String get drawTitle => 'Draw the room';

  @override
  String get drawModeManual => 'Manual';

  @override
  String get drawModeVisual => 'Visual';

  @override
  String get drawHintRaw =>
      'Raw sketch. Tap the button to return to \"Clean\".';

  @override
  String get drawHintShapeReady => 'Shape ready! Drag the corners to resize.';

  @override
  String get drawHintFreehand => 'Draw the room\'s shape with your finger.';

  @override
  String get drawHintMarkCorners => 'Mark the room\'s corners (at least 3).';

  @override
  String drawHintMorePoints(int count) {
    return 'Add $count more points.';
  }

  @override
  String get drawHintClose => 'Tap the first point or \"Close\" to finish.';

  @override
  String get drawToggleClean => 'Clean';

  @override
  String get drawToggleRaw => 'Raw';

  @override
  String get drawRedo => 'Redo';

  @override
  String get drawClear => 'Clear';

  @override
  String get drawWallLength => 'Wall length';

  @override
  String get drawAreaWarning => 'Warning: area is outside the typical range';

  @override
  String drawTitleRect(String width, String length, String height) {
    return 'Room: $width × $length × $height m';
  }

  @override
  String drawTitlePolygon(int corners, String width, String length) {
    return 'Polygon · $corners walls · $width×$length m';
  }

  @override
  String get a11yQuantityDecrease => 'Decrease quantity';

  @override
  String get a11yQuantityIncrease => 'Increase quantity';

  @override
  String get a11yRemoveFromCart => 'Remove from cart';

  @override
  String get a11yAddToCart => 'Add to cart';

  @override
  String get a11yCallDealer => 'Call';

  @override
  String get a11yMessageDealer => 'Send message';

  @override
  String shopDealerPhoneUnavailable(String dealer) {
    return '$dealer: phone number not available yet';
  }

  @override
  String shopDealerMessageUnavailable(String dealer) {
    return 'Messaging with $dealer isn\'t available yet';
  }

  @override
  String get a11yEditProfile => 'Edit profile';

  @override
  String get a11yMastersListView => 'List view';

  @override
  String get settingsScreenTitle => 'Preferences';

  @override
  String get settingsNotificationsSectionTitle => 'Notifications';

  @override
  String get settingsPushNotificationsTitle => 'Push Notifications';

  @override
  String get settingsPushNotificationsSubtitle =>
      'Get updates about projects and contractors';

  @override
  String get settingsEmailDigestTitle => 'Email Digest';

  @override
  String get settingsEmailDigestSubtitle => 'Weekly summary of your projects';

  @override
  String get settingsMarketingEmailsTitle => 'Marketing Emails';

  @override
  String get settingsMarketingEmailsSubtitle =>
      'News about new features and offers';

  @override
  String get settingsUnitsDisplaySectionTitle => 'Units & Display';

  @override
  String get settingsMeasurementUnitsTitle => 'Measurement Units';

  @override
  String get settingsUnitMetric => 'Metric (m²)';

  @override
  String get settingsUnitImperial => 'Imperial (ft²)';

  @override
  String get settingsThemeTitle => 'Theme';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsLargeTextTitle => 'Large Text';

  @override
  String get settingsLargeTextSubtitle =>
      'Increase text size for better readability';

  @override
  String get settingsProjectSettingsSectionTitle => 'Project Settings';

  @override
  String get settingsAutoSaveTitle => 'Auto-Save Projects';

  @override
  String get settingsAutoSaveSubtitle =>
      'Automatically save your work as you progress';

  @override
  String get settingsCloudSyncTitle => 'Cloud Sync';

  @override
  String get settingsCloudSyncSubtitle =>
      'Sync projects across all your devices';

  @override
  String get settingsCloudSyncEnabledMessage => 'Cloud sync turned on';

  @override
  String get settingsCloudSyncDisabledMessage => 'Cloud sync turned off';

  @override
  String get settingsClearCacheTitle => 'Clear Cache';

  @override
  String get settingsClearCacheSubtitle => 'Free up storage space';

  @override
  String get settingsClearingCacheInProgress => 'Clearing...';

  @override
  String get settingsCacheClearedMessage => 'Cache cleared';

  @override
  String settingsCacheClearFailedMessage(String error) {
    return 'Couldn\'t clear cache: $error';
  }

  @override
  String get settingsPrivacySecuritySectionTitle => 'Privacy & Security';

  @override
  String get settingsPrivacyPolicyTitle => 'Privacy Policy';

  @override
  String get settingsPrivacyPolicySubtitle => 'Read our privacy policy';

  @override
  String get settingsTermsOfServiceTitle => 'Terms of Service';

  @override
  String get settingsTermsOfServiceSubtitle => 'Review terms and conditions';

  @override
  String settingsLinkOpenFailedMessage(String url) {
    return 'Couldn\'t open the link: $url';
  }

  @override
  String get settingsAboutSectionTitle => 'About';

  @override
  String get settingsAppVersionLabel => 'App Version';

  @override
  String get settingsBuildNumberLabel => 'Build Number';

  @override
  String get settingsCheckForUpdatesButton => 'Check for Updates';

  @override
  String get settingsUpdatesDialogTitle => 'Updates';

  @override
  String get settingsUpdatesDialogBody =>
      'You\'re on the latest version of the app.';

  @override
  String get settingsUpdatesDialogOk => 'OK';

  @override
  String get registerRoleTitle => 'Who are you?';

  @override
  String get roleUser => 'User';

  @override
  String get roleUserDesc => 'For my own renovation and design projects';

  @override
  String get roleShop => 'Shop owner';

  @override
  String get roleShopDesc => 'I sell furniture and materials';

  @override
  String get roleUsta => 'Craftsman';

  @override
  String get roleUstaDesc => 'I offer renovation services';

  @override
  String get businessApplyShopTitle => 'Shop application';

  @override
  String get businessApplyUstaTitle => 'Craftsman application';

  @override
  String get businessApplyIntro =>
      'Fill in your details. Once the admins review and approve, you will appear in the list.';

  @override
  String get businessFieldShopName => 'Shop name';

  @override
  String get businessFieldUstaName => 'Your name or team name';

  @override
  String get businessFieldTrade => 'Your trade';

  @override
  String get businessFieldDistrict => 'District';

  @override
  String get businessFieldPhone => 'Phone (+998...)';

  @override
  String get businessFieldTelegram => 'Telegram (optional)';

  @override
  String get businessFieldPriceMin => 'From';

  @override
  String get businessFieldPriceMax => 'Up to';

  @override
  String get businessFieldPriceTitle => 'Price (UZS)';

  @override
  String get businessSubmit => 'Submit application';

  @override
  String get businessSkip => 'Later';

  @override
  String get businessErrorName => 'Enter a name';

  @override
  String get businessErrorPhone => 'Enter the full phone number with +998';

  @override
  String get businessErrorPrice =>
      'The maximum price cannot be below the minimum';

  @override
  String get businessErrorExists => 'You already have this application';

  @override
  String get businessErrorFailed =>
      'Could not send the application. Please try again.';

  @override
  String get businessTitle => 'My business';

  @override
  String get businessShopSection => 'Shop';

  @override
  String get businessUstaSection => 'Craftsman profile';

  @override
  String get businessStatusPending => 'Under review';

  @override
  String get businessStatusApproved => 'Approved';

  @override
  String get businessStatusRejected => 'Rejected';

  @override
  String get businessPendingHint =>
      'Your application is with the admins. Once approved you will appear in the list.';

  @override
  String get businessApprovedHint => 'Your profile is visible in the list.';

  @override
  String get businessResubmit => 'Resubmit';

  @override
  String get businessComingProducts => 'Product management coming soon';

  @override
  String get businessComingRequests => 'Customer requests coming soon';

  @override
  String get businessLoadFailed => 'Could not load the data';

  @override
  String get profileMenuBusiness => 'My business';

  @override
  String get profileMenuBecomePartner => 'Join as a shop or craftsman';

  @override
  String get tradeElektrik => 'Electrician';

  @override
  String get tradeElektrikLoyihachi => 'Electrical designer';

  @override
  String get tradeSantexnik => 'Plumber';

  @override
  String get tradeMalyar => 'Painter';

  @override
  String get tradeOboy => 'Wallpaper installer';

  @override
  String get tradeLaminat => 'Laminate installer';

  @override
  String get tradeBrigada => 'Crew';

  @override
  String businessRejectedReason(String note) {
    return 'Reason: $note';
  }

  @override
  String get shopProductsTitle => 'My products';

  @override
  String get shopProductsEmpty =>
      'No products yet. Take a photo and add your first one.';

  @override
  String get shopProductsOpen => 'Manage products';

  @override
  String get shopProductVisible => 'Visible in the catalog';

  @override
  String get shopProductEdit => 'Edit';

  @override
  String get shopProductName => 'Name';

  @override
  String get shopProductPrice => 'Price (UZS)';

  @override
  String get shopProductSave => 'Save';

  @override
  String get shopProductDelete => 'Delete';

  @override
  String get shopProductDeleteConfirm =>
      'Delete this product? This cannot be undone.';

  @override
  String get shopProductCancel => 'Cancel';

  @override
  String get shopProductFailed => 'Could not complete the action. Try again.';

  @override
  String get shopProductNoPrice => 'No price set';

  @override
  String get addProductTitle => 'New product';

  @override
  String get addProductPhotoHint =>
      'Take a clear photo of the furniture (a plain background works best). We build the 3D model.';

  @override
  String get addProductGallery => 'From gallery';

  @override
  String get addProductCamera => 'From camera';

  @override
  String get addProductCategory => 'Type';

  @override
  String get addProductRoom => 'Room';

  @override
  String get addProductRoomAll => 'All rooms';

  @override
  String get addProductPlacement => 'Placement';

  @override
  String get addProductSubmit => 'Build 3D model and add';

  @override
  String get addProductBuilding =>
      'Building the 3D model… about 1–2 minutes, keep the app open';

  @override
  String get addProductUploading => 'Adding the product to your shop…';

  @override
  String get addProductDone =>
      'Product added. It appears in the catalog once an admin approves it.';

  @override
  String get addProductNeedPhoto => 'Pick a photo first';

  @override
  String get addProductNeedName => 'Enter a name';

  @override
  String get addProductFailed =>
      'Could not build the 3D model. Try a different photo.';

  @override
  String get addProductUnavailable =>
      'The 3D model service is unavailable right now';

  @override
  String get addProductLimit =>
      'Today\'s limit is used up. Try again tomorrow.';

  @override
  String get addProductTooMany =>
      'Many products await approval. Wait for them to be reviewed.';

  @override
  String get categoryDivan => 'Sofa';

  @override
  String get categoryStol => 'Table';

  @override
  String get categoryStul => 'Chair';

  @override
  String get categoryKaravot => 'Bed';

  @override
  String get categoryShkaf => 'Wardrobe';

  @override
  String get categoryLampa => 'Lamp';

  @override
  String get categoryBoshqa => 'Other';

  @override
  String get roomMehmonxona => 'Living room';

  @override
  String get roomOshxona => 'Kitchen';

  @override
  String get roomYotoqxona => 'Bedroom';

  @override
  String get roomHammom => 'Bathroom';

  @override
  String get roomBalkon => 'Balcony';

  @override
  String get placementPol => 'Floor';

  @override
  String get placementDevor => 'Wall';

  @override
  String get placementShift => 'Ceiling';

  @override
  String get ustaLeadsTitle => 'Customer requests';

  @override
  String get ustaLeadsOpen => 'Customer requests';

  @override
  String get ustaLeadsEmpty =>
      'No requests yet. They show up here when customers contact you with an estimate.';

  @override
  String get ustaLeadCall => 'Call';

  @override
  String get ustaLeadNoPhone => 'No phone given';

  @override
  String get ustaLeadClient => 'Customer';

  @override
  String ustaLeadEstimate(String total, int lines) {
    return 'Estimate: $total ($lines lines)';
  }

  @override
  String get leadStatusNew => 'New';

  @override
  String get leadStatusViewed => 'Viewed';

  @override
  String get leadStatusContacted => 'Contacted';

  @override
  String get leadStatusClosed => 'Closed';

  @override
  String get ustaLeadMarkViewed => 'Viewed';

  @override
  String get ustaLeadMarkContacted => 'Contacted';

  @override
  String get ustaLeadMarkClosed => 'Close';

  @override
  String get ustaEditOpen => 'Edit profile';

  @override
  String get ustaEditTitle => 'My craftsman profile';

  @override
  String get ustaEditSave => 'Save';

  @override
  String get ustaEditFailed => 'Could not save. Try again.';

  @override
  String get shopEditTitle => 'Shop profile';

  @override
  String get addProductMoreAngles => 'More angles (optional)';

  @override
  String get addProductMoreAnglesHint =>
      'Photos from the left, back and right make the 3D model more accurate.';

  @override
  String get addProductAngleLeft => 'Left';

  @override
  String get addProductAngleBack => 'Back';

  @override
  String get addProductAngleRight => 'Right';

  @override
  String get addProductAngleRemove => 'Remove';

  @override
  String get shopInquiriesTitle => 'Customer inquiries';

  @override
  String get shopInquiriesOpen => 'Inquiries';

  @override
  String shopInquiriesOpenWithNew(int count) {
    return 'Inquiries ($count new)';
  }

  @override
  String get shopInquiriesEmpty =>
      'No inquiries yet. When customers ask about your products they will show up here.';

  @override
  String shopInquiryProduct(String name) {
    return 'Product: $name';
  }

  @override
  String get shopStatsOpen => 'Statistics';

  @override
  String get shopStatsTitle => 'Shop statistics';

  @override
  String get shopStatsProducts => 'Products';

  @override
  String get shopStatsApproved => 'Approved';

  @override
  String get shopStatsPending => 'Pending review';

  @override
  String get shopStatsRejected => 'Rejected';

  @override
  String get shopStatsVisible => 'Visible in catalog';

  @override
  String get shopStatsInquiries => 'Inquiries';

  @override
  String get shopStatsNewInquiries => 'New inquiries';

  @override
  String get shopStatsPlacements => 'Times placed in rooms';

  @override
  String get shopStatsTop => 'Most used products';

  @override
  String get shopStatsTopEmpty => 'No data yet.';

  @override
  String get mastersSendFailed => 'Could not send. Try again.';

  @override
  String shopCheckoutUnlinkedLines(String names) {
    return 'Some cart items are not linked to a shop catalog item, so the order cannot be placed: $names. Remove them from the cart.';
  }

  @override
  String shopOrderPartial(String dealer, String error) {
    return 'The order from $dealer was not accepted: $error The other orders were sent.';
  }

  @override
  String get shopOrdersTitle => 'Orders';

  @override
  String get shopOrdersOpen => 'Orders';

  @override
  String get shopOrdersEmpty =>
      'No orders yet. When customers order, they will show up here.';

  @override
  String get shopOrderMarkGathering => 'Mark as gathering';

  @override
  String get shopOrderMarkOnTheWay => 'Mark as on the way';

  @override
  String get shopOrderMarkDelivered => 'Mark as delivered';

  @override
  String shopOrderAddressLine(String value) {
    return 'Address: $value';
  }

  @override
  String shopOrderPaymentLine(String value) {
    return 'Payment: $value';
  }

  @override
  String get shopOrderPayCash => 'Cash';

  @override
  String get shopOrderPayCard => 'Card';

  @override
  String get tradePlitkachi => 'Tiler';

  @override
  String get tradeShtukatur => 'Plasterer';

  @override
  String get tradeGipsokartonchi => 'Drywall installer';

  @override
  String get tradeEshikOyna => 'Door & window installer';

  @override
  String get tradeIsitishKonditsioner => 'Heating & AC technician';

  @override
  String get tradeDemontaj => 'Demolition worker';

  @override
  String get ustaPortfolioOpen => 'Portfolio';

  @override
  String get ustaPortfolioTitle => 'My portfolio';

  @override
  String get ustaPortfolioEmpty =>
      'No work photos yet. Add the jobs you have done.';

  @override
  String get ustaPortfolioAdd => 'Add photo';

  @override
  String get ustaPortfolioCaption => 'Caption (optional)';

  @override
  String get ustaPortfolioUpload => 'Upload';

  @override
  String get ustaPortfolioDeleteConfirm =>
      'Delete this photo? This cannot be undone.';

  @override
  String get ustaPortfolioLoadFailed => 'Could not load the portfolio.';

  @override
  String ustaLeadMessage(String message) {
    return 'Client\'s message: $message';
  }

  @override
  String get profileMenuDeleteAccount => 'Delete account';

  @override
  String get deleteAccountTitle => 'Delete your account?';

  @override
  String get deleteAccountBody =>
      'Your projects, photos, orders and any shop or usta profile will be deleted along with your account. This is permanent and cannot be undone.';

  @override
  String get deleteAccountPasswordLabel => 'Password';

  @override
  String get deleteAccountPasswordHint =>
      'If you sign in with a phone code, leave this empty';

  @override
  String get deleteAccountDone => 'Your account was deleted';

  @override
  String scanFailedReason(String reason) {
    return 'Reason: $reason';
  }

  @override
  String get shopCategoryBoyoq => 'Paint';

  @override
  String get shopCategoryOboy => 'Wallpaper';

  @override
  String get shopCategoryLaminat => 'Laminate';

  @override
  String get shopCategoryKafel => 'Tiles';

  @override
  String get shopCategoryParket => 'Parquet';

  @override
  String get shopCategoryGips => 'Plaster';

  @override
  String get shopCategorySement => 'Cement';

  @override
  String get shopCategorySantexnika => 'Plumbing';

  @override
  String get shopCategoryElektr => 'Electrical';

  @override
  String get shopCategoryEshik => 'Doors';

  @override
  String get shopCategoryDeraza => 'Windows';

  @override
  String get tradeBoshqa => 'Other tradesperson';

  @override
  String get qualityTierEkonom => 'Economy';

  @override
  String get qualityTierStandart => 'Standard';

  @override
  String get qualityTierPremium => 'Premium';

  @override
  String get estimateOpen3dStudio => '3D Studio';

  @override
  String get actionDelete => 'Delete';

  @override
  String get mapAttribution => '© OpenStreetMap contributors';

  @override
  String get pushPromptTitle => 'Shall we notify you?';

  @override
  String get pushPromptBody =>
      'We\'ll tell you when your design is ready or your order status changes.';

  @override
  String get pushPromptYes => 'Yes';

  @override
  String get pushPromptLater => 'Later';

  @override
  String get settingsNotificationsTitle => 'Notifications';

  @override
  String get settingsNotificationsOn => 'On';

  @override
  String get settingsNotificationsOff => 'Off';

  @override
  String get pushChannelName => 'Andoza updates';

  @override
  String get sharePinTitle => 'Pinterest pin';

  @override
  String get sharePinChooseRoom => 'Which room is it for?';

  @override
  String get sharePinHint => 'The Studio\'s AI designer opens with this pin.';

  @override
  String get sharePinNoRooms => 'No rooms yet. Add one with \"+\" first.';

  @override
  String get sharePinNotPin => 'This is not a Pinterest pin link';

  @override
  String get sharePinNotPinHint =>
      'Open the pin in the Pinterest app and choose Share → Andoza AI.';

  @override
  String get furnitureStylesLabel => 'Styles';

  @override
  String get furnitureStylesAll => 'Suits every style';

  @override
  String get furnitureStyleNeoklassika => 'Neoclassical';

  @override
  String get furnitureStyleKlassik => 'Classic';

  @override
  String get furnitureStyleZamonaviy => 'Modern';

  @override
  String get furnitureStyleHitech => 'Hi-Tech';

  @override
  String get furnitureStyleMinimalist => 'Minimalist';

  @override
  String get furnitureStyleSkandinav => 'Scandinavian';

  @override
  String get furnitureStyleLoft => 'Loft';

  @override
  String get furnitureStyleMilliy => 'National';

  @override
  String get estimateFloorStandIn =>
      'No floor product is chosen, so the price is the shops\' median floor (approximate).';

  @override
  String get scanChoiceTitle => 'What are we scanning?';

  @override
  String get scanChoiceOneRoom => 'One room';

  @override
  String get scanChoiceFlat => 'Several rooms (apartment)';

  @override
  String get scanChoiceFlatHint =>
      'Scan the rooms one after another — they land in place on the plan';

  @override
  String get scanNextRoom => 'Next room';

  @override
  String get scanFinish => 'Finish';

  @override
  String scanRoomN(int n) {
    return 'Room $n';
  }

  @override
  String get flatReviewTitle => 'Scanned rooms';

  @override
  String get flatReviewRoomName => 'Room name';

  @override
  String get flatReviewContinue => 'Open in the studio';

  @override
  String flatReviewPartial(int n) {
    return 'The scan stopped — $n rooms kept';
  }

  @override
  String flatReviewDropped(int n) {
    return '$n rooms could not be read and were left out';
  }

  @override
  String flatReviewSavedSome(int saved, int total) {
    return '$saved of $total rooms saved — scan the rest again';
  }

  @override
  String get loginWithApple => 'Sign in with Apple';

  @override
  String get loginAppleFailed =>
      'Couldn\'t sign in with Apple. Please try again.';

  @override
  String get reportAction => 'Report';

  @override
  String get reportTitle => 'Report';

  @override
  String get reportHint =>
      'What\'s wrong? Our moderators will review your report.';

  @override
  String get reportReasonSpam => 'Spam or advertising';

  @override
  String get reportReasonInappropriate => 'Inappropriate content';

  @override
  String get reportReasonFraud => 'Fraud or scam';

  @override
  String get reportReasonOther => 'Other';

  @override
  String get reportDetails => 'Details (optional)';

  @override
  String get reportSend => 'Send';

  @override
  String get reportSent => 'Thanks! Your report has been sent.';

  @override
  String get blockUstaAction => 'Block';

  @override
  String get blockUstaTitle => 'Block this craftsman?';

  @override
  String get blockUstaBody => 'They will no longer appear on your map or list.';

  @override
  String get blockUstaConfirm => 'Block';

  @override
  String get blockUstaDone => 'Craftsman blocked';

  @override
  String get shopFurnitureSection => 'Furniture';

  @override
  String get shopFurnitureNoPrice => 'Price on request';

  @override
  String storePageOpen(String name) {
    return '$name shop';
  }

  @override
  String get storeLoadFailed => 'Couldn\'t open the shop';

  @override
  String get storeCall => 'Call';

  @override
  String get storeTelegram => 'Telegram';

  @override
  String get storeNoProducts => 'This shop has no products yet';

  @override
  String get storeReport => 'Report this shop';

  @override
  String get furnitureSize => 'Size';

  @override
  String furnitureSizeValue(String size) {
    return '$size cm';
  }

  @override
  String get furniturePlaceInRoom => 'Place in my room';

  @override
  String get furniturePickRoom => 'Which room?';

  @override
  String get furnitureNoRooms => 'Create or scan a room first';

  @override
  String get furnitureNoModel =>
      'This product has no 3D model, so it can\'t be placed in a room';

  @override
  String get furnitureLoadFailed => 'Couldn\'t open the product';

  @override
  String get profileMenuMebel => 'Furniture manufacturing';

  @override
  String get profileMenuMebelHint =>
      'For workshops: cabinet parts, edge banding and price';

  @override
  String get mebelExportFailed => 'Couldn\'t open the file';

  @override
  String get scanHintStart => 'Walk slowly around the room to scan it';

  @override
  String get scanCoachMoveCloser => 'Hold the phone closer to the wall';

  @override
  String get scanCoachMoveAway => 'Move the phone a little away from the wall';

  @override
  String get scanCoachSlowDown => 'You\'re moving too fast — slow down';

  @override
  String get scanCoachTurnOnLight => 'The room is dark — turn on the light';

  @override
  String get scanCoachLowTexture =>
      'This surface is too plain — point the camera elsewhere';

  @override
  String get scanCoachGood =>
      'Going well — keep walking around the room at this pace';

  @override
  String get scanCoachKeepGoing => 'Keep scanning';
}
