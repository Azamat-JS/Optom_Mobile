import 'package:dio/dio.dart';

import 'package:bsmart/core/enums/restaurant_order_enums.dart';
import 'package:bsmart/core/network/dio_error_mapper.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/restaurant_orders/data/datasources/restaurant_orders_remote_data_source.dart';
import 'package:bsmart/features/restaurant_orders/domain/entities/restaurant_order.dart';
import 'package:bsmart/features/restaurant_orders/domain/entities/restaurant_order_item_input.dart';
import 'package:bsmart/features/restaurant_orders/domain/entities/restaurant_order_person_ref.dart';
import 'package:bsmart/features/restaurant_orders/domain/entities/restaurant_order_write_params.dart';
import 'package:bsmart/features/restaurant_orders/domain/repositories/restaurant_orders_repository.dart';

class RestaurantOrdersRepositoryImpl implements RestaurantOrdersRepository {
  RestaurantOrdersRepositoryImpl(this._remote);

  final RestaurantOrdersRemoteDataSource _remote;

  @override
  Future<Result<RestaurantOrder>> create(CreateRestaurantOrderParams params) async {
    try {
      return Result.ok(await _remote.create(params));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<List<RestaurantOrder>>> findOpen() async {
    try {
      return Result.ok(await _remote.findOpen());
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<RestaurantOrder>> findOne(String id) async {
    try {
      return Result.ok(await _remote.findOne(id));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<RestaurantOrder>> addItems(String id, List<RestaurantOrderItemInput> items) async {
    try {
      return Result.ok(await _remote.addItems(id, items));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<RestaurantOrder>> updateStatus(String id, RestaurantOrderStatus status) async {
    try {
      return Result.ok(await _remote.updateStatus(id, status));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<RestaurantOrder>> accept(String id) async {
    try {
      return Result.ok(await _remote.accept(id));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<RestaurantOrder>> assignCourier(String id, String? courierId) async {
    try {
      return Result.ok(await _remote.assignCourier(id, courierId));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<List<RestaurantOrderPersonRef>>> listCouriers() async {
    try {
      return Result.ok(await _remote.listCouriers());
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }
}
