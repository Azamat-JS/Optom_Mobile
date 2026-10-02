import 'package:flutter/material.dart';

import 'package:bsmart/features/deliveries/domain/entities/delivery.dart';

class DeliveryStatusBadge extends StatelessWidget {
  const DeliveryStatusBadge({super.key, required this.status});

  final DeliveryStatus status;

  static Color colorOf(DeliveryStatus status, ColorScheme scheme) => switch (status) {
        DeliveryStatus.pending || DeliveryStatus.assigned => const Color(0xFFF9A825),
        DeliveryStatus.accepted => scheme.primary,
        DeliveryStatus.pickedUp || DeliveryStatus.arrived => const Color(0xFF1565C0),
        DeliveryStatus.delivered => const Color(0xFF2E7D32),
        DeliveryStatus.cancelled => scheme.error,
      };

  @override
  Widget build(BuildContext context) {
    final color = colorOf(status, Theme.of(context).colorScheme);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(status.label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
