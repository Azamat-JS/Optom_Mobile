import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/reports/domain/entities/period_stats.dart';
import 'package:bsmart/features/reports/domain/entities/report_period.dart';
import 'package:bsmart/features/reports/domain/repositories/reports_repository.dart';

class GetPeriodStatsUseCase {
  GetPeriodStatsUseCase(this._repository);

  final ReportsRepository _repository;

  Future<Result<PeriodStats>> call({required ReportPeriod period, String? month}) =>
      _repository.periodStats(period: period, month: month);
}
