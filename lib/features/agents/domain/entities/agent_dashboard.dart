import 'package:bsmart/core/entities/reporting_shared.dart';

/// `GET /agent/summary`: a lead agent's whole team, or a staff agent's own sales and debts.
class AgentSummary {
  const AgentSummary({
    required this.todayCount,
    required this.todayRevenue,
    required this.monthCount,
    required this.monthRevenue,
    required this.customerDebt,
    required this.openDebtCount,
    this.debtToOwner,
    this.stockValue,
  });

  final int todayCount;
  final MoneyByCurrency todayRevenue;
  final int monthCount;
  final MoneyByCurrency monthRevenue;
  final MoneyByCurrency customerDebt;
  final int openDebtCount;

  /// Lead agent only.
  final MoneyByCurrency? debtToOwner;
  final MoneyByCurrency? stockValue;
}

/// The windows `GET /agent/profit?period=` accepts that this app offers.
enum AgentProfitPeriod {
  today,
  last7,
  last30;

  String toWire() => name;
}

/// One currency of the lead agent's net profit (same rules as the owner's "Sof foyda"): credit
/// sales count only for what customers paid; [pendingProfit] waits for the rest. [ownDebts] is
/// its unpaid debt to the owner taken in the window — shown, never subtracted.
class AgentProfitStats {
  const AgentProfitStats({
    required this.salesCount,
    required this.revenue,
    required this.cost,
    required this.netProfit,
    required this.pendingProfit,
    required this.ownDebts,
  });

  final int salesCount;
  final double revenue;
  final double cost;
  final double netProfit;
  final double pendingProfit;
  final double ownDebts;
}

class AgentProfit {
  const AgentProfit({required this.uzs, required this.usd});

  final AgentProfitStats uzs;
  final AgentProfitStats usd;
}
