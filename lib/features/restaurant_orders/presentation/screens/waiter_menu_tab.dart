import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/products/presentation/providers/products_list_notifier.dart';
import 'package:bsmart/features/warehouse/domain/entities/dish.dart';
import 'package:bsmart/features/warehouse/presentation/providers/warehouse_providers.dart';
import 'package:bsmart/features/warehouse/presentation/widgets/warehouse_widgets.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

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
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final productsAsync = ref.watch(productsListProvider);
    // Whether each dish can be made from the warehouse now (dishes with a recipe only).
    final availability = ref.watch(dishAvailabilityProvider).valueOrNull ?? const {};

    return productsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => DashEmptyState(
        icon: Icons.cloud_off_rounded,
        text: l10n.commonErrorWith('$error'),
        action: TextButton(onPressed: () => ref.invalidate(productsListProvider), child: Text(l10n.commonRetry)),
      ),
      data: (state) => RefreshIndicator(
        color: AppColors.onBrand,
        backgroundColor: AppColors.brandYellow,
        onRefresh: () {
          ref.invalidate(dishAvailabilityProvider);
          return ref.read(productsListProvider.notifier).refresh();
        },
        child: state.items.isEmpty
            ? DashEmptyState(icon: Icons.restaurant_menu_rounded, text: l10n.restMenuEmpty)
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                itemCount: state.items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final product = state.items[index];
                  final dish = availability[product.id];
                  return DashListCard(
                    dimmed: !product.isActive,
                    leading: DashThumb(url: product.primaryImage?.url, icon: Icons.restaurant_menu_rounded, size: 52),
                    title: product.name,
                    subtitle: product.category?.name,
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          CurrencyFormatter.format(product.price, product.currency),
                          style: TextStyle(color: colors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                        if (!product.isActive) ...[
                          const SizedBox(height: 4),
                          DashTag(label: l10n.commonInactive, color: Theme.of(context).colorScheme.error),
                        ],
                        if (dish != null && dish.status != DishStatus.noRecipe) ...[
                          const SizedBox(height: 4),
                          DishAvailabilityTag(status: dish.status, portions: dish.portions),
                        ],
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
