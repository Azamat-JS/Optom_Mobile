import 'package:bsmart/core/entities/reporting_shared.dart';

/// `RETAILER`-role headcount by vertical — a sub-split of
/// [PlatformUserStats.retailers], not an independent count (confirmed
/// against `reporting.service.ts adminDashboard()`'s `businessTypes` object
/// directly).
class PlatformBusinessTypeCounts {
  const PlatformBusinessTypeCounts({
    required this.general,
    required this.restaurant,
    required this.applianceStore,
    required this.constructionTools,
    required this.toyStore,
    required this.autoParts,
    required this.pharmacy,
    required this.clothingStore,
  });

  final int general;
  final int restaurant;
  final int applianceStore;
  final int constructionTools;
  final int toyStore;
  final int autoParts;
  final int pharmacy;
  final int clothingStore;

  factory PlatformBusinessTypeCounts.fromJson(Map<String, dynamic> json) => PlatformBusinessTypeCounts(
        general: json['general'] as int? ?? 0,
        restaurant: json['restaurant'] as int? ?? 0,
        applianceStore: json['applianceStore'] as int? ?? 0,
        constructionTools: json['constructionTools'] as int? ?? 0,
        toyStore: json['toyStore'] as int? ?? 0,
        autoParts: json['autoParts'] as int? ?? 0,
        pharmacy: json['pharmacy'] as int? ?? 0,
        clothingStore: json['clothingStore'] as int? ?? 0,
      );
}

class PlatformUserStats {
  const PlatformUserStats({
    required this.active,
    required this.wholesalers,
    required this.retailers,
    required this.customers,
    required this.businessTypes,
  });

  final int active;
  final int wholesalers;
  final int retailers;
  final int customers;
  final PlatformBusinessTypeCounts businessTypes;

  factory PlatformUserStats.fromJson(Map<String, dynamic> json) => PlatformUserStats(
        active: json['active'] as int,
        wholesalers: json['wholesalers'] as int,
        retailers: json['retailers'] as int,
        customers: json['customers'] as int,
        businessTypes: PlatformBusinessTypeCounts.fromJson(json['businessTypes'] as Map<String, dynamic>),
      );
}

/// `GET /reports/admin` — the platform-wide snapshot. Every currency-split
/// field reuses `core/entities/reporting_shared.dart`'s value objects
/// directly (same shapes as the wholesaler/retailer dashboard), confirmed
/// field-for-field against the real `adminDashboard()` return statement, not
/// the (partly stale) Swagger doc comment on the controller.
class PlatformDashboard {
  const PlatformDashboard({
    required this.users,
    required this.ordersTotal,
    required this.sales,
    required this.totalSellings,
    required this.cashReceived,
    required this.cardReceived,
    required this.debtsB2b,
    required this.debtsB2c,
    required this.debtsTotalBalance,
    required this.paymentBreakdown,
    required this.salesTrend,
    required this.generatedAt,
  });

  final PlatformUserStats users;
  final int ordersTotal;
  final CountAndAmountByCurrency sales;
  final MoneyByCurrency totalSellings;
  final MoneyByCurrency cashReceived;
  final MoneyByCurrency cardReceived;
  final CountAndBalanceByCurrency debtsB2b;
  final CountAndBalanceByCurrency debtsB2c;
  final MoneyByCurrency debtsTotalBalance;
  final PaymentBreakdownByCurrency paymentBreakdown;
  final TrendPointsByCurrency salesTrend;
  final DateTime generatedAt;

  factory PlatformDashboard.fromJson(Map<String, dynamic> json) {
    final debts = json['debts'] as Map<String, dynamic>;
    return PlatformDashboard(
      users: PlatformUserStats.fromJson(json['users'] as Map<String, dynamic>),
      ordersTotal: (json['orders'] as Map<String, dynamic>)['total'] as int,
      sales: CountAndAmountByCurrency.fromJson(json['sales'] as Map<String, dynamic>),
      totalSellings: MoneyByCurrency.fromJson(json['totalSellings'] as Map<String, dynamic>),
      cashReceived: MoneyByCurrency.fromJson(json['cashReceived'] as Map<String, dynamic>),
      cardReceived: MoneyByCurrency.fromJson(json['cardReceived'] as Map<String, dynamic>),
      debtsB2b: CountAndBalanceByCurrency.fromJson(debts['b2b'] as Map<String, dynamic>),
      debtsB2c: CountAndBalanceByCurrency.fromJson(debts['b2c'] as Map<String, dynamic>),
      debtsTotalBalance: MoneyByCurrency.fromJson(debts['totalBalance'] as Map<String, dynamic>),
      paymentBreakdown: PaymentBreakdownByCurrency.fromJson(json['paymentBreakdown'] as Map<String, dynamic>),
      salesTrend: TrendPointsByCurrency.fromJson(json['salesTrend'] as Map<String, dynamic>),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
    );
  }
}
