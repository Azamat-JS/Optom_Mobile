import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

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

    return DashPage(
      title: context.l10n.profileMyDeliveries,
      body: RefreshIndicator(
        color: AppColors.onBrand,
        backgroundColor: AppColors.brandYellow,
        onRefresh: notifier.refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
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
                  child: Center(child: Text(context.l10n.commonErrorWith('$error'), textAlign: TextAlign.center)),
                ),
              ],
              data: (items) => items.isEmpty
                  ? [
                      Padding(
                        padding: const EdgeInsets.only(top: 80),
                        child: Column(
                          children: [
                            Container(
                              width: 76,
                              height: 76,
                              decoration: BoxDecoration(color: DashColors.card(context), shape: BoxShape.circle),
                              child: Icon(Icons.moped_rounded, size: 36, color: BrandColors.of(context).textMuted),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              context.l10n.dlvNone,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: BrandColors.of(context).textSecondary,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]
                  : [
                      for (final d in items) ...[const SizedBox(height: 10), _DeliveryTile(delivery: d)],
                    ],
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
    final tint = DeliveryStatusBadge.colorOf(d.status, Theme.of(context).colorScheme);
    final subtitle = [
      if (d.source == DeliverySource.restaurantOrder) context.l10n.dlvRestaurantOrder,
      d.label,
      if (d.status.isActive && eta != null) context.l10n.dlvMinutesLong('${(eta.seconds / 60).ceil()}'),
    ].join(' · ');
    return DashListCard(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(color: tint.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(14)),
        child: Icon(d.status.isActive ? Icons.moped_rounded : Icons.inventory_2_rounded, color: tint),
      ),
      title: d.storeName ?? context.l10n.dlvLabelFallback,
      subtitle: subtitle,
      trailing: DeliveryStatusBadge(status: d.status),
      onTap: () =>
          Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => DeliveryTrackingScreen(deliveryId: d.id))),
    );
  }
}
