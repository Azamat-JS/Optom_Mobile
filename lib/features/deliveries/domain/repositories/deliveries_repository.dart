import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/deliveries/domain/entities/assignable_courier.dart';
import 'package:bsmart/features/deliveries/domain/entities/delivery.dart';
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

  Future<Result<DeliveryRoute?>> route(String id);

  // ─── Owner/admin (B2C orders) ───
  Future<Result<List<AssignableCourier>>> assignableCouriers();

  /// [courierId] null = offer to all couriers. Reopens a cancelled delivery.
  Future<Result<Delivery>> create(String orderId, {String? courierId});

  /// Only before acceptance; null clears back to an open offer.
  Future<Result<Delivery>> reassign(String id, {String? courierId});

  Future<Result<Delivery>> cancel(String id);
}
