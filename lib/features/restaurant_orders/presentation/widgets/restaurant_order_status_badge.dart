import 'package:flutter/material.dart';

import 'package:bsmart/core/enums/restaurant_order_enums.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// Tinted status pill (Phase 9).
class RestaurantOrderStatusBadge extends StatelessWidget {
  const RestaurantOrderStatusBadge({super.key, required this.status});

  final RestaurantOrderStatus status;

  /// Shared with the board rows' icon tint.
  static Color colorOf(BuildContext context, RestaurantOrderStatus status) => switch (status) {
    RestaurantOrderStatus.newOrder => BrandColors.of(context).accentText,
    RestaurantOrderStatus.preparing => const Color(0xFFD9822B),
    RestaurantOrderStatus.ready => const Color(0xFF3D6FD6),
    RestaurantOrderStatus.served || RestaurantOrderStatus.delivered => AppColors.success,
    RestaurantOrderStatus.cancelled => Theme.of(context).colorScheme.error,
  };

  @override
  Widget build(BuildContext context) => DashTag(label: status.label, color: colorOf(context, status));
}
