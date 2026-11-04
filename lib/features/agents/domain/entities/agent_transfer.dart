import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/product_unit.dart';
import 'package:bsmart/core/enums/sale_enums.dart';
import 'package:bsmart/features/agents/domain/entities/agent_sale.dart';

/// One owner → lead agent hand-over (`AgentTransfer`). The lead agent owes each line's price; the
/// transfer's debt is that total less what was paid on hand-over.
class AgentTransfer {
  const AgentTransfer({
    required this.id,
    required this.transferNumber,
    required this.currency,
    required this.total,
    required this.paidAmount,
    required this.createdAt,
    required this.leadAgent,
    required this.itemCount,
    this.notes,
    this.debtBalance,
    this.debtStatus,
    this.salaryPercent = 0,
    this.salarySoldQuantity = 0,
    this.salarySoldRevenue = 0,
    this.salaryEarned = 0,
  });

  final String id;
  final String transferNumber;
  final Currency currency;
  final double total;
  final double paidAmount;
  final DateTime createdAt;
  final AgentPerson leadAgent;
  final int itemCount;
  final String? notes;
  final double? debtBalance;
  final DebtStatus? debtStatus;

  /// The lead agent's salary on this transfer: this % of what its team sells from these units.
  final double salaryPercent;

  /// Sold so far from this transfer, what it sold for, and the salary earned on it.
  final double salarySoldQuantity;
  final double salarySoldRevenue;
  final double salaryEarned;
}

class AgentTransferLine {
  const AgentTransferLine({
    required this.id,
    required this.productName,
    this.unit,
    required this.quantity,
    required this.remaining,
    required this.returnedQuantity,
    required this.unitPrice,
    required this.total,
    required this.minPrice,
    required this.maxPrice,
    this.discountPercent = 0,
    this.costPrice,
  });

  final String id;
  final String productName;
  final ProductUnit? unit;
  final double quantity;

  /// Still with the lead agent (not yet sold or returned).
  final double remaining;
  final double returnedQuantity;

  /// What the lead agent owes per unit.
  final double unitPrice;
  final double total;
  final double minPrice;
  final double maxPrice;
  final double discountPercent;

  /// The owner's own cost — sent to the owner only.
  final double? costPrice;
}

class AgentTransferDetail {
  const AgentTransferDetail({required this.transfer, required this.lines, this.storeName, this.givenBy});

  final AgentTransfer transfer;
  final List<AgentTransferLine> lines;
  final String? storeName;
  final AgentPerson? givenBy;
}
