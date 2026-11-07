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
      'leadAgent': 'Diller',
      'agent': 'Agent',
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

  @override
  String get commonYes => 'Ha';

  @override
  String get commonNo => 'Yo\'q';

  @override
  String get commonPhone => 'Telefon';

  @override
  String get commonAddressRequired => 'Manzil *';

  @override
  String get restNeedDish => 'Kamida bitta taom qo\'shing';

  @override
  String get restPickTable => 'Stolni tanlang';

  @override
  String get restAddressMissing => 'Yetkazib berish manzilini kiriting';

  @override
  String get restNewOrder => 'Yangi buyurtma';

  @override
  String get restPlaceOrder => 'Buyurtma berish';

  @override
  String get restTableRequired => 'Stol *';

  @override
  String get restDeliveryPoint => 'Yetkazib berish joyi';

  @override
  String get restCustomerName => 'Mijoz ismi';

  @override
  String get restCustomerPhone => 'Mijoz telefoni';

  @override
  String get restDishes => 'Taomlar';

  @override
  String get restNoDishesYet => 'Hali taom qo\'shilmagan';

  @override
  String get restMenuSearchHint => 'Menyudan qidirish...';

  @override
  String restDishCount(int count) {
    return '$count ta taom';
  }

  @override
  String restTableWith(String name) {
    return 'Stol: $name';
  }

  @override
  String get restCreatedBy => 'Yaratdi';

  @override
  String restServiceChargeWith(String percent) {
    return 'Xizmat haqi ($percent%)';
  }

  @override
  String restWaiterCommissionWith(String percent) {
    return 'Ofitsiant xizmat haqi ($percent%)';
  }

  @override
  String get restNoCourier => 'Kuryer tayinlanmagan';

  @override
  String restCourierPending(String name) {
    return '$name (kutilmoqda)';
  }

  @override
  String get restAwaitingAccept => 'Qabul qilinishi kutilmoqda';

  @override
  String get restAssign => 'Tayinlash';

  @override
  String get restPickCourier => 'Kuryerni tanlang';

  @override
  String get restUnassignedAll => '— Tayinlanmagan (barcha kuryerlarga) —';

  @override
  String get restTrackingLink => 'Kuzatish havolasi';

  @override
  String get restRevokeLinks => 'Kuzatish havolalarini bekor qilish';

  @override
  String get restRevokeLinksTitle => 'Kuzatish havolalarini bekor qilish?';

  @override
  String get restRevokeLinksBody =>
      'Mijozga yuborilgan barcha havolalar ishlamay qoladi, ochiq sahifalar ham uziladi. Kerak bo\'lsa yangisini yuborishingiz mumkin.';

  @override
  String get restRevoke => 'Bekor qilish';

  @override
  String get restNoActiveLinks => 'Faol havola yo\'q edi';

  @override
  String restLinksRevoked(int count) {
    return '$count ta havola bekor qilindi';
  }

  @override
  String restShareTrackText(String order, String url) {
    return '$order buyurtmangizni xaritada kuzating: $url';
  }

  @override
  String get restShareTrackSubject => 'Buyurtmani kuzatish';

  @override
  String get restCourierNotAccepted => 'Kuryer buyurtmani hali qabul qilmagan.';

  @override
  String get restActionPreparing => 'Tayyorlashni boshlash';

  @override
  String get restActionReady => 'Tayyor deb belgilash';

  @override
  String get restActionServed => 'Berildi deb belgilash';

  @override
  String get restActionDelivered => 'Yetkazildi deb belgilash';

  @override
  String get restCancelOrder => 'Bekor qilish';

  @override
  String get restAccept => 'Qabul qilish';

  @override
  String get restCancelOrderTitle => 'Buyurtmani bekor qilish';

  @override
  String get restCancelOrderConfirm =>
      'Bu buyurtmani bekor qilishni tasdiqlaysizmi?';

  @override
  String get restNoOpenOrders => 'Ochiq buyurtmalar yo\'q';

  @override
  String get restMenuEmpty => 'Menyu bo\'sh';

  @override
  String get tablesEditTitle => 'Stolni tahrirlash';

  @override
  String get tablesNewTitle => 'Yangi stol';

  @override
  String get tablesServiceChargeRequired => 'Xizmat haqi (%) *';

  @override
  String get tablesPercentMissing => 'Foizni kiriting';

  @override
  String get tablesPercentRange => '0 dan 100 gacha bo\'lishi kerak';

  @override
  String get tablesDeleteTitle => 'Stolni o\'chirish';

  @override
  String tablesDeleteConfirm(String name) {
    return '$name o\'chirilsinmi? Ochiq buyurtmasi bo\'lsa, xatolik qaytadi.';
  }

  @override
  String get tablesNotFound => 'Stollar topilmadi';

  @override
  String tablesServiceCharge(String percent) {
    return 'Xizmat haqi: $percent%';
  }

  @override
  String get staffStoreBranchRequired => 'Do\'kon (filial) *';

  @override
  String get waitersEditTitle => 'Ofitsiantni tahrirlash';

  @override
  String get waitersNewTitle => 'Yangi ofitsiant';

  @override
  String get waitersDeleteTitle => 'Ofitsiantni o\'chirish';

  @override
  String get waitersNotFound => 'Ofitsiantlar topilmadi';

  @override
  String waitersUsage(String used, String limit) {
    return '$used / $limit ofitsiant ishlatilmoqda';
  }

  @override
  String get waitersCommissionOptional => 'Komissiya (%) — ixtiyoriy';

  @override
  String waitersCommission(String percent) {
    return 'Komissiya: $percent%';
  }

  @override
  String waitersToday(int count) {
    return 'Bugun: $count ta buyurtma';
  }

  @override
  String get couriersEditTitle => 'Kuryerni tahrirlash';

  @override
  String get couriersNewTitle => 'Yangi kuryer';

  @override
  String get couriersDeleteTitle => 'Kuryerni o\'chirish';

  @override
  String get couriersNotFound => 'Kuryerlar topilmadi';

  @override
  String couriersUsage(String used, String limit) {
    return '$used / $limit kuryer ishlatilmoqda';
  }

  @override
  String couriersToday(int count) {
    return 'Bugun: $count ta yetkazish';
  }

  @override
  String enumDeliveryStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'pending': 'Kutilmoqda',
      'assigned': 'Biriktirilgan',
      'accepted': 'Qabul qilingan',
      'pickedUp': 'Yo\'lda',
      'arrived': 'Yetib keldi',
      'delivered': 'Topshirildi',
      'cancelled': 'Bekor qilingan',
      'failed': 'Yetkazib bo\'lmadi',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String enumDeliveryFailReason(String reason) {
    String _temp0 = intl.Intl.selectLogic(reason, {
      'notHome': 'Mijoz manzilda yo\'q',
      'refused': 'Mijoz qabul qilmadi',
      'wrongAddress': 'Manzil noto\'g\'ri',
      'other': 'Boshqa sabab',
    });
    return '$_temp0';
  }

  @override
  String dlvHeadline(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'pending': 'Kuryer qidirilmoqda',
      'assigned': 'Kuryer tayinlandi, tasdiqlashini kutmoqda',
      'accepted': 'Kuryer do\'konga bormoqda',
      'pickedUp': 'Kuryer yo\'lda',
      'arrived': 'Kuryer yetib keldi!',
      'delivered': 'Buyurtma topshirildi',
      'cancelled': 'Yetkazish bekor qilindi',
      'failed': 'Yetkazib bo\'lmadi',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get dlvLabelFallback => 'Yetkazish';

  @override
  String get dlvConfirmHandoverTitle => 'Buyurtma topshirildimi?';

  @override
  String dlvConfirmHandoverBody(String label) {
    return '$label mijozga topshirilganini tasdiqlang.';
  }

  @override
  String get dlvYesHandedOver => 'Ha, topshirdim';

  @override
  String get dlvCallFailed => 'Qo\'ng\'iroq qilib bo\'lmadi';

  @override
  String get dlvNavigatorFailed => 'Navigatorni ochib bo\'lmadi';

  @override
  String dlvCount(int count) {
    return '$count ta yetkazish';
  }

  @override
  String get dlvNone => 'Hozircha yetkazish yo\'q';

  @override
  String get dlvActiveSection => 'Faol yetkazishlar';

  @override
  String get dlvOffersSection => 'Yangi takliflar';

  @override
  String get dlvActiveBannerTitle => 'Faol yetkazish bor';

  @override
  String get dlvActiveBannerCustomer =>
      'Mijoz va biznes egangiz sizni xaritada ko\'rishi uchun onlayn bo\'ling.';

  @override
  String get dlvActiveBannerOwner =>
      'Biznes egangiz sizni xaritada ko\'rishi uchun onlayn bo\'ling.';

  @override
  String get dlvNoAddress => 'Manzil ko\'rsatilmagan';

  @override
  String get dlvCompleted => 'Yetkazish yakunlandi';

  @override
  String get dlvFailedMarked =>
      'Belgilandi: yetkazib bo\'lmadi. Buyurtmani do\'konga qaytaring.';

  @override
  String get mapFitAll => 'Hammasini ko\'rsatish';

  @override
  String get mapMyLocation => 'Mening joylashuvim';

  @override
  String get dlvPickup => 'Olib ketish';

  @override
  String get dlvYouAreOffline => 'Siz oflaynsiz';

  @override
  String get dlvLocationHidden => 'Joylashuvingiz ko\'rinmayapti';

  @override
  String get dlvFailed => 'Yetkazib bo\'lmadi';

  @override
  String get dlvCancelledTitle => 'Yetkazish bekor qilindi';

  @override
  String get dlvFinishedTitle => 'Yetkazish yakunlangan';

  @override
  String get dlvGoToStore => 'Do\'konga boring';

  @override
  String get dlvDeliverToCustomer => 'Mijozga yetkazing';

  @override
  String get dlvCodeLockedHint =>
      'Kod bloklangan — do\'konga qo\'ng\'iroq qiling';

  @override
  String get dlvAskCode => 'Topshirishda mijozdan 4 xonali kodni so\'rang';

  @override
  String get dlvStoreFallback => 'Do\'kon';

  @override
  String get dlvNavigator => 'Navigator';

  @override
  String get dlvHandedOver => 'Topshirdim';

  @override
  String get dlvPickedUp => 'Buyurtmani oldim';

  @override
  String get dlvArrived => 'Yetib keldim';

  @override
  String dlvMinutesShort(String minutes) {
    return '~$minutes daq';
  }

  @override
  String dlvToStore(String time) {
    return 'Do\'kongacha $time';
  }

  @override
  String dlvToCustomer(String time) {
    return 'Mijozgacha $time';
  }

  @override
  String commonKm(String km) {
    return '$km km';
  }

  @override
  String commonMeters(String meters) {
    return '$meters m';
  }

  @override
  String get dlvRestaurantOrder => 'Restoran buyurtmasi';

  @override
  String dlvMinutesLong(String minutes) {
    return '~$minutes daqiqa';
  }

  @override
  String dlvFailedCustomer(String reason) {
    return '$reason. Do\'kon siz bilan bog\'lanadi.';
  }

  @override
  String get dlvFailedFallback => 'Topshirib bo\'lmadi';

  @override
  String get dlvCourierUpdating => 'Kuryer joylashuvi yangilanmoqda…';

  @override
  String get dlvYourCourier => 'Sizning kuryeringiz';

  @override
  String get commonCall => 'Qo\'ng\'iroq';

  @override
  String get dlvAssignTitle => 'Kuryerga berish';

  @override
  String get dlvOfferAll => 'Barcha kuryerlarga taklif qilish';

  @override
  String get dlvOfferAllHint => 'Birinchi qabul qilgan kuryer oladi';

  @override
  String get dlvNoActiveCouriers => 'Faol kuryer yo\'q';

  @override
  String dlvActiveDeliveries(int count) {
    return '$count ta faol yetkazish';
  }

  @override
  String get dlvCodeFourDigits => 'Kod 4 ta raqamdan iborat';

  @override
  String get dlvCodeLocked => 'Kod bloklandi';

  @override
  String get dlvWaivedTitle => 'Do\'kon kodsiz topshirishga ruxsat berdi';

  @override
  String get dlvHandoverCode => 'Topshirish kodi';

  @override
  String get dlvTooManyTries =>
      'Noto\'g\'ri urinishlar juda ko\'p. Do\'konga qo\'ng\'iroq qiling — ular kodsiz topshirishga ruxsat beradi.';

  @override
  String get dlvConfirmHandedOver =>
      'Buyurtmani mijozga topshirganingizni tasdiqlang.';

  @override
  String get dlvAskCodeLong =>
      'Mijozdan 4 xonali kodni so\'rang. Kod mijozning ilovasida va Telegramida.';

  @override
  String dlvAttemptsLeft(int count) {
    return 'Urinishlar: $count ta qoldi';
  }

  @override
  String get dlvRecheck => 'Qayta tekshirish';

  @override
  String get dlvWhyFailed => 'Nima uchun topshirib bo\'lmadi?';

  @override
  String get dlvFailNotice =>
      'Mijoz va do\'kon xabardor qilinadi. Buyurtmani do\'konga qaytaring.';

  @override
  String get dlvNoteRequired => 'Izoh (majburiy)';

  @override
  String get dlvWaiveTitle => 'Kodsiz topshirishga ruxsat berilsinmi?';

  @override
  String get dlvWaiveBody =>
      'Kuryer buyurtmani mijoz kodisiz topshira oladi. Faqat mijoz bilan gaplashib, buyurtmani olganiga ishonch hosil qilsangiz ruxsat bering.';

  @override
  String get dlvWaiveConfirm => 'Ruxsat berish';

  @override
  String get dlvWaived => 'Ruxsat berildi — kuryer kodsiz topshira oladi';

  @override
  String dlvReasonWith(String reason) {
    return 'Sabab: $reason';
  }

  @override
  String dlvDistanceFromDropoff(String distance) {
    return 'Kuryer mijoz manzilidan $distance uzoqlikda edi';
  }

  @override
  String dlvCancelReasonWith(String reason) {
    return 'Bekor qilish sababi: $reason';
  }

  @override
  String get dlvCodeLockedStaff =>
      'Kod bloklandi: kuryer noto\'g\'ri kodni ko\'p kiritdi';

  @override
  String dlvCodeWaiting(int count) {
    return 'Mijoz kodi kutilmoqda ($count urinish qoldi)';
  }

  @override
  String get dlvWaivedStaff => 'Kodsiz topshirishga ruxsat berilgan';

  @override
  String get dlvWaiveButton => 'Kodsiz topshirishga ruxsat';

  @override
  String get dlvHandoverCodeHint =>
      'Buyurtmani olganingizda kuryerga ayting. Boshqa hech kimga bermang.';

  @override
  String dlvCodeSemantics(String digits) {
    return 'Kod $digits';
  }

  @override
  String dlvCourierWith(String name) {
    return 'Kuryer: $name';
  }

  @override
  String get dlvChangeCourier => 'Kuryerni o\'zgartirish';

  @override
  String get dlvCancel => 'Bekor qilish';

  @override
  String get dlvReassign => 'Qayta kuryerga berish';

  @override
  String get dlvTrackCourier => 'Kuryerni kuzatish';

  @override
  String get dlvOfferedAll => 'Barcha kuryerlarga taklif qilindi';

  @override
  String get dlvAssigned => 'Kuryerga berildi';

  @override
  String get dlvCancelTitle => 'Yetkazishni bekor qilish?';

  @override
  String get dlvCancelBody =>
      'Kuryer bu buyurtmani endi ko\'rmaydi. Keyin qayta berishingiz mumkin.';

  @override
  String get commonRefresh => 'Yangilash';

  @override
  String fleetOnline(String count) {
    return '$count onlayn';
  }

  @override
  String fleetBusy(String count) {
    return '$count yetkazishda';
  }

  @override
  String fleetStale(String count) {
    return '$count aloqasiz';
  }

  @override
  String get fleetNoSignal => 'Aloqa yo\'q';

  @override
  String get fleetDelivering => 'Yetkazishda';

  @override
  String get fleetFree => 'Bo\'sh';

  @override
  String get fleetNoneOnline => 'Hozircha onlayn kuryer yo\'q';

  @override
  String fleetLastLocation(String ago) {
    return 'oxirgi joylashuv $ago';
  }

  @override
  String get fleetViewDelivery => 'Yetkazishni ko\'rish';

  @override
  String fleetViewDeliveryN(String n) {
    return 'Yetkazishni ko\'rish ($n)';
  }

  @override
  String get trkOnline => 'Onlayn';

  @override
  String get trkOffline => 'Oflayn';

  @override
  String get trkNotificationTitle => 'bsmart joylashuvingizni ulashmoqda';

  @override
  String trkNotifActiveCustomer(String label) {
    return 'Faol yetkazish: $label — mijoz va biznes egangiz ko\'radi';
  }

  @override
  String trkNotifActiveOwner(String label) {
    return 'Faol yetkazish: $label — biznes egangiz ko\'radi';
  }

  @override
  String get trkNotifOnline =>
      'Onlayn — joylashuvingiz biznes egasiga ko\'rinadi';

  @override
  String get trkShareTitle => 'Joylashuvni ulashish';

  @override
  String get trkWatchersNone => 'Hech kim — joylashuv yuborilmayapti';

  @override
  String trkWatchersWithCustomer(String label) {
    return 'Biznes egangiz, administratorlar va mijoz ($label)';
  }

  @override
  String get trkWatchersOwner => 'Biznes egangiz va administratorlar';

  @override
  String get trkWhatTitle => 'Nima ulashiladi';

  @override
  String get trkWhatBody =>
      'Telefoningizning GPS joylashuvi: koordinatalar, tezlik va harakat yo\'nalishi.';

  @override
  String get trkWhenTitle => 'Qachon';

  @override
  String get trkWhenBody =>
      'Faqat siz «Onlayn» bo\'lganingizda yoki faol yetkazish paytida — ilova fonda yoki ekran o\'chiq bo\'lsa ham. Bu vaqtda bildirishnomalar panelida doimiy xabar turadi.';

  @override
  String get trkWhoTitle => 'Kim ko\'radi';

  @override
  String get trkWhoBody =>
      'Biznes egangiz va uning administratorlari, hamda faol yetkazish buyurtmasining mijozi.';

  @override
  String get trkStopTitle => 'Qanday to\'xtatiladi';

  @override
  String get trkStopBody =>
      'Istalgan vaqtda «Oflayn» ga o\'ting — joylashuv yuborish darhol to\'xtaydi. Oflayn paytida joylashuvingiz yuborilmaydi.';

  @override
  String get trkDisclosureLead =>
      'Yetkazishlarni kuzatish uchun bsmart joylashuvingizdan foydalanadi';

  @override
  String get trkNotNow => 'Hozir emas';

  @override
  String get trkAgree => 'Roziman';

  @override
  String get trkGoOfflineTitle => 'Oflayn bo\'lish';

  @override
  String get trkGoOfflineBody =>
      'Joylashuvingizni ulashish to\'xtatiladi — biznes egangiz sizni xaritada ko\'rmaydi.';

  @override
  String trkGoOfflineActiveCustomer(String label) {
    return 'Sizda faol yetkazish bor ($label). Joylashuv ulashish to\'xtatilsa, mijoz va biznes egangiz sizni xaritada ko\'rmay qoladi.';
  }

  @override
  String trkGoOfflineActiveOwner(String label) {
    return 'Sizda faol yetkazish bor ($label). Joylashuv ulashish to\'xtatilsa, biznes egangiz sizni xaritada ko\'rmay qoladi.';
  }

  @override
  String get trkStop => 'To\'xtatish';

  @override
  String get trkNotSentYet => 'hali yuborilmagan';

  @override
  String trkSecondsAgo(String seconds) {
    return '$seconds soniya oldin';
  }

  @override
  String trkMinutesAgo(String minutes) {
    return '$minutes daqiqa oldin';
  }

  @override
  String trkWatchersWith(String who) {
    return 'Ko\'radi: $who';
  }

  @override
  String get trkGoOnlineHint => 'Ishni boshlash uchun onlayn bo\'ling';

  @override
  String get trkGpsOffBanner => 'Telefoningizda GPS (joylashuv) o\'chirilgan.';

  @override
  String get trkTurnOnGps => 'GPS ni yoqish';

  @override
  String get trkDeniedForever =>
      'Joylashuv ruxsati rad etilgan. Sozlamalardan ruxsat bering.';

  @override
  String get trkOpenSettings => 'Sozlamalarni ochish';

  @override
  String get trkPermissionNeeded =>
      'Onlayn bo\'lish uchun joylashuv ruxsati kerak.';

  @override
  String get trkLastSent => 'Oxirgi yuborilgan joylashuv';

  @override
  String get trkWhoNow => 'Hozir kim ko\'radi';

  @override
  String get trkNoNotifPermission => 'Bildirishnoma ruxsati yo\'q';

  @override
  String get trkNoNotifPermissionBody =>
      'Kuzatuv davom etadi, lekin bildirishnoma panelida ko\'rinmaydi.';

  @override
  String get trkBatterySaver => 'Batareya tejash rejimi';

  @override
  String get trkBatterySaverBody =>
      'Ba\'zi telefonlar fondagi ilovalarni to\'xtatadi. Muammo bo\'lsa, bsmart uchun batareya cheklovini o\'chiring.';

  @override
  String get trkAboutSharing => 'Joylashuv ulashish haqida';

  @override
  String get trkSharing => 'Joylashuv ulashilmoqda';

  @override
  String get trkConnecting => 'Ulanmoqda…';

  @override
  String get trkNoGps => 'GPS signali yo\'q';

  @override
  String get trkReconnecting => 'Qayta ulanmoqda…';

  @override
  String get trkDenied => 'Ruxsat berilmagan';

  @override
  String get trkGpsOff => 'GPS o\'chirilgan';

  @override
  String get trkJustNow => 'hozirgina';

  @override
  String get tgRequestNotFound => 'So\'rov topilmadi. Qaytadan boshlang.';

  @override
  String get tgRequestUsed =>
      'Bu so\'rov allaqachon ishlatilgan. Qaytadan boshlang.';

  @override
  String get sfUnknownShop => 'Noma\'lum do\'kon';

  @override
  String get favLoginPrompt => 'Sevimlilarni ko\'rish uchun tizimga kiring';

  @override
  String get favEmpty => 'Sevimlilar ro\'yxati bo\'sh';

  @override
  String get usersNotFound => 'Foydalanuvchilar topilmadi';

  @override
  String get usersSearchHint => 'Ism, familiya yoki telefon...';

  @override
  String get usersDeleteTitle => 'Foydalanuvchini o\'chirish';

  @override
  String usersDeleteConfirm(String name) {
    return '$name butunlay o\'chirilsinmi? Bu amalni bekor qilib bo\'lmaydi.';
  }

  @override
  String get usersEditTitle => 'Foydalanuvchini tahrirlash';

  @override
  String get usersNewTitle => 'Yangi foydalanuvchi';

  @override
  String get usersRoleRequired => 'Rol *';

  @override
  String get usersVerticalRequired => 'Yo\'nalish *';

  @override
  String get usersShopName => 'Do\'kon nomi';

  @override
  String get adminVerticalsTitle => 'Yo\'nalishlar bo\'yicha do\'konchilar';

  @override
  String get adminTotalRevenue => 'Jami tushum';

  @override
  String get adminActiveUsers => 'Faol foydalanuvchilar';

  @override
  String get adminTotalDebt => 'Umumiy qarzdorlik';

  @override
  String get scannerHint => 'Shtrix-kodni ramka ichiga joylang';

  @override
  String get scannerTorch => 'Chiroq';

  @override
  String get locationDragHint => 'Xaritani suring — pin markazda qoladi';

  @override
  String get categoriesPickerTitle => 'Kategoriyani tanlang';

  @override
  String get scannerCameraError =>
      'Kamerani ochib bo\'lmadi. Kameraga ruxsat berilganini tekshiring.';

  @override
  String get agentTabHome => 'Bosh sahifa';

  @override
  String get agentTabSell => 'Sotish';

  @override
  String get agentTabSales => 'Sotuvlar';

  @override
  String get agentTabDebts => 'Qarzdorlar';

  @override
  String agentHello(String name) {
    return 'Salom, $name!';
  }

  @override
  String agentLeadOf(String business) {
    return '$business dilleri';
  }

  @override
  String agentStaffOf(String lead) {
    return '$lead dillerining agenti';
  }

  @override
  String get agentTodaySales => 'Bugungi savdo';

  @override
  String get agentMonthSales => '30 kunlik savdo';

  @override
  String get agentMyTodaySales => 'Bugungi savdom';

  @override
  String get agentMyMonthSales => '30 kunlik savdom';

  @override
  String agentSalesCount(int count) {
    return '$count ta sotuv';
  }

  @override
  String get agentCustomersOwe => 'Mijozlar qarzi';

  @override
  String get agentMyDebtsGiven => 'Men bergan qarzlar';

  @override
  String agentOpenDebts(int count) {
    return '$count ta ochiq qarz';
  }

  @override
  String get agentOwedToOwner => 'Biznes egasiga qarzim';

  @override
  String get agentStockValue => 'Qo\'limdagi tovar';

  @override
  String get agentProfitTitle => 'Sof foyda';

  @override
  String get agentProfitToday => 'Bugun';

  @override
  String get agentProfit7 => '7 kun';

  @override
  String get agentProfit30 => '30 kun';

  @override
  String get agentProfitRevenue => 'Sotuv summasi';

  @override
  String get agentProfitCost => 'Egaga to\'lanadigan narx';

  @override
  String get agentProfitPending => 'Mijozlar qarzidagi foyda';

  @override
  String get agentProfitHint =>
      'Qarzga sotuvlar foydasi mijoz to\'lagach qo\'shiladi';

  @override
  String get agentShortcutProducts => 'Mahsulotlarim';

  @override
  String get agentNoStock => 'Hozircha mahsulot yo\'q';

  @override
  String get agentNoStockHint =>
      'Biznes egasi mahsulot berganda shu yerda paydo bo\'ladi.';

  @override
  String agentStockLeft(String qty) {
    return 'Qoldi: $qty';
  }

  @override
  String agentPriceRange(String min, String max) {
    return '$min – $max';
  }

  @override
  String get agentOtherCurrency => 'Bitta sotuvda bitta valyuta bo\'ladi';

  @override
  String agentCartCount(int count) {
    return '$count ta mahsulot';
  }

  @override
  String get agentCheckout => 'Rasmiylashtirish';

  @override
  String get agentCheckoutTitle => 'Sotuv';

  @override
  String get agentQuantity => 'Miqdori';

  @override
  String get agentPrice => 'Narx';

  @override
  String agentPriceOutOfRange(String name, String min, String max) {
    return '«$name»: narx $min – $max oralig\'ida bo\'lsin';
  }

  @override
  String agentQtyInvalid(String name) {
    return '«$name»: miqdorni kiriting';
  }

  @override
  String agentQtyTooMuch(String name, String qty) {
    return '«$name»: faqat $qty bor';
  }

  @override
  String get agentCash => 'Naqd';

  @override
  String get agentDebt => 'Qarzga';

  @override
  String get agentCustomer => 'Xaridor';

  @override
  String get agentCustomerName => 'Ismi';

  @override
  String get agentCustomerLastName => 'Familiyasi (ixtiyoriy)';

  @override
  String get agentCustomerPhone => 'Telefon raqami';

  @override
  String get agentCustomerOptional => 'Xaridor ma\'lumotlari ixtiyoriy';

  @override
  String get agentReturningDebtorHint =>
      'Raqam avval yozilgan bo\'lsa, qarz o\'sha xaridorga qo\'shiladi';

  @override
  String get agentDebtNeedsCustomer =>
      'Qarzga sotish uchun ism va telefon kerak';

  @override
  String get agentPhoneInvalid => 'Telefon raqami noto\'g\'ri';

  @override
  String agentSellNow(String total) {
    return 'Sotish · $total';
  }

  @override
  String get agentSold => 'Sotuv saqlandi';

  @override
  String get agentSalesEmpty => 'Hali sotuv yo\'q';

  @override
  String agentSaleSeller(String name) {
    return 'Sotuvchi: $name';
  }

  @override
  String agentLineCost(String amount) {
    return 'Tannarx: $amount';
  }

  @override
  String get agentDebtsOpen => 'Ochiq';

  @override
  String get agentDebtsAll => 'Hammasi';

  @override
  String get agentDebtsEmpty => 'Qarz yo\'q';

  @override
  String get agentDebtsTotal => 'Jami qarz';

  @override
  String get agentDebtOriginal => 'Qarz summasi';

  @override
  String get agentDebtPaid => 'To\'langan';

  @override
  String get agentDebtBalance => 'Qoldiq';

  @override
  String get agentPayTitle => 'To\'lov qabul qilish';

  @override
  String get agentPayFull => 'To\'liq';

  @override
  String get agentPaySubmit => 'Qabul qilish';

  @override
  String get agentPaid => 'To\'lov qabul qilindi';

  @override
  String get agentPayInvalid => 'Summani kiriting';

  @override
  String get agentPayTooMuch => 'Summa qarz qoldig\'idan oshmasin';

  @override
  String get agentPaymentsHistory => 'To\'lovlar tarixi';

  @override
  String get agentNoPayments => 'Hali to\'lov yo\'q';

  @override
  String get agentDebtClosed => 'Qarz yopilgan';

  @override
  String get agentAccountTitle => 'Hisob-kitob';

  @override
  String agentAccountWith(String owner) {
    return '$owner bilan hisob';
  }

  @override
  String get agentMyDebt => 'Qarzim';

  @override
  String get agentNothingOwed => 'Qarzingiz yo\'q';

  @override
  String get agentPendingPayments => 'Kutilayotgan to\'lovlar';

  @override
  String get agentPendingReturns => 'Kutilayotgan qaytarishlar';

  @override
  String get agentSendPayment => 'To\'lov yuborish';

  @override
  String get agentSendPaymentHint =>
      'Biznes egasiga bergan pulingizni yozing. U tasdiqlagach qarzingiz kamayadi.';

  @override
  String get agentPaymentSent => 'To\'lov so\'rovi yuborildi';

  @override
  String get agentReturnGoods => 'Mahsulot qaytarish';

  @override
  String get agentReturnHint =>
      'Qaytariladigan miqdorni kiriting. Mahsulotlar darhol zaxirangizdan ayriladi; biznes egasi tasdiqlagach qarzingiz kamayadi, rad etsa qaytib keladi.';

  @override
  String agentReturnSend(int count) {
    return 'Qaytarish ($count)';
  }

  @override
  String get agentReturnSent => 'Qaytarish so\'rovi yuborildi';

  @override
  String get agentReturnPickOne => 'Kamida bitta mahsulot miqdorini kiriting';

  @override
  String get agentTabPayments => 'To\'lovlar';

  @override
  String get agentTabReturns => 'Qaytarishlar';

  @override
  String get agentStatusPending => 'Kutilmoqda';

  @override
  String get agentStatusConfirmed => 'Tasdiqlangan';

  @override
  String get agentStatusRejected => 'Rad etilgan';

  @override
  String get agentStatusCancelled => 'Bekor qilingan';

  @override
  String get agentCancelRequest => 'Bekor qilish';

  @override
  String get agentCancelRequestConfirm => 'So\'rov bekor qilinsinmi?';

  @override
  String get agentRequestCancelled => 'So\'rov bekor qilindi';

  @override
  String get agentPaymentsEmpty => 'Hali to\'lov so\'rovi yo\'q';

  @override
  String get agentReturnsEmpty => 'Hali qaytarish yo\'q';

  @override
  String get agentReturnValue => 'Qiymati';

  @override
  String get agentRefund => 'Naqd qaytarildi';

  @override
  String agentReturnFromTransfer(String number) {
    return 'O\'tkazma $number';
  }

  @override
  String get agentTransfersTitle => 'Kirimlar';

  @override
  String get agentTransfersEmpty => 'Hali kirim yo\'q';

  @override
  String agentTransferPaid(String amount) {
    return 'To\'langan: $amount';
  }

  @override
  String agentTransferDebt(String amount) {
    return 'Qarz: $amount';
  }

  @override
  String agentTransferLineQty(String given, String left) {
    return 'Berildi $given · qoldi $left';
  }

  @override
  String agentTransferReturned(String qty) {
    return 'Qaytarildi $qty';
  }

  @override
  String agentTransferOwed(String price) {
    return 'Narxi $price';
  }

  @override
  String agentTransferRange(String range) {
    return 'Sotish: $range';
  }

  @override
  String agentTransferGivenBy(String name) {
    return 'Bergan: $name';
  }

  @override
  String get agentStaffTitle => 'Agentlar';

  @override
  String get agentStaffEmpty => 'Hali agent yo\'q';

  @override
  String get agentStaffNew => 'Yangi agent';

  @override
  String get agentStaffEdit => 'Agentni tahrirlash';

  @override
  String get agentStaffDeleteTitle => 'Agentni o\'chirish';

  @override
  String agentRejectReason(String reason) {
    return 'Sabab: $reason';
  }

  @override
  String agentAvailableToSend(String amount) {
    return 'Yuborish mumkin: $amount';
  }

  @override
  String get navLeadAgents => 'Dillerlar';

  @override
  String get ownerLeadNew => 'Yangi diller';

  @override
  String get ownerLeadEdit => 'Dillerni tahrirlash';

  @override
  String get ownerLeadDeleteTitle => 'Dillerni o\'chirish';

  @override
  String get ownerLeadsEmpty => 'Hali diller yo\'q';

  @override
  String get ownerLeadStoreHint => 'Diller shu do\'kon mahsulotlarini oladi';

  @override
  String ownerLeadStaffCount(int count) {
    return '$count ta agent';
  }

  @override
  String ownerLeadPendingCount(int count) {
    return '$count ta so\'rov';
  }

  @override
  String get ownerLeadOwes => 'Menga qarzi';

  @override
  String get ownerLeadStock => 'Qo\'lidagi mahsulotlar';

  @override
  String get ownerLeadStaff => 'Agentlari';

  @override
  String get ownerTeamTitle => 'Jamoa savdosi';

  @override
  String get ownerGiveProducts => 'Mahsulot berish';

  @override
  String get ownerTabStock => 'Mahsulotlari';

  @override
  String get ownerTabTransfers => 'Berilganlar';

  @override
  String get ownerTabCustomerDebts => 'Mijoz qarzlari';

  @override
  String get ownerStockEmpty => 'Dillerda mahsulot yo\'q';

  @override
  String get ownerSellPrice => 'Sotish narxi';

  @override
  String get ownerDiscountPercent => 'Chegirma, %';

  @override
  String get ownerEditRange => 'Narx va chegirmani o\'zgartirish';

  @override
  String get ownerRangeUpdated => 'Narx va chegirma yangilandi';

  @override
  String ownerDiscountInvalid(String name) {
    return '«$name»: chegirma 0 dan 100% gacha bo\'lsin';
  }

  @override
  String ownerPriceInvalid(String name) {
    return '«$name»: narxni kiriting';
  }

  @override
  String get ownerPriceBelowOwed =>
      'Sotish narxi diller to\'laydigan narxdan past';

  @override
  String ownerSellsFor(String min, String max) {
    return 'Agentlar sotadi: $min – $max';
  }

  @override
  String ownerDiscountUpTo(String percent) {
    return '−$percent% gacha';
  }

  @override
  String get ownerConfirm => 'Tasdiqlash';

  @override
  String get ownerReject => 'Rad etish';

  @override
  String get ownerConfirmed => 'Tasdiqlandi';

  @override
  String get ownerRejected => 'Rad etildi';

  @override
  String get ownerRejectTitle => 'So\'rovni rad etish';

  @override
  String get ownerRejectReason => 'Sabab (ixtiyoriy)';

  @override
  String get ownerConfirmPaymentTitle => 'To\'lovni tasdiqlash';

  @override
  String ownerConfirmPaymentText(String name, String amount) {
    return '$name $amount to\'laganini tasdiqlaysizmi? Summa eng eski qarzlaridan boshlab yopiladi.';
  }

  @override
  String get ownerConfirmReturnTitle => 'Qaytarishni tasdiqlash';

  @override
  String get ownerConfirmReturnText =>
      'Mahsulotlar omboringizga qaytadi va dillerning qarzi kamayadi.';

  @override
  String ownerDebtReduceLine(String amount) {
    return 'Qarzdan ayriladi: $amount';
  }

  @override
  String ownerRefundLine(String amount) {
    return 'Naqd qaytarasiz: $amount';
  }

  @override
  String get ownerTransferEmpty => 'Bu do\'konda berish uchun mahsulot yo\'q';

  @override
  String ownerTransferInStock(String qty) {
    return 'Omborda: $qty';
  }

  @override
  String ownerTransferHeld(String qty) {
    return 'Dillerda: $qty';
  }

  @override
  String get ownerTransferOneCurrency =>
      'Bitta berishda bitta valyuta bo\'ladi';

  @override
  String get ownerTransferPicked => 'Tanlanganlar';

  @override
  String get ownerTransferPaid => 'Hozir to\'langan summa';

  @override
  String get ownerTransferPaidTooMuch =>
      'To\'langan summa umumiy summadan oshmasin';

  @override
  String ownerTransferDebtLine(String amount) {
    return 'Qarzga yoziladi: $amount';
  }

  @override
  String ownerTransferSubmit(int count) {
    return 'Berish ($count)';
  }

  @override
  String get ownerTransferDone => 'Mahsulotlar berildi';

  @override
  String get ownerTransferPickOne => 'Kamida bitta mahsulot tanlang';

  @override
  String get commonLoadMore => 'Yana ko\'rsatish';

  @override
  String get navCrmDrivers => 'Haydovchilar';

  @override
  String get navCrmReminders => 'Eslatmalar';

  @override
  String get crmDriversSearchHint => 'Ism, telefon yoki davlat raqami';

  @override
  String get crmDriversEmpty => 'Hali haydovchilar yo\'q';

  @override
  String get crmNotEnabled => 'CRM bu biznes uchun yoqilmagan';

  @override
  String get crmAddDriver => 'Haydovchi qo\'shish';

  @override
  String get crmNewDriver => 'Yangi haydovchi';

  @override
  String get crmEditDriver => 'Haydovchini tahrirlash';

  @override
  String get crmLastName => 'Familiya';

  @override
  String get crmPhoneHint =>
      'Shu raqam bilan do\'kon mijozlari ro\'yxatiga ham qo\'shiladi';

  @override
  String get crmFirstCar => 'Mashina (ixtiyoriy)';

  @override
  String get crmPlate => 'Davlat raqami';

  @override
  String get crmPlateMissing => 'Davlat raqamini kiriting';

  @override
  String get crmPlateInvalid => 'Davlat raqami noto\'g\'ri';

  @override
  String get crmModel => 'Model';

  @override
  String get crmModelMissing => 'Mashina modelini kiriting';

  @override
  String get crmDailyKm => 'Kuniga yuradigan masofa (km)';

  @override
  String get crmDailyKmHint =>
      'Taxminan. Xizmat muddati shu asosida hisoblanadi';

  @override
  String get crmDailyKmInvalid => '1 dan 3000 gacha butun son kiriting';

  @override
  String get crmActiveHint => 'Nofaol haydovchiga eslatmalar yuborilmaydi';

  @override
  String get crmVehicles => 'Mashinalar';

  @override
  String get crmVehicle => 'Mashina';

  @override
  String get crmAddVehicle => 'Mashina qo\'shish';

  @override
  String get crmEditVehicle => 'Mashinani tahrirlash';

  @override
  String get crmNoVehicles => 'Mashina qo\'shilmagan';

  @override
  String crmDailyKmValue(String km) {
    return 'Kuniga ~$km km';
  }

  @override
  String get crmDailyKmMissing => 'Kunlik masofa kiritilmagan';

  @override
  String crmNextDue(String name) {
    return 'Keyingi: $name';
  }

  @override
  String get crmRecordService => 'Xizmat yozish';

  @override
  String get crmHistory => 'Xizmatlar tarixi';

  @override
  String get crmNoVisits => 'Hali xizmat yozilmagan';

  @override
  String crmLinkedCustomer(String name) {
    return 'Mijozlar ro\'yxatida: $name';
  }

  @override
  String get crmInactiveNoService =>
      'Haydovchi nofaol: xizmat yozish uchun avval uni faollashtiring';

  @override
  String get crmDeleteDriverTitle => 'Haydovchini o\'chirish';

  @override
  String crmDeleteDriverConfirm(String name) {
    return '$name va uning mashinalari o\'chiriladi. Mijozlar ro\'yxatidagi yozuvi va savdolari saqlanib qoladi.';
  }

  @override
  String get crmDeleteVehicleTitle => 'Mashinani o\'chirish';

  @override
  String crmDeleteVehicleConfirm(String plate) {
    return '$plate mashinasi o\'chiriladi.';
  }

  @override
  String get crmPhotoAdd => 'Rasm qo\'shish';

  @override
  String get crmPhotoChange => 'Rasmni almashtirish';

  @override
  String get crmPhotoRemove => 'Rasmni o\'chirish';

  @override
  String get crmDueToday => 'bugun';

  @override
  String crmDueIn(int count) {
    return '$count kun qoldi';
  }

  @override
  String crmOverdueBy(int count) {
    return '$count kun o\'tdi';
  }

  @override
  String get crmItemReplaced => 'Keyingi xizmatda almashtirildi';

  @override
  String get crmItemDone => 'Bajarildi';

  @override
  String get crmItemCancelled => 'Bekor qilingan';

  @override
  String get crmNoReminder => 'Eslatmasiz';

  @override
  String get crmNoSale => 'Sotuvsiz';

  @override
  String crmSaleDebtLeft(String amount) {
    return 'Qarz: $amount';
  }

  @override
  String get crmSaleDebtSettled => 'Qarz to\'langan';

  @override
  String crmKmValue(String km) {
    return '$km km';
  }

  @override
  String crmEveryKm(String km) {
    return 'har $km km';
  }

  @override
  String crmAtKm(String km) {
    return '$km km da';
  }

  @override
  String get crmTgLinked => 'Telegram: eslatmalar boradi';

  @override
  String get crmTgNotLinked => 'Telegram ulanmagan';

  @override
  String get crmTgBlocked => 'Haydovchi botni bloklagan';

  @override
  String get crmTgNoBot =>
      'Do\'konga Telegram bot ulanmagan, eslatmalar haydovchiga Telegram orqali bormaydi';

  @override
  String get crmTgHowTo =>
      'Haydovchi do\'kon botini ochib, telefon raqamini yuborishi kerak';

  @override
  String get crmTgShareLink => 'Bot havolasini yuborish';

  @override
  String get crmVisitTitle => 'Xizmat yozish';

  @override
  String get crmServiceDate => 'Xizmat sanasi';

  @override
  String get crmOdometer => 'Spidometr (km)';

  @override
  String get crmParts => 'O\'rnatilgan qismlar';

  @override
  String get crmAddPart => 'Mahsulot qo\'shish';

  @override
  String get crmAddManual => 'Qo\'lda';

  @override
  String get crmPartSearch => 'Ehtiyot qism yoki moy qidirish';

  @override
  String get crmPartsEmpty => 'Mahsulot yoki qo\'lda qator qo\'shing';

  @override
  String get crmManualName => 'Nomi (masalan: Ish haqi)';

  @override
  String get crmQuantity => 'Miqdor';

  @override
  String get crmIntervalKm => 'Keyingi xizmatgacha, km';

  @override
  String get crmNextDate => 'Keyingi sana';

  @override
  String crmDueAuto(String date) {
    return 'Taxminan $date da qaytib keladi';
  }

  @override
  String get crmDueManual => 'Sana qo\'lda kiritildi';

  @override
  String get crmDueNeedsDate => 'Kunlik masofa yo\'q — sanani kiriting';

  @override
  String get crmRecordSale => 'Sotuv sifatida yozish';

  @override
  String get crmRecordSaleOn =>
      'Mahsulot ombordan chiqadi, to\'lov yoki qarz yoziladi';

  @override
  String get crmRecordSaleOff =>
      'Faqat eslatma uchun: ombor va pul o\'zgarmaydi';

  @override
  String get crmPaidNow => 'Hozir to\'langan summa (ixtiyoriy)';

  @override
  String crmDebtLeft(String amount) {
    return 'Qarz: $amount';
  }

  @override
  String get crmSaveVisit => 'Xizmatni saqlash';

  @override
  String get crmVisitSaved => 'Xizmat yozildi';

  @override
  String crmInStock(String qty) {
    return 'Omborda: $qty';
  }

  @override
  String get crmPickVehicle => 'Mashinani tanlang';

  @override
  String get crmAddPartFirst => 'Kamida bitta qator qo\'shing';

  @override
  String get crmManualNameMissing =>
      'Qo\'lda qo\'shilgan qator nomini kiriting';

  @override
  String crmPriceMissing(String name) {
    return '\"$name\" uchun narxni kiriting';
  }

  @override
  String crmNotEnoughStock(String name) {
    return '\"$name\" omborda yetarli emas';
  }

  @override
  String crmDueAfterService(String name) {
    return '\"$name\" uchun keyingi sana xizmat sanasidan keyin bo\'lishi kerak';
  }

  @override
  String crmDueNeeded(String name) {
    return 'Kunlik masofa kiritilmagan: \"$name\" uchun keyingi sanani tanlang';
  }

  @override
  String get crmPaidTooMuch =>
      'To\'langan summa jami summadan oshmasligi kerak';

  @override
  String get crmMixedCurrency =>
      'Bitta xizmatda faqat bitta valyutadagi mahsulotlar bo\'lishi mumkin';

  @override
  String get crmRemindersAll => 'Barchasi';

  @override
  String get crmRemindersOverdue => 'Muddati o\'tgan';

  @override
  String get crmRemindersSoon => '7 kun ichida';

  @override
  String get crmRemindersEmpty => 'Eslatmalar yo\'q';

  @override
  String get crmMarkDone => 'Bajarildi';

  @override
  String get crmMoveDate => 'Sanani o\'zgartirish';

  @override
  String get crmCancelReminder => 'Eslatmani bekor qilish';

  @override
  String get crmReminderDone => 'Bajarildi deb belgilandi';

  @override
  String get crmReminderCancelled => 'Eslatma bekor qilindi';

  @override
  String get crmDateMoved => 'Sana o\'zgartirildi';

  @override
  String get crmDueManualShort => 'Sana qo\'lda kiritilgan';

  @override
  String get crmDriverSaved => 'Haydovchi saqlandi';

  @override
  String get crmVehicleSaved => 'Mashina saqlandi';

  @override
  String get notifTitle => 'Bildirishnomalar';

  @override
  String get notifEmpty => 'Hozircha bildirishnoma yo\'q';

  @override
  String get notifReadAll => 'Hammasini o\'qilgan qilish';

  @override
  String notifServiceDueStaff(String plate, String driver) {
    return '$plate — xizmat vaqti ($driver)';
  }

  @override
  String get notifDriverNotified => 'Haydovchiga Telegram orqali eslatildi';

  @override
  String notifCallDriver(String phone) {
    return 'Haydovchi botga ulanmagan — qo\'ng\'iroq qiling: $phone';
  }

  @override
  String notifServiceDueDriver(String store) {
    return '$store: xizmat vaqti yaqinlashdi';
  }

  @override
  String get notifUnknown => 'Yangi bildirishnoma';

  @override
  String get notifOpen => 'Ochish';

  @override
  String get specialBadge => 'Maxsus';

  @override
  String get specialCustomersTitle => 'Maxsus mijozlar';

  @override
  String get specialFilterAll => 'Hammasi';

  @override
  String get specialListHint =>
      'Bu mijozlar har doim chakana narxda xarid qiladi. Chakana narxi yo\'q mahsulot ularga oddiy narxda sotiladi.';

  @override
  String get specialEmpty =>
      'Maxsus mijozlar yo\'q. Mijozni tahrirlab, \"Maxsus mijoz\"ni yoqing.';

  @override
  String get specialFieldTitle => 'Maxsus mijoz';

  @override
  String get specialFieldHint => 'Har doim chakana narxda xarid qiladi';

  @override
  String get specialAppliedTitle => 'Maxsus mijoz — chakana narx';

  @override
  String specialAppliedSaving(int count, String amount) {
    return '$count ta mahsulot chakana narxda, $amount arzonroq';
  }

  @override
  String get specialAppliedNoSaving => 'Mahsulotlar chakana narxda hisoblandi';

  @override
  String specialNoRetail(int count) {
    return '$count ta mahsulotning chakana narxi yo\'q — oddiy narxda';
  }

  @override
  String get specialCrmHint =>
      'Haydovchi maxsus mijoz: mahsulotlar chakana narxda hisoblanadi';

  @override
  String get productsRetailPrice => 'Chakana narx';

  @override
  String get productsRetailPriceHint =>
      'Ixtiyoriy. Maxsus mijozlar shu narxda oladi';

  @override
  String get productsRetailPriceTooHigh =>
      'Chakana narx asosiy narxdan qimmat bo\'lishi mumkin emas';

  @override
  String productsRetailPriceWith(String amount) {
    return 'Chakana narx: $amount';
  }

  @override
  String get productsDiscountPercent => 'Chegirma, %';

  @override
  String get productsDiscountPercentNone => 'Cheklov yo\'q';

  @override
  String get productsDiscountPercentHint =>
      'Sotishda narxdan ko\'pi bilan shuncha foiz chegirma berish mumkin (siz va adminlaringiz). Dillerga yuborishda ham shu foiz taklif qilinadi. Bo\'sh — cheklov yo\'q.';

  @override
  String get productsDiscountPercentRange =>
      'Chegirma 0 dan 100 gacha, ko\'pi bilan 2 kasr xonali bo\'lsin';

  @override
  String productsDiscountLimitWith(String percent, String amount) {
    return 'Chegirma ko\'pi bilan $percent% · eng past narx $amount';
  }

  @override
  String salesDiscountTooHigh(String amount) {
    return 'Umumiy chegirma ko\'pi bilan $amount bo\'lishi mumkin — mahsulotlarning chegirma cheklovi bor';
  }

  @override
  String salesDiscountMax(String amount) {
    return 'Mahsulotlarning chegirma cheklovi bo\'yicha ko\'pi bilan $amount';
  }

  @override
  String salesLineDiscountApplied(String percent, String amount) {
    return 'Chegirma $percent% (−$amount)';
  }

  @override
  String get salesLineDiscountAdd => 'Chegirma berish';

  @override
  String salesLineDiscountAddUpTo(String percent) {
    return 'Chegirma berish (ko\'pi bilan $percent%)';
  }

  @override
  String get salesLineDiscountLabel => 'Chegirma, %';

  @override
  String salesLineDiscountMax(String percent) {
    return 'Ko\'pi bilan $percent%';
  }

  @override
  String salesLineDiscountRange(String max) {
    return '0 dan $max% gacha kiriting (ko\'pi bilan 2 kasr xonasi)';
  }

  @override
  String crmPriceBelowLimit(String name, String percent, String amount) {
    return '\"$name\": chegirma ko\'pi bilan $percent% — narx $amount dan past bo\'lmasin';
  }

  @override
  String get productsSelect => 'Tanlash';

  @override
  String get productsSelectAll => 'Hammasini tanlash';

  @override
  String productsSelectedCount(int count) {
    return '$count ta tanlandi';
  }

  @override
  String get productsSelectionHint =>
      'Yuboriladigan mahsulotlarni bosib tanlang';

  @override
  String get productsMoveAction => 'Boshqa do\'konga';

  @override
  String get productsMoveBarLabel => 'Tanlangan mahsulotlar';

  @override
  String get productsMoveTitle => 'Boshqa do\'konga yuborish';

  @override
  String productsMoveFrom(int count, String store) {
    return '$count ta mahsulot «$store» ro\'yxatidan olinib, tanlangan do\'konning mahsulotlariga o\'tkaziladi.';
  }

  @override
  String get productsMoveTarget => 'Qaysi do\'konga';

  @override
  String get productsMovePickStore => 'Do\'konni tanlang';

  @override
  String get productsMoveNoteMoves =>
      'Qoldiq, narxlar, rasmlar va kirim tarixi mahsulot bilan birga o\'tadi.';

  @override
  String get productsMoveNoteHistory =>
      'Oldingi sotuvlar sotilgan do\'konida qoladi.';

  @override
  String get productsMoveNoteBlocked =>
      'Qabul qiluvchi do\'konda shu shtrix-kod yoki PLU band bo\'lsa, yoki mahsulot tasdiqlanmagan buyurtmada bo\'lsa, hech narsa o\'tkazilmaydi.';

  @override
  String get productsMoveSubmit => 'Yuborish';

  @override
  String productsMoveDone(int count, String store) {
    return '$count ta mahsulot «$store» do\'koniga o\'tkazildi';
  }

  @override
  String get agentSalaryPercent => 'Diller maoshi, %';

  @override
  String get agentSalaryPercentHint =>
      'Jamoasi shu o\'tkazmadan sotganining shu foizi dillerga maosh bo\'ladi. Boshqa o\'tkazmalarga ta\'sir qilmaydi.';

  @override
  String agentSalaryEstimate(String amount) {
    return 'Hammasi shu narxda sotilsa, maosh: ~$amount';
  }

  @override
  String get agentSalaryPercentInvalid =>
      'Maosh foizi 0–100, ko\'pi bilan 2 xonali kasr';

  @override
  String get agentSalaryTitle => 'Diller maoshi';

  @override
  String get agentSalaryEdit => 'Foizni tuzatish';

  @override
  String get agentSalaryEditHint =>
      'Yangi foiz shu o\'tkazmadan qilingan barcha sotuvlarga, avvalgilariga ham qo\'llanadi.';

  @override
  String get agentSalarySold => 'Shu o\'tkazmadan sotildi';

  @override
  String get agentSalaryEarned => 'Hisoblangan maosh';

  @override
  String get agentSalaryNone => 'Bu o\'tkazmada maosh foizi belgilanmagan';

  @override
  String get agentSalaryPercentSaved => 'Maosh foizi saqlandi';

  @override
  String agentSalaryLine(String amount, String percent) {
    return 'Maosh: $amount ($percent%)';
  }

  @override
  String get agentMySalary30 => 'Maoshim (30 kun)';

  @override
  String get agentLeadSalary30 => 'Diller maoshi (30 kun)';

  @override
  String get agentSalaryAllTime => 'Maosh, jami';

  @override
  String agentSalaryTotalLine(String total) {
    return 'Jami: $total';
  }

  @override
  String get agentProfitSalary => 'Maoshim';

  @override
  String get manualRevenueAdd => 'Daromad qo\'shish';

  @override
  String get manualRevenueTitle => 'Qo\'lda daromad kiritish';

  @override
  String get manualRevenueIntro =>
      'Ilovaga kiritilmagan mahsulotlar sotuvidan tushgan pulni daromad sifatida yozing';

  @override
  String get manualRevenueAmount => 'Summa';

  @override
  String get manualRevenueAmountMissing => 'Summani kiriting';

  @override
  String get manualRevenueAmountInvalid =>
      'Summa musbat son bo\'lishi kerak (ko\'pi bilan 2 kasr xonasi)';

  @override
  String get manualRevenueAmountTooLarge => 'Summa juda katta';

  @override
  String get manualRevenueMethod => 'To\'lov usuli';

  @override
  String get manualRevenueDate => 'Sana (ixtiyoriy)';

  @override
  String get manualRevenueDateNow => 'Hozirgi vaqt';

  @override
  String get manualRevenueDateHint =>
      'Kiritilmasa, hozirgi vaqt bilan yoziladi';

  @override
  String get manualRevenueDateClear => 'Sanani tozalash';

  @override
  String get manualRevenueCustomer => 'Mijoz (ixtiyoriy)';

  @override
  String get manualRevenueCustomerNone => 'Mijozsiz';

  @override
  String get manualRevenueCustomerPick => 'Ro\'yxatdan';

  @override
  String get manualRevenueCustomerNew => 'Yangi';

  @override
  String get manualRevenueCustomerNoneHint =>
      'Daromad \"Mehmon xaridor\" nomiga yoziladi';

  @override
  String get manualRevenuePickCustomer => 'Mijozni tanlang';

  @override
  String get manualRevenuePickMissing => 'Ro\'yxatdan mijozni tanlang';

  @override
  String get manualRevenueFirstName => 'Ism';

  @override
  String get manualRevenueLastName => 'Familiya (ixtiyoriy)';

  @override
  String get manualRevenuePhone => 'Telefon raqami';

  @override
  String get manualRevenueReturningHint =>
      'Bu raqamli mijoz bo\'lsa, daromad unga yoziladi';

  @override
  String get manualRevenueNameMissing => 'Mijoz ismini kiriting';

  @override
  String get manualRevenuePhoneInvalid => 'Telefon raqami noto\'g\'ri';

  @override
  String get manualRevenueSave => 'Daromadni saqlash';

  @override
  String get manualRevenueCreated => 'Daromad qo\'shildi';

  @override
  String get manualRevenueTag => 'Qo\'lda';

  @override
  String get manualRevenueFilter => 'Qo\'lda';

  @override
  String get manualRevenueDetailTitle => 'Qo\'lda kiritilgan daromad';

  @override
  String get manualRevenueDetailHint =>
      'Ilovaga kiritilmagan mahsulotlardan tushgan pul. Ombordagi qoldiq o\'zgarmagan.';

  @override
  String get manualRevenueCancel => 'Bekor qilish';

  @override
  String get manualRevenueCancelTitle => 'Daromadni bekor qilasizmi?';

  @override
  String manualRevenueCancelText(String amount) {
    return '$amount hisobotlardan, kassa tushumidan va sof foydadan olib tashlanadi. Buni qaytarib bo\'lmaydi.';
  }

  @override
  String get manualRevenueCancelConfirm => 'Ha, bekor qilish';

  @override
  String get manualRevenueKeep => 'Yo\'q';

  @override
  String get manualRevenueCancelled => 'Daromad bekor qilindi';

  @override
  String get manualRevenueSection => 'Qo\'lda kiritilgan daromad';

  @override
  String get manualRevenueDashboardHint =>
      'Ilovaga kiritilmagan mahsulotlardan tushgan pul. Kassa va hisobotlarga ham qo\'shiladi.';

  @override
  String get manualRevenueToday => 'Bugun';

  @override
  String get manualRevenueLast30 => 'Oxirgi 30 kun';

  @override
  String get manualRevenueAllTime => 'Jami';

  @override
  String manualRevenueEntries(int count) {
    return '$count ta yozuv';
  }

  @override
  String get manualRevenueViewAll => 'Barchasi';

  @override
  String get manualRevenueEmpty => 'Qo\'lda kiritilgan daromadlar yo\'q';

  @override
  String get commonOptional => 'Ixtiyoriy';

  @override
  String get navWarehouse => 'Ombor';

  @override
  String get navRecipes => 'Retseptlar';

  @override
  String enumIngredientUnit(String unit) {
    String _temp0 = intl.Intl.selectLogic(unit, {
      'kilogram': 'Kilogramm (kg)',
      'gram': 'Gramm (g)',
      'litr': 'Litr (l)',
      'millilitr': 'Millilitr (ml)',
      'dona': 'Dona',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String enumIngredientUnitShort(String unit) {
    String _temp0 = intl.Intl.selectLogic(unit, {
      'kilogram': 'kg',
      'gram': 'g',
      'litr': 'l',
      'millilitr': 'ml',
      'dona': 'dona',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get whTitle => 'Ombor';

  @override
  String get whRecipesTitle => 'Retseptlar';

  @override
  String get whForbidden =>
      'Ombor va retseptlar faqat restoran egasi va adminlari uchun';

  @override
  String get whSearchHint => 'Masalliq qidirish…';

  @override
  String get whSearchDishHint => 'Taom qidirish…';

  @override
  String get whAdd => 'Masalliq qo\'shish';

  @override
  String get whFilterLow => 'Kam qolgan';

  @override
  String get whFilterOut => 'Tugagan';

  @override
  String get whFilterUnavailable => 'Tayyorlab bo\'lmaydi';

  @override
  String get whFilterEnough => 'Yetarli';

  @override
  String get whFilterNoRecipe => 'Retseptsiz';

  @override
  String get whStatTotal => 'Masalliqlar';

  @override
  String get whStatLow => 'Kam qolgan';

  @override
  String get whStatOut => 'Tugagan';

  @override
  String get whStatValue => 'Ombor qiymati';

  @override
  String get whEmpty =>
      'Omborda hali masalliq yo\'q. Pomidor, kartoshka, go\'sht kabi masalliqlarni qo\'shing.';

  @override
  String get whLevelOk => 'Yetarli';

  @override
  String get whLevelLow => 'Kam qoldi';

  @override
  String get whLevelOut => 'Tugagan';

  @override
  String whMinShort(String value) {
    return 'Min: $value';
  }

  @override
  String whAvgPerUnit(String price, String unit) {
    return '$price / $unit';
  }

  @override
  String get whNewTitle => 'Yangi masalliq';

  @override
  String get whEditTitle => 'Masalliqni tahrirlash';

  @override
  String get whName => 'Nomi';

  @override
  String get whNameHint => 'Masalan: Pomidor';

  @override
  String get whNameRequired => 'Nomini kiriting';

  @override
  String get whUnit => 'O\'lchov birligi';

  @override
  String get whUnitHint =>
      'Keyin o\'zgartirib bo\'lmaydi — retseptlar va tarix shu birlikda.';

  @override
  String get whUnitLocked => 'O\'lchov birligini o\'zgartirib bo\'lmaydi.';

  @override
  String whMinStock(String unit) {
    return 'Minimal qoldiq ($unit)';
  }

  @override
  String get whMinStockHint =>
      'Qoldiq shu miqdorga tushsa, \"kam qoldi\" deb ko\'rsatiladi.';

  @override
  String get whOpeningTitle => 'Hozir bor qoldiq';

  @override
  String get whOpeningHint =>
      'Ixtiyoriy. Narxsiz qoldiq tannarxi noma\'lum bo\'lib qoladi.';

  @override
  String whStockOnHand(String unit) {
    return 'Hozirgi qoldiq ($unit)';
  }

  @override
  String whPricePerUnit(String unit) {
    return '1 $unit narxi (so\'m)';
  }

  @override
  String get whPriceNeedsStock =>
      'Narx faqat qoldiq bilan saqlanadi — avval qoldiqni kiriting';

  @override
  String get whActiveHint =>
      'Nofaol masalliq mavjud retseptlarda ishlayveradi.';

  @override
  String get whAmountInvalid =>
      'Miqdorni to\'g\'ri kiriting (4 xonagacha kasr)';

  @override
  String get whAmountPositive => 'Miqdor 0 dan katta bo\'lishi kerak';

  @override
  String get whPriceInvalid => 'Narxni to\'g\'ri kiriting';

  @override
  String get whInStock => 'Hozirgi qoldiq';

  @override
  String get whNegativeHint =>
      'Oshxona qayd etilganidan ko\'proq ishlatgan — kirim yoki sanoq qiling';

  @override
  String get whNoCost => 'Narxi noma\'lum';

  @override
  String whValue(String value) {
    return 'Qiymati: $value';
  }

  @override
  String get whAvgCost => 'O\'rtacha narx';

  @override
  String get whReceiveShort => 'Kirim';

  @override
  String get whAdjustShort => 'Sanoq / chiqarish';

  @override
  String get whUsedIn => 'Retseptlarda';

  @override
  String whPerPortionValue(String value) {
    return '$value / porsiya';
  }

  @override
  String get whHistory => 'Harakatlar tarixi';

  @override
  String get whHistoryEmpty => 'Hali harakat yo\'q';

  @override
  String get whShowMore => 'Yana ko\'rsatish';

  @override
  String get whReversed => 'qaytarilgan';

  @override
  String whBalance(String value) {
    return 'Qoldiq: $value';
  }

  @override
  String get whMoveReceipt => 'Kirim';

  @override
  String get whMoveUsage => 'Taomga ketdi';

  @override
  String get whMoveRestore => 'Qaytarildi (bekor qilingan)';

  @override
  String get whMoveAdjustment => 'Sanoq tuzatishi';

  @override
  String get whMoveWaste => 'Hisobdan chiqarildi';

  @override
  String get whDeleteTitle => 'Masalliqni o\'chirish';

  @override
  String whDeleteConfirm(String name) {
    return '\"$name\" ombordan o\'chiriladi. Tarixi saqlanib qoladi.';
  }

  @override
  String whDeleteInRecipes(int count) {
    return 'Bu masalliq $count ta retseptda ishlatilgan. Avval retseptlardan olib tashlang.';
  }

  @override
  String whDeleted(String name) {
    return '$name o\'chirildi';
  }

  @override
  String whReceiveTitle(String name) {
    return 'Kirim: $name';
  }

  @override
  String whReceiveQty(String unit) {
    return 'Kelgan miqdor ($unit)';
  }

  @override
  String get whPriceTotal => 'Umumiy summa';

  @override
  String get whPriceSom => 'Narx (so\'m)';

  @override
  String whAfterReceipt(String stock) {
    return 'Kirimdan keyin: $stock';
  }

  @override
  String whPriceSummary(String unitPrice, String unit, String total) {
    return '$unitPrice / $unit, jami $total';
  }

  @override
  String get whReceiveNoteHint => 'Masalan: bozordan';

  @override
  String get whReceiveSubmit => 'Kirimni saqlash';

  @override
  String whReceiveDone(String name) {
    return '$name kirimi saqlandi';
  }

  @override
  String whAdjustTitle(String name) {
    return '$name: qoldiq';
  }

  @override
  String get whCount => 'Sanoq';

  @override
  String get whWaste => 'Hisobdan chiqarish';

  @override
  String get whCountHint =>
      'Sanab chiqqan miqdoringizni kiriting — qoldiq shunga tenglanadi.';

  @override
  String get whWasteHint =>
      'Buzilgan yoki tashlangan miqdorni kiriting — qoldiqdan ayriladi.';

  @override
  String whCounted(String unit) {
    return 'Sanalgan miqdor ($unit)';
  }

  @override
  String whWasted(String unit) {
    return 'Chiqariladigan miqdor ($unit)';
  }

  @override
  String get whCountSame => 'Qoldiq bilan bir xil — o\'zgarish yo\'q';

  @override
  String whChange(String value) {
    return 'O\'zgarish: $value';
  }

  @override
  String get whWasteNoteHint => 'Masalan: chirib qolgan';

  @override
  String get whCountDone => 'Qoldiq tuzatildi';

  @override
  String get whWasteDone => 'Hisobdan chiqarildi';

  @override
  String whPortions(int count) {
    return '$count porsiya';
  }

  @override
  String get whDishOk => 'Tayyorlash mumkin';

  @override
  String get whDishUnavailable => 'Masalliq yetmaydi';

  @override
  String whDishLowPortions(int count) {
    return '$count porsiya qoldi';
  }

  @override
  String whUnavailableBanner(int count) {
    return '$count ta taomni hozir tayyorlab bo\'lmaydi — masalliq yetmaydi. Omborga kirim qiling yoki menyudan vaqtincha olib qo\'ying.';
  }

  @override
  String get whDishesEmpty =>
      'Menyuda taom yo\'q. Avval Mahsulotlar bo\'limida taom qo\'shing.';

  @override
  String get whNoRecipe => 'Retsept yo\'q';

  @override
  String whIngredientCount(int count) {
    return '$count ta masalliq';
  }

  @override
  String whShortLine(String name, String short) {
    return '$name: $short yetmaydi';
  }

  @override
  String get whCostUnknown => 'Narxi noma\'lum masalliq bor';

  @override
  String whPortionCostValue(String value) {
    return 'Tannarx $value';
  }

  @override
  String whPriceValue(String value) {
    return 'narx $value';
  }

  @override
  String whMarginValue(int percent) {
    return 'foyda $percent%';
  }

  @override
  String whRecipeTitle(String name) {
    return 'Retsept: $name';
  }

  @override
  String get whRecipeHint =>
      'Bir porsiya uchun masalliqlar. Taom oshxonaga yuborilganda yoki kassada sotilganda shular ombordan ayriladi.';

  @override
  String get whRecipeNoIngredients =>
      'Omborda masalliq yo\'q. Avval Ombor bo\'limida masalliqlarni qo\'shing.';

  @override
  String whLineN(int n) {
    return '$n-masalliq';
  }

  @override
  String get whRemoveLine => 'Qatorni o\'chirish';

  @override
  String get whIngredient => 'Masalliq';

  @override
  String get whPickIngredient => 'Masalliqni tanlang';

  @override
  String get whAlreadyInRecipe => 'Retseptda bor';

  @override
  String get whPerPortionAmount => '1 porsiyaga';

  @override
  String whLineStock(String stock, String need) {
    return 'Omborda $stock, porsiyaga $need';
  }

  @override
  String whLinePortions(int count) {
    return '$count porsiyaga yetadi';
  }

  @override
  String get whLimiting => 'birinchi tugaydi';

  @override
  String get whAddLine => 'Masalliq qo\'shish';

  @override
  String get whRecipeNotes => 'Tayyorlash izohi';

  @override
  String get whCanMakeNow => 'Hozir tayyorlash mumkin';

  @override
  String get whPortionCost => '1 porsiya tannarxi';

  @override
  String get whMenuPrice => 'Menyudagi narx';

  @override
  String get whMargin => 'Foyda';

  @override
  String get whRecipeNeedOne => 'Kamida bitta masalliq qo\'shing';

  @override
  String whRecipeBadQty(String name) {
    return '\"$name\" miqdorini to\'g\'ri kiriting';
  }

  @override
  String get whRecipeSaved => 'Retsept saqlandi';

  @override
  String get whRecipeDelete => 'Retseptni o\'chirish';

  @override
  String get whRecipeDeleteTitle => 'Retseptni o\'chirish';

  @override
  String whRecipeDeleteConfirm(String name) {
    return '\"$name\" retsepti o\'chiriladi. Taom endi ombordan masalliq olmaydi.';
  }

  @override
  String get whRecipeDeleted => 'Retsept o\'chirildi';
}
