import 'package:bsmart/core/enums/restaurant_order_enums.dart';
import 'package:bsmart/core/utils/decimal_parser.dart';
import 'package:bsmart/features/restaurant_orders/domain/entities/restaurant_order.dart';
import 'package:bsmart/features/restaurant_orders/domain/entities/restaurant_order_item.dart';
import 'package:bsmart/features/restaurant_orders/domain/entities/restaurant_order_person_ref.dart';
import 'package:bsmart/features/restaurant_orders/domain/entities/restaurant_table_ref.dart';

RestaurantOrderPersonRef? _personRefFromJson(Map<String, dynamic>? json) {
  if (json == null) return null;
  return RestaurantOrderPersonRef(
    id: json['id'] as String,
    firstName: json['firstName'] as String,
    lastName: json['lastName'] as String,
  );
}

RestaurantOrderItem _itemFromJson(Map<String, dynamic> json) => RestaurantOrderItem(
      id: json['id'] as String,
      productId: json['productId'] as String?,
      productName: json['productName'] as String,
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: parseDecimal(json['unitPrice']),
      notes: json['notes'] as String?,
    );

RestaurantOrder restaurantOrderFromJson(Map<String, dynamic> json) {
  final table = json['table'] as Map<String, dynamic>?;
  final itemsJson = json['items'] as List<dynamic>? ?? const [];
  return RestaurantOrder(
    id: json['id'] as String,
    orderNumber: json['orderNumber'] as String,
    type: RestaurantOrderType.fromWire(json['type'] as String),
    status: RestaurantOrderStatus.fromWire(json['status'] as String),
    table: table == null
        ? null
        : RestaurantTableRef(
            id: table['id'] as String,
            name: table['name'] as String,
            percent: parseDecimal(table['percent']),
          ),
    tableNumber: json['tableNumber'] as String?,
    customerName: json['customerName'] as String?,
    customerPhone: json['customerPhone'] as String?,
    deliveryAddress: json['deliveryAddress'] as String?,
    notes: json['notes'] as String?,
    subtotal: parseDecimal(json['subtotal']),
    discount: parseDecimal(json['discount']),
    total: parseDecimal(json['total']),
    serviceChargePercent: parseDecimal(json['serviceChargePercent']),
    serviceChargeAmount: parseDecimal(json['serviceChargeAmount']),
    waiterCommissionPercent: parseDecimal(json['waiterCommissionPercent']),
    waiterCommissionAmount: parseDecimal(json['waiterCommissionAmount']),
    grandTotal: parseDecimal(json['grandTotal']),
    createdBy: _personRefFromJson(json['createdBy'] as Map<String, dynamic>?),
    waiter: _personRefFromJson(json['waiter'] as Map<String, dynamic>?),
    courier: _personRefFromJson(json['courier'] as Map<String, dynamic>?),
    courierAcceptedAt: json['courierAcceptedAt'] != null ? DateTime.parse(json['courierAcceptedAt'] as String) : null,
    items: itemsJson.map((e) => _itemFromJson(e as Map<String, dynamic>)).toList(),
    servedAt: json['servedAt'] != null ? DateTime.parse(json['servedAt'] as String) : null,
    deliveredAt: json['deliveredAt'] != null ? DateTime.parse(json['deliveredAt'] as String) : null,
    cancelledAt: json['cancelledAt'] != null ? DateTime.parse(json['cancelledAt'] as String) : null,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
