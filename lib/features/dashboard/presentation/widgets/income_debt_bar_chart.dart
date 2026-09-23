import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:bsmart/core/entities/reporting_shared.dart';

/// Last-6-months income-vs-debt grouped bar chart.
class IncomeDebtBarChart extends StatelessWidget {
  const IncomeDebtBarChart({super.key, required this.points});

  final List<IncomeDebtPoint> points;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final maxY = points
        .map((p) => p.income > p.debt ? p.income : p.debt)
        .fold<double>(0, (a, b) => a > b ? a : b);
    final hasData = points.any((p) => p.income > 0 || p.debt > 0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Daromad va qarz (6 oy)', style: Theme.of(context).textTheme.titleMedium),
                Row(
                  children: [
                    _legendDot(scheme.primary, 'Daromad'),
                    const SizedBox(width: 12),
                    _legendDot(scheme.error, 'Qarz'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: !hasData
                  ? Center(child: Text("Ma'lumot yo'q", style: TextStyle(color: Theme.of(context).hintColor)))
                  : BarChart(
                      BarChartData(
                        maxY: maxY == 0 ? 1 : maxY * 1.2,
                        gridData: const FlGridData(show: true, drawVerticalLine: false),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < 0 || index >= points.length) return const SizedBox.shrink();
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(points[index].month, style: Theme.of(context).textTheme.bodySmall),
                                );
                              },
                            ),
                          ),
                        ),
                        barGroups: [
                          for (var i = 0; i < points.length; i++)
                            BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(toY: points[i].income, color: scheme.primary, width: 8),
                                BarChartRodData(toY: points[i].debt, color: scheme.error, width: 8),
                              ],
                            ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: const Duration(milliseconds: 200));
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
