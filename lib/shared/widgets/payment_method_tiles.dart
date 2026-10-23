import 'package:flutter/material.dart';

import 'package:bsmart/core/enums/payment_method.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';

/// One selectable tile per immediate payment method (cash, card, …), three
/// per row; the selected one is yellow. POS checkout and debt payments.
class PaymentMethodTiles extends StatelessWidget {
  const PaymentMethodTiles({required this.selected, required this.onSelected, this.onSheet = false, super.key});

  final PaymentMethod selected;
  final ValueChanged<PaymentMethod> onSelected;

  /// On a white sheet: unselected tiles use the recessed fill.
  final bool onSheet;

  static IconData _icon(PaymentMethod m) => switch (m) {
    PaymentMethod.cash => Icons.payments_rounded,
    PaymentMethod.card => Icons.credit_card_rounded,
    PaymentMethod.bankTransfer => Icons.account_balance_rounded,
    PaymentMethod.click => Icons.touch_app_rounded,
    PaymentMethod.payme => Icons.phone_iphone_rounded,
    PaymentMethod.debt => Icons.receipt_long_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 8.0;
        final width = (constraints.maxWidth - 2 * gap) / 3;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final m in PaymentMethod.immediateMethods)
              SizedBox(
                width: width,
                child: Semantics(
                  selected: m == selected,
                  button: true,
                  child: Material(
                    color: m == selected
                        ? AppColors.brandYellow
                        : onSheet
                        ? BrandColors.of(context).field
                        : DashColors.card(context),
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: () => onSelected(m),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                        child: Column(
                          children: [
                            Icon(_icon(m), color: m == selected ? AppColors.onBrand : colors.textPrimary),
                            const SizedBox(height: 4),
                            Text(
                              m.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: m == selected ? AppColors.onBrand : colors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
