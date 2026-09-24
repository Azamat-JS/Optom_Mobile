import 'package:dio/dio.dart';

import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/features/restaurant_tables/data/models/restaurant_table_model.dart';
import 'package:bsmart/features/restaurant_tables/domain/entities/restaurant_table.dart';
import 'package:bsmart/features/restaurant_tables/domain/entities/restaurant_table_write_params.dart';

class RestaurantTablesRemoteDataSource {
  RestaurantTablesRemoteDataSource(this._dio);

  final Dio _dio;

  Future<PaginatedResult<RestaurantTable>> list({String? search, int limit = 100}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/restaurant-tables',
      queryParameters: {'limit': limit, if (search != null && search.isNotEmpty) 'search': search},
    );
    return PaginatedResult.fromJson(response.data!, restaurantTableFromJson);
  }

  Future<RestaurantTable> create(CreateRestaurantTableParams params) async {
    final response = await _dio.post<Map<String, dynamic>>('/restaurant-tables', data: params.toRequestBody());
    return restaurantTableFromJson(response.data!);
  }

  Future<RestaurantTable> update(String id, UpdateRestaurantTableParams params) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/restaurant-tables/$id',
      data: params.toRequestBody(),
    );
    return restaurantTableFromJson(response.data!);
  }

  Future<void> delete(String id) => _dio.delete<void>('/restaurant-tables/$id');
}
