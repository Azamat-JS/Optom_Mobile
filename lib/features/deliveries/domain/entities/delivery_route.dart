import 'package:bsmart/features/deliveries/domain/entities/delivery.dart';

enum RouteStopKind { pickup, dropoff }

class RouteStop {
  const RouteStop({required this.kind, required this.point, required this.etaSeconds, required this.distanceMeters});

  final RouteStopKind kind;
  final LatLngPoint point;

  /// Cumulative from the route origin, as of [DeliveryRoute.computedAt].
  final int etaSeconds;
  final int distanceMeters;
}

/// Road route + per-stop ETA from `GET /deliveries/:id/route` or a
/// `delivery:route` socket event (Optom_Savdo CLAUDE.md "Routing & ETA — T6").
class DeliveryRoute {
  const DeliveryRoute({
    required this.deliveryId,
    required this.toPickup,
    required this.fromCourier,
    required this.origin,
    required this.stops,
    required this.distanceMeters,
    required this.encodedPolyline,
    required this.computedAt,
  });

  final String deliveryId;

  /// TO_PICKUP phase (courier → store → customer) vs TO_DROPOFF.
  final bool toPickup;

  /// True when the origin is the courier's live position — only then are
  /// the ETAs real. Otherwise the route starts at the store.
  final bool fromCourier;

  /// Where the route was computed from — the courier's position at
  /// [computedAt] when [fromCourier] (a good first marker position for viewers).
  final LatLngPoint origin;
  final List<RouteStop> stops;
  final int distanceMeters;
  final String encodedPolyline;
  final DateTime computedAt;

  RouteStop? stop(RouteStopKind kind) => stops.where((s) => s.kind == kind).firstOrNull;

  /// ETA to [kind] counting down from [computedAt]; never below one minute.
  Duration? remaining(RouteStopKind kind, DateTime now) {
    final s = stop(kind);
    if (s == null || !fromCourier) return null;
    final left = Duration(seconds: s.etaSeconds) - now.difference(computedAt);
    return left < const Duration(minutes: 1) ? const Duration(minutes: 1) : left;
  }
}
