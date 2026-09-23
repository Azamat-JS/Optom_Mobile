import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/features/active_store/presentation/active_store_notifier.dart';
import 'package:bsmart/features/customers/presentation/providers/customers_list_notifier.dart';
import 'package:bsmart/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:bsmart/features/debts/presentation/providers/debts_list_notifier.dart';
import 'package:bsmart/features/debts/presentation/providers/sale_debts_list_notifier.dart';
import 'package:bsmart/features/orders/presentation/providers/orders_list_notifier.dart';
import 'package:bsmart/features/products/presentation/providers/products_list_notifier.dart';
import 'package:bsmart/features/sales/presentation/providers/sales_list_notifier.dart';
import 'package:bsmart/features/stores/domain/entities/store.dart';
import 'package:bsmart/features/stores/presentation/providers/stores_list_notifier.dart';

/// The owner's active-branch switcher — invisible whenever there's nothing
/// to switch between (0 or 1 store, or a locked staff session with no store
/// selection of their own — see `Session.isLockedToStore`). Placed
/// prominently on the dashboard, not tucked into a menu, per the original
/// milestone plan ("active-store switcher promoted to prominent UI once 2+
/// stores exist").
///
/// Switching has no per-provider surgical invalidation — every store-scoped
/// screen's data was fetched under the *previous* `X-Store-Id` header, and
/// this app has no central data cache to invalidate piecemeal (each feature
/// owns its own `AsyncNotifier`). Invalidating the known list/dashboard
/// providers here is the mobile equivalent of the reference web app's own
/// `window.location.reload()` on store switch.
class StoreSwitcher extends ConsumerWidget {
  const StoreSwitcher({super.key});

  void _invalidateStoreScopedProviders(WidgetRef ref) {
    ref.invalidate(dashboardProvider);
    ref.invalidate(productsListProvider);
    ref.invalidate(customersListProvider);
    ref.invalidate(salesListProvider);
    ref.invalidate(ordersListProvider);
    ref.invalidate(debtsListProvider);
    ref.invalidate(saleDebtsListProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storesAsync = ref.watch(storesListProvider);
    final activeStoreId = ref.watch(activeStoreNotifierProvider).valueOrNull;

    return storesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (stores) {
        if (stores.length <= 1) return const SizedBox.shrink();

        final active = stores.where((s) => s.id == activeStoreId).firstOrNull ??
            stores.where((s) => s.isDefault).firstOrNull ??
            stores.first;

        return PopupMenuButton<Store>(
          initialValue: active,
          onSelected: (store) async {
            await ref.read(activeStoreNotifierProvider.notifier).select(store.id);
            _invalidateStoreScopedProviders(ref);
          },
          itemBuilder: (context) => [
            for (final store in stores)
              PopupMenuItem(
                value: store,
                child: Row(
                  children: [
                    if (store.id == active.id) const Icon(Icons.check, size: 18) else const SizedBox(width: 18),
                    const SizedBox(width: 8),
                    Text(store.name),
                  ],
                ),
              ),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.storefront_outlined, size: 18),
                const SizedBox(width: 6),
                Text(active.name, overflow: TextOverflow.ellipsis),
                const Icon(Icons.arrow_drop_down, size: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
