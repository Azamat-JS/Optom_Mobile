import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/l10n/app_l10n.dart';
import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/features/deliveries/domain/entities/delivery.dart';
import 'package:bsmart/features/deliveries/domain/usecases/manage_delivery_usecases.dart';
import 'package:bsmart/features/deliveries/presentation/delivery_actions.dart';
import 'package:bsmart/features/deliveries/presentation/providers/order_delivery_notifier.dart';
import 'package:bsmart/features/deliveries/presentation/screens/delivery_tracking_screen.dart';
import 'package:bsmart/features/deliveries/presentation/widgets/assign_courier_sheet.dart';
import 'package:bsmart/features/deliveries/presentation/widgets/delivery_outcome_section.dart';
import 'package:bsmart/features/deliveries/presentation/widgets/delivery_status_badge.dart';
import 'package:bsmart/features/deliveries/presentation/widgets/handover_code_card.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';

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

  static String headline(DeliveryStatus status) => appL10n.dlvHeadline(status.name);

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
            Expanded(child: Text(context.l10n.restNoCourier)),
            FilledButton.icon(
              onPressed: () => _assign(context, ref, null),
              icon: const Icon(Icons.moped_outlined),
              label: Text(context.l10n.dlvAssignTitle),
            ),
          ],
        ),
      );
    }
    final trackable = delivery.status.isActive;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: DashCard(
        padding: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                Text(context.l10n.dlvCourierWith(delivery.courier!.firstName), style: theme.textTheme.bodyMedium),
              ],
              if (canManage)
                DeliveryOutcomeSection(
                  delivery: delivery,
                  onChanged: () => ref.invalidate(orderDeliveryProvider(orderId)),
                )
              else ...[
                if (delivery.handover.code != null) ...[
                  const SizedBox(height: 10),
                  HandoverCodeCard(code: delivery.handover.code!),
                ],
                if (delivery.status == DeliveryStatus.failed) ...[
                  const SizedBox(height: 6),
                  Text(
                    context.l10n.dlvFailedCustomer(delivery.failReason?.label ?? context.l10n.dlvFailedFallback),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ],
              if (canManage && delivery.status.isOffer) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _assign(context, ref, delivery),
                        child: Text(context.l10n.dlvChangeCourier),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(onPressed: () => _cancel(context, ref, delivery), child: Text(context.l10n.dlvCancel)),
                  ],
                ),
              ],
              // Reopen after a cancel or a failed attempt (Phase 7 N2); a failed one can also be
              // given up on.
              if (canManage &&
                  canAssign &&
                  (delivery.status == DeliveryStatus.cancelled || delivery.status == DeliveryStatus.failed)) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: () => _assign(context, ref, null),
                        icon: const Icon(Icons.replay),
                        label: Text(context.l10n.dlvReassign),
                      ),
                    ),
                    if (delivery.status == DeliveryStatus.failed) ...[
                      const SizedBox(width: 8),
                      TextButton(onPressed: () => _cancel(context, ref, delivery), child: Text(context.l10n.dlvCancel)),
                    ],
                  ],
                ),
              ],
              if (trackable) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (_) => DeliveryTrackingScreen(deliveryId: delivery.id))),
                    icon: const Icon(Icons.map_outlined),
                    label: Text(context.l10n.dlvTrackCourier),
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
    padding: const EdgeInsets.only(top: 12),
    child: DashCard(child: child),
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
        SnackBar(content: Text(choice.courierId == null ? context.l10n.dlvOfferedAll : context.l10n.dlvAssigned)),
      ),
      (failure) => DeliveryActions.showError(context, failure.message),
    );
  }

  Future<void> _cancel(BuildContext context, WidgetRef ref, Delivery delivery) async {
    final reason = await showDialog<String>(context: context, builder: (_) => const _CancelReasonDialog());
    if (reason == null) return;
    final result = await getIt<CancelDeliveryUseCase>().call(delivery.id, reason: reason);
    ref.invalidate(orderDeliveryProvider(orderId));
    if (!context.mounted) return;
    result.fold((_) => null, (failure) => DeliveryActions.showError(context, failure.message));
  }
}

/// Cancel confirmation with an optional reason (staff-only, Phase 7 N2). Pops the reason ('' when
/// left empty) or null when dismissed.
class _CancelReasonDialog extends StatefulWidget {
  const _CancelReasonDialog();

  @override
  State<_CancelReasonDialog> createState() => _CancelReasonDialogState();
}

class _CancelReasonDialogState extends State<_CancelReasonDialog> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(context.l10n.dlvCancelTitle),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.dlvCancelBody),
        const SizedBox(height: 12),
        TextField(
          controller: _reason,
          maxLength: 300,
          decoration: InputDecoration(labelText: context.l10n.commonReasonOptional, border: const OutlineInputBorder()),
        ),
      ],
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.commonNo)),
      FilledButton(onPressed: () => Navigator.pop(context, _reason.text.trim()), child: Text(context.l10n.dlvCancel)),
    ],
  );
}
