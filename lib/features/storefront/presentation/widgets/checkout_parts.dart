import 'package:flutter/material.dart';

import 'package:bsmart/core/theme/brand_theme.dart';

// The bill row and dashed divider moved to the shared operator kit (POS uses them too).
export 'package:bsmart/shared/widgets/dash_kit.dart' show BillRow, DashedDivider;

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
