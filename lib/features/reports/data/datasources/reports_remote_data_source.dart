import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'package:bsmart/features/reports/domain/entities/period_stats.dart';
import 'package:bsmart/features/reports/domain/entities/report_period.dart';
import 'package:bsmart/features/reports/domain/entities/sales_chart_result.dart';
import 'package:bsmart/features/reports/domain/entities/work_day.dart';

/// Raw `/reports/*` (period-comparison endpoints only — the fixed-window
/// dashboard endpoints live in `features/dashboard`) and `/work-day/*` calls.
class ReportsRemoteDataSource {
  ReportsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<PeriodStats> periodStats({required ReportPeriod period, String? month}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/reports/period-stats',
      queryParameters: {'period': period.toWire(), 'month': ?month},
    );
    return PeriodStats.fromJson(response.data!);
  }

  Future<SalesChartResult> salesChart({required ReportPeriod period, String? month}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/reports/sales-chart',
      queryParameters: {'period': period.toWire(), 'month': ?month},
    );
    return SalesChartResult.fromJson(response.data!);
  }

  Future<WorkDay?> currentWorkDay() async {
    final response = await _dio.get<Map<String, dynamic>?>('/work-day/current');
    final data = response.data;
    return data == null ? null : WorkDay.fromJson(data);
  }

  Future<WorkDay> startWorkDay() async {
    final response = await _dio.post<Map<String, dynamic>>('/work-day/start');
    return WorkDay.fromJson(response.data!);
  }

  Future<WorkDay> endWorkDay() async {
    final response = await _dio.post<Map<String, dynamic>>('/work-day/end');
    return WorkDay.fromJson(response.data!);
  }

  Future<Uint8List> exportDebtsXlsx() async {
    final response = await _dio.get<List<int>>(
      '/work-day/debts-export.xlsx',
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data!);
  }
}
