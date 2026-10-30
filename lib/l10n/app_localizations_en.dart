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
      'leadAgent': 'Lead agent',
      'agent': 'Agent',
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
  String get debtsWillClose => 'will close';

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

  @override
  String get sfSearchTitle => 'Search products & shops';

  @override
  String get sfSearchFieldHint => 'Search, pick, order!';

  @override
  String get sfRecentSearches => 'Recent searches';

  @override
  String get sfClearRecent => 'Clear history';

  @override
  String get sfBrowseCategories => 'Categories';

  @override
  String get sfSuggestionProduct => 'Product';

  @override
  String sfShopsFor(String query) {
    return 'Shops for “$query”';
  }

  @override
  String get sfMoreResults => 'More matching results';

  @override
  String get sfSearching => 'Finding the best matches…';

  @override
  String sfResultsIn(String category) {
    return 'Showing results in $category';
  }

  @override
  String get sfSort => 'Sort by';

  @override
  String get sfSortRelevance => 'Relevance';

  @override
  String get sfSortPriceLow => 'Price: low to high';

  @override
  String get sfSortPriceHigh => 'Price: high to low';

  @override
  String get sfSortName => 'Name (A–Z)';

  @override
  String get sfInStockOnly => 'In stock';

  @override
  String sfShopMatches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count matching products',
      one: '$count matching product',
    );
    return '$_temp0';
  }

  @override
  String sfNoResults(String query) {
    return 'Nothing found for “$query”';
  }

  @override
  String get sfNoResultsHint => 'Try another word or remove the filters';

  @override
  String get sfFeaturedShops => 'Matching shops';

  @override
  String get sfChooseCategory => 'Where should we search?';

  @override
  String get sfShopProducts => 'Shop products';

  @override
  String get sfProductsShort => 'products';

  @override
  String get sfChooseBranch => 'Choose a branch';

  @override
  String get sfCurrentBranch => 'Current branch';

  @override
  String get sfOtherBranches => 'Other branches';

  @override
  String sfBranchesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count branches',
      one: '$count branch',
    );
    return '$_temp0 · choose another';
  }

  @override
  String get sfCallShop => 'Call';

  @override
  String get sfCallFailed => 'Couldn\'t place the call';

  @override
  String get sfShopOwner => 'Shop owner';

  @override
  String sfSearchInShop(String shop) {
    return 'Search in $shop';
  }

  @override
  String get sfMenu => 'MENU';

  @override
  String get sfOtherCategory => 'Other';

  @override
  String get sfCartHasOtherShop =>
      'Your cart has products from another shop. Empty it first to add products from here.';

  @override
  String get sfShopEmpty => 'This shop has no products yet';

  @override
  String get sfDescription => 'Description';

  @override
  String get sfReadMore => 'more';

  @override
  String get sfReadLess => 'less';

  @override
  String get sfMoreFromShop => 'More from this shop';

  @override
  String get sfOpenShop => 'Open shop';

  @override
  String get sfExploreShop => 'Browse with photos';

  @override
  String sfUnitLabel(String unit) {
    return 'Unit: $unit';
  }

  @override
  String sfInCart(String quantity) {
    return 'In cart: $quantity';
  }

  @override
  String get cartEmptyTitle => 'Your cart is empty';

  @override
  String get cartEmptyHint =>
      'Add products you like from the shops — they\'ll show up here.';

  @override
  String get cartStartShopping => 'Start shopping';

  @override
  String get cartAddMore => 'Add more items';

  @override
  String get cartRemove => 'Remove';

  @override
  String get cartClear => 'Clear cart';

  @override
  String get cartClearConfirm => 'All products will be removed from the cart.';

  @override
  String get cartBillTitle => 'Bill details';

  @override
  String get cartItemsTotal => 'Items';

  @override
  String get cartDelivery => 'Delivery';

  @override
  String get cartDeliveryAgreed => 'Agreed with the shop';

  @override
  String get cartToPay => 'Total';

  @override
  String get cartNoteLabel => 'NOTE:';

  @override
  String get cartNote =>
      'The shop confirms your order and agrees payment and delivery with you.';

  @override
  String get cartCheckout => 'Checkout';

  @override
  String cartUnitPrice(String price, String unit) {
    return '$price / $unit';
  }

  @override
  String enumProductUnitShort(String unit) {
    String _temp0 = intl.Intl.selectLogic(unit, {
      'dona': 'pc',
      'metr': 'm',
      'litr': 'L',
      'kilogram': 'kg',
      'gram': 'g',
      'blok': 'block',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get coTitle => 'Checkout';

  @override
  String get coDeliverTo => 'Delivery address';

  @override
  String get coPickup => 'I\'ll pick it up';

  @override
  String get coPickupHint => 'You\'ll collect the order at the shop';

  @override
  String get coWhereToDeliver => 'Where should we deliver this order?';

  @override
  String get coAddAddress => 'Add address';

  @override
  String get coSelectAddress => 'Select address';

  @override
  String get coNoDelivery => 'No address — I\'ll pick it up';

  @override
  String get coItems => 'Order items';

  @override
  String get coNoteHint => 'Note for the shop (optional)';

  @override
  String get coPayment => 'Payment';

  @override
  String get coPaymentValue => 'At the shop: cash or card';

  @override
  String coSlideToOrder(String total) {
    return 'Slide to order | $total';
  }

  @override
  String get coPlacing => 'Hold on!';

  @override
  String get coPlacedTitle => 'Order received!';

  @override
  String coPlacedBody(String shop) {
    return '$shop will review your order and get in touch.';
  }

  @override
  String get coTrackOrder => 'View order';

  @override
  String get coContinueShopping => 'Continue shopping';

  @override
  String get addrSelectTitle => 'Select your location';

  @override
  String get addrSearchHint => 'Search saved addresses';

  @override
  String get addrUseCurrent => 'Use my current location';

  @override
  String get addrPickOnMap => 'Pick on the map';

  @override
  String get addrRecent => 'Recent addresses';

  @override
  String get addrNoneSaved => 'No saved addresses yet';

  @override
  String get addrDeliveredHere => 'Order will be delivered here';

  @override
  String get addrFieldLabel => 'Address (street, building, flat, landmark)';

  @override
  String get addrConfirm => 'Confirm & proceed';

  @override
  String get addrDetecting => 'Finding the address…';

  @override
  String get addrRemove => 'Remove address';

  @override
  String otTitle(String number) {
    return 'Order #$number';
  }

  @override
  String otSubtitle(String time, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '$count item',
    );
    return '$time · $_temp0';
  }

  @override
  String get otNewTitle => 'Order received!';

  @override
  String get otNewHint => 'Waiting for the shop to confirm it';

  @override
  String get otApprovedTitle => 'Order getting packed!';

  @override
  String get otApprovedHint => 'The shop confirmed and is packing it';

  @override
  String get otCourierSearching => 'Finding a courier';

  @override
  String get otCourierAssigned => 'Courier assigned';

  @override
  String get otCourierToShop => 'Courier heading to the shop';

  @override
  String get otOnTheWay => 'Order on the way!';

  @override
  String get otArrived => 'Courier has arrived!';

  @override
  String get otDeliveredTitle => 'Order delivered';

  @override
  String get otDeliveredHint => 'Thanks for shopping!';

  @override
  String get otRejectedTitle => 'Order rejected';

  @override
  String get otDeliveryCancelled => 'Delivery cancelled';

  @override
  String get otDeliveryFailed => 'Delivery failed';

  @override
  String get otPickupAt => 'You\'ll pick it up at the shop';

  @override
  String get otStepPlaced => 'Placed';

  @override
  String get otStepApproved => 'Confirmed';

  @override
  String get otStepOnTheWay => 'On the way';

  @override
  String get otStepDelivered => 'Delivered';

  @override
  String get otMins => 'mins';

  @override
  String get otViewItems => 'View item list';

  @override
  String get otTrackCourier => 'Track the courier on the map';

  @override
  String get otCallShop => 'Call the shop';

  @override
  String get otYourCourier => 'Your courier';

  @override
  String get otRefresh => 'Refresh';

  @override
  String get otShowAll => 'Show everything';

  @override
  String get otCourierUpdating => 'Updating the courier\'s location…';

  @override
  String otCourierBringing(String name) {
    return '$name is bringing your order';
  }

  @override
  String homeHello(String name) {
    return 'Hi, $name!';
  }

  @override
  String get homeSections => 'Sections';

  @override
  String get homeInventoryValue => 'Stock value';

  @override
  String homeExpectedProfit(String amount) {
    return 'Expected profit: $amount';
  }

  @override
  String get homeCashReceived => 'Cash received';

  @override
  String get homeAllTime => 'All time';

  @override
  String get homeOpenPos => 'Open the till';

  @override
  String get commonMonthsShort =>
      'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec';

  @override
  String get posCheckout => 'Checkout';

  @override
  String get posOutOfStock => 'Out of stock';

  @override
  String posStockLeft(String stock) {
    return 'Left: $stock';
  }

  @override
  String get salesCustomer => 'Customer';

  @override
  String get commonChange => 'Change';

  @override
  String get salesPaymentType => 'Payment type';

  @override
  String get salesNewSale => 'New sale';

  @override
  String get salesCustomerHint => 'Every sale is recorded to a customer';

  @override
  String get salesDebtLeft => 'Left as debt';

  @override
  String productsProfitWith(String amount, String percent) {
    return 'Profit: $amount · $percent%';
  }

  @override
  String get productsExpiry => 'Expiry date';

  @override
  String get productsDetails => 'Details';

  @override
  String get formBasics => 'Basics';

  @override
  String get formPricing => 'Pricing';

  @override
  String get formStockSection => 'Stock';

  @override
  String get formExtra => 'More';

  @override
  String get productsSource => 'Source';

  @override
  String get commonContinue => 'Continue';

  @override
  String get debtsSummaryTotal => 'Total owed';

  @override
  String debtsPeopleCount(int count) {
    return '$count people';
  }

  @override
  String get debtsItemsTitle => 'Debts';

  @override
  String get debtsOriginal => 'Original amount';

  @override
  String get commonYes => 'Yes';

  @override
  String get commonNo => 'No';

  @override
  String get commonPhone => 'Phone';

  @override
  String get commonAddressRequired => 'Address *';

  @override
  String get restNeedDish => 'Add at least one dish';

  @override
  String get restPickTable => 'Choose a table';

  @override
  String get restAddressMissing => 'Enter the delivery address';

  @override
  String get restNewOrder => 'New order';

  @override
  String get restPlaceOrder => 'Place order';

  @override
  String get restTableRequired => 'Table *';

  @override
  String get restDeliveryPoint => 'Delivery location';

  @override
  String get restCustomerName => 'Customer name';

  @override
  String get restCustomerPhone => 'Customer phone';

  @override
  String get restDishes => 'Dishes';

  @override
  String get restNoDishesYet => 'No dishes added yet';

  @override
  String get restMenuSearchHint => 'Search the menu...';

  @override
  String restDishCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dishes',
      one: '1 dish',
    );
    return '$_temp0';
  }

  @override
  String restTableWith(String name) {
    return 'Table: $name';
  }

  @override
  String get restCreatedBy => 'Created by';

  @override
  String restServiceChargeWith(String percent) {
    return 'Service charge ($percent%)';
  }

  @override
  String restWaiterCommissionWith(String percent) {
    return 'Waiter commission ($percent%)';
  }

  @override
  String get restNoCourier => 'No courier assigned';

  @override
  String restCourierPending(String name) {
    return '$name (pending)';
  }

  @override
  String get restAwaitingAccept => 'Waiting for acceptance';

  @override
  String get restAssign => 'Assign';

  @override
  String get restPickCourier => 'Choose a courier';

  @override
  String get restUnassignedAll => '— Unassigned (offer to all couriers) —';

  @override
  String get restTrackingLink => 'Tracking link';

  @override
  String get restRevokeLinks => 'Revoke tracking links';

  @override
  String get restRevokeLinksTitle => 'Revoke the tracking links?';

  @override
  String get restRevokeLinksBody =>
      'Every link sent to the customer stops working and open pages disconnect. You can send a new one if needed.';

  @override
  String get restRevoke => 'Revoke';

  @override
  String get restNoActiveLinks => 'There were no active links';

  @override
  String restLinksRevoked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count links revoked',
      one: '1 link revoked',
    );
    return '$_temp0';
  }

  @override
  String restShareTrackText(String order, String url) {
    return 'Track your order $order on the map: $url';
  }

  @override
  String get restShareTrackSubject => 'Order tracking';

  @override
  String get restCourierNotAccepted =>
      'The courier hasn\'t accepted the order yet.';

  @override
  String get restActionPreparing => 'Start preparing';

  @override
  String get restActionReady => 'Mark as ready';

  @override
  String get restActionServed => 'Mark as served';

  @override
  String get restActionDelivered => 'Mark as delivered';

  @override
  String get restCancelOrder => 'Cancel order';

  @override
  String get restAccept => 'Accept';

  @override
  String get restCancelOrderTitle => 'Cancel the order';

  @override
  String get restCancelOrderConfirm => 'Do you want to cancel this order?';

  @override
  String get restNoOpenOrders => 'No open orders';

  @override
  String get restMenuEmpty => 'The menu is empty';

  @override
  String get tablesEditTitle => 'Edit table';

  @override
  String get tablesNewTitle => 'New table';

  @override
  String get tablesServiceChargeRequired => 'Service charge (%) *';

  @override
  String get tablesPercentMissing => 'Enter the percent';

  @override
  String get tablesPercentRange => 'Must be between 0 and 100';

  @override
  String get tablesDeleteTitle => 'Delete table';

  @override
  String tablesDeleteConfirm(String name) {
    return 'Delete $name? If it has open orders, this will fail.';
  }

  @override
  String get tablesNotFound => 'No tables found';

  @override
  String tablesServiceCharge(String percent) {
    return 'Service charge: $percent%';
  }

  @override
  String get staffStoreBranchRequired => 'Store (branch) *';

  @override
  String get waitersEditTitle => 'Edit waiter';

  @override
  String get waitersNewTitle => 'New waiter';

  @override
  String get waitersDeleteTitle => 'Delete waiter';

  @override
  String get waitersNotFound => 'No waiters found';

  @override
  String waitersUsage(String used, String limit) {
    return '$used / $limit waiters in use';
  }

  @override
  String get waitersCommissionOptional => 'Commission (%) — optional';

  @override
  String waitersCommission(String percent) {
    return 'Commission: $percent%';
  }

  @override
  String waitersToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Today: $count orders',
      one: 'Today: 1 order',
    );
    return '$_temp0';
  }

  @override
  String get couriersEditTitle => 'Edit courier';

  @override
  String get couriersNewTitle => 'New courier';

  @override
  String get couriersDeleteTitle => 'Delete courier';

  @override
  String get couriersNotFound => 'No couriers found';

  @override
  String couriersUsage(String used, String limit) {
    return '$used / $limit couriers in use';
  }

  @override
  String couriersToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Today: $count deliveries',
      one: 'Today: 1 delivery',
    );
    return '$_temp0';
  }

  @override
  String enumDeliveryStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'pending': 'Pending',
      'assigned': 'Assigned',
      'accepted': 'Accepted',
      'pickedUp': 'On the way',
      'arrived': 'Arrived',
      'delivered': 'Delivered',
      'cancelled': 'Cancelled',
      'failed': 'Not delivered',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String enumDeliveryFailReason(String reason) {
    String _temp0 = intl.Intl.selectLogic(reason, {
      'notHome': 'Customer not at the address',
      'refused': 'Customer refused',
      'wrongAddress': 'Wrong address',
      'other': 'Other reason',
    });
    return '$_temp0';
  }

  @override
  String dlvHeadline(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'pending': 'Looking for a courier',
      'assigned': 'Courier assigned, waiting for confirmation',
      'accepted': 'The courier is heading to the store',
      'pickedUp': 'The courier is on the way',
      'arrived': 'The courier has arrived!',
      'delivered': 'Order delivered',
      'cancelled': 'Delivery cancelled',
      'failed': 'Couldn\'t deliver',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get dlvLabelFallback => 'Delivery';

  @override
  String get dlvConfirmHandoverTitle => 'Order handed over?';

  @override
  String dlvConfirmHandoverBody(String label) {
    return 'Confirm that $label was handed to the customer.';
  }

  @override
  String get dlvYesHandedOver => 'Yes, handed over';

  @override
  String get dlvCallFailed => 'Couldn\'t place the call';

  @override
  String get dlvNavigatorFailed => 'Couldn\'t open the navigator';

  @override
  String dlvCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count deliveries',
      one: '1 delivery',
    );
    return '$_temp0';
  }

  @override
  String get dlvNone => 'No deliveries yet';

  @override
  String get dlvActiveSection => 'Active deliveries';

  @override
  String get dlvOffersSection => 'New offers';

  @override
  String get dlvActiveBannerTitle => 'You have an active delivery';

  @override
  String get dlvActiveBannerCustomer =>
      'Go online so the customer and your business owner can see you on the map.';

  @override
  String get dlvActiveBannerOwner =>
      'Go online so your business owner can see you on the map.';

  @override
  String get dlvNoAddress => 'No address given';

  @override
  String get dlvCompleted => 'Delivery completed';

  @override
  String get dlvFailedMarked =>
      'Marked as not delivered. Return the order to the store.';

  @override
  String get mapFitAll => 'Show everything';

  @override
  String get mapMyLocation => 'My location';

  @override
  String get dlvPickup => 'Pickup';

  @override
  String get dlvYouAreOffline => 'You\'re offline';

  @override
  String get dlvLocationHidden => 'Your location isn\'t visible';

  @override
  String get dlvFailed => 'Couldn\'t deliver';

  @override
  String get dlvCancelledTitle => 'Delivery cancelled';

  @override
  String get dlvFinishedTitle => 'Delivery finished';

  @override
  String get dlvGoToStore => 'Go to the store';

  @override
  String get dlvDeliverToCustomer => 'Deliver to the customer';

  @override
  String get dlvCodeLockedHint => 'Code locked — call the store';

  @override
  String get dlvAskCode => 'Ask the customer for the 4-digit code at handover';

  @override
  String get dlvStoreFallback => 'Store';

  @override
  String get dlvNavigator => 'Navigate';

  @override
  String get dlvHandedOver => 'Handed over';

  @override
  String get dlvPickedUp => 'Picked up the order';

  @override
  String get dlvArrived => 'I\'ve arrived';

  @override
  String dlvMinutesShort(String minutes) {
    return '~$minutes min';
  }

  @override
  String dlvToStore(String time) {
    return 'To the store $time';
  }

  @override
  String dlvToCustomer(String time) {
    return 'To the customer $time';
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
  String get dlvRestaurantOrder => 'Restaurant order';

  @override
  String dlvMinutesLong(String minutes) {
    return '~$minutes min';
  }

  @override
  String dlvFailedCustomer(String reason) {
    return '$reason. The store will contact you.';
  }

  @override
  String get dlvFailedFallback => 'Couldn\'t hand over';

  @override
  String get dlvCourierUpdating => 'Updating the courier\'s location…';

  @override
  String get dlvYourCourier => 'Your courier';

  @override
  String get commonCall => 'Call';

  @override
  String get dlvAssignTitle => 'Assign a courier';

  @override
  String get dlvOfferAll => 'Offer to all couriers';

  @override
  String get dlvOfferAllHint => 'The first courier to accept gets it';

  @override
  String get dlvNoActiveCouriers => 'No active couriers';

  @override
  String dlvActiveDeliveries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active deliveries',
      one: '1 active delivery',
    );
    return '$_temp0';
  }

  @override
  String get dlvCodeFourDigits => 'The code has 4 digits';

  @override
  String get dlvCodeLocked => 'Code locked';

  @override
  String get dlvWaivedTitle => 'The store allowed handover without a code';

  @override
  String get dlvHandoverCode => 'Handover code';

  @override
  String get dlvTooManyTries =>
      'Too many wrong attempts. Call the store — they can allow handover without a code.';

  @override
  String get dlvConfirmHandedOver =>
      'Confirm that you handed the order to the customer.';

  @override
  String get dlvAskCodeLong =>
      'Ask the customer for the 4-digit code. It\'s in their app and on Telegram.';

  @override
  String dlvAttemptsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count attempts left',
      one: '1 attempt left',
    );
    return '$_temp0';
  }

  @override
  String get dlvRecheck => 'Check again';

  @override
  String get dlvWhyFailed => 'Why couldn\'t you hand it over?';

  @override
  String get dlvFailNotice =>
      'The customer and the store will be notified. Return the order to the store.';

  @override
  String get dlvNoteRequired => 'Note (required)';

  @override
  String get dlvWaiveTitle => 'Allow handover without a code?';

  @override
  String get dlvWaiveBody =>
      'The courier will be able to hand over without the customer\'s code. Allow it only after talking to the customer and making sure they got the order.';

  @override
  String get dlvWaiveConfirm => 'Allow';

  @override
  String get dlvWaived => 'Allowed — the courier can hand over without a code';

  @override
  String dlvReasonWith(String reason) {
    return 'Reason: $reason';
  }

  @override
  String dlvDistanceFromDropoff(String distance) {
    return 'The courier was $distance from the customer\'s address';
  }

  @override
  String dlvCancelReasonWith(String reason) {
    return 'Cancellation reason: $reason';
  }

  @override
  String get dlvCodeLockedStaff =>
      'Code locked: the courier entered a wrong code too many times';

  @override
  String dlvCodeWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Waiting for the customer\'s code ($count attempts left)',
      one: 'Waiting for the customer\'s code (1 attempt left)',
    );
    return '$_temp0';
  }

  @override
  String get dlvWaivedStaff => 'Handover without a code is allowed';

  @override
  String get dlvWaiveButton => 'Allow without a code';

  @override
  String get dlvHandoverCodeHint =>
      'Tell it to the courier when you get your order. Don\'t share it with anyone else.';

  @override
  String dlvCodeSemantics(String digits) {
    return 'Code $digits';
  }

  @override
  String dlvCourierWith(String name) {
    return 'Courier: $name';
  }

  @override
  String get dlvChangeCourier => 'Change courier';

  @override
  String get dlvCancel => 'Cancel delivery';

  @override
  String get dlvReassign => 'Assign again';

  @override
  String get dlvTrackCourier => 'Track the courier';

  @override
  String get dlvOfferedAll => 'Offered to all couriers';

  @override
  String get dlvAssigned => 'Assigned to the courier';

  @override
  String get dlvCancelTitle => 'Cancel the delivery?';

  @override
  String get dlvCancelBody =>
      'The courier won\'t see this order anymore. You can assign it again later.';

  @override
  String get commonRefresh => 'Refresh';

  @override
  String fleetOnline(String count) {
    return '$count online';
  }

  @override
  String fleetBusy(String count) {
    return '$count delivering';
  }

  @override
  String fleetStale(String count) {
    return '$count no signal';
  }

  @override
  String get fleetNoSignal => 'No signal';

  @override
  String get fleetDelivering => 'Delivering';

  @override
  String get fleetFree => 'Free';

  @override
  String get fleetNoneOnline => 'No couriers online yet';

  @override
  String fleetLastLocation(String ago) {
    return 'last location $ago';
  }

  @override
  String get fleetViewDelivery => 'View delivery';

  @override
  String fleetViewDeliveryN(String n) {
    return 'View delivery ($n)';
  }

  @override
  String get trkOnline => 'Online';

  @override
  String get trkOffline => 'Offline';

  @override
  String get trkNotificationTitle => 'bsmart is sharing your location';

  @override
  String trkNotifActiveCustomer(String label) {
    return 'Active delivery: $label — visible to the customer and your business owner';
  }

  @override
  String trkNotifActiveOwner(String label) {
    return 'Active delivery: $label — visible to your business owner';
  }

  @override
  String get trkNotifOnline =>
      'Online — your business owner can see your location';

  @override
  String get trkShareTitle => 'Location sharing';

  @override
  String get trkWatchersNone => 'Nobody — your location isn\'t being sent';

  @override
  String trkWatchersWithCustomer(String label) {
    return 'Your business owner, admins and the customer ($label)';
  }

  @override
  String get trkWatchersOwner => 'Your business owner and admins';

  @override
  String get trkWhatTitle => 'What is shared';

  @override
  String get trkWhatBody =>
      'Your phone\'s GPS location: coordinates, speed and direction of travel.';

  @override
  String get trkWhenTitle => 'When';

  @override
  String get trkWhenBody =>
      'Only while you\'re \"Online\" or on an active delivery — even with the app in the background or the screen off. A persistent notification stays in the notification panel during this time.';

  @override
  String get trkWhoTitle => 'Who sees it';

  @override
  String get trkWhoBody =>
      'Your business owner and their admins, plus the customer of an active delivery.';

  @override
  String get trkStopTitle => 'How to stop it';

  @override
  String get trkStopBody =>
      'Switch to \"Offline\" at any time — sending stops right away. While offline, your location isn\'t sent.';

  @override
  String get trkDisclosureLead =>
      'bsmart uses your location to track deliveries';

  @override
  String get trkNotNow => 'Not now';

  @override
  String get trkAgree => 'I agree';

  @override
  String get trkGoOfflineTitle => 'Go offline';

  @override
  String get trkGoOfflineBody =>
      'Location sharing stops — your business owner won\'t see you on the map.';

  @override
  String trkGoOfflineActiveCustomer(String label) {
    return 'You have an active delivery ($label). If you stop sharing, the customer and your business owner won\'t see you on the map.';
  }

  @override
  String trkGoOfflineActiveOwner(String label) {
    return 'You have an active delivery ($label). If you stop sharing, your business owner won\'t see you on the map.';
  }

  @override
  String get trkStop => 'Stop';

  @override
  String get trkNotSentYet => 'not sent yet';

  @override
  String trkSecondsAgo(String seconds) {
    return '$seconds s ago';
  }

  @override
  String trkMinutesAgo(String minutes) {
    return '$minutes min ago';
  }

  @override
  String trkWatchersWith(String who) {
    return 'Visible to: $who';
  }

  @override
  String get trkGoOnlineHint => 'Go online to start working';

  @override
  String get trkGpsOffBanner => 'GPS (location) is off on your phone.';

  @override
  String get trkTurnOnGps => 'Turn on GPS';

  @override
  String get trkDeniedForever =>
      'Location permission was denied. Allow it in Settings.';

  @override
  String get trkOpenSettings => 'Open Settings';

  @override
  String get trkPermissionNeeded =>
      'Location permission is needed to go online.';

  @override
  String get trkLastSent => 'Last location sent';

  @override
  String get trkWhoNow => 'Who can see you now';

  @override
  String get trkNoNotifPermission => 'No notification permission';

  @override
  String get trkNoNotifPermissionBody =>
      'Tracking continues, but it won\'t show in the notification panel.';

  @override
  String get trkBatterySaver => 'Battery saver';

  @override
  String get trkBatterySaverBody =>
      'Some phones stop apps running in the background. If you have problems, turn off battery restrictions for bsmart.';

  @override
  String get trkAboutSharing => 'About location sharing';

  @override
  String get trkSharing => 'Sharing location';

  @override
  String get trkConnecting => 'Connecting…';

  @override
  String get trkNoGps => 'No GPS signal';

  @override
  String get trkReconnecting => 'Reconnecting…';

  @override
  String get trkDenied => 'No permission';

  @override
  String get trkGpsOff => 'GPS is off';

  @override
  String get trkJustNow => 'just now';

  @override
  String get tgRequestNotFound => 'Request not found. Start again.';

  @override
  String get tgRequestUsed =>
      'This request has already been used. Start again.';

  @override
  String get sfUnknownShop => 'Unknown store';

  @override
  String get favLoginPrompt => 'Log in to see your favorites';

  @override
  String get favEmpty => 'Your favorites list is empty';

  @override
  String get usersNotFound => 'No users found';

  @override
  String get usersSearchHint => 'Name, surname or phone...';

  @override
  String get usersDeleteTitle => 'Delete user';

  @override
  String usersDeleteConfirm(String name) {
    return 'Delete $name permanently? This can\'t be undone.';
  }

  @override
  String get usersEditTitle => 'Edit user';

  @override
  String get usersNewTitle => 'New user';

  @override
  String get usersRoleRequired => 'Role *';

  @override
  String get usersVerticalRequired => 'Business type *';

  @override
  String get usersShopName => 'Store name';

  @override
  String get adminVerticalsTitle => 'Retailers by business type';

  @override
  String get adminTotalRevenue => 'Total revenue';

  @override
  String get adminActiveUsers => 'Active users';

  @override
  String get adminTotalDebt => 'Total debt';

  @override
  String get scannerHint => 'Fit the barcode inside the frame';

  @override
  String get scannerTorch => 'Flashlight';

  @override
  String get locationDragHint => 'Move the map — the pin stays in the centre';

  @override
  String get categoriesPickerTitle => 'Choose a category';

  @override
  String get scannerCameraError =>
      'Couldn\'t open the camera. Check that camera access is allowed.';

  @override
  String get agentTabHome => 'Home';

  @override
  String get agentTabSell => 'Sell';

  @override
  String get agentTabSales => 'Sales';

  @override
  String get agentTabDebts => 'Debtors';

  @override
  String agentHello(String name) {
    return 'Hi, $name!';
  }

  @override
  String agentLeadOf(String business) {
    return 'Lead agent of $business';
  }

  @override
  String agentStaffOf(String lead) {
    return 'Agent of $lead';
  }

  @override
  String get agentTodaySales => 'Sales today';

  @override
  String get agentMonthSales => 'Sales, 30 days';

  @override
  String get agentMyTodaySales => 'My sales today';

  @override
  String get agentMyMonthSales => 'My sales, 30 days';

  @override
  String agentSalesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sales',
      one: '1 sale',
    );
    return '$_temp0';
  }

  @override
  String get agentCustomersOwe => 'Customers owe';

  @override
  String get agentMyDebtsGiven => 'Debts I gave';

  @override
  String agentOpenDebts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count open debts',
      one: '1 open debt',
    );
    return '$_temp0';
  }

  @override
  String get agentOwedToOwner => 'I owe the owner';

  @override
  String get agentStockValue => 'Stock held';

  @override
  String get agentProfitTitle => 'Net profit';

  @override
  String get agentProfitToday => 'Today';

  @override
  String get agentProfit7 => '7 days';

  @override
  String get agentProfit30 => '30 days';

  @override
  String get agentProfitRevenue => 'Sales';

  @override
  String get agentProfitCost => 'Owed to the owner';

  @override
  String get agentProfitPending => 'Profit in customer debts';

  @override
  String get agentProfitHint =>
      'Profit from sales on debt counts once customers pay';

  @override
  String get agentShortcutProducts => 'My products';

  @override
  String get agentNoStock => 'No products yet';

  @override
  String get agentNoStockHint =>
      'They appear here when the business owner gives you products.';

  @override
  String agentStockLeft(String qty) {
    return 'Left: $qty';
  }

  @override
  String agentPriceRange(String min, String max) {
    return '$min – $max';
  }

  @override
  String get agentOtherCurrency => 'One sale, one currency';

  @override
  String agentCartCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count products',
      one: '1 product',
    );
    return '$_temp0';
  }

  @override
  String get agentCheckout => 'Check out';

  @override
  String get agentCheckoutTitle => 'Sale';

  @override
  String get agentQuantity => 'Quantity';

  @override
  String get agentPrice => 'Price';

  @override
  String agentPriceOutOfRange(String name, String min, String max) {
    return '“$name”: price must be within $min – $max';
  }

  @override
  String agentQtyInvalid(String name) {
    return '“$name”: enter a quantity';
  }

  @override
  String agentQtyTooMuch(String name, String qty) {
    return '“$name”: only $qty left';
  }

  @override
  String get agentCash => 'Cash';

  @override
  String get agentDebt => 'On debt';

  @override
  String get agentCustomer => 'Customer';

  @override
  String get agentCustomerName => 'Name';

  @override
  String get agentCustomerLastName => 'Last name (optional)';

  @override
  String get agentCustomerPhone => 'Phone';

  @override
  String get agentCustomerOptional => 'Customer details are optional';

  @override
  String get agentReturningDebtorHint =>
      'If the phone is on file, the debt goes to that customer';

  @override
  String get agentDebtNeedsCustomer => 'Selling on debt needs a name and phone';

  @override
  String get agentPhoneInvalid => 'Invalid phone number';

  @override
  String agentSellNow(String total) {
    return 'Sell · $total';
  }

  @override
  String get agentSold => 'Sale saved';

  @override
  String get agentSalesEmpty => 'No sales yet';

  @override
  String agentSaleSeller(String name) {
    return 'Seller: $name';
  }

  @override
  String agentLineCost(String amount) {
    return 'Cost: $amount';
  }

  @override
  String get agentDebtsOpen => 'Open';

  @override
  String get agentDebtsAll => 'All';

  @override
  String get agentDebtsEmpty => 'No debts';

  @override
  String get agentDebtsTotal => 'Total owed';

  @override
  String get agentDebtOriginal => 'Debt amount';

  @override
  String get agentDebtPaid => 'Paid';

  @override
  String get agentDebtBalance => 'Balance';

  @override
  String get agentPayTitle => 'Receive payment';

  @override
  String get agentPayFull => 'Full';

  @override
  String get agentPaySubmit => 'Receive';

  @override
  String get agentPaid => 'Payment received';

  @override
  String get agentPayInvalid => 'Enter an amount';

  @override
  String get agentPayTooMuch => 'Amount must not exceed the balance';

  @override
  String get agentPaymentsHistory => 'Payments';

  @override
  String get agentNoPayments => 'No payments yet';

  @override
  String get agentDebtClosed => 'Debt closed';

  @override
  String get agentAccountTitle => 'Account';

  @override
  String agentAccountWith(String owner) {
    return 'Account with $owner';
  }

  @override
  String get agentMyDebt => 'I owe';

  @override
  String get agentNothingOwed => 'You owe nothing';

  @override
  String get agentPendingPayments => 'Pending payments';

  @override
  String get agentPendingReturns => 'Pending returns';

  @override
  String get agentSendPayment => 'Send payment';

  @override
  String get agentSendPaymentHint =>
      'Enter the money you handed to the owner. Your debt goes down once they confirm.';

  @override
  String get agentPaymentSent => 'Payment request sent';

  @override
  String get agentReturnGoods => 'Return products';

  @override
  String get agentReturnHint =>
      'Enter quantities. They leave your stock right away; once the owner confirms your debt goes down, and if they reject, they come back.';

  @override
  String agentReturnSend(int count) {
    return 'Return ($count)';
  }

  @override
  String get agentReturnSent => 'Return request sent';

  @override
  String get agentReturnPickOne => 'Enter a quantity for at least one product';

  @override
  String get agentTabPayments => 'Payments';

  @override
  String get agentTabReturns => 'Returns';

  @override
  String get agentStatusPending => 'Pending';

  @override
  String get agentStatusConfirmed => 'Confirmed';

  @override
  String get agentStatusRejected => 'Rejected';

  @override
  String get agentStatusCancelled => 'Cancelled';

  @override
  String get agentCancelRequest => 'Cancel';

  @override
  String get agentCancelRequestConfirm => 'Cancel this request?';

  @override
  String get agentRequestCancelled => 'Request cancelled';

  @override
  String get agentPaymentsEmpty => 'No payment requests yet';

  @override
  String get agentReturnsEmpty => 'No returns yet';

  @override
  String get agentReturnValue => 'Value';

  @override
  String get agentRefund => 'Refunded in cash';

  @override
  String agentReturnFromTransfer(String number) {
    return 'Transfer $number';
  }

  @override
  String get agentTransfersTitle => 'Received';

  @override
  String get agentTransfersEmpty => 'Nothing received yet';

  @override
  String agentTransferPaid(String amount) {
    return 'Paid: $amount';
  }

  @override
  String agentTransferDebt(String amount) {
    return 'Debt: $amount';
  }

  @override
  String agentTransferLineQty(String given, String left) {
    return 'Given $given · left $left';
  }

  @override
  String agentTransferReturned(String qty) {
    return 'Returned $qty';
  }

  @override
  String agentTransferOwed(String price) {
    return 'Price $price';
  }

  @override
  String agentTransferRange(String range) {
    return 'Sell at: $range';
  }

  @override
  String agentTransferGivenBy(String name) {
    return 'Given by: $name';
  }

  @override
  String get agentStaffTitle => 'Agents';

  @override
  String get agentStaffEmpty => 'No agents yet';

  @override
  String get agentStaffNew => 'New agent';

  @override
  String get agentStaffEdit => 'Edit agent';

  @override
  String get agentStaffDeleteTitle => 'Delete agent';

  @override
  String agentRejectReason(String reason) {
    return 'Reason: $reason';
  }

  @override
  String agentAvailableToSend(String amount) {
    return 'You can send up to $amount';
  }

  @override
  String get navLeadAgents => 'Lead agents';

  @override
  String get ownerLeadNew => 'New lead agent';

  @override
  String get ownerLeadEdit => 'Edit lead agent';

  @override
  String get ownerLeadDeleteTitle => 'Delete lead agent';

  @override
  String get ownerLeadsEmpty => 'No lead agents yet';

  @override
  String get ownerLeadStoreHint =>
      'The lead agent gets products from this store';

  @override
  String ownerLeadStaffCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count agents',
      one: '1 agent',
    );
    return '$_temp0';
  }

  @override
  String ownerLeadPendingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count requests',
      one: '1 request',
    );
    return '$_temp0';
  }

  @override
  String get ownerLeadOwes => 'Owes me';

  @override
  String get ownerLeadStock => 'Products held';

  @override
  String get ownerLeadStaff => 'Staff agents';

  @override
  String get ownerTeamTitle => 'Team sales';

  @override
  String get ownerGiveProducts => 'Give products';

  @override
  String get ownerTabStock => 'Products';

  @override
  String get ownerTabTransfers => 'Transfers';

  @override
  String get ownerTabCustomerDebts => 'Customer debts';

  @override
  String get ownerStockEmpty => 'The lead agent holds no products';

  @override
  String get ownerMinPrice => 'Min price';

  @override
  String get ownerMaxPrice => 'Max price';

  @override
  String get ownerEditRange => 'Change price range';

  @override
  String get ownerRangeUpdated => 'Price range updated';

  @override
  String ownerRangeInvalid(String name) {
    return '“$name”: min price must not exceed max price';
  }

  @override
  String ownerPriceInvalid(String name) {
    return '“$name”: enter a price';
  }

  @override
  String get ownerMinBelowPrice =>
      'Min price is below what the lead agent owes';

  @override
  String get ownerConfirm => 'Confirm';

  @override
  String get ownerReject => 'Reject';

  @override
  String get ownerConfirmed => 'Confirmed';

  @override
  String get ownerRejected => 'Rejected';

  @override
  String get ownerRejectTitle => 'Reject request';

  @override
  String get ownerRejectReason => 'Reason (optional)';

  @override
  String get ownerConfirmPaymentTitle => 'Confirm payment';

  @override
  String ownerConfirmPaymentText(String name, String amount) {
    return 'Confirm that $name paid $amount? It pays off the oldest debts first.';
  }

  @override
  String get ownerConfirmReturnTitle => 'Confirm return';

  @override
  String get ownerConfirmReturnText =>
      'The products go back into your stock and the lead agent\'s debt goes down.';

  @override
  String ownerDebtReduceLine(String amount) {
    return 'Taken off the debt: $amount';
  }

  @override
  String ownerRefundLine(String amount) {
    return 'You refund in cash: $amount';
  }

  @override
  String get ownerTransferEmpty => 'No products in this store to give';

  @override
  String ownerTransferInStock(String qty) {
    return 'In stock: $qty';
  }

  @override
  String ownerTransferHeld(String qty) {
    return 'Lead agent has: $qty';
  }

  @override
  String get ownerTransferOneCurrency => 'One transfer, one currency';

  @override
  String get ownerTransferPicked => 'Selected';

  @override
  String get ownerTransferPaid => 'Paid now';

  @override
  String get ownerTransferPaidTooMuch =>
      'Paid amount must not exceed the total';

  @override
  String ownerTransferDebtLine(String amount) {
    return 'Goes on the debt: $amount';
  }

  @override
  String ownerTransferSubmit(int count) {
    return 'Give ($count)';
  }

  @override
  String get ownerTransferDone => 'Products given';

  @override
  String get ownerTransferPickOne => 'Pick at least one product';

  @override
  String get commonLoadMore => 'Show more';

  @override
  String get navCrmDrivers => 'Drivers';

  @override
  String get navCrmReminders => 'Reminders';

  @override
  String get crmDriversSearchHint => 'Name, phone or plate';

  @override
  String get crmDriversEmpty => 'No drivers yet';

  @override
  String get crmNotEnabled => 'CRM isn\'t enabled for this business';

  @override
  String get crmAddDriver => 'Add driver';

  @override
  String get crmNewDriver => 'New driver';

  @override
  String get crmEditDriver => 'Edit driver';

  @override
  String get crmLastName => 'Last name';

  @override
  String get crmPhoneHint =>
      'The driver is also added to the store\'s customers with this number';

  @override
  String get crmFirstCar => 'Car (optional)';

  @override
  String get crmPlate => 'Plate number';

  @override
  String get crmPlateMissing => 'Enter the plate number';

  @override
  String get crmPlateInvalid => 'Invalid plate number';

  @override
  String get crmModel => 'Model';

  @override
  String get crmModelMissing => 'Enter the car model';

  @override
  String get crmDailyKm => 'Distance per day (km)';

  @override
  String get crmDailyKmHint =>
      'Approximate. Service due dates are counted from it';

  @override
  String get crmDailyKmInvalid => 'Enter a whole number from 1 to 3000';

  @override
  String get crmActiveHint => 'Inactive drivers get no reminders';

  @override
  String get crmVehicles => 'Cars';

  @override
  String get crmAddVehicle => 'Add car';

  @override
  String get crmEditVehicle => 'Edit car';

  @override
  String get crmNoVehicles => 'No cars added';

  @override
  String crmDailyKmValue(String km) {
    return '~$km km per day';
  }

  @override
  String get crmDailyKmMissing => 'Daily distance not set';

  @override
  String crmNextDue(String name) {
    return 'Next: $name';
  }

  @override
  String get crmRecordService => 'Record service';

  @override
  String get crmHistory => 'Service history';

  @override
  String get crmNoVisits => 'No services yet';

  @override
  String crmLinkedCustomer(String name) {
    return 'In customers: $name';
  }

  @override
  String get crmInactiveNoService =>
      'The driver is inactive: activate them to record a service';

  @override
  String get crmDeleteDriverTitle => 'Delete driver';

  @override
  String crmDeleteDriverConfirm(String name) {
    return '$name and their cars will be deleted. Their customer record and sales are kept.';
  }

  @override
  String get crmDeleteVehicleTitle => 'Delete car';

  @override
  String crmDeleteVehicleConfirm(String plate) {
    return 'Car $plate will be deleted.';
  }

  @override
  String get crmPhotoAdd => 'Add photo';

  @override
  String get crmPhotoChange => 'Change photo';

  @override
  String get crmPhotoRemove => 'Remove photo';

  @override
  String get crmDueToday => 'today';

  @override
  String crmDueIn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days left',
      one: '1 day left',
    );
    return '$_temp0';
  }

  @override
  String crmOverdueBy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days overdue',
      one: '1 day overdue',
    );
    return '$_temp0';
  }

  @override
  String get crmItemReplaced => 'Replaced at a later service';

  @override
  String get crmItemDone => 'Done';

  @override
  String get crmItemCancelled => 'Cancelled';

  @override
  String get crmNoReminder => 'No reminder';

  @override
  String get crmNoSale => 'No sale';

  @override
  String crmSaleDebtLeft(String amount) {
    return 'Owes $amount';
  }

  @override
  String get crmSaleDebtSettled => 'Debt paid off';

  @override
  String crmKmValue(String km) {
    return '$km km';
  }

  @override
  String crmEveryKm(String km) {
    return 'every $km km';
  }

  @override
  String crmAtKm(String km) {
    return 'at $km km';
  }

  @override
  String get crmTgLinked => 'Telegram: reminders go through';

  @override
  String get crmTgNotLinked => 'Telegram not connected';

  @override
  String get crmTgBlocked => 'The driver blocked the bot';

  @override
  String get crmTgNoBot =>
      'No Telegram bot is connected to the store, so reminders don\'t reach the driver on Telegram';

  @override
  String get crmTgHowTo =>
      'The driver needs to open the store\'s bot and share their phone number';

  @override
  String get crmTgShareLink => 'Send the bot link';

  @override
  String get crmVisitTitle => 'Record a service';

  @override
  String get crmServiceDate => 'Service date';

  @override
  String get crmOdometer => 'Odometer (km)';

  @override
  String get crmParts => 'Installed parts';

  @override
  String get crmAddPart => 'Add product';

  @override
  String get crmAddManual => 'Manual';

  @override
  String get crmPartSearch => 'Search for a part or oil';

  @override
  String get crmPartsEmpty => 'Add a product or a manual line';

  @override
  String get crmManualName => 'Name (e.g. Labour)';

  @override
  String get crmQuantity => 'Quantity';

  @override
  String get crmIntervalKm => 'Until next service, km';

  @override
  String get crmNextDate => 'Next date';

  @override
  String crmDueAuto(String date) {
    return 'Due back around $date';
  }

  @override
  String get crmDueManual => 'Date set by hand';

  @override
  String get crmDueNeedsDate => 'No daily distance — pick a date';

  @override
  String get crmRecordSale => 'Record as a sale';

  @override
  String get crmRecordSaleOn =>
      'Stock is taken and a payment or debt is recorded';

  @override
  String get crmRecordSaleOff => 'Reminder only: stock and money don\'t change';

  @override
  String get crmPaidNow => 'Paid now (optional)';

  @override
  String crmDebtLeft(String amount) {
    return 'Debt: $amount';
  }

  @override
  String get crmSaveVisit => 'Save service';

  @override
  String get crmVisitSaved => 'Service recorded';

  @override
  String crmInStock(String qty) {
    return 'In stock: $qty';
  }

  @override
  String get crmPickVehicle => 'Choose a car';

  @override
  String get crmAddPartFirst => 'Add at least one line';

  @override
  String get crmManualNameMissing => 'Enter a name for the manual line';

  @override
  String crmPriceMissing(String name) {
    return 'Enter a price for \"$name\"';
  }

  @override
  String crmNotEnoughStock(String name) {
    return 'Not enough \"$name\" in stock';
  }

  @override
  String crmDueAfterService(String name) {
    return 'The next date for \"$name\" must be after the service date';
  }

  @override
  String crmDueNeeded(String name) {
    return 'No daily distance: pick the next date for \"$name\"';
  }

  @override
  String get crmPaidTooMuch => 'The amount paid can\'t exceed the total';

  @override
  String get crmMixedCurrency =>
      'One service can only have products in one currency';

  @override
  String get crmRemindersAll => 'All';

  @override
  String get crmRemindersOverdue => 'Overdue';

  @override
  String get crmRemindersSoon => 'Within 7 days';

  @override
  String get crmRemindersEmpty => 'No reminders';

  @override
  String get crmMarkDone => 'Done';

  @override
  String get crmMoveDate => 'Change date';

  @override
  String get crmCancelReminder => 'Cancel reminder';

  @override
  String get crmReminderDone => 'Marked as done';

  @override
  String get crmReminderCancelled => 'Reminder cancelled';

  @override
  String get crmDateMoved => 'Date changed';

  @override
  String get crmDueManualShort => 'Date set by hand';

  @override
  String get crmDriverSaved => 'Driver saved';

  @override
  String get crmVehicleSaved => 'Car saved';

  @override
  String get notifTitle => 'Notifications';

  @override
  String get notifEmpty => 'No notifications yet';

  @override
  String get notifReadAll => 'Mark all as read';

  @override
  String notifServiceDueStaff(String plate, String driver) {
    return '$plate — service due ($driver)';
  }

  @override
  String get notifDriverNotified => 'The driver was reminded on Telegram';

  @override
  String notifCallDriver(String phone) {
    return 'The driver isn\'t on the bot — call them: $phone';
  }

  @override
  String notifServiceDueDriver(String store) {
    return '$store: service coming up';
  }

  @override
  String get notifUnknown => 'New notification';
}
