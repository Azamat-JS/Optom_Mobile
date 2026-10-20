import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:bsmart/core/entities/reporting_shared.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';

/// Share of payment methods (cash / card / bank / debt) as a donut.
class PaymentBreakdownChart extends StatelessWidget {
  const PaymentBreakdownChart({super.key, required this.breakdown});

  final PaymentBreakdown breakdown;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    final l10n = context.l10n;
    final entries = <(String, double, Color)>[
      (l10n.dashPaymentCash, breakdown.cash, colors.success),
      (l10n.dashPaymentCard, breakdown.card, AppColors.brandAmber),
      (l10n.dashPaymentBank, breakdown.bankTransfer, const Color(0xFF4C6FD6)),
      (l10n.dashPaymentDebt, breakdown.debt, Theme.of(context).colorScheme.error),
    ];
    final total = breakdown.total;

    return DashCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.dashPaymentTypes,
            style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          if (total == 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  l10n.commonNoData,
                  style: TextStyle(color: colors.textMuted, fontWeight: FontWeight.w600),
                ),
              ),
            )
          else
            Row(
              children: [
                SizedBox(
                  height: 124,
                  width: 124,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 34,
                      sections: [
                        for (final entry in entries)
                          if (entry.$2 > 0)
                            PieChartSectionData(value: entry.$2, color: entry.$3, showTitle: false, radius: 24),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final entry in entries)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(color: entry.$3, borderRadius: BorderRadius.circular(3)),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  entry.$1,
                                  style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w600),
                                ),
                              ),
                              Text(
                                '${(entry.$2 / total * 100).toStringAsFixed(0)}%',
                                style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w800),
                              ),
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
    ).animate().fadeIn(delay: const Duration(milliseconds: 150));
  }
}
