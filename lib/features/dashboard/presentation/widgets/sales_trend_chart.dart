import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/entities/reporting_shared.dart';

/// 14-day daily-total line chart — `salesTrend` from the dashboard response,
/// already zero-filled/gap-free per day server-side.
class SalesTrendChart extends StatelessWidget {
  const SalesTrendChart({super.key, required this.points, required this.currency});

  final List<TrendPoint> points;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final maxY = points.map((p) => p.total).fold<double>(0, (a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Savdo dinamikasi (14 kun)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: points.every((p) => p.total == 0)
                  ? Center(
                      child: Text("Ma'lumot yo'q", style: TextStyle(color: Theme.of(context).hintColor)),
                    )
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
                            spots: [
                              for (var i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i].total),
                            ],
                            isCurved: true,
                            color: scheme.primary,
                            barWidth: 2.5,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(show: true, color: scheme.primary.withValues(alpha: 0.12)),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: const Duration(milliseconds: 100));
  }
}
