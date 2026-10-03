import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/features/deliveries/domain/entities/delivery.dart';
import 'package:bsmart/features/deliveries/domain/usecases/manage_delivery_usecases.dart';
import 'package:bsmart/features/deliveries/presentation/delivery_actions.dart';
import 'package:bsmart/features/deliveries/presentation/providers/order_delivery_notifier.dart';
import 'package:bsmart/features/deliveries/presentation/screens/delivery_tracking_screen.dart';
import 'package:bsmart/features/deliveries/presentation/widgets/assign_courier_sheet.dart';
import 'package:bsmart/features/deliveries/presentation/widgets/delivery_status_badge.dart';

/// Courier-delivery summary on an order's detail screen, with "Kuryerni
/// kuzatish" while the courier is on the way.
///
/// For the seller's staff ([canManage]) it is also where deliveries are
/// managed: "Kuryerga berish" (assign one courier or offer to all), change
/// courier / cancel before acceptance, and re-assign after a cancel. Without
/// [canManage] it renders nothing for an order without a delivery.
class OrderDeliveryCard extends ConsumerWidget {
  const OrderDeliveryCard({super.key, required this.orderId, this.canManage = false, this.canAssign = false});

  final String orderId;

  /// Viewer is the selling business's staff and the order is B2C.
  final bool canManage;

  /// The order is APPROVED (a delivery can be created/reopened).
  final bool canAssign;

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
    final theme = Theme.of(context);
    if (delivery == null) {
      if (!canManage || !canAssign) return const SizedBox.shrink();
      return _shell(
        child: Row(
          children: [
            Icon(Icons.delivery_dining, color: theme.colorScheme.primary),
            const SizedBox(width: 10),
            const Expanded(child: Text('Kuryer biriktirilmagan')),
            FilledButton.icon(
              onPressed: () => _assign(context, ref, null),
              icon: const Icon(Icons.moped_outlined),
              label: const Text('Kuryerga berish'),
            ),
          ],
        ),
      );
    }
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
              if (canManage && delivery.status.isOffer) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _assign(context, ref, delivery),
                        child: const Text("Kuryerni o'zgartirish"),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(onPressed: () => _cancel(context, ref, delivery), child: const Text('Bekor qilish')),
                  ],
                ),
              ],
              if (canManage && canAssign && delivery.status == DeliveryStatus.cancelled) ...[
                const SizedBox(height: 10),
                FilledButton.tonalIcon(
                  onPressed: () => _assign(context, ref, null),
                  icon: const Icon(Icons.replay),
                  label: const Text('Qayta kuryerga berish'),
                ),
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

  Widget _shell({required Widget child}) => Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Card(child: Padding(padding: const EdgeInsets.all(14), child: child)),
      ).animate().fadeIn(duration: AppMotion.standard).slideY(begin: 0.1, curve: AppMotion.emphasized);

  /// New delivery (or reopen a cancelled one) when [existing] is null, else reassign it.
  Future<void> _assign(BuildContext context, WidgetRef ref, Delivery? existing) async {
    final choice = await AssignCourierSheet.show(context, currentCourierId: existing?.courierId);
    if (choice == null) return;
    final Result<Delivery> result = existing == null
        ? await getIt<CreateDeliveryUseCase>().call(orderId, courierId: choice.courierId)
        : await getIt<ReassignDeliveryUseCase>().call(existing.id, courierId: choice.courierId);
    ref.invalidate(orderDeliveryProvider(orderId));
    if (!context.mounted) return;
    result.fold(
      (_) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(choice.courierId == null ? 'Barcha kuryerlarga taklif qilindi' : 'Kuryerga berildi')),
      ),
      (failure) => DeliveryActions.showError(context, failure.message),
    );
  }

  Future<void> _cancel(BuildContext context, WidgetRef ref, Delivery delivery) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yetkazishni bekor qilish?'),
        content: const Text('Kuryer bu buyurtmani endi ko\'rmaydi. Keyin qayta berishingiz mumkin.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Yo'q")),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Bekor qilish')),
        ],
      ),
    );
    if (ok != true) return;
    final result = await getIt<CancelDeliveryUseCase>().call(delivery.id);
    ref.invalidate(orderDeliveryProvider(orderId));
    if (!context.mounted) return;
    result.fold((_) => null, (failure) => DeliveryActions.showError(context, failure.message));
  }
}
