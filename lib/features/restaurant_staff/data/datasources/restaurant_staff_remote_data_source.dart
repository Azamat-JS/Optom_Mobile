import 'package:dio/dio.dart';

import 'package:bsmart/features/restaurant_staff/data/models/waiter_model.dart';
import 'package:bsmart/features/restaurant_staff/domain/entities/waiter.dart';
import 'package:bsmart/features/restaurant_staff/domain/entities/waiter_list_result.dart';
import 'package:bsmart/features/restaurant_staff/domain/entities/waiter_write_params.dart';

class RestaurantStaffRemoteDataSource {
  RestaurantStaffRemoteDataSource(this._dio);

  final Dio _dio;

  Future<WaiterListResult> list({String? search, int limit = 100}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/restaurant-staff',
      queryParameters: {'limit': limit, if (search != null && search.isNotEmpty) 'search': search},
    );
    final json = response.data!;
    final data = (json['data'] as List).map((e) => waiterFromJson(e as Map<String, dynamic>)).toList();
    final meta = json['meta'] as Map<String, dynamic>;
    return WaiterListResult(items: data, waiterLimit: (meta['waiterLimit'] as num?)?.toInt() ?? 0);
  }

  Future<Waiter> create(CreateWaiterParams params) async {
    final response = await _dio.post<Map<String, dynamic>>('/restaurant-staff', data: params.toRequestBody());
    return waiterFromJson(response.data!);
  }

  Future<Waiter> update(String id, UpdateWaiterParams params) async {
    final response = await _dio.patch<Map<String, dynamic>>('/restaurant-staff/$id', data: params.toRequestBody());
    return waiterFromJson(response.data!);
  }

  Future<Waiter> setActive(String id, bool isActive) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/restaurant-staff/$id/${isActive ? 'activate' : 'deactivate'}',
    );
    return waiterFromJson(response.data!);
  }

  Future<void> delete(String id) => _dio.delete<void>('/restaurant-staff/$id');
}
