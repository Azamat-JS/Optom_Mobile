import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/dashboard/domain/entities/dashboard_shared.dart';
import 'package:bsmart/features/dashboard/domain/entities/retailer_dashboard.dart';
import 'package:bsmart/features/dashboard/domain/entities/wholesaler_dashboard.dart';

abstract class ReportingRepository {
  Future<Result<WholesalerDashboard>> getWholesalerDashboard();

  Future<Result<RetailerDashboard>> getRetailerDashboard();

  /// Last-6-months income-vs-debt bar chart, split by currency.
  Future<Result<IncomeDebtChart>> getIncomeDebtChart();
}
