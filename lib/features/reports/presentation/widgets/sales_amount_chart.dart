import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:bsmart/features/reports/domain/entities/sales_chart_result.dart';

/// Day-by-day revenue line for the Reports hub's selectable-period
/// `/reports/sales-chart` — a single `{date, amount}` series (unlike the
/// dashboard's fixed 14-day `SalesTrendChart`, which breaks totals down by
/// payment method), so this is its own, simpler widget rather than a reuse.
class SalesAmountChart extends StatelessWidget {
  const SalesAmountChart({super.key, required this.points});

  final List<AmountPoint> points;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final maxY = points.map((p) => p.amount).fold<double>(0, (a, b) => a > b ? a : b);

    return SizedBox(
      height: 180,
      child: points.isEmpty || points.every((p) => p.amount == 0)
          ? Center(child: Text("Ma'lumot yo'q", style: TextStyle(color: Theme.of(context).hintColor)))
          : LineChart(
              LineChartData(
                minY: 0,
                maxY: maxY == 0 ? 1 : maxY * 1.2,
                gridData: const FlGridData(show: true, drawVerticalLine: false),
                titlesData: const FlTitlesData(
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [for (var i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i].amount)],
                    isCurved: true,
                    color: scheme.primary,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: scheme.primary.withValues(alpha: 0.12)),
                  ),
                ],
              ),
            ),
    ).animate().fadeIn(delay: const Duration(milliseconds: 100));
  }
}
