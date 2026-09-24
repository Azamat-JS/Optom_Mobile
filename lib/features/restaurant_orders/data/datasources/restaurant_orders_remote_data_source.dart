import 'package:dio/dio.dart';

import 'package:bsmart/core/enums/restaurant_order_enums.dart';
import 'package:bsmart/features/restaurant_orders/data/models/restaurant_order_model.dart';
import 'package:bsmart/features/restaurant_orders/domain/entities/restaurant_order.dart';
import 'package:bsmart/features/restaurant_orders/domain/entities/restaurant_order_item_input.dart';
import 'package:bsmart/features/restaurant_orders/domain/entities/restaurant_order_person_ref.dart';
import 'package:bsmart/features/restaurant_orders/domain/entities/restaurant_order_write_params.dart';

class RestaurantOrdersRemoteDataSource {
  RestaurantOrdersRemoteDataSource(this._dio);

  final Dio _dio;

  Future<RestaurantOrder> create(CreateRestaurantOrderParams params) async {
    final response = await _dio.post<Map<String, dynamic>>('/restaurant-orders', data: params.toRequestBody());
    return restaurantOrderFromJson(response.data!);
  }

  /// Every non-terminal order, no pagination — the order board's default
  /// (and, in this app, only) view, mirroring the reference backend's own
  /// "POS waiting orders panel" use of this same endpoint.
  Future<List<RestaurantOrder>> findOpen() async {
    final response = await _dio.get<List<dynamic>>('/restaurant-orders/open');
    return response.data!.map((e) => restaurantOrderFromJson(e as Map<String, dynamic>)).toList();
  }

  Future<RestaurantOrder> findOne(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/restaurant-orders/$id');
    return restaurantOrderFromJson(response.data!);
  }

  Future<RestaurantOrder> addItems(String id, List<RestaurantOrderItemInput> items) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/restaurant-orders/$id/items',
      data: {'items': items.map((i) => i.toRequestBody()).toList()},
    );
    return restaurantOrderFromJson(response.data!);
  }

  Future<RestaurantOrder> updateStatus(String id, RestaurantOrderStatus status) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/restaurant-orders/$id/status',
      data: {'status': status.toWire()},
    );
    return restaurantOrderFromJson(response.data!);
  }

  Future<RestaurantOrder> accept(String id) async {
    final response = await _dio.patch<Map<String, dynamic>>('/restaurant-orders/$id/accept');
    return restaurantOrderFromJson(response.data!);
  }

  Future<RestaurantOrder> assignCourier(String id, String? courierId) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/restaurant-orders/$id/courier',
      data: {'courierId': courierId},
    );
    return restaurantOrderFromJson(response.data!);
  }

  Future<List<RestaurantOrderPersonRef>> listCouriers() async {
    final response = await _dio.get<List<dynamic>>('/restaurant-orders/couriers');
    return response.data!
        .map(
          (e) => RestaurantOrderPersonRef(
            id: (e as Map<String, dynamic>)['id'] as String,
            firstName: e['firstName'] as String,
            lastName: e['lastName'] as String,
          ),
        )
        .toList();
  }
}
