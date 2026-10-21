import 'package:flutter/material.dart';

import 'package:bsmart/core/enums/sale_enums.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// Tinted status pill (Phase 9).
class DebtStatusBadge extends StatelessWidget {
  const DebtStatusBadge({super.key, required this.status});

  final DebtStatus status;

  @override
  Widget build(BuildContext context) {
    final error = Theme.of(context).colorScheme.error;
    final color = switch (status) {
      DebtStatus.active || DebtStatus.overdue => error,
      DebtStatus.partial => BrandColors.of(context).accentText,
      DebtStatus.settled => AppColors.success,
      DebtStatus.writtenOff => BrandColors.of(context).textMuted,
    };
    return DashTag(label: status.label, color: color);
  }
}
