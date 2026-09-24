import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/products/presentation/providers/products_list_notifier.dart';

/// Read-only "Menu" — a restaurant's own inventory (`features/products`),
/// re-skinned for a waiter with no create/edit/delete affordances at all
/// (the backend's `ProductController` only grants `WAITER` `GET` access —
/// see `CLAUDE.md` "Restaurant Staff"). Deliberately a small dedicated
/// screen rather than adding an `isReadOnly` mode to the operator's own
/// `ProductsListScreen`, to avoid any risk of regressing that screen for
/// every other role.
class WaiterMenuTab extends ConsumerWidget {
  const WaiterMenuTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsListProvider);

    return productsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Xatolik: $error')),
      data: (state) {
        if (state.items.isEmpty) return const Center(child: Text('Menyu bo\'sh'));
        return RefreshIndicator(
          onRefresh: () => ref.read(productsListProvider.notifier).refresh(),
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: state.items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final product = state.items[index];
              return ListTile(
                leading: const Icon(Icons.restaurant_menu_outlined),
                title: Text(product.name),
                subtitle: Text(product.isActive ? 'Faol' : 'Faolsiz'),
                trailing: Text(CurrencyFormatter.format(product.price, product.currency)),
              );
            },
          ),
        );
      },
    );
  }
}
