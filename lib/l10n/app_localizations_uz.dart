// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Uzbek (`uz`).
class AppLocalizationsUz extends AppLocalizations {
  AppLocalizationsUz([String locale = 'uz']) : super(locale);

  @override
  String get commonCancel => 'Bekor qilish';

  @override
  String get commonRetry => 'Qayta urinish';

  @override
  String get commonLogout => 'Chiqish';

  @override
  String get commonLogin => 'Kirish';

  @override
  String get commonRegister => 'Ro\'yxatdan o\'tish';

  @override
  String get commonSettings => 'Sozlamalar';

  @override
  String get commonUnknownError => 'Noma\'lum xatolik yuz berdi.';

  @override
  String roleLabel(String role) {
    String _temp0 = intl.Intl.selectLogic(role, {
      'superAdmin': 'Super Admin',
      'seller': 'Optomchi',
      'sellerAdmin': 'Optomchi xodimi',
      'retailer': 'Do\'konchi',
      'retailerAdmin': 'Do\'konchi xodimi',
      'customer': 'Mijoz',
      'waiter': 'Ofitsiant',
      'courier': 'Kuryer',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get languageTitle => 'Til';

  @override
  String get languageHint => 'Interfeys tilini tanlang';

  @override
  String get languageChange => 'Tilni o\'zgartirish';

  @override
  String get settingsTitle => 'Sozlamalar';

  @override
  String get settingsAccount => 'Hisob';

  @override
  String get authPhoneLabel => 'Telefon raqam';

  @override
  String get authPhoneRequired => 'Telefon raqam kiritilishi shart';

  @override
  String get authPhoneFormat => 'Format: +998XXXXXXXXX';

  @override
  String get authTagline => 'Aqlli savdo, yaxlit biznes';

  @override
  String get authEnterNumber => 'Raqamingizni kiriting';

  @override
  String get authSkip => 'Keyinroq';

  @override
  String get authOr => 'yoki';

  @override
  String get authClear => 'Tozalash';

  @override
  String get tgVerifyingNumber => 'Tasdiqlanadigan raqam';

  @override
  String get loginSubtitle => 'Optom Savdo tizimiga kirish';

  @override
  String get loginContinueWithTelegram => 'Telegram orqali davom etish';

  @override
  String get loginAccountAutoCreated =>
      'Hisobingiz bo\'lmasa, avtomatik yaratiladi';

  @override
  String get loginWithPassword => 'Parol bilan kirish';

  @override
  String get loginPasswordLabel => 'Parol';

  @override
  String get loginPasswordRequired => 'Parol kiritilishi shart';

  @override
  String get loginPasswordMinLength => 'Kamida 6 ta belgi';

  @override
  String get registerSubtitle => 'Yangi mijoz hisobi yaratish';

  @override
  String get registerHint =>
      'Raqamingiz Telegram orqali tasdiqlanadi. Ism-familiyangiz Telegram profilingizdan olinadi — keyin profilda o\'zgartirishingiz mumkin.';

  @override
  String get registerWithTelegram => 'Telegram orqali ro\'yxatdan o\'tish';

  @override
  String get registerHaveAccount => 'Hisobingiz bormi? Kirish';

  @override
  String get splashError => 'Ilovani ishga tushirishda xatolik yuz berdi.';

  @override
  String get tgTitle => 'Telegram orqali tasdiqlash';

  @override
  String get tgOpenFailed =>
      'Telegramni ochib bo\'lmadi. Ilova o\'rnatilganini tekshiring.';

  @override
  String get tgPhoneVerified => 'Raqamingiz tasdiqlandi ✅';

  @override
  String get tgWelcomeNew => 'Xush kelibsiz! Hisobingiz yaratildi.';

  @override
  String get tgWelcome => 'Xush kelibsiz!';

  @override
  String get tgChangePhone => 'Raqamni o\'zgartirish';

  @override
  String get tgPreparing => 'Tayyorlanmoqda…';

  @override
  String get tgVerified => 'Tasdiqlandi';

  @override
  String get tgVerifiedLoggingIn => 'Tasdiqlandi, kirilmoqda…';

  @override
  String get tgFinishStepVerify =>
      'Ilovaga qayting — tasdiqlash avtomatik yakunlanadi';

  @override
  String get tgFinishStepLogin =>
      'Ilovaga qayting — kirish avtomatik bajariladi';

  @override
  String get tgMismatchTitle => 'Raqam mos kelmadi';

  @override
  String tgMismatchOwn(String phone) {
    return 'Telegram akkauntingizdagi raqam hisobingizdagi $phone raqamiga mos emas. Shu raqam ulangan Telegram akkauntidan foydalaning.';
  }

  @override
  String tgMismatch(String phone) {
    return 'Telegram akkauntingizdagi raqam $phone raqamiga mos emas. Shu raqam ulangan Telegram akkauntidan foydalaning yoki raqamni o\'zgartiring.';
  }

  @override
  String get tgExpiredTitle => 'Tasdiqlash muddati tugadi';

  @override
  String get tgExpiredMessage =>
      '10 daqiqa ichida raqam tasdiqlanmadi. Qaytadan urinib ko\'ring.';

  @override
  String get tgFailedTitle => 'Tasdiqlab bo\'lmadi';

  @override
  String get tgConfirmInTelegram => 'Telegramda tasdiqlang';

  @override
  String get tgStep1 => 'Telegramda bsmart tasdiqlash boti ochiladi';

  @override
  String get tgStep2 => '«Start» tugmasini bosing';

  @override
  String get tgStep3 => '«📱 Raqamni tasdiqlash» tugmasini bosing';

  @override
  String tgWaiting(String countdown) {
    return 'Tasdiqlash kutilmoqda · $countdown';
  }

  @override
  String get tgOpenTelegram => 'Telegramni ochish';

  @override
  String get verifyBannerAction => 'Raqamni tasdiqlash';

  @override
  String get verifyBannerProfile =>
      'Restoran yetkazishlarini kuzatish va qarzlaringizni ko\'rish uchun telefon raqamingizni Telegram orqali tasdiqlang.';

  @override
  String get verifyBannerDebts =>
      'Do\'konlardagi qarzlaringizni ko\'rish uchun telefon raqamingizni Telegram orqali tasdiqlang.';

  @override
  String get verifyBannerDeliveries =>
      'Restoranga telefon orqali bergan buyurtmalaringizni kuzatish uchun telefon raqamingizni Telegram orqali tasdiqlang.';

  @override
  String get tgNotifTitle => 'Telegram bildirishnomalari';

  @override
  String get tgNotifConnect => 'Ulash';

  @override
  String get tgNotifOff => 'O\'chirilgan';

  @override
  String get tgNotifCustomerEnabled =>
      'Kuryer buyurtmani olganda, yetib kelganda va topshirganda xabar keladi';

  @override
  String get tgNotifCustomerLink =>
      'Buyurtmangiz yo\'lga chiqqanda xabar olish uchun raqamingizni Telegram orqali tasdiqlang';

  @override
  String get tgNotifCourierEnabled =>
      'Sizga yetkazish biriktirilsa, taklif qilinsa yoki bekor qilinsa xabar keladi';

  @override
  String get tgNotifCourierLink =>
      'Yangi yetkazishlar haqida Telegram\'da xabar olish uchun raqamingizni tasdiqlang';

  @override
  String get tgNotifLinkTelegram => 'Telegramni ulash';

  @override
  String get tgNotifEnabled => 'Bildirishnomalar yoqilgan';

  @override
  String get tgNotifDisabled => 'Bildirishnomalar o\'chirilgan';

  @override
  String get navCatalog => 'Katalog';

  @override
  String get navCart => 'Savat';

  @override
  String get navFavorites => 'Sevimlilar';

  @override
  String get navProfile => 'Profil';

  @override
  String get navMenu => 'Menyu';

  @override
  String get navDeliveries => 'Yetkazishlar';

  @override
  String get navPos => 'Kassa';

  @override
  String get navOrders => 'Buyurtmalar';

  @override
  String get navProducts => 'Mahsulotlar';

  @override
  String get navCustomers => 'Mijozlar';

  @override
  String get navSalesHistory => 'Sotuvlar tarixi';

  @override
  String get navDebts => 'Qarzlar';

  @override
  String get navReports => 'Hisobotlar';

  @override
  String get navFleetMap => 'Kuryerlar xaritasi';

  @override
  String get navRestaurantOrders => 'Restoran buyurtmalari';

  @override
  String get navTables => 'Stollar';

  @override
  String get navStores => 'Do\'konlar';

  @override
  String get navStaff => 'Xodimlar';

  @override
  String get navWaiters => 'Ofitsiantlar';

  @override
  String get navCouriers => 'Kuryerlar';

  @override
  String get navExpenditures => 'Harajatlarim';

  @override
  String get navUsers => 'Foydalanuvchilar';

  @override
  String get navCategories => 'Kategoriyalar';

  @override
  String get navCatalogModeration => 'Katalog nazorati';

  @override
  String get profileLoginPrompt => 'Profilni koʻrish uchun tizimga kiring';

  @override
  String get profilePhoneVerified => 'Raqam tasdiqlangan';

  @override
  String get profileMyOrders => 'Buyurtmalarim';

  @override
  String get profileMyDeliveries => 'Yetkazishlarim';

  @override
  String get profileMyDebts => 'Qarzlarim';

  @override
  String homeWelcome(String name) {
    return 'Xush kelibsiz, $name';
  }

  @override
  String get homeStatistics => 'Statistika';

  @override
  String get homeStatsLoadFailed => 'Statistikani yuklab bo\'lmadi';

  @override
  String get homeTodaySales => 'Bugungi savdo';

  @override
  String get homeTotalSales => 'Jami savdo';

  @override
  String homeSalesCount(int count) {
    return '$count ta savdo';
  }

  @override
  String get homeOutstandingDebt => 'Qarzdorlik';

  @override
  String get homeReceivedPayments => 'Qabul qilingan to\'lovlar';

  @override
  String get homeCustomerDebts => 'Mijoz qarzlari';

  @override
  String get homeWholesalerDebts => 'Optomchi qarzlari';

  @override
  String enumOrderStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'newOrder': 'Yangi',
      'approved': 'Tasdiqlangan',
      'rejected': 'Rad etilgan',
      'delivered': 'Yetkazilgan',
      'debtRecorded': 'Qarzga yozilgan',
      'paid': 'To\'langan',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String enumPaymentMethod(String method) {
    String _temp0 = intl.Intl.selectLogic(method, {
      'cash': 'Naqd',
      'card': 'Karta',
      'bankTransfer': 'Bank o\'tkazmasi',
      'click': 'Click',
      'payme': 'Payme',
      'debt': 'Qarzga',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String enumBusinessType(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'general': 'Do\'kon',
      'restaurant': 'Restoran',
      'applianceStore': 'Maishiy texnika',
      'constructionTools': 'Qurilish mollari',
      'toyStore': 'O\'yinchoqlar',
      'autoParts': 'Avto ehtiyot qismlar',
      'pharmacy': 'Dorixona',
      'clothingStore': 'Kiyim-kechak',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String enumExpenditureType(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'electricity': 'Elektr energiyasi',
      'gas': 'Gaz',
      'water': 'Suv',
      'taxes': 'Soliqlar',
      'renting': 'Ijara',
      'other': 'Boshqa',
    });
    return '$_temp0';
  }

  @override
  String enumProductUnit(String unit) {
    String _temp0 = intl.Intl.selectLogic(unit, {
      'dona': 'Dona',
      'metr': 'Metr',
      'litr': 'Litr',
      'kilogram': 'Kilogramm',
      'gram': 'Gramm',
      'blok': 'Blok',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String enumRestaurantOrderType(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'dineIn': 'Zalda',
      'delivery': 'Yetkazib berish',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String enumRestaurantOrderStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'newOrder': 'Yangi',
      'preparing': 'Tayyorlanmoqda',
      'ready': 'Tayyor',
      'served': 'Berildi',
      'delivered': 'Yetkazildi',
      'cancelled': 'Bekor qilindi',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String enumSaleType(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'paid': 'To\'langan',
      'debt': 'Qarzga',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String enumSaleStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'completed': 'Yakunlangan',
      'cancelled': 'Bekor qilingan',
      'partiallyReturned': 'Qisman qaytarilgan',
      'returned': 'Qaytarilgan',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String enumDebtStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'active': 'Faol',
      'partial': 'Qisman to\'langan',
      'settled': 'To\'langan',
      'overdue': 'Muddati o\'tgan',
      'writtenOff': 'Bekor qilingan',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get currencySom => 'so\'m';

  @override
  String get errorSessionExpired => 'Sessiya tugagan, qayta kiring.';

  @override
  String get errorForbidden => 'Bu amalni bajarishga ruxsat yo\'q.';

  @override
  String get errorNotFound => 'Topilmadi.';

  @override
  String get errorConflict => 'Amalni bajarib bo\'lmadi, ziddiyat mavjud.';

  @override
  String get errorNoInternet => 'Internet aloqasi yo\'q.';

  @override
  String get errorInvalidData => 'Ma\'lumotlar noto\'g\'ri kiritildi.';

  @override
  String get tgTooManyAttempts =>
      'Bu raqam uchun urinishlar juda ko\'p. Birozdan so\'ng qayta urinib ko\'ring.';

  @override
  String get tgUnavailable =>
      'Telegram orqali tasdiqlash vaqtincha ishlamayapti. Keyinroq urinib ko\'ring.';

  @override
  String get tgInvalidPhone =>
      'Telefon raqam noto\'g\'ri. Format: +998XXXXXXXXX';

  @override
  String get commonSave => 'Saqlash';

  @override
  String get commonDelete => 'O\'chirish';

  @override
  String get commonAdd => 'Qo\'shish';

  @override
  String get commonEdit => 'Tahrirlash';

  @override
  String get commonActive => 'Faol';

  @override
  String get commonInactive => 'Faol emas';

  @override
  String get commonAll => 'Barchasi';

  @override
  String get commonNone => 'Yo\'q';

  @override
  String get commonNotSelected => 'Tanlanmagan';

  @override
  String get commonNotSelectedDash => '— Tanlanmagan —';

  @override
  String commonErrorWith(String error) {
    return 'Xatolik: $error';
  }

  @override
  String get commonNothingFound => 'Hech narsa topilmadi';

  @override
  String get commonReject => 'Rad etish';

  @override
  String get commonReasonOptional => 'Sababi (ixtiyoriy)';

  @override
  String get commonName => 'Nomi';

  @override
  String get commonNameRequired => 'Nomi *';

  @override
  String get commonNameMissing => 'Nomini kiriting';

  @override
  String get commonDescription => 'Tavsif';

  @override
  String get commonCategory => 'Kategoriya';

  @override
  String get commonBrand => 'Brend';

  @override
  String get commonBarcode => 'Shtrix-kod';

  @override
  String get commonPrice => 'Narx';

  @override
  String get commonPriceRequired => 'Narx *';

  @override
  String get commonCostPrice => 'Tannarx';

  @override
  String get commonStock => 'Zaxira';

  @override
  String get commonUnit => 'O\'lchov birligi';

  @override
  String get commonCurrency => 'Valyuta';

  @override
  String get commonCurrencyRequired => 'Valyuta *';

  @override
  String get currencyUzsLong => 'So\'m (UZS)';

  @override
  String get currencyUsdLong => 'Dollar (USD)';

  @override
  String get commonQuantityRequired => 'Miqdor kiritilishi shart';

  @override
  String get productsTitle => 'Mahsulotlar';

  @override
  String get productsProduct => 'Mahsulot';

  @override
  String get productsSentToCatalog =>
      'Ko\'rib chiqish uchun katalogga yuborildi';

  @override
  String get productsDeleteTitle => 'Mahsulotni o\'chirish';

  @override
  String get productsDeleteConfirm =>
      'Bu mahsulotni o\'chirishni tasdiqlaysizmi?';

  @override
  String productsCostPriceWith(String price) {
    return 'Tannarx: $price';
  }

  @override
  String get productsAddStock => 'Zaxira qo\'shish';

  @override
  String get productsCreateBarcode => 'Barkod yaratish';

  @override
  String get productsShareToCatalog => 'Katalogga ulashish';

  @override
  String get productsNameOrCatalog =>
      'Mahsulot nomini kiriting yoki katalogdan tanlang';

  @override
  String get productsPriceInvalid => 'Narx noto\'g\'ri kiritildi';

  @override
  String get productsEditTitle => 'Mahsulotni tahrirlash';

  @override
  String get productsNewTitle => 'Yangi mahsulot';

  @override
  String get productsPriceRequired => 'Narx kiritilishi shart';

  @override
  String get productsInitialStock => 'Boshlang\'ich zaxira';

  @override
  String productsStockEditHint(String stock) {
    return '$stock — o\'zgartirish uchun mahsulot sahifasidagi \"Zaxira qo\'shish\" tugmasini ishlating';
  }

  @override
  String get productsPluSuggest => 'Taklif';

  @override
  String get productsExpiryOptional => 'Yaroqlilik muddati (ixtiyoriy)';

  @override
  String get productsPickFromCatalog => 'Katalogdan tanlash';

  @override
  String get productsNameRequired => 'Mahsulot nomi *';

  @override
  String get productsFindTitle => 'Mahsulotni topish';

  @override
  String get productsSearchHint => 'Nomi yoki shtrix-kod bo\'yicha qidirish...';

  @override
  String get productsNotFound => 'Mahsulotlar topilmadi';

  @override
  String productsCurrentStock(String stock) {
    return 'Joriy zaxira: $stock';
  }

  @override
  String get productsAddQuantity => 'Qo\'shiladigan miqdor';

  @override
  String get productsCorrectionOptional => 'Qo\'shimcha tuzatish (ixtiyoriy)';

  @override
  String get productsCorrectionHint => 'Manfiy son ham kiritish mumkin';

  @override
  String get commonConfirm => 'Tasdiqlash';

  @override
  String get commonDone => 'Tayyor';

  @override
  String get commonSearchHint => 'Qidirish...';

  @override
  String get commonInactiveShort => 'Faolsiz';

  @override
  String commonDeleteWithDependentsConfirm(String name) {
    return '$name o\'chirilsinmi? Unga bog\'liq mahsulotlar bo\'lsa, xatolik qaytadi.';
  }

  @override
  String get masterStatusPending => 'Kutilmoqda';

  @override
  String get masterStatusApproved => 'Tasdiqlangan';

  @override
  String get masterStatusRejected => 'Rad etilgan';

  @override
  String get masterDeleteTitle => 'Katalog yozuvini o\'chirish';

  @override
  String get masterReviewTitle => 'Katalog nazorati';

  @override
  String get masterEditTitle => 'Katalog yozuvini tahrirlash';

  @override
  String get masterNewTitle => 'Yangi katalog yozuvi';

  @override
  String get masterActiveVisible => 'Faol (katalogda ko\'rinadi)';

  @override
  String get masterSearchHint => 'Katalogdan qidirish...';

  @override
  String get categoriesDeleteTitle => 'Kategoriyani o\'chirish';

  @override
  String get categoriesTitle => 'Kategoriyalar';

  @override
  String get categoriesNotFound => 'Kategoriyalar topilmadi';

  @override
  String get categoriesEditTitle => 'Kategoriyani tahrirlash';

  @override
  String get categoriesNewTitle => 'Yangi kategoriya';

  @override
  String get categoriesParent => 'Ota kategoriya';

  @override
  String get categoriesNoParent => '— Yo\'q (asosiy kategoriya) —';

  @override
  String get categoriesSortOrder => 'Tartib raqami';

  @override
  String get categoriesPickerNotFound => 'Kategoriya topilmadi';

  @override
  String get commonDeactivate => 'Faolsizlantirish';

  @override
  String get commonFirstNameRequired => 'Ism *';

  @override
  String get commonFirstNameMissing => 'Ismni kiriting';

  @override
  String get commonLastNameRequired => 'Familiya *';

  @override
  String get commonLastNameMissing => 'Familiyani kiriting';

  @override
  String get commonPhoneRequired => 'Telefon *';

  @override
  String get commonPhoneMissing => 'Telefon raqamini kiriting';

  @override
  String get commonInvalidFormat => 'Noto\'g\'ri format';

  @override
  String get commonAddress => 'Manzil';

  @override
  String get commonNote => 'Izoh';

  @override
  String get commonTotal => 'Jami';

  @override
  String get commonSubtotal => 'Oraliq summa';

  @override
  String get commonDiscount => 'Chegirma';

  @override
  String commonPieces(String count) {
    return '$count ta';
  }

  @override
  String commonProductCount(int count) {
    return '$count ta mahsulot';
  }

  @override
  String get commonProducts => 'Mahsulotlar';

  @override
  String get commonDeliveryAddress => 'Yetkazib berish manzili';

  @override
  String get customersDeactivateTitle => 'Mijozni faolsizlantirish';

  @override
  String customersDeactivateConfirm(String name) {
    return '$name faolsizlantirilsinmi?';
  }

  @override
  String get customersTitle => 'Mijozlar';

  @override
  String get customersSearchHint => 'Ism yoki telefon bo\'yicha qidirish...';

  @override
  String get customersNotFound => 'Mijozlar topilmadi';

  @override
  String get customersEditTitle => 'Mijozni tahrirlash';

  @override
  String get customersNewTitle => 'Yangi mijoz';

  @override
  String get ordersSingleCurrency =>
      'Bitta buyurtmada faqat bitta valyutadagi mahsulotlar bo\'lishi mumkin';

  @override
  String ordersAddedToCart(String name) {
    return '$name savatga qo\'shildi';
  }

  @override
  String get ordersSearchProduct => 'Mahsulot qidirish...';

  @override
  String get ordersAllBranches => 'Barcha filiallar';

  @override
  String ordersCartSummary(int count, String total) {
    return '$count ta mahsulot — $total';
  }

  @override
  String get ordersPickWholesaler => 'Optomchini tanlang';

  @override
  String get ordersNoWholesalers => 'Optomchilar topilmadi';

  @override
  String get ordersIncomingTitle => 'Kelgan buyurtmalar';

  @override
  String get ordersMineTitle => 'Buyurtmalarim';

  @override
  String get ordersTabOutgoing => 'Chiqarilgan';

  @override
  String get ordersTabIncoming => 'Kelgan';

  @override
  String get ordersNotFound => 'Buyurtmalar topilmadi';

  @override
  String get ordersReviewTitle => 'Buyurtmani ko\'rib chiqish';

  @override
  String get ordersPlace => 'Buyurtma berish';

  @override
  String get ordersApproveTitle => 'Buyurtmani tasdiqlash';

  @override
  String get ordersApproveConfirm =>
      'Bu buyurtmani tasdiqlaysizmi? Mahsulot zaxirasi kamayadi.';

  @override
  String get ordersRejectTitle => 'Buyurtmani rad etish';

  @override
  String get ordersDeliveredTitle => 'Yetkazib berildi deb belgilash';

  @override
  String get ordersDeliveredConfirm =>
      'Bu buyurtma yetkazib berilganini tasdiqlaysizmi?';

  @override
  String get ordersOrder => 'Buyurtma';

  @override
  String ordersRejectionReason(String reason) {
    return 'Rad etilish sababi: $reason';
  }

  @override
  String get ordersSeller => 'Sotuvchi';

  @override
  String get ordersBuyer => 'Xaridor';

  @override
  String get ordersHistory => 'Tarix';

  @override
  String get ordersDelivered => 'Yetkazildi';

  @override
  String get commonUnknownPerson => 'Noma\'lum';

  @override
  String get commonAmount => 'Summa';

  @override
  String get commonPaymentMethod => 'To\'lov usuli';

  @override
  String get commonNoteOptional => 'Izoh (ixtiyoriy)';

  @override
  String get commonClose => 'Yopish';

  @override
  String get commonDateRequired => 'Sana *';

  @override
  String commonTotalWith(String amount) {
    return 'Jami: $amount';
  }

  @override
  String commonBalanceWith(String amount) {
    return 'Qoldiq: $amount';
  }

  @override
  String commonDueWith(String date) {
    return 'Muddat: $date';
  }

  @override
  String get expensesEditTitle => 'Harajatni tahrirlash';

  @override
  String get expensesNewTitle => 'Yangi harajat';

  @override
  String get expensesTypeRequired => 'Turi *';

  @override
  String get expensesAmountRequired => 'Summasi (so\'m) *';

  @override
  String get expensesAmountMissing => 'Summani kiriting';

  @override
  String get expensesAmountInvalid => 'Noto\'g\'ri summa';

  @override
  String get expensesDeleteTitle => 'Harajatni o\'chirish';

  @override
  String expensesDeleteConfirm(String expense) {
    return '$expense butunlay o\'chirilsinmi?';
  }

  @override
  String get expensesTitle => 'Harajatlarim';

  @override
  String get expensesFilterByType => 'Turi bo\'yicha filtr';

  @override
  String get expensesTotal => 'Jami xarajat';

  @override
  String get expensesNotFound => 'Harajatlar topilmadi';

  @override
  String debtsPaymentsApplied(int count) {
    return '$count ta qarzga to\'lov qo\'llanildi';
  }

  @override
  String get debtsCloseTitle => 'Qarzni yopish';

  @override
  String debtsCloseConfirm(String amount) {
    return 'Qolgan $amount to\'liq to\'langan deb belgilansinmi?';
  }

  @override
  String debtsTotalBalance(String amount) {
    return 'Jami qoldiq: $amount';
  }

  @override
  String get debtsPayDownTitle => 'Umumiy to\'lov (FIFO)';

  @override
  String get debtsPayDownHint =>
      'Eng eski qarzdan boshlab avtomatik taqsimlanadi';

  @override
  String get debtsAllocation => 'Taqsimlanishi:';

  @override
  String get debtsWillClose => 'yopiladi';

  @override
  String get debtsExceedsTotal => 'Summa jami qoldiqdan oshib ketmoqda';

  @override
  String get debtsConfirmPayment => 'To\'lovni tasdiqlash';

  @override
  String get debtsTitle => 'Qarzlar';

  @override
  String get debtsPayment => 'To\'lov';

  @override
  String get debtsTabCustomers => 'Mijozlar';

  @override
  String get debtsTabOwedToMe => 'Menga';

  @override
  String get debtsTabMine => 'Mening qarzim';

  @override
  String get debtsNotFound => 'Qarzlar topilmadi';

  @override
  String get debtsCustomerNotFound => 'Mijoz qarzlari topilmadi';

  @override
  String debtsActiveCount(int count) {
    return '$count ta faol qarz';
  }

  @override
  String get debtsEnterValidAmount => 'To\'g\'ri summa kiriting';

  @override
  String debtsAmountExceedsBalance(String balance) {
    return 'Summa qoldiqdan ($balance) oshmasligi kerak';
  }

  @override
  String get debtsMakePayment => 'To\'lov qilish';

  @override
  String get commonActivate => 'Faollashtirish';

  @override
  String commonDeletePermanentlyConfirm(String name) {
    return '$name butunlay o\'chirilsinmi?';
  }

  @override
  String get commonPasswordRequired => 'Parol *';

  @override
  String get staffDeleteTitle => 'Xodimni o\'chirish';

  @override
  String get staffTitle => 'Xodimlar';

  @override
  String get staffNotFound => 'Xodimlar topilmadi';

  @override
  String get staffStoreRequired => 'Do\'kon tanlanishi shart';

  @override
  String get staffEditTitle => 'Xodimni tahrirlash';

  @override
  String get staffNewTitle => 'Yangi xodim';

  @override
  String get staffStoreLabel => 'Do\'kon *';

  @override
  String get storesDeleteTitle => 'Do\'konni o\'chirish';

  @override
  String get storesTitle => 'Do\'konlar';

  @override
  String get storesDefault => 'Asosiy';

  @override
  String get storesEditTitle => 'Do\'konni tahrirlash';

  @override
  String get storesNewTitle => 'Yangi do\'kon';

  @override
  String get storesMapLocation => 'Xaritadagi joyi';

  @override
  String get storesLocationTitle => 'Do\'kon joylashuvi';

  @override
  String get storesLocationHint => 'Kuryerlar buyurtmani shu yerdan oladi';

  @override
  String get storesHandoverCode => 'Topshirish kodi';

  @override
  String get storesHandoverCodeHint =>
      'Kuryer buyurtmani topshirishda mijozdan 4 xonali kodni so\'raydi. Ilovasi yoki tasdiqlangan raqami bo\'lmagan mijozdan kod so\'ralmaydi.';

  @override
  String get commonBalance => 'Qoldiq';

  @override
  String get commonPaid => 'To\'langan';

  @override
  String get commonOnCredit => 'Qarzga';

  @override
  String get commonPickCustomer => 'Mijozni tanlang';

  @override
  String get commonNew => 'Yangi';

  @override
  String get posScanProduct => 'Mahsulotni skanerlash';

  @override
  String get posBarcodeNotFound => 'Bu shtrix-kod bo\'yicha mahsulot topilmadi';

  @override
  String get posSingleCurrency =>
      'Bitta sotuvda faqat bitta valyutadagi mahsulotlar bo\'lishi mumkin';

  @override
  String get posTitle => 'Kassa';

  @override
  String get posSavedCarts => 'Saqlangan savatlar';

  @override
  String posPriceAndStock(String price, String stock) {
    return '$price · Qoldiq: $stock';
  }

  @override
  String get salesPickReturnItem => 'Qaytariladigan mahsulotni tanlang';

  @override
  String get salesReturn => 'Qaytarish';

  @override
  String salesReturnableLeft(String count) {
    return 'Qoldi: $count';
  }

  @override
  String get salesRefundMethod => 'Pulni qaytarish usuli';

  @override
  String salesReturnAmount(String amount) {
    return 'Qaytariladigan summa: $amount';
  }

  @override
  String get salesConfirmReturn => 'Qaytarishni tasdiqlash';

  @override
  String get salesPayment => 'To\'lov';

  @override
  String get salesPaidNow => 'To\'landi';

  @override
  String get salesDownPaymentOptional => 'Oldindan to\'lov (ixtiyoriy)';

  @override
  String salesConfirmWithTotal(String total) {
    return 'Tasdiqlash — $total';
  }

  @override
  String get salesHistoryTitle => 'Sotuvlar tarixi';

  @override
  String get salesNotFound => 'Sotuvlar topilmadi';

  @override
  String get salesSale => 'Sotuv';

  @override
  String get salesCreated => 'Sotuv yaratildi';

  @override
  String salesReturnedQty(String count) {
    return 'qaytarilgan: $count';
  }

  @override
  String get salesDebt => 'Qarz';

  @override
  String get salesPayments => 'To\'lovlar';

  @override
  String get salesCustomerSearchHint => 'Ism yoki telefon...';

  @override
  String get salesCustomerNotFound => 'Mijoz topilmadi';

  @override
  String get cartsSaved => 'Savat saqlandi';

  @override
  String get cartsSaveOrClearFirst =>
      'Avval joriy savatni saqlang yoki tozalang';

  @override
  String cartsSkipped(int count) {
    return '$count ta mahsulot topilmadi, savatga qo\'shilmadi';
  }

  @override
  String get cartsDeleteTitle => 'Saqlangan savatni o\'chirish';

  @override
  String get cartsDeleteConfirm =>
      'Bu amalni ortga qaytarib bo\'lmaydi. Davom etasizmi?';

  @override
  String get cartsCurrentEmpty => 'Joriy savat bo\'sh';

  @override
  String cartsSaveCurrent(int count) {
    return 'Joriy savatni saqlash ($count ta)';
  }

  @override
  String get cartsNone => 'Saqlangan savatlar yo\'q';

  @override
  String cartsMore(int count) {
    return '+$count ta';
  }

  @override
  String get cartsRestore => 'Qaytarib olish';

  @override
  String get commonNoData => 'Ma\'lumot yo\'q';

  @override
  String get reportsTitle => 'Hisobotlar';

  @override
  String get reportsTopProducts => 'Eng ko\'p sotilgan mahsulotlar';

  @override
  String reportsStockWith(String stock) {
    return 'Zaxira: $stock';
  }

  @override
  String get reportsStatistics => 'Statistika';

  @override
  String get reportsRevenue => 'Tushum';

  @override
  String get reportsNewDebts => 'Yangi qarzlar';

  @override
  String get reportsDebtPayments => 'Qarz to\'lovlari';

  @override
  String get reportsOutstanding => 'Qoldiq qarzdorlik';

  @override
  String get reportsSalesChart => 'Savdo grafigi';

  @override
  String get reportsLast30 => 'So\'nggi 30 kun';

  @override
  String get reportsThisMonth => 'Bu oy';

  @override
  String get workDayDebtsShareText => 'Qarzlar ro\'yxati';

  @override
  String get workDayTitle => 'Ish kuni';

  @override
  String get workDayOpen => 'Ochiq';

  @override
  String get workDayClosed => 'Yopilgan';

  @override
  String get workDayNotStarted => 'Hali ish kuni boshlanmagan';

  @override
  String workDayStartedAt(String time) {
    return 'Boshlangan: $time';
  }

  @override
  String workDayEndedAt(String time) {
    return 'Tugagan: $time';
  }

  @override
  String get workDayStart => 'Ish kunini boshlash';

  @override
  String get workDayEnd => 'Ish kunini yakunlash';

  @override
  String get workDayExportDebts => 'Qarzlar (Excel)';

  @override
  String get dashPaymentCash => 'Naqd';

  @override
  String get dashPaymentCard => 'Karta';

  @override
  String get dashPaymentBank => 'Bank';

  @override
  String get dashPaymentDebt => 'Qarz';

  @override
  String get dashPaymentTypes => 'To\'lov turlari';

  @override
  String get dashIncomeDebt6m => 'Daromad va qarz (6 oy)';

  @override
  String get dashIncome => 'Daromad';

  @override
  String get dashSalesTrend14d => 'Savdo dinamikasi (14 kun)';

  @override
  String get scannerTitle => 'Shtrix-kodni skanerlang';

  @override
  String get locationMarkOnMap => 'Xaritada belgilash';

  @override
  String get locationPickTitle => 'Joyni belgilang';

  @override
  String get locationMarked => 'Xaritada belgilangan';

  @override
  String get locationCourierHint => 'Kuryer aniq joyni topishi uchun';

  @override
  String get locationRemove => 'Olib tashlash';

  @override
  String get locationDetectFailed =>
      'Joylashuvni aniqlab bo\'lmadi — GPS va ruxsatni tekshiring';

  @override
  String get locationMyLocation => 'Mening joylashuvim';

  @override
  String get locationChooseHere => 'Shu joyni tanlash';

  @override
  String sfGreeting(String name) {
    return 'Salom, $name!';
  }

  @override
  String get sfGreetingGuest => 'Xush kelibsiz!';

  @override
  String get sfGreetingSubtitle => 'Bugun nima xarid qilamiz?';

  @override
  String get sfAllCategories => 'Barchasi';

  @override
  String sfSearchHint(String term) {
    return '«$term» ni qidiring';
  }

  @override
  String get sfSearchHintDefault => 'Mahsulot qidirish';

  @override
  String get sfShops => 'Do\'konlar';

  @override
  String get sfNewArrivals => 'Yangi kelganlar';

  @override
  String get sfFavoritesLogin =>
      'Sevimli mahsulotlaringizni ko\'rish uchun hisobingizga kiring';

  @override
  String get sfFavoritesEmpty =>
      'Hali sevimli mahsulot yo\'q. Yoqqan mahsulotdagi ♡ ni bosing.';

  @override
  String get sfProductsSubtitle => 'Siz uchun saralangan mahsulotlar';

  @override
  String sfInStock(String quantity) {
    return 'Qoldi: $quantity';
  }

  @override
  String get sfOutOfStock => 'Tugagan';

  @override
  String get sfAdd => 'QO\'SHISH';

  @override
  String sfAddedToCart(String name) {
    return '$name savatga qo\'shildi';
  }

  @override
  String get sfCartOtherShop =>
      'Savatda faqat bitta do\'kondan mahsulot bo\'lishi mumkin';

  @override
  String get sfNoProducts => 'Mahsulotlar topilmadi';

  @override
  String get sfRemoveFilter => 'Filtrni olib tashlash';

  @override
  String get sfSearchTitle => 'Mahsulot va do\'konlarni qidiring';

  @override
  String get sfSearchFieldHint => 'Qidiring, tanlang, buyurtma bering!';

  @override
  String get sfRecentSearches => 'So\'nggi qidiruvlar';

  @override
  String get sfClearRecent => 'Tarixni tozalash';

  @override
  String get sfBrowseCategories => 'Kategoriyalar';

  @override
  String get sfSuggestionProduct => 'Mahsulot';

  @override
  String sfShopsFor(String query) {
    return '«$query» bo\'yicha do\'konlar';
  }

  @override
  String get sfMoreResults => 'Boshqa mos natijalar';

  @override
  String get sfSearching => 'Siz uchun eng mosini qidiryapmiz…';

  @override
  String sfResultsIn(String category) {
    return 'Natijalar: $category';
  }

  @override
  String get sfSort => 'Saralash';

  @override
  String get sfSortRelevance => 'Tavsiya etilgan';

  @override
  String get sfSortPriceLow => 'Avval arzonlari';

  @override
  String get sfSortPriceHigh => 'Avval qimmatlari';

  @override
  String get sfSortName => 'Nomi bo\'yicha (A–Z)';

  @override
  String get sfInStockOnly => 'Mavjud';

  @override
  String sfShopMatches(int count) {
    return '$count ta mos mahsulot';
  }

  @override
  String sfNoResults(String query) {
    return '«$query» bo\'yicha hech narsa topilmadi';
  }

  @override
  String get sfNoResultsHint =>
      'Boshqa so\'z bilan qidiring yoki filtrlarni olib tashlang';

  @override
  String get sfFeaturedShops => 'Mos do\'konlar';

  @override
  String get sfChooseCategory => 'Qaysi bo\'limda qidiramiz?';

  @override
  String get sfShopProducts => 'Do\'kon mahsulotlari';

  @override
  String get sfProductsShort => 'mahsulot';

  @override
  String get sfChooseBranch => 'Filialni tanlang';

  @override
  String get sfCurrentBranch => 'Joriy filial';

  @override
  String get sfOtherBranches => 'Boshqa filiallar';

  @override
  String sfBranchesCount(int count) {
    return '$count ta filial · boshqasini tanlash';
  }

  @override
  String get sfCallShop => 'Qo\'ng\'iroq qilish';

  @override
  String get sfCallFailed => 'Qo\'ng\'iroq qilib bo\'lmadi';

  @override
  String get sfShopOwner => 'Do\'kon egasi';

  @override
  String sfSearchInShop(String shop) {
    return '«$shop» dan qidiring';
  }

  @override
  String get sfMenu => 'MENYU';

  @override
  String get sfOtherCategory => 'Boshqa';

  @override
  String get sfCartHasOtherShop =>
      'Savatingizda boshqa do\'kon mahsulotlari bor. Bu do\'kondan qo\'shish uchun avval savatni bo\'shating.';

  @override
  String get sfShopEmpty => 'Bu do\'konda hozircha mahsulot yo\'q';

  @override
  String get sfDescription => 'Tavsif';

  @override
  String get sfReadMore => 'batafsil';

  @override
  String get sfReadLess => 'yig\'ish';

  @override
  String get sfMoreFromShop => 'Shu do\'kondan yana';

  @override
  String get sfOpenShop => 'Do\'konga o\'tish';

  @override
  String get sfExploreShop => 'Rasmlar bilan ko\'rish';

  @override
  String sfUnitLabel(String unit) {
    return 'O\'lchov: $unit';
  }

  @override
  String sfInCart(String quantity) {
    return 'Savatda: $quantity';
  }

  @override
  String get cartEmptyTitle => 'Savatingiz bo\'sh';

  @override
  String get cartEmptyHint =>
      'Do\'konlardan yoqqan mahsulotlarni qo\'shing — ular shu yerda paydo bo\'ladi.';

  @override
  String get cartStartShopping => 'Xarid qilish';

  @override
  String get cartAddMore => 'Yana qo\'shish';

  @override
  String get cartRemove => 'O\'chirish';

  @override
  String get cartClear => 'Savatni tozalash';

  @override
  String get cartClearConfirm => 'Savatdagi barcha mahsulotlar o\'chiriladi.';

  @override
  String get cartBillTitle => 'To\'lov tafsilotlari';

  @override
  String get cartItemsTotal => 'Mahsulotlar';

  @override
  String get cartDelivery => 'Yetkazib berish';

  @override
  String get cartDeliveryAgreed => 'Do\'kon bilan kelishiladi';

  @override
  String get cartToPay => 'Jami';

  @override
  String get cartNoteLabel => 'ESLATMA:';

  @override
  String get cartNote =>
      'Buyurtmani do\'kon tasdiqlaydi. To\'lov va yetkazib berish shartlarini do\'kon siz bilan kelishadi.';

  @override
  String get cartCheckout => 'Rasmiylashtirish';

  @override
  String cartUnitPrice(String price, String unit) {
    return '$price / $unit';
  }

  @override
  String enumProductUnitShort(String unit) {
    String _temp0 = intl.Intl.selectLogic(unit, {
      'dona': 'dona',
      'metr': 'm',
      'litr': 'l',
      'kilogram': 'kg',
      'gram': 'g',
      'blok': 'blok',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get coTitle => 'Rasmiylashtirish';

  @override
  String get coDeliverTo => 'Yetkazish manzili';

  @override
  String get coPickup => 'O\'zim olib ketaman';

  @override
  String get coPickupHint => 'Buyurtmani do\'kondan olib ketasiz';

  @override
  String get coWhereToDeliver => 'Buyurtmani qayerga yetkazamiz?';

  @override
  String get coAddAddress => 'Manzil qo\'shish';

  @override
  String get coSelectAddress => 'Manzilni tanlash';

  @override
  String get coNoDelivery => 'Manzilsiz — o\'zim olib ketaman';

  @override
  String get coItems => 'Buyurtma tarkibi';

  @override
  String get coNoteHint => 'Do\'kon uchun izoh (ixtiyoriy)';

  @override
  String get coPayment => 'To\'lov';

  @override
  String get coPaymentValue => 'Do\'konga: naqd yoki karta';

  @override
  String coSlideToOrder(String total) {
    return 'Surib buyurtma bering | $total';
  }

  @override
  String get coPlacing => 'Biroz kuting!';

  @override
  String get coPlacedTitle => 'Buyurtma qabul qilindi!';

  @override
  String coPlacedBody(String shop) {
    return '«$shop» buyurtmangizni ko\'rib chiqadi va siz bilan bog\'lanadi.';
  }

  @override
  String get coTrackOrder => 'Buyurtmani ko\'rish';

  @override
  String get coContinueShopping => 'Xaridni davom ettirish';

  @override
  String get addrSelectTitle => 'Manzilni tanlang';

  @override
  String get addrSearchHint => 'Saqlangan manzillardan qidiring';

  @override
  String get addrUseCurrent => 'Joriy joylashuvimdan foydalanish';

  @override
  String get addrPickOnMap => 'Xaritada belgilash';

  @override
  String get addrRecent => 'So\'nggi manzillar';

  @override
  String get addrNoneSaved => 'Hali saqlangan manzil yo\'q';

  @override
  String get addrDeliveredHere => 'Buyurtma shu yerga yetkaziladi';

  @override
  String get addrFieldLabel => 'Manzil (ko\'cha, uy, xonadon, mo\'ljal)';

  @override
  String get addrConfirm => 'Tasdiqlash va davom etish';

  @override
  String get addrDetecting => 'Manzil aniqlanmoqda…';

  @override
  String get addrRemove => 'Manzilni o\'chirish';

  @override
  String otTitle(String number) {
    return 'Buyurtma #$number';
  }

  @override
  String otSubtitle(String time, int count) {
    return '$time · $count ta mahsulot';
  }

  @override
  String get otNewTitle => 'Buyurtma qabul qilindi!';

  @override
  String get otNewHint => 'Do\'kon buyurtmani tasdiqlashini kutmoqdamiz';

  @override
  String get otApprovedTitle => 'Buyurtma tayyorlanmoqda!';

  @override
  String get otApprovedHint => 'Do\'kon tasdiqladi va buyurtmani yig\'moqda';

  @override
  String get otCourierSearching => 'Kuryer qidirilmoqda';

  @override
  String get otCourierAssigned => 'Kuryer tayinlandi';

  @override
  String get otCourierToShop => 'Kuryer do\'konga bormoqda';

  @override
  String get otOnTheWay => 'Buyurtma yo\'lda!';

  @override
  String get otArrived => 'Kuryer yetib keldi!';

  @override
  String get otDeliveredTitle => 'Buyurtma topshirildi';

  @override
  String get otDeliveredHint => 'Xaridingiz uchun rahmat!';

  @override
  String get otRejectedTitle => 'Buyurtma rad etildi';

  @override
  String get otDeliveryCancelled => 'Yetkazish bekor qilindi';

  @override
  String get otDeliveryFailed => 'Yetkazib bo\'lmadi';

  @override
  String get otPickupAt => 'Do\'kondan olib ketasiz';

  @override
  String get otStepPlaced => 'Qabul';

  @override
  String get otStepApproved => 'Tasdiq';

  @override
  String get otStepOnTheWay => 'Yo\'lda';

  @override
  String get otStepDelivered => 'Topshirildi';

  @override
  String get otMins => 'daq';

  @override
  String get otViewItems => 'Mahsulotlar ro\'yxati';

  @override
  String get otTrackCourier => 'Kuryerni xaritada kuzatish';

  @override
  String get otCallShop => 'Do\'konga qo\'ng\'iroq';

  @override
  String get otYourCourier => 'Sizning kuryeringiz';

  @override
  String get otRefresh => 'Yangilash';

  @override
  String get otShowAll => 'Hammasini ko\'rsatish';

  @override
  String get otCourierUpdating => 'Kuryer joylashuvi yangilanmoqda…';

  @override
  String otCourierBringing(String name) {
    return '$name buyurtmangizni olib kelmoqda';
  }

  @override
  String homeHello(String name) {
    return 'Salom, $name!';
  }

  @override
  String get homeSections => 'Bo\'limlar';

  @override
  String get homeInventoryValue => 'Ombor qiymati';

  @override
  String homeExpectedProfit(String amount) {
    return 'Kutilgan foyda: $amount';
  }

  @override
  String get homeCashReceived => 'Naqd tushum';

  @override
  String get homeAllTime => 'Barcha vaqt';

  @override
  String get homeOpenPos => 'Kassani ochish';

  @override
  String get commonMonthsShort =>
      'Yan,Fev,Mar,Apr,May,Iyn,Iyl,Avg,Sen,Okt,Noy,Dek';

  @override
  String get posCheckout => 'To\'lovga o\'tish';

  @override
  String get posOutOfStock => 'Tugagan';

  @override
  String posStockLeft(String stock) {
    return 'Qoldi: $stock';
  }

  @override
  String get salesCustomer => 'Mijoz';

  @override
  String get commonChange => 'O\'zgartirish';

  @override
  String get salesPaymentType => 'To\'lov turi';

  @override
  String get salesNewSale => 'Yangi sotuv';

  @override
  String get salesCustomerHint => 'Har bir sotuv mijoz nomiga yoziladi';

  @override
  String get salesDebtLeft => 'Qarzga qoladi';

  @override
  String productsProfitWith(String amount, String percent) {
    return 'Foyda: $amount · $percent%';
  }

  @override
  String get productsExpiry => 'Yaroqlilik muddati';

  @override
  String get productsDetails => 'Ma\'lumotlar';

  @override
  String get formBasics => 'Asosiy ma\'lumotlar';

  @override
  String get formPricing => 'Narx';

  @override
  String get formStockSection => 'Ombor';

  @override
  String get formExtra => 'Qo\'shimcha';

  @override
  String get productsSource => 'Manba';

  @override
  String get commonContinue => 'Davom etish';

  @override
  String get debtsSummaryTotal => 'Jami qarz';

  @override
  String debtsPeopleCount(int count) {
    return '$count kishi';
  }

  @override
  String get debtsItemsTitle => 'Qarzlar ro\'yxati';

  @override
  String get debtsOriginal => 'Dastlabki summa';
}
