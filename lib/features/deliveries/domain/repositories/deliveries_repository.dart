import 'package:bsmart/core/network/result.dart';
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
}
