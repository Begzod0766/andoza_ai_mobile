// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Andoza AI';

  @override
  String get actionRetry => 'Повторить попытку';

  @override
  String get actionBack => 'Назад';

  @override
  String get actionNext => 'Далее';

  @override
  String get actionContinue => 'Продолжить';

  @override
  String get actionCancel => 'Отмена';

  @override
  String get actionSave => 'Сохранить';

  @override
  String get actionClose => 'Закрыть';

  @override
  String get actionDone => 'Готово';

  @override
  String get actionFinish => 'Завершить';

  @override
  String get navHome => 'Главная';

  @override
  String get navShop => 'Магазин';

  @override
  String get navMasters => 'Мастера';

  @override
  String get navProfile => 'Профиль';

  @override
  String get loginEmailHint => 'Email';

  @override
  String get loginPasswordHint => 'Пароль';

  @override
  String get loginShowPassword => 'Показать пароль';

  @override
  String get loginHidePassword => 'Скрыть пароль';

  @override
  String get loginButton => 'Войти';

  @override
  String get loginEmptyFields => 'Пожалуйста, заполните все поля';

  @override
  String get b1Question => 'В каком состоянии сейчас ваша комната?';

  @override
  String get b1DontKnowDifference => 'Не знаете разницу? →';

  @override
  String get b1FloorCeilingDifferent => 'Если пол или потолок отличаются →';

  @override
  String get b1EnterRoom => 'Войти в комнату';

  @override
  String get brandName => 'AndozaAI';

  @override
  String get navAddProject => 'Добавить новый проект';

  @override
  String get loginPhoneLabel => 'Номер телефона';

  @override
  String get loginPhoneSubtitle => 'Для входа требуется номер телефона';

  @override
  String get loginPhoneHint => '90 123 45 67';

  @override
  String get loginPhoneSmsHint => 'SMS-код будет отправлен на этот номер';

  @override
  String get loginSendOtp => 'Отправить код';

  @override
  String get loginOtpInfoBox =>
      'На указанный номер будет отправлен 6-значный код. Если SMS не приходит, повторите попытку через 2-3 минуты.';

  @override
  String get loginWithUsername => 'Войти по имени пользователя';

  @override
  String get loginCodeSentTitle => '✓ Код отправлен';

  @override
  String get loginCodeSentSuffix => ' — отправим 6-значный код на этот номер';

  @override
  String get loginVerify => 'Подтвердить';

  @override
  String get loginResend => 'Отправить повторно';

  @override
  String loginResendCountdown(int seconds) {
    return 'Отправить повторно ($seconds с)';
  }

  @override
  String get loginBackArrow => '← Назад';

  @override
  String get loginSignIn => 'Вход';

  @override
  String get loginUsernameHint => 'Имя пользователя';

  @override
  String get loginPasswordLabel => 'Пароль';

  @override
  String get loginNoAccount => 'Нет аккаунта? ';

  @override
  String get loginRegister => 'Регистрация';

  @override
  String get loginNameHint => 'Имя (необязательно)';

  @override
  String get loginConfirmPasswordHint => 'Подтвердите пароль';

  @override
  String get loginHaveAccount => 'Уже есть аккаунт? ';

  @override
  String get loginWithGoogle => 'Войти через Google';

  @override
  String get loginGoogleFailed =>
      'Не удалось войти через Google. Попробуйте ещё раз.';

  @override
  String get loginOr => 'или';

  @override
  String get loginTagline => 'Проекты ремонта и интерьера в одном месте';

  @override
  String get loginVersion => 'AndozaAI v1.0.0';

  @override
  String get loginErrorInvalidPhone =>
      'Неверный номер телефона. Например: 90 123 45 67';

  @override
  String get loginErrorServer => 'Ошибка сервера. Попробуйте снова.';

  @override
  String get loginErrorInvalidCode => 'Код неверный или устарел.';

  @override
  String get loginErrorCredentialsRequired =>
      'Имя пользователя и пароль обязательны.';

  @override
  String get loginErrorWrongCredentials =>
      'Неверное имя пользователя или пароль.';

  @override
  String get loginErrorUsernameShort =>
      'Имя пользователя должно содержать не менее 3 символов.';

  @override
  String get loginErrorUsernameLong =>
      'Имя пользователя должно быть не длиннее 50 символов.';

  @override
  String get loginErrorPasswordShort =>
      'Пароль должен содержать не менее 6 символов.';

  @override
  String get loginErrorPasswordMismatch => 'Пароли не совпадают.';

  @override
  String get loginErrorUsernameTaken => 'Это имя пользователя уже занято.';

  @override
  String get loginErrorRegisterFailed => 'Ошибка при регистрации.';

  @override
  String get homeWelcome => 'Добро пожаловать';

  @override
  String homeGreetingNamed(String name) {
    return 'Привет, $name! 👋';
  }

  @override
  String get homeGreeting => 'Привет! 👋';

  @override
  String get homeStoryHowItWorks => 'Как это работает?';

  @override
  String get homeStoryDemoGuide => 'Демо-гид';

  @override
  String get homeStoryDemo => 'Демо';

  @override
  String get homeEmptyTitle => 'Добавьте свою первую комнату';

  @override
  String get homeEmptyMessage => 'Проектов пока нет — начните новый проект';

  @override
  String get homeEmptyAction => '+ Добавить проект';

  @override
  String get homeQuickActions => 'Быстрые действия';

  @override
  String get homeQuickScan => 'Сканировать комнату';

  @override
  String get homeQuickEstimate => 'Смета';

  @override
  String get homeQuickDealers => 'Дилеры';

  @override
  String get homeProjectsLoadError => 'Не удалось загрузить проекты';

  @override
  String get homeLoadMore => 'Показать ещё';

  @override
  String get homeLegendExisting => 'Имеется (не учитывается)';

  @override
  String get homeLegendNeeded => 'Нужно (дельта)';

  @override
  String get homeResume => 'Продолжить';

  @override
  String get homeNoRoomYet => 'В этом проекте пока нет комнаты';

  @override
  String homeStageProgress(int current) {
    return 'Этап $current/8';
  }

  @override
  String homeStageProgressExcluded(int current, String names) {
    return 'Этап $current/8 · ✓ $names уже было';
  }

  @override
  String homeStageProgressExcludedCount(int current, int count) {
    return 'Этап $current/8 · ✓ $count этапов уже было';
  }

  @override
  String get homeStagePickerTitle => 'Выберите этап';

  @override
  String homeStageOption(int index, String label) {
    return 'Этап $index/8 · $label';
  }

  @override
  String get homeStageSaveError => 'Не удалось сохранить этап';

  @override
  String homeRoomCount(int count) {
    return '$count комн.';
  }

  @override
  String get homeStatAreaLabel => 'Площадь';

  @override
  String get homeStatModelsLabel => '3D модель';

  @override
  String get homeStatEstimateLabel => 'Смета';

  @override
  String homeAreaValue(String area) {
    return '$area м²';
  }

  @override
  String homeEstimateMln(String amount) {
    return '$amount млн';
  }

  @override
  String get homeStatDash => '—';

  @override
  String get stageSuvoq => 'штукатурка';

  @override
  String get stageShpaklovka => 'шпаклёвка';

  @override
  String get stageBoyoqOboi => 'краска/обои';

  @override
  String get stagePol => 'пол';

  @override
  String get stageMebel => 'мебель';

  @override
  String get stageElektr => 'электрика';

  @override
  String get stageYoruglik => 'освещение';

  @override
  String get stageSantexnika => 'сантехника';

  @override
  String get commonYes => 'Да';

  @override
  String get commonNo => 'Нет';

  @override
  String get shopCartTooltip => 'Корзина';

  @override
  String get shopSearchHint => 'Поиск материалов...';

  @override
  String get shopFilterAll => 'Все';

  @override
  String get shopInProjectTag => 'В проекте';

  @override
  String get shopMaterialsTitle => 'Материалы проекта';

  @override
  String shopMaterialsAutoCalc(String area, int count) {
    return 'Приложение автоматически рассчитало на основе вашего проекта — $area м², $count этапов';
  }

  @override
  String get shopAddAllToCart => 'Выбранное в корзину';

  @override
  String get shopSelectRoomLabel => 'Для какой комнаты?';

  @override
  String shopSelectedCount(int count) {
    return 'Выбрано: $count';
  }

  @override
  String get shopOfficialDealer => '✓ Официальный дилер';

  @override
  String shopProjectNeed(String quantity, String unit) {
    return 'Для вашего проекта нужно ~$quantity $unit';
  }

  @override
  String get shopQuantityLabel => 'Количество:';

  @override
  String get shopSpecCoverage => 'Покрытие';

  @override
  String get shopSpecDryingTime => 'Время высыхания';

  @override
  String get shopSpecWashable => 'Моющийся';

  @override
  String shopWhereToBuy(String name) {
    return 'Где купить — $name';
  }

  @override
  String shopPriceFromDealer(String dealer) {
    return 'Цена от $dealer';
  }

  @override
  String get shopAddedToCart => 'Добавлено в корзину';

  @override
  String shopAddToCartPrice(String price) {
    return 'Добавить в корзину · $price';
  }

  @override
  String get shopDealerCompareTitle => 'Сравнение дилеров';

  @override
  String get shopFilterCheapest => 'Самый дешёвый';

  @override
  String get shopFilterOfficial => 'Официальный дилер';

  @override
  String get shopFilterFastest => 'Самый быстрый';

  @override
  String get shopBestRibbon => 'ЛУЧШЕЕ';

  @override
  String shopDeliveryDays(String district, int days) {
    return '$district · доставка за $days дн.';
  }

  @override
  String get shopSelect => 'Выбрать';

  @override
  String get shopCartTitle => 'Корзина';

  @override
  String get shopCartEmpty => 'Корзина пуста';

  @override
  String get shopMaterials => 'Материалы';

  @override
  String get shopDelivery => 'Доставка';

  @override
  String get shopGrandTotal => 'Итоговая сумма';

  @override
  String get shopCheckout => 'Оформить заказ';

  @override
  String get shopCheckoutTitle => 'Оплата';

  @override
  String get shopDeliveryAddress => 'Адрес доставки';

  @override
  String get shopAddressHint => 'Адрес';

  @override
  String get shopPhoneHint => 'Номер телефона';

  @override
  String get shopPaymentMethod => 'Способ оплаты';

  @override
  String get shopOrderSummary => 'Сводка заказа';

  @override
  String get shopAmountDue => 'К оплате';

  @override
  String get shopPay => 'Оплатить';

  @override
  String shopOrderSaveError(String error) {
    return 'Ошибка сохранения заказа на сервере: $error';
  }

  @override
  String get shopOrderStatusTitle => 'Статус заказа';

  @override
  String get shopOrderContents => 'Состав заказа';

  @override
  String get shopTotal => 'Итого';

  @override
  String get shopMasterNotified => 'Мастер уведомлён';

  @override
  String get shopHandToMaster => 'Передать мастеру';

  @override
  String get shopBackToShop => 'Вернуться в магазин';

  @override
  String get mastersNotFound => 'Мастер не найден';

  @override
  String get unsavedChangesTitle => 'Несохранённые изменения';

  @override
  String get unsavedChangesBody => 'Если выйти, введённые данные пропадут.';

  @override
  String get unsavedChangesLeave => 'Выйти';

  @override
  String get unsavedChangesStay => 'Остаться';

  @override
  String get roomSaveFailed =>
      'Комната не сохранилась на сервере. Проверьте интернет и попробуйте ещё раз.';

  @override
  String get newProjectArScanTitle => 'Измерить камерой';

  @override
  String get newProjectArScanDesc =>
      'Отметьте углы пола камерой телефона и получите план комнаты';

  @override
  String get arScanFindFloor =>
      'Наведите телефон на пол и медленно поводите им';

  @override
  String get arScanCornersHint =>
      'Наведите прицел на угол пола и добавьте угол';

  @override
  String get arScanAddCorner => 'Добавить угол';

  @override
  String get arScanUndo => 'Отменить';

  @override
  String get arScanFinish => 'Готово';

  @override
  String get arScanSnapToFirst => 'Подойдите к первому углу — контур замкнётся';

  @override
  String get arScanAimCeiling => 'Наведите на линию потолка над первым углом';

  @override
  String get arScanConfirm => 'Подтвердить';

  @override
  String get arScanEnterManually => 'Ввести вручную';

  @override
  String get arScanExit => 'Выйти';

  @override
  String get arScanExitConfirm =>
      'Прервать измерение? Отмеченные углы пропадут.';

  @override
  String get arScanTrackingLost =>
      'Мало света или телефон двигался слишком быстро';

  @override
  String get arScanFloorHint =>
      'Попробуйте при лучшем свете, наведите на ковёр или пол с узором';

  @override
  String get arScanCornersLost =>
      'Некоторые углы потерялись — отметьте их снова';

  @override
  String get arScanNoFloorHere => 'Сначала отсканируйте пол';

  @override
  String get arScanKeepMeasuring => 'Продолжить измерение';

  @override
  String get arScanStepFloor => '1/3 — пол';

  @override
  String get arScanStepCorners => '2/3 — углы';

  @override
  String get arScanStepHeight => '3/3 — высота';

  @override
  String get arScanRescan => 'Измерить заново';

  @override
  String get arScanNotInstalled =>
      'Для измерения камерой нужны «Сервисы Google Play для AR»';

  @override
  String get arScanInstall => 'Установить';

  @override
  String get arScanCameraDenied =>
      'Разрешите доступ к камере, чтобы измерить комнату';

  @override
  String get arScanOpenSettings => 'Открыть настройки';

  @override
  String get arScanUnsupported =>
      'На этом телефоне измерение камерой недоступно. Нарисуйте комнату или введите размеры.';

  @override
  String get arScanFailed => 'Не удалось измерить. Попробуйте ещё раз.';

  @override
  String get arScanRejected_too_few_corners => 'Нужно минимум 3 угла';

  @override
  String get arScanRejected_self_intersecting =>
      'Стены пересекаются — отмечайте углы по порядку';

  @override
  String get arScanRejected_wall_too_long =>
      'Одна стена длиннее 30 м — угол отмечен не там';

  @override
  String get scanReviewArcoreAccuracy =>
      'Измерение камерой: возможна погрешность ±3–5%, важные стены проверьте рулеткой';

  @override
  String get shopNoResults => 'Ничего не найдено';

  @override
  String get shopSearchResultsTitle => 'Результаты поиска';

  @override
  String get shopFilterForProject => 'Подходит проекту';

  @override
  String get shopFilterRating => 'Рейтинг';

  @override
  String shopResultCount(int count) {
    return '$count результатов';
  }

  @override
  String get commonVerifiedBadge => '✓ Подтверждён';

  @override
  String get mastersSearchHint => 'Какой мастер нужен?';

  @override
  String mastersRatingReviews(String rating, int count) {
    return '$rating ($count отзывов)';
  }

  @override
  String mastersAreaDistance(String area, String distance) {
    return '$area · ~$distance км';
  }

  @override
  String get mastersViewProfile => 'Смотреть профиль';

  @override
  String get mastersStatRating => 'рейтинг';

  @override
  String get mastersStatReviews => 'отзывов';

  @override
  String get mastersStatJobs => 'работ';

  @override
  String get mastersPortfolio => 'Портфолио';

  @override
  String get mastersPortfolioEmpty => 'Пока нет фотографий портфолио';

  @override
  String get mastersServices => 'Услуги';

  @override
  String mastersServiceTrade(String trade) {
    return 'Работы: $trade';
  }

  @override
  String get mastersServiceConsultation => 'Консультация';

  @override
  String get mastersLocation => 'Расположение';

  @override
  String get mastersSendEstimate => 'Отправить смету';

  @override
  String get mastersSendMessage => 'Написать сообщение';

  @override
  String mastersSendConfirmTitle(String name) {
    return 'Отправить ваш проект мастеру $name?';
  }

  @override
  String get mastersProjectSummaryTitle => 'Ремонт гостиной';

  @override
  String mastersProjectSummaryValue(String area, String price) {
    return '$area м² · $price';
  }

  @override
  String get mastersCommentHint => 'Комментарий (необязательно)';

  @override
  String get phoneErrorInvalid =>
      'Неверный номер телефона. Пример: +998 90 123 45 67';

  @override
  String get mastersPhoneLabel => 'Ваш номер телефона';

  @override
  String get mastersEstimateNote =>
      'Мастер рассмотрит смету и предложит свою цену';

  @override
  String get mastersEstimateSent => 'Смета отправлена';

  @override
  String get mastersSend => 'Отправить';

  @override
  String get profileDefaultName => 'Пользователь';

  @override
  String get profileComingSoon => 'Скоро';

  @override
  String get profileStatProjects => 'проектов';

  @override
  String get profileStatOrders => 'заказов';

  @override
  String get profileStatSaved => 'сэкономлено';

  @override
  String profileSavedMln(String amount) {
    return '$amount млн';
  }

  @override
  String get profileMenuProjects => 'Мои проекты';

  @override
  String get profileMenuOrders => 'Мои заказы';

  @override
  String get profileMenuSavedDesigns => 'Сохранённые дизайны';

  @override
  String get profileMenuAddresses => 'Мои адреса';

  @override
  String get profileMenuPaymentMethods => 'Способы оплаты';

  @override
  String get profileMenuLanguage => 'Язык';

  @override
  String get profileMenuSettings => 'Настройки';

  @override
  String get profileMenuHelp => 'Помощь';

  @override
  String get profileMenuLogout => 'Выйти';

  @override
  String get profileLanguageUzbek => 'Узбекский';

  @override
  String get profileFilterOngoing => 'В процессе';

  @override
  String get profileFilterFinished => 'Завершён';

  @override
  String get profileProjectsEmptyTitle => 'Проектов пока нет';

  @override
  String get profileProjectsEmptyMessage => 'Начните свой первый проект';

  @override
  String get profileProjectsEmptyAction => '+ Новый проект';

  @override
  String profileProjectMeta(int count, String details) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count комнат',
      many: '$count комнат',
      few: '$count комнаты',
      one: '$count комната',
    );
    return '$_temp0 · $details';
  }

  @override
  String get profileOrdersEmptyTitle => 'Заказов нет';

  @override
  String get profileOrdersEmptyMessage =>
      'Здесь появятся ваши покупки из магазина';

  @override
  String get orderStepAccepted => 'Принят';

  @override
  String get orderStepGathering => 'Собирается';

  @override
  String get orderStepOnTheWay => 'В пути';

  @override
  String get orderStepDelivered => 'Доставлен';

  @override
  String get profileSavedDesignsEmptyTitle => 'Сохранённых дизайнов нет';

  @override
  String get profileSavedDesignsEmptyMessage =>
      'Сохраняйте понравившиеся дизайны здесь';

  @override
  String get onboardingSkip => 'Пропустить';

  @override
  String get onboardingStart => 'Начать';

  @override
  String get onboardingMeasureTitle => 'Измерьте вашу комнату';

  @override
  String get onboardingMeasureBody =>
      'Получите точные размеры комнаты с помощью камеры телефона или LiDAR.';

  @override
  String get onboardingDeltaTitle => 'Начинаем с текущего состояния';

  @override
  String get onboardingDeltaBody =>
      'Вы не платите за то, что уже есть в комнате — учитываем только необходимое.';

  @override
  String get onboardingDeltaCurrent => 'Текущее';

  @override
  String get onboardingDeltaPill => 'учитывается только РАЗНИЦА';

  @override
  String get onboardingDecorateTitle => 'Оформите в 3D';

  @override
  String get onboardingDecorateBody =>
      'Перетаскивайте материалы прямо в 3D-вид комнаты и сразу видьте результат.';

  @override
  String get onboardingPriceTitle => 'Узнайте цену, получите материалы';

  @override
  String get onboardingPriceBody =>
      'Получите точную смету и купите нужные материалы прямо в приложении.';

  @override
  String get onboardingPriceSaved => 'Вы сэкономили 4.2 млн';

  @override
  String get onboardingDemoTitle => 'Демо-гид';

  @override
  String get onboardingDemoStep1 =>
      'Добавление комнаты — LiDAR, 360° или ручной замер';

  @override
  String get onboardingDemoStep2 => 'Выбор текущего состояния комнаты';

  @override
  String get onboardingDemoStep3 =>
      'Оформление стен, пола и мебели через панель';

  @override
  String get onboardingDemoStep4 =>
      'Планирование электрики и сантехники в конце';

  @override
  String get onboardingDemoStep5 => 'Просмотр сметы и покупка материалов';

  @override
  String get onboardingDemoWatchVideo => 'Смотреть видео';

  @override
  String get onboardingDemoTryMyself => 'Попробую сам';

  @override
  String get commonBackTo3d => 'Вернуться в 3D';

  @override
  String get designSurfaceFloorHeading => 'Пол';

  @override
  String get designSurfaceCeilingHeading => 'Потолок';

  @override
  String get designFloorRaw => 'Черновой бетон';

  @override
  String get designFloorPlastered => 'Стяжка';

  @override
  String get designFloorPuttied => 'Есть покрытие';

  @override
  String get designCeilingRaw => 'Черновой';

  @override
  String get designCeilingPlastered => 'Штукатурка';

  @override
  String get designCeilingPuttied => 'Готово';

  @override
  String designRoomEntryIntro(String condition) {
    return 'Ваша комната в таком состоянии — $condition. Теперь оформим её поэтапно.';
  }

  @override
  String get designConditionRaw => 'в состоянии коробки';

  @override
  String get designConditionPlastered => 'оштукатурена';

  @override
  String get designConditionPuttied => 'прошпаклёвана';

  @override
  String get designToastShpaklovkaAdded => '✓ Шпаклёвка добавлена';

  @override
  String get designStageBoyoqOboi => 'Этап краски/обоев';

  @override
  String get designRailTabBoyoq => 'Краска';

  @override
  String get designDragHint => 'Перетащите материал пальцем на стену';

  @override
  String get designNextStage => 'Следующий этап →';

  @override
  String get interiorToastFloorApplied => '✓ Применено к полу';

  @override
  String get interiorStagePol => 'Этап пола';

  @override
  String get interiorRailTabKafel => 'Плитка';

  @override
  String get interiorRailTabLaminat => 'Ламинат';

  @override
  String get interiorRailTabParket => 'Паркет';

  @override
  String get interiorRailTabBeton => 'Бетон';

  @override
  String get interiorStageMebel => 'Этап мебели';

  @override
  String get interiorRailTabMehmonxona => 'Гостиная';

  @override
  String get interiorRailTabOshxona => 'Кухня';

  @override
  String get interiorRailTabYotoqxona => 'Спальня';

  @override
  String get interiorRailTabVanna => 'Ванная';

  @override
  String get interiorWalkthroughHint =>
      'Можно ходить по полу — проведите пальцем';

  @override
  String get interiorGoToPlan => 'Перейти к плану →';

  @override
  String get interiorDecorationComplete => 'Оформление завершено';

  @override
  String get interiorGoToElectrical => 'Перейти к электрике →';

  @override
  String get interiorWallpaperAdded => '✓ Обои добавлены в библиотеку';

  @override
  String interiorUploadFailed(String error) {
    return 'Не удалось загрузить: $error';
  }

  @override
  String get interiorWallpaperLibrary => 'Библиотека обоев';

  @override
  String get interiorUploading => 'Загружается…';

  @override
  String get interiorUploadImage => 'Загрузить изображение';

  @override
  String get interiorNoWallpapers =>
      'Обоев пока нет — загрузите первое изображение';

  @override
  String get electricalWireRouting => 'Прокладка проводки';

  @override
  String get electricalView2d => '2D план';

  @override
  String get electricalView3d => '3D';

  @override
  String get electricalViewBoth => 'Оба';

  @override
  String get electricalRecomputeRoute => 'Пересчитать трассу';

  @override
  String get electricalNext => 'Далее →';

  @override
  String get electricalResult => 'Результат электрики';

  @override
  String get electricalFinish => 'Завершить →';

  @override
  String get electricalProjectReady => 'Ваш проект готов';

  @override
  String get electricalViewEstimate => 'Смотреть смету →';

  @override
  String get estimateTitlePrefix => 'Смета ремонта';

  @override
  String get estimateDefaultRoomName => 'Гостиная';

  @override
  String estimatePdfFailed(String error) {
    return 'Не удалось загрузить PDF: $error';
  }

  @override
  String get estimateSomeWork => 'Часть работ';

  @override
  String get estimateStageFallback => 'Этап';

  @override
  String get estimateFloorUnpriced =>
      'Тип пола выбран, но товар не выбран — пол не вошёл в смету.';

  @override
  String get estimateFloorPick => 'Выбрать пол';

  @override
  String get estimateAdjust => 'Настройка сметы';

  @override
  String get estimateApproxTotal => 'Приблизительная общая стоимость';

  @override
  String get estimateLabor => 'Рабочая сила';

  @override
  String estimateSavingsBanner(String label, String amount) {
    return '$label уже было — вы сэкономили $amount';
  }

  @override
  String get estimateExcludedNote => 'у вас уже есть — не учтено';

  @override
  String get estimateZeroSom => '0 сум';

  @override
  String get estimatePreparingPdf => 'Подготавливается…';

  @override
  String get estimateBuyFromShops => 'Купить в магазинах';

  @override
  String get estimateSendToMaster => 'Отправить мастеру';

  @override
  String get estimateMaterialsTotal => 'Итого материалы';

  @override
  String get estimateStageTotal => 'Итого по этапу';

  @override
  String get estimateAddMaterialsToCart => 'Материалы в корзину';

  @override
  String get estimateQualityLevel => 'Уровень качества';

  @override
  String get estimateExcludeLabor => 'Не включать рабочую силу';

  @override
  String get estimateDiySubtitle => 'Сделаю сам — учитываются только материалы';

  @override
  String estimateDeltaSavings(String stage) {
    return 'Экономия дельты ($stage)';
  }

  @override
  String get estimateNewTotal => 'Новый итог';

  @override
  String get estimateSaveEstimate => 'Сохранить смету';

  @override
  String get studioAiDesignerInStudio => 'AI-дизайнер (3D Студия)';

  @override
  String get studioAiDesigner => 'AI-дизайнер';

  @override
  String get studioAiApplied => '✓ Изменения AI применены';

  @override
  String studioApplyFailed(String error) {
    return 'Не удалось применить: $error';
  }

  @override
  String get studioAiHint =>
      'Например: \"Покрась стены в тёплый бежевый и добавь диван\"';

  @override
  String get studioAiStyleLabel => 'Стиль (необязательно)';

  @override
  String get studioGenerating => 'Обрабатывается…';

  @override
  String get studioGenerate => 'Создать';

  @override
  String studioActionLabel(String name) {
    return 'Действие: $name';
  }

  @override
  String studioDoneLabel(String name) {
    return 'Выполнено: $name';
  }

  @override
  String studioAiNoResponse(String message) {
    return 'AI пока не смог ответить.\n$message';
  }

  @override
  String studioChangeCeiling(String height) {
    return 'Высота потолка: $height м';
  }

  @override
  String studioChangeSurfaces(int count) {
    return '$count материалов поверхности';
  }

  @override
  String studioChangeWalls(int count) {
    return '$count размеров стен';
  }

  @override
  String studioChangeFurniture(int count) {
    return '$count предметов мебели';
  }

  @override
  String studioChangeLights(int count) {
    return '$count светильников';
  }

  @override
  String get studioApply => 'Применить';

  @override
  String get studioLoginRequired => 'Войдите в систему, чтобы открыть студию.';

  @override
  String studioLoadFailed(String error) {
    return 'Студия не загрузилась: $error';
  }

  @override
  String get studioWebViewTitle => '3D Студия';

  @override
  String get actionAdd => 'Добавить';

  @override
  String get actionPrev => 'Назад';

  @override
  String get actionOk => 'OK';

  @override
  String get actionCancelShort => 'Отмена';

  @override
  String get roomDefaultName => 'Комната';

  @override
  String get ceilingHeightLabel => 'Высота потолка';

  @override
  String get measureLength => 'Длина';

  @override
  String get furnitureDelete => 'Удалить';

  @override
  String get furnitureRotate => 'Повернуть';

  @override
  String get electricalTotalsTitle => 'Электрика рассчитана';

  @override
  String get electricalTotalsWireLabel => 'всего провода';

  @override
  String get electricalTotalsDeviceLabel => 'устройств';

  @override
  String electricalTotalsSocketWires(String meters) {
    return 'Провода розеток $meters м';
  }

  @override
  String electricalTotalsSwitchWires(String meters) {
    return 'Провода выключателей $meters м';
  }

  @override
  String electricalTotalsSwitchLightSummary(int switches, int lights) {
    return '$switches выключателей · $lights светильников';
  }

  @override
  String get electricalTotalsColDevice => 'Устройство';

  @override
  String get electricalTotalsColWall => 'Стена';

  @override
  String get electricalTotalsColHeight => 'Высота';

  @override
  String get dimensionsTitle => 'Размеры комнаты';

  @override
  String get dimensionsTabManual => 'Ввести вручную';

  @override
  String get dimensionsTabUpload => 'Загрузить план';

  @override
  String dimensionsTotalSummary(int count, String area) {
    return 'Всего: $count комн. · $area м²';
  }

  @override
  String get dimensionsNextMeasure => 'Далее: замер стен';

  @override
  String get dimensionsConvert3d => 'Преобразовать в 3D';

  @override
  String get dimensionsAddRoom => '+ Добавить комнату';

  @override
  String dimensionsRoomDefaultName(int number) {
    return 'Комната $number';
  }

  @override
  String get dimensionsRoomNameLabel => 'Название комнаты';

  @override
  String get dimensionsLengthLabel => 'Длина (м)';

  @override
  String get dimensionsWidthLabel => 'Ширина (м)';

  @override
  String get dimensionsHeightLabel => 'Высота (м)';

  @override
  String get dimensionsUploadTitle => 'Загрузите изображение плана';

  @override
  String get dimensionsUploadHint =>
      'PNG или JPG · максимум 10 МБ\nИли перетащите сюда';

  @override
  String get dimensionsChooseFile => 'Выбрать файл';

  @override
  String get dimensionsUploadNote =>
      'Для точного результата загрузите план с указанными размерами';

  @override
  String get openingAddTitle => 'Добавить дверь/окно';

  @override
  String get openingAddSpaced => 'Дверь / Окно добавить';

  @override
  String get openingTypeDoor => 'Дверь';

  @override
  String get openingTypeWindow => 'Окно';

  @override
  String get openingTypeBalcony => 'Балконная дверь';

  @override
  String get openingSizeLabel => 'Размер (см)';

  @override
  String get openingSizeOther => 'Другой размер…';

  @override
  String get openingPositionLabel => 'Положение вдоль стены';

  @override
  String get openingAddToWall => 'Добавить к стене';

  @override
  String get newProjectTitle => 'Новый проект';

  @override
  String get newProjectSubtitle => 'Как хотите добавить комнату?';

  @override
  String get newProjectWizardTitle => '3D Мастер';

  @override
  String get newProjectWizardDesc =>
      'Введите размеры комнаты в интерактивном 3D-виде';

  @override
  String get newProjectLidarTitle => 'LiDAR сканер';

  @override
  String get newProjectLidarDesc =>
      'Отсканируйте комнату с помощью LiDAR и получите готовую 3D-модель';

  @override
  String get newProjectPhotoTitle => '360° Фотоскан';

  @override
  String get newProjectPhotoDesc =>
      'Сфотографируйте комнату на 360° — приложение само определит точки';

  @override
  String get newProjectDrawTitle => 'Нарисуйте сами';

  @override
  String get newProjectDrawDesc =>
      'Нарисуйте комнату пальцем — размеры рассчитаются автоматически по рисунку';

  @override
  String get summarySavedTitle => 'Размеры сохранены!';

  @override
  String get summaryStatFloor => 'пол';

  @override
  String get summaryStatWallNet => 'стена (нетто)';

  @override
  String get summaryStatPerimeter => 'периметр';

  @override
  String get summaryStatOpenings => 'дверь/окно';

  @override
  String summaryOpeningsCount(int count) {
    return '$count шт.';
  }

  @override
  String get summaryOpeningsNote => 'Двери/окна автоматически вычтены (нетто)';

  @override
  String get summaryAddRoom => '+ Добавить новую комнату';

  @override
  String get roomSetupDefaultProjectName => 'Ремонт гостиной';

  @override
  String get roomSetupWallLabelA => 'Стена A';

  @override
  String get roomSetupWallLabelB => 'Стена B';

  @override
  String get roomSetupWallLabelC => 'Стена C';

  @override
  String get roomSetupWallLabelD => 'Стена D';

  @override
  String get roomSetupWallLabelFallback => 'Стена';

  @override
  String get wizardTitle => 'Новая комната';

  @override
  String get wizardCeilingQuestion => 'Высота потолка?';

  @override
  String get wizardCeilingHint => 'Обычно в диапазоне 2.5–3.2 метра';

  @override
  String get wizardExactValue => 'Точное значение (м)';

  @override
  String wizardCeilingOutOfRange(String min, String max) {
    return 'Высота потолка должна быть от $min до $max м';
  }

  @override
  String wizardWallTitle(String letter) {
    return 'Стена $letter';
  }

  @override
  String get wizardWallSubtitle => 'Введите длину';

  @override
  String get wizardSummaryTitle => 'Размеры готовы';

  @override
  String get wizardSummarySubtitle =>
      'Выберите смету или оформление — тогда комната сохранится';

  @override
  String get wizardStatFloor => 'ПЛОЩАДЬ ПОЛА';

  @override
  String get wizardStatWallNet => 'ПЛОЩАДЬ СТЕН (НЕТТО)';

  @override
  String get wizardStatPerimeter => 'ПЕРИМЕТР';

  @override
  String get wizardStatOpenings => 'ДВЕРИ/ОКНА';

  @override
  String get wizardViewSmeta => 'Смотреть смету';

  @override
  String get wizardOpening => 'Открывается…';

  @override
  String get wizardStartDesign => 'Начать оформление';

  @override
  String get measureOpenings => 'Двери / окна';

  @override
  String measureFromLeft(String offset) {
    return 'Слева $offset м';
  }

  @override
  String get lidarScanning => 'Сканирование...';

  @override
  String get lidarMoveHint => 'Медленно перемещайте телефон';

  @override
  String get lidarLabelWall => 'стена';

  @override
  String get lidarLabelDoor => 'дверь';

  @override
  String get lidarLabelWindow => 'окно';

  @override
  String photoPointsCount(int captured, int total) {
    return '$captured/$total точка';
  }

  @override
  String get photoTurnHint => 'Поверните телефон к следующей точке';

  @override
  String get photoCapture => 'Сфотографировать';

  @override
  String get scanReviewTitle => 'Результат сканирования';

  @override
  String scanReviewDetected(String value) {
    return 'Обнаружено: $value';
  }

  @override
  String scanReviewWalls(int count) {
    return 'Стены ($count)';
  }

  @override
  String scanReviewWall(int number) {
    return 'Стена $number';
  }

  @override
  String scanReviewObjects(int count) {
    return 'Найденные предметы ($count)';
  }

  @override
  String get scanReviewNoObjects => 'Предметы не найдены';

  @override
  String scanReviewObjectsDetectedNotice(int count) {
    return 'Обнаружено предметов: $count — увидите их в студии во «Вид скана»';
  }

  @override
  String get scanReviewRescan => 'Пересканировать';

  @override
  String get scanReviewSummaryTitle => 'Что было обнаружено';

  @override
  String get scanReviewSummaryWalls => 'Стены';

  @override
  String get scanReviewSummaryDoors => 'Двери';

  @override
  String get scanReviewSummaryWindows => 'Окна';

  @override
  String get scanReviewSummaryObjects => 'Предметы';

  @override
  String scanReviewSummaryLowConfidence(int count) {
    return '$count элементов измерено с низкой точностью — проверьте размеры.';
  }

  @override
  String get scanReviewSummaryNoOpenings =>
      'Двери или окна не найдены. Стекло и открытые двери часто не распознаются.';

  @override
  String get scanReviewSummaryRescanHint => 'Пересканируйте ближе и медленнее.';

  @override
  String get scanReviewSaveFailed =>
      'Не удалось сохранить комнату. Проверьте интернет.';

  @override
  String scanReviewUploadFailed(String error) {
    return 'Файлы скана не загружены: $error Комната сохранена, вы можете пересканировать позже.';
  }

  @override
  String scanReviewThumbnailFailed(String error) {
    return 'Превью комнаты не загружено: $error Карточка проекта будет без изображения.';
  }

  @override
  String scanReviewError(String error) {
    return 'Ошибка: $error';
  }

  @override
  String scanReviewCeilingHeightValue(String h) {
    return '$h m';
  }

  @override
  String get pendingScanTitle => 'Найдено незавершённое сканирование';

  @override
  String get pendingScanBody =>
      'Вы ранее сканировали комнату, но вышли, не нажав \"Продолжить\". Продолжить сейчас?';

  @override
  String get pendingScanResume => 'Продолжить';

  @override
  String get pendingScanDiscard => 'Отменить';

  @override
  String get scanCategoryTable => 'Стол';

  @override
  String get scanCategoryChair => 'Стул';

  @override
  String get scanCategorySofa => 'Диван';

  @override
  String get scanCategoryBed => 'Кровать';

  @override
  String get scanCategoryStorage => 'Шкаф';

  @override
  String get scanCategoryRefrigerator => 'Холодильник';

  @override
  String get scanCategoryStove => 'Плита';

  @override
  String get scanCategorySink => 'Раковина';

  @override
  String get scanCategoryToilet => 'Унитаз';

  @override
  String get scanCategoryBathtub => 'Ванна';

  @override
  String get scanCategoryWasher => 'Стиральная машина';

  @override
  String get scanCategoryTelevision => 'Телевизор';

  @override
  String get scanCategoryFireplace => 'Камин';

  @override
  String get scanCategoryStairs => 'Лестница';

  @override
  String get scanCategoryOther => 'Другое';

  @override
  String get scanBusy => 'Сканер уже работает.';

  @override
  String get scanFailedRetry => 'Ошибка сканирования. Попробуйте снова.';

  @override
  String scanErrorPrefixed(String message) {
    return 'Ошибка: $message';
  }

  @override
  String get scanNotDetected => 'Комната не обнаружена. Попробуйте снова.';

  @override
  String get scanLidarUnavailableTitle => 'LiDAR недоступен';

  @override
  String get scanLidarUnavailableBody =>
      'LiDAR сканер работает только на устройствах с LiDAR: iPhone Pro (12 Pro и новее) или iPad Pro. Добавьте комнату другим способом:';

  @override
  String get scanInProgress => 'Комната сканируется…';

  @override
  String get drawTitle => 'Нарисуйте комнату';

  @override
  String get drawModeManual => 'Вручную';

  @override
  String get drawModeVisual => 'Визуально';

  @override
  String get drawHintRaw =>
      'Черновой рисунок. Нажмите кнопку, чтобы вернуться к \"Чистому\".';

  @override
  String get drawHintShapeReady =>
      'Форма готова! Двигайте углы, чтобы изменить размер.';

  @override
  String get drawHintFreehand => 'Нарисуйте форму комнаты пальцем.';

  @override
  String get drawHintMarkCorners => 'Отметьте углы комнаты (минимум 3).';

  @override
  String drawHintMorePoints(int count) {
    return 'Добавьте ещё $count точки.';
  }

  @override
  String get drawHintClose =>
      'Нажмите на первую точку или \"Закрыть\", чтобы завершить.';

  @override
  String get drawToggleClean => 'Чисто';

  @override
  String get drawToggleRaw => 'Черновик';

  @override
  String get drawRedo => 'Вперёд';

  @override
  String get drawClear => 'Очистить';

  @override
  String get drawWallLength => 'Длина стены';

  @override
  String get drawAreaWarning => 'Внимание: площадь выходит за обычные пределы';

  @override
  String drawTitleRect(String width, String length, String height) {
    return 'Комната: $width × $length × $height м';
  }

  @override
  String drawTitlePolygon(int corners, String width, String length) {
    return 'Многоугольник · $corners стен · $width×$length м';
  }

  @override
  String get a11yQuantityDecrease => 'Уменьшить количество';

  @override
  String get a11yQuantityIncrease => 'Увеличить количество';

  @override
  String get a11yRemoveFromCart => 'Убрать из корзины';

  @override
  String get a11yAddToCart => 'Добавить в корзину';

  @override
  String get a11yCallDealer => 'Позвонить';

  @override
  String get a11yMessageDealer => 'Отправить сообщение';

  @override
  String shopDealerPhoneUnavailable(String dealer) {
    return '$dealer: номер телефона пока недоступен';
  }

  @override
  String shopDealerMessageUnavailable(String dealer) {
    return 'Обмен сообщениями с $dealer пока недоступен';
  }

  @override
  String get a11yEditProfile => 'Редактировать профиль';

  @override
  String get a11yMastersListView => 'Вид списком';

  @override
  String get settingsScreenTitle => 'Настройки';

  @override
  String get settingsNotificationsSectionTitle => 'Уведомления';

  @override
  String get settingsPushNotificationsTitle => 'Push-уведомления';

  @override
  String get settingsPushNotificationsSubtitle =>
      'Получайте обновления о проектах и подрядчиках';

  @override
  String get settingsEmailDigestTitle => 'Email-рассылка';

  @override
  String get settingsEmailDigestSubtitle =>
      'Еженедельная сводка по вашим проектам';

  @override
  String get settingsMarketingEmailsTitle => 'Рекламные письма';

  @override
  String get settingsMarketingEmailsSubtitle =>
      'Новости о новых функциях и предложениях';

  @override
  String get settingsUnitsDisplaySectionTitle => 'Единицы измерения и экран';

  @override
  String get settingsMeasurementUnitsTitle => 'Единицы измерения';

  @override
  String get settingsUnitMetric => 'Метрическая (м²)';

  @override
  String get settingsUnitImperial => 'Имперская (фут²)';

  @override
  String get settingsThemeTitle => 'Тема';

  @override
  String get settingsThemeLight => 'Светлая';

  @override
  String get settingsThemeDark => 'Тёмная';

  @override
  String get settingsThemeSystem => 'Системная';

  @override
  String get settingsLargeTextTitle => 'Крупный текст';

  @override
  String get settingsLargeTextSubtitle =>
      'Увеличить размер текста для удобства чтения';

  @override
  String get settingsProjectSettingsSectionTitle => 'Настройки проекта';

  @override
  String get settingsAutoSaveTitle => 'Автосохранение проектов';

  @override
  String get settingsAutoSaveSubtitle =>
      'Автоматически сохранять вашу работу по мере продвижения';

  @override
  String get settingsCloudSyncTitle => 'Облачная синхронизация';

  @override
  String get settingsCloudSyncSubtitle =>
      'Синхронизируйте проекты на всех ваших устройствах';

  @override
  String get settingsCloudSyncEnabledMessage =>
      'Облачная синхронизация включена';

  @override
  String get settingsCloudSyncDisabledMessage =>
      'Облачная синхронизация отключена';

  @override
  String get settingsClearCacheTitle => 'Очистить кэш';

  @override
  String get settingsClearCacheSubtitle => 'Освободить место в хранилище';

  @override
  String get settingsClearingCacheInProgress => 'Очистка...';

  @override
  String get settingsCacheClearedMessage => 'Кэш очищен';

  @override
  String settingsCacheClearFailedMessage(String error) {
    return 'Не удалось очистить кэш: $error';
  }

  @override
  String get settingsPrivacySecuritySectionTitle =>
      'Конфиденциальность и безопасность';

  @override
  String get settingsPrivacyPolicyTitle => 'Политика конфиденциальности';

  @override
  String get settingsPrivacyPolicySubtitle =>
      'Ознакомьтесь с нашей политикой конфиденциальности';

  @override
  String get settingsTermsOfServiceTitle => 'Условия использования';

  @override
  String get settingsTermsOfServiceSubtitle =>
      'Ознакомьтесь с условиями и положениями';

  @override
  String settingsLinkOpenFailedMessage(String url) {
    return 'Не удалось открыть ссылку: $url';
  }

  @override
  String get settingsAboutSectionTitle => 'О приложении';

  @override
  String get settingsAppVersionLabel => 'Версия приложения';

  @override
  String get settingsBuildNumberLabel => 'Номер сборки';

  @override
  String get settingsCheckForUpdatesButton => 'Проверить обновления';

  @override
  String get settingsUpdatesDialogTitle => 'Обновления';

  @override
  String get settingsUpdatesDialogBody =>
      'У вас установлена последняя версия приложения.';

  @override
  String get settingsUpdatesDialogOk => 'ОК';

  @override
  String get registerRoleTitle => 'Кто вы?';

  @override
  String get roleUser => 'Пользователь';

  @override
  String get roleUserDesc => 'Для моих проектов ремонта и дизайна';

  @override
  String get roleShop => 'Владелец магазина';

  @override
  String get roleShopDesc => 'Продаю мебель и материалы';

  @override
  String get roleUsta => 'Мастер';

  @override
  String get roleUstaDesc => 'Предлагаю услуги по ремонту';

  @override
  String get businessApplyShopTitle => 'Заявка магазина';

  @override
  String get businessApplyUstaTitle => 'Заявка мастера';

  @override
  String get businessApplyIntro =>
      'Укажите данные. После проверки администраторами вы появитесь в списке.';

  @override
  String get businessFieldShopName => 'Название магазина';

  @override
  String get businessFieldUstaName => 'Ваше имя или название бригады';

  @override
  String get businessFieldTrade => 'Ваша специальность';

  @override
  String get businessFieldDistrict => 'Район';

  @override
  String get businessFieldPhone => 'Телефон (+998...)';

  @override
  String get businessFieldTelegram => 'Telegram (необязательно)';

  @override
  String get businessFieldPriceMin => 'От';

  @override
  String get businessFieldPriceMax => 'До';

  @override
  String get businessFieldPriceTitle => 'Цена (сум)';

  @override
  String get businessSubmit => 'Отправить заявку';

  @override
  String get businessSkip => 'Позже';

  @override
  String get businessErrorName => 'Укажите название';

  @override
  String get businessErrorPhone => 'Введите телефон полностью, с +998';

  @override
  String get businessErrorPrice =>
      'Максимальная цена не может быть меньше минимальной';

  @override
  String get businessErrorExists => 'У вас уже есть такая заявка';

  @override
  String get businessErrorFailed =>
      'Не удалось отправить заявку. Попробуйте ещё раз.';

  @override
  String get businessTitle => 'Мой бизнес';

  @override
  String get businessShopSection => 'Магазин';

  @override
  String get businessUstaSection => 'Профиль мастера';

  @override
  String get businessStatusPending => 'На проверке';

  @override
  String get businessStatusApproved => 'Подтверждено';

  @override
  String get businessStatusRejected => 'Отклонено';

  @override
  String get businessPendingHint =>
      'Заявка на проверке у администраторов. После подтверждения вы появитесь в списке.';

  @override
  String get businessApprovedHint => 'Ваш профиль виден в списке.';

  @override
  String get businessResubmit => 'Отправить повторно';

  @override
  String get businessComingProducts => 'Управление товарами скоро';

  @override
  String get businessComingRequests => 'Заявки клиентов скоро';

  @override
  String get businessLoadFailed => 'Не удалось загрузить данные';

  @override
  String get profileMenuBusiness => 'Мой бизнес';

  @override
  String get profileMenuBecomePartner =>
      'Присоединиться как магазин или мастер';

  @override
  String get tradeElektrik => 'Электрик';

  @override
  String get tradeElektrikLoyihachi => 'Проектировщик электрики';

  @override
  String get tradeSantexnik => 'Сантехник';

  @override
  String get tradeMalyar => 'Маляр';

  @override
  String get tradeOboy => 'Мастер по обоям';

  @override
  String get tradeLaminat => 'Мастер по ламинату';

  @override
  String get tradeBrigada => 'Бригада';

  @override
  String businessRejectedReason(String note) {
    return 'Причина: $note';
  }

  @override
  String get shopProductsTitle => 'Мои товары';

  @override
  String get shopProductsEmpty =>
      'Товаров пока нет. Сфотографируйте и добавьте первый товар.';

  @override
  String get shopProductsOpen => 'Управление товарами';

  @override
  String get shopProductVisible => 'Виден в каталоге';

  @override
  String get shopProductEdit => 'Изменить';

  @override
  String get shopProductName => 'Название';

  @override
  String get shopProductPrice => 'Цена (сум)';

  @override
  String get shopProductSave => 'Сохранить';

  @override
  String get shopProductDelete => 'Удалить';

  @override
  String get shopProductDeleteConfirm => 'Удалить товар? Это нельзя отменить.';

  @override
  String get shopProductCancel => 'Отмена';

  @override
  String get shopProductFailed =>
      'Не удалось выполнить действие. Попробуйте ещё раз.';

  @override
  String get shopProductNoPrice => 'Цена не указана';

  @override
  String get addProductTitle => 'Новый товар';

  @override
  String get addProductPhotoHint =>
      'Сфотографируйте мебель чётко (лучше на чистом фоне). 3D-модель мы создадим сами.';

  @override
  String get addProductGallery => 'Из галереи';

  @override
  String get addProductCamera => 'С камеры';

  @override
  String get addProductCategory => 'Тип';

  @override
  String get addProductRoom => 'Комната';

  @override
  String get addProductRoomAll => 'Все комнаты';

  @override
  String get addProductPlacement => 'Размещение';

  @override
  String get addProductSubmit => 'Создать 3D-модель и добавить';

  @override
  String get addProductBuilding =>
      'Создаём 3D-модель… около 1–2 минут, не закрывайте приложение';

  @override
  String get addProductUploading => 'Товар добавляется в магазин…';

  @override
  String get addProductDone =>
      'Товар добавлен. Появится в каталоге после одобрения админом.';

  @override
  String get addProductNeedPhoto => 'Сначала выберите фото';

  @override
  String get addProductNeedName => 'Введите название';

  @override
  String get addProductFailed =>
      'Не удалось создать 3D-модель. Попробуйте другое фото.';

  @override
  String get addProductUnavailable => 'Сервис 3D-моделей сейчас недоступен';

  @override
  String get addProductLimit => 'Лимит на сегодня исчерпан. Попробуйте завтра.';

  @override
  String get addProductTooMany =>
      'Много неодобренных товаров. Дождитесь проверки.';

  @override
  String get categoryDivan => 'Диван';

  @override
  String get categoryStol => 'Стол';

  @override
  String get categoryStul => 'Стул';

  @override
  String get categoryKaravot => 'Кровать';

  @override
  String get categoryShkaf => 'Шкаф';

  @override
  String get categoryLampa => 'Лампа';

  @override
  String get categoryBoshqa => 'Другое';

  @override
  String get roomMehmonxona => 'Гостиная';

  @override
  String get roomOshxona => 'Кухня';

  @override
  String get roomYotoqxona => 'Спальня';

  @override
  String get roomHammom => 'Ванная';

  @override
  String get roomBalkon => 'Балкон';

  @override
  String get placementPol => 'На полу';

  @override
  String get placementDevor => 'На стене';

  @override
  String get placementShift => 'На потолке';

  @override
  String get ustaLeadsTitle => 'Заявки клиентов';

  @override
  String get ustaLeadsOpen => 'Заявки клиентов';

  @override
  String get ustaLeadsEmpty =>
      'Заявок пока нет. Когда клиенты обратятся к вам со сметой, они появятся здесь.';

  @override
  String get ustaLeadCall => 'Позвонить';

  @override
  String get ustaLeadNoPhone => 'Телефон не указан';

  @override
  String get ustaLeadClient => 'Клиент';

  @override
  String ustaLeadEstimate(String total, int lines) {
    return 'Смета: $total (строк: $lines)';
  }

  @override
  String get leadStatusNew => 'Новая';

  @override
  String get leadStatusViewed => 'Просмотрена';

  @override
  String get leadStatusContacted => 'Связались';

  @override
  String get leadStatusClosed => 'Закрыта';

  @override
  String get ustaLeadMarkViewed => 'Просмотрено';

  @override
  String get ustaLeadMarkContacted => 'Связались';

  @override
  String get ustaLeadMarkClosed => 'Закрыть';

  @override
  String get ustaEditOpen => 'Изменить профиль';

  @override
  String get ustaEditTitle => 'Мой профиль мастера';

  @override
  String get ustaEditSave => 'Сохранить';

  @override
  String get ustaEditFailed => 'Не удалось сохранить. Попробуйте ещё раз.';

  @override
  String get shopEditTitle => 'Профиль магазина';

  @override
  String get addProductMoreAngles => 'Другие ракурсы (необязательно)';

  @override
  String get addProductMoreAnglesHint =>
      'Фото слева, сзади и справа делают 3D-модель точнее.';

  @override
  String get addProductAngleLeft => 'Слева';

  @override
  String get addProductAngleBack => 'Сзади';

  @override
  String get addProductAngleRight => 'Справа';

  @override
  String get addProductAngleRemove => 'Убрать';

  @override
  String get shopInquiriesTitle => 'Обращения клиентов';

  @override
  String get shopInquiriesOpen => 'Обращения';

  @override
  String shopInquiriesOpenWithNew(int count) {
    return 'Обращения ($count новых)';
  }

  @override
  String get shopInquiriesEmpty =>
      'Обращений пока нет. Когда клиенты спросят о вашем товаре, они появятся здесь.';

  @override
  String shopInquiryProduct(String name) {
    return 'Товар: $name';
  }

  @override
  String get shopStatsOpen => 'Статистика';

  @override
  String get shopStatsTitle => 'Статистика магазина';

  @override
  String get shopStatsProducts => 'Товары';

  @override
  String get shopStatsApproved => 'Одобрено';

  @override
  String get shopStatsPending => 'На проверке';

  @override
  String get shopStatsRejected => 'Отклонено';

  @override
  String get shopStatsVisible => 'Видно в каталоге';

  @override
  String get shopStatsInquiries => 'Обращения';

  @override
  String get shopStatsNewInquiries => 'Новые обращения';

  @override
  String get shopStatsPlacements => 'Размещено в комнатах';

  @override
  String get shopStatsTop => 'Самые выбираемые товары';

  @override
  String get shopStatsTopEmpty => 'Данных пока нет.';

  @override
  String get mastersSendFailed => 'Не удалось отправить. Попробуйте ещё раз.';

  @override
  String shopCheckoutUnlinkedLines(String names) {
    return 'Некоторые товары в корзине не связаны с каталогом магазина, поэтому заказ оформить нельзя: $names. Удалите их из корзины.';
  }

  @override
  String shopOrderPartial(String dealer, String error) {
    return 'Заказ $dealer не принят: $error Остальные заказы отправлены.';
  }

  @override
  String get shopOrdersTitle => 'Заказы';

  @override
  String get shopOrdersOpen => 'Заказы';

  @override
  String get shopOrdersEmpty =>
      'Заказов пока нет. Когда клиенты закажут, они появятся здесь.';

  @override
  String get shopOrderMarkGathering => 'Отметить: собирается';

  @override
  String get shopOrderMarkOnTheWay => 'Отметить: в пути';

  @override
  String get shopOrderMarkDelivered => 'Отметить: доставлен';

  @override
  String shopOrderAddressLine(String value) {
    return 'Адрес: $value';
  }

  @override
  String shopOrderPaymentLine(String value) {
    return 'Оплата: $value';
  }

  @override
  String get shopOrderPayCash => 'Наличными';

  @override
  String get shopOrderPayCard => 'Картой';

  @override
  String get tradePlitkachi => 'Плиточник';

  @override
  String get tradeShtukatur => 'Штукатур';

  @override
  String get tradeGipsokartonchi => 'Гипсокартонщик';

  @override
  String get tradeEshikOyna => 'Мастер по дверям и окнам';

  @override
  String get tradeIsitishKonditsioner => 'Мастер по отоплению и кондиционерам';

  @override
  String get tradeDemontaj => 'Мастер по демонтажу';

  @override
  String get ustaPortfolioOpen => 'Портфолио';

  @override
  String get ustaPortfolioTitle => 'Моё портфолио';

  @override
  String get ustaPortfolioEmpty =>
      'Фотографий работ пока нет. Добавьте выполненные работы.';

  @override
  String get ustaPortfolioAdd => 'Добавить фото';

  @override
  String get ustaPortfolioCaption => 'Подпись (необязательно)';

  @override
  String get ustaPortfolioUpload => 'Загрузить';

  @override
  String get ustaPortfolioDeleteConfirm => 'Удалить фото? Это нельзя отменить.';

  @override
  String get ustaPortfolioLoadFailed => 'Не удалось загрузить портфолио.';

  @override
  String ustaLeadMessage(String message) {
    return 'Сообщение клиента: $message';
  }

  @override
  String get profileMenuDeleteAccount => 'Удалить аккаунт';

  @override
  String get deleteAccountTitle => 'Удалить аккаунт?';

  @override
  String get deleteAccountBody =>
      'Вместе с аккаунтом будут удалены все ваши проекты, фотографии, заказы, а также профиль магазина или мастера. Это необратимо, отменить удаление нельзя.';

  @override
  String get deleteAccountPasswordLabel => 'Пароль';

  @override
  String get deleteAccountPasswordHint =>
      'Если входили по коду из SMS, оставьте пустым';

  @override
  String get deleteAccountDone => 'Ваш аккаунт удалён';

  @override
  String scanFailedReason(String reason) {
    return 'Причина: $reason';
  }

  @override
  String get shopCategoryBoyoq => 'Краска';

  @override
  String get shopCategoryOboy => 'Обои';

  @override
  String get shopCategoryLaminat => 'Ламинат';

  @override
  String get shopCategoryKafel => 'Плитка';

  @override
  String get shopCategoryParket => 'Паркет';

  @override
  String get shopCategoryGips => 'Гипс';

  @override
  String get shopCategorySement => 'Цемент';

  @override
  String get shopCategorySantexnika => 'Сантехника';

  @override
  String get shopCategoryElektr => 'Электрика';

  @override
  String get shopCategoryEshik => 'Двери';

  @override
  String get shopCategoryDeraza => 'Окна';

  @override
  String get tradeBoshqa => 'Другой мастер';

  @override
  String get qualityTierEkonom => 'Эконом';

  @override
  String get qualityTierStandart => 'Стандарт';

  @override
  String get qualityTierPremium => 'Премиум';

  @override
  String get estimateOpen3dStudio => '3D-студия';

  @override
  String get actionDelete => 'Удалить';

  @override
  String get mapAttribution => '© участники OpenStreetMap';

  @override
  String get pushPromptTitle => 'Сообщать вам?';

  @override
  String get pushPromptBody =>
      'Сообщим, когда дизайн будет готов или изменится статус заказа.';

  @override
  String get pushPromptYes => 'Да';

  @override
  String get pushPromptLater => 'Позже';

  @override
  String get settingsNotificationsTitle => 'Уведомления';

  @override
  String get settingsNotificationsOn => 'Включены';

  @override
  String get settingsNotificationsOff => 'Выключены';

  @override
  String get pushChannelName => 'Новости Andoza';

  @override
  String get sharePinTitle => 'Пин из Pinterest';

  @override
  String get sharePinChooseRoom => 'К какой комнате применить?';

  @override
  String get sharePinHint => 'AI-дизайнер в Студии откроется с этим пином.';

  @override
  String get sharePinNoRooms =>
      'Комнат пока нет. Сначала добавьте комнату через «+».';

  @override
  String get sharePinNotPin => 'Это не ссылка на пин Pinterest';

  @override
  String get sharePinNotPinHint =>
      'Откройте пин в приложении Pinterest и выберите «Поделиться» → Andoza AI.';

  @override
  String get furnitureStylesLabel => 'Стили';

  @override
  String get furnitureStylesAll => 'Подходит ко всем стилям';

  @override
  String get furnitureStyleNeoklassika => 'Неоклассика';

  @override
  String get furnitureStyleKlassik => 'Классика';

  @override
  String get furnitureStyleZamonaviy => 'Современный';

  @override
  String get furnitureStyleHitech => 'Хай-тек';

  @override
  String get furnitureStyleMinimalist => 'Минимализм';

  @override
  String get furnitureStyleSkandinav => 'Скандинавский';

  @override
  String get furnitureStyleLoft => 'Лофт';

  @override
  String get furnitureStyleMilliy => 'Национальный';

  @override
  String get estimateFloorStandIn =>
      'Товар для пола не выбран — цена взята по средней в магазинах (примерно).';

  @override
  String get scanChoiceTitle => 'Что сканируем?';

  @override
  String get scanChoiceOneRoom => 'Одну комнату';

  @override
  String get scanChoiceFlat => 'Несколько комнат (квартира)';

  @override
  String get scanChoiceFlatHint =>
      'Сканируйте комнаты подряд — они встанут на свои места в плане';

  @override
  String get scanNextRoom => 'Следующая комната';

  @override
  String get scanFinish => 'Готово';

  @override
  String scanRoomN(int n) {
    return 'Комната $n';
  }

  @override
  String get flatReviewTitle => 'Отсканированные комнаты';

  @override
  String get flatReviewRoomName => 'Название комнаты';

  @override
  String get flatReviewContinue => 'Открыть в студии';

  @override
  String flatReviewPartial(int n) {
    return 'Сканирование прервалось — сохранено комнат: $n';
  }

  @override
  String flatReviewDropped(int n) {
    return 'Не удалось распознать комнат: $n, они не добавлены';
  }

  @override
  String flatReviewSavedSome(int saved, int total) {
    return 'Сохранено комнат: $saved из $total — остальные отсканируйте заново';
  }

  @override
  String get loginWithApple => 'Войти через Apple';

  @override
  String get loginAppleFailed =>
      'Не удалось войти через Apple. Попробуйте ещё раз.';

  @override
  String get reportAction => 'Пожаловаться';

  @override
  String get reportTitle => 'Жалоба';

  @override
  String get reportHint => 'Что не так? Модераторы рассмотрят жалобу.';

  @override
  String get reportReasonSpam => 'Спам или реклама';

  @override
  String get reportReasonInappropriate => 'Неприемлемый контент';

  @override
  String get reportReasonFraud => 'Мошенничество';

  @override
  String get reportReasonOther => 'Другое';

  @override
  String get reportDetails => 'Комментарий (необязательно)';

  @override
  String get reportSend => 'Отправить';

  @override
  String get reportSent => 'Спасибо! Жалоба отправлена.';

  @override
  String get blockUstaAction => 'Заблокировать';

  @override
  String get blockUstaTitle => 'Заблокировать мастера?';

  @override
  String get blockUstaBody =>
      'Он больше не будет виден вам на карте и в списке.';

  @override
  String get blockUstaConfirm => 'Заблокировать';

  @override
  String get blockUstaDone => 'Мастер заблокирован';

  @override
  String get shopFurnitureSection => 'Мебель';

  @override
  String get shopFurnitureNoPrice => 'Цена по договорённости';

  @override
  String storePageOpen(String name) {
    return 'Магазин «$name»';
  }

  @override
  String get storeLoadFailed => 'Не удалось открыть магазин';

  @override
  String get storeCall => 'Позвонить';

  @override
  String get storeTelegram => 'Telegram';

  @override
  String get storeNoProducts => 'В этом магазине пока нет товаров';

  @override
  String get storeReport => 'Пожаловаться на магазин';

  @override
  String get furnitureSize => 'Размер';

  @override
  String furnitureSizeValue(String size) {
    return '$size см';
  }

  @override
  String get furniturePlaceInRoom => 'Поставить в мою комнату';

  @override
  String get furniturePickRoom => 'В какую комнату поставить?';

  @override
  String get furnitureNoRooms => 'Сначала создайте или отсканируйте комнату';

  @override
  String get furnitureNoModel =>
      'У этого товара нет 3D-модели, его нельзя поставить в комнату';

  @override
  String get furnitureLoadFailed => 'Не удалось открыть товар';

  @override
  String get profileMenuMebel => 'Производство мебели';

  @override
  String get profileMenuMebelHint => 'Для цехов: детали шкафа, кромка и цена';

  @override
  String get mebelExportFailed => 'Не удалось открыть файл';

  @override
  String get scanHintStart => 'Медленно обойдите комнату, сканируя её';

  @override
  String get scanCoachMoveCloser => 'Поднесите телефон ближе к стене';

  @override
  String get scanCoachMoveAway => 'Отодвиньте телефон немного от стены';

  @override
  String get scanCoachSlowDown => 'Вы двигаетесь слишком быстро — помедленнее';

  @override
  String get scanCoachTurnOnLight => 'В комнате темно — включите свет';

  @override
  String get scanCoachLowTexture =>
      'Поверхность слишком однородная — направьте камеру в другую сторону';

  @override
  String get scanCoachGood =>
      'Отлично — продолжайте обходить комнату в том же темпе';

  @override
  String get scanCoachKeepGoing => 'Продолжайте сканирование';
}
