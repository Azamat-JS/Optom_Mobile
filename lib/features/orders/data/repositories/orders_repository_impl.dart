import 'package:dio/dio.dart';

import 'package:bsmart/core/network/dio_error_mapper.dart';
import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/orders/data/datasources/orders_remote_data_source.dart';
import 'package:bsmart/features/orders/domain/entities/order.dart';
import 'package:bsmart/features/orders/domain/entities/order_query.dart';
import 'package:bsmart/features/orders/domain/entities/order_write_params.dart';
import 'package:bsmart/features/orders/domain/repositories/orders_repository.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  OrdersRepositoryImpl(this._remote);

  final OrdersRemoteDataSource _remote;

  @override
  Future<Result<PaginatedResult<Order>>> list(OrderQuery query) async {
    try {
      return Result.ok(await _remote.list(query));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<Order>> getById(String id) async {
    try {
      return Result.ok(await _remote.getById(id));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<Order>> create(CreateOrderParams params) async {
    try {
      return Result.ok(await _remote.create(params));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<Order>> updateStatus(String id, UpdateOrderStatusParams params) async {
    try {
      return Result.ok(await _remote.updateStatus(id, params));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }
}
