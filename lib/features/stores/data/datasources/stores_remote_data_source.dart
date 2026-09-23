import 'package:dio/dio.dart';

import 'package:bsmart/features/stores/data/models/store_model.dart';
import 'package:bsmart/features/stores/domain/entities/store.dart';
import 'package:bsmart/features/stores/domain/entities/store_write_params.dart';

/// Raw `/stores` calls — no pagination, a small working set by design (see
/// `store.controller.ts`'s own doc comment).
class StoresRemoteDataSource {
  StoresRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<Store>> list() async {
    final response = await _dio.get<List<dynamic>>('/stores');
    return response.data!.map((e) => storeFromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Store> create(CreateStoreParams params) async {
    final response = await _dio.post<Map<String, dynamic>>('/stores', data: params.toRequestBody());
    return storeFromJson(response.data!);
  }

  Future<Store> update(String id, UpdateStoreParams params) async {
    final response = await _dio.patch<Map<String, dynamic>>('/stores/$id', data: params.toRequestBody());
    return storeFromJson(response.data!);
  }

  Future<Store> setActive(String id, bool isActive) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/stores/$id/${isActive ? 'activate' : 'deactivate'}',
    );
    return storeFromJson(response.data!);
  }

  Future<void> delete(String id) => _dio.delete<void>('/stores/$id');
}
