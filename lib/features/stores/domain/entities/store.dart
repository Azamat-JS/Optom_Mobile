import 'package:bsmart/core/entities/geo_point.dart';

/// One of the owner's physical stores/branches (`Store` model) — owner-only
/// (SELLER/RETAILER); `_ADMIN`/`WAITER`/`COURIER` staff never manage this
/// roster, only work within whichever store they're locked to.
class Store {
  const Store({
    required this.id,
    required this.name,
    this.address,
    this.location,
    required this.isActive,
    required this.isDefault,
    this.requireHandoverCode = false,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String? address;

  /// Pickup point for courier deliveries (null until set on the map).
  final GeoPoint? location;
  final bool isActive;
  final bool isDefault;

  /// Couriers must enter the customer's 4-digit code to complete a delivery (Phase 7 N2).
  final bool requireHandoverCode;
  final DateTime createdAt;
}
