/// Mirrors the backend's Prisma `OrderStatus` enum. Valid transitions
/// (enforced server-side, `order.service.ts`'s `VALID_TRANSITIONS`):
/// `NEW → APPROVED/REJECTED`, `APPROVED → DELIVERED`. `DEBT_RECORDED`/`PAID`
/// exist in the enum for future use but are never reached by the current
/// `updateStatus` transition map — an approved B2B order's debt is tracked
/// via a separate `Debt` record instead, not a further `Order.status` value.
enum OrderStatus {
  newOrder,
  approved,
  rejected,
  delivered,
  debtRecorded,
  paid;

  static OrderStatus fromWire(String value) => switch (value) {
        'NEW' => OrderStatus.newOrder,
        'APPROVED' => OrderStatus.approved,
        'REJECTED' => OrderStatus.rejected,
        'DELIVERED' => OrderStatus.delivered,
        'DEBT_RECORDED' => OrderStatus.debtRecorded,
        'PAID' => OrderStatus.paid,
        _ => throw ArgumentError('Unknown OrderStatus from backend: $value'),
      };

  String toWire() => switch (this) {
        OrderStatus.newOrder => 'NEW',
        OrderStatus.approved => 'APPROVED',
        OrderStatus.rejected => 'REJECTED',
        OrderStatus.delivered => 'DELIVERED',
        OrderStatus.debtRecorded => 'DEBT_RECORDED',
        OrderStatus.paid => 'PAID',
      };

  String get label => switch (this) {
        OrderStatus.newOrder => 'Yangi',
        OrderStatus.approved => 'Tasdiqlangan',
        OrderStatus.rejected => 'Rad etilgan',
        OrderStatus.delivered => 'Yetkazilgan',
        OrderStatus.debtRecorded => 'Qarzga yozilgan',
        OrderStatus.paid => "To'langan",
      };
}

/// `OrderType` describes the transaction from the seller's side (a
/// wholesaler selling is B2B, a retailer selling is B2C) — regardless of
/// what role the buyer has.
enum OrderType {
  b2b,
  b2c;

  static OrderType fromWire(String value) => switch (value) {
        'B2B' => OrderType.b2b,
        'B2C' => OrderType.b2c,
        _ => throw ArgumentError('Unknown OrderType from backend: $value'),
      };
}
