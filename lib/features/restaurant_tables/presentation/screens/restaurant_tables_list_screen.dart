import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/features/restaurant_tables/domain/entities/restaurant_table.dart';
import 'package:bsmart/features/restaurant_tables/domain/usecases/delete_restaurant_table_usecase.dart';
import 'package:bsmart/features/restaurant_tables/presentation/providers/restaurant_tables_list_notifier.dart';
import 'package:bsmart/features/restaurant_tables/presentation/screens/restaurant_table_form_screen.dart';

/// Table/room management — not owner-only (`RETAILER_ADMIN` gets it too,
/// operational config rather than owner-private data, mirroring
/// `StoresListScreen`'s access level, not `AdminsListScreen`'s).
class RestaurantTablesListScreen extends ConsumerWidget {
  const RestaurantTablesListScreen({super.key});

  Future<void> _openForm(BuildContext context, WidgetRef ref, {RestaurantTable? editing}) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => RestaurantTableFormScreen(editingTable: editing)),
    );
    if (saved == true) ref.read(restaurantTablesListProvider.notifier).refresh();
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, RestaurantTable table) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Stolni o'chirish"),
        content: Text('${table.name} oʻchirilsinmi? Ochiq buyurtmasi bo\'lsa, xatolik qaytadi.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Bekor qilish')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text("O'chirish")),
        ],
      ),
    );
    if (confirmed != true) return;
    final result = await getIt<DeleteRestaurantTableUseCase>().call(table.id);
    if (!context.mounted) return;
    result.fold(
      (_) => ref.read(restaurantTablesListProvider.notifier).refresh(),
      (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tablesAsync = ref.watch(restaurantTablesListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Stollar')),
      body: tablesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Xatolik: $error')),
        data: (tables) {
          if (tables.isEmpty) return const Center(child: Text('Stollar topilmadi'));
          return RefreshIndicator(
            onRefresh: () => ref.read(restaurantTablesListProvider.notifier).refresh(),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: tables.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final table = tables[index];
                return ListTile(
                  leading: const Icon(Icons.table_restaurant_outlined),
                  title: Text(table.name),
                  subtitle: Text(
                    'Xizmat haqi: ${table.percent % 1 == 0 ? table.percent.toStringAsFixed(0) : table.percent.toStringAsFixed(2)}%',
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (action) {
                      switch (action) {
                        case 'edit':
                          _openForm(context, ref, editing: table);
                        case 'delete':
                          _delete(context, ref, table);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Tahrirlash')),
                      const PopupMenuItem(value: 'delete', child: Text("O'chirish")),
                    ],
                  ),
                  onTap: () => _openForm(context, ref, editing: table),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}
