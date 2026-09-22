import 'package:dio/dio.dart';

import 'package:bsmart/core/network/dio_error_mapper.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/dashboard/data/datasources/reporting_remote_data_source.dart';
import 'package:bsmart/features/dashboard/domain/entities/dashboard_shared.dart';
import 'package:bsmart/features/dashboard/domain/entities/retailer_dashboard.dart';
import 'package:bsmart/features/dashboard/domain/entities/wholesaler_dashboard.dart';
import 'package:bsmart/features/dashboard/domain/repositories/reporting_repository.dart';

class ReportingRepositoryImpl implements ReportingRepository {
  ReportingRepositoryImpl(this._remote);

  final ReportingRemoteDataSource _remote;

  @override
  Future<Result<WholesalerDashboard>> getWholesalerDashboard() async {
    try {
      return Result.ok(await _remote.getWholesalerDashboard());
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<RetailerDashboard>> getRetailerDashboard() async {
    try {
      return Result.ok(await _remote.getRetailerDashboard());
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<IncomeDebtChart>> getIncomeDebtChart() async {
    try {
      return Result.ok(await _remote.getIncomeDebtChart());
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }
}
