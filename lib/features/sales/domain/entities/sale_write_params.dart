import 'package:bsmart/core/enums/payment_method.dart';
import 'package:bsmart/core/enums/sale_enums.dart';

/// Mirrors `SaleItemInputDto` — a manual/custom line item (no `productId`)
/// requires [productName]/[unitPrice]; a product-backed one only needs
/// [productId] (+ optional override [unitPrice]/[discount]).
class CreateSaleItemParams {
  const CreateSaleItemParams({
    this.productId,
    this.productName,
    required this.quantity,
    this.unitPrice,
    this.discount,
  });

  final String? productId;
  final String? productName;
  final double quantity;
  final double? unitPrice;
  final double? discount;

  Map<String, dynamic> toRequestBody() => {
        if (productId != null) 'productId': productId,
        if (productName != null) 'productName': productName,
        'quantity': quantity,
        if (unitPrice != null) 'unitPrice': unitPrice,
        if (discount != null && discount! > 0) 'discount': discount,
      };
}

/// Mirrors `CreateSaleDto` exactly.
class CreateSaleParams {
  const CreateSaleParams({
    required this.customerId,
    required this.type,
    this.paymentMethod,
    required this.items,
    this.discount,
    this.notes,
    this.dueDate,
    this.debtNotes,
    this.paidAmount,
  });

  final String customerId;
  final SaleType type;
  final PaymentMethod? paymentMethod;
  final List<CreateSaleItemParams> items;
  final double? discount;
  final String? notes;
  final DateTime? dueDate;
  final String? debtNotes;
  final double? paidAmount;

  Map<String, dynamic> toRequestBody() => {
        'customerId': customerId,
        'type': type.toWire(),
        if (paymentMethod != null) 'paymentMethod': paymentMethod!.toWire(),
        'items': items.map((i) => i.toRequestBody()).toList(),
        if (discount != null && discount! > 0) 'discount': discount,
        if (notes != null && notes!.isNotEmpty) 'notes': notes,
        if (dueDate != null) 'dueDate': dueDate!.toUtc().toIso8601String(),
        if (debtNotes != null && debtNotes!.isNotEmpty) 'debtNotes': debtNotes,
        if (paidAmount != null && paidAmount! > 0) 'paidAmount': paidAmount,
      };
}

/// Mirrors `CreateSaleReturnDto`.
class CreateSaleReturnItemParams {
  const CreateSaleReturnItemParams({required this.saleItemId, required this.quantity});

  final String saleItemId;
  final double quantity;

  Map<String, dynamic> toRequestBody() => {'saleItemId': saleItemId, 'quantity': quantity};
}

class CreateSaleReturnParams {
  const CreateSaleReturnParams({required this.items, this.reason, this.refundMethod});

  final List<CreateSaleReturnItemParams> items;
  final String? reason;
  final PaymentMethod? refundMethod;

  Map<String, dynamic> toRequestBody() => {
        'items': items.map((i) => i.toRequestBody()).toList(),
        if (reason != null && reason!.isNotEmpty) 'reason': reason,
        if (refundMethod != null) 'refundMethod': refundMethod!.toWire(),
      };
}
