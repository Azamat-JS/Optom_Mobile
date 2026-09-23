/// Mirrors `DebtQueryDto` exactly. [role] lets a RETAILER split "debts I owe"
/// (debtor) from "debts owed to me" (creditor) — a SELLER only ever sees the
/// creditor view by default (see `CLAUDE.md`'s "Customers / POS" reference
/// section for why a debtor-role toggle isn't exposed for SELLER in v1).
class DebtQuery {
  const DebtQuery({this.page = 1, this.limit = 500, this.debtorId, this.role});

  final int page;
  final int limit;
  final String? debtorId;
  final String? role;

  Map<String, dynamic> toQueryParameters() => {
        'page': page,
        'limit': limit,
        if (debtorId != null) 'debtorId': debtorId,
        if (role != null) 'role': role,
      };
}

/// Mirrors `SaleDebtQueryDto` exactly.
class SaleDebtQuery {
  const SaleDebtQuery({this.page = 1, this.limit = 500, this.customerId});

  final int page;
  final int limit;
  final String? customerId;

  Map<String, dynamic> toQueryParameters() => {
        'page': page,
        'limit': limit,
        if (customerId != null) 'customerId': customerId,
      };
}
