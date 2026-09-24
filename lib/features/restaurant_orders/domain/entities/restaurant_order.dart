import 'package:bsmart/core/enums/restaurant_order_enums.dart';
import 'package:bsmart/features/restaurant_orders/domain/entities/restaurant_order_item.dart';
import 'package:bsmart/features/restaurant_orders/domain/entities/restaurant_order_person_ref.dart';
import 'package:bsmart/features/restaurant_orders/domain/entities/restaurant_table_ref.dart';

/// A dine-in/delivery order taken by a restaurant — deliberately separate
/// from the B2B/B2C `Order`/`Sale` models (`features/orders`/`features/sales`)
/// elsewhere in this app; this is the restaurant itself taking an order from
/// a table or a delivery customer, not a wholesale purchase or a POS
/// checkout. Not linked to stock/`Payment`/`Debt` in any way — staff record
/// the actual payment manually elsewhere (matches the reference backend's own
/// "manual payment recording only" scope, see its CLAUDE.md).
///
/// [serviceChargeAmount]/[waiterCommissionAmount]/[grandTotal] are all
/// server-computed on every read (never persisted) — `total * percent / 100`
/// each, summed independently into `grandTotal`, exactly mirroring
/// `RestaurantOrderService.withGrandTotal`.
class RestaurantOrder {
  const RestaurantOrder({
    required this.id,
    required this.orderNumber,
    required this.type,
    required this.status,
    this.table,
    this.tableNumber,
    this.customerName,
    this.customerPhone,
    this.deliveryAddress,
    this.notes,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.serviceChargePercent,
    required this.serviceChargeAmount,
    required this.waiterCommissionPercent,
    required this.waiterCommissionAmount,
    required this.grandTotal,
    this.createdBy,
    this.waiter,
    this.courier,
    this.courierAcceptedAt,
    this.items = const [],
    this.servedAt,
    this.deliveredAt,
    this.cancelledAt,
    required this.createdAt,
  });

  final String id;
  final String orderNumber;
  final RestaurantOrderType type;
  final RestaurantOrderStatus status;
  final RestaurantTableRef? table;
  final String? tableNumber;
  final String? customerName;
  final String? customerPhone;
  final String? deliveryAddress;
  final String? notes;
  final double subtotal;
  final double discount;
  final double total;
  final double serviceChargePercent;
  final double serviceChargeAmount;
  final double waiterCommissionPercent;
  final double waiterCommissionAmount;
  final double grandTotal;
  final RestaurantOrderPersonRef? createdBy;
  final RestaurantOrderPersonRef? waiter;
  final RestaurantOrderPersonRef? courier;
  final DateTime? courierAcceptedAt;
  final List<RestaurantOrderItem> items;
  final DateTime? servedAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final DateTime createdAt;

  /// Assigned (courier set) but not yet accepted, and still actionable —
  /// mirrors the web app's `isCourierAssignmentPending` exactly, including
  /// gating on non-terminal status so an already-`DELIVERED` order (an owner
  /// can always mark one delivered directly, bypassing the courier entirely)
  /// never shows a stale "pending" hint.
  bool get isCourierAssignmentPending => courier != null && courierAcceptedAt == null && !status.isTerminal;
}
