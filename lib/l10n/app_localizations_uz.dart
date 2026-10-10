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
}
