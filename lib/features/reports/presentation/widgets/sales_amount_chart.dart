import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/features/reports/domain/entities/sales_chart_result.dart';
import 'package:bsmart/shared/widgets/brand_line_chart.dart';

/// Day-by-day revenue line for the Reports hub's selectable-period
/// `/reports/sales-chart` — a single `{date, amount}` series (unlike the
/// dashboard's fixed 14-day `SalesTrendChart`, which breaks totals down by
/// payment method). Both draw through [BrandLineChart].
class SalesAmountChart extends StatelessWidget {
  const SalesAmountChart({super.key, required this.points, this.currency = Currency.uzs});

  final List<AmountPoint> points;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    return BrandLineChart(
      points: [for (final p in points) (date: p.date, amount: p.amount)],
      currency: currency,
    ).animate().fadeIn(delay: const Duration(milliseconds: 100));
  }
}
