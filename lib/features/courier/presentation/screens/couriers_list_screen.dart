import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/features/courier/domain/entities/courier.dart';
import 'package:bsmart/features/courier/domain/usecases/delete_courier_usecase.dart';
import 'package:bsmart/features/courier/domain/usecases/set_courier_active_usecase.dart';
import 'package:bsmart/features/courier/presentation/providers/couriers_list_notifier.dart';
import 'package:bsmart/features/courier/presentation/screens/courier_form_screen.dart';
import 'package:bsmart/features/stores/presentation/providers/stores_list_notifier.dart';

/// Owner-only courier roster — `assertCanManageCouriers` also 403s unless
/// `courierFeatureEnabled` (SUPER_ADMIN-gated) is on, surfaced here as a
/// plain error state rather than a bespoke "feature disabled" screen, since
/// this screen is only ever reachable via a nav entry already gated on that
/// same flag (see `HomeScreen`).
class CouriersListScreen extends ConsumerWidget {
  const CouriersListScreen({super.key});

  Future<void> _openForm(BuildContext context, WidgetRef ref, {Courier? editing}) async {
    final saved = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => CourierFormScreen(editingCourier: editing)));
    if (saved == true) ref.read(couriersListProvider.notifier).refresh();
  }

  Future<void> _toggleActive(BuildContext context, WidgetRef ref, Courier courier) async {
    final result = await getIt<SetCourierActiveUseCase>().call(courier.id, !courier.isActive);
    if (!context.mounted) return;
    result.fold(
      (_) => ref.read(couriersListProvider.notifier).refresh(),
      (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Courier courier) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.couriersDeleteTitle),
        content: Text(context.l10n.commonDeletePermanentlyConfirm(courier.fullName)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(context.l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(context.l10n.commonDelete)),
        ],
      ),
    );
    if (confirmed != true) return;
    final result = await getIt<DeleteCourierUseCase>().call(courier.id);
    if (!context.mounted) return;
    result.fold(
      (_) => ref.read(couriersListProvider.notifier).refresh(),
      (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final couriersAsync = ref.watch(couriersListProvider);
    final storesAsync = ref.watch(storesListProvider);

    return DashPage(
      title: context.l10n.navCouriers,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context, ref),
        child: const Icon(Icons.person_add_alt_1_rounded),
      ),
      body: couriersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            DashEmptyState(icon: Icons.cloud_off_rounded, text: context.l10n.commonErrorWith('$error')),
        data: (state) {
          final storeNames = {for (final s in storesAsync.valueOrNull ?? []) s.id: s.name};
          final items = state.items;
          return RefreshIndicator(
            color: AppColors.onBrand,
            backgroundColor: AppColors.brandYellow,
            onRefresh: () => ref.read(couriersListProvider.notifier).refresh(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
              children: [
                DashUsageCard(
                  label: context.l10n.couriersUsage('${state.items.length}', '${state.courierLimit}'),
                  used: state.items.length,
                  limit: state.courierLimit,
                  icon: Icons.moped_rounded,
                ),
                const SizedBox(height: 12),
                if (items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: Text(
                      context.l10n.couriersNotFound,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: BrandColors.of(context).textSecondary, fontWeight: FontWeight.w600),
                    ),
                  ),
                for (final (i, courier) in items.indexed) ...[
                  if (i > 0) const SizedBox(height: 10),
                  DashListCard(
                    dimmed: !courier.isActive,
                    leading: DashAvatar(name: courier.firstName, active: courier.isActive),
                    title: courier.fullName,
                    subtitle: [
                      courier.phone,
                      storeNames[courier.storeId] ?? courier.storeId,
                      context.l10n.couriersToday(courier.todayOrderCount),
                    ].join(' · '),
                    trailing: DashMenuButton(
                      items: [
                        (value: 'edit', icon: Icons.edit_rounded, label: context.l10n.commonEdit, destructive: false),
                        (
                          value: 'toggle',
                          icon: courier.isActive ? Icons.block_rounded : Icons.check_circle_rounded,
                          label: courier.isActive ? context.l10n.commonDeactivate : context.l10n.commonActivate,
                          destructive: false,
                        ),
                        (
                          value: 'delete',
                          icon: Icons.delete_outline_rounded,
                          label: context.l10n.commonDelete,
                          destructive: true,
                        ),
                      ],
                      onSelected: (action) {
                        switch (action) {
                          case 'edit':
                            _openForm(context, ref, editing: courier);
                          case 'toggle':
                            _toggleActive(context, ref, courier);
                          case 'delete':
                            _delete(context, ref, courier);
                        }
                      },
                    ),
                    onTap: () => _openForm(context, ref, editing: courier),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
