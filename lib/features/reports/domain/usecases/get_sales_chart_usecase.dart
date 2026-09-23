import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/reports/domain/entities/report_period.dart';
import 'package:bsmart/features/reports/domain/entities/sales_chart_result.dart';
import 'package:bsmart/features/reports/domain/repositories/reports_repository.dart';

class GetSalesChartUseCase {
  GetSalesChartUseCase(this._repository);

  final ReportsRepository _repository;

  Future<Result<SalesChartResult>> call({required ReportPeriod period, String? month}) =>
      _repository.salesChart(period: period, month: month);
}
