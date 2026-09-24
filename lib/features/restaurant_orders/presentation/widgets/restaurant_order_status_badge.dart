import 'package:flutter/material.dart';

import 'package:bsmart/core/enums/restaurant_order_enums.dart';

class RestaurantOrderStatusBadge extends StatelessWidget {
  const RestaurantOrderStatusBadge({super.key, required this.status});

  final RestaurantOrderStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (background, foreground) = switch (status) {
      RestaurantOrderStatus.newOrder => (scheme.primaryContainer, scheme.onPrimaryContainer),
      RestaurantOrderStatus.preparing => (Colors.orange.shade100, Colors.orange.shade900),
      RestaurantOrderStatus.ready => (Colors.blue.shade100, Colors.blue.shade900),
      RestaurantOrderStatus.served => (Colors.green.shade100, Colors.green.shade900),
      RestaurantOrderStatus.delivered => (Colors.green.shade100, Colors.green.shade900),
      RestaurantOrderStatus.cancelled => (scheme.errorContainer, scheme.onErrorContainer),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(6)),
      child: Text(
        status.label,
        style: TextStyle(color: foreground, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
