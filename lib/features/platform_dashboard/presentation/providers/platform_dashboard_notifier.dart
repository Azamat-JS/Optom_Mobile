import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/entities/reporting_shared.dart';
import 'package:bsmart/features/platform_dashboard/domain/entities/platform_dashboard.dart';
import 'package:bsmart/features/platform_dashboard/domain/usecases/get_platform_dashboard_usecase.dart';
import 'package:bsmart/features/platform_dashboard/domain/usecases/get_platform_income_debt_chart_usecase.dart';

class PlatformDashboardData {
  const PlatformDashboardData({required this.dashboard, required this.incomeDebtChart});

  final PlatformDashboard dashboard;
  final IncomeDebtChart incomeDebtChart;
}

class PlatformDashboardNotifier extends AsyncNotifier<PlatformDashboardData> {
  @override
  Future<PlatformDashboardData> build() async {
    final dashboardResult = await getIt<GetPlatformDashboardUseCase>().call();
    final incomeDebtResult = await getIt<GetPlatformIncomeDebtChartUseCase>().call();
    final dashboard = dashboardResult.fold((d) => d, (failure) => throw failure);
    final incomeDebt = incomeDebtResult.fold((d) => d, (failure) => throw failure);
    return PlatformDashboardData(dashboard: dashboard, incomeDebtChart: incomeDebt);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final platformDashboardProvider = AsyncNotifierProvider<PlatformDashboardNotifier, PlatformDashboardData>(
  PlatformDashboardNotifier.new,
);
