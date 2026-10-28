import 'package:bsmart/core/entities/reporting_shared.dart';
import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/product_unit.dart';
import 'package:bsmart/core/enums/sale_enums.dart';
import 'package:bsmart/core/utils/decimal_parser.dart';
import 'package:bsmart/features/agents/domain/entities/agent_dashboard.dart';
import 'package:bsmart/features/agents/domain/entities/agent_debt.dart';
import 'package:bsmart/features/agents/domain/entities/agent_sale.dart';
import 'package:bsmart/features/agents/domain/entities/agent_stock_item.dart';

// Shapes confirmed against Optom_Savdo/apps/server/src/agent/{agent-stock,agent-sale}.service.ts
// and reporting.service.ts#profitReport. Decimals arrive as strings (see parseDecimal).

/// Line units are point-in-time snapshots (free text server-side), so an unknown value is null.
ProductUnit? agentUnitFromWire(dynamic value) {
  if (value is! String) return null;
  try {
    return ProductUnit.fromWire(value);
  } catch (_) {
    return null;
  }
}

AgentPerson? _personOrNull(dynamic json) => json is Map<String, dynamic> ? agentPersonFromJson(json) : null;

AgentPerson agentPersonFromJson(Map<String, dynamic> json) => AgentPerson(
  id: json['id'] as String,
  firstName: json['firstName'] as String? ?? '',
  lastName: json['lastName'] as String? ?? '',
  phone: json['phone'] as String?,
);

/// The server's `productSummary` shape (name/image already resolved from the catalog entry).
AgentProductRef agentProductRefFromJson(Map<String, dynamic> json) => AgentProductRef(
  id: json['id'] as String,
  name: json['name'] as String? ?? '',
  unit: agentUnitFromWire(json['unit']),
  barcode: json['barcode'] as String?,
  imageUrl: json['imageUrl'] as String?,
);

AgentStockItem agentStockItemFromJson(Map<String, dynamic> json) => AgentStockItem(
  id: json['id'] as String,
  currency: Currency.fromWire(json['currency'] as String),
  stock: parseDecimal(json['stock']),
  minPrice: parseDecimal(json['minPrice']),
  maxPrice: parseDecimal(json['maxPrice']),
  product: agentProductRefFromJson(json['product'] as Map<String, dynamic>),
);

AgentSale agentSaleFromJson(Map<String, dynamic> json) {
  final debt = json['debt'] as Map<String, dynamic>?;
  return AgentSale(
    id: json['id'] as String,
    saleNumber: json['saleNumber'] as String,
    type: SaleType.fromWire(json['type'] as String),
    currency: Currency.fromWire(json['currency'] as String),
    total: parseDecimal(json['total']),
    createdAt: DateTime.parse(json['createdAt'] as String),
    customer: agentPersonFromJson(json['customer'] as Map<String, dynamic>),
    seller: _personOrNull(json['createdBy']),
    itemCount: (json['itemCount'] as num?)?.toInt() ?? (json['items'] as List?)?.length ?? 0,
    debtBalance: debt == null ? null : parseDecimal(debt['balance']),
    debtStatus: debt == null ? null : DebtStatus.fromWire(debt['status'] as String),
  );
}

AgentSaleDetail agentSaleDetailFromJson(Map<String, dynamic> json) {
  final debt = json['debt'] as Map<String, dynamic>?;
  return AgentSaleDetail(
    sale: agentSaleFromJson(json),
    notes: json['notes'] as String?,
    debtPaid: debt == null ? null : parseNullableDecimal(debt['paidAmount']),
    lines: [
      for (final raw in (json['items'] as List? ?? []))
        () {
          final line = raw as Map<String, dynamic>;
          return AgentSaleLine(
            id: line['id'] as String,
            productName: line['productName'] as String,
            unit: agentUnitFromWire(line['productUnit']),
            quantity: parseDecimal(line['quantity']),
            unitPrice: parseDecimal(line['unitPrice']),
            total: parseDecimal(line['total']),
            costPrice: parseNullableDecimal(line['costPrice']),
          );
        }(),
    ],
  );
}

AgentDebt agentDebtFromJson(Map<String, dynamic> json) => AgentDebt(
  id: json['id'] as String,
  originalAmount: parseDecimal(json['originalAmount']),
  paidAmount: parseDecimal(json['paidAmount']),
  balance: parseDecimal(json['balance']),
  currency: Currency.fromWire(json['currency'] as String),
  status: DebtStatus.fromWire(json['status'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  customer: agentPersonFromJson(json['customer'] as Map<String, dynamic>),
  seller: _personOrNull(json['createdBy']),
  saleNumber: (json['sale'] as Map<String, dynamic>?)?['saleNumber'] as String? ?? '',
);

AgentDebtDetail agentDebtDetailFromJson(Map<String, dynamic> json) => AgentDebtDetail(
  debt: agentDebtFromJson(json),
  payments: [
    for (final raw in (json['payments'] as List? ?? []))
      () {
        final p = raw as Map<String, dynamic>;
        return AgentDebtPayment(
          id: p['id'] as String,
          amount: parseDecimal(p['amount']),
          paidAt: DateTime.parse(p['paidAt'] as String),
          notes: p['notes'] as String?,
          by: _personOrNull(p['createdBy']),
        );
      }(),
  ],
);

MoneyByCurrency _money(dynamic json) => json is Map<String, dynamic>
    ? MoneyByCurrency(uzs: parseDecimal(json['uzs'] ?? 0), usd: parseDecimal(json['usd'] ?? 0))
    : const MoneyByCurrency(uzs: 0, usd: 0);

AgentSummary agentSummaryFromJson(Map<String, dynamic> json) {
  final today = json['today'] as Map<String, dynamic>;
  final month = json['last30'] as Map<String, dynamic>;
  return AgentSummary(
    todayCount: (today['count'] as num).toInt(),
    todayRevenue: _money(today['revenue']),
    monthCount: (month['count'] as num).toInt(),
    monthRevenue: _money(month['revenue']),
    customerDebt: _money(json['customerDebt']),
    openDebtCount: (json['openDebtCount'] as num?)?.toInt() ?? 0,
    debtToOwner: json['debtToOwner'] == null ? null : _money(json['debtToOwner']),
    stockValue: json['stockValue'] == null ? null : _money(json['stockValue']),
  );
}

AgentProfitStats _profitStats(Map<String, dynamic> json) => AgentProfitStats(
  salesCount: (json['salesCount'] as num?)?.toInt() ?? 0,
  revenue: parseDecimal(json['revenue'] ?? 0),
  cost: parseDecimal(json['cost'] ?? 0),
  netProfit: parseDecimal(json['netProfit'] ?? 0),
  pendingProfit: parseDecimal(json['pendingProfit'] ?? 0),
  ownDebts: parseDecimal(json['ownDebts'] ?? 0),
);

AgentProfit agentProfitFromJson(Map<String, dynamic> json) {
  final summary = json['summary'] as Map<String, dynamic>;
  return AgentProfit(
    uzs: _profitStats(summary['uzs'] as Map<String, dynamic>),
    usd: _profitStats(summary['usd'] as Map<String, dynamic>),
  );
}
