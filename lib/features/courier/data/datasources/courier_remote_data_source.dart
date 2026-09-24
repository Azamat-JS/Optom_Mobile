import 'package:dio/dio.dart';

import 'package:bsmart/features/courier/data/models/courier_model.dart';
import 'package:bsmart/features/courier/domain/entities/courier.dart';
import 'package:bsmart/features/courier/domain/entities/courier_list_result.dart';
import 'package:bsmart/features/courier/domain/entities/courier_write_params.dart';

class CourierRemoteDataSource {
  CourierRemoteDataSource(this._dio);

  final Dio _dio;

  Future<CourierListResult> list({String? search, int limit = 100}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/courier',
      queryParameters: {'limit': limit, if (search != null && search.isNotEmpty) 'search': search},
    );
    final json = response.data!;
    final data = (json['data'] as List).map((e) => courierFromJson(e as Map<String, dynamic>)).toList();
    final meta = json['meta'] as Map<String, dynamic>;
    return CourierListResult(items: data, courierLimit: (meta['courierLimit'] as num?)?.toInt() ?? 0);
  }

  Future<Courier> create(CreateCourierParams params) async {
    final response = await _dio.post<Map<String, dynamic>>('/courier', data: params.toRequestBody());
    return courierFromJson(response.data!);
  }

  Future<Courier> update(String id, UpdateCourierParams params) async {
    final response = await _dio.patch<Map<String, dynamic>>('/courier/$id', data: params.toRequestBody());
    return courierFromJson(response.data!);
  }

  Future<Courier> setActive(String id, bool isActive) async {
    final response = await _dio.patch<Map<String, dynamic>>('/courier/$id/${isActive ? 'activate' : 'deactivate'}');
    return courierFromJson(response.data!);
  }

  Future<void> delete(String id) => _dio.delete<void>('/courier/$id');
}
