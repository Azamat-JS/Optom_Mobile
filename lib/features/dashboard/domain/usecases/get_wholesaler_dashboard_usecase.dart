import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/dashboard/domain/entities/wholesaler_dashboard.dart';
import 'package:bsmart/features/dashboard/domain/repositories/reporting_repository.dart';

class GetWholesalerDashboardUseCase {
  GetWholesalerDashboardUseCase(this._repository);

  final ReportingRepository _repository;

  Future<Result<WholesalerDashboard>> call() => _repository.getWholesalerDashboard();
}
