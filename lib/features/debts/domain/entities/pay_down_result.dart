/// Mirrors `PaymentService.payDown()`'s response shape — the payments it
/// created across however many debts the FIFO allocation touched, plus the
/// person's aggregate balance after applying [totalApplied].
class PayDownResult {
  const PayDownResult({required this.paymentCount, required this.totalApplied, required this.remainingBalance});

  final int paymentCount;
  final double totalApplied;
  final double remainingBalance;
}
