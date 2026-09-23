import 'package:dio/dio.dart';

import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/features/debts/data/models/debt_model.dart';
import 'package:bsmart/features/debts/domain/entities/debt.dart';
import 'package:bsmart/features/debts/domain/entities/debt_query.dart';

/// Raw `/sale-debts` calls — read-only (B2C `SaleDebt`, always created by
/// `sale.service.ts` on a `type: DEBT` checkout; no create/close route here).
class SaleDebtsRemoteDataSource {
  SaleDebtsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<PaginatedResult<SaleDebt>> list(SaleDebtQuery query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/sale-debts',
      queryParameters: query.toQueryParameters(),
    );
    return PaginatedResult.fromJson(response.data!, saleDebtFromJson);
  }

  Future<SaleDebt> getById(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/sale-debts/$id');
    return saleDebtFromJson(response.data!);
  }
}
