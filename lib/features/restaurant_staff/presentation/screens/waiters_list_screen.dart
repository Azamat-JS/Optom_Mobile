import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => WaiterFormScreen(editingWaiter: editing)),
    );
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

    return Scaffold(
      appBar: AppBar(title: const Text('Ofitsiantlar')),
      body: waitersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Xatolik: $error')),
        data: (state) {
          final storeNames = {for (final s in storesAsync.valueOrNull ?? []) s.id: s.name};
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${state.items.length} / ${state.waiterLimit} ofitsiant ishlatilmoqda',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
              Expanded(
                child: state.items.isEmpty
                    ? const Center(child: Text('Ofitsiantlar topilmadi'))
                    : RefreshIndicator(
                        onRefresh: () => ref.read(waitersListProvider.notifier).refresh(),
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: state.items.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final waiter = state.items[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    waiter.isActive ? null : Theme.of(context).colorScheme.surfaceContainerHighest,
                                child: Text(waiter.firstName.isNotEmpty ? waiter.firstName.characters.first : '?'),
                              ),
                              title: Text(waiter.fullName),
                              subtitle: Text(
                                [
                                  waiter.phone,
                                  storeNames[waiter.storeId] ?? waiter.storeId,
                                  if (waiter.commissionPercent != null && waiter.commissionPercent! > 0)
                                    'Komissiya: ${waiter.commissionPercent!.toStringAsFixed(0)}%',
                                  'Bugun: ${waiter.todayOrderCount} ta buyurtma',
                                  if (!waiter.isActive) 'Faolsiz',
                                ].join(' • '),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: PopupMenuButton<String>(
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
                                itemBuilder: (context) => [
                                  const PopupMenuItem(value: 'edit', child: Text('Tahrirlash')),
                                  PopupMenuItem(
                                    value: 'toggle',
                                    child: Text(waiter.isActive ? 'Faolsizlantirish' : 'Faollashtirish'),
                                  ),
                                  const PopupMenuItem(value: 'delete', child: Text("O'chirish")),
                                ],
                              ),
                              onTap: () => _openForm(context, ref, editing: waiter),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context, ref),
        child: const Icon(Icons.person_add_alt_1),
      ),
    );
  }
}
