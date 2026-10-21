import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/features/deliveries/domain/entities/delivery.dart';
import 'package:bsmart/features/deliveries/presentation/delivery_actions.dart';
import 'package:bsmart/features/deliveries/presentation/providers/courier_deliveries_notifier.dart';
import 'package:bsmart/features/deliveries/presentation/screens/courier_delivery_screen.dart';
import 'package:bsmart/features/deliveries/presentation/widgets/delivery_status_badge.dart';
import 'package:bsmart/features/tracking/presentation/providers/tracking_notifier.dart';
import 'package:bsmart/features/tracking/presentation/tracking_actions.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

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
      color: AppColors.onBrand,
      backgroundColor: AppColors.brandYellow,
      onRefresh: () => ref.read(courierDeliveriesProvider.notifier).refresh(),
      child: deliveries.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => DashEmptyState(icon: Icons.cloud_off_rounded, text: context.l10n.commonErrorWith('$e')),
        data: (items) {
          final active = items.where((d) => d.status.isActive).toList();
          final offers = items.where((d) => d.status.isOffer).toList();
          if (items.isEmpty) {
            return const DashEmptyState(icon: Icons.moped_rounded, text: "Hozircha yetkazish yo'q");
          }
          var i = 0;
          Widget animated(Widget child) => child
              .animate(delay: AppMotion.fast * 0.3 * (i++))
              .fadeIn(duration: AppMotion.standard)
              .slideY(begin: 0.08, curve: AppMotion.emphasized);
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              if (!online && active.isNotEmpty)
                animated(_GoOnlineBanner(customerWatches: active.any((d) => d.source == DeliverySource.order))),
              if (active.isNotEmpty)
                const DashSectionTitle('Faol yetkazishlar', padding: EdgeInsets.fromLTRB(4, 14, 4, 10)),
              for (final d in active) animated(_DeliveryCard(delivery: d)),
              if (offers.isNotEmpty)
                const DashSectionTitle('Yangi takliflar', padding: EdgeInsets.fromLTRB(4, 14, 4, 10)),
              for (final d in offers) animated(_DeliveryCard(delivery: d)),
            ],
          );
        },
      ),
    );
  }
}

class _GoOnlineBanner extends ConsumerWidget {
  const _GoOnlineBanner({required this.customerWatches});

  /// Restaurant customers have no account, so only B2C deliveries have a customer watching.
  final bool customerWatches;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = BrandColors.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.brandYellow.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(Icons.location_off_rounded, color: colors.accentText),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Faol yetkazish bor',
                  style: TextStyle(color: colors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800),
                ),
                Text(
                  "${customerWatches ? 'Mijoz va biznes egangiz' : 'Biznes egangiz'} sizni xaritada ko'rishi uchun onlayn bo'ling.",
                  style: TextStyle(color: colors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(onPressed: () => TrackingActions.goOnline(context, ref), child: const Text('Onlayn')),
        ],
      ),
    );
  }
}

class _DeliveryCard extends ConsumerWidget {
  const _DeliveryCard({required this.delivery});

  final Delivery delivery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = BrandColors.of(context);
    final tint = DeliveryStatusBadge.colorOf(delivery.status, Theme.of(context).colorScheme);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DashCard(
        onTap: () => CourierDeliveriesTab.open(context, delivery),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: tint.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.moped_rounded, color: tint),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    delivery.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 8),
                DeliveryStatusBadge(status: delivery.status),
              ],
            ),
            const SizedBox(height: 12),
            if (delivery.storeName != null) _Line(icon: Icons.storefront_rounded, text: delivery.storeName!),
            _Line(icon: Icons.place_rounded, text: delivery.dropoffAddress ?? "Manzil ko'rsatilmagan"),
            if (delivery.customerName != null) _Line(icon: Icons.person_rounded, text: delivery.customerName!),
            if (delivery.status.isOffer) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () async {
                    // Capture the navigator first: on success this card moves to the "Faol"
                    // section, so its own context is disposed by the time accept returns.
                    final navigator = Navigator.of(context);
                    if (await DeliveryActions.accept(context, ref, delivery)) {
                      navigator.push(MaterialPageRoute(builder: (_) => CourierDeliveryScreen(deliveryId: delivery.id)));
                    }
                  },
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Qabul qilish'),
                ),
              ),
            ],
          ],
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
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colors.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: colors.textSecondary, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
