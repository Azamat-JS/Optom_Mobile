import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/order_status.dart';
import 'package:bsmart/core/enums/user_role.dart';
import 'package:bsmart/core/utils/decimal_parser.dart';
import 'package:bsmart/features/orders/domain/entities/order.dart';
import 'package:bsmart/features/orders/domain/entities/order_item.dart';
import 'package:bsmart/features/orders/domain/entities/order_person_ref.dart';
import 'package:bsmart/features/orders/domain/entities/order_status_history_entry.dart';

OrderPersonRef? orderPersonRefFromJson(Map<String, dynamic>? json) {
  if (json == null) return null;
  return OrderPersonRef(
    id: json['id'] as String,
    firstName: json['firstName'] as String,
    lastName: json['lastName'] as String,
    phone: json['phone'] as String?,
    role: json['role'] != null ? UserRole.fromWire(json['role'] as String) : null,
  );
}

OrderItem orderItemFromJson(Map<String, dynamic> json) => OrderItem(
      productId: json['productId'] as String?,
      productName: json['productName'] as String,
      productSku: json['productSku'] as String?,
      productUnit: json['productUnit'] as String?,
      quantity: parseDecimal(json['quantity']),
      unitPrice: parseDecimal(json['unitPrice']),
      discount: parseDecimal(json['discount'] ?? 0),
      total: parseDecimal(json['total']),
    );

OrderStatusHistoryEntry orderStatusHistoryEntryFromJson(Map<String, dynamic> json) => OrderStatusHistoryEntry(
      fromStatus: json['fromStatus'] != null ? OrderStatus.fromWire(json['fromStatus'] as String) : null,
      toStatus: OrderStatus.fromWire(json['toStatus'] as String),
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      actor: orderPersonRefFromJson(json['actor'] as Map<String, dynamic>?),
    );

/// Parses both the list (`GET /orders`) and detail (`GET /orders/:id`) shapes
/// — the list response additionally carries `_count.items` in place of a
/// full `items[]`/`statusHistory[]`, both otherwise identical scalar shapes.
Order orderFromJson(Map<String, dynamic> json) {
  final itemsJson = json['items'] as List<dynamic>?;
  final statusHistoryJson = json['statusHistory'] as List<dynamic>?;
  final count = json['_count'] as Map<String, dynamic>?;

  return Order(
    id: json['id'] as String,
    orderNumber: json['orderNumber'] as String,
    status: OrderStatus.fromWire(json['status'] as String),
    currency: Currency.fromWire(json['currency'] as String? ?? 'UZS'),
    subtotal: parseDecimal(json['subtotal']),
    discount: parseDecimal(json['discount'] ?? 0),
    total: parseDecimal(json['total']),
    paid: parseDecimal(json['paid'] ?? 0),
    balance: parseDecimal(json['balance'] ?? 0),
    notes: json['notes'] as String?,
    deliveryAddress: json['deliveryAddress'] as String?,
    rejectionReason: json['rejectionReason'] as String?,
    approvedAt: json['approvedAt'] != null ? DateTime.parse(json['approvedAt'] as String) : null,
    rejectedAt: json['rejectedAt'] != null ? DateTime.parse(json['rejectedAt'] as String) : null,
    deliveredAt: json['deliveredAt'] != null ? DateTime.parse(json['deliveredAt'] as String) : null,
    seller: orderPersonRefFromJson(json['seller'] as Map<String, dynamic>?),
    buyer: orderPersonRefFromJson(json['buyer'] as Map<String, dynamic>?),
    createdBy: orderPersonRefFromJson(json['createdBy'] as Map<String, dynamic>?),
    items: itemsJson?.map((e) => orderItemFromJson(e as Map<String, dynamic>)).toList() ?? const [],
    statusHistory:
        statusHistoryJson?.map((e) => orderStatusHistoryEntryFromJson(e as Map<String, dynamic>)).toList() ??
            const [],
    itemCount: itemsJson?.length ?? (count?['items'] as int? ?? 0),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
