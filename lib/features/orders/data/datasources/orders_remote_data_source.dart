import 'package:dio/dio.dart';

import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/features/orders/data/models/order_model.dart';
import 'package:bsmart/features/orders/domain/entities/order.dart';
import 'package:bsmart/features/orders/domain/entities/order_query.dart';
import 'package:bsmart/features/orders/domain/entities/order_write_params.dart';

class OrdersRemoteDataSource {
  OrdersRemoteDataSource(this._dio);

  final Dio _dio;

  Future<PaginatedResult<Order>> list(OrderQuery query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/orders',
      queryParameters: query.toQueryParameters(),
    );
    return PaginatedResult.fromJson(response.data!, orderFromJson);
  }

  Future<Order> getById(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/orders/$id');
    return orderFromJson(response.data!);
  }

  Future<Order> create(CreateOrderParams params) async {
    final response = await _dio.post<Map<String, dynamic>>('/orders', data: params.toRequestBody());
    return orderFromJson(response.data!);
  }

  Future<Order> updateStatus(String id, UpdateOrderStatusParams params) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/orders/$id/status',
      data: params.toRequestBody(),
    );
    return orderFromJson(response.data!);
  }
}
