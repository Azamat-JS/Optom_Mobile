import 'package:dio/dio.dart';

import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/features/debts/data/models/debt_model.dart';
import 'package:bsmart/features/debts/domain/entities/debt.dart';
import 'package:bsmart/features/debts/domain/entities/debt_query.dart';
import 'package:bsmart/features/debts/domain/entities/payment_write_params.dart';

/// Raw `/debts` calls — the B2B `Debt` model (wholesaler↔retailer, or a
/// manually-recorded retailer→customer / self-owed entry).
class DebtsRemoteDataSource {
  DebtsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<PaginatedResult<Debt>> list(DebtQuery query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/debts',
      queryParameters: query.toQueryParameters(),
    );
    return PaginatedResult.fromJson(response.data!, debtFromJson);
  }

  Future<Debt> getById(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/debts/$id');
    return debtFromJson(response.data!);
  }

  Future<Debt> close(String id, CloseDebtParams params) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/debts/$id/close',
      data: params.toRequestBody(),
    );
    return debtFromJson(response.data!);
  }
}
