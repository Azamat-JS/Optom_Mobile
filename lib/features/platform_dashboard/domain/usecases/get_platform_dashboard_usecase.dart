import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/platform_dashboard/domain/entities/platform_dashboard.dart';
import 'package:bsmart/features/platform_dashboard/domain/repositories/platform_dashboard_repository.dart';

class GetPlatformDashboardUseCase {
  GetPlatformDashboardUseCase(this._repository);

  final PlatformDashboardRepository _repository;

  Future<Result<PlatformDashboard>> call() => _repository.getDashboard();
}
