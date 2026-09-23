import 'package:bsmart/core/entities/reporting_shared.dart';

/// `salesByPaymentMethod`'s per-currency bucket on `/reports/period-stats` —
/// 6 methods (unlike the dashboard's `PaymentBreakdown`, which only has 4:
/// no `click`/`payme` there). Mirrors `reporting.service.ts`'s `shiftSummary`
/// exactly, confirmed by reading the real implementation, not just the
/// (occasionally stale, see `CLAUDE.md`) Swagger doc comment.
class SalesByPaymentMethod {
  const SalesByPaymentMethod({
    required this.cash,
    required this.card,
    required this.bankTransfer,
    required this.click,
    required this.payme,
    required this.debt,
  });

  final double cash;
  final double card;
  final double bankTransfer;
  final double click;
  final double payme;
  final double debt;

  factory SalesByPaymentMethod.fromJson(Map<String, dynamic> json) => SalesByPaymentMethod(
        cash: (json['cash'] as num).toDouble(),
        card: (json['card'] as num).toDouble(),
        bankTransfer: (json['bankTransfer'] as num).toDouble(),
        click: (json['click'] as num).toDouble(),
        payme: (json['payme'] as num).toDouble(),
        debt: (json['debt'] as num).toDouble(),
      );

  double get total => cash + card + bankTransfer + click + payme + debt;
}

class SalesByPaymentMethodByCurrency {
  const SalesByPaymentMethodByCurrency({required this.uzs, required this.usd});
  final SalesByPaymentMethod uzs;
  final SalesByPaymentMethod usd;

  factory SalesByPaymentMethodByCurrency.fromJson(Map<String, dynamic> json) => SalesByPaymentMethodByCurrency(
        uzs: SalesByPaymentMethod.fromJson(json['uzs'] as Map<String, dynamic>),
        usd: SalesByPaymentMethod.fromJson(json['usd'] as Map<String, dynamic>),
      );
}

/// `GET /reports/period-stats` — same shape as the `WorkDay.summary` JSON
/// snapshot (`ShiftSummary` on the backend), just windowed by a
/// caller-selected period instead of a shift's start/end.
class PeriodStats {
  const PeriodStats({
    required this.from,
    required this.to,
    required this.totalRevenue,
    required this.salesByPaymentMethod,
    required this.newDebtsCreated,
    required this.newOwnDebtsCreated,
    required this.debtPaymentsCollected,
    required this.outstandingDebtsAtClose,
    required this.ownDebtsAtClose,
  });

  final DateTime from;
  final DateTime to;
  final MoneyByCurrency totalRevenue;
  final SalesByPaymentMethodByCurrency salesByPaymentMethod;
  final CountAndAmountByCurrency newDebtsCreated;
  final CountAndAmountByCurrency newOwnDebtsCreated;
  final CountAndAmountByCurrency debtPaymentsCollected;
  final DebtSummaryByCurrency outstandingDebtsAtClose;
  final DebtSummaryByCurrency ownDebtsAtClose;

  factory PeriodStats.fromJson(Map<String, dynamic> json) => PeriodStats(
        from: DateTime.parse(json['from'] as String),
        to: DateTime.parse(json['to'] as String),
        totalRevenue: MoneyByCurrency.fromJson(json['totalRevenue'] as Map<String, dynamic>),
        salesByPaymentMethod: SalesByPaymentMethodByCurrency.fromJson(
          json['salesByPaymentMethod'] as Map<String, dynamic>,
        ),
        newDebtsCreated: CountAndAmountByCurrency.fromJson(json['newDebtsCreated'] as Map<String, dynamic>),
        newOwnDebtsCreated: CountAndAmountByCurrency.fromJson(json['newOwnDebtsCreated'] as Map<String, dynamic>),
        debtPaymentsCollected: CountAndAmountByCurrency.fromJson(
          json['debtPaymentsCollected'] as Map<String, dynamic>,
        ),
        outstandingDebtsAtClose: DebtSummaryByCurrency.fromJson(
          json['outstandingDebtsAtClose'] as Map<String, dynamic>,
        ),
        ownDebtsAtClose: DebtSummaryByCurrency.fromJson(json['ownDebtsAtClose'] as Map<String, dynamic>),
      );
}
