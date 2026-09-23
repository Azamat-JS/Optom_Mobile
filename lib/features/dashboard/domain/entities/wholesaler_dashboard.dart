import 'package:bsmart/core/entities/reporting_shared.dart';

/// `GET /reports/wholesaler` — SELLER/SELLER_ADMIN only.
class WholesalerDashboard {
  const WholesalerDashboard({
    required this.todaySales,
    required this.totalSales,
    required this.outstandingDebts,
    required this.receivedPayments,
    required this.cardPayments,
    required this.paymentBreakdown,
    required this.salesTrend,
    required this.inventory,
    required this.generatedAt,
  });

  final CountAndAmountByCurrency todaySales;
  final CountAndAmountByCurrency totalSales;
  final DebtSummaryByCurrency outstandingDebts;
  final AllTimeAndToday receivedPayments;
  final AllTimeAndToday cardPayments;
  final PaymentBreakdownByCurrency paymentBreakdown;
  final TrendPointsByCurrency salesTrend;
  final InventoryStatsByCurrency inventory;
  final DateTime generatedAt;

  factory WholesalerDashboard.fromJson(Map<String, dynamic> json) => WholesalerDashboard(
        todaySales: CountAndAmountByCurrency.fromJson(json['todaySales'] as Map<String, dynamic>),
        totalSales: CountAndAmountByCurrency.fromJson(json['totalSales'] as Map<String, dynamic>),
        outstandingDebts: DebtSummaryByCurrency.fromJson(json['outstandingDebts'] as Map<String, dynamic>),
        receivedPayments: AllTimeAndToday.fromJson(json['receivedPayments'] as Map<String, dynamic>),
        cardPayments: AllTimeAndToday.fromJson(json['cardPayments'] as Map<String, dynamic>),
        paymentBreakdown: PaymentBreakdownByCurrency.fromJson(json['paymentBreakdown'] as Map<String, dynamic>),
        salesTrend: TrendPointsByCurrency.fromJson(json['salesTrend'] as Map<String, dynamic>),
        inventory: InventoryStatsByCurrency.fromJson(json['inventory'] as Map<String, dynamic>),
        generatedAt: DateTime.parse(json['generatedAt'] as String),
      );
}
