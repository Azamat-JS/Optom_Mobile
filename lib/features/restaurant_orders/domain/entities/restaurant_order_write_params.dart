import 'package:bsmart/core/enums/restaurant_order_enums.dart';
import 'package:bsmart/features/restaurant_orders/domain/entities/restaurant_order_item_input.dart';

/// Mirrors `CreateRestaurantOrderDto`.
class CreateRestaurantOrderParams {
  const CreateRestaurantOrderParams({
    required this.type,
    this.tableId,
    this.customerName,
    this.customerPhone,
    this.deliveryAddress,
    this.notes,
    required this.items,
    this.discount,
    this.courierId,
  });

  final RestaurantOrderType type;
  final String? tableId;
  final String? customerName;
  final String? customerPhone;
  final String? deliveryAddress;
  final String? notes;
  final List<RestaurantOrderItemInput> items;
  final double? discount;
  final String? courierId;

  Map<String, dynamic> toRequestBody() => {
        'type': type.toWire(),
        if (tableId != null) 'tableId': tableId,
        if (customerName != null && customerName!.isNotEmpty) 'customerName': customerName,
        if (customerPhone != null && customerPhone!.isNotEmpty) 'customerPhone': customerPhone,
        if (deliveryAddress != null && deliveryAddress!.isNotEmpty) 'deliveryAddress': deliveryAddress,
        if (notes != null && notes!.isNotEmpty) 'notes': notes,
        'items': items.map((i) => i.toRequestBody()).toList(),
        if (discount != null) 'discount': discount,
        if (courierId != null) 'courierId': courierId,
      };
}
