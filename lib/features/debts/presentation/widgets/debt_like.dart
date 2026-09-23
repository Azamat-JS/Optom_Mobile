import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/sale_enums.dart';
import 'package:bsmart/features/debts/domain/entities/debt.dart';

enum DebtKind { b2b, saleDebt }

/// A presentation-only adapter unifying `Debt` and `SaleDebt` for the shared
/// grouping/list/detail UI — the two domain entities intentionally stay
/// separate (different backend models, different write paths), this is
/// purely a display-layer convenience so one screen can render both.
class DebtLike {
  const DebtLike({
    required this.id,
    required this.kind,
    required this.originalAmount,
    required this.paidAmount,
    required this.balance,
    required this.currency,
    required this.status,
    this.dueDate,
    this.notes,
    required this.payments,
    required this.createdAt,
  });

  factory DebtLike.fromDebt(Debt debt) => DebtLike(
        id: debt.id,
        kind: DebtKind.b2b,
        originalAmount: debt.originalAmount,
        paidAmount: debt.paidAmount,
        balance: debt.balance,
        currency: debt.currency,
        status: debt.status,
        dueDate: debt.dueDate,
        notes: debt.notes,
        payments: debt.payments,
        createdAt: debt.createdAt,
      );

  factory DebtLike.fromSaleDebt(SaleDebt saleDebt) => DebtLike(
        id: saleDebt.id,
        kind: DebtKind.saleDebt,
        originalAmount: saleDebt.originalAmount,
        paidAmount: saleDebt.paidAmount,
        balance: saleDebt.balance,
        currency: saleDebt.currency,
        status: saleDebt.status,
        dueDate: saleDebt.dueDate,
        notes: saleDebt.notes,
        payments: saleDebt.payments,
        createdAt: saleDebt.createdAt,
      );

  final String id;
  final DebtKind kind;
  final double originalAmount;
  final double paidAmount;
  final double balance;
  final Currency currency;
  final DebtStatus status;
  final DateTime? dueDate;
  final String? notes;
  final List<PaymentEntry> payments;
  final DateTime createdAt;

  bool get isSettled => status == DebtStatus.settled || status == DebtStatus.writtenOff;
}

/// A person (or notes-identified debtor)'s aggregated debts in one currency —
/// the FIFO pay-down's natural unit, matching `PayDownDto`'s own
/// debtorId/debtorNotes/customerId + currency scoping.
class DebtGroup {
  const DebtGroup({
    required this.kind,
    this.personId,
    this.personNotesKey,
    required this.personName,
    this.personPhone,
    required this.currency,
    required this.items,
    this.viewerIsDebtor = false,
  });

  final DebtKind kind;

  /// Set when the debtor/customer is a real linked person. Null for a
  /// notes-only B2B debtor (see `Debt.notes`'s " — " convention).
  final String? personId;
  final String? personNotesKey;
  final String personName;
  final String? personPhone;
  final Currency currency;
  final List<DebtLike> items;

  /// True when the signed-in tenant is the *debtor* on these B2B rows (the
  /// "Mening qarzim" view) rather than the creditor. Only the creditor may
  /// record a payment or close a debt (`debt.service.ts`/`payment.service.ts`
  /// both scope those writes to `creditorId: tenant.tenantId`) — the detail
  /// screen hides those actions in this case rather than letting the user
  /// tap a button that can only ever 404. Always false for a B2C `SaleDebt`
  /// group, since the tenant viewing one is always its `ownerId`.
  final bool viewerIsDebtor;

  double get totalBalance => items.fold(0, (sum, item) => sum + item.balance);
  int get activeCount => items.where((i) => !i.isSettled).length;
}

/// Groups by the *other* party relative to [currentUserId] — a B2B `Debt` is
/// symmetric (either side, RETAILER especially, can be the debtor on some
/// rows and the creditor on others in the same combined list), so grouping
/// by a fixed side would sometimes display the viewer's own name instead of
/// who they actually owe/are owed by.
List<DebtGroup> groupDebts(List<Debt> debts, {required String currentUserId}) {
  final byKey = <String, List<Debt>>{};
  for (final debt in debts) {
    final viewerIsDebtor = debt.debtor?.id == currentUserId;
    final otherParty = viewerIsDebtor ? debt.creditor : debt.debtor;
    final key = '${otherParty?.id ?? debt.notes}|${debt.currency.toWire()}|$viewerIsDebtor';
    byKey.putIfAbsent(key, () => []).add(debt);
  }
  return byKey.values.map((group) {
    final first = group.first;
    final viewerIsDebtor = first.debtor?.id == currentUserId;
    final otherParty = viewerIsDebtor ? first.creditor : first.debtor;
    return DebtGroup(
      kind: DebtKind.b2b,
      personId: otherParty?.id,
      personNotesKey: otherParty == null ? first.notes : null,
      personName: otherParty?.fullName ?? (first.notes?.split(' — ').first ?? 'Noma\'lum'),
      personPhone: otherParty?.phone ?? (first.notes?.split(' — ').elementAtOrNull(1)),
      currency: first.currency,
      items: group.map(DebtLike.fromDebt).toList()..sort((a, b) => a.createdAt.compareTo(b.createdAt)),
      viewerIsDebtor: viewerIsDebtor,
    );
  }).toList()
    ..sort((a, b) => b.totalBalance.compareTo(a.totalBalance));
}

List<DebtGroup> groupSaleDebts(List<SaleDebt> saleDebts) {
  final byKey = <String, List<SaleDebt>>{};
  for (final debt in saleDebts) {
    final key = '${debt.customer?.id}|${debt.currency.toWire()}';
    byKey.putIfAbsent(key, () => []).add(debt);
  }
  return byKey.values.map((group) {
    final first = group.first;
    return DebtGroup(
      kind: DebtKind.saleDebt,
      personId: first.customer?.id,
      personName: first.customer?.fullName ?? 'Noma\'lum',
      personPhone: first.customer?.phone,
      currency: first.currency,
      items: group.map(DebtLike.fromSaleDebt).toList()..sort((a, b) => a.createdAt.compareTo(b.createdAt)),
    );
  }).toList()
    ..sort((a, b) => b.totalBalance.compareTo(a.totalBalance));
}

extension _ElementAtOrNull<T> on List<T> {
  T? elementAtOrNull(int index) => index >= 0 && index < length ? this[index] : null;
}
