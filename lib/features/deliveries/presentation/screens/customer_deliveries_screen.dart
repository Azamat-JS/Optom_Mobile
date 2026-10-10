import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/features/auth/presentation/widgets/verify_phone_banner.dart';
import 'package:bsmart/features/deliveries/domain/entities/delivery.dart';
import 'package:bsmart/features/deliveries/presentation/providers/customer_deliveries_notifier.dart';
import 'package:bsmart/features/deliveries/presentation/screens/delivery_tracking_screen.dart';
import 'package:bsmart/features/deliveries/presentation/widgets/delivery_status_badge.dart';
import 'package:bsmart/core/l10n/l10n.dart';

/// CUSTOMER "Yetkazishlarim" (Phase 6 V5): storefront deliveries plus
/// restaurant deliveries ordered by phone/in person for the user's verified
/// number. Tapping one opens the live [DeliveryTrackingScreen] (T7).
class CustomerDeliveriesScreen extends ConsumerWidget {
  const CustomerDeliveriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deliveries = ref.watch(customerDeliveriesProvider);
    final notifier = ref.read(customerDeliveriesProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Yetkazishlarim')),
      body: RefreshIndicator(
        onRefresh: notifier.refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            VerifyPhoneBanner(message: context.l10n.verifyBannerDeliveries),
            ...deliveries.when(
              loading: () => const [
                Padding(
                  padding: EdgeInsets.only(top: 96),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
              error: (error, _) => [
                Padding(
                  padding: const EdgeInsets.only(top: 96),
                  child: Center(child: Text('Xatolik: $error', textAlign: TextAlign.center)),
                ),
              ],
              data: (items) => items.isEmpty
                  ? const [
                      Padding(
                        padding: EdgeInsets.fromLTRB(24, 96, 24, 0),
                        child: Text('Hozircha yetkazishlar yo‘q', textAlign: TextAlign.center),
                      ),
                    ]
                  : [for (final d in items) _DeliveryTile(delivery: d)],
            ),
          ],
        ),
      ),
    );
  }
}

class _DeliveryTile extends StatelessWidget {
  const _DeliveryTile({required this.delivery});

  final Delivery delivery;

  @override
  Widget build(BuildContext context) {
    final d = delivery;
    final eta = d.eta;
    final subtitle = [
      if (d.source == DeliverySource.restaurantOrder) 'Restoran buyurtmasi',
      d.label,
      if (d.status.isActive && eta != null) '~${(eta.seconds / 60).ceil()} daqiqa',
    ].join(' · ');
    return ListTile(
      leading: Icon(
        d.status.isActive ? Icons.delivery_dining : Icons.inventory_2_outlined,
        color: d.status.isActive ? Theme.of(context).colorScheme.primary : null,
      ),
      title: Text(d.storeName ?? 'Yetkazish'),
      subtitle: Text(subtitle),
      trailing: DeliveryStatusBadge(status: d.status),
      onTap: () =>
          Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => DeliveryTrackingScreen(deliveryId: d.id))),
    );
  }
}
