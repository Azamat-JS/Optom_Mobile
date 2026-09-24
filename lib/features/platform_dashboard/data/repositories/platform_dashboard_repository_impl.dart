import 'package:dio/dio.dart';

import 'package:bsmart/core/entities/reporting_shared.dart';
import 'package:bsmart/core/network/dio_error_mapper.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/platform_dashboard/data/datasources/platform_dashboard_remote_data_source.dart';
import 'package:bsmart/features/platform_dashboard/domain/entities/platform_dashboard.dart';
import 'package:bsmart/features/platform_dashboard/domain/repositories/platform_dashboard_repository.dart';

class PlatformDashboardRepositoryImpl implements PlatformDashboardRepository {
  PlatformDashboardRepositoryImpl(this._remote);

  final PlatformDashboardRemoteDataSource _remote;

  @override
  Future<Result<PlatformDashboard>> getDashboard() async {
    try {
      return Result.ok(await _remote.getDashboard());
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
