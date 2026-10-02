import 'package:bsmart/core/entities/geo_point.dart';
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
    this.deliveryPoint,
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

  /// Optional drop-off pin for courier delivery (backend `deliveryLat/deliveryLng`).
  final GeoPoint? deliveryPoint;
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
        if (deliveryPoint != null) 'deliveryLat': deliveryPoint!.lat,
        if (deliveryPoint != null) 'deliveryLng': deliveryPoint!.lng,
        if (notes != null && notes!.isNotEmpty) 'notes': notes,
        'items': items.map((i) => i.toRequestBody()).toList(),
        if (discount != null) 'discount': discount,
        if (courierId != null) 'courierId': courierId,
      };
}
