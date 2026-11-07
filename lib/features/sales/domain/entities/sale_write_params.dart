import 'package:bsmart/core/enums/currency.dart';
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
    this.costPrice,
  });

  final String? productId;
  final String? productName;
  final double quantity;
  final double? unitPrice;
  final double? discount;

  /// Only for a line without a product (e.g. a restaurant's service charge: 0 = pure income).
  final double? costPrice;

  Map<String, dynamic> toRequestBody() => {
        if (productId != null) 'productId': productId,
        if (productName != null) 'productName': productName,
        'quantity': quantity,
        if (unitPrice != null) 'unitPrice': unitPrice,
        if (discount != null && discount! > 0) 'discount': discount,
        if (costPrice != null) 'costPrice': costPrice,
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
    this.restaurantOrderId,
  });

  /// The restaurant order this sale pays (the Kassa's "To'lovga o'tish"): links it and frees the table.
  final String? restaurantOrderId;

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
        if (restaurantOrderId != null) 'restaurantOrderId': restaurantOrderId,
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

/// `CreateManualRevenueDto.customer`: found by phone (last 9 digits) among the
/// store's customers, else created.
class ManualRevenueCustomer {
  const ManualRevenueCustomer({required this.firstName, this.lastName, required this.phone});

  final String firstName;
  final String? lastName;
  final String phone;

  Map<String, dynamic> toRequestBody() => {
        'firstName': firstName,
        if (lastName != null && lastName!.isNotEmpty) 'lastName': lastName,
        'phone': phone,
      };
}

/// Mirrors `CreateManualRevenueDto` (`POST /sales/manual-revenue`). Send
/// [customerId] or [customer], never both; neither = the walk-in buyer.
/// [date] is a `YYYY-MM-DD` Tashkent day, omitted for now
/// (see `manualRevenueDateParam`).
class CreateManualRevenueParams {
  const CreateManualRevenueParams({
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    this.date,
    this.customerId,
    this.customer,
  }) : assert(customerId == null || customer == null);

  final double amount;
  final Currency currency;
  final PaymentMethod paymentMethod;
  final String? date;
  final String? customerId;
  final ManualRevenueCustomer? customer;

  Map<String, dynamic> toRequestBody() => {
        'amount': amount,
        'currency': currency.toWire(),
        'paymentMethod': paymentMethod.toWire(),
        if (date != null) 'date': date,
        if (customerId != null) 'customerId': customerId,
        if (customer != null) 'customer': customer!.toRequestBody(),
      };
}
