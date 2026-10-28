import 'package:bsmart/core/entities/reporting_shared.dart';
import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/features/agents/domain/entities/agent_stock_item.dart';

/// `GET /lead-agents/:id` — one lead agent as its business owner sees it: what it holds (at the
/// price it owes), its open debt, its staff, and requests waiting for the owner.
class LeadAgentSummary {
  const LeadAgentSummary({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.isActive,
    required this.staffCount,
    required this.stockValue,
    required this.debt,
    required this.pendingPayments,
    required this.pendingReturns,
    this.storeId,
    this.storeName,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final bool isActive;
  final String? storeId;
  final String? storeName;
  final int staffCount;
  final MoneyByCurrency stockValue;
  final MoneyByCurrency debt;
  final int pendingPayments;
  final int pendingReturns;

  String get fullName => '$firstName $lastName'.trim();
}

/// One of the owner's products (in the lead agent's store, in stock) that can be handed over. The
/// lead agent owes [price]; [agentMinPrice]/[agentMaxPrice] are its current range for it, if any.
class TransferableProduct {
  const TransferableProduct({
    required this.product,
    required this.price,
    required this.currency,
    required this.stock,
    this.agentStock,
    this.agentMinPrice,
    this.agentMaxPrice,
  });

  final AgentProductRef product;
  final double price;
  final Currency currency;
  final double stock;
  final double? agentStock;
  final double? agentMinPrice;
  final double? agentMaxPrice;
}

class AgentTransferLineParams {
  const AgentTransferLineParams({
    required this.productId,
    required this.quantity,
    required this.minPrice,
    required this.maxPrice,
  });

  final String productId;
  final double quantity;
  final double minPrice;
  final double maxPrice;

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'quantity': quantity,
    'minPrice': minPrice,
    'maxPrice': maxPrice,
  };
}

/// Mirrors `CreateAgentTransferDto`: whatever isn't paid now becomes the lead agent's debt.
class CreateAgentTransferParams {
  const CreateAgentTransferParams({required this.leadAgentId, required this.lines, this.paidAmount = 0, this.notes});

  final String leadAgentId;
  final List<AgentTransferLineParams> lines;
  final double paidAmount;
  final String? notes;

  Map<String, dynamic> toRequestBody() => {
    'leadAgentId': leadAgentId,
    'items': [for (final l in lines) l.toJson()],
    if (paidAmount > 0) 'paidAmount': paidAmount,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
  };
}
