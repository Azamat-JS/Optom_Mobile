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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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

  /// No description provided for @commonCancel.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilish'**
  String get commonCancel;

  /// No description provided for @commonRetry.
  ///
  /// In uz, this message translates to:
  /// **'Qayta urinish'**
  String get commonRetry;

  /// No description provided for @commonLogout.
  ///
  /// In uz, this message translates to:
  /// **'Chiqish'**
  String get commonLogout;

  /// No description provided for @commonLogin.
  ///
  /// In uz, this message translates to:
  /// **'Kirish'**
  String get commonLogin;

  /// No description provided for @commonRegister.
  ///
  /// In uz, this message translates to:
  /// **'Ro\'yxatdan o\'tish'**
  String get commonRegister;

  /// No description provided for @commonSettings.
  ///
  /// In uz, this message translates to:
  /// **'Sozlamalar'**
  String get commonSettings;

  /// No description provided for @commonUnknownError.
  ///
  /// In uz, this message translates to:
  /// **'Noma\'lum xatolik yuz berdi.'**
  String get commonUnknownError;

  /// Display name of a user role (UserRole enum name).
  ///
  /// In uz, this message translates to:
  /// **'{role, select, superAdmin{Super Admin} seller{Optomchi} sellerAdmin{Optomchi xodimi} retailer{Do\'konchi} retailerAdmin{Do\'konchi xodimi} customer{Mijoz} waiter{Ofitsiant} courier{Kuryer} other{}}'**
  String roleLabel(String role);

  /// No description provided for @languageTitle.
  ///
  /// In uz, this message translates to:
  /// **'Til'**
  String get languageTitle;

  /// No description provided for @languageHint.
  ///
  /// In uz, this message translates to:
  /// **'Interfeys tilini tanlang'**
  String get languageHint;

  /// No description provided for @languageChange.
  ///
  /// In uz, this message translates to:
  /// **'Tilni o\'zgartirish'**
  String get languageChange;

  /// No description provided for @settingsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Sozlamalar'**
  String get settingsTitle;

  /// No description provided for @settingsAccount.
  ///
  /// In uz, this message translates to:
  /// **'Hisob'**
  String get settingsAccount;

  /// No description provided for @authPhoneLabel.
  ///
  /// In uz, this message translates to:
  /// **'Telefon raqam'**
  String get authPhoneLabel;

  /// No description provided for @authPhoneRequired.
  ///
  /// In uz, this message translates to:
  /// **'Telefon raqam kiritilishi shart'**
  String get authPhoneRequired;

  /// No description provided for @authPhoneFormat.
  ///
  /// In uz, this message translates to:
  /// **'Format: +998XXXXXXXXX'**
  String get authPhoneFormat;

  /// No description provided for @authTagline.
  ///
  /// In uz, this message translates to:
  /// **'Aqlli savdo, yaxlit biznes'**
  String get authTagline;

  /// No description provided for @authEnterNumber.
  ///
  /// In uz, this message translates to:
  /// **'Raqamingizni kiriting'**
  String get authEnterNumber;

  /// No description provided for @authSkip.
  ///
  /// In uz, this message translates to:
  /// **'Keyinroq'**
  String get authSkip;

  /// No description provided for @authOr.
  ///
  /// In uz, this message translates to:
  /// **'yoki'**
  String get authOr;

  /// No description provided for @authClear.
  ///
  /// In uz, this message translates to:
  /// **'Tozalash'**
  String get authClear;

  /// No description provided for @tgVerifyingNumber.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlanadigan raqam'**
  String get tgVerifyingNumber;

  /// No description provided for @loginSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Optom Savdo tizimiga kirish'**
  String get loginSubtitle;

  /// No description provided for @loginContinueWithTelegram.
  ///
  /// In uz, this message translates to:
  /// **'Telegram orqali davom etish'**
  String get loginContinueWithTelegram;

  /// No description provided for @loginAccountAutoCreated.
  ///
  /// In uz, this message translates to:
  /// **'Hisobingiz bo\'lmasa, avtomatik yaratiladi'**
  String get loginAccountAutoCreated;

  /// No description provided for @loginWithPassword.
  ///
  /// In uz, this message translates to:
  /// **'Parol bilan kirish'**
  String get loginWithPassword;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In uz, this message translates to:
  /// **'Parol'**
  String get loginPasswordLabel;

  /// No description provided for @loginPasswordRequired.
  ///
  /// In uz, this message translates to:
  /// **'Parol kiritilishi shart'**
  String get loginPasswordRequired;

  /// No description provided for @loginPasswordMinLength.
  ///
  /// In uz, this message translates to:
  /// **'Kamida 6 ta belgi'**
  String get loginPasswordMinLength;

  /// No description provided for @registerSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Yangi mijoz hisobi yaratish'**
  String get registerSubtitle;

  /// No description provided for @registerHint.
  ///
  /// In uz, this message translates to:
  /// **'Raqamingiz Telegram orqali tasdiqlanadi. Ism-familiyangiz Telegram profilingizdan olinadi — keyin profilda o\'zgartirishingiz mumkin.'**
  String get registerHint;

  /// No description provided for @registerWithTelegram.
  ///
  /// In uz, this message translates to:
  /// **'Telegram orqali ro\'yxatdan o\'tish'**
  String get registerWithTelegram;

  /// No description provided for @registerHaveAccount.
  ///
  /// In uz, this message translates to:
  /// **'Hisobingiz bormi? Kirish'**
  String get registerHaveAccount;

  /// No description provided for @splashError.
  ///
  /// In uz, this message translates to:
  /// **'Ilovani ishga tushirishda xatolik yuz berdi.'**
  String get splashError;

  /// No description provided for @tgTitle.
  ///
  /// In uz, this message translates to:
  /// **'Telegram orqali tasdiqlash'**
  String get tgTitle;

  /// No description provided for @tgOpenFailed.
  ///
  /// In uz, this message translates to:
  /// **'Telegramni ochib bo\'lmadi. Ilova o\'rnatilganini tekshiring.'**
  String get tgOpenFailed;

  /// No description provided for @tgPhoneVerified.
  ///
  /// In uz, this message translates to:
  /// **'Raqamingiz tasdiqlandi ✅'**
  String get tgPhoneVerified;

  /// No description provided for @tgWelcomeNew.
  ///
  /// In uz, this message translates to:
  /// **'Xush kelibsiz! Hisobingiz yaratildi.'**
  String get tgWelcomeNew;

  /// No description provided for @tgWelcome.
  ///
  /// In uz, this message translates to:
  /// **'Xush kelibsiz!'**
  String get tgWelcome;

  /// No description provided for @tgChangePhone.
  ///
  /// In uz, this message translates to:
  /// **'Raqamni o\'zgartirish'**
  String get tgChangePhone;

  /// No description provided for @tgPreparing.
  ///
  /// In uz, this message translates to:
  /// **'Tayyorlanmoqda…'**
  String get tgPreparing;

  /// No description provided for @tgVerified.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlandi'**
  String get tgVerified;

  /// No description provided for @tgVerifiedLoggingIn.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlandi, kirilmoqda…'**
  String get tgVerifiedLoggingIn;

  /// No description provided for @tgFinishStepVerify.
  ///
  /// In uz, this message translates to:
  /// **'Ilovaga qayting — tasdiqlash avtomatik yakunlanadi'**
  String get tgFinishStepVerify;

  /// No description provided for @tgFinishStepLogin.
  ///
  /// In uz, this message translates to:
  /// **'Ilovaga qayting — kirish avtomatik bajariladi'**
  String get tgFinishStepLogin;

  /// No description provided for @tgMismatchTitle.
  ///
  /// In uz, this message translates to:
  /// **'Raqam mos kelmadi'**
  String get tgMismatchTitle;

  /// No description provided for @tgMismatchOwn.
  ///
  /// In uz, this message translates to:
  /// **'Telegram akkauntingizdagi raqam hisobingizdagi {phone} raqamiga mos emas. Shu raqam ulangan Telegram akkauntidan foydalaning.'**
  String tgMismatchOwn(String phone);

  /// No description provided for @tgMismatch.
  ///
  /// In uz, this message translates to:
  /// **'Telegram akkauntingizdagi raqam {phone} raqamiga mos emas. Shu raqam ulangan Telegram akkauntidan foydalaning yoki raqamni o\'zgartiring.'**
  String tgMismatch(String phone);

  /// No description provided for @tgExpiredTitle.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlash muddati tugadi'**
  String get tgExpiredTitle;

  /// No description provided for @tgExpiredMessage.
  ///
  /// In uz, this message translates to:
  /// **'10 daqiqa ichida raqam tasdiqlanmadi. Qaytadan urinib ko\'ring.'**
  String get tgExpiredMessage;

  /// No description provided for @tgFailedTitle.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlab bo\'lmadi'**
  String get tgFailedTitle;

  /// No description provided for @tgConfirmInTelegram.
  ///
  /// In uz, this message translates to:
  /// **'Telegramda tasdiqlang'**
  String get tgConfirmInTelegram;

  /// No description provided for @tgStep1.
  ///
  /// In uz, this message translates to:
  /// **'Telegramda bsmart tasdiqlash boti ochiladi'**
  String get tgStep1;

  /// No description provided for @tgStep2.
  ///
  /// In uz, this message translates to:
  /// **'«Start» tugmasini bosing'**
  String get tgStep2;

  /// No description provided for @tgStep3.
  ///
  /// In uz, this message translates to:
  /// **'«📱 Raqamni tasdiqlash» tugmasini bosing'**
  String get tgStep3;

  /// No description provided for @tgWaiting.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlash kutilmoqda · {countdown}'**
  String tgWaiting(String countdown);

  /// No description provided for @tgOpenTelegram.
  ///
  /// In uz, this message translates to:
  /// **'Telegramni ochish'**
  String get tgOpenTelegram;

  /// No description provided for @verifyBannerAction.
  ///
  /// In uz, this message translates to:
  /// **'Raqamni tasdiqlash'**
  String get verifyBannerAction;

  /// No description provided for @verifyBannerProfile.
  ///
  /// In uz, this message translates to:
  /// **'Restoran yetkazishlarini kuzatish va qarzlaringizni ko\'rish uchun telefon raqamingizni Telegram orqali tasdiqlang.'**
  String get verifyBannerProfile;

  /// No description provided for @verifyBannerDebts.
  ///
  /// In uz, this message translates to:
  /// **'Do\'konlardagi qarzlaringizni ko\'rish uchun telefon raqamingizni Telegram orqali tasdiqlang.'**
  String get verifyBannerDebts;

  /// No description provided for @verifyBannerDeliveries.
  ///
  /// In uz, this message translates to:
  /// **'Restoranga telefon orqali bergan buyurtmalaringizni kuzatish uchun telefon raqamingizni Telegram orqali tasdiqlang.'**
  String get verifyBannerDeliveries;

  /// No description provided for @tgNotifTitle.
  ///
  /// In uz, this message translates to:
  /// **'Telegram bildirishnomalari'**
  String get tgNotifTitle;

  /// No description provided for @tgNotifConnect.
  ///
  /// In uz, this message translates to:
  /// **'Ulash'**
  String get tgNotifConnect;

  /// No description provided for @tgNotifOff.
  ///
  /// In uz, this message translates to:
  /// **'O\'chirilgan'**
  String get tgNotifOff;

  /// No description provided for @tgNotifCustomerEnabled.
  ///
  /// In uz, this message translates to:
  /// **'Kuryer buyurtmani olganda, yetib kelganda va topshirganda xabar keladi'**
  String get tgNotifCustomerEnabled;

  /// No description provided for @tgNotifCustomerLink.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtmangiz yo\'lga chiqqanda xabar olish uchun raqamingizni Telegram orqali tasdiqlang'**
  String get tgNotifCustomerLink;

  /// No description provided for @tgNotifCourierEnabled.
  ///
  /// In uz, this message translates to:
  /// **'Sizga yetkazish biriktirilsa, taklif qilinsa yoki bekor qilinsa xabar keladi'**
  String get tgNotifCourierEnabled;

  /// No description provided for @tgNotifCourierLink.
  ///
  /// In uz, this message translates to:
  /// **'Yangi yetkazishlar haqida Telegram\'da xabar olish uchun raqamingizni tasdiqlang'**
  String get tgNotifCourierLink;

  /// No description provided for @tgNotifLinkTelegram.
  ///
  /// In uz, this message translates to:
  /// **'Telegramni ulash'**
  String get tgNotifLinkTelegram;

  /// No description provided for @tgNotifEnabled.
  ///
  /// In uz, this message translates to:
  /// **'Bildirishnomalar yoqilgan'**
  String get tgNotifEnabled;

  /// No description provided for @tgNotifDisabled.
  ///
  /// In uz, this message translates to:
  /// **'Bildirishnomalar o\'chirilgan'**
  String get tgNotifDisabled;

  /// No description provided for @navCatalog.
  ///
  /// In uz, this message translates to:
  /// **'Katalog'**
  String get navCatalog;

  /// No description provided for @navCart.
  ///
  /// In uz, this message translates to:
  /// **'Savat'**
  String get navCart;

  /// No description provided for @navFavorites.
  ///
  /// In uz, this message translates to:
  /// **'Sevimlilar'**
  String get navFavorites;

  /// No description provided for @navProfile.
  ///
  /// In uz, this message translates to:
  /// **'Profil'**
  String get navProfile;

  /// No description provided for @navMenu.
  ///
  /// In uz, this message translates to:
  /// **'Menyu'**
  String get navMenu;

  /// No description provided for @navDeliveries.
  ///
  /// In uz, this message translates to:
  /// **'Yetkazishlar'**
  String get navDeliveries;

  /// No description provided for @navPos.
  ///
  /// In uz, this message translates to:
  /// **'Kassa'**
  String get navPos;

  /// No description provided for @navOrders.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtmalar'**
  String get navOrders;

  /// No description provided for @navProducts.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulotlar'**
  String get navProducts;

  /// No description provided for @navCustomers.
  ///
  /// In uz, this message translates to:
  /// **'Mijozlar'**
  String get navCustomers;

  /// No description provided for @navSalesHistory.
  ///
  /// In uz, this message translates to:
  /// **'Sotuvlar tarixi'**
  String get navSalesHistory;

  /// No description provided for @navDebts.
  ///
  /// In uz, this message translates to:
  /// **'Qarzlar'**
  String get navDebts;

  /// No description provided for @navReports.
  ///
  /// In uz, this message translates to:
  /// **'Hisobotlar'**
  String get navReports;

  /// No description provided for @navFleetMap.
  ///
  /// In uz, this message translates to:
  /// **'Kuryerlar xaritasi'**
  String get navFleetMap;

  /// No description provided for @navRestaurantOrders.
  ///
  /// In uz, this message translates to:
  /// **'Restoran buyurtmalari'**
  String get navRestaurantOrders;

  /// No description provided for @navTables.
  ///
  /// In uz, this message translates to:
  /// **'Stollar'**
  String get navTables;

  /// No description provided for @navStores.
  ///
  /// In uz, this message translates to:
  /// **'Do\'konlar'**
  String get navStores;

  /// No description provided for @navStaff.
  ///
  /// In uz, this message translates to:
  /// **'Xodimlar'**
  String get navStaff;

  /// No description provided for @navWaiters.
  ///
  /// In uz, this message translates to:
  /// **'Ofitsiantlar'**
  String get navWaiters;

  /// No description provided for @navCouriers.
  ///
  /// In uz, this message translates to:
  /// **'Kuryerlar'**
  String get navCouriers;

  /// No description provided for @navExpenditures.
  ///
  /// In uz, this message translates to:
  /// **'Harajatlarim'**
  String get navExpenditures;

  /// No description provided for @navUsers.
  ///
  /// In uz, this message translates to:
  /// **'Foydalanuvchilar'**
  String get navUsers;

  /// No description provided for @navCategories.
  ///
  /// In uz, this message translates to:
  /// **'Kategoriyalar'**
  String get navCategories;

  /// No description provided for @navCatalogModeration.
  ///
  /// In uz, this message translates to:
  /// **'Katalog nazorati'**
  String get navCatalogModeration;

  /// No description provided for @profileLoginPrompt.
  ///
  /// In uz, this message translates to:
  /// **'Profilni koʻrish uchun tizimga kiring'**
  String get profileLoginPrompt;

  /// No description provided for @profilePhoneVerified.
  ///
  /// In uz, this message translates to:
  /// **'Raqam tasdiqlangan'**
  String get profilePhoneVerified;

  /// No description provided for @profileMyOrders.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtmalarim'**
  String get profileMyOrders;

  /// No description provided for @profileMyDeliveries.
  ///
  /// In uz, this message translates to:
  /// **'Yetkazishlarim'**
  String get profileMyDeliveries;

  /// No description provided for @profileMyDebts.
  ///
  /// In uz, this message translates to:
  /// **'Qarzlarim'**
  String get profileMyDebts;

  /// No description provided for @homeWelcome.
  ///
  /// In uz, this message translates to:
  /// **'Xush kelibsiz, {name}'**
  String homeWelcome(String name);

  /// No description provided for @homeStatistics.
  ///
  /// In uz, this message translates to:
  /// **'Statistika'**
  String get homeStatistics;

  /// No description provided for @homeStatsLoadFailed.
  ///
  /// In uz, this message translates to:
  /// **'Statistikani yuklab bo\'lmadi'**
  String get homeStatsLoadFailed;

  /// No description provided for @homeTodaySales.
  ///
  /// In uz, this message translates to:
  /// **'Bugungi savdo'**
  String get homeTodaySales;

  /// No description provided for @homeTotalSales.
  ///
  /// In uz, this message translates to:
  /// **'Jami savdo'**
  String get homeTotalSales;

  /// No description provided for @homeSalesCount.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta savdo'**
  String homeSalesCount(int count);

  /// No description provided for @homeOutstandingDebt.
  ///
  /// In uz, this message translates to:
  /// **'Qarzdorlik'**
  String get homeOutstandingDebt;

  /// No description provided for @homeReceivedPayments.
  ///
  /// In uz, this message translates to:
  /// **'Qabul qilingan to\'lovlar'**
  String get homeReceivedPayments;

  /// No description provided for @homeCustomerDebts.
  ///
  /// In uz, this message translates to:
  /// **'Mijoz qarzlari'**
  String get homeCustomerDebts;

  /// No description provided for @homeWholesalerDebts.
  ///
  /// In uz, this message translates to:
  /// **'Optomchi qarzlari'**
  String get homeWholesalerDebts;

  /// No description provided for @enumOrderStatus.
  ///
  /// In uz, this message translates to:
  /// **'{status, select, newOrder{Yangi} approved{Tasdiqlangan} rejected{Rad etilgan} delivered{Yetkazilgan} debtRecorded{Qarzga yozilgan} paid{To\'langan} other{}}'**
  String enumOrderStatus(String status);

  /// No description provided for @enumPaymentMethod.
  ///
  /// In uz, this message translates to:
  /// **'{method, select, cash{Naqd} card{Karta} bankTransfer{Bank o\'tkazmasi} click{Click} payme{Payme} debt{Qarzga} other{}}'**
  String enumPaymentMethod(String method);

  /// No description provided for @enumBusinessType.
  ///
  /// In uz, this message translates to:
  /// **'{type, select, general{Do\'kon} restaurant{Restoran} applianceStore{Maishiy texnika} constructionTools{Qurilish mollari} toyStore{O\'yinchoqlar} autoParts{Avto ehtiyot qismlar} pharmacy{Dorixona} clothingStore{Kiyim-kechak} other{}}'**
  String enumBusinessType(String type);

  /// No description provided for @enumExpenditureType.
  ///
  /// In uz, this message translates to:
  /// **'{type, select, electricity{Elektr energiyasi} gas{Gaz} water{Suv} taxes{Soliqlar} renting{Ijara} other{Boshqa}}'**
  String enumExpenditureType(String type);

  /// No description provided for @enumProductUnit.
  ///
  /// In uz, this message translates to:
  /// **'{unit, select, dona{Dona} metr{Metr} litr{Litr} kilogram{Kilogramm} gram{Gramm} blok{Blok} other{}}'**
  String enumProductUnit(String unit);

  /// No description provided for @enumRestaurantOrderType.
  ///
  /// In uz, this message translates to:
  /// **'{type, select, dineIn{Zalda} delivery{Yetkazib berish} other{}}'**
  String enumRestaurantOrderType(String type);

  /// No description provided for @enumRestaurantOrderStatus.
  ///
  /// In uz, this message translates to:
  /// **'{status, select, newOrder{Yangi} preparing{Tayyorlanmoqda} ready{Tayyor} served{Berildi} delivered{Yetkazildi} cancelled{Bekor qilindi} other{}}'**
  String enumRestaurantOrderStatus(String status);

  /// No description provided for @enumSaleType.
  ///
  /// In uz, this message translates to:
  /// **'{type, select, paid{To\'langan} debt{Qarzga} other{}}'**
  String enumSaleType(String type);

  /// No description provided for @enumSaleStatus.
  ///
  /// In uz, this message translates to:
  /// **'{status, select, completed{Yakunlangan} cancelled{Bekor qilingan} partiallyReturned{Qisman qaytarilgan} returned{Qaytarilgan} other{}}'**
  String enumSaleStatus(String status);

  /// No description provided for @enumDebtStatus.
  ///
  /// In uz, this message translates to:
  /// **'{status, select, active{Faol} partial{Qisman to\'langan} settled{To\'langan} overdue{Muddati o\'tgan} writtenOff{Bekor qilingan} other{}}'**
  String enumDebtStatus(String status);

  /// No description provided for @currencySom.
  ///
  /// In uz, this message translates to:
  /// **'so\'m'**
  String get currencySom;

  /// No description provided for @errorSessionExpired.
  ///
  /// In uz, this message translates to:
  /// **'Sessiya tugagan, qayta kiring.'**
  String get errorSessionExpired;

  /// No description provided for @errorForbidden.
  ///
  /// In uz, this message translates to:
  /// **'Bu amalni bajarishga ruxsat yo\'q.'**
  String get errorForbidden;

  /// No description provided for @errorNotFound.
  ///
  /// In uz, this message translates to:
  /// **'Topilmadi.'**
  String get errorNotFound;

  /// No description provided for @errorConflict.
  ///
  /// In uz, this message translates to:
  /// **'Amalni bajarib bo\'lmadi, ziddiyat mavjud.'**
  String get errorConflict;

  /// No description provided for @errorNoInternet.
  ///
  /// In uz, this message translates to:
  /// **'Internet aloqasi yo\'q.'**
  String get errorNoInternet;

  /// No description provided for @errorInvalidData.
  ///
  /// In uz, this message translates to:
  /// **'Ma\'lumotlar noto\'g\'ri kiritildi.'**
  String get errorInvalidData;

  /// No description provided for @tgTooManyAttempts.
  ///
  /// In uz, this message translates to:
  /// **'Bu raqam uchun urinishlar juda ko\'p. Birozdan so\'ng qayta urinib ko\'ring.'**
  String get tgTooManyAttempts;

  /// No description provided for @tgUnavailable.
  ///
  /// In uz, this message translates to:
  /// **'Telegram orqali tasdiqlash vaqtincha ishlamayapti. Keyinroq urinib ko\'ring.'**
  String get tgUnavailable;

  /// No description provided for @tgInvalidPhone.
  ///
  /// In uz, this message translates to:
  /// **'Telefon raqam noto\'g\'ri. Format: +998XXXXXXXXX'**
  String get tgInvalidPhone;

  /// No description provided for @commonSave.
  ///
  /// In uz, this message translates to:
  /// **'Saqlash'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In uz, this message translates to:
  /// **'O\'chirish'**
  String get commonDelete;

  /// No description provided for @commonAdd.
  ///
  /// In uz, this message translates to:
  /// **'Qo\'shish'**
  String get commonAdd;

  /// No description provided for @commonEdit.
  ///
  /// In uz, this message translates to:
  /// **'Tahrirlash'**
  String get commonEdit;

  /// No description provided for @commonActive.
  ///
  /// In uz, this message translates to:
  /// **'Faol'**
  String get commonActive;

  /// No description provided for @commonInactive.
  ///
  /// In uz, this message translates to:
  /// **'Faol emas'**
  String get commonInactive;

  /// No description provided for @commonAll.
  ///
  /// In uz, this message translates to:
  /// **'Barchasi'**
  String get commonAll;

  /// No description provided for @commonNone.
  ///
  /// In uz, this message translates to:
  /// **'Yo\'q'**
  String get commonNone;

  /// No description provided for @commonNotSelected.
  ///
  /// In uz, this message translates to:
  /// **'Tanlanmagan'**
  String get commonNotSelected;

  /// No description provided for @commonNotSelectedDash.
  ///
  /// In uz, this message translates to:
  /// **'— Tanlanmagan —'**
  String get commonNotSelectedDash;

  /// No description provided for @commonErrorWith.
  ///
  /// In uz, this message translates to:
  /// **'Xatolik: {error}'**
  String commonErrorWith(String error);

  /// No description provided for @commonNothingFound.
  ///
  /// In uz, this message translates to:
  /// **'Hech narsa topilmadi'**
  String get commonNothingFound;

  /// No description provided for @commonReject.
  ///
  /// In uz, this message translates to:
  /// **'Rad etish'**
  String get commonReject;

  /// No description provided for @commonReasonOptional.
  ///
  /// In uz, this message translates to:
  /// **'Sababi (ixtiyoriy)'**
  String get commonReasonOptional;

  /// No description provided for @commonName.
  ///
  /// In uz, this message translates to:
  /// **'Nomi'**
  String get commonName;

  /// No description provided for @commonNameRequired.
  ///
  /// In uz, this message translates to:
  /// **'Nomi *'**
  String get commonNameRequired;

  /// No description provided for @commonNameMissing.
  ///
  /// In uz, this message translates to:
  /// **'Nomini kiriting'**
  String get commonNameMissing;

  /// No description provided for @commonDescription.
  ///
  /// In uz, this message translates to:
  /// **'Tavsif'**
  String get commonDescription;

  /// No description provided for @commonCategory.
  ///
  /// In uz, this message translates to:
  /// **'Kategoriya'**
  String get commonCategory;

  /// No description provided for @commonBrand.
  ///
  /// In uz, this message translates to:
  /// **'Brend'**
  String get commonBrand;

  /// No description provided for @commonBarcode.
  ///
  /// In uz, this message translates to:
  /// **'Shtrix-kod'**
  String get commonBarcode;

  /// No description provided for @commonPrice.
  ///
  /// In uz, this message translates to:
  /// **'Narx'**
  String get commonPrice;

  /// No description provided for @commonPriceRequired.
  ///
  /// In uz, this message translates to:
  /// **'Narx *'**
  String get commonPriceRequired;

  /// No description provided for @commonCostPrice.
  ///
  /// In uz, this message translates to:
  /// **'Tannarx'**
  String get commonCostPrice;

  /// No description provided for @commonStock.
  ///
  /// In uz, this message translates to:
  /// **'Zaxira'**
  String get commonStock;

  /// No description provided for @commonUnit.
  ///
  /// In uz, this message translates to:
  /// **'O\'lchov birligi'**
  String get commonUnit;

  /// No description provided for @commonCurrency.
  ///
  /// In uz, this message translates to:
  /// **'Valyuta'**
  String get commonCurrency;

  /// No description provided for @commonCurrencyRequired.
  ///
  /// In uz, this message translates to:
  /// **'Valyuta *'**
  String get commonCurrencyRequired;

  /// No description provided for @currencyUzsLong.
  ///
  /// In uz, this message translates to:
  /// **'So\'m (UZS)'**
  String get currencyUzsLong;

  /// No description provided for @currencyUsdLong.
  ///
  /// In uz, this message translates to:
  /// **'Dollar (USD)'**
  String get currencyUsdLong;

  /// No description provided for @commonQuantityRequired.
  ///
  /// In uz, this message translates to:
  /// **'Miqdor kiritilishi shart'**
  String get commonQuantityRequired;

  /// No description provided for @productsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulotlar'**
  String get productsTitle;

  /// No description provided for @productsProduct.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulot'**
  String get productsProduct;

  /// No description provided for @productsSentToCatalog.
  ///
  /// In uz, this message translates to:
  /// **'Ko\'rib chiqish uchun katalogga yuborildi'**
  String get productsSentToCatalog;

  /// No description provided for @productsDeleteTitle.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulotni o\'chirish'**
  String get productsDeleteTitle;

  /// No description provided for @productsDeleteConfirm.
  ///
  /// In uz, this message translates to:
  /// **'Bu mahsulotni o\'chirishni tasdiqlaysizmi?'**
  String get productsDeleteConfirm;

  /// No description provided for @productsCostPriceWith.
  ///
  /// In uz, this message translates to:
  /// **'Tannarx: {price}'**
  String productsCostPriceWith(String price);

  /// No description provided for @productsAddStock.
  ///
  /// In uz, this message translates to:
  /// **'Zaxira qo\'shish'**
  String get productsAddStock;

  /// No description provided for @productsCreateBarcode.
  ///
  /// In uz, this message translates to:
  /// **'Barkod yaratish'**
  String get productsCreateBarcode;

  /// No description provided for @productsShareToCatalog.
  ///
  /// In uz, this message translates to:
  /// **'Katalogga ulashish'**
  String get productsShareToCatalog;

  /// No description provided for @productsNameOrCatalog.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulot nomini kiriting yoki katalogdan tanlang'**
  String get productsNameOrCatalog;

  /// No description provided for @productsPriceInvalid.
  ///
  /// In uz, this message translates to:
  /// **'Narx noto\'g\'ri kiritildi'**
  String get productsPriceInvalid;

  /// No description provided for @productsEditTitle.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulotni tahrirlash'**
  String get productsEditTitle;

  /// No description provided for @productsNewTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yangi mahsulot'**
  String get productsNewTitle;

  /// No description provided for @productsPriceRequired.
  ///
  /// In uz, this message translates to:
  /// **'Narx kiritilishi shart'**
  String get productsPriceRequired;

  /// No description provided for @productsInitialStock.
  ///
  /// In uz, this message translates to:
  /// **'Boshlang\'ich zaxira'**
  String get productsInitialStock;

  /// No description provided for @productsStockEditHint.
  ///
  /// In uz, this message translates to:
  /// **'{stock} — o\'zgartirish uchun mahsulot sahifasidagi \"Zaxira qo\'shish\" tugmasini ishlating'**
  String productsStockEditHint(String stock);

  /// No description provided for @productsPluSuggest.
  ///
  /// In uz, this message translates to:
  /// **'Taklif'**
  String get productsPluSuggest;

  /// No description provided for @productsExpiryOptional.
  ///
  /// In uz, this message translates to:
  /// **'Yaroqlilik muddati (ixtiyoriy)'**
  String get productsExpiryOptional;

  /// No description provided for @productsPickFromCatalog.
  ///
  /// In uz, this message translates to:
  /// **'Katalogdan tanlash'**
  String get productsPickFromCatalog;

  /// No description provided for @productsNameRequired.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulot nomi *'**
  String get productsNameRequired;

  /// No description provided for @productsFindTitle.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulotni topish'**
  String get productsFindTitle;

  /// No description provided for @productsSearchHint.
  ///
  /// In uz, this message translates to:
  /// **'Nomi yoki shtrix-kod bo\'yicha qidirish...'**
  String get productsSearchHint;

  /// No description provided for @productsNotFound.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulotlar topilmadi'**
  String get productsNotFound;

  /// No description provided for @productsCurrentStock.
  ///
  /// In uz, this message translates to:
  /// **'Joriy zaxira: {stock}'**
  String productsCurrentStock(String stock);

  /// No description provided for @productsAddQuantity.
  ///
  /// In uz, this message translates to:
  /// **'Qo\'shiladigan miqdor'**
  String get productsAddQuantity;

  /// No description provided for @productsCorrectionOptional.
  ///
  /// In uz, this message translates to:
  /// **'Qo\'shimcha tuzatish (ixtiyoriy)'**
  String get productsCorrectionOptional;

  /// No description provided for @productsCorrectionHint.
  ///
  /// In uz, this message translates to:
  /// **'Manfiy son ham kiritish mumkin'**
  String get productsCorrectionHint;

  /// No description provided for @commonConfirm.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlash'**
  String get commonConfirm;

  /// No description provided for @commonDone.
  ///
  /// In uz, this message translates to:
  /// **'Tayyor'**
  String get commonDone;

  /// No description provided for @commonSearchHint.
  ///
  /// In uz, this message translates to:
  /// **'Qidirish...'**
  String get commonSearchHint;

  /// No description provided for @commonInactiveShort.
  ///
  /// In uz, this message translates to:
  /// **'Faolsiz'**
  String get commonInactiveShort;

  /// No description provided for @commonDeleteWithDependentsConfirm.
  ///
  /// In uz, this message translates to:
  /// **'{name} o\'chirilsinmi? Unga bog\'liq mahsulotlar bo\'lsa, xatolik qaytadi.'**
  String commonDeleteWithDependentsConfirm(String name);

  /// No description provided for @masterStatusPending.
  ///
  /// In uz, this message translates to:
  /// **'Kutilmoqda'**
  String get masterStatusPending;

  /// No description provided for @masterStatusApproved.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlangan'**
  String get masterStatusApproved;

  /// No description provided for @masterStatusRejected.
  ///
  /// In uz, this message translates to:
  /// **'Rad etilgan'**
  String get masterStatusRejected;

  /// No description provided for @masterDeleteTitle.
  ///
  /// In uz, this message translates to:
  /// **'Katalog yozuvini o\'chirish'**
  String get masterDeleteTitle;

  /// No description provided for @masterReviewTitle.
  ///
  /// In uz, this message translates to:
  /// **'Katalog nazorati'**
  String get masterReviewTitle;

  /// No description provided for @masterEditTitle.
  ///
  /// In uz, this message translates to:
  /// **'Katalog yozuvini tahrirlash'**
  String get masterEditTitle;

  /// No description provided for @masterNewTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yangi katalog yozuvi'**
  String get masterNewTitle;

  /// No description provided for @masterActiveVisible.
  ///
  /// In uz, this message translates to:
  /// **'Faol (katalogda ko\'rinadi)'**
  String get masterActiveVisible;

  /// No description provided for @masterSearchHint.
  ///
  /// In uz, this message translates to:
  /// **'Katalogdan qidirish...'**
  String get masterSearchHint;

  /// No description provided for @categoriesDeleteTitle.
  ///
  /// In uz, this message translates to:
  /// **'Kategoriyani o\'chirish'**
  String get categoriesDeleteTitle;

  /// No description provided for @categoriesTitle.
  ///
  /// In uz, this message translates to:
  /// **'Kategoriyalar'**
  String get categoriesTitle;

  /// No description provided for @categoriesNotFound.
  ///
  /// In uz, this message translates to:
  /// **'Kategoriyalar topilmadi'**
  String get categoriesNotFound;

  /// No description provided for @categoriesEditTitle.
  ///
  /// In uz, this message translates to:
  /// **'Kategoriyani tahrirlash'**
  String get categoriesEditTitle;

  /// No description provided for @categoriesNewTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yangi kategoriya'**
  String get categoriesNewTitle;

  /// No description provided for @categoriesParent.
  ///
  /// In uz, this message translates to:
  /// **'Ota kategoriya'**
  String get categoriesParent;

  /// No description provided for @categoriesNoParent.
  ///
  /// In uz, this message translates to:
  /// **'— Yo\'q (asosiy kategoriya) —'**
  String get categoriesNoParent;

  /// No description provided for @categoriesSortOrder.
  ///
  /// In uz, this message translates to:
  /// **'Tartib raqami'**
  String get categoriesSortOrder;

  /// No description provided for @categoriesPickerNotFound.
  ///
  /// In uz, this message translates to:
  /// **'Kategoriya topilmadi'**
  String get categoriesPickerNotFound;

  /// No description provided for @commonDeactivate.
  ///
  /// In uz, this message translates to:
  /// **'Faolsizlantirish'**
  String get commonDeactivate;

  /// No description provided for @commonFirstNameRequired.
  ///
  /// In uz, this message translates to:
  /// **'Ism *'**
  String get commonFirstNameRequired;

  /// No description provided for @commonFirstNameMissing.
  ///
  /// In uz, this message translates to:
  /// **'Ismni kiriting'**
  String get commonFirstNameMissing;

  /// No description provided for @commonLastNameRequired.
  ///
  /// In uz, this message translates to:
  /// **'Familiya *'**
  String get commonLastNameRequired;

  /// No description provided for @commonLastNameMissing.
  ///
  /// In uz, this message translates to:
  /// **'Familiyani kiriting'**
  String get commonLastNameMissing;

  /// No description provided for @commonPhoneRequired.
  ///
  /// In uz, this message translates to:
  /// **'Telefon *'**
  String get commonPhoneRequired;

  /// No description provided for @commonPhoneMissing.
  ///
  /// In uz, this message translates to:
  /// **'Telefon raqamini kiriting'**
  String get commonPhoneMissing;

  /// No description provided for @commonInvalidFormat.
  ///
  /// In uz, this message translates to:
  /// **'Noto\'g\'ri format'**
  String get commonInvalidFormat;

  /// No description provided for @commonAddress.
  ///
  /// In uz, this message translates to:
  /// **'Manzil'**
  String get commonAddress;

  /// No description provided for @commonNote.
  ///
  /// In uz, this message translates to:
  /// **'Izoh'**
  String get commonNote;

  /// No description provided for @commonTotal.
  ///
  /// In uz, this message translates to:
  /// **'Jami'**
  String get commonTotal;

  /// No description provided for @commonSubtotal.
  ///
  /// In uz, this message translates to:
  /// **'Oraliq summa'**
  String get commonSubtotal;

  /// No description provided for @commonDiscount.
  ///
  /// In uz, this message translates to:
  /// **'Chegirma'**
  String get commonDiscount;

  /// No description provided for @commonPieces.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta'**
  String commonPieces(String count);

  /// No description provided for @commonProductCount.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta mahsulot'**
  String commonProductCount(int count);

  /// No description provided for @commonProducts.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulotlar'**
  String get commonProducts;

  /// No description provided for @commonDeliveryAddress.
  ///
  /// In uz, this message translates to:
  /// **'Yetkazib berish manzili'**
  String get commonDeliveryAddress;

  /// No description provided for @customersDeactivateTitle.
  ///
  /// In uz, this message translates to:
  /// **'Mijozni faolsizlantirish'**
  String get customersDeactivateTitle;

  /// No description provided for @customersDeactivateConfirm.
  ///
  /// In uz, this message translates to:
  /// **'{name} faolsizlantirilsinmi?'**
  String customersDeactivateConfirm(String name);

  /// No description provided for @customersTitle.
  ///
  /// In uz, this message translates to:
  /// **'Mijozlar'**
  String get customersTitle;

  /// No description provided for @customersSearchHint.
  ///
  /// In uz, this message translates to:
  /// **'Ism yoki telefon bo\'yicha qidirish...'**
  String get customersSearchHint;

  /// No description provided for @customersNotFound.
  ///
  /// In uz, this message translates to:
  /// **'Mijozlar topilmadi'**
  String get customersNotFound;

  /// No description provided for @customersEditTitle.
  ///
  /// In uz, this message translates to:
  /// **'Mijozni tahrirlash'**
  String get customersEditTitle;

  /// No description provided for @customersNewTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yangi mijoz'**
  String get customersNewTitle;

  /// No description provided for @ordersSingleCurrency.
  ///
  /// In uz, this message translates to:
  /// **'Bitta buyurtmada faqat bitta valyutadagi mahsulotlar bo\'lishi mumkin'**
  String get ordersSingleCurrency;

  /// No description provided for @ordersAddedToCart.
  ///
  /// In uz, this message translates to:
  /// **'{name} savatga qo\'shildi'**
  String ordersAddedToCart(String name);

  /// No description provided for @ordersSearchProduct.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulot qidirish...'**
  String get ordersSearchProduct;

  /// No description provided for @ordersAllBranches.
  ///
  /// In uz, this message translates to:
  /// **'Barcha filiallar'**
  String get ordersAllBranches;

  /// No description provided for @ordersCartSummary.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta mahsulot — {total}'**
  String ordersCartSummary(int count, String total);

  /// No description provided for @ordersPickWholesaler.
  ///
  /// In uz, this message translates to:
  /// **'Optomchini tanlang'**
  String get ordersPickWholesaler;

  /// No description provided for @ordersNoWholesalers.
  ///
  /// In uz, this message translates to:
  /// **'Optomchilar topilmadi'**
  String get ordersNoWholesalers;

  /// No description provided for @ordersIncomingTitle.
  ///
  /// In uz, this message translates to:
  /// **'Kelgan buyurtmalar'**
  String get ordersIncomingTitle;

  /// No description provided for @ordersMineTitle.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtmalarim'**
  String get ordersMineTitle;

  /// No description provided for @ordersTabOutgoing.
  ///
  /// In uz, this message translates to:
  /// **'Chiqarilgan'**
  String get ordersTabOutgoing;

  /// No description provided for @ordersTabIncoming.
  ///
  /// In uz, this message translates to:
  /// **'Kelgan'**
  String get ordersTabIncoming;

  /// No description provided for @ordersNotFound.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtmalar topilmadi'**
  String get ordersNotFound;

  /// No description provided for @ordersReviewTitle.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtmani ko\'rib chiqish'**
  String get ordersReviewTitle;

  /// No description provided for @ordersPlace.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtma berish'**
  String get ordersPlace;

  /// No description provided for @ordersApproveTitle.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtmani tasdiqlash'**
  String get ordersApproveTitle;

  /// No description provided for @ordersApproveConfirm.
  ///
  /// In uz, this message translates to:
  /// **'Bu buyurtmani tasdiqlaysizmi? Mahsulot zaxirasi kamayadi.'**
  String get ordersApproveConfirm;

  /// No description provided for @ordersRejectTitle.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtmani rad etish'**
  String get ordersRejectTitle;

  /// No description provided for @ordersDeliveredTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yetkazib berildi deb belgilash'**
  String get ordersDeliveredTitle;

  /// No description provided for @ordersDeliveredConfirm.
  ///
  /// In uz, this message translates to:
  /// **'Bu buyurtma yetkazib berilganini tasdiqlaysizmi?'**
  String get ordersDeliveredConfirm;

  /// No description provided for @ordersOrder.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtma'**
  String get ordersOrder;

  /// No description provided for @ordersRejectionReason.
  ///
  /// In uz, this message translates to:
  /// **'Rad etilish sababi: {reason}'**
  String ordersRejectionReason(String reason);

  /// No description provided for @ordersSeller.
  ///
  /// In uz, this message translates to:
  /// **'Sotuvchi'**
  String get ordersSeller;

  /// No description provided for @ordersBuyer.
  ///
  /// In uz, this message translates to:
  /// **'Xaridor'**
  String get ordersBuyer;

  /// No description provided for @ordersHistory.
  ///
  /// In uz, this message translates to:
  /// **'Tarix'**
  String get ordersHistory;

  /// No description provided for @ordersDelivered.
  ///
  /// In uz, this message translates to:
  /// **'Yetkazildi'**
  String get ordersDelivered;

  /// No description provided for @commonUnknownPerson.
  ///
  /// In uz, this message translates to:
  /// **'Noma\'lum'**
  String get commonUnknownPerson;

  /// No description provided for @commonAmount.
  ///
  /// In uz, this message translates to:
  /// **'Summa'**
  String get commonAmount;

  /// No description provided for @commonPaymentMethod.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov usuli'**
  String get commonPaymentMethod;

  /// No description provided for @commonNoteOptional.
  ///
  /// In uz, this message translates to:
  /// **'Izoh (ixtiyoriy)'**
  String get commonNoteOptional;

  /// No description provided for @commonClose.
  ///
  /// In uz, this message translates to:
  /// **'Yopish'**
  String get commonClose;

  /// No description provided for @commonDateRequired.
  ///
  /// In uz, this message translates to:
  /// **'Sana *'**
  String get commonDateRequired;

  /// No description provided for @commonTotalWith.
  ///
  /// In uz, this message translates to:
  /// **'Jami: {amount}'**
  String commonTotalWith(String amount);

  /// No description provided for @commonBalanceWith.
  ///
  /// In uz, this message translates to:
  /// **'Qoldiq: {amount}'**
  String commonBalanceWith(String amount);

  /// No description provided for @commonDueWith.
  ///
  /// In uz, this message translates to:
  /// **'Muddat: {date}'**
  String commonDueWith(String date);

  /// No description provided for @expensesEditTitle.
  ///
  /// In uz, this message translates to:
  /// **'Harajatni tahrirlash'**
  String get expensesEditTitle;

  /// No description provided for @expensesNewTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yangi harajat'**
  String get expensesNewTitle;

  /// No description provided for @expensesTypeRequired.
  ///
  /// In uz, this message translates to:
  /// **'Turi *'**
  String get expensesTypeRequired;

  /// No description provided for @expensesAmountRequired.
  ///
  /// In uz, this message translates to:
  /// **'Summasi (so\'m) *'**
  String get expensesAmountRequired;

  /// No description provided for @expensesAmountMissing.
  ///
  /// In uz, this message translates to:
  /// **'Summani kiriting'**
  String get expensesAmountMissing;

  /// No description provided for @expensesAmountInvalid.
  ///
  /// In uz, this message translates to:
  /// **'Noto\'g\'ri summa'**
  String get expensesAmountInvalid;

  /// No description provided for @expensesDeleteTitle.
  ///
  /// In uz, this message translates to:
  /// **'Harajatni o\'chirish'**
  String get expensesDeleteTitle;

  /// No description provided for @expensesDeleteConfirm.
  ///
  /// In uz, this message translates to:
  /// **'{expense} butunlay o\'chirilsinmi?'**
  String expensesDeleteConfirm(String expense);

  /// No description provided for @expensesTitle.
  ///
  /// In uz, this message translates to:
  /// **'Harajatlarim'**
  String get expensesTitle;

  /// No description provided for @expensesFilterByType.
  ///
  /// In uz, this message translates to:
  /// **'Turi bo\'yicha filtr'**
  String get expensesFilterByType;

  /// No description provided for @expensesTotal.
  ///
  /// In uz, this message translates to:
  /// **'Jami xarajat'**
  String get expensesTotal;

  /// No description provided for @expensesNotFound.
  ///
  /// In uz, this message translates to:
  /// **'Harajatlar topilmadi'**
  String get expensesNotFound;

  /// No description provided for @debtsPaymentsApplied.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta qarzga to\'lov qo\'llanildi'**
  String debtsPaymentsApplied(int count);

  /// No description provided for @debtsCloseTitle.
  ///
  /// In uz, this message translates to:
  /// **'Qarzni yopish'**
  String get debtsCloseTitle;

  /// No description provided for @debtsCloseConfirm.
  ///
  /// In uz, this message translates to:
  /// **'Qolgan {amount} to\'liq to\'langan deb belgilansinmi?'**
  String debtsCloseConfirm(String amount);

  /// No description provided for @debtsTotalBalance.
  ///
  /// In uz, this message translates to:
  /// **'Jami qoldiq: {amount}'**
  String debtsTotalBalance(String amount);

  /// No description provided for @debtsPayDownTitle.
  ///
  /// In uz, this message translates to:
  /// **'Umumiy to\'lov (FIFO)'**
  String get debtsPayDownTitle;

  /// No description provided for @debtsPayDownHint.
  ///
  /// In uz, this message translates to:
  /// **'Eng eski qarzdan boshlab avtomatik taqsimlanadi'**
  String get debtsPayDownHint;

  /// No description provided for @debtsAllocation.
  ///
  /// In uz, this message translates to:
  /// **'Taqsimlanishi:'**
  String get debtsAllocation;

  /// No description provided for @debtsWillClose.
  ///
  /// In uz, this message translates to:
  /// **'(yopiladi)'**
  String get debtsWillClose;

  /// No description provided for @debtsExceedsTotal.
  ///
  /// In uz, this message translates to:
  /// **'Summa jami qoldiqdan oshib ketmoqda'**
  String get debtsExceedsTotal;

  /// No description provided for @debtsConfirmPayment.
  ///
  /// In uz, this message translates to:
  /// **'To\'lovni tasdiqlash'**
  String get debtsConfirmPayment;

  /// No description provided for @debtsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Qarzlar'**
  String get debtsTitle;

  /// No description provided for @debtsPayment.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov'**
  String get debtsPayment;

  /// No description provided for @debtsTabCustomers.
  ///
  /// In uz, this message translates to:
  /// **'Mijozlar'**
  String get debtsTabCustomers;

  /// No description provided for @debtsTabOwedToMe.
  ///
  /// In uz, this message translates to:
  /// **'Menga'**
  String get debtsTabOwedToMe;

  /// No description provided for @debtsTabMine.
  ///
  /// In uz, this message translates to:
  /// **'Mening qarzim'**
  String get debtsTabMine;

  /// No description provided for @debtsNotFound.
  ///
  /// In uz, this message translates to:
  /// **'Qarzlar topilmadi'**
  String get debtsNotFound;

  /// No description provided for @debtsCustomerNotFound.
  ///
  /// In uz, this message translates to:
  /// **'Mijoz qarzlari topilmadi'**
  String get debtsCustomerNotFound;

  /// No description provided for @debtsActiveCount.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta faol qarz'**
  String debtsActiveCount(int count);

  /// No description provided for @debtsEnterValidAmount.
  ///
  /// In uz, this message translates to:
  /// **'To\'g\'ri summa kiriting'**
  String get debtsEnterValidAmount;

  /// No description provided for @debtsAmountExceedsBalance.
  ///
  /// In uz, this message translates to:
  /// **'Summa qoldiqdan ({balance}) oshmasligi kerak'**
  String debtsAmountExceedsBalance(String balance);

  /// No description provided for @debtsMakePayment.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov qilish'**
  String get debtsMakePayment;

  /// No description provided for @commonActivate.
  ///
  /// In uz, this message translates to:
  /// **'Faollashtirish'**
  String get commonActivate;

  /// No description provided for @commonDeletePermanentlyConfirm.
  ///
  /// In uz, this message translates to:
  /// **'{name} butunlay o\'chirilsinmi?'**
  String commonDeletePermanentlyConfirm(String name);

  /// No description provided for @commonPasswordRequired.
  ///
  /// In uz, this message translates to:
  /// **'Parol *'**
  String get commonPasswordRequired;

  /// No description provided for @staffDeleteTitle.
  ///
  /// In uz, this message translates to:
  /// **'Xodimni o\'chirish'**
  String get staffDeleteTitle;

  /// No description provided for @staffTitle.
  ///
  /// In uz, this message translates to:
  /// **'Xodimlar'**
  String get staffTitle;

  /// No description provided for @staffNotFound.
  ///
  /// In uz, this message translates to:
  /// **'Xodimlar topilmadi'**
  String get staffNotFound;

  /// No description provided for @staffStoreRequired.
  ///
  /// In uz, this message translates to:
  /// **'Do\'kon tanlanishi shart'**
  String get staffStoreRequired;

  /// No description provided for @staffEditTitle.
  ///
  /// In uz, this message translates to:
  /// **'Xodimni tahrirlash'**
  String get staffEditTitle;

  /// No description provided for @staffNewTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yangi xodim'**
  String get staffNewTitle;

  /// No description provided for @staffStoreLabel.
  ///
  /// In uz, this message translates to:
  /// **'Do\'kon *'**
  String get staffStoreLabel;

  /// No description provided for @storesDeleteTitle.
  ///
  /// In uz, this message translates to:
  /// **'Do\'konni o\'chirish'**
  String get storesDeleteTitle;

  /// No description provided for @storesTitle.
  ///
  /// In uz, this message translates to:
  /// **'Do\'konlar'**
  String get storesTitle;

  /// No description provided for @storesDefault.
  ///
  /// In uz, this message translates to:
  /// **'Asosiy'**
  String get storesDefault;

  /// No description provided for @storesEditTitle.
  ///
  /// In uz, this message translates to:
  /// **'Do\'konni tahrirlash'**
  String get storesEditTitle;

  /// No description provided for @storesNewTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yangi do\'kon'**
  String get storesNewTitle;

  /// No description provided for @storesMapLocation.
  ///
  /// In uz, this message translates to:
  /// **'Xaritadagi joyi'**
  String get storesMapLocation;

  /// No description provided for @storesLocationTitle.
  ///
  /// In uz, this message translates to:
  /// **'Do\'kon joylashuvi'**
  String get storesLocationTitle;

  /// No description provided for @storesLocationHint.
  ///
  /// In uz, this message translates to:
  /// **'Kuryerlar buyurtmani shu yerdan oladi'**
  String get storesLocationHint;

  /// No description provided for @storesHandoverCode.
  ///
  /// In uz, this message translates to:
  /// **'Topshirish kodi'**
  String get storesHandoverCode;

  /// No description provided for @storesHandoverCodeHint.
  ///
  /// In uz, this message translates to:
  /// **'Kuryer buyurtmani topshirishda mijozdan 4 xonali kodni so\'raydi. Ilovasi yoki tasdiqlangan raqami bo\'lmagan mijozdan kod so\'ralmaydi.'**
  String get storesHandoverCodeHint;

  /// No description provided for @commonBalance.
  ///
  /// In uz, this message translates to:
  /// **'Qoldiq'**
  String get commonBalance;

  /// No description provided for @commonPaid.
  ///
  /// In uz, this message translates to:
  /// **'To\'langan'**
  String get commonPaid;

  /// No description provided for @commonOnCredit.
  ///
  /// In uz, this message translates to:
  /// **'Qarzga'**
  String get commonOnCredit;

  /// No description provided for @commonPickCustomer.
  ///
  /// In uz, this message translates to:
  /// **'Mijozni tanlang'**
  String get commonPickCustomer;

  /// No description provided for @commonNew.
  ///
  /// In uz, this message translates to:
  /// **'Yangi'**
  String get commonNew;

  /// No description provided for @posScanProduct.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulotni skanerlash'**
  String get posScanProduct;

  /// No description provided for @posBarcodeNotFound.
  ///
  /// In uz, this message translates to:
  /// **'Bu shtrix-kod bo\'yicha mahsulot topilmadi'**
  String get posBarcodeNotFound;

  /// No description provided for @posSingleCurrency.
  ///
  /// In uz, this message translates to:
  /// **'Bitta sotuvda faqat bitta valyutadagi mahsulotlar bo\'lishi mumkin'**
  String get posSingleCurrency;

  /// No description provided for @posTitle.
  ///
  /// In uz, this message translates to:
  /// **'Kassa'**
  String get posTitle;

  /// No description provided for @posSavedCarts.
  ///
  /// In uz, this message translates to:
  /// **'Saqlangan savatlar'**
  String get posSavedCarts;

  /// No description provided for @posPriceAndStock.
  ///
  /// In uz, this message translates to:
  /// **'{price} · Qoldiq: {stock}'**
  String posPriceAndStock(String price, String stock);

  /// No description provided for @salesPickReturnItem.
  ///
  /// In uz, this message translates to:
  /// **'Qaytariladigan mahsulotni tanlang'**
  String get salesPickReturnItem;

  /// No description provided for @salesReturn.
  ///
  /// In uz, this message translates to:
  /// **'Qaytarish'**
  String get salesReturn;

  /// No description provided for @salesReturnableLeft.
  ///
  /// In uz, this message translates to:
  /// **'Qoldi: {count}'**
  String salesReturnableLeft(String count);

  /// No description provided for @salesRefundMethod.
  ///
  /// In uz, this message translates to:
  /// **'Pulni qaytarish usuli'**
  String get salesRefundMethod;

  /// No description provided for @salesReturnAmount.
  ///
  /// In uz, this message translates to:
  /// **'Qaytariladigan summa: {amount}'**
  String salesReturnAmount(String amount);

  /// No description provided for @salesConfirmReturn.
  ///
  /// In uz, this message translates to:
  /// **'Qaytarishni tasdiqlash'**
  String get salesConfirmReturn;

  /// No description provided for @salesPayment.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov'**
  String get salesPayment;

  /// No description provided for @salesPaidNow.
  ///
  /// In uz, this message translates to:
  /// **'To\'landi'**
  String get salesPaidNow;

  /// No description provided for @salesDownPaymentOptional.
  ///
  /// In uz, this message translates to:
  /// **'Oldindan to\'lov (ixtiyoriy)'**
  String get salesDownPaymentOptional;

  /// No description provided for @salesConfirmWithTotal.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlash — {total}'**
  String salesConfirmWithTotal(String total);

  /// No description provided for @salesHistoryTitle.
  ///
  /// In uz, this message translates to:
  /// **'Sotuvlar tarixi'**
  String get salesHistoryTitle;

  /// No description provided for @salesNotFound.
  ///
  /// In uz, this message translates to:
  /// **'Sotuvlar topilmadi'**
  String get salesNotFound;

  /// No description provided for @salesSale.
  ///
  /// In uz, this message translates to:
  /// **'Sotuv'**
  String get salesSale;

  /// No description provided for @salesCreated.
  ///
  /// In uz, this message translates to:
  /// **'Sotuv yaratildi'**
  String get salesCreated;

  /// No description provided for @salesReturnedQty.
  ///
  /// In uz, this message translates to:
  /// **'qaytarilgan: {count}'**
  String salesReturnedQty(String count);

  /// No description provided for @salesDebt.
  ///
  /// In uz, this message translates to:
  /// **'Qarz'**
  String get salesDebt;

  /// No description provided for @salesPayments.
  ///
  /// In uz, this message translates to:
  /// **'To\'lovlar'**
  String get salesPayments;

  /// No description provided for @salesCustomerSearchHint.
  ///
  /// In uz, this message translates to:
  /// **'Ism yoki telefon...'**
  String get salesCustomerSearchHint;

  /// No description provided for @salesCustomerNotFound.
  ///
  /// In uz, this message translates to:
  /// **'Mijoz topilmadi'**
  String get salesCustomerNotFound;

  /// No description provided for @cartsSaved.
  ///
  /// In uz, this message translates to:
  /// **'Savat saqlandi'**
  String get cartsSaved;

  /// No description provided for @cartsSaveOrClearFirst.
  ///
  /// In uz, this message translates to:
  /// **'Avval joriy savatni saqlang yoki tozalang'**
  String get cartsSaveOrClearFirst;

  /// No description provided for @cartsSkipped.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta mahsulot topilmadi, savatga qo\'shilmadi'**
  String cartsSkipped(int count);

  /// No description provided for @cartsDeleteTitle.
  ///
  /// In uz, this message translates to:
  /// **'Saqlangan savatni o\'chirish'**
  String get cartsDeleteTitle;

  /// No description provided for @cartsDeleteConfirm.
  ///
  /// In uz, this message translates to:
  /// **'Bu amalni ortga qaytarib bo\'lmaydi. Davom etasizmi?'**
  String get cartsDeleteConfirm;

  /// No description provided for @cartsCurrentEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Joriy savat bo\'sh'**
  String get cartsCurrentEmpty;

  /// No description provided for @cartsSaveCurrent.
  ///
  /// In uz, this message translates to:
  /// **'Joriy savatni saqlash ({count} ta)'**
  String cartsSaveCurrent(int count);

  /// No description provided for @cartsNone.
  ///
  /// In uz, this message translates to:
  /// **'Saqlangan savatlar yo\'q'**
  String get cartsNone;

  /// No description provided for @cartsMore.
  ///
  /// In uz, this message translates to:
  /// **'+{count} ta'**
  String cartsMore(int count);

  /// No description provided for @cartsRestore.
  ///
  /// In uz, this message translates to:
  /// **'Qaytarib olish'**
  String get cartsRestore;

  /// No description provided for @commonNoData.
  ///
  /// In uz, this message translates to:
  /// **'Ma\'lumot yo\'q'**
  String get commonNoData;

  /// No description provided for @reportsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Hisobotlar'**
  String get reportsTitle;

  /// No description provided for @reportsTopProducts.
  ///
  /// In uz, this message translates to:
  /// **'Eng ko\'p sotilgan mahsulotlar'**
  String get reportsTopProducts;

  /// No description provided for @reportsStockWith.
  ///
  /// In uz, this message translates to:
  /// **'Zaxira: {stock}'**
  String reportsStockWith(String stock);

  /// No description provided for @reportsStatistics.
  ///
  /// In uz, this message translates to:
  /// **'Statistika'**
  String get reportsStatistics;

  /// No description provided for @reportsRevenue.
  ///
  /// In uz, this message translates to:
  /// **'Tushum'**
  String get reportsRevenue;

  /// No description provided for @reportsNewDebts.
  ///
  /// In uz, this message translates to:
  /// **'Yangi qarzlar'**
  String get reportsNewDebts;

  /// No description provided for @reportsDebtPayments.
  ///
  /// In uz, this message translates to:
  /// **'Qarz to\'lovlari'**
  String get reportsDebtPayments;

  /// No description provided for @reportsOutstanding.
  ///
  /// In uz, this message translates to:
  /// **'Qoldiq qarzdorlik'**
  String get reportsOutstanding;

  /// No description provided for @reportsSalesChart.
  ///
  /// In uz, this message translates to:
  /// **'Savdo grafigi'**
  String get reportsSalesChart;

  /// No description provided for @reportsLast30.
  ///
  /// In uz, this message translates to:
  /// **'So\'nggi 30 kun'**
  String get reportsLast30;

  /// No description provided for @reportsThisMonth.
  ///
  /// In uz, this message translates to:
  /// **'Bu oy'**
  String get reportsThisMonth;

  /// No description provided for @workDayDebtsShareText.
  ///
  /// In uz, this message translates to:
  /// **'Qarzlar ro\'yxati'**
  String get workDayDebtsShareText;

  /// No description provided for @workDayTitle.
  ///
  /// In uz, this message translates to:
  /// **'Ish kuni'**
  String get workDayTitle;

  /// No description provided for @workDayOpen.
  ///
  /// In uz, this message translates to:
  /// **'Ochiq'**
  String get workDayOpen;

  /// No description provided for @workDayClosed.
  ///
  /// In uz, this message translates to:
  /// **'Yopilgan'**
  String get workDayClosed;

  /// No description provided for @workDayNotStarted.
  ///
  /// In uz, this message translates to:
  /// **'Hali ish kuni boshlanmagan'**
  String get workDayNotStarted;

  /// No description provided for @workDayStartedAt.
  ///
  /// In uz, this message translates to:
  /// **'Boshlangan: {time}'**
  String workDayStartedAt(String time);

  /// No description provided for @workDayEndedAt.
  ///
  /// In uz, this message translates to:
  /// **'Tugagan: {time}'**
  String workDayEndedAt(String time);

  /// No description provided for @workDayStart.
  ///
  /// In uz, this message translates to:
  /// **'Ish kunini boshlash'**
  String get workDayStart;

  /// No description provided for @workDayEnd.
  ///
  /// In uz, this message translates to:
  /// **'Ish kunini yakunlash'**
  String get workDayEnd;

  /// No description provided for @workDayExportDebts.
  ///
  /// In uz, this message translates to:
  /// **'Qarzlar (Excel)'**
  String get workDayExportDebts;

  /// No description provided for @dashPaymentCash.
  ///
  /// In uz, this message translates to:
  /// **'Naqd'**
  String get dashPaymentCash;

  /// No description provided for @dashPaymentCard.
  ///
  /// In uz, this message translates to:
  /// **'Karta'**
  String get dashPaymentCard;

  /// No description provided for @dashPaymentBank.
  ///
  /// In uz, this message translates to:
  /// **'Bank'**
  String get dashPaymentBank;

  /// No description provided for @dashPaymentDebt.
  ///
  /// In uz, this message translates to:
  /// **'Qarz'**
  String get dashPaymentDebt;

  /// No description provided for @dashPaymentTypes.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov turlari'**
  String get dashPaymentTypes;

  /// No description provided for @dashIncomeDebt6m.
  ///
  /// In uz, this message translates to:
  /// **'Daromad va qarz (6 oy)'**
  String get dashIncomeDebt6m;

  /// No description provided for @dashIncome.
  ///
  /// In uz, this message translates to:
  /// **'Daromad'**
  String get dashIncome;

  /// No description provided for @dashSalesTrend14d.
  ///
  /// In uz, this message translates to:
  /// **'Savdo dinamikasi (14 kun)'**
  String get dashSalesTrend14d;

  /// No description provided for @scannerTitle.
  ///
  /// In uz, this message translates to:
  /// **'Shtrix-kodni skanerlang'**
  String get scannerTitle;

  /// No description provided for @locationMarkOnMap.
  ///
  /// In uz, this message translates to:
  /// **'Xaritada belgilash'**
  String get locationMarkOnMap;

  /// No description provided for @locationPickTitle.
  ///
  /// In uz, this message translates to:
  /// **'Joyni belgilang'**
  String get locationPickTitle;

  /// No description provided for @locationMarked.
  ///
  /// In uz, this message translates to:
  /// **'Xaritada belgilangan'**
  String get locationMarked;

  /// No description provided for @locationCourierHint.
  ///
  /// In uz, this message translates to:
  /// **'Kuryer aniq joyni topishi uchun'**
  String get locationCourierHint;

  /// No description provided for @locationRemove.
  ///
  /// In uz, this message translates to:
  /// **'Olib tashlash'**
  String get locationRemove;

  /// No description provided for @locationDetectFailed.
  ///
  /// In uz, this message translates to:
  /// **'Joylashuvni aniqlab bo\'lmadi — GPS va ruxsatni tekshiring'**
  String get locationDetectFailed;

  /// No description provided for @locationMyLocation.
  ///
  /// In uz, this message translates to:
  /// **'Mening joylashuvim'**
  String get locationMyLocation;

  /// No description provided for @locationChooseHere.
  ///
  /// In uz, this message translates to:
  /// **'Shu joyni tanlash'**
  String get locationChooseHere;

  /// No description provided for @sfGreeting.
  ///
  /// In uz, this message translates to:
  /// **'Salom, {name}!'**
  String sfGreeting(String name);

  /// No description provided for @sfGreetingGuest.
  ///
  /// In uz, this message translates to:
  /// **'Xush kelibsiz!'**
  String get sfGreetingGuest;

  /// No description provided for @sfGreetingSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Bugun nima xarid qilamiz?'**
  String get sfGreetingSubtitle;

  /// No description provided for @sfAllCategories.
  ///
  /// In uz, this message translates to:
  /// **'Barchasi'**
  String get sfAllCategories;

  /// No description provided for @sfSearchHint.
  ///
  /// In uz, this message translates to:
  /// **'«{term}» ni qidiring'**
  String sfSearchHint(String term);

  /// No description provided for @sfSearchHintDefault.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulot qidirish'**
  String get sfSearchHintDefault;

  /// No description provided for @sfShops.
  ///
  /// In uz, this message translates to:
  /// **'Do\'konlar'**
  String get sfShops;

  /// No description provided for @sfNewArrivals.
  ///
  /// In uz, this message translates to:
  /// **'Yangi kelganlar'**
  String get sfNewArrivals;

  /// No description provided for @sfFavoritesLogin.
  ///
  /// In uz, this message translates to:
  /// **'Sevimli mahsulotlaringizni ko\'rish uchun hisobingizga kiring'**
  String get sfFavoritesLogin;

  /// No description provided for @sfFavoritesEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Hali sevimli mahsulot yo\'q. Yoqqan mahsulotdagi ♡ ni bosing.'**
  String get sfFavoritesEmpty;

  /// No description provided for @sfProductsSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Siz uchun saralangan mahsulotlar'**
  String get sfProductsSubtitle;

  /// No description provided for @sfInStock.
  ///
  /// In uz, this message translates to:
  /// **'Qoldi: {quantity}'**
  String sfInStock(String quantity);

  /// No description provided for @sfOutOfStock.
  ///
  /// In uz, this message translates to:
  /// **'Tugagan'**
  String get sfOutOfStock;

  /// No description provided for @sfAdd.
  ///
  /// In uz, this message translates to:
  /// **'QO\'SHISH'**
  String get sfAdd;

  /// No description provided for @sfAddedToCart.
  ///
  /// In uz, this message translates to:
  /// **'{name} savatga qo\'shildi'**
  String sfAddedToCart(String name);

  /// No description provided for @sfCartOtherShop.
  ///
  /// In uz, this message translates to:
  /// **'Savatda faqat bitta do\'kondan mahsulot bo\'lishi mumkin'**
  String get sfCartOtherShop;

  /// No description provided for @sfNoProducts.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulotlar topilmadi'**
  String get sfNoProducts;

  /// No description provided for @sfRemoveFilter.
  ///
  /// In uz, this message translates to:
  /// **'Filtrni olib tashlash'**
  String get sfRemoveFilter;

  /// No description provided for @sfSearchTitle.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulot va do\'konlarni qidiring'**
  String get sfSearchTitle;

  /// No description provided for @sfSearchFieldHint.
  ///
  /// In uz, this message translates to:
  /// **'Qidiring, tanlang, buyurtma bering!'**
  String get sfSearchFieldHint;

  /// No description provided for @sfRecentSearches.
  ///
  /// In uz, this message translates to:
  /// **'So\'nggi qidiruvlar'**
  String get sfRecentSearches;

  /// No description provided for @sfClearRecent.
  ///
  /// In uz, this message translates to:
  /// **'Tarixni tozalash'**
  String get sfClearRecent;

  /// No description provided for @sfBrowseCategories.
  ///
  /// In uz, this message translates to:
  /// **'Kategoriyalar'**
  String get sfBrowseCategories;

  /// No description provided for @sfSuggestionProduct.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulot'**
  String get sfSuggestionProduct;

  /// No description provided for @sfShopsFor.
  ///
  /// In uz, this message translates to:
  /// **'«{query}» bo\'yicha do\'konlar'**
  String sfShopsFor(String query);

  /// No description provided for @sfMoreResults.
  ///
  /// In uz, this message translates to:
  /// **'Boshqa mos natijalar'**
  String get sfMoreResults;

  /// No description provided for @sfSearching.
  ///
  /// In uz, this message translates to:
  /// **'Siz uchun eng mosini qidiryapmiz…'**
  String get sfSearching;

  /// No description provided for @sfResultsIn.
  ///
  /// In uz, this message translates to:
  /// **'Natijalar: {category}'**
  String sfResultsIn(String category);

  /// No description provided for @sfSort.
  ///
  /// In uz, this message translates to:
  /// **'Saralash'**
  String get sfSort;

  /// No description provided for @sfSortRelevance.
  ///
  /// In uz, this message translates to:
  /// **'Tavsiya etilgan'**
  String get sfSortRelevance;

  /// No description provided for @sfSortPriceLow.
  ///
  /// In uz, this message translates to:
  /// **'Avval arzonlari'**
  String get sfSortPriceLow;

  /// No description provided for @sfSortPriceHigh.
  ///
  /// In uz, this message translates to:
  /// **'Avval qimmatlari'**
  String get sfSortPriceHigh;

  /// No description provided for @sfSortName.
  ///
  /// In uz, this message translates to:
  /// **'Nomi bo\'yicha (A–Z)'**
  String get sfSortName;

  /// No description provided for @sfInStockOnly.
  ///
  /// In uz, this message translates to:
  /// **'Mavjud'**
  String get sfInStockOnly;

  /// No description provided for @sfShopMatches.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta mos mahsulot'**
  String sfShopMatches(int count);

  /// No description provided for @sfNoResults.
  ///
  /// In uz, this message translates to:
  /// **'«{query}» bo\'yicha hech narsa topilmadi'**
  String sfNoResults(String query);

  /// No description provided for @sfNoResultsHint.
  ///
  /// In uz, this message translates to:
  /// **'Boshqa so\'z bilan qidiring yoki filtrlarni olib tashlang'**
  String get sfNoResultsHint;

  /// No description provided for @sfFeaturedShops.
  ///
  /// In uz, this message translates to:
  /// **'Mos do\'konlar'**
  String get sfFeaturedShops;

  /// No description provided for @sfChooseCategory.
  ///
  /// In uz, this message translates to:
  /// **'Qaysi bo\'limda qidiramiz?'**
  String get sfChooseCategory;

  /// No description provided for @sfShopProducts.
  ///
  /// In uz, this message translates to:
  /// **'Do\'kon mahsulotlari'**
  String get sfShopProducts;

  /// No description provided for @sfProductsShort.
  ///
  /// In uz, this message translates to:
  /// **'mahsulot'**
  String get sfProductsShort;

  /// No description provided for @sfChooseBranch.
  ///
  /// In uz, this message translates to:
  /// **'Filialni tanlang'**
  String get sfChooseBranch;

  /// No description provided for @sfCurrentBranch.
  ///
  /// In uz, this message translates to:
  /// **'Joriy filial'**
  String get sfCurrentBranch;

  /// No description provided for @sfOtherBranches.
  ///
  /// In uz, this message translates to:
  /// **'Boshqa filiallar'**
  String get sfOtherBranches;

  /// No description provided for @sfBranchesCount.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta filial · boshqasini tanlash'**
  String sfBranchesCount(int count);

  /// No description provided for @sfCallShop.
  ///
  /// In uz, this message translates to:
  /// **'Qo\'ng\'iroq qilish'**
  String get sfCallShop;

  /// No description provided for @sfCallFailed.
  ///
  /// In uz, this message translates to:
  /// **'Qo\'ng\'iroq qilib bo\'lmadi'**
  String get sfCallFailed;

  /// No description provided for @sfShopOwner.
  ///
  /// In uz, this message translates to:
  /// **'Do\'kon egasi'**
  String get sfShopOwner;

  /// No description provided for @sfSearchInShop.
  ///
  /// In uz, this message translates to:
  /// **'«{shop}» dan qidiring'**
  String sfSearchInShop(String shop);

  /// No description provided for @sfMenu.
  ///
  /// In uz, this message translates to:
  /// **'MENYU'**
  String get sfMenu;

  /// No description provided for @sfOtherCategory.
  ///
  /// In uz, this message translates to:
  /// **'Boshqa'**
  String get sfOtherCategory;

  /// No description provided for @sfCartHasOtherShop.
  ///
  /// In uz, this message translates to:
  /// **'Savatingizda boshqa do\'kon mahsulotlari bor. Bu do\'kondan qo\'shish uchun avval savatni bo\'shating.'**
  String get sfCartHasOtherShop;

  /// No description provided for @sfShopEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Bu do\'konda hozircha mahsulot yo\'q'**
  String get sfShopEmpty;

  /// No description provided for @sfDescription.
  ///
  /// In uz, this message translates to:
  /// **'Tavsif'**
  String get sfDescription;

  /// No description provided for @sfReadMore.
  ///
  /// In uz, this message translates to:
  /// **'batafsil'**
  String get sfReadMore;

  /// No description provided for @sfReadLess.
  ///
  /// In uz, this message translates to:
  /// **'yig\'ish'**
  String get sfReadLess;

  /// No description provided for @sfMoreFromShop.
  ///
  /// In uz, this message translates to:
  /// **'Shu do\'kondan yana'**
  String get sfMoreFromShop;

  /// No description provided for @sfOpenShop.
  ///
  /// In uz, this message translates to:
  /// **'Do\'konga o\'tish'**
  String get sfOpenShop;

  /// No description provided for @sfExploreShop.
  ///
  /// In uz, this message translates to:
  /// **'Rasmlar bilan ko\'rish'**
  String get sfExploreShop;

  /// No description provided for @sfUnitLabel.
  ///
  /// In uz, this message translates to:
  /// **'O\'lchov: {unit}'**
  String sfUnitLabel(String unit);

  /// No description provided for @sfInCart.
  ///
  /// In uz, this message translates to:
  /// **'Savatda: {quantity}'**
  String sfInCart(String quantity);

  /// No description provided for @cartEmptyTitle.
  ///
  /// In uz, this message translates to:
  /// **'Savatingiz bo\'sh'**
  String get cartEmptyTitle;

  /// No description provided for @cartEmptyHint.
  ///
  /// In uz, this message translates to:
  /// **'Do\'konlardan yoqqan mahsulotlarni qo\'shing — ular shu yerda paydo bo\'ladi.'**
  String get cartEmptyHint;

  /// No description provided for @cartStartShopping.
  ///
  /// In uz, this message translates to:
  /// **'Xarid qilish'**
  String get cartStartShopping;

  /// No description provided for @cartAddMore.
  ///
  /// In uz, this message translates to:
  /// **'Yana qo\'shish'**
  String get cartAddMore;

  /// No description provided for @cartRemove.
  ///
  /// In uz, this message translates to:
  /// **'O\'chirish'**
  String get cartRemove;

  /// No description provided for @cartClear.
  ///
  /// In uz, this message translates to:
  /// **'Savatni tozalash'**
  String get cartClear;

  /// No description provided for @cartClearConfirm.
  ///
  /// In uz, this message translates to:
  /// **'Savatdagi barcha mahsulotlar o\'chiriladi.'**
  String get cartClearConfirm;

  /// No description provided for @cartBillTitle.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov tafsilotlari'**
  String get cartBillTitle;

  /// No description provided for @cartItemsTotal.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulotlar'**
  String get cartItemsTotal;

  /// No description provided for @cartDelivery.
  ///
  /// In uz, this message translates to:
  /// **'Yetkazib berish'**
  String get cartDelivery;

  /// No description provided for @cartDeliveryAgreed.
  ///
  /// In uz, this message translates to:
  /// **'Do\'kon bilan kelishiladi'**
  String get cartDeliveryAgreed;

  /// No description provided for @cartToPay.
  ///
  /// In uz, this message translates to:
  /// **'Jami'**
  String get cartToPay;

  /// No description provided for @cartNoteLabel.
  ///
  /// In uz, this message translates to:
  /// **'ESLATMA:'**
  String get cartNoteLabel;

  /// No description provided for @cartNote.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtmani do\'kon tasdiqlaydi. To\'lov va yetkazib berish shartlarini do\'kon siz bilan kelishadi.'**
  String get cartNote;

  /// No description provided for @cartCheckout.
  ///
  /// In uz, this message translates to:
  /// **'Rasmiylashtirish'**
  String get cartCheckout;

  /// No description provided for @cartUnitPrice.
  ///
  /// In uz, this message translates to:
  /// **'{price} / {unit}'**
  String cartUnitPrice(String price, String unit);

  /// Short unit for prices ("20 000 so'm / kg"); keyed by ProductUnit enum name.
  ///
  /// In uz, this message translates to:
  /// **'{unit, select, dona{dona} metr{m} litr{l} kilogram{kg} gram{g} blok{blok} other{}}'**
  String enumProductUnitShort(String unit);

  /// No description provided for @coTitle.
  ///
  /// In uz, this message translates to:
  /// **'Rasmiylashtirish'**
  String get coTitle;

  /// No description provided for @coDeliverTo.
  ///
  /// In uz, this message translates to:
  /// **'Yetkazish manzili'**
  String get coDeliverTo;

  /// No description provided for @coPickup.
  ///
  /// In uz, this message translates to:
  /// **'O\'zim olib ketaman'**
  String get coPickup;

  /// No description provided for @coPickupHint.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtmani do\'kondan olib ketasiz'**
  String get coPickupHint;

  /// No description provided for @coWhereToDeliver.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtmani qayerga yetkazamiz?'**
  String get coWhereToDeliver;

  /// No description provided for @coAddAddress.
  ///
  /// In uz, this message translates to:
  /// **'Manzil qo\'shish'**
  String get coAddAddress;

  /// No description provided for @coSelectAddress.
  ///
  /// In uz, this message translates to:
  /// **'Manzilni tanlash'**
  String get coSelectAddress;

  /// No description provided for @coNoDelivery.
  ///
  /// In uz, this message translates to:
  /// **'Manzilsiz — o\'zim olib ketaman'**
  String get coNoDelivery;

  /// No description provided for @coItems.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtma tarkibi'**
  String get coItems;

  /// No description provided for @coNoteHint.
  ///
  /// In uz, this message translates to:
  /// **'Do\'kon uchun izoh (ixtiyoriy)'**
  String get coNoteHint;

  /// No description provided for @coPayment.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov'**
  String get coPayment;

  /// No description provided for @coPaymentValue.
  ///
  /// In uz, this message translates to:
  /// **'Do\'konga: naqd yoki karta'**
  String get coPaymentValue;

  /// No description provided for @coSlideToOrder.
  ///
  /// In uz, this message translates to:
  /// **'Surib buyurtma bering | {total}'**
  String coSlideToOrder(String total);

  /// No description provided for @coPlacing.
  ///
  /// In uz, this message translates to:
  /// **'Biroz kuting!'**
  String get coPlacing;

  /// No description provided for @coPlacedTitle.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtma qabul qilindi!'**
  String get coPlacedTitle;

  /// No description provided for @coPlacedBody.
  ///
  /// In uz, this message translates to:
  /// **'«{shop}» buyurtmangizni ko\'rib chiqadi va siz bilan bog\'lanadi.'**
  String coPlacedBody(String shop);

  /// No description provided for @coTrackOrder.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtmani ko\'rish'**
  String get coTrackOrder;

  /// No description provided for @coContinueShopping.
  ///
  /// In uz, this message translates to:
  /// **'Xaridni davom ettirish'**
  String get coContinueShopping;

  /// No description provided for @addrSelectTitle.
  ///
  /// In uz, this message translates to:
  /// **'Manzilni tanlang'**
  String get addrSelectTitle;

  /// No description provided for @addrSearchHint.
  ///
  /// In uz, this message translates to:
  /// **'Saqlangan manzillardan qidiring'**
  String get addrSearchHint;

  /// No description provided for @addrUseCurrent.
  ///
  /// In uz, this message translates to:
  /// **'Joriy joylashuvimdan foydalanish'**
  String get addrUseCurrent;

  /// No description provided for @addrPickOnMap.
  ///
  /// In uz, this message translates to:
  /// **'Xaritada belgilash'**
  String get addrPickOnMap;

  /// No description provided for @addrRecent.
  ///
  /// In uz, this message translates to:
  /// **'So\'nggi manzillar'**
  String get addrRecent;

  /// No description provided for @addrNoneSaved.
  ///
  /// In uz, this message translates to:
  /// **'Hali saqlangan manzil yo\'q'**
  String get addrNoneSaved;

  /// No description provided for @addrDeliveredHere.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtma shu yerga yetkaziladi'**
  String get addrDeliveredHere;

  /// No description provided for @addrFieldLabel.
  ///
  /// In uz, this message translates to:
  /// **'Manzil (ko\'cha, uy, xonadon, mo\'ljal)'**
  String get addrFieldLabel;

  /// No description provided for @addrConfirm.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlash va davom etish'**
  String get addrConfirm;

  /// No description provided for @addrDetecting.
  ///
  /// In uz, this message translates to:
  /// **'Manzil aniqlanmoqda…'**
  String get addrDetecting;

  /// No description provided for @addrRemove.
  ///
  /// In uz, this message translates to:
  /// **'Manzilni o\'chirish'**
  String get addrRemove;
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
