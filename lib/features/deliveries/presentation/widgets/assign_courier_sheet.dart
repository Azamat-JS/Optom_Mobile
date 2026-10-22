import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/features/deliveries/domain/entities/assignable_courier.dart';
import 'package:bsmart/features/deliveries/domain/usecases/manage_delivery_usecases.dart';

final assignableCouriersProvider = FutureProvider.autoDispose<List<AssignableCourier>>((ref) async {
  final result = await getIt<ListAssignableCouriersUseCase>().call();
  return result.fold((list) => list, (failure) => throw failure);
});

/// The owner/admin's choice: one courier, or an open offer to all couriers.
typedef CourierChoice = ({String? courierId});

/// Bottom sheet listing assignable couriers (online first, with current load)
/// plus "Barcha kuryerlarga taklif qilish". Resolves to null if dismissed.
class AssignCourierSheet extends ConsumerWidget {
  const AssignCourierSheet({super.key, this.currentCourierId});

  final String? currentCourierId;

  static Future<CourierChoice?> show(BuildContext context, {String? currentCourierId}) =>
      showModalBottomSheet<CourierChoice>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (_) => AssignCourierSheet(currentCourierId: currentCourierId),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final couriers = ref.watch(assignableCouriersProvider);
    final theme = Theme.of(context);
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(context.l10n.dlvAssignTitle, style: theme.textTheme.titleLarge),
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.secondaryContainer,
                child: const Icon(Icons.campaign_outlined),
              ),
              title: Text(context.l10n.dlvOfferAll),
              subtitle: Text(context.l10n.dlvOfferAllHint),
              selected: currentCourierId == null,
              onTap: () => Navigator.pop(context, (courierId: null)),
            ),
            const Divider(),
            Flexible(
              child: couriers.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) =>
                    Padding(padding: const EdgeInsets.all(24), child: Text(context.l10n.commonErrorWith('$e'))),
                data: (list) {
                  if (list.isEmpty) {
                    return Padding(padding: const EdgeInsets.all(24), child: Text(context.l10n.dlvNoActiveCouriers));
                  }
                  final sorted = [...list]..sort((a, b) => (b.online ? 1 : 0) - (a.online ? 1 : 0));
                  return ListView(
                    shrinkWrap: true,
                    children: [
                      for (final (i, c) in sorted.indexed)
                        ListTile(
                          selected: c.id == currentCourierId,
                          leading: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              CircleAvatar(child: Text(c.firstName.isEmpty ? '?' : c.firstName[0])),
                              Positioned(
                                right: -1,
                                bottom: -1,
                                child: Container(
                                  width: 13,
                                  height: 13,
                                  decoration: BoxDecoration(
                                    color: c.online ? const Color(0xFF2E7D32) : theme.colorScheme.outline,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: theme.colorScheme.surface, width: 2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          title: Text(c.fullName),
                          subtitle: Text(
                            [
                              c.online ? context.l10n.trkOnline : context.l10n.trkOffline,
                              if (c.activeDeliveries > 0) context.l10n.dlvActiveDeliveries(c.activeDeliveries),
                            ].join(' · '),
                          ),
                          onTap: () => Navigator.pop(context, (courierId: c.id)),
                        ).animate(delay: AppMotion.fast * 0.3 * i).fadeIn(duration: AppMotion.standard),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
