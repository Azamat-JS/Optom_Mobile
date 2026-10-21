import 'package:flutter/material.dart';

import 'package:bsmart/core/enums/order_status.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// Tinted status pill (Phase 9).
class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({super.key, required this.status});

  final OrderStatus status;

  /// Shared with the order rows' icon tint.
  static Color colorOf(BuildContext context, OrderStatus status) => switch (status) {
    OrderStatus.newOrder => BrandColors.of(context).accentText,
    OrderStatus.approved => const Color(0xFF3D6FD6),
    OrderStatus.rejected => Theme.of(context).colorScheme.error,
    OrderStatus.delivered || OrderStatus.paid => AppColors.success,
    OrderStatus.debtRecorded => const Color(0xFFD9822B),
  };

  @override
  Widget build(BuildContext context) => DashTag(label: status.label, color: colorOf(context, status));
}
