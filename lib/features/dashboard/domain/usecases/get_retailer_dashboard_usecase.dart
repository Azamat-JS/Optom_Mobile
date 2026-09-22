import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/dashboard/domain/entities/retailer_dashboard.dart';
import 'package:bsmart/features/dashboard/domain/repositories/reporting_repository.dart';

class GetRetailerDashboardUseCase {
  GetRetailerDashboardUseCase(this._repository);

  final ReportingRepository _repository;

  Future<Result<RetailerDashboard>> call() => _repository.getRetailerDashboard();
}
