import 'package:flutter/material.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// Marks a "Maxsus mijoz" — a customer who always buys at the retail price.
class SpecialCustomerTag extends StatelessWidget {
  const SpecialCustomerTag({super.key});

  @override
  Widget build(BuildContext context) {
    return DashTag(label: '★ ${context.l10n.specialBadge}', color: BrandColors.of(context).accentText);
  }
}
