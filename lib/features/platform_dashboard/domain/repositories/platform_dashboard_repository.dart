import 'package:bsmart/core/entities/reporting_shared.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/platform_dashboard/domain/entities/platform_dashboard.dart';

abstract class PlatformDashboardRepository {
  Future<Result<PlatformDashboard>> getDashboard();

  Future<Result<IncomeDebtChart>> getIncomeDebtChart();
}
