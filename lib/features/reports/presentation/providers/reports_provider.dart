import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/features/reports/domain/entities/period_stats.dart';
import 'package:bsmart/features/reports/domain/entities/report_period.dart';
import 'package:bsmart/features/reports/domain/entities/sales_chart_result.dart';
import 'package:bsmart/features/reports/domain/usecases/get_period_stats_usecase.dart';
import 'package:bsmart/features/reports/domain/usecases/get_sales_chart_usecase.dart';

/// The period selector driving both [reportsProvider]'s sections — see
/// `ReportPeriod`'s doc comment for why only these two values are exposed.
final selectedReportPeriodProvider = StateProvider<ReportPeriod>((ref) => ReportPeriod.last30);

/// The UZS/USD toggle for the Reports hub's sales chart — pure UI state,
/// same role as `selectedDashboardCurrencyProvider`.
final selectedReportCurrencyProvider = StateProvider<Currency>((ref) => Currency.uzs);

class ReportsData {
  const ReportsData({required this.periodStats, required this.salesChart});

  final PeriodStats periodStats;
  final SalesChartResult salesChart;
}

class ReportsNotifier extends AsyncNotifier<ReportsData> {
  @override
  Future<ReportsData> build() async {
    final period = ref.watch(selectedReportPeriodProvider);

    final statsResult = await getIt<GetPeriodStatsUseCase>().call(period: period);
    final chartResult = await getIt<GetSalesChartUseCase>().call(period: period);

    final stats = statsResult.fold((d) => d, (failure) => throw failure);
    final chart = chartResult.fold((d) => d, (failure) => throw failure);
    return ReportsData(periodStats: stats, salesChart: chart);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final reportsProvider = AsyncNotifierProvider<ReportsNotifier, ReportsData>(ReportsNotifier.new);
