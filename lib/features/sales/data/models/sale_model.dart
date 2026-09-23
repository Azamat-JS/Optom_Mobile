import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/payment_method.dart';
import 'package:bsmart/core/enums/sale_enums.dart';
import 'package:bsmart/core/utils/decimal_parser.dart';
import 'package:bsmart/features/sales/domain/entities/sale.dart';

SalePersonRef? salePersonRefFromJson(Map<String, dynamic>? json) {
  if (json == null) return null;
  return SalePersonRef(
    id: json['id'] as String,
    firstName: json['firstName'] as String,
    lastName: json['lastName'] as String?,
    phone: json['phone'] as String?,
  );
}

SaleItem saleItemFromJson(Map<String, dynamic> json) => SaleItem(
      id: json['id'] as String,
      productName: json['productName'] as String,
      productSku: json['productSku'] as String?,
      productUnit: json['productUnit'] as String?,
      quantity: parseDecimal(json['quantity']),
      unitPrice: parseDecimal(json['unitPrice']),
      discount: parseDecimal(json['discount'] ?? 0),
      total: parseDecimal(json['total']),
      returnedQuantity: parseDecimal(json['returnedQuantity'] ?? 0),
      productId: json['productId'] as String?,
    );

SalePayment salePaymentFromJson(Map<String, dynamic> json) => SalePayment(
      id: json['id'] as String,
      amount: parseDecimal(json['amount']),
      method: PaymentMethod.fromWire(json['method'] as String),
      status: json['status'] as String,
      paidAt: DateTime.parse(json['paidAt'] as String),
    );

SaleDebtRef? saleDebtRefFromJson(dynamic json) {
  if (json is! Map<String, dynamic> || json.isEmpty) return null;
  return SaleDebtRef(
    id: json['id'] as String,
    originalAmount: parseDecimal(json['originalAmount']),
    paidAmount: parseDecimal(json['paidAmount'] ?? 0),
    balance: parseDecimal(json['balance']),
    currency: Currency.fromWire(json['currency'] as String? ?? 'UZS'),
    status: DebtStatus.fromWire(json['status'] as String),
    dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null,
  );
}

/// Parses a `Sale` row as returned by `sale.service.ts`'s `saleIncludes()` —
/// `subtotal`/`discount`/`total` and every item/payment amount are `Decimal`
/// fields serialized as JSON strings, same gotcha as `Product`.
Sale saleFromJson(Map<String, dynamic> json) {
  final itemsJson = json['items'] as List<dynamic>? ?? const [];
  final paymentsJson = json['payments'] as List<dynamic>? ?? const [];

  return Sale(
    id: json['id'] as String,
    saleNumber: json['saleNumber'] as String,
    type: SaleType.fromWire(json['type'] as String),
    status: SaleStatus.fromWire(json['status'] as String),
    currency: Currency.fromWire(json['currency'] as String? ?? 'UZS'),
    subtotal: parseDecimal(json['subtotal']),
    discount: parseDecimal(json['discount'] ?? 0),
    total: parseDecimal(json['total']),
    notes: json['notes'] as String?,
    customer: salePersonRefFromJson(json['customer'] as Map<String, dynamic>?),
    createdBy: salePersonRefFromJson(json['createdBy'] as Map<String, dynamic>?),
    items: itemsJson.map((e) => saleItemFromJson(e as Map<String, dynamic>)).toList(),
    payments: paymentsJson.map((e) => salePaymentFromJson(e as Map<String, dynamic>)).toList(),
    debt: saleDebtRefFromJson(json['debt']),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
