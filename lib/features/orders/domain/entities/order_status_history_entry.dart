import 'package:bsmart/core/enums/order_status.dart';
import 'package:bsmart/features/orders/domain/entities/order_person_ref.dart';

class OrderStatusHistoryEntry {
  const OrderStatusHistoryEntry({
    this.fromStatus,
    required this.toStatus,
    this.comment,
    required this.createdAt,
    this.actor,
  });

  final OrderStatus? fromStatus;
  final OrderStatus toStatus;
  final String? comment;
  final DateTime createdAt;
  final OrderPersonRef? actor;
}
