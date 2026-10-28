import 'package:bsmart/core/entities/reporting_shared.dart';
import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/utils/decimal_parser.dart';
import 'package:bsmart/features/agents/data/models/agent_models.dart';
import 'package:bsmart/features/agents/domain/entities/owner_agent.dart';

// Shapes confirmed against Optom_Savdo/apps/server/src/agent/agent-stock.service.ts
// (leadSummary, transferableProducts). Decimals arrive as strings (see parseDecimal).

MoneyByCurrency _money(dynamic json) => json is Map<String, dynamic>
    ? MoneyByCurrency(uzs: parseDecimal(json['uzs'] ?? 0), usd: parseDecimal(json['usd'] ?? 0))
    : const MoneyByCurrency(uzs: 0, usd: 0);

LeadAgentSummary leadAgentSummaryFromJson(Map<String, dynamic> json) {
  final store = json['agentStore'] as Map<String, dynamic>?;
  return LeadAgentSummary(
    id: json['id'] as String,
    firstName: json['firstName'] as String? ?? '',
    lastName: json['lastName'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    isActive: json['isActive'] as bool? ?? true,
    storeId: json['agentStoreId'] as String?,
    storeName: store?['name'] as String?,
    staffCount: (json['staffCount'] as num?)?.toInt() ?? 0,
    stockValue: _money(json['stockValue']),
    debt: _money(json['debt']),
    pendingPayments: (json['pendingPayments'] as num?)?.toInt() ?? 0,
    pendingReturns: (json['pendingReturns'] as num?)?.toInt() ?? 0,
  );
}

TransferableProduct transferableProductFromJson(Map<String, dynamic> json) {
  final agent = json['agent'] as Map<String, dynamic>?;
  return TransferableProduct(
    product: agentProductRefFromJson(json),
    price: parseDecimal(json['price']),
    currency: Currency.fromWire(json['currency'] as String),
    stock: parseDecimal(json['stock']),
    agentStock: agent == null ? null : parseDecimal(agent['stock']),
    agentMinPrice: agent == null ? null : parseDecimal(agent['minPrice']),
    agentMaxPrice: agent == null ? null : parseDecimal(agent['maxPrice']),
  );
}
