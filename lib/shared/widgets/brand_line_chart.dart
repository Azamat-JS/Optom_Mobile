import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';

/// One value per day for [BrandLineChart]; [date] is `YYYY-MM-DD`.
typedef DailyAmount = ({String date, double amount});

/// Daily amounts as a smooth yellow line with a fading fill (the Stripe /
/// Revolut references). Tapping shows the day and amount in a dark pill;
/// the first, middle and last dates label the x axis.
class BrandLineChart extends StatelessWidget {
  const BrandLineChart({required this.points, required this.currency, this.height = 190, super.key});

  final List<DailyAmount> points;
  final Currency currency;
  final double height;

  static String shortDate(String iso) {
    final parts = iso.split('T').first.split('-');
    return parts.length == 3 ? '${parts[2]}.${parts[1]}' : iso;
  }

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    final maxY = points.map((p) => p.amount).fold<double>(0, (a, b) => a > b ? a : b);
    if (points.isEmpty || maxY == 0) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            context.l10n.commonNoData,
            style: TextStyle(color: colors.textMuted, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }
    final last = points.length - 1;
    final labelled = {0, last ~/ 2, last};
    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY * 1.25,
          minX: 0,
          maxX: last.toDouble(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY * 1.25 / 4,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: colors.outline.withValues(alpha: 0.6), strokeWidth: 1, dashArray: [4, 4]),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: const AxisTitles(),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 26,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final i = value.round();
                  if (value != i.toDouble() || !labelled.contains(i)) return const SizedBox.shrink();
                  // Edge labels are centred on the first/last point; shift
                  // them inward so they stay inside the card.
                  final shift = i == 0 ? 14.0 : (i == last ? -14.0 : 0.0);
                  return Padding(
                    padding: EdgeInsets.only(
                      top: 8,
                      left: shift > 0 ? shift * 2 : 0,
                      right: shift < 0 ? -shift * 2 : 0,
                    ),
                    child: Text(
                      shortDate(points[i].date),
                      style: TextStyle(color: colors.textMuted, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppColors.ink,
              tooltipRoundedRadius: 10,
              tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              getTooltipItems: (spots) => [
                for (final s in spots)
                  LineTooltipItem(
                    '${shortDate(points[s.x.round()].date)}\n',
                    TextStyle(
                      fontFamily: BrandTheme.fontFamily,
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 11,
                    ),
                    children: [
                      TextSpan(
                        text: CurrencyFormatter.format(s.y, currency),
                        style: const TextStyle(
                          fontFamily: BrandTheme.fontFamily,
                          color: AppColors.brandYellow,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            getTouchedSpotIndicator: (bar, indexes) => [
              for (final _ in indexes)
                TouchedSpotIndicatorData(
                  FlLine(color: colors.textMuted, strokeWidth: 1, dashArray: [3, 3]),
                  FlDotData(
                    getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                      radius: 5,
                      color: AppColors.brandYellow,
                      strokeWidth: 2.5,
                      strokeColor: AppColors.ink,
                    ),
                  ),
                ),
            ],
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [for (var i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i].amount)],
              isCurved: true,
              curveSmoothness: 0.25,
              preventCurveOverShooting: true,
              color: AppColors.brandAmber,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.brandYellow.withValues(alpha: 0.35), AppColors.brandYellow.withValues(alpha: 0)],
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 400),
      ),
    );
  }
}
