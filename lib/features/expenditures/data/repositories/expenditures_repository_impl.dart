import 'package:dio/dio.dart';

import 'package:bsmart/core/network/dio_error_mapper.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/expenditures/data/datasources/expenditures_remote_data_source.dart';
import 'package:bsmart/features/expenditures/domain/entities/expenditure.dart';
import 'package:bsmart/features/expenditures/domain/entities/expenditure_list_result.dart';
import 'package:bsmart/features/expenditures/domain/entities/expenditure_query.dart';
import 'package:bsmart/features/expenditures/domain/entities/expenditure_write_params.dart';
import 'package:bsmart/features/expenditures/domain/repositories/expenditures_repository.dart';

class ExpendituresRepositoryImpl implements ExpendituresRepository {
  ExpendituresRepositoryImpl(this._remote);

  final ExpendituresRemoteDataSource _remote;

  @override
  Future<Result<ExpenditureListResult>> list(ExpenditureQuery query) async {
    try {
      return Result.ok(await _remote.list(query));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<Expenditure>> create(CreateExpenditureParams params) async {
    try {
      return Result.ok(await _remote.create(params));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<Expenditure>> update(String id, UpdateExpenditureParams params) async {
    try {
      return Result.ok(await _remote.update(id, params));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await _remote.delete(id);
      return const Result.ok(null);
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }
}
