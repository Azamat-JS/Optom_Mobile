import 'package:flutter/material.dart';

import 'package:bsmart/core/enums/sale_enums.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/brand_theme.dart';

/// Tinted pill (Phase 9): the colour at 14% behind the same colour's text,
/// so it reads in light and dark mode alike.
class _TintPill extends StatelessWidget {
  const _TintPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(20)),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12.5, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class SaleStatusBadge extends StatelessWidget {
  const SaleStatusBadge({super.key, required this.status});

  final SaleStatus status;

  @override
  Widget build(BuildContext context) {
    final error = Theme.of(context).colorScheme.error;
    final color = switch (status) {
      SaleStatus.completed => AppColors.success,
      SaleStatus.partiallyReturned => BrandColors.of(context).accentText,
      SaleStatus.cancelled || SaleStatus.returned => error,
    };
    return _TintPill(label: status.label, color: color);
  }
}

class SaleTypeBadge extends StatelessWidget {
  const SaleTypeBadge({super.key, required this.type});

  final SaleType type;

  @override
  Widget build(BuildContext context) {
    final color = switch (type) {
      SaleType.paid => AppColors.success,
      SaleType.debt => BrandColors.of(context).accentText,
    };
    return _TintPill(label: type.label, color: color);
  }
}
