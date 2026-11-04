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
    this.salary,
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

  /// The lead agent's salary (its own view and the owner's team view; never a staff agent's).
  final AgentSalarySummary? salary;
}

/// The lead agent's salary: each transfer's % of what its team sold from that transfer's units
/// (see Optom_Savdo CLAUDE.md "Agents (Dillers)" → "Diller salary"). Per currency, never summed.
class AgentSalarySummary {
  const AgentSalarySummary({required this.today, required this.last30, required this.total});

  final MoneyByCurrency today;
  final MoneyByCurrency last30;
  final MoneyByCurrency total;
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
    this.salaryIncome = 0,
  });

  final int salesCount;
  final double revenue;
  final double cost;
  final double netProfit;
  final double pendingProfit;
  final double ownDebts;

  /// The lead agent's salary on sales in the window — already added into [netProfit].
  final double salaryIncome;
}

class AgentProfit {
  const AgentProfit({required this.uzs, required this.usd});

  final AgentProfitStats uzs;
  final AgentProfitStats usd;
}
