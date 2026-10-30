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
      'leadAgent': 'Дилер',
      'agent': 'Агент',
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
  String get debtsWillClose => 'будет закрыт';

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

  @override
  String get cartEmptyTitle => 'Корзина пуста';

  @override
  String get cartEmptyHint =>
      'Добавляйте понравившиеся товары из магазинов — они появятся здесь.';

  @override
  String get cartStartShopping => 'За покупками';

  @override
  String get cartAddMore => 'Добавить ещё';

  @override
  String get cartRemove => 'Удалить';

  @override
  String get cartClear => 'Очистить корзину';

  @override
  String get cartClearConfirm => 'Все товары будут удалены из корзины.';

  @override
  String get cartBillTitle => 'Детали оплаты';

  @override
  String get cartItemsTotal => 'Товары';

  @override
  String get cartDelivery => 'Доставка';

  @override
  String get cartDeliveryAgreed => 'По договорённости с магазином';

  @override
  String get cartToPay => 'Итого';

  @override
  String get cartNoteLabel => 'ВАЖНО:';

  @override
  String get cartNote =>
      'Заказ подтверждает магазин. Условия оплаты и доставки магазин согласует с вами.';

  @override
  String get cartCheckout => 'Оформить';

  @override
  String cartUnitPrice(String price, String unit) {
    return '$price / $unit';
  }

  @override
  String enumProductUnitShort(String unit) {
    String _temp0 = intl.Intl.selectLogic(unit, {
      'dona': 'шт',
      'metr': 'м',
      'litr': 'л',
      'kilogram': 'кг',
      'gram': 'г',
      'blok': 'блок',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get coTitle => 'Оформление';

  @override
  String get coDeliverTo => 'Адрес доставки';

  @override
  String get coPickup => 'Заберу сам';

  @override
  String get coPickupHint => 'Вы заберёте заказ в магазине';

  @override
  String get coWhereToDeliver => 'Куда доставить заказ?';

  @override
  String get coAddAddress => 'Добавить адрес';

  @override
  String get coSelectAddress => 'Выбрать адрес';

  @override
  String get coNoDelivery => 'Без адреса — заберу сам';

  @override
  String get coItems => 'Состав заказа';

  @override
  String get coNoteHint => 'Комментарий для магазина (необязательно)';

  @override
  String get coPayment => 'Оплата';

  @override
  String get coPaymentValue => 'В магазине: наличные или карта';

  @override
  String coSlideToOrder(String total) {
    return 'Сдвиньте, чтобы заказать | $total';
  }

  @override
  String get coPlacing => 'Минутку!';

  @override
  String get coPlacedTitle => 'Заказ принят!';

  @override
  String coPlacedBody(String shop) {
    return '«$shop» рассмотрит ваш заказ и свяжется с вами.';
  }

  @override
  String get coTrackOrder => 'Открыть заказ';

  @override
  String get coContinueShopping => 'Продолжить покупки';

  @override
  String get addrSelectTitle => 'Выберите адрес';

  @override
  String get addrSearchHint => 'Поиск по сохранённым адресам';

  @override
  String get addrUseCurrent => 'Использовать текущее местоположение';

  @override
  String get addrPickOnMap => 'Отметить на карте';

  @override
  String get addrRecent => 'Недавние адреса';

  @override
  String get addrNoneSaved => 'Сохранённых адресов пока нет';

  @override
  String get addrDeliveredHere => 'Заказ будет доставлен сюда';

  @override
  String get addrFieldLabel => 'Адрес (улица, дом, квартира, ориентир)';

  @override
  String get addrConfirm => 'Подтвердить и продолжить';

  @override
  String get addrDetecting => 'Определяем адрес…';

  @override
  String get addrRemove => 'Удалить адрес';

  @override
  String otTitle(String number) {
    return 'Заказ #$number';
  }

  @override
  String otSubtitle(String time, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count товаров',
      few: '$count товара',
      one: '$count товар',
    );
    return '$time · $_temp0';
  }

  @override
  String get otNewTitle => 'Заказ принят!';

  @override
  String get otNewHint => 'Ждём, пока магазин подтвердит заказ';

  @override
  String get otApprovedTitle => 'Заказ собирают!';

  @override
  String get otApprovedHint => 'Магазин подтвердил и собирает заказ';

  @override
  String get otCourierSearching => 'Ищем курьера';

  @override
  String get otCourierAssigned => 'Курьер назначен';

  @override
  String get otCourierToShop => 'Курьер едет в магазин';

  @override
  String get otOnTheWay => 'Заказ в пути!';

  @override
  String get otArrived => 'Курьер на месте!';

  @override
  String get otDeliveredTitle => 'Заказ доставлен';

  @override
  String get otDeliveredHint => 'Спасибо за покупку!';

  @override
  String get otRejectedTitle => 'Заказ отклонён';

  @override
  String get otDeliveryCancelled => 'Доставка отменена';

  @override
  String get otDeliveryFailed => 'Не удалось доставить';

  @override
  String get otPickupAt => 'Вы заберёте заказ в магазине';

  @override
  String get otStepPlaced => 'Принят';

  @override
  String get otStepApproved => 'Подтверждён';

  @override
  String get otStepOnTheWay => 'В пути';

  @override
  String get otStepDelivered => 'Доставлен';

  @override
  String get otMins => 'мин';

  @override
  String get otViewItems => 'Список товаров';

  @override
  String get otTrackCourier => 'Следить за курьером на карте';

  @override
  String get otCallShop => 'Позвонить в магазин';

  @override
  String get otYourCourier => 'Ваш курьер';

  @override
  String get otRefresh => 'Обновить';

  @override
  String get otShowAll => 'Показать всё';

  @override
  String get otCourierUpdating => 'Обновляем местоположение курьера…';

  @override
  String otCourierBringing(String name) {
    return '$name везёт ваш заказ';
  }

  @override
  String homeHello(String name) {
    return 'Привет, $name!';
  }

  @override
  String get homeSections => 'Разделы';

  @override
  String get homeInventoryValue => 'Стоимость склада';

  @override
  String homeExpectedProfit(String amount) {
    return 'Ожидаемая прибыль: $amount';
  }

  @override
  String get homeCashReceived => 'Наличные';

  @override
  String get homeAllTime => 'За всё время';

  @override
  String get homeOpenPos => 'Открыть кассу';

  @override
  String get commonMonthsShort =>
      'Янв,Фев,Мар,Апр,Май,Июн,Июл,Авг,Сен,Окт,Ноя,Дек';

  @override
  String get posCheckout => 'К оплате';

  @override
  String get posOutOfStock => 'Нет в наличии';

  @override
  String posStockLeft(String stock) {
    return 'Остаток: $stock';
  }

  @override
  String get salesCustomer => 'Клиент';

  @override
  String get commonChange => 'Изменить';

  @override
  String get salesPaymentType => 'Тип оплаты';

  @override
  String get salesNewSale => 'Новая продажа';

  @override
  String get salesCustomerHint => 'Каждая продажа записывается на клиента';

  @override
  String get salesDebtLeft => 'Останется в долг';

  @override
  String productsProfitWith(String amount, String percent) {
    return 'Прибыль: $amount · $percent%';
  }

  @override
  String get productsExpiry => 'Срок годности';

  @override
  String get productsDetails => 'Сведения';

  @override
  String get formBasics => 'Основное';

  @override
  String get formPricing => 'Цена';

  @override
  String get formStockSection => 'Склад';

  @override
  String get formExtra => 'Дополнительно';

  @override
  String get productsSource => 'Источник';

  @override
  String get commonContinue => 'Далее';

  @override
  String get debtsSummaryTotal => 'Общий долг';

  @override
  String debtsPeopleCount(int count) {
    return '$count чел.';
  }

  @override
  String get debtsItemsTitle => 'Список долгов';

  @override
  String get debtsOriginal => 'Исходная сумма';

  @override
  String get commonYes => 'Да';

  @override
  String get commonNo => 'Нет';

  @override
  String get commonPhone => 'Телефон';

  @override
  String get commonAddressRequired => 'Адрес *';

  @override
  String get restNeedDish => 'Добавьте хотя бы одно блюдо';

  @override
  String get restPickTable => 'Выберите стол';

  @override
  String get restAddressMissing => 'Введите адрес доставки';

  @override
  String get restNewOrder => 'Новый заказ';

  @override
  String get restPlaceOrder => 'Оформить заказ';

  @override
  String get restTableRequired => 'Стол *';

  @override
  String get restDeliveryPoint => 'Место доставки';

  @override
  String get restCustomerName => 'Имя клиента';

  @override
  String get restCustomerPhone => 'Телефон клиента';

  @override
  String get restDishes => 'Блюда';

  @override
  String get restNoDishesYet => 'Блюда ещё не добавлены';

  @override
  String get restMenuSearchHint => 'Поиск по меню...';

  @override
  String restDishCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count блюд',
      few: '$count блюда',
      one: '$count блюдо',
    );
    return '$_temp0';
  }

  @override
  String restTableWith(String name) {
    return 'Стол: $name';
  }

  @override
  String get restCreatedBy => 'Создал';

  @override
  String restServiceChargeWith(String percent) {
    return 'Обслуживание ($percent%)';
  }

  @override
  String restWaiterCommissionWith(String percent) {
    return 'Комиссия официанта ($percent%)';
  }

  @override
  String get restNoCourier => 'Курьер не назначен';

  @override
  String restCourierPending(String name) {
    return '$name (ожидает)';
  }

  @override
  String get restAwaitingAccept => 'Ожидает принятия';

  @override
  String get restAssign => 'Назначить';

  @override
  String get restPickCourier => 'Выберите курьера';

  @override
  String get restUnassignedAll => '— Не назначен (всем курьерам) —';

  @override
  String get restTrackingLink => 'Ссылка для отслеживания';

  @override
  String get restRevokeLinks => 'Отменить ссылки отслеживания';

  @override
  String get restRevokeLinksTitle => 'Отменить ссылки отслеживания?';

  @override
  String get restRevokeLinksBody =>
      'Все ссылки, отправленные клиенту, перестанут работать, открытые страницы тоже отключатся. При необходимости можно отправить новую.';

  @override
  String get restRevoke => 'Отменить';

  @override
  String get restNoActiveLinks => 'Активных ссылок не было';

  @override
  String restLinksRevoked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Отменено $count ссылок',
      few: 'Отменены $count ссылки',
      one: 'Отменена $count ссылка',
    );
    return '$_temp0';
  }

  @override
  String restShareTrackText(String order, String url) {
    return 'Отслеживайте заказ $order на карте: $url';
  }

  @override
  String get restShareTrackSubject => 'Отслеживание заказа';

  @override
  String get restCourierNotAccepted => 'Курьер ещё не принял заказ.';

  @override
  String get restActionPreparing => 'Начать готовить';

  @override
  String get restActionReady => 'Отметить готовым';

  @override
  String get restActionServed => 'Отметить поданным';

  @override
  String get restActionDelivered => 'Отметить доставленным';

  @override
  String get restCancelOrder => 'Отменить';

  @override
  String get restAccept => 'Принять';

  @override
  String get restCancelOrderTitle => 'Отмена заказа';

  @override
  String get restCancelOrderConfirm => 'Подтверждаете отмену этого заказа?';

  @override
  String get restNoOpenOrders => 'Нет открытых заказов';

  @override
  String get restMenuEmpty => 'Меню пусто';

  @override
  String get tablesEditTitle => 'Редактировать стол';

  @override
  String get tablesNewTitle => 'Новый стол';

  @override
  String get tablesServiceChargeRequired => 'Обслуживание (%) *';

  @override
  String get tablesPercentMissing => 'Введите процент';

  @override
  String get tablesPercentRange => 'Должно быть от 0 до 100';

  @override
  String get tablesDeleteTitle => 'Удалить стол';

  @override
  String tablesDeleteConfirm(String name) {
    return 'Удалить $name? Если у стола есть открытые заказы, будет ошибка.';
  }

  @override
  String get tablesNotFound => 'Столы не найдены';

  @override
  String tablesServiceCharge(String percent) {
    return 'Обслуживание: $percent%';
  }

  @override
  String get staffStoreBranchRequired => 'Магазин (филиал) *';

  @override
  String get waitersEditTitle => 'Редактировать официанта';

  @override
  String get waitersNewTitle => 'Новый официант';

  @override
  String get waitersDeleteTitle => 'Удалить официанта';

  @override
  String get waitersNotFound => 'Официанты не найдены';

  @override
  String waitersUsage(String used, String limit) {
    return 'Используется официантов: $used / $limit';
  }

  @override
  String get waitersCommissionOptional => 'Комиссия (%) — необязательно';

  @override
  String waitersCommission(String percent) {
    return 'Комиссия: $percent%';
  }

  @override
  String waitersToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Сегодня: $count заказов',
      few: 'Сегодня: $count заказа',
      one: 'Сегодня: $count заказ',
    );
    return '$_temp0';
  }

  @override
  String get couriersEditTitle => 'Редактировать курьера';

  @override
  String get couriersNewTitle => 'Новый курьер';

  @override
  String get couriersDeleteTitle => 'Удалить курьера';

  @override
  String get couriersNotFound => 'Курьеры не найдены';

  @override
  String couriersUsage(String used, String limit) {
    return 'Используется курьеров: $used / $limit';
  }

  @override
  String couriersToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Сегодня: $count доставок',
      few: 'Сегодня: $count доставки',
      one: 'Сегодня: $count доставка',
    );
    return '$_temp0';
  }

  @override
  String enumDeliveryStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'pending': 'Ожидает',
      'assigned': 'Назначена',
      'accepted': 'Принята',
      'pickedUp': 'В пути',
      'arrived': 'На месте',
      'delivered': 'Доставлена',
      'cancelled': 'Отменена',
      'failed': 'Не доставлена',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String enumDeliveryFailReason(String reason) {
    String _temp0 = intl.Intl.selectLogic(reason, {
      'notHome': 'Клиента нет на месте',
      'refused': 'Клиент отказался',
      'wrongAddress': 'Неверный адрес',
      'other': 'Другая причина',
    });
    return '$_temp0';
  }

  @override
  String dlvHeadline(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'pending': 'Ищем курьера',
      'assigned': 'Курьер назначен, ждём подтверждения',
      'accepted': 'Курьер едет в магазин',
      'pickedUp': 'Курьер в пути',
      'arrived': 'Курьер на месте!',
      'delivered': 'Заказ передан',
      'cancelled': 'Доставка отменена',
      'failed': 'Не удалось доставить',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get dlvLabelFallback => 'Доставка';

  @override
  String get dlvConfirmHandoverTitle => 'Заказ передан?';

  @override
  String dlvConfirmHandoverBody(String label) {
    return 'Подтвердите, что $label передан клиенту.';
  }

  @override
  String get dlvYesHandedOver => 'Да, передал';

  @override
  String get dlvCallFailed => 'Не удалось позвонить';

  @override
  String get dlvNavigatorFailed => 'Не удалось открыть навигатор';

  @override
  String dlvCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count доставок',
      few: '$count доставки',
      one: '$count доставка',
    );
    return '$_temp0';
  }

  @override
  String get dlvNone => 'Пока нет доставок';

  @override
  String get dlvActiveSection => 'Активные доставки';

  @override
  String get dlvOffersSection => 'Новые предложения';

  @override
  String get dlvActiveBannerTitle => 'Есть активная доставка';

  @override
  String get dlvActiveBannerCustomer =>
      'Выйдите онлайн, чтобы клиент и владелец бизнеса видели вас на карте.';

  @override
  String get dlvActiveBannerOwner =>
      'Выйдите онлайн, чтобы владелец бизнеса видел вас на карте.';

  @override
  String get dlvNoAddress => 'Адрес не указан';

  @override
  String get dlvCompleted => 'Доставка завершена';

  @override
  String get dlvFailedMarked =>
      'Отмечено: не доставлено. Верните заказ в магазин.';

  @override
  String get mapFitAll => 'Показать всё';

  @override
  String get mapMyLocation => 'Моё местоположение';

  @override
  String get dlvPickup => 'Забрать';

  @override
  String get dlvYouAreOffline => 'Вы офлайн';

  @override
  String get dlvLocationHidden => 'Ваше местоположение не видно';

  @override
  String get dlvFailed => 'Не удалось доставить';

  @override
  String get dlvCancelledTitle => 'Доставка отменена';

  @override
  String get dlvFinishedTitle => 'Доставка завершена';

  @override
  String get dlvGoToStore => 'Езжайте в магазин';

  @override
  String get dlvDeliverToCustomer => 'Доставьте клиенту';

  @override
  String get dlvCodeLockedHint => 'Код заблокирован — позвоните в магазин';

  @override
  String get dlvAskCode => 'При передаче спросите у клиента 4-значный код';

  @override
  String get dlvStoreFallback => 'Магазин';

  @override
  String get dlvNavigator => 'Навигатор';

  @override
  String get dlvHandedOver => 'Передал';

  @override
  String get dlvPickedUp => 'Забрал заказ';

  @override
  String get dlvArrived => 'Я на месте';

  @override
  String dlvMinutesShort(String minutes) {
    return '~$minutes мин';
  }

  @override
  String dlvToStore(String time) {
    return 'До магазина $time';
  }

  @override
  String dlvToCustomer(String time) {
    return 'До клиента $time';
  }

  @override
  String commonKm(String km) {
    return '$km км';
  }

  @override
  String commonMeters(String meters) {
    return '$meters м';
  }

  @override
  String get dlvRestaurantOrder => 'Заказ из ресторана';

  @override
  String dlvMinutesLong(String minutes) {
    return '~$minutes мин';
  }

  @override
  String dlvFailedCustomer(String reason) {
    return '$reason. Магазин свяжется с вами.';
  }

  @override
  String get dlvFailedFallback => 'Не удалось передать';

  @override
  String get dlvCourierUpdating => 'Обновляем местоположение курьера…';

  @override
  String get dlvYourCourier => 'Ваш курьер';

  @override
  String get commonCall => 'Позвонить';

  @override
  String get dlvAssignTitle => 'Передать курьеру';

  @override
  String get dlvOfferAll => 'Предложить всем курьерам';

  @override
  String get dlvOfferAllHint => 'Заказ получит первый принявший курьер';

  @override
  String get dlvNoActiveCouriers => 'Нет активных курьеров';

  @override
  String dlvActiveDeliveries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count активных доставок',
      few: '$count активные доставки',
      one: '$count активная доставка',
    );
    return '$_temp0';
  }

  @override
  String get dlvCodeFourDigits => 'Код состоит из 4 цифр';

  @override
  String get dlvCodeLocked => 'Код заблокирован';

  @override
  String get dlvWaivedTitle => 'Магазин разрешил передачу без кода';

  @override
  String get dlvHandoverCode => 'Код передачи';

  @override
  String get dlvTooManyTries =>
      'Слишком много неверных попыток. Позвоните в магазин — там могут разрешить передачу без кода.';

  @override
  String get dlvConfirmHandedOver => 'Подтвердите, что передали заказ клиенту.';

  @override
  String get dlvAskCodeLong =>
      'Спросите у клиента 4-значный код. Он есть в приложении клиента и в его Telegram.';

  @override
  String dlvAttemptsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Осталось $count попыток',
      few: 'Осталось $count попытки',
      one: 'Осталась $count попытка',
    );
    return '$_temp0';
  }

  @override
  String get dlvRecheck => 'Проверить снова';

  @override
  String get dlvWhyFailed => 'Почему не удалось передать?';

  @override
  String get dlvFailNotice =>
      'Клиент и магазин получат уведомление. Верните заказ в магазин.';

  @override
  String get dlvNoteRequired => 'Комментарий (обязательно)';

  @override
  String get dlvWaiveTitle => 'Разрешить передачу без кода?';

  @override
  String get dlvWaiveBody =>
      'Курьер сможет передать заказ без кода клиента. Разрешайте, только если поговорили с клиентом и уверены, что он получил заказ.';

  @override
  String get dlvWaiveConfirm => 'Разрешить';

  @override
  String get dlvWaived => 'Разрешено — курьер может передать без кода';

  @override
  String dlvReasonWith(String reason) {
    return 'Причина: $reason';
  }

  @override
  String dlvDistanceFromDropoff(String distance) {
    return 'Курьер был в $distance от адреса клиента';
  }

  @override
  String dlvCancelReasonWith(String reason) {
    return 'Причина отмены: $reason';
  }

  @override
  String get dlvCodeLockedStaff =>
      'Код заблокирован: курьер много раз ввёл неверный код';

  @override
  String dlvCodeWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ждём код клиента (осталось $count попыток)',
      few: 'Ждём код клиента (осталось $count попытки)',
      one: 'Ждём код клиента (осталась $count попытка)',
    );
    return '$_temp0';
  }

  @override
  String get dlvWaivedStaff => 'Передача без кода разрешена';

  @override
  String get dlvWaiveButton => 'Разрешить без кода';

  @override
  String get dlvHandoverCodeHint =>
      'Назовите его курьеру при получении заказа. Больше никому не сообщайте.';

  @override
  String dlvCodeSemantics(String digits) {
    return 'Код $digits';
  }

  @override
  String dlvCourierWith(String name) {
    return 'Курьер: $name';
  }

  @override
  String get dlvChangeCourier => 'Сменить курьера';

  @override
  String get dlvCancel => 'Отменить';

  @override
  String get dlvReassign => 'Снова передать курьеру';

  @override
  String get dlvTrackCourier => 'Отследить курьера';

  @override
  String get dlvOfferedAll => 'Предложено всем курьерам';

  @override
  String get dlvAssigned => 'Передано курьеру';

  @override
  String get dlvCancelTitle => 'Отменить доставку?';

  @override
  String get dlvCancelBody =>
      'Курьер больше не увидит этот заказ. Позже можно передать снова.';

  @override
  String get commonRefresh => 'Обновить';

  @override
  String fleetOnline(String count) {
    return '$count онлайн';
  }

  @override
  String fleetBusy(String count) {
    return '$count в доставке';
  }

  @override
  String fleetStale(String count) {
    return '$count без связи';
  }

  @override
  String get fleetNoSignal => 'Нет связи';

  @override
  String get fleetDelivering => 'В доставке';

  @override
  String get fleetFree => 'Свободен';

  @override
  String get fleetNoneOnline => 'Пока нет курьеров онлайн';

  @override
  String fleetLastLocation(String ago) {
    return 'последнее местоположение $ago';
  }

  @override
  String get fleetViewDelivery => 'Открыть доставку';

  @override
  String fleetViewDeliveryN(String n) {
    return 'Открыть доставку ($n)';
  }

  @override
  String get trkOnline => 'Онлайн';

  @override
  String get trkOffline => 'Офлайн';

  @override
  String get trkNotificationTitle => 'bsmart передаёт ваше местоположение';

  @override
  String trkNotifActiveCustomer(String label) {
    return 'Активная доставка: $label — видят клиент и владелец бизнеса';
  }

  @override
  String trkNotifActiveOwner(String label) {
    return 'Активная доставка: $label — видит владелец бизнеса';
  }

  @override
  String get trkNotifOnline =>
      'Онлайн — владелец бизнеса видит ваше местоположение';

  @override
  String get trkShareTitle => 'Передача местоположения';

  @override
  String get trkWatchersNone => 'Никто — местоположение не передаётся';

  @override
  String trkWatchersWithCustomer(String label) {
    return 'Владелец бизнеса, администраторы и клиент ($label)';
  }

  @override
  String get trkWatchersOwner => 'Владелец бизнеса и администраторы';

  @override
  String get trkWhatTitle => 'Что передаётся';

  @override
  String get trkWhatBody =>
      'GPS-местоположение вашего телефона: координаты, скорость и направление движения.';

  @override
  String get trkWhenTitle => 'Когда';

  @override
  String get trkWhenBody =>
      'Только когда вы «Онлайн» или во время активной доставки — даже если приложение в фоне или экран выключен. В это время в панели уведомлений висит постоянное уведомление.';

  @override
  String get trkWhoTitle => 'Кто видит';

  @override
  String get trkWhoBody =>
      'Владелец бизнеса и его администраторы, а также клиент активной доставки.';

  @override
  String get trkStopTitle => 'Как остановить';

  @override
  String get trkStopBody =>
      'В любой момент перейдите в «Офлайн» — передача сразу прекратится. В офлайне ваше местоположение не передаётся.';

  @override
  String get trkDisclosureLead =>
      'bsmart использует ваше местоположение, чтобы отслеживать доставки';

  @override
  String get trkNotNow => 'Не сейчас';

  @override
  String get trkAgree => 'Согласен';

  @override
  String get trkGoOfflineTitle => 'Выйти в офлайн';

  @override
  String get trkGoOfflineBody =>
      'Передача местоположения остановится — владелец бизнеса не увидит вас на карте.';

  @override
  String trkGoOfflineActiveCustomer(String label) {
    return 'У вас активная доставка ($label). Если остановить передачу, клиент и владелец бизнеса перестанут видеть вас на карте.';
  }

  @override
  String trkGoOfflineActiveOwner(String label) {
    return 'У вас активная доставка ($label). Если остановить передачу, владелец бизнеса перестанет видеть вас на карте.';
  }

  @override
  String get trkStop => 'Остановить';

  @override
  String get trkNotSentYet => 'ещё не отправлено';

  @override
  String trkSecondsAgo(String seconds) {
    return '$seconds сек. назад';
  }

  @override
  String trkMinutesAgo(String minutes) {
    return '$minutes мин. назад';
  }

  @override
  String trkWatchersWith(String who) {
    return 'Видят: $who';
  }

  @override
  String get trkGoOnlineHint => 'Выйдите онлайн, чтобы начать работу';

  @override
  String get trkGpsOffBanner => 'На телефоне выключен GPS (геолокация).';

  @override
  String get trkTurnOnGps => 'Включить GPS';

  @override
  String get trkDeniedForever =>
      'Доступ к геолокации запрещён. Разрешите его в настройках.';

  @override
  String get trkOpenSettings => 'Открыть настройки';

  @override
  String get trkPermissionNeeded =>
      'Чтобы выйти онлайн, нужен доступ к геолокации.';

  @override
  String get trkLastSent => 'Последнее отправленное местоположение';

  @override
  String get trkWhoNow => 'Кто видит сейчас';

  @override
  String get trkNoNotifPermission => 'Нет разрешения на уведомления';

  @override
  String get trkNoNotifPermissionBody =>
      'Отслеживание продолжится, но в панели уведомлений его не будет видно.';

  @override
  String get trkBatterySaver => 'Режим энергосбережения';

  @override
  String get trkBatterySaverBody =>
      'Некоторые телефоны останавливают фоновые приложения. Если возникнут проблемы, отключите ограничение батареи для bsmart.';

  @override
  String get trkAboutSharing => 'О передаче местоположения';

  @override
  String get trkSharing => 'Местоположение передаётся';

  @override
  String get trkConnecting => 'Подключение…';

  @override
  String get trkNoGps => 'Нет сигнала GPS';

  @override
  String get trkReconnecting => 'Переподключение…';

  @override
  String get trkDenied => 'Нет разрешения';

  @override
  String get trkGpsOff => 'GPS выключен';

  @override
  String get trkJustNow => 'только что';

  @override
  String get tgRequestNotFound => 'Запрос не найден. Начните заново.';

  @override
  String get tgRequestUsed => 'Этот запрос уже использован. Начните заново.';

  @override
  String get sfUnknownShop => 'Неизвестный магазин';

  @override
  String get favLoginPrompt => 'Войдите, чтобы увидеть избранное';

  @override
  String get favEmpty => 'Список избранного пуст';

  @override
  String get usersNotFound => 'Пользователи не найдены';

  @override
  String get usersSearchHint => 'Имя, фамилия или телефон...';

  @override
  String get usersDeleteTitle => 'Удалить пользователя';

  @override
  String usersDeleteConfirm(String name) {
    return 'Удалить $name навсегда? Это действие нельзя отменить.';
  }

  @override
  String get usersEditTitle => 'Редактировать пользователя';

  @override
  String get usersNewTitle => 'Новый пользователь';

  @override
  String get usersRoleRequired => 'Роль *';

  @override
  String get usersVerticalRequired => 'Направление *';

  @override
  String get usersShopName => 'Название магазина';

  @override
  String get adminVerticalsTitle => 'Розничные продавцы по направлениям';

  @override
  String get adminTotalRevenue => 'Общая выручка';

  @override
  String get adminActiveUsers => 'Активные аккаунты';

  @override
  String get adminTotalDebt => 'Общий долг';

  @override
  String get scannerHint => 'Поместите штрихкод в рамку';

  @override
  String get scannerTorch => 'Фонарик';

  @override
  String get locationDragHint => 'Двигайте карту — метка остаётся в центре';

  @override
  String get categoriesPickerTitle => 'Выберите категорию';

  @override
  String get scannerCameraError =>
      'Не удалось открыть камеру. Проверьте доступ к камере.';

  @override
  String get agentTabHome => 'Главная';

  @override
  String get agentTabSell => 'Продажа';

  @override
  String get agentTabSales => 'Продажи';

  @override
  String get agentTabDebts => 'Должники';

  @override
  String agentHello(String name) {
    return 'Здравствуйте, $name!';
  }

  @override
  String agentLeadOf(String business) {
    return 'Дилер $business';
  }

  @override
  String agentStaffOf(String lead) {
    return 'Агент дилера $lead';
  }

  @override
  String get agentTodaySales => 'Продажи сегодня';

  @override
  String get agentMonthSales => 'Продажи за 30 дней';

  @override
  String get agentMyTodaySales => 'Мои продажи сегодня';

  @override
  String get agentMyMonthSales => 'Мои за 30 дней';

  @override
  String agentSalesCount(int count) {
    return 'Продаж: $count';
  }

  @override
  String get agentCustomersOwe => 'Долги покупателей';

  @override
  String get agentMyDebtsGiven => 'Мои продажи в долг';

  @override
  String agentOpenDebts(int count) {
    return 'Открытых долгов: $count';
  }

  @override
  String get agentOwedToOwner => 'Мой долг владельцу';

  @override
  String get agentStockValue => 'Товар на руках';

  @override
  String get agentProfitTitle => 'Чистая прибыль';

  @override
  String get agentProfitToday => 'Сегодня';

  @override
  String get agentProfit7 => '7 дней';

  @override
  String get agentProfit30 => '30 дней';

  @override
  String get agentProfitRevenue => 'Сумма продаж';

  @override
  String get agentProfitCost => 'Цена для владельца';

  @override
  String get agentProfitPending => 'Прибыль в долгах покупателей';

  @override
  String get agentProfitHint =>
      'Прибыль с продаж в долг добавляется после оплаты';

  @override
  String get agentShortcutProducts => 'Мои товары';

  @override
  String get agentNoStock => 'Товаров пока нет';

  @override
  String get agentNoStockHint =>
      'Они появятся здесь, когда владелец передаст товары.';

  @override
  String agentStockLeft(String qty) {
    return 'Осталось: $qty';
  }

  @override
  String agentPriceRange(String min, String max) {
    return '$min – $max';
  }

  @override
  String get agentOtherCurrency => 'В одной продаже — одна валюта';

  @override
  String agentCartCount(int count) {
    return 'Товаров: $count';
  }

  @override
  String get agentCheckout => 'Оформить';

  @override
  String get agentCheckoutTitle => 'Продажа';

  @override
  String get agentQuantity => 'Количество';

  @override
  String get agentPrice => 'Цена';

  @override
  String agentPriceOutOfRange(String name, String min, String max) {
    return '«$name»: цена должна быть в пределах $min – $max';
  }

  @override
  String agentQtyInvalid(String name) {
    return '«$name»: укажите количество';
  }

  @override
  String agentQtyTooMuch(String name, String qty) {
    return '«$name»: есть только $qty';
  }

  @override
  String get agentCash => 'Наличные';

  @override
  String get agentDebt => 'В долг';

  @override
  String get agentCustomer => 'Покупатель';

  @override
  String get agentCustomerName => 'Имя';

  @override
  String get agentCustomerLastName => 'Фамилия (необязательно)';

  @override
  String get agentCustomerPhone => 'Телефон';

  @override
  String get agentCustomerOptional => 'Данные покупателя необязательны';

  @override
  String get agentReturningDebtorHint =>
      'Если номер уже записан, долг добавится этому покупателю';

  @override
  String get agentDebtNeedsCustomer => 'Для продажи в долг нужны имя и телефон';

  @override
  String get agentPhoneInvalid => 'Неверный номер телефона';

  @override
  String agentSellNow(String total) {
    return 'Продать · $total';
  }

  @override
  String get agentSold => 'Продажа сохранена';

  @override
  String get agentSalesEmpty => 'Продаж пока нет';

  @override
  String agentSaleSeller(String name) {
    return 'Продавец: $name';
  }

  @override
  String agentLineCost(String amount) {
    return 'Себестоимость: $amount';
  }

  @override
  String get agentDebtsOpen => 'Открытые';

  @override
  String get agentDebtsAll => 'Все';

  @override
  String get agentDebtsEmpty => 'Долгов нет';

  @override
  String get agentDebtsTotal => 'Всего долг';

  @override
  String get agentDebtOriginal => 'Сумма долга';

  @override
  String get agentDebtPaid => 'Оплачено';

  @override
  String get agentDebtBalance => 'Остаток';

  @override
  String get agentPayTitle => 'Принять оплату';

  @override
  String get agentPayFull => 'Полностью';

  @override
  String get agentPaySubmit => 'Принять';

  @override
  String get agentPaid => 'Оплата принята';

  @override
  String get agentPayInvalid => 'Введите сумму';

  @override
  String get agentPayTooMuch => 'Сумма не должна превышать остаток';

  @override
  String get agentPaymentsHistory => 'История оплат';

  @override
  String get agentNoPayments => 'Оплат пока нет';

  @override
  String get agentDebtClosed => 'Долг закрыт';

  @override
  String get agentAccountTitle => 'Расчёты';

  @override
  String agentAccountWith(String owner) {
    return 'Расчёты с $owner';
  }

  @override
  String get agentMyDebt => 'Мой долг';

  @override
  String get agentNothingOwed => 'У вас нет долга';

  @override
  String get agentPendingPayments => 'Ожидающие оплаты';

  @override
  String get agentPendingReturns => 'Ожидающие возвраты';

  @override
  String get agentSendPayment => 'Отправить оплату';

  @override
  String get agentSendPaymentHint =>
      'Укажите сумму, переданную владельцу. После подтверждения долг уменьшится.';

  @override
  String get agentPaymentSent => 'Запрос на оплату отправлен';

  @override
  String get agentReturnGoods => 'Вернуть товары';

  @override
  String get agentReturnHint =>
      'Укажите количество. Товары сразу списываются с остатка; после подтверждения долг уменьшится, при отказе товары вернутся.';

  @override
  String agentReturnSend(int count) {
    return 'Вернуть ($count)';
  }

  @override
  String get agentReturnSent => 'Запрос на возврат отправлен';

  @override
  String get agentReturnPickOne => 'Укажите количество хотя бы одного товара';

  @override
  String get agentTabPayments => 'Оплаты';

  @override
  String get agentTabReturns => 'Возвраты';

  @override
  String get agentStatusPending => 'Ожидает';

  @override
  String get agentStatusConfirmed => 'Подтверждено';

  @override
  String get agentStatusRejected => 'Отклонено';

  @override
  String get agentStatusCancelled => 'Отменено';

  @override
  String get agentCancelRequest => 'Отменить';

  @override
  String get agentCancelRequestConfirm => 'Отменить запрос?';

  @override
  String get agentRequestCancelled => 'Запрос отменён';

  @override
  String get agentPaymentsEmpty => 'Запросов на оплату пока нет';

  @override
  String get agentReturnsEmpty => 'Возвратов пока нет';

  @override
  String get agentReturnValue => 'Стоимость';

  @override
  String get agentRefund => 'Возвращено наличными';

  @override
  String agentReturnFromTransfer(String number) {
    return 'Передача $number';
  }

  @override
  String get agentTransfersTitle => 'Поступления';

  @override
  String get agentTransfersEmpty => 'Поступлений пока нет';

  @override
  String agentTransferPaid(String amount) {
    return 'Оплачено: $amount';
  }

  @override
  String agentTransferDebt(String amount) {
    return 'Долг: $amount';
  }

  @override
  String agentTransferLineQty(String given, String left) {
    return 'Передано $given · осталось $left';
  }

  @override
  String agentTransferReturned(String qty) {
    return 'Возвращено $qty';
  }

  @override
  String agentTransferOwed(String price) {
    return 'Цена $price';
  }

  @override
  String agentTransferRange(String range) {
    return 'Продажа: $range';
  }

  @override
  String agentTransferGivenBy(String name) {
    return 'Передал: $name';
  }

  @override
  String get agentStaffTitle => 'Агенты';

  @override
  String get agentStaffEmpty => 'Агентов пока нет';

  @override
  String get agentStaffNew => 'Новый агент';

  @override
  String get agentStaffEdit => 'Редактировать агента';

  @override
  String get agentStaffDeleteTitle => 'Удалить агента';

  @override
  String agentRejectReason(String reason) {
    return 'Причина: $reason';
  }

  @override
  String agentAvailableToSend(String amount) {
    return 'Можно отправить: $amount';
  }

  @override
  String get navLeadAgents => 'Дилеры';

  @override
  String get ownerLeadNew => 'Новый дилер';

  @override
  String get ownerLeadEdit => 'Изменить дилера';

  @override
  String get ownerLeadDeleteTitle => 'Удалить дилера';

  @override
  String get ownerLeadsEmpty => 'Дилеров пока нет';

  @override
  String get ownerLeadStoreHint => 'Дилер получает товары этого магазина';

  @override
  String ownerLeadStaffCount(int count) {
    return 'Агентов: $count';
  }

  @override
  String ownerLeadPendingCount(int count) {
    return 'Запросов: $count';
  }

  @override
  String get ownerLeadOwes => 'Должен мне';

  @override
  String get ownerLeadStock => 'Товары на руках';

  @override
  String get ownerLeadStaff => 'Агенты';

  @override
  String get ownerTeamTitle => 'Продажи команды';

  @override
  String get ownerGiveProducts => 'Передать товары';

  @override
  String get ownerTabStock => 'Товары';

  @override
  String get ownerTabTransfers => 'Передачи';

  @override
  String get ownerTabCustomerDebts => 'Долги покупателей';

  @override
  String get ownerStockEmpty => 'У дилера нет товаров';

  @override
  String get ownerMinPrice => 'Мин. цена';

  @override
  String get ownerMaxPrice => 'Макс. цена';

  @override
  String get ownerEditRange => 'Изменить диапазон цен';

  @override
  String get ownerRangeUpdated => 'Диапазон цен обновлён';

  @override
  String ownerRangeInvalid(String name) {
    return '«$name»: мин. цена не должна быть больше макс.';
  }

  @override
  String ownerPriceInvalid(String name) {
    return '«$name»: введите цену';
  }

  @override
  String get ownerMinBelowPrice => 'Мин. цена ниже цены, которую должен дилер';

  @override
  String get ownerConfirm => 'Подтвердить';

  @override
  String get ownerReject => 'Отклонить';

  @override
  String get ownerConfirmed => 'Подтверждено';

  @override
  String get ownerRejected => 'Отклонено';

  @override
  String get ownerRejectTitle => 'Отклонить запрос';

  @override
  String get ownerRejectReason => 'Причина (необязательно)';

  @override
  String get ownerConfirmPaymentTitle => 'Подтвердить оплату';

  @override
  String ownerConfirmPaymentText(String name, String amount) {
    return 'Подтверждаете, что $name оплатил $amount? Сумма закроет самые старые долги.';
  }

  @override
  String get ownerConfirmReturnTitle => 'Подтвердить возврат';

  @override
  String get ownerConfirmReturnText =>
      'Товары вернутся на ваш склад, а долг дилера уменьшится.';

  @override
  String ownerDebtReduceLine(String amount) {
    return 'Спишется с долга: $amount';
  }

  @override
  String ownerRefundLine(String amount) {
    return 'Вы вернёте наличными: $amount';
  }

  @override
  String get ownerTransferEmpty => 'В этом магазине нет товаров для передачи';

  @override
  String ownerTransferInStock(String qty) {
    return 'На складе: $qty';
  }

  @override
  String ownerTransferHeld(String qty) {
    return 'У дилера: $qty';
  }

  @override
  String get ownerTransferOneCurrency => 'В одной передаче одна валюта';

  @override
  String get ownerTransferPicked => 'Выбрано';

  @override
  String get ownerTransferPaid => 'Оплачено сейчас';

  @override
  String get ownerTransferPaidTooMuch =>
      'Оплата не может превышать общую сумму';

  @override
  String ownerTransferDebtLine(String amount) {
    return 'Запишется в долг: $amount';
  }

  @override
  String ownerTransferSubmit(int count) {
    return 'Передать ($count)';
  }

  @override
  String get ownerTransferDone => 'Товары переданы';

  @override
  String get ownerTransferPickOne => 'Выберите хотя бы один товар';

  @override
  String get commonLoadMore => 'Показать ещё';

  @override
  String get navCrmDrivers => 'Водители';

  @override
  String get navCrmReminders => 'Напоминания';

  @override
  String get crmDriversSearchHint => 'Имя, телефон или госномер';

  @override
  String get crmDriversEmpty => 'Водителей пока нет';

  @override
  String get crmNotEnabled => 'CRM для этого бизнеса не включён';

  @override
  String get crmAddDriver => 'Добавить водителя';

  @override
  String get crmNewDriver => 'Новый водитель';

  @override
  String get crmEditDriver => 'Редактировать водителя';

  @override
  String get crmLastName => 'Фамилия';

  @override
  String get crmPhoneHint =>
      'По этому номеру водитель добавится и в клиенты магазина';

  @override
  String get crmFirstCar => 'Машина (необязательно)';

  @override
  String get crmPlate => 'Госномер';

  @override
  String get crmPlateMissing => 'Введите госномер';

  @override
  String get crmPlateInvalid => 'Неверный госномер';

  @override
  String get crmModel => 'Модель';

  @override
  String get crmModelMissing => 'Введите модель машины';

  @override
  String get crmDailyKm => 'Пробег в день (км)';

  @override
  String get crmDailyKmHint =>
      'Примерно. По нему рассчитывается срок обслуживания';

  @override
  String get crmDailyKmInvalid => 'Введите целое число от 1 до 3000';

  @override
  String get crmActiveHint =>
      'Неактивному водителю напоминания не отправляются';

  @override
  String get crmVehicles => 'Машины';

  @override
  String get crmAddVehicle => 'Добавить машину';

  @override
  String get crmEditVehicle => 'Редактировать машину';

  @override
  String get crmNoVehicles => 'Машин нет';

  @override
  String crmDailyKmValue(String km) {
    return '~$km км в день';
  }

  @override
  String get crmDailyKmMissing => 'Пробег в день не указан';

  @override
  String crmNextDue(String name) {
    return 'Следующее: $name';
  }

  @override
  String get crmRecordService => 'Записать обслуживание';

  @override
  String get crmHistory => 'История обслуживания';

  @override
  String get crmNoVisits => 'Обслуживаний пока нет';

  @override
  String crmLinkedCustomer(String name) {
    return 'В клиентах: $name';
  }

  @override
  String get crmInactiveNoService =>
      'Водитель неактивен: чтобы записать обслуживание, сначала активируйте его';

  @override
  String get crmDeleteDriverTitle => 'Удалить водителя';

  @override
  String crmDeleteDriverConfirm(String name) {
    return '$name и его машины будут удалены. Запись в клиентах и продажи сохранятся.';
  }

  @override
  String get crmDeleteVehicleTitle => 'Удалить машину';

  @override
  String crmDeleteVehicleConfirm(String plate) {
    return 'Машина $plate будет удалена.';
  }

  @override
  String get crmPhotoAdd => 'Добавить фото';

  @override
  String get crmPhotoChange => 'Заменить фото';

  @override
  String get crmPhotoRemove => 'Удалить фото';

  @override
  String get crmDueToday => 'сегодня';

  @override
  String crmDueIn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'осталось $count дня',
      many: 'осталось $count дней',
      few: 'осталось $count дня',
      one: 'остался $count день',
    );
    return '$_temp0';
  }

  @override
  String crmOverdueBy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'просрочено на $count дня',
      many: 'просрочено на $count дней',
      few: 'просрочено на $count дня',
      one: 'просрочено на $count день',
    );
    return '$_temp0';
  }

  @override
  String get crmItemReplaced => 'Заменено при следующем обслуживании';

  @override
  String get crmItemDone => 'Выполнено';

  @override
  String get crmItemCancelled => 'Отменено';

  @override
  String get crmNoReminder => 'Без напоминания';

  @override
  String get crmNoSale => 'Без продажи';

  @override
  String crmSaleDebtLeft(String amount) {
    return 'Долг: $amount';
  }

  @override
  String get crmSaleDebtSettled => 'Долг погашен';

  @override
  String crmKmValue(String km) {
    return '$km км';
  }

  @override
  String crmEveryKm(String km) {
    return 'каждые $km км';
  }

  @override
  String crmAtKm(String km) {
    return 'на $km км';
  }

  @override
  String get crmTgLinked => 'Telegram: напоминания приходят';

  @override
  String get crmTgNotLinked => 'Telegram не подключён';

  @override
  String get crmTgBlocked => 'Водитель заблокировал бота';

  @override
  String get crmTgNoBot =>
      'К магазину не подключён Telegram-бот, водителю напоминания в Telegram не приходят';

  @override
  String get crmTgHowTo =>
      'Водитель должен открыть бота магазина и отправить свой номер';

  @override
  String get crmTgShareLink => 'Отправить ссылку на бота';

  @override
  String get crmVisitTitle => 'Запись обслуживания';

  @override
  String get crmServiceDate => 'Дата обслуживания';

  @override
  String get crmOdometer => 'Пробег по одометру (км)';

  @override
  String get crmParts => 'Установленные запчасти';

  @override
  String get crmAddPart => 'Добавить товар';

  @override
  String get crmAddManual => 'Вручную';

  @override
  String get crmPartSearch => 'Поиск запчасти или масла';

  @override
  String get crmPartsEmpty => 'Добавьте товар или строку вручную';

  @override
  String get crmManualName => 'Название (например: Работа)';

  @override
  String get crmQuantity => 'Количество';

  @override
  String get crmIntervalKm => 'До следующего ТО, км';

  @override
  String get crmNextDate => 'Следующая дата';

  @override
  String crmDueAuto(String date) {
    return 'Вернётся примерно $date';
  }

  @override
  String get crmDueManual => 'Дата указана вручную';

  @override
  String get crmDueNeedsDate => 'Нет пробега в день — укажите дату';

  @override
  String get crmRecordSale => 'Записать как продажу';

  @override
  String get crmRecordSaleOn =>
      'Товар списывается со склада, записывается оплата или долг';

  @override
  String get crmRecordSaleOff =>
      'Только для напоминания: склад и деньги не меняются';

  @override
  String get crmPaidNow => 'Оплачено сейчас (необязательно)';

  @override
  String crmDebtLeft(String amount) {
    return 'Долг: $amount';
  }

  @override
  String get crmSaveVisit => 'Сохранить обслуживание';

  @override
  String get crmVisitSaved => 'Обслуживание записано';

  @override
  String crmInStock(String qty) {
    return 'В наличии: $qty';
  }

  @override
  String get crmPickVehicle => 'Выберите машину';

  @override
  String get crmAddPartFirst => 'Добавьте хотя бы одну строку';

  @override
  String get crmManualNameMissing => 'Введите название строки';

  @override
  String crmPriceMissing(String name) {
    return 'Укажите цену для «$name»';
  }

  @override
  String crmNotEnoughStock(String name) {
    return '«$name» недостаточно на складе';
  }

  @override
  String crmDueAfterService(String name) {
    return 'Следующая дата для «$name» должна быть позже даты обслуживания';
  }

  @override
  String crmDueNeeded(String name) {
    return 'Пробег в день не указан: выберите дату для «$name»';
  }

  @override
  String get crmPaidTooMuch => 'Оплата не может превышать итог';

  @override
  String get crmMixedCurrency =>
      'В одном обслуживании — товары только в одной валюте';

  @override
  String get crmRemindersAll => 'Все';

  @override
  String get crmRemindersOverdue => 'Просрочено';

  @override
  String get crmRemindersSoon => '7 дней';

  @override
  String get crmRemindersEmpty => 'Напоминаний нет';

  @override
  String get crmMarkDone => 'Выполнено';

  @override
  String get crmMoveDate => 'Изменить дату';

  @override
  String get crmCancelReminder => 'Отменить напоминание';

  @override
  String get crmReminderDone => 'Отмечено как выполненное';

  @override
  String get crmReminderCancelled => 'Напоминание отменено';

  @override
  String get crmDateMoved => 'Дата изменена';

  @override
  String get crmDueManualShort => 'Дата указана вручную';

  @override
  String get crmDriverSaved => 'Водитель сохранён';

  @override
  String get crmVehicleSaved => 'Машина сохранена';

  @override
  String get notifTitle => 'Уведомления';

  @override
  String get notifEmpty => 'Уведомлений пока нет';

  @override
  String get notifReadAll => 'Прочитать все';

  @override
  String notifServiceDueStaff(String plate, String driver) {
    return '$plate — пора на обслуживание ($driver)';
  }

  @override
  String get notifDriverNotified => 'Водителю напомнили в Telegram';

  @override
  String notifCallDriver(String phone) {
    return 'Водитель не подключён к боту — позвоните: $phone';
  }

  @override
  String notifServiceDueDriver(String store) {
    return '$store: скоро обслуживание';
  }

  @override
  String get notifUnknown => 'Новое уведомление';
}
