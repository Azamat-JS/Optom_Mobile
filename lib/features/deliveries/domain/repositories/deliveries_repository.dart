import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/deliveries/domain/entities/assignable_courier.dart';
import 'package:bsmart/features/deliveries/domain/entities/delivery.dart';
import 'package:bsmart/features/deliveries/domain/entities/delivery_tracking_link.dart';
import 'package:bsmart/features/deliveries/domain/entities/delivery_route.dart';

/// Courier step endpoints: `PATCH /deliveries/:id/{accept|pickup|arrive|complete}`.
enum DeliveryAction {
  accept('accept'),
  pickup('pickup'),
  arrive('arrive'),
  complete('complete');

  const DeliveryAction(this.path);

  final String path;
}

abstract interface class DeliveriesRepository {
  Future<Result<List<Delivery>>> list({bool openOnly = false});

  Future<Result<Delivery>> get(String id);

  /// The delivery of an order, or null when it has none (yet).
  Future<Result<Delivery?>> byOrder(String orderId);

  Future<Result<Delivery>> advance(String id, DeliveryAction action);

  // ─── Courier outcomes (Phase 7 N2/N3) ───
  /// [code] is required while `handover.pending`.
  Future<Result<Delivery>> complete(String id, {String? code});

  Future<Result<Delivery>> fail(String id, DeliveryFailReason reason, {String? note});

  /// The delivery of a restaurant order, or null before a courier accepts it.
  Future<Result<Delivery?>> byRestaurantOrder(String restaurantOrderId);

  Future<Result<DeliveryRoute?>> route(String id);

  // ─── Owner/admin (B2C orders) ───
  Future<Result<List<AssignableCourier>>> assignableCouriers();

  /// [courierId] null = offer to all couriers. Reopens a cancelled delivery.
  Future<Result<Delivery>> create(String orderId, {String? courierId});

  /// Only before acceptance; null clears back to an open offer.
  Future<Result<Delivery>> reassign(String id, {String? courierId});

  Future<Result<Delivery>> cancel(String id, {String? reason});

  Future<Result<Delivery>> waiveHandover(String id);

  Future<Result<int>> revokeTrackingLinks(String id);

  // ─── Restaurant staff (Phase 6 V6) ───
  /// Public tracking link for a phone/walk-in restaurant customer without the app.
  Future<Result<DeliveryTrackingLink>> createTrackingLink({required String restaurantOrderId});
}
