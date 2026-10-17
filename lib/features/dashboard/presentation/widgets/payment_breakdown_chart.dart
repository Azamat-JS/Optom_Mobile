import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/entities/reporting_shared.dart';

class PaymentBreakdownChart extends StatelessWidget {
  const PaymentBreakdownChart({super.key, required this.breakdown});

  final PaymentBreakdown breakdown;

  @override
  Widget build(BuildContext context) {
    final entries = <(String, double, Color)>[
      (context.l10n.dashPaymentCash, breakdown.cash, const Color(0xFF2E7D5B)),
      (context.l10n.dashPaymentCard, breakdown.card, const Color(0xFF3B82C4)),
      (context.l10n.dashPaymentBank, breakdown.bankTransfer, const Color(0xFFC47F3B)),
      (context.l10n.dashPaymentDebt, breakdown.debt, const Color(0xFFB4443B)),
    ];
    final total = breakdown.total;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.dashPaymentTypes, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (total == 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text(context.l10n.commonNoData, style: TextStyle(color: Theme.of(context).hintColor))),
              )
            else
              Row(
                children: [
                  SizedBox(
                    height: 120,
                    width: 120,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 28,
                        sections: [
                          for (final entry in entries)
                            if (entry.$2 > 0)
                              PieChartSectionData(
                                value: entry.$2,
                                color: entry.$3,
                                showTitle: false,
                                radius: 22,
                              ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final entry in entries)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              children: [
                                Container(width: 10, height: 10, color: entry.$3),
                                const SizedBox(width: 8),
                                Expanded(child: Text(entry.$1)),
                                Text('${(entry.$2 / total * 100).toStringAsFixed(0)}%'),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: const Duration(milliseconds: 150));
  }
}
