import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:bsmart/core/entities/reporting_shared.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';

/// Last-6-months income-vs-debt grouped bar chart (the Revolut "Income" card).
class IncomeDebtBarChart extends StatelessWidget {
  const IncomeDebtBarChart({super.key, required this.points});

  final List<IncomeDebtPoint> points;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    final debtColor = Theme.of(context).colorScheme.error;
    final maxY = points.map((p) => p.income > p.debt ? p.income : p.debt).fold<double>(0, (a, b) => a > b ? a : b);
    final hasData = points.any((p) => p.income > 0 || p.debt > 0);

    return DashCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.dashIncomeDebt6m,
                  style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
              _legendDot(context, AppColors.brandAmber, context.l10n.dashIncome),
              const SizedBox(width: 12),
              _legendDot(context, debtColor, context.l10n.dashPaymentDebt),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: !hasData
                ? Center(
                    child: Text(
                      context.l10n.commonNoData,
                      style: TextStyle(color: colors.textMuted, fontWeight: FontWeight.w600),
                    ),
                  )
                : BarChart(
                    BarChartData(
                      maxY: maxY * 1.2,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) =>
                            FlLine(color: colors.outline.withValues(alpha: 0.6), strokeWidth: 1, dashArray: [4, 4]),
                      ),
                      borderData: FlBorderData(show: false),
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(),
                        rightTitles: const AxisTitles(),
                        leftTitles: const AxisTitles(),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 26,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= points.length) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  _shortMonth(context, points[index].month),
                                  style: TextStyle(color: colors.textMuted, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      barGroups: [
                        for (var i = 0; i < points.length; i++)
                          BarChartGroupData(
                            x: i,
                            barsSpace: 4,
                            barRods: [
                              BarChartRodData(
                                toY: points[i].income,
                                color: AppColors.brandAmber,
                                width: 10,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              BarChartRodData(
                                toY: points[i].debt,
                                color: debtColor,
                                width: 10,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: const Duration(milliseconds: 200));
  }

  Widget _legendDot(BuildContext context, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(color: BrandColors.of(context).textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

/// "2026-05" → "May" (localized); anything else is shown as is.
String _shortMonth(BuildContext context, String yearMonth) {
  final month = int.tryParse(yearMonth.split('-').elementAtOrNull(1) ?? '');
  final names = context.l10n.commonMonthsShort.split(',');
  return month != null && month >= 1 && month <= names.length ? names[month - 1] : yearMonth;
}
