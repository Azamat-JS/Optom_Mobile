import 'package:flutter/material.dart';

import 'package:bsmart/core/enums/order_status.dart';

class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (background, foreground) = switch (status) {
      OrderStatus.newOrder => (scheme.primaryContainer, scheme.onPrimaryContainer),
      OrderStatus.approved => (Colors.blue.shade100, Colors.blue.shade900),
      OrderStatus.rejected => (scheme.errorContainer, scheme.onErrorContainer),
      OrderStatus.delivered => (Colors.green.shade100, Colors.green.shade900),
      OrderStatus.debtRecorded => (Colors.orange.shade100, Colors.orange.shade900),
      OrderStatus.paid => (Colors.green.shade100, Colors.green.shade900),
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
