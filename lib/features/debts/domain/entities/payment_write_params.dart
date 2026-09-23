import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/payment_method.dart';

/// Mirrors `CreatePaymentDto` — exactly one of [debtId]/[saleDebtId] must be set.
class CreatePaymentParams {
  const CreatePaymentParams({
    this.debtId,
    this.saleDebtId,
    required this.amount,
    required this.method,
    this.notes,
  });

  final String? debtId;
  final String? saleDebtId;
  final double amount;
  final PaymentMethod method;
  final String? notes;

  Map<String, dynamic> toRequestBody() => {
        if (debtId != null) 'debtId': debtId,
        if (saleDebtId != null) 'saleDebtId': saleDebtId,
        'amount': amount,
        'method': method.toWire(),
        if (notes != null && notes!.isNotEmpty) 'notes': notes,
      };
}

/// Mirrors `PayDownDto` — exactly one of [debtorId]/[debtorNotes]/[customerId]
/// must be set, scoping the FIFO allocation to that person's debts.
class PayDownParams {
  const PayDownParams({
    this.debtorId,
    this.debtorNotes,
    this.customerId,
    required this.amount,
    required this.currency,
    required this.method,
    this.notes,
  });

  final String? debtorId;
  final String? debtorNotes;
  final String? customerId;
  final double amount;
  final Currency currency;
  final PaymentMethod method;
  final String? notes;

  Map<String, dynamic> toRequestBody() => {
        if (debtorId != null) 'debtorId': debtorId,
        if (debtorNotes != null) 'debtorNotes': debtorNotes,
        if (customerId != null) 'customerId': customerId,
        'amount': amount,
        'currency': currency.toWire(),
        'method': method.toWire(),
        if (notes != null && notes!.isNotEmpty) 'notes': notes,
      };
}

/// Mirrors `CloseDebtDto`.
class CloseDebtParams {
  const CloseDebtParams({this.notes});

  final String? notes;

  Map<String, dynamic> toRequestBody() => {if (notes != null && notes!.isNotEmpty) 'notes': notes};
}
