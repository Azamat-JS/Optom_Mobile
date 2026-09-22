import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/dashboard/domain/entities/dashboard_shared.dart';
import 'package:bsmart/features/dashboard/domain/repositories/reporting_repository.dart';

class GetIncomeDebtChartUseCase {
  GetIncomeDebtChartUseCase(this._repository);

  final ReportingRepository _repository;

  Future<Result<IncomeDebtChart>> call() => _repository.getIncomeDebtChart();
}
