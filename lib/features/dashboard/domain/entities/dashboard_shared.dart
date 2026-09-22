/// Shared value objects reused across the wholesaler/retailer dashboard
/// responses — field names/shapes mirror `reporting.service.ts` exactly
/// (`MoneyByCurrency`, `CountAndAmount(ByCurrency)`, `TrendPoint(sByCurrency)`,
/// `InventoryStats(ByCurrency)`). Unlike `Product`'s `Decimal` fields, every
/// numeric value here is already a plain JSON number — the reporting service
/// converts explicitly via its own `num()` helper before responding.
library;

class MoneyByCurrency {
  const MoneyByCurrency({required this.uzs, required this.usd});
  final double uzs;
  final double usd;

  factory MoneyByCurrency.fromJson(Map<String, dynamic> json) => MoneyByCurrency(
        uzs: (json['uzs'] as num).toDouble(),
        usd: (json['usd'] as num).toDouble(),
      );
}

class CountAndAmount {
  const CountAndAmount({required this.count, required this.amount});
  final int count;
  final double amount;

  factory CountAndAmount.fromJson(Map<String, dynamic> json) => CountAndAmount(
        count: json['count'] as int,
        amount: (json['amount'] as num).toDouble(),
      );
}

class CountAndAmountByCurrency {
  const CountAndAmountByCurrency({required this.uzs, required this.usd});
  final CountAndAmount uzs;
  final CountAndAmount usd;

  factory CountAndAmountByCurrency.fromJson(Map<String, dynamic> json) => CountAndAmountByCurrency(
        uzs: CountAndAmount.fromJson(json['uzs'] as Map<String, dynamic>),
        usd: CountAndAmount.fromJson(json['usd'] as Map<String, dynamic>),
      );
}

/// `outstandingDebts`/`customerDebts`/`wholesalerDebts`-style shape:
/// count + balance + originalAmount.
class DebtSummary {
  const DebtSummary({required this.count, required this.balance, required this.originalAmount});
  final int count;
  final double balance;
  final double originalAmount;

  factory DebtSummary.fromJson(Map<String, dynamic> json) => DebtSummary(
        count: json['count'] as int,
        balance: (json['balance'] as num).toDouble(),
        originalAmount: (json['originalAmount'] as num).toDouble(),
      );
}

class DebtSummaryByCurrency {
  const DebtSummaryByCurrency({required this.uzs, required this.usd});
  final DebtSummary uzs;
  final DebtSummary usd;

  factory DebtSummaryByCurrency.fromJson(Map<String, dynamic> json) => DebtSummaryByCurrency(
        uzs: DebtSummary.fromJson(json['uzs'] as Map<String, dynamic>),
        usd: DebtSummary.fromJson(json['usd'] as Map<String, dynamic>),
      );
}

/// `{allTime, today}` pair — `receivedPayments`/`cardPayments` on the
/// wholesaler dashboard.
class AllTimeAndToday {
  const AllTimeAndToday({required this.allTime, required this.today});
  final CountAndAmountByCurrency allTime;
  final CountAndAmountByCurrency today;

  factory AllTimeAndToday.fromJson(Map<String, dynamic> json) => AllTimeAndToday(
        allTime: CountAndAmountByCurrency.fromJson(json['allTime'] as Map<String, dynamic>),
        today: CountAndAmountByCurrency.fromJson(json['today'] as Map<String, dynamic>),
      );
}

class PaymentBreakdown {
  const PaymentBreakdown({required this.cash, required this.card, required this.bankTransfer, required this.debt});
  final double cash;
  final double card;
  final double bankTransfer;
  final double debt;

  factory PaymentBreakdown.fromJson(Map<String, dynamic> json) => PaymentBreakdown(
        cash: (json['cash'] as num).toDouble(),
        card: (json['card'] as num).toDouble(),
        bankTransfer: (json['bankTransfer'] as num).toDouble(),
        debt: (json['debt'] as num).toDouble(),
      );

