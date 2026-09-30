import 'package:dio/dio.dart';

import 'package:bsmart/features/sales/data/models/shared_cart_model.dart';
import 'package:bsmart/features/sales/domain/entities/shared_cart.dart';
import 'package:bsmart/features/sales/domain/entities/shared_cart_write_params.dart';

/// Raw `/shared-cart` calls — no pagination on the list endpoint, matching
/// its own small-working-set design (see `shared-cart.service.ts`).
class SharedCartRemoteDataSource {
  SharedCartRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<SharedCart>> list() async {
    final response = await _dio.get<List<dynamic>>('/shared-cart');
    return response.data!.map((e) => sharedCartFromJson(e as Map<String, dynamic>)).toList();
  }

  Future<SharedCart> park(CreateSharedCartParams params) async {
    final response = await _dio.post<Map<String, dynamic>>('/shared-cart', data: params.toRequestBody());
    return sharedCartFromJson(response.data!);
  }

  Future<SharedCart> remove(String id) async {
    final response = await _dio.delete<Map<String, dynamic>>('/shared-cart/$id');
    return sharedCartFromJson(response.data!);
  }
}
