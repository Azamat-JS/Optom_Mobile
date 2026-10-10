// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonLogout => 'Log out';

  @override
  String get commonLogin => 'Log in';

  @override
  String get commonRegister => 'Sign up';

  @override
  String get commonSettings => 'Settings';

  @override
  String get commonUnknownError => 'An unknown error occurred.';

  @override
  String roleLabel(String role) {
    String _temp0 = intl.Intl.selectLogic(role, {
      'superAdmin': 'Super Admin',
      'seller': 'Wholesaler',
      'sellerAdmin': 'Wholesaler staff',
      'retailer': 'Retailer',
      'retailerAdmin': 'Retailer staff',
      'customer': 'Customer',
      'waiter': 'Waiter',
      'courier': 'Courier',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get languageTitle => 'Language';

  @override
  String get languageHint => 'Choose the interface language';

  @override
  String get languageChange => 'Change language';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAccount => 'Account';

  @override
  String get authPhoneLabel => 'Phone number';

  @override
  String get authPhoneRequired => 'Phone number is required';

  @override
  String get authPhoneFormat => 'Format: +998XXXXXXXXX';

  @override
  String get loginSubtitle => 'Sign in to Optom Savdo';

  @override
  String get loginContinueWithTelegram => 'Continue with Telegram';

  @override
  String get loginAccountAutoCreated =>
      'If you don\'t have an account, one will be created automatically';

  @override
  String get loginWithPassword => 'Log in with password';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginPasswordRequired => 'Password is required';

  @override
  String get loginPasswordMinLength => 'At least 6 characters';

  @override
  String get registerSubtitle => 'Create a customer account';

  @override
  String get registerHint =>
      'Your number is verified through Telegram. Your name is taken from your Telegram profile — you can change it later in your profile.';

  @override
  String get registerWithTelegram => 'Sign up with Telegram';

  @override
  String get registerHaveAccount => 'Already have an account? Log in';

  @override
  String get splashError => 'Something went wrong while starting the app.';

  @override
  String get tgTitle => 'Verify with Telegram';

  @override
  String get tgOpenFailed =>
      'Couldn\'t open Telegram. Make sure the app is installed.';

  @override
  String get tgPhoneVerified => 'Your number is verified ✅';

  @override
  String get tgWelcomeNew => 'Welcome! Your account has been created.';

  @override
  String get tgWelcome => 'Welcome!';

  @override
  String get tgChangePhone => 'Change number';

  @override
  String get tgPreparing => 'Preparing…';

  @override
  String get tgVerified => 'Verified';

  @override
  String get tgVerifiedLoggingIn => 'Verified, logging in…';

  @override
  String get tgFinishStepVerify =>
      'Come back to the app — verification finishes automatically';

  @override
  String get tgFinishStepLogin =>
      'Come back to the app — you\'ll be logged in automatically';

  @override
  String get tgMismatchTitle => 'Number doesn\'t match';

  @override
  String tgMismatchOwn(String phone) {
    return 'The number on your Telegram account doesn\'t match $phone on your profile. Use the Telegram account linked to that number.';
  }

  @override
  String tgMismatch(String phone) {
    return 'The number on your Telegram account doesn\'t match $phone. Use the Telegram account linked to that number, or change the number.';
  }

  @override
  String get tgExpiredTitle => 'Verification expired';

  @override
  String get tgExpiredMessage =>
      'The number wasn\'t verified within 10 minutes. Please try again.';

  @override
  String get tgFailedTitle => 'Couldn\'t verify';

  @override
  String get tgConfirmInTelegram => 'Confirm in Telegram';

  @override
  String get tgStep1 => 'The bsmart verification bot opens in Telegram';

  @override
  String get tgStep2 => 'Tap «Start»';

  @override
  String get tgStep3 => 'Tap «📱 Raqamni tasdiqlash» (verify number)';

  @override
  String tgWaiting(String countdown) {
    return 'Waiting for confirmation · $countdown';
  }

  @override
  String get tgOpenTelegram => 'Open Telegram';

  @override
  String get verifyBannerAction => 'Verify number';

  @override
  String get verifyBannerProfile =>
      'Verify your phone number via Telegram to track restaurant deliveries and see your debts.';

  @override
  String get verifyBannerDebts =>
      'Verify your phone number via Telegram to see your debts at stores.';

  @override
  String get verifyBannerDeliveries =>
      'Verify your phone number via Telegram to track orders you placed with a restaurant by phone.';

  @override
  String get tgNotifTitle => 'Telegram notifications';

  @override
  String get tgNotifConnect => 'Connect';

  @override
  String get tgNotifOff => 'Off';

  @override
  String get tgNotifCustomerEnabled =>
      'You\'ll get a message when the courier picks up, arrives with and hands over your order';

  @override
  String get tgNotifCustomerLink =>
      'Verify your number via Telegram to get a message when your order is on its way';

  @override
  String get tgNotifCourierEnabled =>
      'You\'ll get a message when a delivery is assigned, offered or cancelled';

  @override
  String get tgNotifCourierLink =>
      'Verify your number to get new-delivery alerts in Telegram';

  @override
  String get tgNotifLinkTelegram => 'Connect Telegram';

  @override
  String get tgNotifEnabled => 'Notifications on';

  @override
  String get tgNotifDisabled => 'Notifications off';

  @override
  String get navCatalog => 'Catalog';

  @override
  String get navCart => 'Cart';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get navProfile => 'Profile';

  @override
  String get navMenu => 'Menu';

  @override
  String get navDeliveries => 'Deliveries';

  @override
  String get navPos => 'POS';

  @override
  String get navOrders => 'Orders';

  @override
  String get navProducts => 'Products';

  @override
  String get navCustomers => 'Customers';

  @override
  String get navSalesHistory => 'Sales history';

  @override
  String get navDebts => 'Debts';

  @override
  String get navReports => 'Reports';

  @override
  String get navFleetMap => 'Courier map';

  @override
  String get navRestaurantOrders => 'Restaurant orders';

  @override
  String get navTables => 'Tables';

  @override
  String get navStores => 'Stores';

  @override
  String get navStaff => 'Staff';

  @override
  String get navWaiters => 'Waiters';

  @override
  String get navCouriers => 'Couriers';

  @override
  String get navExpenditures => 'My expenses';

  @override
  String get navUsers => 'Users';

  @override
  String get navCategories => 'Categories';

  @override
  String get navCatalogModeration => 'Catalog moderation';

  @override
  String get profileLoginPrompt => 'Log in to see your profile';

  @override
  String get profilePhoneVerified => 'Number verified';

  @override
  String get profileMyOrders => 'My orders';

  @override
  String get profileMyDeliveries => 'My deliveries';

  @override
  String get profileMyDebts => 'My debts';

  @override
  String homeWelcome(String name) {
    return 'Welcome, $name';
  }

  @override
  String get homeStatistics => 'Statistics';

  @override
  String get homeStatsLoadFailed => 'Couldn\'t load statistics';

  @override
  String get homeTodaySales => 'Today\'s sales';

  @override
  String get homeTotalSales => 'Total sales';

  @override
  String homeSalesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sales',
      one: '$count sale',
    );
    return '$_temp0';
  }

  @override
  String get homeOutstandingDebt => 'Outstanding debt';

  @override
  String get homeReceivedPayments => 'Payments received';

  @override
  String get homeCustomerDebts => 'Customer debts';

  @override
  String get homeWholesalerDebts => 'Wholesaler debts';
}
