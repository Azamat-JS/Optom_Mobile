import 'package:bsmart/core/entities/reporting_shared.dart';

/// `GET /reports/retailer` — RETAILER/RETAILER_ADMIN only.
class RetailerDashboard {
  const RetailerDashboard({
    required this.todaySales,
    required this.totalSales,
    required this.cashReceived,
    required this.cardReceived,
    required this.customerDebts,
    required this.wholesalerDebts,
    required this.paymentBreakdown,
    required this.salesTrend,
    required this.inventory,
    required this.generatedAt,
  });

  final CountAndAmountByCurrency todaySales;
  final CountAndAmountByCurrency totalSales;
  final CountAndAmountByCurrency cashReceived;
  final CountAndAmountByCurrency cardReceived;
  final DebtSummaryByCurrency customerDebts;
  final DebtSummaryByCurrency wholesalerDebts;
  final PaymentBreakdownByCurrency paymentBreakdown;
  final TrendPointsByCurrency salesTrend;
  final InventoryStatsByCurrency inventory;
  final DateTime generatedAt;

  factory RetailerDashboard.fromJson(Map<String, dynamic> json) => RetailerDashboard(
        todaySales: CountAndAmountByCurrency.fromJson(json['todaySales'] as Map<String, dynamic>),
        totalSales: CountAndAmountByCurrency.fromJson(json['totalSales'] as Map<String, dynamic>),
        cashReceived: CountAndAmountByCurrency.fromJson(json['cashReceived'] as Map<String, dynamic>),
        cardReceived: CountAndAmountByCurrency.fromJson(json['cardReceived'] as Map<String, dynamic>),
        customerDebts: DebtSummaryByCurrency.fromJson(json['customerDebts'] as Map<String, dynamic>),
        wholesalerDebts: DebtSummaryByCurrency.fromJson(json['wholesalerDebts'] as Map<String, dynamic>),
        paymentBreakdown: PaymentBreakdownByCurrency.fromJson(json['paymentBreakdown'] as Map<String, dynamic>),
        salesTrend: TrendPointsByCurrency.fromJson(json['salesTrend'] as Map<String, dynamic>),
        inventory: InventoryStatsByCurrency.fromJson(json['inventory'] as Map<String, dynamic>),
        generatedAt: DateTime.parse(json['generatedAt'] as String),
      );
}