  double get total => cash + card + bankTransfer + debt;
}

class PaymentBreakdownByCurrency {
  const PaymentBreakdownByCurrency({required this.uzs, required this.usd});
  final PaymentBreakdown uzs;
  final PaymentBreakdown usd;

  factory PaymentBreakdownByCurrency.fromJson(Map<String, dynamic> json) => PaymentBreakdownByCurrency(
        uzs: PaymentBreakdown.fromJson(json['uzs'] as Map<String, dynamic>),
        usd: PaymentBreakdown.fromJson(json['usd'] as Map<String, dynamic>),
      );
}

class TrendPoint {
  const TrendPoint({
    required this.date,
    required this.cash,
    required this.card,
    required this.bankTransfer,
    required this.debt,
    required this.total,
  });
  final String date;
  final double cash;
  final double card;
  final double bankTransfer;
  final double debt;
  final double total;

  factory TrendPoint.fromJson(Map<String, dynamic> json) => TrendPoint(
        date: json['date'] as String,
        cash: (json['cash'] as num).toDouble(),
        card: (json['card'] as num).toDouble(),
        bankTransfer: (json['bankTransfer'] as num).toDouble(),
        debt: (json['debt'] as num).toDouble(),
        total: (json['total'] as num).toDouble(),
      );
}

class TrendPointsByCurrency {
  const TrendPointsByCurrency({required this.uzs, required this.usd});
  final List<TrendPoint> uzs;
  final List<TrendPoint> usd;

  factory TrendPointsByCurrency.fromJson(Map<String, dynamic> json) => TrendPointsByCurrency(
        uzs: (json['uzs'] as List).map((e) => TrendPoint.fromJson(e as Map<String, dynamic>)).toList(),
        usd: (json['usd'] as List).map((e) => TrendPoint.fromJson(e as Map<String, dynamic>)).toList(),
      );
}

class InventoryStats {
  const InventoryStats({required this.totalCostValue, required this.totalStockValue, required this.expectedProfit});
  final double totalCostValue;
  final double totalStockValue;
  final double expectedProfit;

  factory InventoryStats.fromJson(Map<String, dynamic> json) => InventoryStats(
        totalCostValue: (json['totalCostValue'] as num).toDouble(),
        totalStockValue: (json['totalStockValue'] as num).toDouble(),
        expectedProfit: (json['expectedProfit'] as num).toDouble(),
      );
}

class InventoryStatsByCurrency {
  const InventoryStatsByCurrency({required this.uzs, required this.usd});
  final InventoryStats uzs;
  final InventoryStats usd;

  factory InventoryStatsByCurrency.fromJson(Map<String, dynamic> json) => InventoryStatsByCurrency(
        uzs: InventoryStats.fromJson(json['uzs'] as Map<String, dynamic>),
        usd: InventoryStats.fromJson(json['usd'] as Map<String, dynamic>),
      );
}

/// `income-debt-chart`'s per-month point (6 entries, oldest → newest).
class IncomeDebtPoint {
  const IncomeDebtPoint({required this.month, required this.income, required this.debt});
  final String month;
  final double income;
  final double debt;

  factory IncomeDebtPoint.fromJson(Map<String, dynamic> json) => IncomeDebtPoint(
        month: json['month'] as String,
        income: (json['income'] as num).toDouble(),
        debt: (json['debt'] as num).toDouble(),
      );
}

class IncomeDebtChart {
  const IncomeDebtChart({required this.uzs, required this.usd});
  final List<IncomeDebtPoint> uzs;
  final List<IncomeDebtPoint> usd;

  factory IncomeDebtChart.fromJson(Map<String, dynamic> json) => IncomeDebtChart(
        uzs: (json['uzs'] as List).map((e) => IncomeDebtPoint.fromJson(e as Map<String, dynamic>)).toList(),
        usd: (json['usd'] as List).map((e) => IncomeDebtPoint.fromJson(e as Map<String, dynamic>)).toList(),
      );
}
