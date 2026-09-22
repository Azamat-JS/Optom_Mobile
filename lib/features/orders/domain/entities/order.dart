import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/order_status.dart';
import 'package:bsmart/features/orders/domain/entities/order_item.dart';
import 'package:bsmart/features/orders/domain/entities/order_person_ref.dart';
import 'package:bsmart/features/orders/domain/entities/order_status_history_entry.dart';

/// One `Order` row — B2B (wholesaler↔retailer) sourcing in Milestone 3's
/// scope. `items`/`statusHistory` are only populated on the detail response
/// (`GET /orders/:id`); the list response (`GET /orders`) only carries
/// [itemCount] via a `_count` — see `orders_remote_data_source.dart`.
class Order {
  const Order({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.currency,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.paid,
    required this.balance,
    this.notes,
    this.deliveryAddress,
    this.rejectionReason,
    this.approvedAt,
    this.rejectedAt,
    this.deliveredAt,
    this.seller,
    this.buyer,
    this.createdBy,
    this.items = const [],
    this.statusHistory = const [],
    this.itemCount = 0,
    required this.createdAt,
  });

  final String id;
  final String orderNumber;
  final OrderStatus status;
  final Currency currency;
  final double subtotal;
  final double discount;
  final double total;
  final double paid;
  final double balance;
  final String? notes;
  final String? deliveryAddress;
  final String? rejectionReason;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;
  final DateTime? deliveredAt;
  final OrderPersonRef? seller;
  final OrderPersonRef? buyer;
  final OrderPersonRef? createdBy;
  final List<OrderItem> items;
  final List<OrderStatusHistoryEntry> statusHistory;
  final int itemCount;
  final DateTime createdAt;

  /// Client-side UX guard only — the server is the real enforcement point
  /// (`VALID_TRANSITIONS` in `order.service.ts`). Prevents e.g. showing an
  /// "Approve" button on an already-approved order.
  bool get canApproveOrReject => status == OrderStatus.newOrder;
  bool get canMarkDelivered => status == OrderStatus.approved;
}
