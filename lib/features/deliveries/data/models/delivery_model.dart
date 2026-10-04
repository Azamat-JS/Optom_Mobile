import 'package:bsmart/features/deliveries/domain/entities/delivery.dart';

// Coordinates/ETA in the delivery view are already plain JSON numbers (the backend's
// toDeliveryView() converts every Decimal) — no parseDecimal needed here.
LatLngPoint? _point(Object? json) {
  if (json is! Map<String, dynamic>) return null;
  return LatLngPoint((json['lat'] as num).toDouble(), (json['lng'] as num).toDouble());
}

DateTime? _date(Object? v) => v is String ? DateTime.parse(v).toLocal() : null;

DeliveryHandover _handover(Object? json) {
  if (json is! Map<String, dynamic>) return DeliveryHandover.none;
  final code = json['code'] as String?;
  return DeliveryHandover(
    required: json['required'] as bool? ?? false,
    // The customer view has no `pending`: a code being shown means it's pending.
    pending: json['pending'] as bool? ?? code != null,
    attemptsLeft: (json['attemptsLeft'] as num?)?.toInt() ?? 5,
    locked: json['locked'] as bool? ?? false,
    waived: json['waivedAt'] != null,
    code: code,
  );
}

DeliveryOutcomeLocation? _outcome(Object? json) {
  final point = _point(json);
  if (point == null) return null;
  final map = json! as Map<String, dynamic>;
  return DeliveryOutcomeLocation(
    point: point,
    at: _date(map['at']),
    distanceToDropoffMeters: (map['distanceToDropoffMeters'] as num?)?.toInt(),
  );
}

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
    failedAt: _date(json['failedAt']),
    failReason: DeliveryFailReason.fromWire(json['failReason']),
    failNote: json['failNote'] as String?,
    cancelReason: json['cancelReason'] as String?,
    handover: _handover(json['handover']),
    outcomeLocation: _outcome(json['outcomeLocation']),
  );
}
