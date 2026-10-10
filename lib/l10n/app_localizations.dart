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
