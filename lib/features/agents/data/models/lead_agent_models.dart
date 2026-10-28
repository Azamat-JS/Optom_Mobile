import 'package:bsmart/core/entities/reporting_shared.dart';
import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/sale_enums.dart';
import 'package:bsmart/core/utils/decimal_parser.dart';
import 'package:bsmart/features/agents/data/models/agent_models.dart';
import 'package:bsmart/features/agents/domain/entities/agent_account_user.dart';
import 'package:bsmart/features/agents/domain/entities/agent_requests.dart';
import 'package:bsmart/features/agents/domain/entities/agent_transfer.dart';

// Shapes confirmed against Optom_Savdo/apps/server/src/agent/{agent-request,agent-transfer,
// agent-account}.service.ts. Decimals arrive as strings (see parseDecimal).

MoneyByCurrency _money(dynamic json) => json is Map<String, dynamic>
    ? MoneyByCurrency(uzs: parseDecimal(json['uzs'] ?? 0), usd: parseDecimal(json['usd'] ?? 0))
    : const MoneyByCurrency(uzs: 0, usd: 0);

DateTime? _date(dynamic value) => value is String ? DateTime.parse(value) : null;

LeadAgentAccount leadAgentAccountFromJson(Map<String, dynamic> json) {
  final owner = json['owner'] as Map<String, dynamic>?;
  final shop = owner?['shopName'] as String?;
  return LeadAgentAccount(
    ownerName: owner == null
        ? ''
        : (shop != null && shop.isNotEmpty ? shop : '${owner['firstName']} ${owner['lastName']}'.trim()),
    debt: _money(json['debt']),
    pendingPayments: _money(json['pendingPayments']),
    pendingReturns: (json['pendingReturns'] as num?)?.toInt() ?? 0,
  );
}

AgentPaymentRequest agentPaymentRequestFromJson(Map<String, dynamic> json) => AgentPaymentRequest(
  id: json['id'] as String,
  status: AgentRequestStatus.fromWire(json['status'] as String),
  amount: parseDecimal(json['amount']),
  currency: Currency.fromWire(json['currency'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  leadAgent: agentPersonFromJson(json['leadAgent'] as Map<String, dynamic>),
  notes: json['notes'] as String?,
  rejectReason: json['rejectReason'] as String?,
  decidedAt: _date(json['decidedAt']),
);

AgentReturn agentReturnFromJson(Map<String, dynamic> json) => AgentReturn(
  id: json['id'] as String,
  returnNumber: json['returnNumber'] as String,
  status: AgentRequestStatus.fromWire(json['status'] as String),
  currency: Currency.fromWire(json['currency'] as String),
  value: parseDecimal(json['value']),
  refundAmount: parseDecimal(json['refundAmount'] ?? 0),
  createdAt: DateTime.parse(json['createdAt'] as String),
  leadAgent: agentPersonFromJson(json['leadAgent'] as Map<String, dynamic>),
  itemCount: (json['itemCount'] as num?)?.toInt() ?? (json['items'] as List?)?.length ?? 0,
  notes: json['notes'] as String?,
  rejectReason: json['rejectReason'] as String?,
);

AgentReturnDetail agentReturnDetailFromJson(Map<String, dynamic> json) => AgentReturnDetail(
  ret: agentReturnFromJson(json),
  lines: [
    for (final raw in (json['items'] as List? ?? []))
      () {
        final line = raw as Map<String, dynamic>;
        return AgentReturnLine(
          id: line['id'] as String,
          productName: line['productName'] as String,
          unit: agentUnitFromWire(line['productUnit']),
          quantity: parseDecimal(line['quantity']),
          unitPrice: parseDecimal(line['unitPrice']),
          transferNumber: line['transferNumber'] as String? ?? '',
        );
      }(),
  ],
);

AgentTransfer agentTransferFromJson(Map<String, dynamic> json) {
  final debt = json['debt'] as Map<String, dynamic>?;
  return AgentTransfer(
    id: json['id'] as String,
    transferNumber: json['transferNumber'] as String,
    currency: Currency.fromWire(json['currency'] as String),
    total: parseDecimal(json['total']),
    paidAmount: parseDecimal(json['paidAmount'] ?? 0),
    createdAt: DateTime.parse(json['createdAt'] as String),
    leadAgent: agentPersonFromJson(json['leadAgent'] as Map<String, dynamic>),
    itemCount: (json['itemCount'] as num?)?.toInt() ?? (json['items'] as List?)?.length ?? 0,
    notes: json['notes'] as String?,
    debtBalance: debt == null ? null : parseDecimal(debt['balance']),
    debtStatus: debt == null ? null : DebtStatus.fromWire(debt['status'] as String),
  );
}

AgentTransferDetail agentTransferDetailFromJson(Map<String, dynamic> json) {
  final createdBy = json['createdBy'] as Map<String, dynamic>?;
  return AgentTransferDetail(
    transfer: agentTransferFromJson(json),
    storeName: (json['store'] as Map<String, dynamic>?)?['name'] as String?,
    givenBy: createdBy == null ? null : agentPersonFromJson(createdBy),
    lines: [
      for (final raw in (json['items'] as List? ?? []))
        () {
          final line = raw as Map<String, dynamic>;
          return AgentTransferLine(
            id: line['id'] as String,
            productName: line['productName'] as String,
            unit: agentUnitFromWire(line['productUnit']),
            quantity: parseDecimal(line['quantity']),
            remaining: parseDecimal(line['remaining']),
            returnedQuantity: parseDecimal(line['returnedQuantity'] ?? 0),
            unitPrice: parseDecimal(line['unitPrice']),
            total: parseDecimal(line['total']),
            minPrice: parseDecimal(line['minPrice']),
            maxPrice: parseDecimal(line['maxPrice']),
            costPrice: parseNullableDecimal(line['costPrice']),
          );
        }(),
    ],
  );
}

AgentAccountUser agentAccountUserFromJson(Map<String, dynamic> json) {
  final store = json['agentStore'] as Map<String, dynamic>?;
  return AgentAccountUser(
    id: json['id'] as String,
    phone: json['phone'] as String,
    firstName: json['firstName'] as String,
    lastName: json['lastName'] as String,
    isActive: json['isActive'] as bool? ?? true,
    createdAt: DateTime.parse(json['createdAt'] as String),
    storeId: json['agentStoreId'] as String?,
    storeName: store?['name'] as String?,
    staffCount: (json['staffCount'] as num?)?.toInt(),
    pendingCount: (json['pendingCount'] as num?)?.toInt(),
  );
}
