import 'package:bsmart/core/entities/reporting_shared.dart';
import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/product_unit.dart';
import 'package:bsmart/features/agents/domain/entities/agent_sale.dart';

/// A lead agent's request the owner decides on (`AgentRequestStatus`).
enum AgentRequestStatus {
  pending,
  confirmed,
  rejected,
  cancelled;

  static AgentRequestStatus fromWire(String value) => switch (value) {
        'PENDING' => AgentRequestStatus.pending,
        'CONFIRMED' => AgentRequestStatus.confirmed,
        'REJECTED' => AgentRequestStatus.rejected,
        'CANCELLED' => AgentRequestStatus.cancelled,
        _ => throw ArgumentError('Unknown AgentRequestStatus from backend: $value'),
      };
}

/// Money the lead agent says it paid the owner — nothing moves until the owner confirms; then it
/// pays off the oldest debts first.
class AgentPaymentRequest {
  const AgentPaymentRequest({
    required this.id,
    required this.status,
    required this.amount,
    required this.currency,
    required this.createdAt,
    required this.leadAgent,
    this.notes,
    this.rejectReason,
    this.decidedAt,
  });

  final String id;
  final AgentRequestStatus status;
  final double amount;
  final Currency currency;
  final DateTime createdAt;
  final AgentPerson leadAgent;
  final String? notes;
  final String? rejectReason;
  final DateTime? decidedAt;
}

/// Unsold goods sent back to the owner. Units leave the lead agent's stock at once; on
/// confirmation its debt drops by what it was charged, and anything beyond the open debt is
/// refunded in cash ([refundAmount]).
class AgentReturn {
  const AgentReturn({
    required this.id,
    required this.returnNumber,
    required this.status,
    required this.currency,
    required this.value,
    required this.refundAmount,
    required this.createdAt,
    required this.leadAgent,
    required this.itemCount,
    this.notes,
    this.rejectReason,
  });

  final String id;
  final String returnNumber;
  final AgentRequestStatus status;
  final Currency currency;
  final double value;
  final double refundAmount;
  final DateTime createdAt;
  final AgentPerson leadAgent;
  final int itemCount;
  final String? notes;
  final String? rejectReason;
}

/// One returned part of one transfer line, at the price the lead agent was charged on it.
class AgentReturnLine {
  const AgentReturnLine({
    required this.id,
    required this.productName,
    this.unit,
    required this.quantity,
    required this.unitPrice,
    required this.transferNumber,
  });

  final String id;
  final String productName;
  final ProductUnit? unit;
  final double quantity;
  final double unitPrice;
  final String transferNumber;
}

class AgentReturnDetail {
  const AgentReturnDetail({required this.ret, required this.lines});

  final AgentReturn ret;
  final List<AgentReturnLine> lines;
}

/// `GET /agent/account`: the lead agent's standing with its business owner.
class LeadAgentAccount {
  const LeadAgentAccount({
    required this.ownerName,
    required this.debt,
    required this.pendingPayments,
    required this.pendingReturns,
  });

  final String ownerName;
  final MoneyByCurrency debt;
  final MoneyByCurrency pendingPayments;
  final int pendingReturns;

  /// What a new payment request may still claim, per currency (open debt − pending requests).
  MoneyByCurrency get available => MoneyByCurrency(
        uzs: (debt.uzs - pendingPayments.uzs).clamp(0, double.infinity).toDouble(),
        usd: (debt.usd - pendingPayments.usd).clamp(0, double.infinity).toDouble(),
      );
}

class AgentReturnLineParams {
  const AgentReturnLineParams({required this.agentProductId, required this.quantity});

  final String agentProductId;
  final double quantity;

  Map<String, dynamic> toJson() => {'agentProductId': agentProductId, 'quantity': quantity};
}
