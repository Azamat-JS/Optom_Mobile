/// Mirrors the backend's Prisma `SaleType` enum.
enum SaleType {
  paid,
  debt;

  static SaleType fromWire(String value) => switch (value) {
        'PAID' => SaleType.paid,
        'DEBT' => SaleType.debt,
        _ => throw ArgumentError('Unknown SaleType from backend: $value'),
      };

  String toWire() => switch (this) {
        SaleType.paid => 'PAID',
        SaleType.debt => 'DEBT',
      };

  String get label => switch (this) {
        SaleType.paid => "To'langan",
        SaleType.debt => 'Qarzga',
      };
}

/// Mirrors the backend's Prisma `SaleStatus` enum.
enum SaleStatus {
  completed,
  cancelled,
  partiallyReturned,
  returned;

  static SaleStatus fromWire(String value) => switch (value) {
        'COMPLETED' => SaleStatus.completed,
        'CANCELLED' => SaleStatus.cancelled,
        'PARTIALLY_RETURNED' => SaleStatus.partiallyReturned,
        'RETURNED' => SaleStatus.returned,
        _ => throw ArgumentError('Unknown SaleStatus from backend: $value'),
      };

  String get label => switch (this) {
        SaleStatus.completed => 'Yakunlangan',
        SaleStatus.cancelled => 'Bekor qilingan',
        SaleStatus.partiallyReturned => 'Qisman qaytarilgan',
        SaleStatus.returned => 'Qaytarilgan',
      };
}

/// Mirrors the backend's Prisma `DebtStatus` enum (shared by `Debt` and
/// `SaleDebt`).
enum DebtStatus {
  active,
  partial,
  settled,
  overdue,
  writtenOff;

  static DebtStatus fromWire(String value) => switch (value) {
        'ACTIVE' => DebtStatus.active,
        'PARTIAL' => DebtStatus.partial,
        'SETTLED' => DebtStatus.settled,
        'OVERDUE' => DebtStatus.overdue,
        'WRITTEN_OFF' => DebtStatus.writtenOff,
        _ => throw ArgumentError('Unknown DebtStatus from backend: $value'),
      };

  String get label => switch (this) {
        DebtStatus.active => 'Faol',
        DebtStatus.partial => 'Qisman to\'langan',
        DebtStatus.settled => "To'langan",
        DebtStatus.overdue => 'Muddati o\'tgan',
        DebtStatus.writtenOff => 'Bekor qilingan',
      };
}
