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
  String get authTagline => 'Умная торговля, цельный бизнес';

  @override
  String get authEnterNumber => 'Введите номер';

  @override
  String get authSkip => 'Позже';

  @override
  String get authOr => 'или';

  @override
  String get authClear => 'Очистить';

  @override
  String get tgVerifyingNumber => 'Подтверждаемый номер';

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

  @override
  String enumOrderStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'newOrder': 'Новый',
      'approved': 'Подтверждён',
      'rejected': 'Отклонён',
      'delivered': 'Доставлен',
      'debtRecorded': 'Записан в долг',
      'paid': 'Оплачен',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String enumPaymentMethod(String method) {
    String _temp0 = intl.Intl.selectLogic(method, {
      'cash': 'Наличные',
      'card': 'Карта',
      'bankTransfer': 'Банковский перевод',
      'click': 'Click',
      'payme': 'Payme',
      'debt': 'В долг',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String enumBusinessType(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'general': 'Магазин',
      'restaurant': 'Ресторан',
      'applianceStore': 'Бытовая техника',
      'constructionTools': 'Стройматериалы',
      'toyStore': 'Игрушки',
      'autoParts': 'Автозапчасти',
      'pharmacy': 'Аптека',
      'clothingStore': 'Одежда',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String enumExpenditureType(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'electricity': 'Электроэнергия',
      'gas': 'Газ',
      'water': 'Вода',
      'taxes': 'Налоги',
      'renting': 'Аренда',
      'other': 'Прочее',
    });
    return '$_temp0';
  }

  @override
  String enumProductUnit(String unit) {
    String _temp0 = intl.Intl.selectLogic(unit, {
      'dona': 'Шт.',
      'metr': 'Метр',
      'litr': 'Литр',
      'kilogram': 'Килограмм',
      'gram': 'Грамм',
      'blok': 'Блок',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String enumRestaurantOrderType(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'dineIn': 'В зале',
      'delivery': 'Доставка',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String enumRestaurantOrderStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'newOrder': 'Новый',
      'preparing': 'Готовится',
      'ready': 'Готов',
      'served': 'Подан',
      'delivered': 'Доставлен',
      'cancelled': 'Отменён',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String enumSaleType(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'paid': 'Оплачено',
      'debt': 'В долг',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String enumSaleStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'completed': 'Завершена',
      'cancelled': 'Отменена',
      'partiallyReturned': 'Частично возвращена',
      'returned': 'Возвращена',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String enumDebtStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'active': 'Активный',
      'partial': 'Частично оплачен',
      'settled': 'Погашен',
      'overdue': 'Просрочен',
      'writtenOff': 'Списан',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get currencySom => 'сум';

  @override
  String get errorSessionExpired => 'Сессия истекла, войдите снова.';

  @override
  String get errorForbidden => 'У вас нет прав на это действие.';

  @override
  String get errorNotFound => 'Не найдено.';

  @override
  String get errorConflict => 'Не удалось выполнить действие: конфликт данных.';

  @override
  String get errorNoInternet => 'Нет подключения к интернету.';

  @override
  String get errorInvalidData => 'Данные введены неверно.';

  @override
  String get tgTooManyAttempts =>
      'Слишком много попыток для этого номера. Попробуйте чуть позже.';

  @override
  String get tgUnavailable =>
      'Подтверждение через Telegram временно недоступно. Попробуйте позже.';

  @override
  String get tgInvalidPhone => 'Неверный номер телефона. Формат: +998XXXXXXXXX';

  @override
  String get commonSave => 'Сохранить';

  @override
  String get commonDelete => 'Удалить';

  @override
  String get commonAdd => 'Добавить';

  @override
  String get commonEdit => 'Редактировать';

  @override
  String get commonActive => 'Активен';

  @override
  String get commonInactive => 'Неактивен';

  @override
  String get commonAll => 'Все';

  @override
  String get commonNone => 'Нет';

  @override
  String get commonNotSelected => 'Не выбрано';

  @override
  String get commonNotSelectedDash => '— Не выбрано —';

  @override
  String commonErrorWith(String error) {
    return 'Ошибка: $error';
  }

  @override
  String get commonNothingFound => 'Ничего не найдено';

  @override
  String get commonReject => 'Отклонить';

  @override
  String get commonReasonOptional => 'Причина (необязательно)';

  @override
  String get commonName => 'Название';

  @override
  String get commonNameRequired => 'Название *';

  @override
  String get commonNameMissing => 'Введите название';

  @override
  String get commonDescription => 'Описание';

  @override
  String get commonCategory => 'Категория';

  @override
  String get commonBrand => 'Бренд';

  @override
  String get commonBarcode => 'Штрихкод';

  @override
  String get commonPrice => 'Цена';

  @override
  String get commonPriceRequired => 'Цена *';

  @override
  String get commonCostPrice => 'Себестоимость';

  @override
  String get commonStock => 'Остаток';

  @override
  String get commonUnit => 'Единица измерения';

  @override
  String get commonCurrency => 'Валюта';

  @override
  String get commonCurrencyRequired => 'Валюта *';

  @override
  String get currencyUzsLong => 'Сум (UZS)';

  @override
  String get currencyUsdLong => 'Доллар (USD)';

  @override
  String get commonQuantityRequired => 'Укажите количество';

  @override
  String get productsTitle => 'Товары';

  @override
  String get productsProduct => 'Товар';

  @override
  String get productsSentToCatalog => 'Отправлено в каталог на проверку';

  @override
  String get productsDeleteTitle => 'Удалить товар';

  @override
  String get productsDeleteConfirm => 'Удалить этот товар?';

  @override
  String productsCostPriceWith(String price) {
    return 'Себестоимость: $price';
  }

  @override
  String get productsAddStock => 'Пополнить остаток';

  @override
  String get productsCreateBarcode => 'Создать штрихкод';

  @override
  String get productsShareToCatalog => 'Поделиться в каталог';

  @override
  String get productsNameOrCatalog =>
      'Введите название товара или выберите из каталога';

  @override
  String get productsPriceInvalid => 'Цена указана неверно';

  @override
  String get productsEditTitle => 'Редактировать товар';

  @override
  String get productsNewTitle => 'Новый товар';

  @override
  String get productsPriceRequired => 'Укажите цену';

  @override
  String get productsInitialStock => 'Начальный остаток';

  @override
  String productsStockEditHint(String stock) {
    return '$stock — чтобы изменить, используйте кнопку «Пополнить остаток» на странице товара';
  }

  @override
  String get productsPluSuggest => 'Предложить';

  @override
  String get productsExpiryOptional => 'Срок годности (необязательно)';

  @override
  String get productsPickFromCatalog => 'Выбрать из каталога';

  @override
  String get productsNameRequired => 'Название товара *';

  @override
  String get productsFindTitle => 'Найти товар';

  @override
  String get productsSearchHint => 'Поиск по названию или штрихкоду...';

  @override
  String get productsNotFound => 'Товары не найдены';

  @override
  String productsCurrentStock(String stock) {
    return 'Текущий остаток: $stock';
  }

  @override
  String get productsAddQuantity => 'Количество к добавлению';

  @override
  String get productsCorrectionOptional =>
      'Дополнительная корректировка (необязательно)';

  @override
  String get productsCorrectionHint => 'Можно ввести и отрицательное число';

  @override
  String get commonConfirm => 'Подтвердить';

  @override
  String get commonDone => 'Готово';

  @override
  String get commonSearchHint => 'Поиск...';

  @override
  String get commonInactiveShort => 'Неактивна';

  @override
  String commonDeleteWithDependentsConfirm(String name) {
    return 'Удалить «$name»? Если к нему привязаны товары, вернётся ошибка.';
  }

  @override
  String get masterStatusPending => 'На рассмотрении';

  @override
  String get masterStatusApproved => 'Одобрен';

  @override
  String get masterStatusRejected => 'Отклонён';

  @override
  String get masterDeleteTitle => 'Удалить запись каталога';

  @override
  String get masterReviewTitle => 'Модерация каталога';

  @override
  String get masterEditTitle => 'Редактировать запись каталога';

  @override
  String get masterNewTitle => 'Новая запись каталога';

  @override
  String get masterActiveVisible => 'Активна (видна в каталоге)';

  @override
  String get masterSearchHint => 'Поиск в каталоге...';

  @override
  String get categoriesDeleteTitle => 'Удалить категорию';

  @override
  String get categoriesTitle => 'Категории';

  @override
  String get categoriesNotFound => 'Категории не найдены';

  @override
  String get categoriesEditTitle => 'Редактировать категорию';

  @override
  String get categoriesNewTitle => 'Новая категория';

  @override
  String get categoriesParent => 'Родительская категория';

  @override
  String get categoriesNoParent => '— Нет (основная категория) —';

  @override
  String get categoriesSortOrder => 'Порядковый номер';

  @override
  String get categoriesPickerNotFound => 'Категория не найдена';

  @override
  String get commonDeactivate => 'Деактивировать';

  @override
  String get commonFirstNameRequired => 'Имя *';

  @override
  String get commonFirstNameMissing => 'Введите имя';

  @override
  String get commonLastNameRequired => 'Фамилия *';

  @override
  String get commonLastNameMissing => 'Введите фамилию';

  @override
  String get commonPhoneRequired => 'Телефон *';

  @override
  String get commonPhoneMissing => 'Введите номер телефона';

  @override
  String get commonInvalidFormat => 'Неверный формат';

  @override
  String get commonAddress => 'Адрес';

  @override
  String get commonNote => 'Примечание';

  @override
  String get commonTotal => 'Итого';

  @override
  String get commonSubtotal => 'Промежуточная сумма';

  @override
  String get commonDiscount => 'Скидка';

  @override
  String commonPieces(String count) {
    return '$count шт.';
  }

  @override
  String commonProductCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count товаров',
      few: '$count товара',
      one: '$count товар',
    );
    return '$_temp0';
  }

  @override
  String get commonProducts => 'Товары';

  @override
  String get commonDeliveryAddress => 'Адрес доставки';

  @override
  String get customersDeactivateTitle => 'Деактивировать клиента';

  @override
  String customersDeactivateConfirm(String name) {
    return 'Деактивировать клиента $name?';
  }

  @override
  String get customersTitle => 'Клиенты';

  @override
  String get customersSearchHint => 'Поиск по имени или телефону...';

  @override
  String get customersNotFound => 'Клиенты не найдены';

  @override
  String get customersEditTitle => 'Редактировать клиента';

  @override
  String get customersNewTitle => 'Новый клиент';

  @override
  String get ordersSingleCurrency =>
      'В одном заказе могут быть товары только в одной валюте';

  @override
  String ordersAddedToCart(String name) {
    return '$name добавлен в корзину';
  }

  @override
  String get ordersSearchProduct => 'Поиск товара...';

  @override
  String get ordersAllBranches => 'Все филиалы';

  @override
  String ordersCartSummary(int count, String total) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count товаров',
      few: '$count товара',
      one: '$count товар',
    );
    return '$_temp0 — $total';
  }

  @override
  String get ordersPickWholesaler => 'Выберите оптовика';

  @override
  String get ordersNoWholesalers => 'Оптовики не найдены';

  @override
  String get ordersIncomingTitle => 'Входящие заказы';

  @override
  String get ordersMineTitle => 'Мои заказы';

  @override
  String get ordersTabOutgoing => 'Исходящие';

  @override
  String get ordersTabIncoming => 'Входящие';

  @override
  String get ordersNotFound => 'Заказы не найдены';

  @override
  String get ordersReviewTitle => 'Проверка заказа';

  @override
  String get ordersPlace => 'Оформить заказ';

  @override
  String get ordersApproveTitle => 'Подтвердить заказ';

  @override
  String get ordersApproveConfirm =>
      'Подтвердить этот заказ? Остатки товаров уменьшатся.';

  @override
  String get ordersRejectTitle => 'Отклонить заказ';

  @override
  String get ordersDeliveredTitle => 'Отметить как доставленный';

  @override
  String get ordersDeliveredConfirm => 'Подтвердить, что этот заказ доставлен?';

  @override
  String get ordersOrder => 'Заказ';

  @override
  String ordersRejectionReason(String reason) {
    return 'Причина отклонения: $reason';
  }

  @override
  String get ordersSeller => 'Продавец';

  @override
  String get ordersBuyer => 'Покупатель';

  @override
  String get ordersHistory => 'История';

  @override
  String get ordersDelivered => 'Доставлен';

  @override
  String get commonUnknownPerson => 'Неизвестно';

  @override
  String get commonAmount => 'Сумма';

  @override
  String get commonPaymentMethod => 'Способ оплаты';

  @override
  String get commonNoteOptional => 'Примечание (необязательно)';

  @override
  String get commonClose => 'Закрыть';

  @override
  String get commonDateRequired => 'Дата *';

  @override
  String commonTotalWith(String amount) {
    return 'Итого: $amount';
  }

  @override
  String commonBalanceWith(String amount) {
    return 'Остаток: $amount';
  }

  @override
  String commonDueWith(String date) {
    return 'Срок: $date';
  }

  @override
  String get expensesEditTitle => 'Редактировать расход';

  @override
  String get expensesNewTitle => 'Новый расход';

  @override
  String get expensesTypeRequired => 'Тип *';

  @override
  String get expensesAmountRequired => 'Сумма (сум) *';

  @override
  String get expensesAmountMissing => 'Введите сумму';

  @override
  String get expensesAmountInvalid => 'Неверная сумма';

  @override
  String get expensesDeleteTitle => 'Удалить расход';

  @override
  String expensesDeleteConfirm(String expense) {
    return 'Удалить расход «$expense» навсегда?';
  }

  @override
  String get expensesTitle => 'Мои расходы';

  @override
  String get expensesFilterByType => 'Фильтр по типу';

  @override
  String get expensesTotal => 'Всего расходов';

  @override
  String get expensesNotFound => 'Расходы не найдены';

  @override
  String debtsPaymentsApplied(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Платёж распределён на $count долгов',
      few: 'Платёж распределён на $count долга',
      one: 'Платёж распределён на $count долг',
    );
    return '$_temp0';
  }

  @override
  String get debtsCloseTitle => 'Закрыть долг';

  @override
  String debtsCloseConfirm(String amount) {
    return 'Отметить оставшиеся $amount как полностью оплаченные?';
  }

  @override
  String debtsTotalBalance(String amount) {
    return 'Общий остаток: $amount';
  }

  @override
  String get debtsPayDownTitle => 'Общий платёж (FIFO)';

  @override
  String get debtsPayDownHint =>
      'Распределяется автоматически, начиная с самого старого долга';

  @override
  String get debtsAllocation => 'Распределение:';

  @override
  String get debtsWillClose => '(будет закрыт)';

  @override
  String get debtsExceedsTotal => 'Сумма превышает общий остаток';

  @override
  String get debtsConfirmPayment => 'Подтвердить платёж';

  @override
  String get debtsTitle => 'Долги';

  @override
  String get debtsPayment => 'Платёж';

  @override
  String get debtsTabCustomers => 'Клиенты';

  @override
  String get debtsTabOwedToMe => 'Мне должны';

  @override
  String get debtsTabMine => 'Мои долги';

  @override
  String get debtsNotFound => 'Долги не найдены';

  @override
  String get debtsCustomerNotFound => 'Долги клиентов не найдены';

  @override
  String debtsActiveCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count активных долгов',
      few: '$count активных долга',
      one: '$count активный долг',
    );
    return '$_temp0';
  }

  @override
  String get debtsEnterValidAmount => 'Введите корректную сумму';

  @override
  String debtsAmountExceedsBalance(String balance) {
    return 'Сумма не должна превышать остаток ($balance)';
  }

  @override
  String get debtsMakePayment => 'Внести платёж';

  @override
  String get commonActivate => 'Активировать';

  @override
  String commonDeletePermanentlyConfirm(String name) {
    return 'Удалить «$name» навсегда?';
  }

  @override
  String get commonPasswordRequired => 'Пароль *';

  @override
  String get staffDeleteTitle => 'Удалить сотрудника';

  @override
  String get staffTitle => 'Сотрудники';

  @override
  String get staffNotFound => 'Сотрудники не найдены';

  @override
  String get staffStoreRequired => 'Выберите магазин';

  @override
  String get staffEditTitle => 'Редактировать сотрудника';

  @override
  String get staffNewTitle => 'Новый сотрудник';

  @override
  String get staffStoreLabel => 'Магазин *';

  @override
  String get storesDeleteTitle => 'Удалить магазин';

  @override
  String get storesTitle => 'Магазины';

  @override
  String get storesDefault => 'Основной';

  @override
  String get storesEditTitle => 'Редактировать магазин';

  @override
  String get storesNewTitle => 'Новый магазин';

  @override
  String get storesMapLocation => 'Место на карте';

  @override
  String get storesLocationTitle => 'Расположение магазина';

  @override
  String get storesLocationHint => 'Курьеры забирают заказы отсюда';

  @override
  String get storesHandoverCode => 'Код передачи';

  @override
  String get storesHandoverCodeHint =>
      'При передаче заказа курьер спрашивает у клиента 4-значный код. У клиентов без приложения или подтверждённого номера код не спрашивается.';

  @override
  String get commonBalance => 'Остаток';

  @override
  String get commonPaid => 'Оплачено';

  @override
  String get commonOnCredit => 'В долг';

  @override
  String get commonPickCustomer => 'Выберите клиента';

  @override
  String get commonNew => 'Новый';

  @override
  String get posScanProduct => 'Сканировать товар';

  @override
  String get posBarcodeNotFound => 'Товар с таким штрихкодом не найден';

  @override
  String get posSingleCurrency =>
      'В одной продаже могут быть товары только в одной валюте';

  @override
  String get posTitle => 'Касса';

  @override
  String get posSavedCarts => 'Сохранённые корзины';

  @override
  String posPriceAndStock(String price, String stock) {
    return '$price · Остаток: $stock';
  }

  @override
  String get salesPickReturnItem => 'Выберите товар для возврата';

  @override
  String get salesReturn => 'Возврат';

  @override
  String salesReturnableLeft(String count) {
    return 'Осталось: $count';
  }

  @override
  String get salesRefundMethod => 'Способ возврата денег';

  @override
  String salesReturnAmount(String amount) {
    return 'Сумма к возврату: $amount';
  }

  @override
  String get salesConfirmReturn => 'Подтвердить возврат';

  @override
  String get salesPayment => 'Оплата';

  @override
  String get salesPaidNow => 'Оплачено';

  @override
  String get salesDownPaymentOptional => 'Предоплата (необязательно)';

  @override
  String salesConfirmWithTotal(String total) {
    return 'Подтвердить — $total';
  }

  @override
  String get salesHistoryTitle => 'История продаж';

  @override
  String get salesNotFound => 'Продажи не найдены';

  @override
  String get salesSale => 'Продажа';

  @override
  String get salesCreated => 'Продажа создана';

  @override
  String salesReturnedQty(String count) {
    return 'возвращено: $count';
  }

  @override
  String get salesDebt => 'Долг';

  @override
  String get salesPayments => 'Платежи';

  @override
  String get salesCustomerSearchHint => 'Имя или телефон...';

  @override
  String get salesCustomerNotFound => 'Клиент не найден';

  @override
  String get cartsSaved => 'Корзина сохранена';

  @override
  String get cartsSaveOrClearFirst =>
      'Сначала сохраните или очистите текущую корзину';

  @override
  String cartsSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count товаров не найдены и не добавлены',
      few: '$count товара не найдены и не добавлены',
      one: '$count товар не найден и не добавлен',
    );
    return '$_temp0 в корзину';
  }

  @override
  String get cartsDeleteTitle => 'Удалить сохранённую корзину';

  @override
  String get cartsDeleteConfirm => 'Это действие нельзя отменить. Продолжить?';

  @override
  String get cartsCurrentEmpty => 'Текущая корзина пуста';

  @override
  String cartsSaveCurrent(int count) {
    return 'Сохранить текущую корзину ($count)';
  }

  @override
  String get cartsNone => 'Сохранённых корзин нет';

  @override
  String cartsMore(int count) {
    return '+$count';
  }

  @override
  String get cartsRestore => 'Восстановить';

  @override
  String get commonNoData => 'Нет данных';

  @override
  String get reportsTitle => 'Отчёты';

  @override
  String get reportsTopProducts => 'Самые продаваемые товары';

  @override
  String reportsStockWith(String stock) {
    return 'Остаток: $stock';
  }

  @override
  String get reportsStatistics => 'Статистика';

  @override
  String get reportsRevenue => 'Выручка';

  @override
  String get reportsNewDebts => 'Новые долги';

  @override
  String get reportsDebtPayments => 'Погашения долгов';

  @override
  String get reportsOutstanding => 'Остаток задолженности';

  @override
  String get reportsSalesChart => 'График продаж';

  @override
  String get reportsLast30 => 'Последние 30 дней';

  @override
  String get reportsThisMonth => 'Этот месяц';

  @override
  String get workDayDebtsShareText => 'Список долгов';

  @override
  String get workDayTitle => 'Рабочий день';

  @override
  String get workDayOpen => 'Открыт';

  @override
  String get workDayClosed => 'Закрыт';

  @override
  String get workDayNotStarted => 'Рабочий день ещё не начат';

  @override
  String workDayStartedAt(String time) {
    return 'Начат: $time';
  }

  @override
  String workDayEndedAt(String time) {
    return 'Завершён: $time';
  }

  @override
  String get workDayStart => 'Начать рабочий день';

  @override
  String get workDayEnd => 'Завершить рабочий день';

  @override
  String get workDayExportDebts => 'Долги (Excel)';

  @override
  String get dashPaymentCash => 'Наличные';

  @override
  String get dashPaymentCard => 'Карта';

  @override
  String get dashPaymentBank => 'Банк';

  @override
  String get dashPaymentDebt => 'Долг';

  @override
  String get dashPaymentTypes => 'Способы оплаты';

  @override
  String get dashIncomeDebt6m => 'Доход и долг (6 мес.)';

  @override
  String get dashIncome => 'Доход';

  @override
  String get dashSalesTrend14d => 'Динамика продаж (14 дней)';

  @override
  String get scannerTitle => 'Отсканируйте штрихкод';

  @override
  String get locationMarkOnMap => 'Отметить на карте';

  @override
  String get locationPickTitle => 'Отметьте место';

  @override
  String get locationMarked => 'Отмечено на карте';

  @override
  String get locationCourierHint => 'Чтобы курьер нашёл точное место';

  @override
  String get locationRemove => 'Убрать';

  @override
  String get locationDetectFailed =>
      'Не удалось определить местоположение — проверьте GPS и разрешения';

  @override
  String get locationMyLocation => 'Моё местоположение';

  @override
  String get locationChooseHere => 'Выбрать это место';

  @override
  String sfGreeting(String name) {
    return 'Привет, $name!';
  }

  @override
  String get sfGreetingGuest => 'Добро пожаловать!';

  @override
  String get sfGreetingSubtitle => 'Что купим сегодня?';

  @override
  String get sfAllCategories => 'Все';

  @override
  String sfSearchHint(String term) {
    return 'Найти «$term»';
  }

  @override
  String get sfSearchHintDefault => 'Поиск товаров';

  @override
  String get sfShops => 'Магазины';

  @override
  String get sfNewArrivals => 'Новинки';

  @override
  String get sfFavoritesLogin => 'Войдите, чтобы видеть избранные товары';

  @override
  String get sfFavoritesEmpty =>
      'В избранном пока пусто. Нажмите ♡ на понравившемся товаре.';

  @override
  String get sfProductsSubtitle => 'Подборка товаров для вас';

  @override
  String sfInStock(String quantity) {
    return 'Осталось: $quantity';
  }

  @override
  String get sfOutOfStock => 'Нет в наличии';

  @override
  String get sfAdd => 'ДОБАВИТЬ';

  @override
  String sfAddedToCart(String name) {
    return '$name — в корзине';
  }

  @override
  String get sfCartOtherShop =>
      'В корзине могут быть товары только одного магазина';

  @override
  String get sfNoProducts => 'Товары не найдены';

  @override
  String get sfRemoveFilter => 'Убрать фильтр';

  @override
  String get sfSearchTitle => 'Поиск товаров и магазинов';

  @override
  String get sfSearchFieldHint => 'Ищите, выбирайте, заказывайте!';

  @override
  String get sfRecentSearches => 'Недавние запросы';

  @override
  String get sfClearRecent => 'Очистить историю';

  @override
  String get sfBrowseCategories => 'Категории';

  @override
  String get sfSuggestionProduct => 'Товар';

  @override
  String sfShopsFor(String query) {
    return 'Магазины по запросу «$query»';
  }

  @override
  String get sfMoreResults => 'Другие подходящие результаты';

  @override
  String get sfSearching => 'Подбираем самое подходящее…';

  @override
  String sfResultsIn(String category) {
    return 'Результаты: $category';
  }

  @override
  String get sfSort => 'Сортировка';

  @override
  String get sfSortRelevance => 'Рекомендуемые';

  @override
  String get sfSortPriceLow => 'Сначала дешёвые';

  @override
  String get sfSortPriceHigh => 'Сначала дорогие';

  @override
  String get sfSortName => 'По названию (А–Я)';

  @override
  String get sfInStockOnly => 'В наличии';

  @override
  String sfShopMatches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count подходящих товаров',
      few: '$count подходящих товара',
      one: '$count подходящий товар',
    );
    return '$_temp0';
  }

  @override
  String sfNoResults(String query) {
    return 'По запросу «$query» ничего не найдено';
  }

  @override
  String get sfNoResultsHint => 'Попробуйте другое слово или уберите фильтры';

  @override
  String get sfFeaturedShops => 'Подходящие магазины';

  @override
  String get sfChooseCategory => 'Где будем искать?';

  @override
  String get sfShopProducts => 'Товары магазина';

  @override
  String get sfProductsShort => 'товаров';

  @override
  String get sfChooseBranch => 'Выберите филиал';

  @override
  String get sfCurrentBranch => 'Текущий филиал';

  @override
  String get sfOtherBranches => 'Другие филиалы';

  @override
  String sfBranchesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count филиалов',
      few: '$count филиала',
      one: '$count филиал',
    );
    return '$_temp0 · выбрать другой';
  }

  @override
  String get sfCallShop => 'Позвонить';

  @override
  String get sfCallFailed => 'Не удалось позвонить';

  @override
  String get sfShopOwner => 'Владелец магазина';

  @override
  String sfSearchInShop(String shop) {
    return 'Поиск в «$shop»';
  }

  @override
  String get sfMenu => 'МЕНЮ';

  @override
  String get sfOtherCategory => 'Другое';

  @override
  String get sfCartHasOtherShop =>
      'В корзине товары другого магазина. Чтобы добавить товары отсюда, сначала очистите корзину.';

  @override
  String get sfShopEmpty => 'В этом магазине пока нет товаров';

  @override
  String get sfDescription => 'Описание';

  @override
  String get sfReadMore => 'подробнее';

  @override
  String get sfReadLess => 'свернуть';

  @override
  String get sfMoreFromShop => 'Ещё из этого магазина';

  @override
  String get sfOpenShop => 'В магазин';

  @override
  String get sfExploreShop => 'Смотреть с фото';

  @override
  String sfUnitLabel(String unit) {
    return 'Единица: $unit';
  }

  @override
  String sfInCart(String quantity) {
    return 'В корзине: $quantity';
  }
}
