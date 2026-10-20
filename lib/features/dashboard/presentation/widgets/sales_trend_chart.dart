import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:bsmart/core/entities/reporting_shared.dart';
import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/shared/widgets/brand_line_chart.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';

/// 14-day daily-total line chart — `salesTrend` from the dashboard response,
/// already zero-filled/gap-free per day server-side. Shows the window's
/// total above the line (the Stripe "Gross volume" card).
class SalesTrendChart extends StatelessWidget {
  const SalesTrendChart({super.key, required this.points, required this.currency});

  final List<TrendPoint> points;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    final total = points.fold<double>(0, (sum, p) => sum + p.total);
    final range = points.isEmpty
        ? ''
        : '${BrandLineChart.shortDate(points.first.date)} – ${BrandLineChart.shortDate(points.last.date)}';
    return DashCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.dashSalesTrend14d,
            style: TextStyle(color: colors.textSecondary, fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              CurrencyFormatter.format(total, currency),
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          Text(
            range,
            style: TextStyle(color: colors.textMuted, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 14),
          BrandLineChart(points: [for (final p in points) (date: p.date, amount: p.total)], currency: currency),
        ],
      ),
    ).animate().fadeIn(delay: const Duration(milliseconds: 100));
  }
}
