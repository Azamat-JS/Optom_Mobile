import 'package:dio/dio.dart';

import 'package:bsmart/core/network/dio_error_mapper.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/deliveries/data/datasources/deliveries_remote_data_source.dart';
import 'package:bsmart/features/deliveries/domain/entities/assignable_courier.dart';
import 'package:bsmart/features/deliveries/domain/entities/delivery.dart';
import 'package:bsmart/features/deliveries/domain/entities/delivery_tracking_link.dart';
import 'package:bsmart/features/deliveries/domain/entities/delivery_route.dart';
import 'package:bsmart/features/deliveries/domain/repositories/deliveries_repository.dart';

class DeliveriesRepositoryImpl implements DeliveriesRepository {
  DeliveriesRepositoryImpl(this._remote);

  final DeliveriesRemoteDataSource _remote;

  Future<Result<T>> _guard<T>(Future<T> Function() call) async {
    try {
      return Result.ok(await call());
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<List<Delivery>>> list({bool openOnly = false}) => _guard(() => _remote.list(openOnly: openOnly));

  @override
  Future<Result<Delivery>> get(String id) => _guard(() => _remote.get(id));

  @override
  Future<Result<Delivery?>> byOrder(String orderId) => _guard(() => _remote.byOrder(orderId));

  @override
  Future<Result<DeliveryRoute?>> route(String id) => _guard(() => _remote.route(id));

  @override
  Future<Result<List<AssignableCourier>>> assignableCouriers() => _guard(_remote.assignableCouriers);

  @override
  Future<Result<Delivery>> create(String orderId, {String? courierId}) =>
      _guard(() => _remote.create(orderId, courierId: courierId));

  @override
  Future<Result<Delivery>> reassign(String id, {String? courierId}) =>
      _guard(() => _remote.reassign(id, courierId: courierId));

  @override
  Future<Result<Delivery>> cancel(String id, {String? reason}) => _guard(() => _remote.cancel(id, reason: reason));

  @override
  Future<Result<Delivery>> complete(String id, {String? code}) => _guard(() => _remote.complete(id, code: code));

  @override
  Future<Result<Delivery>> fail(String id, DeliveryFailReason reason, {String? note}) =>
      _guard(() => _remote.fail(id, reason, note: note));

  @override
  Future<Result<Delivery?>> byRestaurantOrder(String restaurantOrderId) =>
      _guard(() => _remote.byRestaurantOrder(restaurantOrderId));

  @override
  Future<Result<Delivery>> waiveHandover(String id) => _guard(() => _remote.waiveHandover(id));

  @override
  Future<Result<int>> revokeTrackingLinks(String id) => _guard(() => _remote.revokeTrackingLinks(id));

  @override
  Future<Result<DeliveryTrackingLink>> createTrackingLink({required String restaurantOrderId}) =>
      _guard(() => _remote.createTrackingLink(restaurantOrderId: restaurantOrderId));

  @override
  Future<Result<Delivery>> advance(String id, DeliveryAction action) => _guard(() => _remote.advance(id, action));
}
