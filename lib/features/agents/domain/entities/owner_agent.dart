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
/// lead agent owes [price]; [agentMaxPrice]/[agentDiscountPercent] are the price and discount its
/// agents currently sell it at, if it already has the product.
class TransferableProduct {
  const TransferableProduct({
    required this.product,
    required this.price,
    required this.currency,
    required this.stock,
    this.agentStock,
    this.agentMaxPrice,
    this.agentDiscountPercent,
    this.discountPercent,
  });

  final AgentProductRef product;
  final double price;
  final Currency currency;
  final double stock;
  final double? agentStock;
  final double? agentMaxPrice;
  final double? agentDiscountPercent;

  /// The product's own discount limit (null = none) — the transfer's discount starts with it.
  final double? discountPercent;
}

class AgentTransferLineParams {
  const AgentTransferLineParams({
    required this.productId,
    required this.quantity,
    required this.price,
    required this.discountPercent,
  });

  final String productId;
  final double quantity;

  /// What agents sell one unit for, and the discount (%) they may give off it.
  final double price;
  final double discountPercent;

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'quantity': quantity,
    'price': price,
    'discountPercent': discountPercent,
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
