import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/core/entities/reporting_shared.dart';
import 'package:bsmart/features/dashboard/domain/entities/retailer_dashboard.dart';
import 'package:bsmart/features/dashboard/domain/entities/wholesaler_dashboard.dart';
import 'package:bsmart/features/dashboard/domain/usecases/get_income_debt_chart_usecase.dart';
import 'package:bsmart/features/dashboard/domain/usecases/get_retailer_dashboard_usecase.dart';
import 'package:bsmart/features/dashboard/domain/usecases/get_wholesaler_dashboard_usecase.dart';

/// Exactly one of [wholesaler]/[retailer] is non-null, depending on the
/// current session's role family — see [DashboardNotifier.build].
class DashboardData {
  const DashboardData({this.wholesaler, this.retailer, required this.incomeDebtChart});

  final WholesalerDashboard? wholesaler;
  final RetailerDashboard? retailer;
  final IncomeDebtChart incomeDebtChart;

  CountAndAmountByCurrency get todaySales => (wholesaler?.todaySales ?? retailer?.todaySales)!;
  CountAndAmountByCurrency get totalSales => (wholesaler?.totalSales ?? retailer?.totalSales)!;
  PaymentBreakdownByCurrency get paymentBreakdown =>
      (wholesaler?.paymentBreakdown ?? retailer?.paymentBreakdown)!;
  TrendPointsByCurrency get salesTrend => (wholesaler?.salesTrend ?? retailer?.salesTrend)!;
  InventoryStatsByCurrency get inventory => (wholesaler?.inventory ?? retailer?.inventory)!;
}

class DashboardNotifier extends AsyncNotifier<DashboardData> {
  @override
  Future<DashboardData> build() async {
    final role = ref.watch(sessionNotifierProvider).valueOrNull?.session?.role;

    if (role != null && role.isSellerFamily) {
      final dashboardResult = await getIt<GetWholesalerDashboardUseCase>().call();
      final incomeDebtResult = await getIt<GetIncomeDebtChartUseCase>().call();
      final wholesaler = dashboardResult.fold((d) => d, (failure) => throw failure);
      final incomeDebt = incomeDebtResult.fold((d) => d, (failure) => throw failure);
      return DashboardData(wholesaler: wholesaler, incomeDebtChart: incomeDebt);
    }

    if (role != null && role.isRetailerFamily) {
      final dashboardResult = await getIt<GetRetailerDashboardUseCase>().call();
      final incomeDebtResult = await getIt<GetIncomeDebtChartUseCase>().call();
      final retailer = dashboardResult.fold((d) => d, (failure) => throw failure);
      final incomeDebt = incomeDebtResult.fold((d) => d, (failure) => throw failure);
      return DashboardData(retailer: retailer, incomeDebtChart: incomeDebt);
    }

    // WAITER/COURIER/SUPER_ADMIN/CUSTOMER never reach this screen in Phase 1
    // (see app_router.dart) — this branch only guards against a bad state.
    throw StateError('No dashboard defined for role: $role');
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final dashboardProvider = AsyncNotifierProvider<DashboardNotifier, DashboardData>(
  DashboardNotifier.new,
);

/// The UZS/USD toggle — pure UI state, not fetched from the backend (every
/// dashboard response already carries both currencies split out; this just
/// selects which one the charts/KPI cards currently render).
final selectedDashboardCurrencyProvider = StateProvider<Currency>((ref) => Currency.uzs);
