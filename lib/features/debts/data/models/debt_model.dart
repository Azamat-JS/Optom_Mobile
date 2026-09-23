import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/payment_method.dart';
import 'package:bsmart/core/enums/sale_enums.dart';
import 'package:bsmart/core/utils/decimal_parser.dart';
import 'package:bsmart/features/debts/domain/entities/debt.dart';

DebtPersonRef? debtPersonRefFromJson(Map<String, dynamic>? json) {
  if (json == null) return null;
  return DebtPersonRef(
    id: json['id'] as String,
    firstName: json['firstName'] as String,
    lastName: json['lastName'] as String?,
    phone: json['phone'] as String?,
  );
}

PaymentEntry paymentEntryFromJson(Map<String, dynamic> json) => PaymentEntry(
      id: json['id'] as String,
      amount: parseDecimal(json['amount']),
      method: PaymentMethod.fromWire(json['method'] as String),
      paidAt: DateTime.parse(json['paidAt'] as String),
      notes: json['notes'] as String?,
    );

/// Parses a `Debt` row as returned by `debt.service.ts`'s `defaultIncludes()`
/// — `originalAmount`/`paidAmount`/`balance` and every payment `amount` are
/// `Decimal` fields serialized as JSON strings, same gotcha as `Product`/`Sale`.
Debt debtFromJson(Map<String, dynamic> json) {
  final paymentsJson = json['payments'] as List<dynamic>? ?? const [];
  return Debt(
    id: json['id'] as String,
    originalAmount: parseDecimal(json['originalAmount']),
    paidAmount: parseDecimal(json['paidAmount'] ?? 0),
    balance: parseDecimal(json['balance']),
    currency: Currency.fromWire(json['currency'] as String? ?? 'UZS'),
    status: DebtStatus.fromWire(json['status'] as String),
    dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null,
    notes: json['notes'] as String?,
    debtor: debtPersonRefFromJson(json['debtor'] as Map<String, dynamic>?),
    creditor: debtPersonRefFromJson(json['creditor'] as Map<String, dynamic>?),
    payments: paymentsJson.map((e) => paymentEntryFromJson(e as Map<String, dynamic>)).toList(),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}

/// Parses a `SaleDebt` row as returned by `sale-debt.service.ts`'s
/// `saleDebtIncludes`.
SaleDebt saleDebtFromJson(Map<String, dynamic> json) {
  final paymentsJson = json['payments'] as List<dynamic>? ?? const [];
  return SaleDebt(
    id: json['id'] as String,
    originalAmount: parseDecimal(json['originalAmount']),
    paidAmount: parseDecimal(json['paidAmount'] ?? 0),
    balance: parseDecimal(json['balance']),
    currency: Currency.fromWire(json['currency'] as String? ?? 'UZS'),
    status: DebtStatus.fromWire(json['status'] as String),
    dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null,
    notes: json['notes'] as String?,
    customer: debtPersonRefFromJson(json['customer'] as Map<String, dynamic>?),
    payments: paymentsJson.map((e) => paymentEntryFromJson(e as Map<String, dynamic>)).toList(),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
