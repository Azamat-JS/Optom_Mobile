import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/features/deliveries/domain/entities/delivery.dart';
import 'package:bsmart/features/deliveries/presentation/providers/order_delivery_notifier.dart';
import 'package:bsmart/features/deliveries/presentation/screens/delivery_tracking_screen.dart';
import 'package:bsmart/features/deliveries/presentation/widgets/delivery_status_badge.dart';

/// Courier-delivery summary on an order's detail screen, with "Kuryerni
/// kuzatish" while the courier is on the way. Renders nothing for an order
/// without a delivery.
class OrderDeliveryCard extends ConsumerWidget {
  const OrderDeliveryCard({super.key, required this.orderId});

  final String orderId;

  static String headline(DeliveryStatus status) => switch (status) {
        DeliveryStatus.pending => 'Kuryer qidirilmoqda',
        DeliveryStatus.assigned => 'Kuryer tayinlandi, tasdiqlashini kutmoqda',
        DeliveryStatus.accepted => "Kuryer do'konga bormoqda",
        DeliveryStatus.pickedUp => "Kuryer yo'lda",
        DeliveryStatus.arrived => 'Kuryer yetib keldi!',
        DeliveryStatus.delivered => 'Buyurtma topshirildi',
        DeliveryStatus.cancelled => 'Yetkazish bekor qilindi',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final delivery = ref.watch(orderDeliveryProvider(orderId)).valueOrNull;
    if (delivery == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final trackable = delivery.status.isActive;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.delivery_dining, color: theme.colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(child: Text(headline(delivery.status), style: theme.textTheme.titleSmall)),
                  DeliveryStatusBadge(status: delivery.status),
                ],
              ),
              if (delivery.courier != null) ...[
                const SizedBox(height: 6),
                Text('Kuryer: ${delivery.courier!.firstName}', style: theme.textTheme.bodyMedium),
              ],
              if (trackable) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => DeliveryTrackingScreen(deliveryId: delivery.id)),
                    ),
                    icon: const Icon(Icons.map_outlined),
                    label: const Text('Kuryerni kuzatish'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: AppMotion.standard).slideY(begin: 0.1, curve: AppMotion.emphasized);
  }
}
