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
  /// **'{role, select, superAdmin{Super Admin} seller{Optomchi} sellerAdmin{Optomchi xodimi} retailer{Do\'konchi} retailerAdmin{Do\'konchi xodimi} customer{Mijoz} waiter{Ofitsiant} courier{Kuryer} leadAgent{Diller} agent{Agent} other{}}'**
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
  /// **'yopiladi'**
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

  /// No description provided for @otTitle.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtma #{number}'**
  String otTitle(String number);

  /// No description provided for @otSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'{time} · {count} ta mahsulot'**
  String otSubtitle(String time, int count);

  /// No description provided for @otNewTitle.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtma qabul qilindi!'**
  String get otNewTitle;

  /// No description provided for @otNewHint.
  ///
  /// In uz, this message translates to:
  /// **'Do\'kon buyurtmani tasdiqlashini kutmoqdamiz'**
  String get otNewHint;

  /// No description provided for @otApprovedTitle.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtma tayyorlanmoqda!'**
  String get otApprovedTitle;

  /// No description provided for @otApprovedHint.
  ///
  /// In uz, this message translates to:
  /// **'Do\'kon tasdiqladi va buyurtmani yig\'moqda'**
  String get otApprovedHint;

  /// No description provided for @otCourierSearching.
  ///
  /// In uz, this message translates to:
  /// **'Kuryer qidirilmoqda'**
  String get otCourierSearching;

  /// No description provided for @otCourierAssigned.
  ///
  /// In uz, this message translates to:
  /// **'Kuryer tayinlandi'**
  String get otCourierAssigned;

  /// No description provided for @otCourierToShop.
  ///
  /// In uz, this message translates to:
  /// **'Kuryer do\'konga bormoqda'**
  String get otCourierToShop;

  /// No description provided for @otOnTheWay.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtma yo\'lda!'**
  String get otOnTheWay;

  /// No description provided for @otArrived.
  ///
  /// In uz, this message translates to:
  /// **'Kuryer yetib keldi!'**
  String get otArrived;

  /// No description provided for @otDeliveredTitle.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtma topshirildi'**
  String get otDeliveredTitle;

  /// No description provided for @otDeliveredHint.
  ///
  /// In uz, this message translates to:
  /// **'Xaridingiz uchun rahmat!'**
  String get otDeliveredHint;

  /// No description provided for @otRejectedTitle.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtma rad etildi'**
  String get otRejectedTitle;

  /// No description provided for @otDeliveryCancelled.
  ///
  /// In uz, this message translates to:
  /// **'Yetkazish bekor qilindi'**
  String get otDeliveryCancelled;

  /// No description provided for @otDeliveryFailed.
  ///
  /// In uz, this message translates to:
  /// **'Yetkazib bo\'lmadi'**
  String get otDeliveryFailed;

  /// No description provided for @otPickupAt.
  ///
  /// In uz, this message translates to:
  /// **'Do\'kondan olib ketasiz'**
  String get otPickupAt;

  /// No description provided for @otStepPlaced.
  ///
  /// In uz, this message translates to:
  /// **'Qabul'**
  String get otStepPlaced;

  /// No description provided for @otStepApproved.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiq'**
  String get otStepApproved;

  /// No description provided for @otStepOnTheWay.
  ///
  /// In uz, this message translates to:
  /// **'Yo\'lda'**
  String get otStepOnTheWay;

  /// No description provided for @otStepDelivered.
  ///
  /// In uz, this message translates to:
  /// **'Topshirildi'**
  String get otStepDelivered;

  /// No description provided for @otMins.
  ///
  /// In uz, this message translates to:
  /// **'daq'**
  String get otMins;

  /// No description provided for @otViewItems.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulotlar ro\'yxati'**
  String get otViewItems;

  /// No description provided for @otTrackCourier.
  ///
  /// In uz, this message translates to:
  /// **'Kuryerni xaritada kuzatish'**
  String get otTrackCourier;

  /// No description provided for @otCallShop.
  ///
  /// In uz, this message translates to:
  /// **'Do\'konga qo\'ng\'iroq'**
  String get otCallShop;

  /// No description provided for @otYourCourier.
  ///
  /// In uz, this message translates to:
  /// **'Sizning kuryeringiz'**
  String get otYourCourier;

  /// No description provided for @otRefresh.
  ///
  /// In uz, this message translates to:
  /// **'Yangilash'**
  String get otRefresh;

  /// No description provided for @otShowAll.
  ///
  /// In uz, this message translates to:
  /// **'Hammasini ko\'rsatish'**
  String get otShowAll;

  /// No description provided for @otCourierUpdating.
  ///
  /// In uz, this message translates to:
  /// **'Kuryer joylashuvi yangilanmoqda…'**
  String get otCourierUpdating;

  /// No description provided for @otCourierBringing.
  ///
  /// In uz, this message translates to:
  /// **'{name} buyurtmangizni olib kelmoqda'**
  String otCourierBringing(String name);

  /// No description provided for @homeHello.
  ///
  /// In uz, this message translates to:
  /// **'Salom, {name}!'**
  String homeHello(String name);

  /// No description provided for @homeSections.
  ///
  /// In uz, this message translates to:
  /// **'Bo\'limlar'**
  String get homeSections;

  /// No description provided for @homeInventoryValue.
  ///
  /// In uz, this message translates to:
  /// **'Ombor qiymati'**
  String get homeInventoryValue;

  /// No description provided for @homeExpectedProfit.
  ///
  /// In uz, this message translates to:
  /// **'Kutilgan foyda: {amount}'**
  String homeExpectedProfit(String amount);

  /// No description provided for @homeCashReceived.
  ///
  /// In uz, this message translates to:
  /// **'Naqd tushum'**
  String get homeCashReceived;

  /// No description provided for @homeAllTime.
  ///
  /// In uz, this message translates to:
  /// **'Barcha vaqt'**
  String get homeAllTime;

  /// No description provided for @homeOpenPos.
  ///
  /// In uz, this message translates to:
  /// **'Kassani ochish'**
  String get homeOpenPos;

  /// 12 short month names, comma-separated, January first
  ///
  /// In uz, this message translates to:
  /// **'Yan,Fev,Mar,Apr,May,Iyn,Iyl,Avg,Sen,Okt,Noy,Dek'**
  String get commonMonthsShort;

  /// No description provided for @posCheckout.
  ///
  /// In uz, this message translates to:
  /// **'To\'lovga o\'tish'**
  String get posCheckout;

  /// No description provided for @posOutOfStock.
  ///
  /// In uz, this message translates to:
  /// **'Tugagan'**
  String get posOutOfStock;

  /// No description provided for @posStockLeft.
  ///
  /// In uz, this message translates to:
  /// **'Qoldi: {stock}'**
  String posStockLeft(String stock);

  /// No description provided for @salesCustomer.
  ///
  /// In uz, this message translates to:
  /// **'Mijoz'**
  String get salesCustomer;

  /// No description provided for @commonChange.
  ///
  /// In uz, this message translates to:
  /// **'O\'zgartirish'**
  String get commonChange;

  /// No description provided for @salesPaymentType.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov turi'**
  String get salesPaymentType;

  /// No description provided for @salesNewSale.
  ///
  /// In uz, this message translates to:
  /// **'Yangi sotuv'**
  String get salesNewSale;

  /// No description provided for @salesCustomerHint.
  ///
  /// In uz, this message translates to:
  /// **'Har bir sotuv mijoz nomiga yoziladi'**
  String get salesCustomerHint;

  /// No description provided for @salesDebtLeft.
  ///
  /// In uz, this message translates to:
  /// **'Qarzga qoladi'**
  String get salesDebtLeft;

  /// No description provided for @productsProfitWith.
  ///
  /// In uz, this message translates to:
  /// **'Foyda: {amount} · {percent}%'**
  String productsProfitWith(String amount, String percent);

  /// No description provided for @productsExpiry.
  ///
  /// In uz, this message translates to:
  /// **'Yaroqlilik muddati'**
  String get productsExpiry;

  /// No description provided for @productsDetails.
  ///
  /// In uz, this message translates to:
  /// **'Ma\'lumotlar'**
  String get productsDetails;

  /// No description provided for @formBasics.
  ///
  /// In uz, this message translates to:
  /// **'Asosiy ma\'lumotlar'**
  String get formBasics;

  /// No description provided for @formPricing.
  ///
  /// In uz, this message translates to:
  /// **'Narx'**
  String get formPricing;

  /// No description provided for @formStockSection.
  ///
  /// In uz, this message translates to:
  /// **'Ombor'**
  String get formStockSection;

  /// No description provided for @formExtra.
  ///
  /// In uz, this message translates to:
  /// **'Qo\'shimcha'**
  String get formExtra;

  /// No description provided for @productsSource.
  ///
  /// In uz, this message translates to:
  /// **'Manba'**
  String get productsSource;

  /// No description provided for @commonContinue.
  ///
  /// In uz, this message translates to:
  /// **'Davom etish'**
  String get commonContinue;

  /// No description provided for @debtsSummaryTotal.
  ///
  /// In uz, this message translates to:
  /// **'Jami qarz'**
  String get debtsSummaryTotal;

  /// No description provided for @debtsPeopleCount.
  ///
  /// In uz, this message translates to:
  /// **'{count} kishi'**
  String debtsPeopleCount(int count);

  /// No description provided for @debtsItemsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Qarzlar ro\'yxati'**
  String get debtsItemsTitle;

  /// No description provided for @debtsOriginal.
  ///
  /// In uz, this message translates to:
  /// **'Dastlabki summa'**
  String get debtsOriginal;

  /// No description provided for @commonYes.
  ///
  /// In uz, this message translates to:
  /// **'Ha'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In uz, this message translates to:
  /// **'Yo\'q'**
  String get commonNo;

  /// No description provided for @commonPhone.
  ///
  /// In uz, this message translates to:
  /// **'Telefon'**
  String get commonPhone;

  /// No description provided for @commonAddressRequired.
  ///
  /// In uz, this message translates to:
  /// **'Manzil *'**
  String get commonAddressRequired;

  /// No description provided for @restNeedDish.
  ///
  /// In uz, this message translates to:
  /// **'Kamida bitta taom qo\'shing'**
  String get restNeedDish;

  /// No description provided for @restPickTable.
  ///
  /// In uz, this message translates to:
  /// **'Stolni tanlang'**
  String get restPickTable;

  /// No description provided for @restAddressMissing.
  ///
  /// In uz, this message translates to:
  /// **'Yetkazib berish manzilini kiriting'**
  String get restAddressMissing;

  /// No description provided for @restNewOrder.
  ///
  /// In uz, this message translates to:
  /// **'Yangi buyurtma'**
  String get restNewOrder;

  /// No description provided for @restPlaceOrder.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtma berish'**
  String get restPlaceOrder;

  /// No description provided for @restTableRequired.
  ///
  /// In uz, this message translates to:
  /// **'Stol *'**
  String get restTableRequired;

  /// No description provided for @restDeliveryPoint.
  ///
  /// In uz, this message translates to:
  /// **'Yetkazib berish joyi'**
  String get restDeliveryPoint;

  /// No description provided for @restCustomerName.
  ///
  /// In uz, this message translates to:
  /// **'Mijoz ismi'**
  String get restCustomerName;

  /// No description provided for @restCustomerPhone.
  ///
  /// In uz, this message translates to:
  /// **'Mijoz telefoni'**
  String get restCustomerPhone;

  /// No description provided for @restDishes.
  ///
  /// In uz, this message translates to:
  /// **'Taomlar'**
  String get restDishes;

  /// No description provided for @restNoDishesYet.
  ///
  /// In uz, this message translates to:
  /// **'Hali taom qo\'shilmagan'**
  String get restNoDishesYet;

  /// No description provided for @restMenuSearchHint.
  ///
  /// In uz, this message translates to:
  /// **'Menyudan qidirish...'**
  String get restMenuSearchHint;

  /// No description provided for @restDishCount.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta taom'**
  String restDishCount(int count);

  /// No description provided for @restTableWith.
  ///
  /// In uz, this message translates to:
  /// **'Stol: {name}'**
  String restTableWith(String name);

  /// No description provided for @restCreatedBy.
  ///
  /// In uz, this message translates to:
  /// **'Yaratdi'**
  String get restCreatedBy;

  /// No description provided for @restServiceChargeWith.
  ///
  /// In uz, this message translates to:
  /// **'Xizmat haqi ({percent}%)'**
  String restServiceChargeWith(String percent);

  /// No description provided for @restWaiterCommissionWith.
  ///
  /// In uz, this message translates to:
  /// **'Ofitsiant xizmat haqi ({percent}%)'**
  String restWaiterCommissionWith(String percent);

  /// No description provided for @restNoCourier.
  ///
  /// In uz, this message translates to:
  /// **'Kuryer tayinlanmagan'**
  String get restNoCourier;

  /// No description provided for @restCourierPending.
  ///
  /// In uz, this message translates to:
  /// **'{name} (kutilmoqda)'**
  String restCourierPending(String name);

  /// No description provided for @restAwaitingAccept.
  ///
  /// In uz, this message translates to:
  /// **'Qabul qilinishi kutilmoqda'**
  String get restAwaitingAccept;

  /// No description provided for @restAssign.
  ///
  /// In uz, this message translates to:
  /// **'Tayinlash'**
  String get restAssign;

  /// No description provided for @restPickCourier.
  ///
  /// In uz, this message translates to:
  /// **'Kuryerni tanlang'**
  String get restPickCourier;

  /// No description provided for @restUnassignedAll.
  ///
  /// In uz, this message translates to:
  /// **'— Tayinlanmagan (barcha kuryerlarga) —'**
  String get restUnassignedAll;

  /// No description provided for @restTrackingLink.
  ///
  /// In uz, this message translates to:
  /// **'Kuzatish havolasi'**
  String get restTrackingLink;

  /// No description provided for @restRevokeLinks.
  ///
  /// In uz, this message translates to:
  /// **'Kuzatish havolalarini bekor qilish'**
  String get restRevokeLinks;

  /// No description provided for @restRevokeLinksTitle.
  ///
  /// In uz, this message translates to:
  /// **'Kuzatish havolalarini bekor qilish?'**
  String get restRevokeLinksTitle;

  /// No description provided for @restRevokeLinksBody.
  ///
  /// In uz, this message translates to:
  /// **'Mijozga yuborilgan barcha havolalar ishlamay qoladi, ochiq sahifalar ham uziladi. Kerak bo\'lsa yangisini yuborishingiz mumkin.'**
  String get restRevokeLinksBody;

  /// No description provided for @restRevoke.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilish'**
  String get restRevoke;

  /// No description provided for @restNoActiveLinks.
  ///
  /// In uz, this message translates to:
  /// **'Faol havola yo\'q edi'**
  String get restNoActiveLinks;

  /// No description provided for @restLinksRevoked.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta havola bekor qilindi'**
  String restLinksRevoked(int count);

  /// No description provided for @restShareTrackText.
  ///
  /// In uz, this message translates to:
  /// **'{order} buyurtmangizni xaritada kuzating: {url}'**
  String restShareTrackText(String order, String url);

  /// No description provided for @restShareTrackSubject.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtmani kuzatish'**
  String get restShareTrackSubject;

  /// No description provided for @restCourierNotAccepted.
  ///
  /// In uz, this message translates to:
  /// **'Kuryer buyurtmani hali qabul qilmagan.'**
  String get restCourierNotAccepted;

  /// No description provided for @restActionPreparing.
  ///
  /// In uz, this message translates to:
  /// **'Tayyorlashni boshlash'**
  String get restActionPreparing;

  /// No description provided for @restActionReady.
  ///
  /// In uz, this message translates to:
  /// **'Tayyor deb belgilash'**
  String get restActionReady;

  /// No description provided for @restActionServed.
  ///
  /// In uz, this message translates to:
  /// **'Berildi deb belgilash'**
  String get restActionServed;

  /// No description provided for @restActionDelivered.
  ///
  /// In uz, this message translates to:
  /// **'Yetkazildi deb belgilash'**
  String get restActionDelivered;

  /// No description provided for @restCancelOrder.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilish'**
  String get restCancelOrder;

  /// No description provided for @restAccept.
  ///
  /// In uz, this message translates to:
  /// **'Qabul qilish'**
  String get restAccept;

  /// No description provided for @restCancelOrderTitle.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtmani bekor qilish'**
  String get restCancelOrderTitle;

  /// No description provided for @restCancelOrderConfirm.
  ///
  /// In uz, this message translates to:
  /// **'Bu buyurtmani bekor qilishni tasdiqlaysizmi?'**
  String get restCancelOrderConfirm;

  /// No description provided for @restNoOpenOrders.
  ///
  /// In uz, this message translates to:
  /// **'Ochiq buyurtmalar yo\'q'**
  String get restNoOpenOrders;

  /// No description provided for @restMenuEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Menyu bo\'sh'**
  String get restMenuEmpty;

  /// No description provided for @tablesEditTitle.
  ///
  /// In uz, this message translates to:
  /// **'Stolni tahrirlash'**
  String get tablesEditTitle;

  /// No description provided for @tablesNewTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yangi stol'**
  String get tablesNewTitle;

  /// No description provided for @tablesServiceChargeRequired.
  ///
  /// In uz, this message translates to:
  /// **'Xizmat haqi (%) *'**
  String get tablesServiceChargeRequired;

  /// No description provided for @tablesPercentMissing.
  ///
  /// In uz, this message translates to:
  /// **'Foizni kiriting'**
  String get tablesPercentMissing;

  /// No description provided for @tablesPercentRange.
  ///
  /// In uz, this message translates to:
  /// **'0 dan 100 gacha bo\'lishi kerak'**
  String get tablesPercentRange;

  /// No description provided for @tablesDeleteTitle.
  ///
  /// In uz, this message translates to:
  /// **'Stolni o\'chirish'**
  String get tablesDeleteTitle;

  /// No description provided for @tablesDeleteConfirm.
  ///
  /// In uz, this message translates to:
  /// **'{name} o\'chirilsinmi? Ochiq buyurtmasi bo\'lsa, xatolik qaytadi.'**
  String tablesDeleteConfirm(String name);

  /// No description provided for @tablesNotFound.
  ///
  /// In uz, this message translates to:
  /// **'Stollar topilmadi'**
  String get tablesNotFound;

  /// No description provided for @tablesServiceCharge.
  ///
  /// In uz, this message translates to:
  /// **'Xizmat haqi: {percent}%'**
  String tablesServiceCharge(String percent);

  /// No description provided for @staffStoreBranchRequired.
  ///
  /// In uz, this message translates to:
  /// **'Do\'kon (filial) *'**
  String get staffStoreBranchRequired;

  /// No description provided for @waitersEditTitle.
  ///
  /// In uz, this message translates to:
  /// **'Ofitsiantni tahrirlash'**
  String get waitersEditTitle;

  /// No description provided for @waitersNewTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yangi ofitsiant'**
  String get waitersNewTitle;

  /// No description provided for @waitersDeleteTitle.
  ///
  /// In uz, this message translates to:
  /// **'Ofitsiantni o\'chirish'**
  String get waitersDeleteTitle;

  /// No description provided for @waitersNotFound.
  ///
  /// In uz, this message translates to:
  /// **'Ofitsiantlar topilmadi'**
  String get waitersNotFound;

  /// No description provided for @waitersUsage.
  ///
  /// In uz, this message translates to:
  /// **'{used} / {limit} ofitsiant ishlatilmoqda'**
  String waitersUsage(String used, String limit);

  /// No description provided for @waitersCommissionOptional.
  ///
  /// In uz, this message translates to:
  /// **'Komissiya (%) — ixtiyoriy'**
  String get waitersCommissionOptional;

  /// No description provided for @waitersCommission.
  ///
  /// In uz, this message translates to:
  /// **'Komissiya: {percent}%'**
  String waitersCommission(String percent);

  /// No description provided for @waitersToday.
  ///
  /// In uz, this message translates to:
  /// **'Bugun: {count} ta buyurtma'**
  String waitersToday(int count);

  /// No description provided for @couriersEditTitle.
  ///
  /// In uz, this message translates to:
  /// **'Kuryerni tahrirlash'**
  String get couriersEditTitle;

  /// No description provided for @couriersNewTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yangi kuryer'**
  String get couriersNewTitle;

  /// No description provided for @couriersDeleteTitle.
  ///
  /// In uz, this message translates to:
  /// **'Kuryerni o\'chirish'**
  String get couriersDeleteTitle;

  /// No description provided for @couriersNotFound.
  ///
  /// In uz, this message translates to:
  /// **'Kuryerlar topilmadi'**
  String get couriersNotFound;

  /// No description provided for @couriersUsage.
  ///
  /// In uz, this message translates to:
  /// **'{used} / {limit} kuryer ishlatilmoqda'**
  String couriersUsage(String used, String limit);

  /// No description provided for @couriersToday.
  ///
  /// In uz, this message translates to:
  /// **'Bugun: {count} ta yetkazish'**
  String couriersToday(int count);

  /// No description provided for @enumDeliveryStatus.
  ///
  /// In uz, this message translates to:
  /// **'{status, select, pending{Kutilmoqda} assigned{Biriktirilgan} accepted{Qabul qilingan} pickedUp{Yo\'lda} arrived{Yetib keldi} delivered{Topshirildi} cancelled{Bekor qilingan} failed{Yetkazib bo\'lmadi} other{}}'**
  String enumDeliveryStatus(String status);

  /// No description provided for @enumDeliveryFailReason.
  ///
  /// In uz, this message translates to:
  /// **'{reason, select, notHome{Mijoz manzilda yo\'q} refused{Mijoz qabul qilmadi} wrongAddress{Manzil noto\'g\'ri} other{Boshqa sabab}}'**
  String enumDeliveryFailReason(String reason);

  /// No description provided for @dlvHeadline.
  ///
  /// In uz, this message translates to:
  /// **'{status, select, pending{Kuryer qidirilmoqda} assigned{Kuryer tayinlandi, tasdiqlashini kutmoqda} accepted{Kuryer do\'konga bormoqda} pickedUp{Kuryer yo\'lda} arrived{Kuryer yetib keldi!} delivered{Buyurtma topshirildi} cancelled{Yetkazish bekor qilindi} failed{Yetkazib bo\'lmadi} other{}}'**
  String dlvHeadline(String status);

  /// No description provided for @dlvLabelFallback.
  ///
  /// In uz, this message translates to:
  /// **'Yetkazish'**
  String get dlvLabelFallback;

  /// No description provided for @dlvConfirmHandoverTitle.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtma topshirildimi?'**
  String get dlvConfirmHandoverTitle;

  /// No description provided for @dlvConfirmHandoverBody.
  ///
  /// In uz, this message translates to:
  /// **'{label} mijozga topshirilganini tasdiqlang.'**
  String dlvConfirmHandoverBody(String label);

  /// No description provided for @dlvYesHandedOver.
  ///
  /// In uz, this message translates to:
  /// **'Ha, topshirdim'**
  String get dlvYesHandedOver;

  /// No description provided for @dlvCallFailed.
  ///
  /// In uz, this message translates to:
  /// **'Qo\'ng\'iroq qilib bo\'lmadi'**
  String get dlvCallFailed;

  /// No description provided for @dlvNavigatorFailed.
  ///
  /// In uz, this message translates to:
  /// **'Navigatorni ochib bo\'lmadi'**
  String get dlvNavigatorFailed;

  /// No description provided for @dlvCount.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta yetkazish'**
  String dlvCount(int count);

  /// No description provided for @dlvNone.
  ///
  /// In uz, this message translates to:
  /// **'Hozircha yetkazish yo\'q'**
  String get dlvNone;

  /// No description provided for @dlvActiveSection.
  ///
  /// In uz, this message translates to:
  /// **'Faol yetkazishlar'**
  String get dlvActiveSection;

  /// No description provided for @dlvOffersSection.
  ///
  /// In uz, this message translates to:
  /// **'Yangi takliflar'**
  String get dlvOffersSection;

  /// No description provided for @dlvActiveBannerTitle.
  ///
  /// In uz, this message translates to:
  /// **'Faol yetkazish bor'**
  String get dlvActiveBannerTitle;

  /// No description provided for @dlvActiveBannerCustomer.
  ///
  /// In uz, this message translates to:
  /// **'Mijoz va biznes egangiz sizni xaritada ko\'rishi uchun onlayn bo\'ling.'**
  String get dlvActiveBannerCustomer;

  /// No description provided for @dlvActiveBannerOwner.
  ///
  /// In uz, this message translates to:
  /// **'Biznes egangiz sizni xaritada ko\'rishi uchun onlayn bo\'ling.'**
  String get dlvActiveBannerOwner;

  /// No description provided for @dlvNoAddress.
  ///
  /// In uz, this message translates to:
  /// **'Manzil ko\'rsatilmagan'**
  String get dlvNoAddress;

  /// No description provided for @dlvCompleted.
  ///
  /// In uz, this message translates to:
  /// **'Yetkazish yakunlandi'**
  String get dlvCompleted;

  /// No description provided for @dlvFailedMarked.
  ///
  /// In uz, this message translates to:
  /// **'Belgilandi: yetkazib bo\'lmadi. Buyurtmani do\'konga qaytaring.'**
  String get dlvFailedMarked;

  /// No description provided for @mapFitAll.
  ///
  /// In uz, this message translates to:
  /// **'Hammasini ko\'rsatish'**
  String get mapFitAll;

  /// No description provided for @mapMyLocation.
  ///
  /// In uz, this message translates to:
  /// **'Mening joylashuvim'**
  String get mapMyLocation;

  /// No description provided for @dlvPickup.
  ///
  /// In uz, this message translates to:
  /// **'Olib ketish'**
  String get dlvPickup;

  /// No description provided for @dlvYouAreOffline.
  ///
  /// In uz, this message translates to:
  /// **'Siz oflaynsiz'**
  String get dlvYouAreOffline;

  /// No description provided for @dlvLocationHidden.
  ///
  /// In uz, this message translates to:
  /// **'Joylashuvingiz ko\'rinmayapti'**
  String get dlvLocationHidden;

  /// No description provided for @dlvFailed.
  ///
  /// In uz, this message translates to:
  /// **'Yetkazib bo\'lmadi'**
  String get dlvFailed;

  /// No description provided for @dlvCancelledTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yetkazish bekor qilindi'**
  String get dlvCancelledTitle;

  /// No description provided for @dlvFinishedTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yetkazish yakunlangan'**
  String get dlvFinishedTitle;

  /// No description provided for @dlvGoToStore.
  ///
  /// In uz, this message translates to:
  /// **'Do\'konga boring'**
  String get dlvGoToStore;

  /// No description provided for @dlvDeliverToCustomer.
  ///
  /// In uz, this message translates to:
  /// **'Mijozga yetkazing'**
  String get dlvDeliverToCustomer;

  /// No description provided for @dlvCodeLockedHint.
  ///
  /// In uz, this message translates to:
  /// **'Kod bloklangan — do\'konga qo\'ng\'iroq qiling'**
  String get dlvCodeLockedHint;

  /// No description provided for @dlvAskCode.
  ///
  /// In uz, this message translates to:
  /// **'Topshirishda mijozdan 4 xonali kodni so\'rang'**
  String get dlvAskCode;

  /// No description provided for @dlvStoreFallback.
  ///
  /// In uz, this message translates to:
  /// **'Do\'kon'**
  String get dlvStoreFallback;

  /// No description provided for @dlvNavigator.
  ///
  /// In uz, this message translates to:
  /// **'Navigator'**
  String get dlvNavigator;

  /// No description provided for @dlvHandedOver.
  ///
  /// In uz, this message translates to:
  /// **'Topshirdim'**
  String get dlvHandedOver;

  /// No description provided for @dlvPickedUp.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtmani oldim'**
  String get dlvPickedUp;

  /// No description provided for @dlvArrived.
  ///
  /// In uz, this message translates to:
  /// **'Yetib keldim'**
  String get dlvArrived;

  /// No description provided for @dlvMinutesShort.
  ///
  /// In uz, this message translates to:
  /// **'~{minutes} daq'**
  String dlvMinutesShort(String minutes);

  /// No description provided for @dlvToStore.
  ///
  /// In uz, this message translates to:
  /// **'Do\'kongacha {time}'**
  String dlvToStore(String time);

  /// No description provided for @dlvToCustomer.
  ///
  /// In uz, this message translates to:
  /// **'Mijozgacha {time}'**
  String dlvToCustomer(String time);

  /// No description provided for @commonKm.
  ///
  /// In uz, this message translates to:
  /// **'{km} km'**
  String commonKm(String km);

  /// No description provided for @commonMeters.
  ///
  /// In uz, this message translates to:
  /// **'{meters} m'**
  String commonMeters(String meters);

  /// No description provided for @dlvRestaurantOrder.
  ///
  /// In uz, this message translates to:
  /// **'Restoran buyurtmasi'**
  String get dlvRestaurantOrder;

  /// No description provided for @dlvMinutesLong.
  ///
  /// In uz, this message translates to:
  /// **'~{minutes} daqiqa'**
  String dlvMinutesLong(String minutes);

  /// No description provided for @dlvFailedCustomer.
  ///
  /// In uz, this message translates to:
  /// **'{reason}. Do\'kon siz bilan bog\'lanadi.'**
  String dlvFailedCustomer(String reason);

  /// No description provided for @dlvFailedFallback.
  ///
  /// In uz, this message translates to:
  /// **'Topshirib bo\'lmadi'**
  String get dlvFailedFallback;

  /// No description provided for @dlvCourierUpdating.
  ///
  /// In uz, this message translates to:
  /// **'Kuryer joylashuvi yangilanmoqda…'**
  String get dlvCourierUpdating;

  /// No description provided for @dlvYourCourier.
  ///
  /// In uz, this message translates to:
  /// **'Sizning kuryeringiz'**
  String get dlvYourCourier;

  /// No description provided for @commonCall.
  ///
  /// In uz, this message translates to:
  /// **'Qo\'ng\'iroq'**
  String get commonCall;

  /// No description provided for @dlvAssignTitle.
  ///
  /// In uz, this message translates to:
  /// **'Kuryerga berish'**
  String get dlvAssignTitle;

  /// No description provided for @dlvOfferAll.
  ///
  /// In uz, this message translates to:
  /// **'Barcha kuryerlarga taklif qilish'**
  String get dlvOfferAll;

  /// No description provided for @dlvOfferAllHint.
  ///
  /// In uz, this message translates to:
  /// **'Birinchi qabul qilgan kuryer oladi'**
  String get dlvOfferAllHint;

  /// No description provided for @dlvNoActiveCouriers.
  ///
  /// In uz, this message translates to:
  /// **'Faol kuryer yo\'q'**
  String get dlvNoActiveCouriers;

  /// No description provided for @dlvActiveDeliveries.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta faol yetkazish'**
  String dlvActiveDeliveries(int count);

  /// No description provided for @dlvCodeFourDigits.
  ///
  /// In uz, this message translates to:
  /// **'Kod 4 ta raqamdan iborat'**
  String get dlvCodeFourDigits;

  /// No description provided for @dlvCodeLocked.
  ///
  /// In uz, this message translates to:
  /// **'Kod bloklandi'**
  String get dlvCodeLocked;

  /// No description provided for @dlvWaivedTitle.
  ///
  /// In uz, this message translates to:
  /// **'Do\'kon kodsiz topshirishga ruxsat berdi'**
  String get dlvWaivedTitle;

  /// No description provided for @dlvHandoverCode.
  ///
  /// In uz, this message translates to:
  /// **'Topshirish kodi'**
  String get dlvHandoverCode;

  /// No description provided for @dlvTooManyTries.
  ///
  /// In uz, this message translates to:
  /// **'Noto\'g\'ri urinishlar juda ko\'p. Do\'konga qo\'ng\'iroq qiling — ular kodsiz topshirishga ruxsat beradi.'**
  String get dlvTooManyTries;

  /// No description provided for @dlvConfirmHandedOver.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtmani mijozga topshirganingizni tasdiqlang.'**
  String get dlvConfirmHandedOver;

  /// No description provided for @dlvAskCodeLong.
  ///
  /// In uz, this message translates to:
  /// **'Mijozdan 4 xonali kodni so\'rang. Kod mijozning ilovasida va Telegramida.'**
  String get dlvAskCodeLong;

  /// No description provided for @dlvAttemptsLeft.
  ///
  /// In uz, this message translates to:
  /// **'Urinishlar: {count} ta qoldi'**
  String dlvAttemptsLeft(int count);

  /// No description provided for @dlvRecheck.
  ///
  /// In uz, this message translates to:
  /// **'Qayta tekshirish'**
  String get dlvRecheck;

  /// No description provided for @dlvWhyFailed.
  ///
  /// In uz, this message translates to:
  /// **'Nima uchun topshirib bo\'lmadi?'**
  String get dlvWhyFailed;

  /// No description provided for @dlvFailNotice.
  ///
  /// In uz, this message translates to:
  /// **'Mijoz va do\'kon xabardor qilinadi. Buyurtmani do\'konga qaytaring.'**
  String get dlvFailNotice;

  /// No description provided for @dlvNoteRequired.
  ///
  /// In uz, this message translates to:
  /// **'Izoh (majburiy)'**
  String get dlvNoteRequired;

  /// No description provided for @dlvWaiveTitle.
  ///
  /// In uz, this message translates to:
  /// **'Kodsiz topshirishga ruxsat berilsinmi?'**
  String get dlvWaiveTitle;

  /// No description provided for @dlvWaiveBody.
  ///
  /// In uz, this message translates to:
  /// **'Kuryer buyurtmani mijoz kodisiz topshira oladi. Faqat mijoz bilan gaplashib, buyurtmani olganiga ishonch hosil qilsangiz ruxsat bering.'**
  String get dlvWaiveBody;

  /// No description provided for @dlvWaiveConfirm.
  ///
  /// In uz, this message translates to:
  /// **'Ruxsat berish'**
  String get dlvWaiveConfirm;

  /// No description provided for @dlvWaived.
  ///
  /// In uz, this message translates to:
  /// **'Ruxsat berildi — kuryer kodsiz topshira oladi'**
  String get dlvWaived;

  /// No description provided for @dlvReasonWith.
  ///
  /// In uz, this message translates to:
  /// **'Sabab: {reason}'**
  String dlvReasonWith(String reason);

  /// No description provided for @dlvDistanceFromDropoff.
  ///
  /// In uz, this message translates to:
  /// **'Kuryer mijoz manzilidan {distance} uzoqlikda edi'**
  String dlvDistanceFromDropoff(String distance);

  /// No description provided for @dlvCancelReasonWith.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilish sababi: {reason}'**
  String dlvCancelReasonWith(String reason);

  /// No description provided for @dlvCodeLockedStaff.
  ///
  /// In uz, this message translates to:
  /// **'Kod bloklandi: kuryer noto\'g\'ri kodni ko\'p kiritdi'**
  String get dlvCodeLockedStaff;

  /// No description provided for @dlvCodeWaiting.
  ///
  /// In uz, this message translates to:
  /// **'Mijoz kodi kutilmoqda ({count} urinish qoldi)'**
  String dlvCodeWaiting(int count);

  /// No description provided for @dlvWaivedStaff.
  ///
  /// In uz, this message translates to:
  /// **'Kodsiz topshirishga ruxsat berilgan'**
  String get dlvWaivedStaff;

  /// No description provided for @dlvWaiveButton.
  ///
  /// In uz, this message translates to:
  /// **'Kodsiz topshirishga ruxsat'**
  String get dlvWaiveButton;

  /// No description provided for @dlvHandoverCodeHint.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtmani olganingizda kuryerga ayting. Boshqa hech kimga bermang.'**
  String get dlvHandoverCodeHint;

  /// No description provided for @dlvCodeSemantics.
  ///
  /// In uz, this message translates to:
  /// **'Kod {digits}'**
  String dlvCodeSemantics(String digits);

  /// No description provided for @dlvCourierWith.
  ///
  /// In uz, this message translates to:
  /// **'Kuryer: {name}'**
  String dlvCourierWith(String name);

  /// No description provided for @dlvChangeCourier.
  ///
  /// In uz, this message translates to:
  /// **'Kuryerni o\'zgartirish'**
  String get dlvChangeCourier;

  /// No description provided for @dlvCancel.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilish'**
  String get dlvCancel;

  /// No description provided for @dlvReassign.
  ///
  /// In uz, this message translates to:
  /// **'Qayta kuryerga berish'**
  String get dlvReassign;

  /// No description provided for @dlvTrackCourier.
  ///
  /// In uz, this message translates to:
  /// **'Kuryerni kuzatish'**
  String get dlvTrackCourier;

  /// No description provided for @dlvOfferedAll.
  ///
  /// In uz, this message translates to:
  /// **'Barcha kuryerlarga taklif qilindi'**
  String get dlvOfferedAll;

  /// No description provided for @dlvAssigned.
  ///
  /// In uz, this message translates to:
  /// **'Kuryerga berildi'**
  String get dlvAssigned;

  /// No description provided for @dlvCancelTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yetkazishni bekor qilish?'**
  String get dlvCancelTitle;

  /// No description provided for @dlvCancelBody.
  ///
  /// In uz, this message translates to:
  /// **'Kuryer bu buyurtmani endi ko\'rmaydi. Keyin qayta berishingiz mumkin.'**
  String get dlvCancelBody;

  /// No description provided for @commonRefresh.
  ///
  /// In uz, this message translates to:
  /// **'Yangilash'**
  String get commonRefresh;

  /// No description provided for @fleetOnline.
  ///
  /// In uz, this message translates to:
  /// **'{count} onlayn'**
  String fleetOnline(String count);

  /// No description provided for @fleetBusy.
  ///
  /// In uz, this message translates to:
  /// **'{count} yetkazishda'**
  String fleetBusy(String count);

  /// No description provided for @fleetStale.
  ///
  /// In uz, this message translates to:
  /// **'{count} aloqasiz'**
  String fleetStale(String count);

  /// No description provided for @fleetNoSignal.
  ///
  /// In uz, this message translates to:
  /// **'Aloqa yo\'q'**
  String get fleetNoSignal;

  /// No description provided for @fleetDelivering.
  ///
  /// In uz, this message translates to:
  /// **'Yetkazishda'**
  String get fleetDelivering;

  /// No description provided for @fleetFree.
  ///
  /// In uz, this message translates to:
  /// **'Bo\'sh'**
  String get fleetFree;

  /// No description provided for @fleetNoneOnline.
  ///
  /// In uz, this message translates to:
  /// **'Hozircha onlayn kuryer yo\'q'**
  String get fleetNoneOnline;

  /// No description provided for @fleetLastLocation.
  ///
  /// In uz, this message translates to:
  /// **'oxirgi joylashuv {ago}'**
  String fleetLastLocation(String ago);

  /// No description provided for @fleetViewDelivery.
  ///
  /// In uz, this message translates to:
  /// **'Yetkazishni ko\'rish'**
  String get fleetViewDelivery;

  /// No description provided for @fleetViewDeliveryN.
  ///
  /// In uz, this message translates to:
  /// **'Yetkazishni ko\'rish ({n})'**
  String fleetViewDeliveryN(String n);

  /// No description provided for @trkOnline.
  ///
  /// In uz, this message translates to:
  /// **'Onlayn'**
  String get trkOnline;

  /// No description provided for @trkOffline.
  ///
  /// In uz, this message translates to:
  /// **'Oflayn'**
  String get trkOffline;

  /// No description provided for @trkNotificationTitle.
  ///
  /// In uz, this message translates to:
  /// **'bsmart joylashuvingizni ulashmoqda'**
  String get trkNotificationTitle;

  /// No description provided for @trkNotifActiveCustomer.
  ///
  /// In uz, this message translates to:
  /// **'Faol yetkazish: {label} — mijoz va biznes egangiz ko\'radi'**
  String trkNotifActiveCustomer(String label);

  /// No description provided for @trkNotifActiveOwner.
  ///
  /// In uz, this message translates to:
  /// **'Faol yetkazish: {label} — biznes egangiz ko\'radi'**
  String trkNotifActiveOwner(String label);

  /// No description provided for @trkNotifOnline.
  ///
  /// In uz, this message translates to:
  /// **'Onlayn — joylashuvingiz biznes egasiga ko\'rinadi'**
  String get trkNotifOnline;

  /// No description provided for @trkShareTitle.
  ///
  /// In uz, this message translates to:
  /// **'Joylashuvni ulashish'**
  String get trkShareTitle;

  /// No description provided for @trkWatchersNone.
  ///
  /// In uz, this message translates to:
  /// **'Hech kim — joylashuv yuborilmayapti'**
  String get trkWatchersNone;

  /// No description provided for @trkWatchersWithCustomer.
  ///
  /// In uz, this message translates to:
  /// **'Biznes egangiz, administratorlar va mijoz ({label})'**
  String trkWatchersWithCustomer(String label);

  /// No description provided for @trkWatchersOwner.
  ///
  /// In uz, this message translates to:
  /// **'Biznes egangiz va administratorlar'**
  String get trkWatchersOwner;

  /// No description provided for @trkWhatTitle.
  ///
  /// In uz, this message translates to:
  /// **'Nima ulashiladi'**
  String get trkWhatTitle;

  /// No description provided for @trkWhatBody.
  ///
  /// In uz, this message translates to:
  /// **'Telefoningizning GPS joylashuvi: koordinatalar, tezlik va harakat yo\'nalishi.'**
  String get trkWhatBody;

  /// No description provided for @trkWhenTitle.
  ///
  /// In uz, this message translates to:
  /// **'Qachon'**
  String get trkWhenTitle;

  /// No description provided for @trkWhenBody.
  ///
  /// In uz, this message translates to:
  /// **'Faqat siz «Onlayn» bo\'lganingizda yoki faol yetkazish paytida — ilova fonda yoki ekran o\'chiq bo\'lsa ham. Bu vaqtda bildirishnomalar panelida doimiy xabar turadi.'**
  String get trkWhenBody;

  /// No description provided for @trkWhoTitle.
  ///
  /// In uz, this message translates to:
  /// **'Kim ko\'radi'**
  String get trkWhoTitle;

  /// No description provided for @trkWhoBody.
  ///
  /// In uz, this message translates to:
  /// **'Biznes egangiz va uning administratorlari, hamda faol yetkazish buyurtmasining mijozi.'**
  String get trkWhoBody;

  /// No description provided for @trkStopTitle.
  ///
  /// In uz, this message translates to:
  /// **'Qanday to\'xtatiladi'**
  String get trkStopTitle;

  /// No description provided for @trkStopBody.
  ///
  /// In uz, this message translates to:
  /// **'Istalgan vaqtda «Oflayn» ga o\'ting — joylashuv yuborish darhol to\'xtaydi. Oflayn paytida joylashuvingiz yuborilmaydi.'**
  String get trkStopBody;

  /// No description provided for @trkDisclosureLead.
  ///
  /// In uz, this message translates to:
  /// **'Yetkazishlarni kuzatish uchun bsmart joylashuvingizdan foydalanadi'**
  String get trkDisclosureLead;

  /// No description provided for @trkNotNow.
  ///
  /// In uz, this message translates to:
  /// **'Hozir emas'**
  String get trkNotNow;

  /// No description provided for @trkAgree.
  ///
  /// In uz, this message translates to:
  /// **'Roziman'**
  String get trkAgree;

  /// No description provided for @trkGoOfflineTitle.
  ///
  /// In uz, this message translates to:
  /// **'Oflayn bo\'lish'**
  String get trkGoOfflineTitle;

  /// No description provided for @trkGoOfflineBody.
  ///
  /// In uz, this message translates to:
  /// **'Joylashuvingizni ulashish to\'xtatiladi — biznes egangiz sizni xaritada ko\'rmaydi.'**
  String get trkGoOfflineBody;

  /// No description provided for @trkGoOfflineActiveCustomer.
  ///
  /// In uz, this message translates to:
  /// **'Sizda faol yetkazish bor ({label}). Joylashuv ulashish to\'xtatilsa, mijoz va biznes egangiz sizni xaritada ko\'rmay qoladi.'**
  String trkGoOfflineActiveCustomer(String label);

  /// No description provided for @trkGoOfflineActiveOwner.
  ///
  /// In uz, this message translates to:
  /// **'Sizda faol yetkazish bor ({label}). Joylashuv ulashish to\'xtatilsa, biznes egangiz sizni xaritada ko\'rmay qoladi.'**
  String trkGoOfflineActiveOwner(String label);

  /// No description provided for @trkStop.
  ///
  /// In uz, this message translates to:
  /// **'To\'xtatish'**
  String get trkStop;

  /// No description provided for @trkNotSentYet.
  ///
  /// In uz, this message translates to:
  /// **'hali yuborilmagan'**
  String get trkNotSentYet;

  /// No description provided for @trkSecondsAgo.
  ///
  /// In uz, this message translates to:
  /// **'{seconds} soniya oldin'**
  String trkSecondsAgo(String seconds);

  /// No description provided for @trkMinutesAgo.
  ///
  /// In uz, this message translates to:
  /// **'{minutes} daqiqa oldin'**
  String trkMinutesAgo(String minutes);

  /// No description provided for @trkWatchersWith.
  ///
  /// In uz, this message translates to:
  /// **'Ko\'radi: {who}'**
  String trkWatchersWith(String who);

  /// No description provided for @trkGoOnlineHint.
  ///
  /// In uz, this message translates to:
  /// **'Ishni boshlash uchun onlayn bo\'ling'**
  String get trkGoOnlineHint;

  /// No description provided for @trkGpsOffBanner.
  ///
  /// In uz, this message translates to:
  /// **'Telefoningizda GPS (joylashuv) o\'chirilgan.'**
  String get trkGpsOffBanner;

  /// No description provided for @trkTurnOnGps.
  ///
  /// In uz, this message translates to:
  /// **'GPS ni yoqish'**
  String get trkTurnOnGps;

  /// No description provided for @trkDeniedForever.
  ///
  /// In uz, this message translates to:
  /// **'Joylashuv ruxsati rad etilgan. Sozlamalardan ruxsat bering.'**
  String get trkDeniedForever;

  /// No description provided for @trkOpenSettings.
  ///
  /// In uz, this message translates to:
  /// **'Sozlamalarni ochish'**
  String get trkOpenSettings;

  /// No description provided for @trkPermissionNeeded.
  ///
  /// In uz, this message translates to:
  /// **'Onlayn bo\'lish uchun joylashuv ruxsati kerak.'**
  String get trkPermissionNeeded;

  /// No description provided for @trkLastSent.
  ///
  /// In uz, this message translates to:
  /// **'Oxirgi yuborilgan joylashuv'**
  String get trkLastSent;

  /// No description provided for @trkWhoNow.
  ///
  /// In uz, this message translates to:
  /// **'Hozir kim ko\'radi'**
  String get trkWhoNow;

  /// No description provided for @trkNoNotifPermission.
  ///
  /// In uz, this message translates to:
  /// **'Bildirishnoma ruxsati yo\'q'**
  String get trkNoNotifPermission;

  /// No description provided for @trkNoNotifPermissionBody.
  ///
  /// In uz, this message translates to:
  /// **'Kuzatuv davom etadi, lekin bildirishnoma panelida ko\'rinmaydi.'**
  String get trkNoNotifPermissionBody;

  /// No description provided for @trkBatterySaver.
  ///
  /// In uz, this message translates to:
  /// **'Batareya tejash rejimi'**
  String get trkBatterySaver;

  /// No description provided for @trkBatterySaverBody.
  ///
  /// In uz, this message translates to:
  /// **'Ba\'zi telefonlar fondagi ilovalarni to\'xtatadi. Muammo bo\'lsa, bsmart uchun batareya cheklovini o\'chiring.'**
  String get trkBatterySaverBody;

  /// No description provided for @trkAboutSharing.
  ///
  /// In uz, this message translates to:
  /// **'Joylashuv ulashish haqida'**
  String get trkAboutSharing;

  /// No description provided for @trkSharing.
  ///
  /// In uz, this message translates to:
  /// **'Joylashuv ulashilmoqda'**
  String get trkSharing;

  /// No description provided for @trkConnecting.
  ///
  /// In uz, this message translates to:
  /// **'Ulanmoqda…'**
  String get trkConnecting;

  /// No description provided for @trkNoGps.
  ///
  /// In uz, this message translates to:
  /// **'GPS signali yo\'q'**
  String get trkNoGps;

  /// No description provided for @trkReconnecting.
  ///
  /// In uz, this message translates to:
  /// **'Qayta ulanmoqda…'**
  String get trkReconnecting;

  /// No description provided for @trkDenied.
  ///
  /// In uz, this message translates to:
  /// **'Ruxsat berilmagan'**
  String get trkDenied;

  /// No description provided for @trkGpsOff.
  ///
  /// In uz, this message translates to:
  /// **'GPS o\'chirilgan'**
  String get trkGpsOff;

  /// No description provided for @trkJustNow.
  ///
  /// In uz, this message translates to:
  /// **'hozirgina'**
  String get trkJustNow;

  /// No description provided for @tgRequestNotFound.
  ///
  /// In uz, this message translates to:
  /// **'So\'rov topilmadi. Qaytadan boshlang.'**
  String get tgRequestNotFound;

  /// No description provided for @tgRequestUsed.
  ///
  /// In uz, this message translates to:
  /// **'Bu so\'rov allaqachon ishlatilgan. Qaytadan boshlang.'**
  String get tgRequestUsed;

  /// No description provided for @sfUnknownShop.
  ///
  /// In uz, this message translates to:
  /// **'Noma\'lum do\'kon'**
  String get sfUnknownShop;

  /// No description provided for @favLoginPrompt.
  ///
  /// In uz, this message translates to:
  /// **'Sevimlilarni ko\'rish uchun tizimga kiring'**
  String get favLoginPrompt;

  /// No description provided for @favEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Sevimlilar ro\'yxati bo\'sh'**
  String get favEmpty;

  /// No description provided for @usersNotFound.
  ///
  /// In uz, this message translates to:
  /// **'Foydalanuvchilar topilmadi'**
  String get usersNotFound;

  /// No description provided for @usersSearchHint.
  ///
  /// In uz, this message translates to:
  /// **'Ism, familiya yoki telefon...'**
  String get usersSearchHint;

  /// No description provided for @usersDeleteTitle.
  ///
  /// In uz, this message translates to:
  /// **'Foydalanuvchini o\'chirish'**
  String get usersDeleteTitle;

  /// No description provided for @usersDeleteConfirm.
  ///
  /// In uz, this message translates to:
  /// **'{name} butunlay o\'chirilsinmi? Bu amalni bekor qilib bo\'lmaydi.'**
  String usersDeleteConfirm(String name);

  /// No description provided for @usersEditTitle.
  ///
  /// In uz, this message translates to:
  /// **'Foydalanuvchini tahrirlash'**
  String get usersEditTitle;

  /// No description provided for @usersNewTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yangi foydalanuvchi'**
  String get usersNewTitle;

  /// No description provided for @usersRoleRequired.
  ///
  /// In uz, this message translates to:
  /// **'Rol *'**
  String get usersRoleRequired;

  /// No description provided for @usersVerticalRequired.
  ///
  /// In uz, this message translates to:
  /// **'Yo\'nalish *'**
  String get usersVerticalRequired;

  /// No description provided for @usersShopName.
  ///
  /// In uz, this message translates to:
  /// **'Do\'kon nomi'**
  String get usersShopName;

  /// No description provided for @adminVerticalsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yo\'nalishlar bo\'yicha do\'konchilar'**
  String get adminVerticalsTitle;

  /// No description provided for @adminTotalRevenue.
  ///
  /// In uz, this message translates to:
  /// **'Jami tushum'**
  String get adminTotalRevenue;

  /// No description provided for @adminActiveUsers.
  ///
  /// In uz, this message translates to:
  /// **'Faol foydalanuvchilar'**
  String get adminActiveUsers;

  /// No description provided for @adminTotalDebt.
  ///
  /// In uz, this message translates to:
  /// **'Umumiy qarzdorlik'**
  String get adminTotalDebt;

  /// No description provided for @scannerHint.
  ///
  /// In uz, this message translates to:
  /// **'Shtrix-kodni ramka ichiga joylang'**
  String get scannerHint;

  /// No description provided for @scannerTorch.
  ///
  /// In uz, this message translates to:
  /// **'Chiroq'**
  String get scannerTorch;

  /// No description provided for @locationDragHint.
  ///
  /// In uz, this message translates to:
  /// **'Xaritani suring — pin markazda qoladi'**
  String get locationDragHint;

  /// No description provided for @categoriesPickerTitle.
  ///
  /// In uz, this message translates to:
  /// **'Kategoriyani tanlang'**
  String get categoriesPickerTitle;

  /// No description provided for @scannerCameraError.
  ///
  /// In uz, this message translates to:
  /// **'Kamerani ochib bo\'lmadi. Kameraga ruxsat berilganini tekshiring.'**
  String get scannerCameraError;

  /// No description provided for @agentTabHome.
  ///
  /// In uz, this message translates to:
  /// **'Bosh sahifa'**
  String get agentTabHome;

  /// No description provided for @agentTabSell.
  ///
  /// In uz, this message translates to:
  /// **'Sotish'**
  String get agentTabSell;

  /// No description provided for @agentTabSales.
  ///
  /// In uz, this message translates to:
  /// **'Sotuvlar'**
  String get agentTabSales;

  /// No description provided for @agentTabDebts.
  ///
  /// In uz, this message translates to:
  /// **'Qarzdorlar'**
  String get agentTabDebts;

  /// No description provided for @agentHello.
  ///
  /// In uz, this message translates to:
  /// **'Salom, {name}!'**
  String agentHello(String name);

  /// No description provided for @agentLeadOf.
  ///
  /// In uz, this message translates to:
  /// **'{business} dilleri'**
  String agentLeadOf(String business);

  /// No description provided for @agentStaffOf.
  ///
  /// In uz, this message translates to:
  /// **'{lead} dillerining agenti'**
  String agentStaffOf(String lead);

  /// No description provided for @agentTodaySales.
  ///
  /// In uz, this message translates to:
  /// **'Bugungi savdo'**
  String get agentTodaySales;

  /// No description provided for @agentMonthSales.
  ///
  /// In uz, this message translates to:
  /// **'30 kunlik savdo'**
  String get agentMonthSales;

  /// No description provided for @agentMyTodaySales.
  ///
  /// In uz, this message translates to:
  /// **'Bugungi savdom'**
  String get agentMyTodaySales;

  /// No description provided for @agentMyMonthSales.
  ///
  /// In uz, this message translates to:
  /// **'30 kunlik savdom'**
  String get agentMyMonthSales;

  /// No description provided for @agentSalesCount.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta sotuv'**
  String agentSalesCount(int count);

  /// No description provided for @agentCustomersOwe.
  ///
  /// In uz, this message translates to:
  /// **'Mijozlar qarzi'**
  String get agentCustomersOwe;

  /// No description provided for @agentMyDebtsGiven.
  ///
  /// In uz, this message translates to:
  /// **'Men bergan qarzlar'**
  String get agentMyDebtsGiven;

  /// No description provided for @agentOpenDebts.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta ochiq qarz'**
  String agentOpenDebts(int count);

  /// No description provided for @agentOwedToOwner.
  ///
  /// In uz, this message translates to:
  /// **'Biznes egasiga qarzim'**
  String get agentOwedToOwner;

  /// No description provided for @agentStockValue.
  ///
  /// In uz, this message translates to:
  /// **'Qo\'limdagi tovar'**
  String get agentStockValue;

  /// No description provided for @agentProfitTitle.
  ///
  /// In uz, this message translates to:
  /// **'Sof foyda'**
  String get agentProfitTitle;

  /// No description provided for @agentProfitToday.
  ///
  /// In uz, this message translates to:
  /// **'Bugun'**
  String get agentProfitToday;

  /// No description provided for @agentProfit7.
  ///
  /// In uz, this message translates to:
  /// **'7 kun'**
  String get agentProfit7;

  /// No description provided for @agentProfit30.
  ///
  /// In uz, this message translates to:
  /// **'30 kun'**
  String get agentProfit30;

  /// No description provided for @agentProfitRevenue.
  ///
  /// In uz, this message translates to:
  /// **'Sotuv summasi'**
  String get agentProfitRevenue;

  /// No description provided for @agentProfitCost.
  ///
  /// In uz, this message translates to:
  /// **'Egaga to\'lanadigan narx'**
  String get agentProfitCost;

  /// No description provided for @agentProfitPending.
  ///
  /// In uz, this message translates to:
  /// **'Mijozlar qarzidagi foyda'**
  String get agentProfitPending;

  /// No description provided for @agentProfitHint.
  ///
  /// In uz, this message translates to:
  /// **'Qarzga sotuvlar foydasi mijoz to\'lagach qo\'shiladi'**
  String get agentProfitHint;

  /// No description provided for @agentShortcutProducts.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulotlarim'**
  String get agentShortcutProducts;

  /// No description provided for @agentNoStock.
  ///
  /// In uz, this message translates to:
  /// **'Hozircha mahsulot yo\'q'**
  String get agentNoStock;

  /// No description provided for @agentNoStockHint.
  ///
  /// In uz, this message translates to:
  /// **'Biznes egasi mahsulot berganda shu yerda paydo bo\'ladi.'**
  String get agentNoStockHint;

  /// No description provided for @agentStockLeft.
  ///
  /// In uz, this message translates to:
  /// **'Qoldi: {qty}'**
  String agentStockLeft(String qty);

  /// No description provided for @agentPriceRange.
  ///
  /// In uz, this message translates to:
  /// **'{min} – {max}'**
  String agentPriceRange(String min, String max);

  /// No description provided for @agentOtherCurrency.
  ///
  /// In uz, this message translates to:
  /// **'Bitta sotuvda bitta valyuta bo\'ladi'**
  String get agentOtherCurrency;

  /// No description provided for @agentCartCount.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta mahsulot'**
  String agentCartCount(int count);

  /// No description provided for @agentCheckout.
  ///
  /// In uz, this message translates to:
  /// **'Rasmiylashtirish'**
  String get agentCheckout;

  /// No description provided for @agentCheckoutTitle.
  ///
  /// In uz, this message translates to:
  /// **'Sotuv'**
  String get agentCheckoutTitle;

  /// No description provided for @agentQuantity.
  ///
  /// In uz, this message translates to:
  /// **'Miqdori'**
  String get agentQuantity;

  /// No description provided for @agentPrice.
  ///
  /// In uz, this message translates to:
  /// **'Narx'**
  String get agentPrice;

  /// No description provided for @agentPriceOutOfRange.
  ///
  /// In uz, this message translates to:
  /// **'«{name}»: narx {min} – {max} oralig\'ida bo\'lsin'**
  String agentPriceOutOfRange(String name, String min, String max);

  /// No description provided for @agentQtyInvalid.
  ///
  /// In uz, this message translates to:
  /// **'«{name}»: miqdorni kiriting'**
  String agentQtyInvalid(String name);

  /// No description provided for @agentQtyTooMuch.
  ///
  /// In uz, this message translates to:
  /// **'«{name}»: faqat {qty} bor'**
  String agentQtyTooMuch(String name, String qty);

  /// No description provided for @agentCash.
  ///
  /// In uz, this message translates to:
  /// **'Naqd'**
  String get agentCash;

  /// No description provided for @agentDebt.
  ///
  /// In uz, this message translates to:
  /// **'Qarzga'**
  String get agentDebt;

  /// No description provided for @agentCustomer.
  ///
  /// In uz, this message translates to:
  /// **'Xaridor'**
  String get agentCustomer;

  /// No description provided for @agentCustomerName.
  ///
  /// In uz, this message translates to:
  /// **'Ismi'**
  String get agentCustomerName;

  /// No description provided for @agentCustomerLastName.
  ///
  /// In uz, this message translates to:
  /// **'Familiyasi (ixtiyoriy)'**
  String get agentCustomerLastName;

  /// No description provided for @agentCustomerPhone.
  ///
  /// In uz, this message translates to:
  /// **'Telefon raqami'**
  String get agentCustomerPhone;

  /// No description provided for @agentCustomerOptional.
  ///
  /// In uz, this message translates to:
  /// **'Xaridor ma\'lumotlari ixtiyoriy'**
  String get agentCustomerOptional;

  /// No description provided for @agentReturningDebtorHint.
  ///
  /// In uz, this message translates to:
  /// **'Raqam avval yozilgan bo\'lsa, qarz o\'sha xaridorga qo\'shiladi'**
  String get agentReturningDebtorHint;

  /// No description provided for @agentDebtNeedsCustomer.
  ///
  /// In uz, this message translates to:
  /// **'Qarzga sotish uchun ism va telefon kerak'**
  String get agentDebtNeedsCustomer;

  /// No description provided for @agentPhoneInvalid.
  ///
  /// In uz, this message translates to:
  /// **'Telefon raqami noto\'g\'ri'**
  String get agentPhoneInvalid;

  /// No description provided for @agentSellNow.
  ///
  /// In uz, this message translates to:
  /// **'Sotish · {total}'**
  String agentSellNow(String total);

  /// No description provided for @agentSold.
  ///
  /// In uz, this message translates to:
  /// **'Sotuv saqlandi'**
  String get agentSold;

  /// No description provided for @agentSalesEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Hali sotuv yo\'q'**
  String get agentSalesEmpty;

  /// No description provided for @agentSaleSeller.
  ///
  /// In uz, this message translates to:
  /// **'Sotuvchi: {name}'**
  String agentSaleSeller(String name);

  /// No description provided for @agentLineCost.
  ///
  /// In uz, this message translates to:
  /// **'Tannarx: {amount}'**
  String agentLineCost(String amount);

  /// No description provided for @agentDebtsOpen.
  ///
  /// In uz, this message translates to:
  /// **'Ochiq'**
  String get agentDebtsOpen;

  /// No description provided for @agentDebtsAll.
  ///
  /// In uz, this message translates to:
  /// **'Hammasi'**
  String get agentDebtsAll;

  /// No description provided for @agentDebtsEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Qarz yo\'q'**
  String get agentDebtsEmpty;

  /// No description provided for @agentDebtsTotal.
  ///
  /// In uz, this message translates to:
  /// **'Jami qarz'**
  String get agentDebtsTotal;

  /// No description provided for @agentDebtOriginal.
  ///
  /// In uz, this message translates to:
  /// **'Qarz summasi'**
  String get agentDebtOriginal;

  /// No description provided for @agentDebtPaid.
  ///
  /// In uz, this message translates to:
  /// **'To\'langan'**
  String get agentDebtPaid;

  /// No description provided for @agentDebtBalance.
  ///
  /// In uz, this message translates to:
  /// **'Qoldiq'**
  String get agentDebtBalance;

  /// No description provided for @agentPayTitle.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov qabul qilish'**
  String get agentPayTitle;

  /// No description provided for @agentPayFull.
  ///
  /// In uz, this message translates to:
  /// **'To\'liq'**
  String get agentPayFull;

  /// No description provided for @agentPaySubmit.
  ///
  /// In uz, this message translates to:
  /// **'Qabul qilish'**
  String get agentPaySubmit;

  /// No description provided for @agentPaid.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov qabul qilindi'**
  String get agentPaid;

  /// No description provided for @agentPayInvalid.
  ///
  /// In uz, this message translates to:
  /// **'Summani kiriting'**
  String get agentPayInvalid;

  /// No description provided for @agentPayTooMuch.
  ///
  /// In uz, this message translates to:
  /// **'Summa qarz qoldig\'idan oshmasin'**
  String get agentPayTooMuch;

  /// No description provided for @agentPaymentsHistory.
  ///
  /// In uz, this message translates to:
  /// **'To\'lovlar tarixi'**
  String get agentPaymentsHistory;

  /// No description provided for @agentNoPayments.
  ///
  /// In uz, this message translates to:
  /// **'Hali to\'lov yo\'q'**
  String get agentNoPayments;

  /// No description provided for @agentDebtClosed.
  ///
  /// In uz, this message translates to:
  /// **'Qarz yopilgan'**
  String get agentDebtClosed;

  /// No description provided for @agentAccountTitle.
  ///
  /// In uz, this message translates to:
  /// **'Hisob-kitob'**
  String get agentAccountTitle;

  /// No description provided for @agentAccountWith.
  ///
  /// In uz, this message translates to:
  /// **'{owner} bilan hisob'**
  String agentAccountWith(String owner);

  /// No description provided for @agentMyDebt.
  ///
  /// In uz, this message translates to:
  /// **'Qarzim'**
  String get agentMyDebt;

  /// No description provided for @agentNothingOwed.
  ///
  /// In uz, this message translates to:
  /// **'Qarzingiz yo\'q'**
  String get agentNothingOwed;

  /// No description provided for @agentPendingPayments.
  ///
  /// In uz, this message translates to:
  /// **'Kutilayotgan to\'lovlar'**
  String get agentPendingPayments;

  /// No description provided for @agentPendingReturns.
  ///
  /// In uz, this message translates to:
  /// **'Kutilayotgan qaytarishlar'**
  String get agentPendingReturns;

  /// No description provided for @agentSendPayment.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov yuborish'**
  String get agentSendPayment;

  /// No description provided for @agentSendPaymentHint.
  ///
  /// In uz, this message translates to:
  /// **'Biznes egasiga bergan pulingizni yozing. U tasdiqlagach qarzingiz kamayadi.'**
  String get agentSendPaymentHint;

  /// No description provided for @agentPaymentSent.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov so\'rovi yuborildi'**
  String get agentPaymentSent;

  /// No description provided for @agentReturnGoods.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulot qaytarish'**
  String get agentReturnGoods;

  /// No description provided for @agentReturnHint.
  ///
  /// In uz, this message translates to:
  /// **'Qaytariladigan miqdorni kiriting. Mahsulotlar darhol zaxirangizdan ayriladi; biznes egasi tasdiqlagach qarzingiz kamayadi, rad etsa qaytib keladi.'**
  String get agentReturnHint;

  /// No description provided for @agentReturnSend.
  ///
  /// In uz, this message translates to:
  /// **'Qaytarish ({count})'**
  String agentReturnSend(int count);

  /// No description provided for @agentReturnSent.
  ///
  /// In uz, this message translates to:
  /// **'Qaytarish so\'rovi yuborildi'**
  String get agentReturnSent;

  /// No description provided for @agentReturnPickOne.
  ///
  /// In uz, this message translates to:
  /// **'Kamida bitta mahsulot miqdorini kiriting'**
  String get agentReturnPickOne;

  /// No description provided for @agentTabPayments.
  ///
  /// In uz, this message translates to:
  /// **'To\'lovlar'**
  String get agentTabPayments;

  /// No description provided for @agentTabReturns.
  ///
  /// In uz, this message translates to:
  /// **'Qaytarishlar'**
  String get agentTabReturns;

  /// No description provided for @agentStatusPending.
  ///
  /// In uz, this message translates to:
  /// **'Kutilmoqda'**
  String get agentStatusPending;

  /// No description provided for @agentStatusConfirmed.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlangan'**
  String get agentStatusConfirmed;

  /// No description provided for @agentStatusRejected.
  ///
  /// In uz, this message translates to:
  /// **'Rad etilgan'**
  String get agentStatusRejected;

  /// No description provided for @agentStatusCancelled.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilingan'**
  String get agentStatusCancelled;

  /// No description provided for @agentCancelRequest.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilish'**
  String get agentCancelRequest;

  /// No description provided for @agentCancelRequestConfirm.
  ///
  /// In uz, this message translates to:
  /// **'So\'rov bekor qilinsinmi?'**
  String get agentCancelRequestConfirm;

  /// No description provided for @agentRequestCancelled.
  ///
  /// In uz, this message translates to:
  /// **'So\'rov bekor qilindi'**
  String get agentRequestCancelled;

  /// No description provided for @agentPaymentsEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Hali to\'lov so\'rovi yo\'q'**
  String get agentPaymentsEmpty;

  /// No description provided for @agentReturnsEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Hali qaytarish yo\'q'**
  String get agentReturnsEmpty;

  /// No description provided for @agentReturnValue.
  ///
  /// In uz, this message translates to:
  /// **'Qiymati'**
  String get agentReturnValue;

  /// No description provided for @agentRefund.
  ///
  /// In uz, this message translates to:
  /// **'Naqd qaytarildi'**
  String get agentRefund;

  /// No description provided for @agentReturnFromTransfer.
  ///
  /// In uz, this message translates to:
  /// **'O\'tkazma {number}'**
  String agentReturnFromTransfer(String number);

  /// No description provided for @agentTransfersTitle.
  ///
  /// In uz, this message translates to:
  /// **'Kirimlar'**
  String get agentTransfersTitle;

  /// No description provided for @agentTransfersEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Hali kirim yo\'q'**
  String get agentTransfersEmpty;

  /// No description provided for @agentTransferPaid.
  ///
  /// In uz, this message translates to:
  /// **'To\'langan: {amount}'**
  String agentTransferPaid(String amount);

  /// No description provided for @agentTransferDebt.
  ///
  /// In uz, this message translates to:
  /// **'Qarz: {amount}'**
  String agentTransferDebt(String amount);

  /// No description provided for @agentTransferLineQty.
  ///
  /// In uz, this message translates to:
  /// **'Berildi {given} · qoldi {left}'**
  String agentTransferLineQty(String given, String left);

  /// No description provided for @agentTransferReturned.
  ///
  /// In uz, this message translates to:
  /// **'Qaytarildi {qty}'**
  String agentTransferReturned(String qty);

  /// No description provided for @agentTransferOwed.
  ///
  /// In uz, this message translates to:
  /// **'Narxi {price}'**
  String agentTransferOwed(String price);

  /// No description provided for @agentTransferRange.
  ///
  /// In uz, this message translates to:
  /// **'Sotish: {range}'**
  String agentTransferRange(String range);

  /// No description provided for @agentTransferGivenBy.
  ///
  /// In uz, this message translates to:
  /// **'Bergan: {name}'**
  String agentTransferGivenBy(String name);

  /// No description provided for @agentStaffTitle.
  ///
  /// In uz, this message translates to:
  /// **'Agentlar'**
  String get agentStaffTitle;

  /// No description provided for @agentStaffEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Hali agent yo\'q'**
  String get agentStaffEmpty;

  /// No description provided for @agentStaffNew.
  ///
  /// In uz, this message translates to:
  /// **'Yangi agent'**
  String get agentStaffNew;

  /// No description provided for @agentStaffEdit.
  ///
  /// In uz, this message translates to:
  /// **'Agentni tahrirlash'**
  String get agentStaffEdit;

  /// No description provided for @agentStaffDeleteTitle.
  ///
  /// In uz, this message translates to:
  /// **'Agentni o\'chirish'**
  String get agentStaffDeleteTitle;

  /// No description provided for @agentRejectReason.
  ///
  /// In uz, this message translates to:
  /// **'Sabab: {reason}'**
  String agentRejectReason(String reason);

  /// No description provided for @agentAvailableToSend.
  ///
  /// In uz, this message translates to:
  /// **'Yuborish mumkin: {amount}'**
  String agentAvailableToSend(String amount);

  /// No description provided for @navLeadAgents.
  ///
  /// In uz, this message translates to:
  /// **'Dillerlar'**
  String get navLeadAgents;

  /// No description provided for @ownerLeadNew.
  ///
  /// In uz, this message translates to:
  /// **'Yangi diller'**
  String get ownerLeadNew;

  /// No description provided for @ownerLeadEdit.
  ///
  /// In uz, this message translates to:
  /// **'Dillerni tahrirlash'**
  String get ownerLeadEdit;

  /// No description provided for @ownerLeadDeleteTitle.
  ///
  /// In uz, this message translates to:
  /// **'Dillerni o\'chirish'**
  String get ownerLeadDeleteTitle;

  /// No description provided for @ownerLeadsEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Hali diller yo\'q'**
  String get ownerLeadsEmpty;

  /// No description provided for @ownerLeadStoreHint.
  ///
  /// In uz, this message translates to:
  /// **'Diller shu do\'kon mahsulotlarini oladi'**
  String get ownerLeadStoreHint;

  /// No description provided for @ownerLeadStaffCount.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta agent'**
  String ownerLeadStaffCount(int count);

  /// No description provided for @ownerLeadPendingCount.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta so\'rov'**
  String ownerLeadPendingCount(int count);

  /// No description provided for @ownerLeadOwes.
  ///
  /// In uz, this message translates to:
  /// **'Menga qarzi'**
  String get ownerLeadOwes;

  /// No description provided for @ownerLeadStock.
  ///
  /// In uz, this message translates to:
  /// **'Qo\'lidagi mahsulotlar'**
  String get ownerLeadStock;

  /// No description provided for @ownerLeadStaff.
  ///
  /// In uz, this message translates to:
  /// **'Agentlari'**
  String get ownerLeadStaff;

  /// No description provided for @ownerTeamTitle.
  ///
  /// In uz, this message translates to:
  /// **'Jamoa savdosi'**
  String get ownerTeamTitle;

  /// No description provided for @ownerGiveProducts.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulot berish'**
  String get ownerGiveProducts;

  /// No description provided for @ownerTabStock.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulotlari'**
  String get ownerTabStock;

  /// No description provided for @ownerTabTransfers.
  ///
  /// In uz, this message translates to:
  /// **'Berilganlar'**
  String get ownerTabTransfers;

  /// No description provided for @ownerTabCustomerDebts.
  ///
  /// In uz, this message translates to:
  /// **'Mijoz qarzlari'**
  String get ownerTabCustomerDebts;

  /// No description provided for @ownerStockEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Dillerda mahsulot yo\'q'**
  String get ownerStockEmpty;

  /// No description provided for @ownerMinPrice.
  ///
  /// In uz, this message translates to:
  /// **'Eng kam narx'**
  String get ownerMinPrice;

  /// No description provided for @ownerMaxPrice.
  ///
  /// In uz, this message translates to:
  /// **'Eng yuqori narx'**
  String get ownerMaxPrice;

  /// No description provided for @ownerEditRange.
  ///
  /// In uz, this message translates to:
  /// **'Narx oralig\'ini o\'zgartirish'**
  String get ownerEditRange;

  /// No description provided for @ownerRangeUpdated.
  ///
  /// In uz, this message translates to:
  /// **'Narx oralig\'i yangilandi'**
  String get ownerRangeUpdated;

  /// No description provided for @ownerRangeInvalid.
  ///
  /// In uz, this message translates to:
  /// **'«{name}»: eng kam narx eng yuqori narxdan katta bo\'lmasin'**
  String ownerRangeInvalid(String name);

  /// No description provided for @ownerPriceInvalid.
  ///
  /// In uz, this message translates to:
  /// **'«{name}»: narxni kiriting'**
  String ownerPriceInvalid(String name);

  /// No description provided for @ownerMinBelowPrice.
  ///
  /// In uz, this message translates to:
  /// **'Eng kam narx diller to\'laydigan narxdan past'**
  String get ownerMinBelowPrice;

  /// No description provided for @ownerConfirm.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlash'**
  String get ownerConfirm;

  /// No description provided for @ownerReject.
  ///
  /// In uz, this message translates to:
  /// **'Rad etish'**
  String get ownerReject;

  /// No description provided for @ownerConfirmed.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlandi'**
  String get ownerConfirmed;

  /// No description provided for @ownerRejected.
  ///
  /// In uz, this message translates to:
  /// **'Rad etildi'**
  String get ownerRejected;

  /// No description provided for @ownerRejectTitle.
  ///
  /// In uz, this message translates to:
  /// **'So\'rovni rad etish'**
  String get ownerRejectTitle;

  /// No description provided for @ownerRejectReason.
  ///
  /// In uz, this message translates to:
  /// **'Sabab (ixtiyoriy)'**
  String get ownerRejectReason;

  /// No description provided for @ownerConfirmPaymentTitle.
  ///
  /// In uz, this message translates to:
  /// **'To\'lovni tasdiqlash'**
  String get ownerConfirmPaymentTitle;

  /// No description provided for @ownerConfirmPaymentText.
  ///
  /// In uz, this message translates to:
  /// **'{name} {amount} to\'laganini tasdiqlaysizmi? Summa eng eski qarzlaridan boshlab yopiladi.'**
  String ownerConfirmPaymentText(String name, String amount);

  /// No description provided for @ownerConfirmReturnTitle.
  ///
  /// In uz, this message translates to:
  /// **'Qaytarishni tasdiqlash'**
  String get ownerConfirmReturnTitle;

  /// No description provided for @ownerConfirmReturnText.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulotlar omboringizga qaytadi va dillerning qarzi kamayadi.'**
  String get ownerConfirmReturnText;

  /// No description provided for @ownerDebtReduceLine.
  ///
  /// In uz, this message translates to:
  /// **'Qarzdan ayriladi: {amount}'**
  String ownerDebtReduceLine(String amount);

  /// No description provided for @ownerRefundLine.
  ///
  /// In uz, this message translates to:
  /// **'Naqd qaytarasiz: {amount}'**
  String ownerRefundLine(String amount);

  /// No description provided for @ownerTransferEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Bu do\'konda berish uchun mahsulot yo\'q'**
  String get ownerTransferEmpty;

  /// No description provided for @ownerTransferInStock.
  ///
  /// In uz, this message translates to:
  /// **'Omborda: {qty}'**
  String ownerTransferInStock(String qty);

  /// No description provided for @ownerTransferHeld.
  ///
  /// In uz, this message translates to:
  /// **'Dillerda: {qty}'**
  String ownerTransferHeld(String qty);

  /// No description provided for @ownerTransferOneCurrency.
  ///
  /// In uz, this message translates to:
  /// **'Bitta berishda bitta valyuta bo\'ladi'**
  String get ownerTransferOneCurrency;

  /// No description provided for @ownerTransferPicked.
  ///
  /// In uz, this message translates to:
  /// **'Tanlanganlar'**
  String get ownerTransferPicked;

  /// No description provided for @ownerTransferPaid.
  ///
  /// In uz, this message translates to:
  /// **'Hozir to\'langan summa'**
  String get ownerTransferPaid;

  /// No description provided for @ownerTransferPaidTooMuch.
  ///
  /// In uz, this message translates to:
  /// **'To\'langan summa umumiy summadan oshmasin'**
  String get ownerTransferPaidTooMuch;

  /// No description provided for @ownerTransferDebtLine.
  ///
  /// In uz, this message translates to:
  /// **'Qarzga yoziladi: {amount}'**
  String ownerTransferDebtLine(String amount);

  /// No description provided for @ownerTransferSubmit.
  ///
  /// In uz, this message translates to:
  /// **'Berish ({count})'**
  String ownerTransferSubmit(int count);

  /// No description provided for @ownerTransferDone.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulotlar berildi'**
  String get ownerTransferDone;

  /// No description provided for @ownerTransferPickOne.
  ///
  /// In uz, this message translates to:
  /// **'Kamida bitta mahsulot tanlang'**
  String get ownerTransferPickOne;

  /// No description provided for @commonLoadMore.
  ///
  /// In uz, this message translates to:
  /// **'Yana ko\'rsatish'**
  String get commonLoadMore;

  /// No description provided for @navCrmDrivers.
  ///
  /// In uz, this message translates to:
  /// **'Haydovchilar'**
  String get navCrmDrivers;

  /// No description provided for @navCrmReminders.
  ///
  /// In uz, this message translates to:
  /// **'Eslatmalar'**
  String get navCrmReminders;

  /// No description provided for @crmDriversSearchHint.
  ///
  /// In uz, this message translates to:
  /// **'Ism, telefon yoki davlat raqami'**
  String get crmDriversSearchHint;

  /// No description provided for @crmDriversEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Hali haydovchilar yo\'q'**
  String get crmDriversEmpty;

  /// No description provided for @crmNotEnabled.
  ///
  /// In uz, this message translates to:
  /// **'CRM bu biznes uchun yoqilmagan'**
  String get crmNotEnabled;

  /// No description provided for @crmAddDriver.
  ///
  /// In uz, this message translates to:
  /// **'Haydovchi qo\'shish'**
  String get crmAddDriver;

  /// No description provided for @crmNewDriver.
  ///
  /// In uz, this message translates to:
  /// **'Yangi haydovchi'**
  String get crmNewDriver;

  /// No description provided for @crmEditDriver.
  ///
  /// In uz, this message translates to:
  /// **'Haydovchini tahrirlash'**
  String get crmEditDriver;

  /// No description provided for @crmLastName.
  ///
  /// In uz, this message translates to:
  /// **'Familiya'**
  String get crmLastName;

  /// No description provided for @crmPhoneHint.
  ///
  /// In uz, this message translates to:
  /// **'Shu raqam bilan do\'kon mijozlari ro\'yxatiga ham qo\'shiladi'**
  String get crmPhoneHint;

  /// No description provided for @crmFirstCar.
  ///
  /// In uz, this message translates to:
  /// **'Mashina (ixtiyoriy)'**
  String get crmFirstCar;

  /// No description provided for @crmPlate.
  ///
  /// In uz, this message translates to:
  /// **'Davlat raqami'**
  String get crmPlate;

  /// No description provided for @crmPlateMissing.
  ///
  /// In uz, this message translates to:
  /// **'Davlat raqamini kiriting'**
  String get crmPlateMissing;

  /// No description provided for @crmPlateInvalid.
  ///
  /// In uz, this message translates to:
  /// **'Davlat raqami noto\'g\'ri'**
  String get crmPlateInvalid;

  /// No description provided for @crmModel.
  ///
  /// In uz, this message translates to:
  /// **'Model'**
  String get crmModel;

  /// No description provided for @crmModelMissing.
  ///
  /// In uz, this message translates to:
  /// **'Mashina modelini kiriting'**
  String get crmModelMissing;

  /// No description provided for @crmDailyKm.
  ///
  /// In uz, this message translates to:
  /// **'Kuniga yuradigan masofa (km)'**
  String get crmDailyKm;

  /// No description provided for @crmDailyKmHint.
  ///
  /// In uz, this message translates to:
  /// **'Taxminan. Xizmat muddati shu asosida hisoblanadi'**
  String get crmDailyKmHint;

  /// No description provided for @crmDailyKmInvalid.
  ///
  /// In uz, this message translates to:
  /// **'1 dan 3000 gacha butun son kiriting'**
  String get crmDailyKmInvalid;

  /// No description provided for @crmActiveHint.
  ///
  /// In uz, this message translates to:
  /// **'Nofaol haydovchiga eslatmalar yuborilmaydi'**
  String get crmActiveHint;

  /// No description provided for @crmVehicles.
  ///
  /// In uz, this message translates to:
  /// **'Mashinalar'**
  String get crmVehicles;

  /// No description provided for @crmAddVehicle.
  ///
  /// In uz, this message translates to:
  /// **'Mashina qo\'shish'**
  String get crmAddVehicle;

  /// No description provided for @crmEditVehicle.
  ///
  /// In uz, this message translates to:
  /// **'Mashinani tahrirlash'**
  String get crmEditVehicle;

  /// No description provided for @crmNoVehicles.
  ///
  /// In uz, this message translates to:
  /// **'Mashina qo\'shilmagan'**
  String get crmNoVehicles;

  /// No description provided for @crmDailyKmValue.
  ///
  /// In uz, this message translates to:
  /// **'Kuniga ~{km} km'**
  String crmDailyKmValue(String km);

  /// No description provided for @crmDailyKmMissing.
  ///
  /// In uz, this message translates to:
  /// **'Kunlik masofa kiritilmagan'**
  String get crmDailyKmMissing;

  /// No description provided for @crmNextDue.
  ///
  /// In uz, this message translates to:
  /// **'Keyingi: {name}'**
  String crmNextDue(String name);

  /// No description provided for @crmRecordService.
  ///
  /// In uz, this message translates to:
  /// **'Xizmat yozish'**
  String get crmRecordService;

  /// No description provided for @crmHistory.
  ///
  /// In uz, this message translates to:
  /// **'Xizmatlar tarixi'**
  String get crmHistory;

  /// No description provided for @crmNoVisits.
  ///
  /// In uz, this message translates to:
  /// **'Hali xizmat yozilmagan'**
  String get crmNoVisits;

  /// No description provided for @crmLinkedCustomer.
  ///
  /// In uz, this message translates to:
  /// **'Mijozlar ro\'yxatida: {name}'**
  String crmLinkedCustomer(String name);

  /// No description provided for @crmInactiveNoService.
  ///
  /// In uz, this message translates to:
  /// **'Haydovchi nofaol: xizmat yozish uchun avval uni faollashtiring'**
  String get crmInactiveNoService;

  /// No description provided for @crmDeleteDriverTitle.
  ///
  /// In uz, this message translates to:
  /// **'Haydovchini o\'chirish'**
  String get crmDeleteDriverTitle;

  /// No description provided for @crmDeleteDriverConfirm.
  ///
  /// In uz, this message translates to:
  /// **'{name} va uning mashinalari o\'chiriladi. Mijozlar ro\'yxatidagi yozuvi va savdolari saqlanib qoladi.'**
  String crmDeleteDriverConfirm(String name);

  /// No description provided for @crmDeleteVehicleTitle.
  ///
  /// In uz, this message translates to:
  /// **'Mashinani o\'chirish'**
  String get crmDeleteVehicleTitle;

  /// No description provided for @crmDeleteVehicleConfirm.
  ///
  /// In uz, this message translates to:
  /// **'{plate} mashinasi o\'chiriladi.'**
  String crmDeleteVehicleConfirm(String plate);

  /// No description provided for @crmPhotoAdd.
  ///
  /// In uz, this message translates to:
  /// **'Rasm qo\'shish'**
  String get crmPhotoAdd;

  /// No description provided for @crmPhotoChange.
  ///
  /// In uz, this message translates to:
  /// **'Rasmni almashtirish'**
  String get crmPhotoChange;

  /// No description provided for @crmPhotoRemove.
  ///
  /// In uz, this message translates to:
  /// **'Rasmni o\'chirish'**
  String get crmPhotoRemove;

  /// No description provided for @crmDueToday.
  ///
  /// In uz, this message translates to:
  /// **'bugun'**
  String get crmDueToday;

  /// No description provided for @crmDueIn.
  ///
  /// In uz, this message translates to:
  /// **'{count} kun qoldi'**
  String crmDueIn(int count);

  /// No description provided for @crmOverdueBy.
  ///
  /// In uz, this message translates to:
  /// **'{count} kun o\'tdi'**
  String crmOverdueBy(int count);

  /// No description provided for @crmItemReplaced.
  ///
  /// In uz, this message translates to:
  /// **'Keyingi xizmatda almashtirildi'**
  String get crmItemReplaced;

  /// No description provided for @crmItemDone.
  ///
  /// In uz, this message translates to:
  /// **'Bajarildi'**
  String get crmItemDone;

  /// No description provided for @crmItemCancelled.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilingan'**
  String get crmItemCancelled;

  /// No description provided for @crmNoReminder.
  ///
  /// In uz, this message translates to:
  /// **'Eslatmasiz'**
  String get crmNoReminder;

  /// No description provided for @crmNoSale.
  ///
  /// In uz, this message translates to:
  /// **'Sotuvsiz'**
  String get crmNoSale;

  /// No description provided for @crmSaleDebtLeft.
  ///
  /// In uz, this message translates to:
  /// **'Qarz: {amount}'**
  String crmSaleDebtLeft(String amount);

  /// No description provided for @crmSaleDebtSettled.
  ///
  /// In uz, this message translates to:
  /// **'Qarz to\'langan'**
  String get crmSaleDebtSettled;

  /// No description provided for @crmKmValue.
  ///
  /// In uz, this message translates to:
  /// **'{km} km'**
  String crmKmValue(String km);

  /// No description provided for @crmEveryKm.
  ///
  /// In uz, this message translates to:
  /// **'har {km} km'**
  String crmEveryKm(String km);

  /// No description provided for @crmAtKm.
  ///
  /// In uz, this message translates to:
  /// **'{km} km da'**
  String crmAtKm(String km);

  /// No description provided for @crmTgLinked.
  ///
  /// In uz, this message translates to:
  /// **'Telegram: eslatmalar boradi'**
  String get crmTgLinked;

  /// No description provided for @crmTgNotLinked.
  ///
  /// In uz, this message translates to:
  /// **'Telegram ulanmagan'**
  String get crmTgNotLinked;

  /// No description provided for @crmTgBlocked.
  ///
  /// In uz, this message translates to:
  /// **'Haydovchi botni bloklagan'**
  String get crmTgBlocked;

  /// No description provided for @crmTgNoBot.
  ///
  /// In uz, this message translates to:
  /// **'Do\'konga Telegram bot ulanmagan, eslatmalar haydovchiga Telegram orqali bormaydi'**
  String get crmTgNoBot;

  /// No description provided for @crmTgHowTo.
  ///
  /// In uz, this message translates to:
  /// **'Haydovchi do\'kon botini ochib, telefon raqamini yuborishi kerak'**
  String get crmTgHowTo;

  /// No description provided for @crmTgShareLink.
  ///
  /// In uz, this message translates to:
  /// **'Bot havolasini yuborish'**
  String get crmTgShareLink;

  /// No description provided for @crmVisitTitle.
  ///
  /// In uz, this message translates to:
  /// **'Xizmat yozish'**
  String get crmVisitTitle;

  /// No description provided for @crmServiceDate.
  ///
  /// In uz, this message translates to:
  /// **'Xizmat sanasi'**
  String get crmServiceDate;

  /// No description provided for @crmOdometer.
  ///
  /// In uz, this message translates to:
  /// **'Spidometr (km)'**
  String get crmOdometer;

  /// No description provided for @crmParts.
  ///
  /// In uz, this message translates to:
  /// **'O\'rnatilgan qismlar'**
  String get crmParts;

  /// No description provided for @crmAddPart.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulot qo\'shish'**
  String get crmAddPart;

  /// No description provided for @crmAddManual.
  ///
  /// In uz, this message translates to:
  /// **'Qo\'lda'**
  String get crmAddManual;

  /// No description provided for @crmPartSearch.
  ///
  /// In uz, this message translates to:
  /// **'Ehtiyot qism yoki moy qidirish'**
  String get crmPartSearch;

  /// No description provided for @crmPartsEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulot yoki qo\'lda qator qo\'shing'**
  String get crmPartsEmpty;

  /// No description provided for @crmManualName.
  ///
  /// In uz, this message translates to:
  /// **'Nomi (masalan: Ish haqi)'**
  String get crmManualName;

  /// No description provided for @crmQuantity.
  ///
  /// In uz, this message translates to:
  /// **'Miqdor'**
  String get crmQuantity;

  /// No description provided for @crmIntervalKm.
  ///
  /// In uz, this message translates to:
  /// **'Keyingi xizmatgacha, km'**
  String get crmIntervalKm;

  /// No description provided for @crmNextDate.
  ///
  /// In uz, this message translates to:
  /// **'Keyingi sana'**
  String get crmNextDate;

  /// No description provided for @crmDueAuto.
  ///
  /// In uz, this message translates to:
  /// **'Taxminan {date} da qaytib keladi'**
  String crmDueAuto(String date);

  /// No description provided for @crmDueManual.
  ///
  /// In uz, this message translates to:
  /// **'Sana qo\'lda kiritildi'**
  String get crmDueManual;

  /// No description provided for @crmDueNeedsDate.
  ///
  /// In uz, this message translates to:
  /// **'Kunlik masofa yo\'q — sanani kiriting'**
  String get crmDueNeedsDate;

  /// No description provided for @crmRecordSale.
  ///
  /// In uz, this message translates to:
  /// **'Sotuv sifatida yozish'**
  String get crmRecordSale;

  /// No description provided for @crmRecordSaleOn.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulot ombordan chiqadi, to\'lov yoki qarz yoziladi'**
  String get crmRecordSaleOn;

  /// No description provided for @crmRecordSaleOff.
  ///
  /// In uz, this message translates to:
  /// **'Faqat eslatma uchun: ombor va pul o\'zgarmaydi'**
  String get crmRecordSaleOff;

  /// No description provided for @crmPaidNow.
  ///
  /// In uz, this message translates to:
  /// **'Hozir to\'langan summa (ixtiyoriy)'**
  String get crmPaidNow;

  /// No description provided for @crmDebtLeft.
  ///
  /// In uz, this message translates to:
  /// **'Qarz: {amount}'**
  String crmDebtLeft(String amount);

  /// No description provided for @crmSaveVisit.
  ///
  /// In uz, this message translates to:
  /// **'Xizmatni saqlash'**
  String get crmSaveVisit;

  /// No description provided for @crmVisitSaved.
  ///
  /// In uz, this message translates to:
  /// **'Xizmat yozildi'**
  String get crmVisitSaved;

  /// No description provided for @crmInStock.
  ///
  /// In uz, this message translates to:
  /// **'Omborda: {qty}'**
  String crmInStock(String qty);

  /// No description provided for @crmPickVehicle.
  ///
  /// In uz, this message translates to:
  /// **'Mashinani tanlang'**
  String get crmPickVehicle;

  /// No description provided for @crmAddPartFirst.
  ///
  /// In uz, this message translates to:
  /// **'Kamida bitta qator qo\'shing'**
  String get crmAddPartFirst;

  /// No description provided for @crmManualNameMissing.
  ///
  /// In uz, this message translates to:
  /// **'Qo\'lda qo\'shilgan qator nomini kiriting'**
  String get crmManualNameMissing;

  /// No description provided for @crmPriceMissing.
  ///
  /// In uz, this message translates to:
  /// **'\"{name}\" uchun narxni kiriting'**
  String crmPriceMissing(String name);

  /// No description provided for @crmNotEnoughStock.
  ///
  /// In uz, this message translates to:
  /// **'\"{name}\" omborda yetarli emas'**
  String crmNotEnoughStock(String name);

  /// No description provided for @crmDueAfterService.
  ///
  /// In uz, this message translates to:
  /// **'\"{name}\" uchun keyingi sana xizmat sanasidan keyin bo\'lishi kerak'**
  String crmDueAfterService(String name);

  /// No description provided for @crmDueNeeded.
  ///
  /// In uz, this message translates to:
  /// **'Kunlik masofa kiritilmagan: \"{name}\" uchun keyingi sanani tanlang'**
  String crmDueNeeded(String name);

  /// No description provided for @crmPaidTooMuch.
  ///
  /// In uz, this message translates to:
  /// **'To\'langan summa jami summadan oshmasligi kerak'**
  String get crmPaidTooMuch;

  /// No description provided for @crmMixedCurrency.
  ///
  /// In uz, this message translates to:
  /// **'Bitta xizmatda faqat bitta valyutadagi mahsulotlar bo\'lishi mumkin'**
  String get crmMixedCurrency;

  /// No description provided for @crmRemindersAll.
  ///
  /// In uz, this message translates to:
  /// **'Barchasi'**
  String get crmRemindersAll;

  /// No description provided for @crmRemindersOverdue.
  ///
  /// In uz, this message translates to:
  /// **'Muddati o\'tgan'**
  String get crmRemindersOverdue;

  /// No description provided for @crmRemindersSoon.
  ///
  /// In uz, this message translates to:
  /// **'7 kun ichida'**
  String get crmRemindersSoon;

  /// No description provided for @crmRemindersEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Eslatmalar yo\'q'**
  String get crmRemindersEmpty;

  /// No description provided for @crmMarkDone.
  ///
  /// In uz, this message translates to:
  /// **'Bajarildi'**
  String get crmMarkDone;

  /// No description provided for @crmMoveDate.
  ///
  /// In uz, this message translates to:
  /// **'Sanani o\'zgartirish'**
  String get crmMoveDate;

  /// No description provided for @crmCancelReminder.
  ///
  /// In uz, this message translates to:
  /// **'Eslatmani bekor qilish'**
  String get crmCancelReminder;

  /// No description provided for @crmReminderDone.
  ///
  /// In uz, this message translates to:
  /// **'Bajarildi deb belgilandi'**
  String get crmReminderDone;

  /// No description provided for @crmReminderCancelled.
  ///
  /// In uz, this message translates to:
  /// **'Eslatma bekor qilindi'**
  String get crmReminderCancelled;

  /// No description provided for @crmDateMoved.
  ///
  /// In uz, this message translates to:
  /// **'Sana o\'zgartirildi'**
  String get crmDateMoved;

  /// No description provided for @crmDueManualShort.
  ///
  /// In uz, this message translates to:
  /// **'Sana qo\'lda kiritilgan'**
  String get crmDueManualShort;

  /// No description provided for @crmDriverSaved.
  ///
  /// In uz, this message translates to:
  /// **'Haydovchi saqlandi'**
  String get crmDriverSaved;

  /// No description provided for @crmVehicleSaved.
  ///
  /// In uz, this message translates to:
  /// **'Mashina saqlandi'**
  String get crmVehicleSaved;

  /// No description provided for @notifTitle.
  ///
  /// In uz, this message translates to:
  /// **'Bildirishnomalar'**
  String get notifTitle;

  /// No description provided for @notifEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Hozircha bildirishnoma yo\'q'**
  String get notifEmpty;

  /// No description provided for @notifReadAll.
  ///
  /// In uz, this message translates to:
  /// **'Hammasini o\'qilgan qilish'**
  String get notifReadAll;

  /// No description provided for @notifServiceDueStaff.
  ///
  /// In uz, this message translates to:
  /// **'{plate} — xizmat vaqti ({driver})'**
  String notifServiceDueStaff(String plate, String driver);

  /// No description provided for @notifDriverNotified.
  ///
  /// In uz, this message translates to:
  /// **'Haydovchiga Telegram orqali eslatildi'**
  String get notifDriverNotified;

  /// No description provided for @notifCallDriver.
  ///
  /// In uz, this message translates to:
  /// **'Haydovchi botga ulanmagan — qo\'ng\'iroq qiling: {phone}'**
  String notifCallDriver(String phone);

  /// No description provided for @notifServiceDueDriver.
  ///
  /// In uz, this message translates to:
  /// **'{store}: xizmat vaqti yaqinlashdi'**
  String notifServiceDueDriver(String store);

  /// No description provided for @notifUnknown.
  ///
  /// In uz, this message translates to:
  /// **'Yangi bildirishnoma'**
  String get notifUnknown;
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
