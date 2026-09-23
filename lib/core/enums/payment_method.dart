/// Mirrors the backend's Prisma `PaymentMethod` enum. `debt` is a member of
/// the enum itself (used elsewhere, e.g. reporting breakdowns) but is never
/// a valid `CreateSaleDto.paymentMethod` value — that field only accepts the
/// "immediate settlement" subset (`sale.service.ts`'s `IMMEDIATE_PAYMENT_METHODS`),
/// which is what [immediateMethods] below exposes for the POS checkout UI.
enum PaymentMethod {
  cash,
  card,
  bankTransfer,
  click,
  payme,
  debt;

  static PaymentMethod fromWire(String value) => switch (value) {
        'CASH' => PaymentMethod.cash,
        'CARD' => PaymentMethod.card,
        'BANK_TRANSFER' => PaymentMethod.bankTransfer,
        'CLICK' => PaymentMethod.click,
        'PAYME' => PaymentMethod.payme,
        'DEBT' => PaymentMethod.debt,
        _ => throw ArgumentError('Unknown PaymentMethod from backend: $value'),
      };

  String toWire() => switch (this) {
        PaymentMethod.cash => 'CASH',
        PaymentMethod.card => 'CARD',
        PaymentMethod.bankTransfer => 'BANK_TRANSFER',
        PaymentMethod.click => 'CLICK',
        PaymentMethod.payme => 'PAYME',
        PaymentMethod.debt => 'DEBT',
      };

  String get label => switch (this) {
        PaymentMethod.cash => 'Naqd',
        PaymentMethod.card => 'Karta',
        PaymentMethod.bankTransfer => "Bank o'tkazmasi",
        PaymentMethod.click => 'Click',
        PaymentMethod.payme => 'Payme',
        PaymentMethod.debt => 'Qarzga',
      };

  static const immediateMethods = [
    PaymentMethod.cash,
    PaymentMethod.card,
    PaymentMethod.bankTransfer,
    PaymentMethod.click,
    PaymentMethod.payme,
  ];
}
