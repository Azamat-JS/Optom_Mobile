// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonRetry => 'Повторить';

  @override
  String get commonLogout => 'Выйти';

  @override
  String get commonLogin => 'Войти';

  @override
  String get commonRegister => 'Регистрация';

  @override
  String get commonSettings => 'Настройки';

  @override
  String get commonUnknownError => 'Произошла неизвестная ошибка.';

  @override
  String roleLabel(String role) {
    String _temp0 = intl.Intl.selectLogic(role, {
      'superAdmin': 'Супер-админ',
      'seller': 'Оптовик',
      'sellerAdmin': 'Сотрудник оптовика',
      'retailer': 'Магазин',
      'retailerAdmin': 'Сотрудник магазина',
      'customer': 'Клиент',
      'waiter': 'Официант',
      'courier': 'Курьер',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get languageTitle => 'Язык';

  @override
  String get languageHint => 'Выберите язык интерфейса';

  @override
  String get languageChange => 'Сменить язык';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsAccount => 'Аккаунт';

  @override
  String get authPhoneLabel => 'Номер телефона';

  @override
  String get authPhoneRequired => 'Введите номер телефона';

  @override
  String get authPhoneFormat => 'Формат: +998XXXXXXXXX';

  @override
  String get loginSubtitle => 'Вход в систему Optom Savdo';

  @override
  String get loginContinueWithTelegram => 'Продолжить через Telegram';

  @override
  String get loginAccountAutoCreated =>
      'Если у вас нет аккаунта, он будет создан автоматически';

  @override
  String get loginWithPassword => 'Войти по паролю';

  @override
  String get loginPasswordLabel => 'Пароль';

  @override
  String get loginPasswordRequired => 'Введите пароль';

  @override
  String get loginPasswordMinLength => 'Минимум 6 символов';

  @override
  String get registerSubtitle => 'Создание аккаунта клиента';

  @override
  String get registerHint =>
      'Номер подтверждается через Telegram. Имя и фамилия берутся из вашего профиля Telegram — позже их можно изменить в профиле.';

  @override
  String get registerWithTelegram => 'Зарегистрироваться через Telegram';

  @override
  String get registerHaveAccount => 'Уже есть аккаунт? Войти';

  @override
  String get splashError => 'Не удалось запустить приложение.';

  @override
  String get tgTitle => 'Подтверждение через Telegram';

  @override
  String get tgOpenFailed =>
      'Не удалось открыть Telegram. Проверьте, что приложение установлено.';

  @override
  String get tgPhoneVerified => 'Номер подтверждён ✅';

  @override
  String get tgWelcomeNew => 'Добро пожаловать! Аккаунт создан.';

  @override
  String get tgWelcome => 'Добро пожаловать!';

  @override
  String get tgChangePhone => 'Изменить номер';

  @override
  String get tgPreparing => 'Подготовка…';

  @override
  String get tgVerified => 'Подтверждено';

  @override
  String get tgVerifiedLoggingIn => 'Подтверждено, выполняется вход…';

  @override
  String get tgFinishStepVerify =>
      'Вернитесь в приложение — подтверждение завершится автоматически';

  @override
  String get tgFinishStepLogin =>
      'Вернитесь в приложение — вход выполнится автоматически';

  @override
  String get tgMismatchTitle => 'Номер не совпадает';

  @override
  String tgMismatchOwn(String phone) {
    return 'Номер в вашем Telegram-аккаунте не совпадает с номером $phone в вашем профиле. Используйте Telegram-аккаунт, привязанный к этому номеру.';
  }

  @override
  String tgMismatch(String phone) {
    return 'Номер в вашем Telegram-аккаунте не совпадает с $phone. Используйте Telegram-аккаунт, привязанный к этому номеру, или измените номер.';
  }

  @override
  String get tgExpiredTitle => 'Время подтверждения истекло';

  @override
  String get tgExpiredMessage =>
      'Номер не был подтверждён в течение 10 минут. Попробуйте ещё раз.';

  @override
  String get tgFailedTitle => 'Не удалось подтвердить';

  @override
  String get tgConfirmInTelegram => 'Подтвердите в Telegram';

  @override
  String get tgStep1 => 'В Telegram откроется бот подтверждения bsmart';

  @override
  String get tgStep2 => 'Нажмите кнопку «Start»';

  @override
  String get tgStep3 =>
      'Нажмите кнопку «📱 Raqamni tasdiqlash» (подтвердить номер)';

  @override
  String tgWaiting(String countdown) {
    return 'Ожидание подтверждения · $countdown';
  }

  @override
  String get tgOpenTelegram => 'Открыть Telegram';

  @override
  String get verifyBannerAction => 'Подтвердить номер';

  @override
  String get verifyBannerProfile =>
      'Подтвердите номер телефона через Telegram, чтобы отслеживать доставки из ресторанов и видеть свои долги.';

  @override
  String get verifyBannerDebts =>
      'Подтвердите номер телефона через Telegram, чтобы видеть свои долги в магазинах.';

  @override
  String get verifyBannerDeliveries =>
      'Подтвердите номер телефона через Telegram, чтобы отслеживать заказы, сделанные в ресторане по телефону.';

  @override
  String get tgNotifTitle => 'Уведомления в Telegram';

  @override
  String get tgNotifConnect => 'Подключить';

  @override
  String get tgNotifOff => 'Выключены';

  @override
  String get tgNotifCustomerEnabled =>
      'Сообщим, когда курьер заберёт заказ, приедет и передаст его';

  @override
  String get tgNotifCustomerLink =>
      'Подтвердите номер через Telegram, чтобы получать сообщения, когда заказ в пути';

  @override
  String get tgNotifCourierEnabled =>
      'Сообщим, когда вам назначат, предложат или отменят доставку';

  @override
  String get tgNotifCourierLink =>
      'Подтвердите номер, чтобы получать сообщения о новых доставках в Telegram';

  @override
  String get tgNotifLinkTelegram => 'Подключить Telegram';

  @override
  String get tgNotifEnabled => 'Уведомления включены';

  @override
  String get tgNotifDisabled => 'Уведомления выключены';

  @override
  String get navCatalog => 'Каталог';

  @override
  String get navCart => 'Корзина';

  @override
  String get navFavorites => 'Избранное';

  @override
  String get navProfile => 'Профиль';

  @override
  String get navMenu => 'Меню';

  @override
  String get navDeliveries => 'Доставки';

  @override
  String get navPos => 'Касса';

  @override
  String get navOrders => 'Заказы';

  @override
  String get navProducts => 'Товары';

  @override
  String get navCustomers => 'Клиенты';

  @override
  String get navSalesHistory => 'История продаж';

  @override
  String get navDebts => 'Долги';

  @override
  String get navReports => 'Отчёты';

  @override
  String get navFleetMap => 'Карта курьеров';

  @override
  String get navRestaurantOrders => 'Заказы ресторана';

  @override
  String get navTables => 'Столы';

  @override
  String get navStores => 'Магазины';

  @override
  String get navStaff => 'Сотрудники';

  @override
  String get navWaiters => 'Официанты';

  @override
  String get navCouriers => 'Курьеры';

  @override
  String get navExpenditures => 'Мои расходы';

  @override
  String get navUsers => 'Пользователи';

  @override
  String get navCategories => 'Категории';

  @override
  String get navCatalogModeration => 'Модерация каталога';

  @override
  String get profileLoginPrompt => 'Войдите, чтобы открыть профиль';

  @override
  String get profilePhoneVerified => 'Номер подтверждён';

  @override
  String get profileMyOrders => 'Мои заказы';

  @override
  String get profileMyDeliveries => 'Мои доставки';

  @override
  String get profileMyDebts => 'Мои долги';

  @override
  String homeWelcome(String name) {
    return 'Добро пожаловать, $name';
  }

  @override
  String get homeStatistics => 'Статистика';

  @override
  String get homeStatsLoadFailed => 'Не удалось загрузить статистику';

  @override
  String get homeTodaySales => 'Продажи за сегодня';

  @override
  String get homeTotalSales => 'Всего продаж';

  @override
  String homeSalesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count продажи',
      many: '$count продаж',
      few: '$count продажи',
      one: '$count продажа',
    );
    return '$_temp0';
  }

  @override
  String get homeOutstandingDebt => 'Задолженность';

  @override
  String get homeReceivedPayments => 'Полученные платежи';

  @override
  String get homeCustomerDebts => 'Долги клиентов';

  @override
  String get homeWholesalerDebts => 'Долги оптовикам';
}
