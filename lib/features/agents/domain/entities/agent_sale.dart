import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/product_unit.dart';
import 'package:bsmart/core/enums/sale_enums.dart';

class AgentPerson {
  const AgentPerson({required this.id, required this.firstName, required this.lastName, this.phone});

  final String id;
  final String firstName;
  final String lastName;
  final String? phone;

  String get fullName => '$firstName $lastName'.trim();
}

/// The lead agent's walk-in buyer for cash sales without a name (backend sentinel phone).
const agentWalkInPhone = '000000000';

/// An agent sale in a list (`GET /agent/sales`). The debt is set for a sale on debt.
class AgentSale {
  const AgentSale({
    required this.id,
    required this.saleNumber,
    required this.type,
    required this.currency,
    required this.total,
    required this.createdAt,
    required this.customer,
    required this.itemCount,
    this.seller,
    this.debtBalance,
    this.debtStatus,
  });

  final String id;
  final String saleNumber;
  final SaleType type;
  final Currency currency;
  final double total;
  final DateTime createdAt;
  final AgentPerson customer;
  final AgentPerson? seller;
  final int itemCount;
  final double? debtBalance;
  final DebtStatus? debtStatus;
}

class AgentSaleLine {
  const AgentSaleLine({
    required this.id,
    required this.productName,
    this.unit,
    required this.quantity,
    required this.unitPrice,
    required this.total,
    this.costPrice,
  });

  final String id;
  final String productName;
  final ProductUnit? unit;
  final double quantity;
  final double unitPrice;
  final double total;

  /// What the lead agent owes per unit — returned to the lead agent only.
  final double? costPrice;
}

class AgentSaleDetail {
  const AgentSaleDetail({required this.sale, required this.lines, this.notes, this.debtPaid});

  final AgentSale sale;
  final List<AgentSaleLine> lines;
  final String? notes;
  final double? debtPaid;
}
