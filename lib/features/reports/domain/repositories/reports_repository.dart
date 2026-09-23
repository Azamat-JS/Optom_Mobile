import 'dart:typed_data';

import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/reports/domain/entities/period_stats.dart';
import 'package:bsmart/features/reports/domain/entities/report_period.dart';
import 'package:bsmart/features/reports/domain/entities/sales_chart_result.dart';
import 'package:bsmart/features/reports/domain/entities/work_day.dart';

abstract class ReportsRepository {
  Future<Result<PeriodStats>> periodStats({required ReportPeriod period, String? month});

  Future<Result<SalesChartResult>> salesChart({required ReportPeriod period, String? month});

  Future<Result<WorkDay?>> currentWorkDay();

  Future<Result<WorkDay>> startWorkDay();

  Future<Result<WorkDay>> endWorkDay();

  Future<Result<Uint8List>> exportDebtsXlsx();
}
