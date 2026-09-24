import 'package:bsmart/core/enums/restaurant_order_enums.dart';
import 'package:bsmart/core/enums/user_role.dart';
import 'package:bsmart/features/restaurant_orders/domain/entities/restaurant_order.dart';

/// Client-side UX-polish mirror of `RestaurantOrderService.updateStatus`'s
/// real transition enforcement (the server re-validates every transition
/// regardless) — decides which status-action buttons to show per role,
/// ported directly from the reference web app's own `status-actions.ts`.
///
/// Flow: `NEW → PREPARING → READY → SERVED` (dine-in) or `→ DELIVERED`
/// (delivery); `CANCELLED` reachable from any non-terminal status.
List<RestaurantOrderStatus> getStatusActions(RestaurantOrder order, UserRole role, String userId) {
  if (order.status.isTerminal) return const [];

  if (role == UserRole.courier) {
    final canDeliver =
        order.type == RestaurantOrderType.delivery && order.courier?.id == userId && order.courierAcceptedAt != null;
    return canDeliver ? const [RestaurantOrderStatus.delivered] : const [];
  }

  final actions = <RestaurantOrderStatus>[];
  switch (order.status) {
    case RestaurantOrderStatus.newOrder:
      actions.add(RestaurantOrderStatus.preparing);
    case RestaurantOrderStatus.preparing:
      actions.add(RestaurantOrderStatus.ready);
    case RestaurantOrderStatus.ready:
      if (order.type == RestaurantOrderType.dineIn) {
        actions.add(RestaurantOrderStatus.served);
      } else if (role == UserRole.retailer || role == UserRole.retailerAdmin) {
        // An owner/admin can always record a delivery manually themselves,
        // bypassing the courier accept flow entirely — unchanged, pre-existing
        // behavior per the reference backend; a WAITER never gets this.
        actions.add(RestaurantOrderStatus.delivered);
      }
    case RestaurantOrderStatus.served:
    case RestaurantOrderStatus.delivered:
    case RestaurantOrderStatus.cancelled:
      break;
  }
  actions.add(RestaurantOrderStatus.cancelled);
  return actions;
}

/// Whether a courier may tap "Qabul qilish" (Accept) on this order — either
/// it's unclaimed (broadcast to every courier) or already assigned to this
/// courier but not yet confirmed.
bool canAcceptOrder(RestaurantOrder order, UserRole role, String userId) {
  if (role != UserRole.courier) return false;
  if (order.status.isTerminal) return false;
  if (order.type != RestaurantOrderType.delivery) return false;
  return order.courier == null || (order.courier!.id == userId && order.courierAcceptedAt == null);
}

/// Only the owner/admin may hand a delivery order to a courier — and only
/// before the currently assigned courier has accepted (locked afterward, so
/// a courier already committed can't be silently swapped out).
bool canAssignCourier(RestaurantOrder order, UserRole role) {
  if (role != UserRole.retailer && role != UserRole.retailerAdmin) return false;
  if (order.type != RestaurantOrderType.delivery) return false;
  if (order.status.isTerminal) return false;
  return order.courierAcceptedAt == null;
}

/// A table/customer can always order more food while the order is still
/// open — owner/admin and waiter only, never courier.
bool canAddItems(RestaurantOrder order, UserRole role) {
  if (order.status.isTerminal) return false;
  return role == UserRole.retailer || role == UserRole.retailerAdmin || role == UserRole.waiter;
}
