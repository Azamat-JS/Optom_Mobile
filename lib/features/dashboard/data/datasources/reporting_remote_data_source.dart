import 'package:dio/dio.dart';

import 'package:bsmart/core/entities/reporting_shared.dart';
import 'package:bsmart/features/dashboard/domain/entities/retailer_dashboard.dart';
import 'package:bsmart/features/dashboard/domain/entities/wholesaler_dashboard.dart';

class ReportingRemoteDataSource {
  ReportingRemoteDataSource(this._dio);

  final Dio _dio;

  Future<WholesalerDashboard> getWholesalerDashboard() async {
    final response = await _dio.get<Map<String, dynamic>>('/reports/wholesaler');
    return WholesalerDashboard.fromJson(response.data!);
  }

  Future<RetailerDashboard> getRetailerDashboard() async {
    final response = await _dio.get<Map<String, dynamic>>('/reports/retailer');
    return RetailerDashboard.fromJson(response.data!);
  }

  Future<IncomeDebtChart> getIncomeDebtChart() async {
    final response = await _dio.get<Map<String, dynamic>>('/reports/income-debt-chart');
    return IncomeDebtChart.fromJson(response.data!);
  }
}
