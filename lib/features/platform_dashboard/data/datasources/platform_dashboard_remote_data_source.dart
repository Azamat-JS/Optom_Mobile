import 'package:dio/dio.dart';

import 'package:bsmart/core/entities/reporting_shared.dart';
import 'package:bsmart/features/platform_dashboard/domain/entities/platform_dashboard.dart';

class PlatformDashboardRemoteDataSource {
  PlatformDashboardRemoteDataSource(this._dio);

  final Dio _dio;

  Future<PlatformDashboard> getDashboard() async {
    final response = await _dio.get<Map<String, dynamic>>('/reports/admin');
    return PlatformDashboard.fromJson(response.data!);
  }

  Future<IncomeDebtChart> getIncomeDebtChart() async {
    final response = await _dio.get<Map<String, dynamic>>('/reports/admin/income-debt-chart');
    return IncomeDebtChart.fromJson(response.data!);
  }
}
