import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => CourierFormScreen(editingCourier: editing)),
    );
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
        title: const Text("Kuryerni o'chirish"),
        content: Text('${courier.fullName} butunlay oʻchirilsinmi?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Bekor qilish')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text("O'chirish")),
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

    return Scaffold(
      appBar: AppBar(title: const Text('Kuryerlar')),
      body: couriersAsync.when(
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
                    '${state.items.length} / ${state.courierLimit} kuryer ishlatilmoqda',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
              Expanded(
                child: state.items.isEmpty
                    ? const Center(child: Text('Kuryerlar topilmadi'))
                    : RefreshIndicator(
                        onRefresh: () => ref.read(couriersListProvider.notifier).refresh(),
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: state.items.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final courier = state.items[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    courier.isActive ? null : Theme.of(context).colorScheme.surfaceContainerHighest,
                                child: Text(courier.firstName.isNotEmpty ? courier.firstName.characters.first : '?'),
                              ),
                              title: Text(courier.fullName),
                              subtitle: Text(
                                [
                                  courier.phone,
                                  storeNames[courier.storeId] ?? courier.storeId,
                                  'Bugun: ${courier.todayOrderCount} ta yetkazish',
                                  if (!courier.isActive) 'Faolsiz',
                                ].join(' • '),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: PopupMenuButton<String>(
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
                                itemBuilder: (context) => [
                                  const PopupMenuItem(value: 'edit', child: Text('Tahrirlash')),
                                  PopupMenuItem(
                                    value: 'toggle',
                                    child: Text(courier.isActive ? 'Faolsizlantirish' : 'Faollashtirish'),
                                  ),
                                  const PopupMenuItem(value: 'delete', child: Text("O'chirish")),
                                ],
                              ),
                              onTap: () => _openForm(context, ref, editing: courier),
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
