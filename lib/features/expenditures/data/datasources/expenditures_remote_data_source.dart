import 'package:dio/dio.dart';

import 'package:bsmart/features/expenditures/data/models/expenditure_model.dart';
import 'package:bsmart/features/expenditures/domain/entities/expenditure.dart';
import 'package:bsmart/features/expenditures/domain/entities/expenditure_list_result.dart';
import 'package:bsmart/features/expenditures/domain/entities/expenditure_query.dart';
import 'package:bsmart/features/expenditures/domain/entities/expenditure_write_params.dart';

/// Raw `/expenditures` calls — a SELLER's/RETAILER's own business overhead
/// spending log. Owner-only server-side (see `CLAUDE.md` "Expenditures") —
/// `_ADMIN` staff sessions get a 403 from every method here.
class ExpendituresRemoteDataSource {
  ExpendituresRemoteDataSource(this._dio);

  final Dio _dio;

  Future<ExpenditureListResult> list(ExpenditureQuery query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/expenditures',
      queryParameters: query.toQueryParameters(),
    );
    return expenditureListResultFromJson(response.data!);
  }

  Future<Expenditure> create(CreateExpenditureParams params) async {
    final response = await _dio.post<Map<String, dynamic>>('/expenditures', data: params.toRequestBody());
    return expenditureFromJson(response.data!);
  }

  Future<Expenditure> update(String id, UpdateExpenditureParams params) async {
    final response = await _dio.patch<Map<String, dynamic>>('/expenditures/$id', data: params.toRequestBody());
    return expenditureFromJson(response.data!);
  }

  Future<void> delete(String id) => _dio.delete<void>('/expenditures/$id');
}
