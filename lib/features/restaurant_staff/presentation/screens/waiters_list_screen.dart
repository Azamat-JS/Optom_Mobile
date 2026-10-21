import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/features/restaurant_staff/domain/entities/waiter.dart';
import 'package:bsmart/features/restaurant_staff/domain/usecases/delete_waiter_usecase.dart';
import 'package:bsmart/features/restaurant_staff/domain/usecases/set_waiter_active_usecase.dart';
import 'package:bsmart/features/restaurant_staff/presentation/providers/waiters_list_notifier.dart';
import 'package:bsmart/features/restaurant_staff/presentation/screens/waiter_form_screen.dart';
import 'package:bsmart/features/stores/presentation/providers/stores_list_notifier.dart';

/// Owner-only (restaurant-vertical `RETAILER` exactly — never `RETAILER_ADMIN`,
/// enforced server-side) waiter roster.
class WaitersListScreen extends ConsumerWidget {
  const WaitersListScreen({super.key});

  Future<void> _openForm(BuildContext context, WidgetRef ref, {Waiter? editing}) async {
    final saved = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => WaiterFormScreen(editingWaiter: editing)));
    if (saved == true) ref.read(waitersListProvider.notifier).refresh();
  }

  Future<void> _toggleActive(BuildContext context, WidgetRef ref, Waiter waiter) async {
    final result = await getIt<SetWaiterActiveUseCase>().call(waiter.id, !waiter.isActive);
    if (!context.mounted) return;
    result.fold(
      (_) => ref.read(waitersListProvider.notifier).refresh(),
      (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Waiter waiter) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ofitsiantni o'chirish"),
        content: Text('${waiter.fullName} butunlay oʻchirilsinmi?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Bekor qilish')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text("O'chirish")),
        ],
      ),
    );
    if (confirmed != true) return;
    final result = await getIt<DeleteWaiterUseCase>().call(waiter.id);
    if (!context.mounted) return;
    result.fold(
      (_) => ref.read(waitersListProvider.notifier).refresh(),
      (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final waitersAsync = ref.watch(waitersListProvider);
    final storesAsync = ref.watch(storesListProvider);

    return DashPage(
      title: 'Ofitsiantlar',
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context, ref),
        child: const Icon(Icons.person_add_alt_1_rounded),
      ),
      body: waitersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            DashEmptyState(icon: Icons.cloud_off_rounded, text: context.l10n.commonErrorWith('$error')),
        data: (state) {
          final storeNames = {for (final s in storesAsync.valueOrNull ?? []) s.id: s.name};
          final items = state.items;
          return RefreshIndicator(
            color: AppColors.onBrand,
            backgroundColor: AppColors.brandYellow,
            onRefresh: () => ref.read(waitersListProvider.notifier).refresh(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
              children: [
                DashUsageCard(
                  label: '${state.items.length} / ${state.waiterLimit} ofitsiant ishlatilmoqda',
                  used: state.items.length,
                  limit: state.waiterLimit,
                  icon: Icons.room_service_rounded,
                ),
                const SizedBox(height: 12),
                if (items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: Text(
                      'Ofitsiantlar topilmadi',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: BrandColors.of(context).textSecondary, fontWeight: FontWeight.w600),
                    ),
                  ),
                for (final (i, waiter) in items.indexed) ...[
                  if (i > 0) const SizedBox(height: 10),
                  DashListCard(
                    dimmed: !waiter.isActive,
                    leading: DashAvatar(name: waiter.firstName, active: waiter.isActive),
                    title: waiter.fullName,
                    subtitle: [
                      waiter.phone,
                      storeNames[waiter.storeId] ?? waiter.storeId,
                      if (waiter.commissionPercent != null && waiter.commissionPercent! > 0)
                        'Komissiya: ${waiter.commissionPercent!.toStringAsFixed(0)}%',
                      'Bugun: ${waiter.todayOrderCount} ta buyurtma',
                    ].join(' · '),
                    trailing: DashMenuButton(
                      items: [
                        (value: 'edit', icon: Icons.edit_rounded, label: 'Tahrirlash', destructive: false),
                        (
                          value: 'toggle',
                          icon: waiter.isActive ? Icons.block_rounded : Icons.check_circle_rounded,
                          label: waiter.isActive ? 'Faolsizlantirish' : 'Faollashtirish',
                          destructive: false,
                        ),
                        (value: 'delete', icon: Icons.delete_outline_rounded, label: "O'chirish", destructive: true),
                      ],
                      onSelected: (action) {
                        switch (action) {
                          case 'edit':
                            _openForm(context, ref, editing: waiter);
                          case 'toggle':
                            _toggleActive(context, ref, waiter);
                          case 'delete':
                            _delete(context, ref, waiter);
                        }
                      },
                    ),
                    onTap: () => _openForm(context, ref, editing: waiter),
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
