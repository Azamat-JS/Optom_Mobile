import 'package:bsmart/core/l10n/app_l10n.dart';

/// Mirrors the backend's `RestaurantOrderType` enum.
enum RestaurantOrderType {
  dineIn,
  delivery;

  static RestaurantOrderType fromWire(String value) => switch (value) {
        'DINE_IN' => RestaurantOrderType.dineIn,
        'DELIVERY' => RestaurantOrderType.delivery,
        _ => throw ArgumentError('Unknown RestaurantOrderType from backend: $value'),
      };

  String toWire() => switch (this) {
        RestaurantOrderType.dineIn => 'DINE_IN',
        RestaurantOrderType.delivery => 'DELIVERY',
      };

  String get label => appL10n.enumRestaurantOrderType(name);
}

/// Mirrors the backend's `RestaurantOrderStatus` enum. Flow:
/// `NEW → PREPARING → READY → SERVED` (dine-in) or `→ DELIVERED` (delivery);
/// `CANCELLED` reachable from any non-terminal status. The real transition
/// enforcement is server-side (`RestaurantOrderService.updateStatus`) — this
/// client only decides which action buttons to show, same UX-polish-only
/// relationship as `Order.canApproveOrReject` elsewhere in this app.
enum RestaurantOrderStatus {
  newOrder,
  preparing,
  ready,
  served,
  delivered,
  cancelled;

  static RestaurantOrderStatus fromWire(String value) => switch (value) {
        'NEW' => RestaurantOrderStatus.newOrder,
        'PREPARING' => RestaurantOrderStatus.preparing,
        'READY' => RestaurantOrderStatus.ready,
        'SERVED' => RestaurantOrderStatus.served,
        'DELIVERED' => RestaurantOrderStatus.delivered,
        'CANCELLED' => RestaurantOrderStatus.cancelled,
        _ => throw ArgumentError('Unknown RestaurantOrderStatus from backend: $value'),
      };

  String toWire() => switch (this) {
        RestaurantOrderStatus.newOrder => 'NEW',
        RestaurantOrderStatus.preparing => 'PREPARING',
        RestaurantOrderStatus.ready => 'READY',
        RestaurantOrderStatus.served => 'SERVED',
        RestaurantOrderStatus.delivered => 'DELIVERED',
        RestaurantOrderStatus.cancelled => 'CANCELLED',
      };

  String get label => appL10n.enumRestaurantOrderStatus(name);

  bool get isTerminal =>
      this == RestaurantOrderStatus.served ||
      this == RestaurantOrderStatus.delivered ||
      this == RestaurantOrderStatus.cancelled;
}
