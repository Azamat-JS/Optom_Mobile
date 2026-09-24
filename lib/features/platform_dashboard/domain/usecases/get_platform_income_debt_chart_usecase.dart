import 'package:bsmart/core/entities/reporting_shared.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/platform_dashboard/domain/repositories/platform_dashboard_repository.dart';

class GetPlatformIncomeDebtChartUseCase {
  GetPlatformIncomeDebtChartUseCase(this._repository);

  final PlatformDashboardRepository _repository;

  Future<Result<IncomeDebtChart>> call() => _repository.getIncomeDebtChart();
}
