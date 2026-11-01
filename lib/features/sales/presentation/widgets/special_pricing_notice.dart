import 'package:flutter/material.dart';

import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/products/domain/entities/product.dart';
import 'package:bsmart/features/sales/domain/pricing/special_pricing.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';

/// Shown once a special customer ("Maxsus mijoz") is chosen: how much cheaper the retail prices
/// make it, and which lines have no retail price. With [hint], a single sentence instead of totals.
class SpecialPricingNotice extends StatelessWidget {
  const SpecialPricingNotice({this.lines = const [], this.currency = Currency.uzs, this.hint, super.key});

  /// (product, quantity) of each product line.
  final List<(Product, double)> lines;
  final Currency currency;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final withRetail = [
      for (final (product, quantity) in lines)
        if (retailPriceOf(product) != null) (product, quantity),
    ];
    final saving = withRetail.fold<double>(0, (sum, line) => sum + line.$2 * (line.$1.price - retailPriceOf(line.$1)!));
    final noRetail = lines.length - withRetail.length;
    final body = TextStyle(color: colors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600);

    return DashCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.star_rounded, color: colors.accentText),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.specialAppliedTitle,
                  style: TextStyle(color: colors.textPrimary, fontSize: 14.5, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                if (hint != null)
                  Text(hint!, style: body)
                else
                  Text(
                    saving > 0
                        ? l10n.specialAppliedSaving(withRetail.length, CurrencyFormatter.format(saving, currency))
                        : l10n.specialAppliedNoSaving,
                    style: body,
                  ),
                if (noRetail > 0) Text(l10n.specialNoRetail(noRetail), style: body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
