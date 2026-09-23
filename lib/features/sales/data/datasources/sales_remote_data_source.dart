import 'package:dio/dio.dart';

import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/features/sales/data/models/sale_model.dart';
import 'package:bsmart/features/sales/domain/entities/sale.dart';
import 'package:bsmart/features/sales/domain/entities/sale_query.dart';
import 'package:bsmart/features/sales/domain/entities/sale_write_params.dart';

/// Raw `/sales` calls — POS checkout reuses this same B2C sale endpoint,
/// there is no separate POS backend service (see `sale.service.ts`).
class SalesRemoteDataSource {
  SalesRemoteDataSource(this._dio);

  final Dio _dio;

  Future<PaginatedResult<Sale>> list(SaleQuery query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/sales',
      queryParameters: query.toQueryParameters(),
    );
    return PaginatedResult.fromJson(response.data!, saleFromJson);
  }

  Future<Sale> getById(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/sales/$id');
    return saleFromJson(response.data!);
  }

  Future<Sale> create(CreateSaleParams params) async {
    final response = await _dio.post<Map<String, dynamic>>('/sales', data: params.toRequestBody());
    return saleFromJson(response.data!);
  }

  Future<Sale> createReturn(String saleId, CreateSaleReturnParams params) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/sales/$saleId/returns',
      data: params.toRequestBody(),
    );
    return saleFromJson(response.data!['sale'] as Map<String, dynamic>);
  }
}
