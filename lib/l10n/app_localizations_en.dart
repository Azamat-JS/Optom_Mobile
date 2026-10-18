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
  String get authTagline => 'Smart trade, whole business';

  @override
  String get authEnterNumber => 'Enter your number';

  @override
  String get authSkip => 'Later';

  @override
  String get authOr => 'or';

  @override
  String get authClear => 'Clear';

  @override
  String get tgVerifyingNumber => 'Number to confirm';

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

  @override
  String enumOrderStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'newOrder': 'New',
      'approved': 'Approved',
      'rejected': 'Rejected',
      'delivered': 'Delivered',
      'debtRecorded': 'Recorded as debt',
      'paid': 'Paid',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String enumPaymentMethod(String method) {
    String _temp0 = intl.Intl.selectLogic(method, {
      'cash': 'Cash',
      'card': 'Card',
      'bankTransfer': 'Bank transfer',
      'click': 'Click',
      'payme': 'Payme',
      'debt': 'On credit',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String enumBusinessType(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'general': 'Shop',
      'restaurant': 'Restaurant',
      'applianceStore': 'Home appliances',
      'constructionTools': 'Construction supplies',
      'toyStore': 'Toys',
      'autoParts': 'Auto parts',
      'pharmacy': 'Pharmacy',
      'clothingStore': 'Clothing',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String enumExpenditureType(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'electricity': 'Electricity',
      'gas': 'Gas',
      'water': 'Water',
      'taxes': 'Taxes',
      'renting': 'Rent',
      'other': 'Other',
    });
    return '$_temp0';
  }

  @override
  String enumProductUnit(String unit) {
    String _temp0 = intl.Intl.selectLogic(unit, {
      'dona': 'Pcs',
      'metr': 'Meter',
      'litr': 'Liter',
      'kilogram': 'Kilogram',
      'gram': 'Gram',
      'blok': 'Block',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String enumRestaurantOrderType(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'dineIn': 'Dine-in',
      'delivery': 'Delivery',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String enumRestaurantOrderStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'newOrder': 'New',
      'preparing': 'Preparing',
      'ready': 'Ready',
      'served': 'Served',
      'delivered': 'Delivered',
      'cancelled': 'Cancelled',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String enumSaleType(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'paid': 'Paid',
      'debt': 'On credit',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String enumSaleStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'completed': 'Completed',
      'cancelled': 'Cancelled',
      'partiallyReturned': 'Partially returned',
      'returned': 'Returned',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String enumDebtStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'active': 'Active',
      'partial': 'Partially paid',
      'settled': 'Settled',
      'overdue': 'Overdue',
      'writtenOff': 'Written off',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get currencySom => 'so\'m';

  @override
  String get errorSessionExpired =>
      'Your session has expired. Please sign in again.';

  @override
  String get errorForbidden => 'You don\'t have permission to do this.';

  @override
  String get errorNotFound => 'Not found.';

  @override
  String get errorConflict =>
      'Couldn\'t complete the action because of a conflict.';

  @override
  String get errorNoInternet => 'No internet connection.';

  @override
  String get errorInvalidData => 'Some of the data is invalid.';

  @override
  String get tgTooManyAttempts =>
      'Too many attempts for this number. Please try again a little later.';

  @override
  String get tgUnavailable =>
      'Telegram verification is temporarily unavailable. Please try again later.';

  @override
  String get tgInvalidPhone => 'Invalid phone number. Format: +998XXXXXXXXX';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonActive => 'Active';

  @override
  String get commonInactive => 'Inactive';

  @override
  String get commonAll => 'All';

  @override
  String get commonNone => 'None';

  @override
  String get commonNotSelected => 'Not selected';

  @override
  String get commonNotSelectedDash => '— Not selected —';

  @override
  String commonErrorWith(String error) {
    return 'Error: $error';
  }

  @override
  String get commonNothingFound => 'Nothing found';

  @override
  String get commonReject => 'Reject';

  @override
  String get commonReasonOptional => 'Reason (optional)';

  @override
  String get commonName => 'Name';

  @override
  String get commonNameRequired => 'Name *';

  @override
  String get commonNameMissing => 'Enter a name';

  @override
  String get commonDescription => 'Description';

  @override
  String get commonCategory => 'Category';

  @override
  String get commonBrand => 'Brand';

  @override
  String get commonBarcode => 'Barcode';

  @override
  String get commonPrice => 'Price';

  @override
  String get commonPriceRequired => 'Price *';

  @override
  String get commonCostPrice => 'Cost price';

  @override
  String get commonStock => 'Stock';

  @override
  String get commonUnit => 'Unit';

  @override
  String get commonCurrency => 'Currency';

  @override
  String get commonCurrencyRequired => 'Currency *';

  @override
  String get currencyUzsLong => 'So\'m (UZS)';

  @override
  String get currencyUsdLong => 'Dollar (USD)';

  @override
  String get commonQuantityRequired => 'Enter a quantity';

  @override
  String get productsTitle => 'Products';

  @override
  String get productsProduct => 'Product';

  @override
  String get productsSentToCatalog => 'Sent to the catalog for review';

  @override
  String get productsDeleteTitle => 'Delete product';

  @override
  String get productsDeleteConfirm => 'Delete this product?';

  @override
  String productsCostPriceWith(String price) {
    return 'Cost price: $price';
  }

  @override
  String get productsAddStock => 'Add stock';

  @override
  String get productsCreateBarcode => 'Create barcode';

  @override
  String get productsShareToCatalog => 'Share to catalog';

  @override
  String get productsNameOrCatalog =>
      'Enter a product name or pick one from the catalog';

  @override
  String get productsPriceInvalid => 'The price is invalid';

  @override
  String get productsEditTitle => 'Edit product';

  @override
  String get productsNewTitle => 'New product';

  @override
  String get productsPriceRequired => 'Enter a price';

  @override
  String get productsInitialStock => 'Initial stock';

  @override
  String productsStockEditHint(String stock) {
    return '$stock — to change it, use the \"Add stock\" button on the product page';
  }

  @override
  String get productsPluSuggest => 'Suggest';

  @override
  String get productsExpiryOptional => 'Expiry date (optional)';

  @override
  String get productsPickFromCatalog => 'Pick from catalog';

  @override
  String get productsNameRequired => 'Product name *';

  @override
  String get productsFindTitle => 'Find product';

  @override
  String get productsSearchHint => 'Search by name or barcode...';

  @override
  String get productsNotFound => 'No products found';

  @override
  String productsCurrentStock(String stock) {
    return 'Current stock: $stock';
  }

  @override
  String get productsAddQuantity => 'Quantity to add';

  @override
  String get productsCorrectionOptional => 'Extra adjustment (optional)';

  @override
  String get productsCorrectionHint => 'Negative numbers are allowed';

  @override
  String get commonConfirm => 'Approve';

  @override
  String get commonDone => 'Done';

  @override
  String get commonSearchHint => 'Search...';

  @override
  String get commonInactiveShort => 'Inactive';

  @override
  String commonDeleteWithDependentsConfirm(String name) {
    return 'Delete $name? If any products depend on it, you\'ll get an error.';
  }

  @override
  String get masterStatusPending => 'Pending';

  @override
  String get masterStatusApproved => 'Approved';

  @override
  String get masterStatusRejected => 'Rejected';

  @override
  String get masterDeleteTitle => 'Delete catalog entry';

  @override
  String get masterReviewTitle => 'Catalog review';

  @override
  String get masterEditTitle => 'Edit catalog entry';

  @override
  String get masterNewTitle => 'New catalog entry';

  @override
  String get masterActiveVisible => 'Active (visible in the catalog)';

  @override
  String get masterSearchHint => 'Search the catalog...';

  @override
  String get categoriesDeleteTitle => 'Delete category';

  @override
  String get categoriesTitle => 'Categories';

  @override
  String get categoriesNotFound => 'No categories found';

  @override
  String get categoriesEditTitle => 'Edit category';

  @override
  String get categoriesNewTitle => 'New category';

  @override
  String get categoriesParent => 'Parent category';

  @override
  String get categoriesNoParent => '— None (top-level category) —';

  @override
  String get categoriesSortOrder => 'Sort order';

  @override
  String get categoriesPickerNotFound => 'No category found';

  @override
  String get commonDeactivate => 'Deactivate';

  @override
  String get commonFirstNameRequired => 'First name *';

  @override
  String get commonFirstNameMissing => 'Enter a first name';

  @override
  String get commonLastNameRequired => 'Last name *';

  @override
  String get commonLastNameMissing => 'Enter a last name';

  @override
  String get commonPhoneRequired => 'Phone *';

  @override
  String get commonPhoneMissing => 'Enter a phone number';

  @override
  String get commonInvalidFormat => 'Invalid format';

  @override
  String get commonAddress => 'Address';

  @override
  String get commonNote => 'Note';

  @override
  String get commonTotal => 'Total';

  @override
  String get commonSubtotal => 'Subtotal';

  @override
  String get commonDiscount => 'Discount';

  @override
  String commonPieces(String count) {
    return '$count pcs';
  }

  @override
  String commonProductCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count products',
      one: '$count product',
    );
    return '$_temp0';
  }

  @override
  String get commonProducts => 'Products';

  @override
  String get commonDeliveryAddress => 'Delivery address';

  @override
  String get customersDeactivateTitle => 'Deactivate customer';

  @override
  String customersDeactivateConfirm(String name) {
    return 'Deactivate $name?';
  }

  @override
  String get customersTitle => 'Customers';

  @override
  String get customersSearchHint => 'Search by name or phone...';

  @override
  String get customersNotFound => 'No customers found';

  @override
  String get customersEditTitle => 'Edit customer';

  @override
  String get customersNewTitle => 'New customer';

  @override
  String get ordersSingleCurrency =>
      'An order can only contain products in one currency';

  @override
  String ordersAddedToCart(String name) {
    return '$name added to cart';
  }

  @override
  String get ordersSearchProduct => 'Search products...';

  @override
  String get ordersAllBranches => 'All branches';

  @override
  String ordersCartSummary(int count, String total) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count products',
      one: '$count product',
    );
    return '$_temp0 — $total';
  }

  @override
  String get ordersPickWholesaler => 'Choose a wholesaler';

  @override
  String get ordersNoWholesalers => 'No wholesalers found';

  @override
  String get ordersIncomingTitle => 'Incoming orders';

  @override
  String get ordersMineTitle => 'My orders';

  @override
  String get ordersTabOutgoing => 'Outgoing';

  @override
  String get ordersTabIncoming => 'Incoming';

  @override
  String get ordersNotFound => 'No orders found';

  @override
  String get ordersReviewTitle => 'Review order';

  @override
  String get ordersPlace => 'Place order';

  @override
  String get ordersApproveTitle => 'Approve order';

  @override
  String get ordersApproveConfirm =>
      'Approve this order? Product stock will be reduced.';

  @override
  String get ordersRejectTitle => 'Reject order';

  @override
  String get ordersDeliveredTitle => 'Mark as delivered';

  @override
  String get ordersDeliveredConfirm =>
      'Confirm that this order has been delivered?';

  @override
  String get ordersOrder => 'Order';

  @override
  String ordersRejectionReason(String reason) {
    return 'Rejection reason: $reason';
  }

  @override
  String get ordersSeller => 'Seller';

  @override
  String get ordersBuyer => 'Buyer';

  @override
  String get ordersHistory => 'History';

  @override
  String get ordersDelivered => 'Delivered';

  @override
  String get commonUnknownPerson => 'Unknown';

  @override
  String get commonAmount => 'Amount';

  @override
  String get commonPaymentMethod => 'Payment method';

  @override
  String get commonNoteOptional => 'Note (optional)';

  @override
  String get commonClose => 'Close';

  @override
  String get commonDateRequired => 'Date *';

  @override
  String commonTotalWith(String amount) {
    return 'Total: $amount';
  }

  @override
  String commonBalanceWith(String amount) {
    return 'Balance: $amount';
  }

  @override
  String commonDueWith(String date) {
    return 'Due: $date';
  }

  @override
  String get expensesEditTitle => 'Edit expense';

  @override
  String get expensesNewTitle => 'New expense';

  @override
  String get expensesTypeRequired => 'Type *';

  @override
  String get expensesAmountRequired => 'Amount (so\'m) *';

  @override
  String get expensesAmountMissing => 'Enter an amount';

  @override
  String get expensesAmountInvalid => 'Invalid amount';

  @override
  String get expensesDeleteTitle => 'Delete expense';

  @override
  String expensesDeleteConfirm(String expense) {
    return 'Permanently delete $expense?';
  }

  @override
  String get expensesTitle => 'My expenses';

  @override
  String get expensesFilterByType => 'Filter by type';

  @override
  String get expensesTotal => 'Total expenses';

  @override
  String get expensesNotFound => 'No expenses found';

  @override
  String debtsPaymentsApplied(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Payment applied to $count debts',
      one: 'Payment applied to $count debt',
    );
    return '$_temp0';
  }

  @override
  String get debtsCloseTitle => 'Close debt';

  @override
  String debtsCloseConfirm(String amount) {
    return 'Mark the remaining $amount as fully paid?';
  }

  @override
  String debtsTotalBalance(String amount) {
    return 'Total balance: $amount';
  }

  @override
  String get debtsPayDownTitle => 'Combined payment (FIFO)';

  @override
  String get debtsPayDownHint =>
      'Distributed automatically, starting with the oldest debt';

  @override
  String get debtsAllocation => 'Allocation:';

  @override
  String get debtsWillClose => '(will be closed)';

  @override
  String get debtsExceedsTotal => 'The amount exceeds the total balance';

  @override
  String get debtsConfirmPayment => 'Confirm payment';

  @override
  String get debtsTitle => 'Debts';

  @override
  String get debtsPayment => 'Payment';

  @override
  String get debtsTabCustomers => 'Customers';

  @override
  String get debtsTabOwedToMe => 'Owed to me';

  @override
  String get debtsTabMine => 'I owe';

  @override
  String get debtsNotFound => 'No debts found';

  @override
  String get debtsCustomerNotFound => 'No customer debts found';

  @override
  String debtsActiveCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active debts',
      one: '$count active debt',
    );
    return '$_temp0';
  }

  @override
  String get debtsEnterValidAmount => 'Enter a valid amount';

  @override
  String debtsAmountExceedsBalance(String balance) {
    return 'The amount must not exceed the balance ($balance)';
  }

  @override
  String get debtsMakePayment => 'Make a payment';

  @override
  String get commonActivate => 'Activate';

  @override
  String commonDeletePermanentlyConfirm(String name) {
    return 'Permanently delete $name?';
  }

  @override
  String get commonPasswordRequired => 'Password *';

  @override
  String get staffDeleteTitle => 'Delete staff member';

  @override
  String get staffTitle => 'Staff';

  @override
  String get staffNotFound => 'No staff found';

  @override
  String get staffStoreRequired => 'Choose a store';

  @override
  String get staffEditTitle => 'Edit staff member';

  @override
  String get staffNewTitle => 'New staff member';

  @override
  String get staffStoreLabel => 'Store *';

  @override
  String get storesDeleteTitle => 'Delete store';

  @override
  String get storesTitle => 'Stores';

  @override
  String get storesDefault => 'Main';

  @override
  String get storesEditTitle => 'Edit store';

  @override
  String get storesNewTitle => 'New store';

  @override
  String get storesMapLocation => 'Location on map';

  @override
  String get storesLocationTitle => 'Store location';

  @override
  String get storesLocationHint => 'Couriers pick up orders here';

  @override
  String get storesHandoverCode => 'Handover code';

  @override
  String get storesHandoverCodeHint =>
      'When handing over an order, the courier asks the customer for a 4-digit code. Customers without the app or a verified number aren\'t asked for one.';

  @override
  String get commonBalance => 'Balance';

  @override
  String get commonPaid => 'Paid';

  @override
  String get commonOnCredit => 'On credit';

  @override
  String get commonPickCustomer => 'Choose a customer';

  @override
  String get commonNew => 'New';

  @override
  String get posScanProduct => 'Scan product';

  @override
  String get posBarcodeNotFound => 'No product found for this barcode';

  @override
  String get posSingleCurrency =>
      'A sale can only contain products in one currency';

  @override
  String get posTitle => 'Checkout';

  @override
  String get posSavedCarts => 'Saved carts';

  @override
  String posPriceAndStock(String price, String stock) {
    return '$price · Stock: $stock';
  }

  @override
  String get salesPickReturnItem => 'Choose an item to return';

  @override
  String get salesReturn => 'Return';

  @override
  String salesReturnableLeft(String count) {
    return 'Remaining: $count';
  }

  @override
  String get salesRefundMethod => 'Refund method';

  @override
  String salesReturnAmount(String amount) {
    return 'Refund amount: $amount';
  }

  @override
  String get salesConfirmReturn => 'Confirm return';

  @override
  String get salesPayment => 'Payment';

  @override
  String get salesPaidNow => 'Paid';

  @override
  String get salesDownPaymentOptional => 'Down payment (optional)';

  @override
  String salesConfirmWithTotal(String total) {
    return 'Confirm — $total';
  }

  @override
  String get salesHistoryTitle => 'Sales history';

  @override
  String get salesNotFound => 'No sales found';

  @override
  String get salesSale => 'Sale';

  @override
  String get salesCreated => 'Sale created';

  @override
  String salesReturnedQty(String count) {
    return 'returned: $count';
  }

  @override
  String get salesDebt => 'Debt';

  @override
  String get salesPayments => 'Payments';

  @override
  String get salesCustomerSearchHint => 'Name or phone...';

  @override
  String get salesCustomerNotFound => 'No customer found';

  @override
  String get cartsSaved => 'Cart saved';

  @override
  String get cartsSaveOrClearFirst => 'Save or clear the current cart first';

  @override
  String cartsSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count products weren\'t found and weren\'t added',
      one: '$count product wasn\'t found and wasn\'t added',
    );
    return '$_temp0 to the cart';
  }

  @override
  String get cartsDeleteTitle => 'Delete saved cart';

  @override
  String get cartsDeleteConfirm => 'This can\'t be undone. Continue?';

  @override
  String get cartsCurrentEmpty => 'The current cart is empty';

  @override
  String cartsSaveCurrent(int count) {
    return 'Save current cart ($count)';
  }

  @override
  String get cartsNone => 'No saved carts';

  @override
  String cartsMore(int count) {
    return '+$count';
  }

  @override
  String get cartsRestore => 'Restore';

  @override
  String get commonNoData => 'No data';

  @override
  String get reportsTitle => 'Reports';

  @override
  String get reportsTopProducts => 'Best-selling products';

  @override
  String reportsStockWith(String stock) {
    return 'Stock: $stock';
  }

  @override
  String get reportsStatistics => 'Statistics';

  @override
  String get reportsRevenue => 'Revenue';

  @override
  String get reportsNewDebts => 'New debts';

  @override
  String get reportsDebtPayments => 'Debt payments';

  @override
  String get reportsOutstanding => 'Outstanding debt';

  @override
  String get reportsSalesChart => 'Sales chart';

  @override
  String get reportsLast30 => 'Last 30 days';

  @override
  String get reportsThisMonth => 'This month';

  @override
  String get workDayDebtsShareText => 'Debt list';

  @override
  String get workDayTitle => 'Work day';

  @override
  String get workDayOpen => 'Open';

  @override
  String get workDayClosed => 'Closed';

  @override
  String get workDayNotStarted => 'The work day hasn\'t started yet';

  @override
  String workDayStartedAt(String time) {
    return 'Started: $time';
  }

  @override
  String workDayEndedAt(String time) {
    return 'Ended: $time';
  }

  @override
  String get workDayStart => 'Start work day';

  @override
  String get workDayEnd => 'End work day';

  @override
  String get workDayExportDebts => 'Debts (Excel)';

  @override
  String get dashPaymentCash => 'Cash';

  @override
  String get dashPaymentCard => 'Card';

  @override
  String get dashPaymentBank => 'Bank';

  @override
  String get dashPaymentDebt => 'Debt';

  @override
  String get dashPaymentTypes => 'Payment types';

  @override
  String get dashIncomeDebt6m => 'Income and debt (6 months)';

  @override
  String get dashIncome => 'Income';

  @override
  String get dashSalesTrend14d => 'Sales trend (14 days)';

  @override
  String get scannerTitle => 'Scan a barcode';

  @override
  String get locationMarkOnMap => 'Mark on map';

  @override
  String get locationPickTitle => 'Mark the location';

  @override
  String get locationMarked => 'Marked on map';

  @override
  String get locationCourierHint => 'So the courier can find the exact spot';

  @override
  String get locationRemove => 'Remove';

  @override
  String get locationDetectFailed =>
      'Couldn\'t get your location — check GPS and permissions';

  @override
  String get locationMyLocation => 'My location';

  @override
  String get locationChooseHere => 'Choose this spot';

  @override
  String sfGreeting(String name) {
    return 'Hi, $name!';
  }

  @override
  String get sfGreetingGuest => 'Welcome!';

  @override
  String get sfGreetingSubtitle => 'What are we buying today?';

  @override
  String get sfAllCategories => 'All';

  @override
  String sfSearchHint(String term) {
    return 'Search for “$term”';
  }

  @override
  String get sfSearchHintDefault => 'Search products';

  @override
  String get sfShops => 'Shops';

  @override
  String get sfNewArrivals => 'New arrivals';

  @override
  String get sfFavoritesLogin => 'Sign in to see your favourite products';

  @override
  String get sfFavoritesEmpty =>
      'No favourites yet. Tap ♡ on a product you like.';

  @override
  String get sfProductsSubtitle => 'Picked for you';

  @override
  String sfInStock(String quantity) {
    return 'Left: $quantity';
  }

  @override
  String get sfOutOfStock => 'Out of stock';

  @override
  String get sfAdd => 'ADD';

  @override
  String sfAddedToCart(String name) {
    return '$name added to cart';
  }

  @override
  String get sfCartOtherShop => 'The cart can only hold products from one shop';

  @override
  String get sfNoProducts => 'No products found';

  @override
  String get sfRemoveFilter => 'Remove filter';
}
