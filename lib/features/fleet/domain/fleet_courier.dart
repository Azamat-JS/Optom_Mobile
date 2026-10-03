import 'package:bsmart/core/entities/geo_point.dart';

/// One courier on the owner/admin fleet map (`GET /tracking/fleet` + live
/// `location`/`presence` events on the fleet room).
class FleetCourier {
  const FleetCourier({
    required this.id,
    required this.name,
    this.phone,
    this.location,
    this.heading,
    this.lastPointAt,
    required this.serverOnline,
    this.deliveryIds = const [],
  });

  final String id;
  final String name;
  final String? phone;
  final GeoPoint? location;
  final double? heading;
  final DateTime? lastPointAt;

  /// The server's view at fetch time (`online` vs `stale`).
  final bool serverOnline;

  /// Accepted, unfinished deliveries (from the tracking context tag).
  final List<String> deliveryIds;

  static const staleAfter = Duration(seconds: 60);

  bool isStale(DateTime now) => lastPointAt == null ? !serverOnline : now.difference(lastPointAt!) > staleAfter;

  bool get busy => deliveryIds.isNotEmpty;

  FleetCourier moved(GeoPoint to, {double? heading, required DateTime at}) => FleetCourier(
    id: id,
    name: name,
    phone: phone,
    location: to,
    heading: heading ?? this.heading,
    lastPointAt: at,
    serverOnline: true,
    deliveryIds: deliveryIds,
  );
}
