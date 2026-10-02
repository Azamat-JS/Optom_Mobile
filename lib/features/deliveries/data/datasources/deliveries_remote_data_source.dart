import 'package:dio/dio.dart';

import 'package:bsmart/features/deliveries/data/models/delivery_model.dart';
import 'package:bsmart/features/deliveries/data/models/delivery_route_model.dart';
import 'package:bsmart/features/deliveries/domain/entities/delivery.dart';
import 'package:bsmart/features/deliveries/domain/entities/delivery_route.dart';
import 'package:bsmart/features/deliveries/domain/repositories/deliveries_repository.dart';

/// `/deliveries` — contract: Optom_Savdo CLAUDE.md "Deliveries — T4".
class DeliveriesRemoteDataSource {
  DeliveriesRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<Delivery>> list({bool openOnly = false}) async {
    final response = await _dio.get<List<dynamic>>(
      '/deliveries',
      queryParameters: {if (openOnly) 'open': true},
    );
    return response.data!.map((e) => deliveryFromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Delivery> get(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/deliveries/$id');
    return deliveryFromJson(response.data!);
  }

  /// 404 → null: the order simply has no delivery (yet).
  Future<Delivery?> byOrder(String orderId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/deliveries/by-order/$orderId');
      return deliveryFromJson(response.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<DeliveryRoute?> route(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/deliveries/$id/route');
    final route = response.data!['route'];
    return route is Map<String, dynamic> ? deliveryRouteFromJson(route) : null;
  }

  Future<Delivery> advance(String id, DeliveryAction action) async {
    final response = await _dio.patch<Map<String, dynamic>>('/deliveries/$id/${action.path}');
    return deliveryFromJson(response.data!);
  }
}
