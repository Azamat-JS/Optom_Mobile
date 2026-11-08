import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/payment_method.dart';
import 'package:bsmart/core/enums/sale_enums.dart';

/// A minimal customer/staff reference embedded on a sale — deliberately not
/// the `customers` feature's own `Customer` entity (same precedent as
/// `orders`' `OrderPersonRef`, see `CLAUDE.md`).
class SalePersonRef {
  const SalePersonRef({required this.id, required this.firstName, this.lastName, this.phone});

  final String id;
  final String firstName;
  final String? lastName;
  final String? phone;

  String get fullName => [firstName, lastName].where((e) => e != null && e.isNotEmpty).join(' ');

  /// The store's shared "Mehmon xaridor" customer that a sale without a picked customer is
  /// recorded to (`POST /customers/walk-in`). Same sentinel as the web's `isWalkInCustomer`.
  bool get isWalkIn => firstName == 'Mehmon' && lastName == 'xaridor' && phone == walkInCustomerPhone;
}

/// The walk-in customer's sentinel phone (backend `customer.service.ts` WALK_IN).
const walkInCustomerPhone = '000000000';

class SaleItem {
  const SaleItem({
    required this.id,
    required this.productName,
    this.productSku,
    this.productUnit,
    required this.quantity,
    required this.unitPrice,
    required this.discount,
    required this.total,
    required this.returnedQuantity,
    this.productId,
  });

  final String id;
  final String productName;
  final String? productSku;
  final String? productUnit;
  final double quantity;
  final double unitPrice;
  final double discount;
  final double total;
  final double returnedQuantity;
  final String? productId;

  double get remainingReturnable => quantity - returnedQuantity;
}

class SalePayment {
  const SalePayment({
    required this.id,
    required this.amount,
    required this.method,
    required this.status,
    required this.paidAt,
  });

  final String id;
  final double amount;
  final PaymentMethod method;
  final String status;
  final DateTime paidAt;
}

/// The B2C debt opened when a `Sale.type == DEBT` (owner → customer).
class SaleDebtRef {
  const SaleDebtRef({
    required this.id,
    required this.originalAmount,
    required this.paidAmount,
    required this.balance,
    required this.currency,
    required this.status,
    this.dueDate,
  });

  final String id;
  final double originalAmount;
  final double paidAmount;
  final double balance;
  final Currency currency;
  final DebtStatus status;
  final DateTime? dueDate;
}

class Sale {
  const Sale({
    required this.id,
    required this.saleNumber,
    required this.type,
    required this.status,
    required this.currency,
    required this.subtotal,
    required this.discount,
    required this.total,
    this.notes,
    this.customer,
    this.createdBy,
    this.items = const [],
    this.payments = const [],
    this.debt,
    this.isManualRevenue = false,
    required this.createdAt,
  });

  final String id;
  final String saleNumber;
  final SaleType type;
  final SaleStatus status;
  final Currency currency;
  final double subtotal;
  final double discount;
  final double total;
  final String? notes;
  final SalePersonRef? customer;
  final SalePersonRef? createdBy;
  final List<SaleItem> items;
  final List<SalePayment> payments;
  final SaleDebtRef? debt;

  /// A manual revenue ("Qo'lda kiritilgan daromad"): money from goods that
  /// were never entered in the app — a PAID sale with one product-less line.
  final bool isManualRevenue;
  final DateTime createdAt;

  /// A manual revenue moved no stock, so it's cancelled instead of returned.
  bool get canReturn => !isManualRevenue && (status == SaleStatus.completed || status == SaleStatus.partiallyReturned);

  /// Only a manual revenue can be cancelled (`PATCH /sales/:id/cancel`).
  bool get canCancel => isManualRevenue && status == SaleStatus.completed;
}
