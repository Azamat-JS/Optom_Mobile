import 'package:bsmart/features/deliveries/domain/entities/delivery.dart';

// Coordinates/ETA in the delivery view are already plain JSON numbers (the backend's
// toDeliveryView() converts every Decimal) — no parseDecimal needed here.
LatLngPoint? _point(Object? json) {
  if (json is! Map<String, dynamic>) return null;
  return LatLngPoint((json['lat'] as num).toDouble(), (json['lng'] as num).toDouble());
}

DateTime? _date(Object? v) => v is String ? DateTime.parse(v).toLocal() : null;

Delivery deliveryFromJson(Map<String, dynamic> json) {
  final courier = json['courier'] as Map<String, dynamic>?;
  final eta = json['eta'] as Map<String, dynamic>?;
  final store = json['store'] as Map<String, dynamic>?;
  return Delivery(
    id: json['id'] as String,
    status: DeliveryStatus.fromWire(json['status'] as String),
    source: json['source'] == 'RESTAURANT_ORDER' ? DeliverySource.restaurantOrder : DeliverySource.order,
    orderNumber: json['orderNumber'] as String?,
    pickup: _point(json['pickup']),
    dropoff: _point(json['dropoff']),
    dropoffAddress: json['dropoffAddress'] as String?,
    storeName: store?['name'] as String?,
    courierId: json['courierId'] as String?,
    courier: courier == null
        ? null
        : DeliveryCourier(
            id: courier['id'] as String?,
            firstName: courier['firstName'] as String? ?? '',
            lastName: courier['lastName'] as String? ?? '',
            phone: courier['phone'] as String?,
          ),
    customerName: json['customerName'] as String?,
    customerPhone: json['customerPhone'] as String?,
    eta: eta == null
        ? null
        : DeliveryEta(seconds: (eta['seconds'] as num).toInt(), distanceMeters: (eta['distanceMeters'] as num?)?.toInt()),
    createdAt: _date(json['createdAt']) ?? DateTime.now(),
    acceptedAt: _date(json['acceptedAt']),
    pickedUpAt: _date(json['pickedUpAt']),
    arrivedAt: _date(json['arrivedAt']),
    deliveredAt: _date(json['deliveredAt']),
  );
}
