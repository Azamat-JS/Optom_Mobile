import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/payment_method.dart';
import 'package:bsmart/core/enums/sale_enums.dart';

/// A minimal debtor/creditor/customer reference embedded on a debt —
/// deliberately not the `customers` feature's own `Customer` entity (same
/// precedent as `orders`'/`sales`' own person-ref types, see `CLAUDE.md`).
class DebtPersonRef {
  const DebtPersonRef({required this.id, required this.firstName, this.lastName, this.phone});

  final String id;
  final String firstName;
  final String? lastName;
  final String? phone;

  String get fullName => [firstName, lastName].where((e) => e != null && e.isNotEmpty).join(' ');
}

class PaymentEntry {
  const PaymentEntry({
    required this.id,
    required this.amount,
    required this.method,
    required this.paidAt,
    this.notes,
  });

  final String id;
  final double amount;
  final PaymentMethod method;
  final DateTime paidAt;
  final String? notes;
}

/// A B2B debt (`Debt` model) — wholesaler↔retailer, or a manually-recorded
/// retailer→customer / self-owed entry. See `CLAUDE.md`'s "Customers / POS"
/// and Optom Savdo's own `CLAUDE.md` "Database Decisions" for the full
/// `Debt` vs `SaleDebt` distinction.
class Debt {
  const Debt({
    required this.id,
    required this.originalAmount,
    required this.paidAmount,
    required this.balance,
    required this.currency,
    required this.status,
    this.dueDate,
    this.notes,
    this.debtor,
    this.creditor,
    this.payments = const [],
    required this.createdAt,
  });

  final String id;
  final double originalAmount;
  final double paidAmount;
  final double balance;
  final Currency currency;
  final DebtStatus status;
  final DateTime? dueDate;
  final String? notes;
  final DebtPersonRef? debtor;
  final DebtPersonRef? creditor;
  final List<PaymentEntry> payments;
  final DateTime createdAt;

  bool get isSettled => status == DebtStatus.settled || status == DebtStatus.writtenOff;
}

/// A B2C sale debt (`SaleDebt` model) — always linked to a `Sale`
/// (`type: DEBT`), owner→customer.
class SaleDebt {
  const SaleDebt({
    required this.id,
    required this.originalAmount,
    required this.paidAmount,
    required this.balance,
    required this.currency,
    required this.status,
    this.dueDate,
    this.notes,
    this.customer,
    this.owner,
    this.payments = const [],
    required this.createdAt,
  });

  final String id;
  final double originalAmount;
  final double paidAmount;
  final double balance;
  final Currency currency;
  final DebtStatus status;
  final DateTime? dueDate;
  final String? notes;
  final DebtPersonRef? customer;
  /// The retailer/wholesaler this debt is owed to — always present on the
  /// backend response (`sale-debt.service.ts`'s `saleDebtIncludes.owner`)
  /// but only actually useful once a `CUSTOMER` views their own debts here
  /// (Phase 2): the retailer's own B2C tab already knows it's the owner,
  /// since every row on that screen is theirs.
  final DebtPersonRef? owner;
  final List<PaymentEntry> payments;
  final DateTime createdAt;

  bool get isSettled => status == DebtStatus.settled || status == DebtStatus.writtenOff;
}
