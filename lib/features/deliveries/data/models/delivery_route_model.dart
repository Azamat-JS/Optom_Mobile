import 'package:bsmart/features/deliveries/domain/entities/delivery.dart';
import 'package:bsmart/features/deliveries/domain/entities/delivery_route.dart';

DeliveryRoute deliveryRouteFromJson(Map<String, dynamic> json) => DeliveryRoute(
      deliveryId: json['deliveryId'] as String,
      toPickup: json['phase'] == 'TO_PICKUP',
      fromCourier: json['originSource'] == 'COURIER',
      origin: LatLngPoint(
        ((json['origin'] as Map<String, dynamic>)['lat'] as num).toDouble(),
        ((json['origin'] as Map<String, dynamic>)['lng'] as num).toDouble(),
      ),
      stops: (json['stops'] as List)
          .cast<Map<String, dynamic>>()
          .map(
            (s) => RouteStop(
              kind: s['kind'] == 'PICKUP' ? RouteStopKind.pickup : RouteStopKind.dropoff,
              point: LatLngPoint((s['lat'] as num).toDouble(), (s['lng'] as num).toDouble()),
              etaSeconds: (s['etaSeconds'] as num).toInt(),
              distanceMeters: (s['distanceMeters'] as num).toInt(),
            ),
          )
          .toList(),
      distanceMeters: (json['distanceMeters'] as num).toInt(),
      encodedPolyline: json['encodedPolyline'] as String,
      computedAt: DateTime.fromMillisecondsSinceEpoch((json['computedAt'] as num).toInt()),
    );
