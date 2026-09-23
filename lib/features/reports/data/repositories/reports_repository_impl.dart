import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'package:bsmart/core/network/dio_error_mapper.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/reports/data/datasources/reports_remote_data_source.dart';
import 'package:bsmart/features/reports/domain/entities/period_stats.dart';
import 'package:bsmart/features/reports/domain/entities/report_period.dart';
import 'package:bsmart/features/reports/domain/entities/sales_chart_result.dart';
import 'package:bsmart/features/reports/domain/entities/work_day.dart';
import 'package:bsmart/features/reports/domain/repositories/reports_repository.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  ReportsRepositoryImpl(this._remote);

  final ReportsRemoteDataSource _remote;

  @override
  Future<Result<PeriodStats>> periodStats({required ReportPeriod period, String? month}) async {
    try {
      return Result.ok(await _remote.periodStats(period: period, month: month));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<SalesChartResult>> salesChart({required ReportPeriod period, String? month}) async {
    try {
      return Result.ok(await _remote.salesChart(period: period, month: month));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<WorkDay?>> currentWorkDay() async {
    try {
      return Result.ok(await _remote.currentWorkDay());
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<WorkDay>> startWorkDay() async {
    try {
      return Result.ok(await _remote.startWorkDay());
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<WorkDay>> endWorkDay() async {
    try {
      return Result.ok(await _remote.endWorkDay());
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<Uint8List>> exportDebtsXlsx() async {
    try {
      return Result.ok(await _remote.exportDebtsXlsx());
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }
}
