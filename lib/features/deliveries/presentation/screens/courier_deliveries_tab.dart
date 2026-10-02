import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/features/deliveries/domain/entities/delivery.dart';
import 'package:bsmart/features/deliveries/presentation/delivery_actions.dart';
import 'package:bsmart/features/deliveries/presentation/providers/courier_deliveries_notifier.dart';
import 'package:bsmart/features/deliveries/presentation/screens/courier_delivery_screen.dart';
import 'package:bsmart/features/deliveries/presentation/widgets/delivery_status_badge.dart';
import 'package:bsmart/features/tracking/presentation/providers/tracking_notifier.dart';
import 'package:bsmart/features/tracking/presentation/tracking_actions.dart';

/// The courier's "Yetkazishlar": active deliveries first, then open offers.
class CourierDeliveriesTab extends ConsumerWidget {
  const CourierDeliveriesTab({super.key});

  static void open(BuildContext context, Delivery delivery) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => CourierDeliveryScreen(deliveryId: delivery.id)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deliveries = ref.watch(courierDeliveriesProvider);
    final online = ref.watch(trackingNotifierProvider.select((t) => t.isOnline));

    return RefreshIndicator(
      onRefresh: () => ref.read(courierDeliveriesProvider.notifier).refresh(),
      child: deliveries.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [Padding(padding: const EdgeInsets.all(24), child: Text('Xatolik: $e', textAlign: TextAlign.center))],
        ),
        data: (items) {
          final active = items.where((d) => d.status.isActive).toList();
          final offers = items.where((d) => d.status.isOffer).toList();
          if (items.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 80),
                Icon(Icons.inventory_2_outlined, size: 56),
                SizedBox(height: 12),
                Text('Hozircha yetkazish yo\'q', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
              ],
            );
          }
          var i = 0;
          Widget animated(Widget child) => child
              .animate(delay: AppMotion.fast * 0.3 * (i++))
              .fadeIn(duration: AppMotion.standard)
              .slideY(begin: 0.08, curve: AppMotion.emphasized);
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
            children: [
              if (!online && active.isNotEmpty)
                animated(_GoOnlineBanner(customerWatches: active.any((d) => d.source == DeliverySource.order))),
              if (active.isNotEmpty) const _SectionTitle('Faol yetkazishlar'),
              for (final d in active) animated(_DeliveryCard(delivery: d)),
              if (offers.isNotEmpty) const _SectionTitle('Yangi takliflar'),
              for (final d in offers) animated(_DeliveryCard(delivery: d)),
            ],
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
        child: Text(text, style: Theme.of(context).textTheme.titleSmall),
      );
}

class _GoOnlineBanner extends ConsumerWidget {
  const _GoOnlineBanner({required this.customerWatches});

  /// Restaurant customers have no account, so only B2C deliveries have a customer watching.
  final bool customerWatches;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.tertiaryContainer,
      child: ListTile(
        leading: Icon(Icons.location_off_outlined, color: scheme.onTertiaryContainer),
        title: const Text('Faol yetkazish bor'),
        subtitle: Text(
          "${customerWatches ? 'Mijoz va biznes egangiz' : 'Biznes egangiz'} sizni xaritada ko'rishi uchun onlayn bo'ling.",
        ),
        trailing: FilledButton(onPressed: () => TrackingActions.goOnline(context, ref), child: const Text('Onlayn')),
      ),
    );
  }
}

class _DeliveryCard extends ConsumerWidget {
  const _DeliveryCard({required this.delivery});

  final Delivery delivery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => CourierDeliveriesTab.open(context, delivery),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(delivery.label, style: theme.textTheme.titleMedium)),
                  DeliveryStatusBadge(status: delivery.status),
                ],
              ),
              const SizedBox(height: 8),
              if (delivery.storeName != null)
                _Line(icon: Icons.storefront_outlined, text: delivery.storeName!),
              _Line(icon: Icons.place_outlined, text: delivery.dropoffAddress ?? 'Manzil ko\'rsatilmagan'),
              if (delivery.customerName != null) _Line(icon: Icons.person_outline, text: delivery.customerName!),
              if (delivery.status.isOffer) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () async {
                      // Capture the navigator first: on success this card moves to the "Faol"
                      // section, so its own context is disposed by the time accept returns.
                      final navigator = Navigator.of(context);
                      if (await DeliveryActions.accept(context, ref, delivery)) {
                        navigator.push(
                          MaterialPageRoute(builder: (_) => CourierDeliveryScreen(deliveryId: delivery.id)),
                        );
                      }
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Qabul qilish'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(child: Text(text)),
          ],
        ),
      );
}
