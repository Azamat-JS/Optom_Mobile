import 'package:bsmart/core/entities/reporting_shared.dart';
import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/sale_enums.dart';
import 'package:bsmart/features/agents/domain/entities/agent_sale.dart';

/// A customer's debt from an agent sale (`SaleDebt` in the lead agent's ledger).
class AgentDebt {
  const AgentDebt({
    required this.id,
    required this.originalAmount,
    required this.paidAmount,
    required this.balance,
    required this.currency,
    required this.status,
    required this.createdAt,
    required this.customer,
    required this.saleNumber,
    this.seller,
  });

  final String id;
  final double originalAmount;
  final double paidAmount;
  final double balance;
  final Currency currency;
  final DebtStatus status;
  final DateTime createdAt;
  final AgentPerson customer;
  final AgentPerson? seller;
  final String saleNumber;

  bool get isOpen => status == DebtStatus.active || status == DebtStatus.partial || status == DebtStatus.overdue;
}

class AgentDebtPayment {
  const AgentDebtPayment({required this.id, required this.amount, required this.paidAt, this.notes, this.by});

  final String id;
  final double amount;
  final DateTime paidAt;
  final String? notes;
  final AgentPerson? by;
}

class AgentDebtDetail {
  const AgentDebtDetail({required this.debt, required this.payments});

  final AgentDebt debt;
  final List<AgentDebtPayment> payments;
}

/// One page of debts plus the outstanding total of the whole filtered list, per currency.
class AgentDebtsPage {
  const AgentDebtsPage({required this.items, required this.hasNext, required this.totalBalance});

  final List<AgentDebt> items;
  final bool hasNext;
  final MoneyByCurrency totalBalance;
}
