import 'package:flutter/material.dart';

import 'package:bsmart/core/theme/brand_theme.dart';

/// White rounded card on the grey cart/checkout page (raised grey in dark mode).
class CheckoutCard extends StatelessWidget {
  const CheckoutCard({required this.child, required this.padding, this.onTap, super.key});

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: dark ? colors.field : Colors.white,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// "Label ........ value" row of a bill card.
class BillRow extends StatelessWidget {
  const BillRow({required this.label, required this.value, this.strong = false, this.muted = false, super.key});

  final String label;
  final String value;
  final bool strong;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    final style = TextStyle(
      color: muted ? colors.textSecondary : colors.textPrimary,
      fontSize: strong ? 17 : 15.5,
      fontWeight: strong ? FontWeight.w800 : FontWeight.w500,
    );
    // Label takes the free space; the value hugs the right edge and wraps
    // inside at most 60% of the row.
    return LayoutBuilder(
      builder: (context, constraints) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: style)),
          const SizedBox(width: 12),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.6),
            child: Text(value, textAlign: TextAlign.right, style: style),
          ),
        ],
      ),
    );
  }
}

/// Dashed hairline between bill sections.
class DashedDivider extends StatelessWidget {
  const DashedDivider({required this.color, super.key});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = (constraints.maxWidth / 9).floor();
        return Row(
          children: [
            for (var i = 0; i < count; i++)
              Container(width: 5, height: 1.2, margin: const EdgeInsets.only(right: 4), color: color),
          ],
        );
      },
    );
  }
}
