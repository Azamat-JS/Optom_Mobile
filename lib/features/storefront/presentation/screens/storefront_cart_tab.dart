import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/storefront/presentation/providers/storefront_cart_notifier.dart';

/// The "Savat" tab — local cart state, guest-editable. Tapping "Buyurtma
/// berish" pushes `RouteNames.customerCartReview`, which is deliberately
/// *not* in `app_router.dart`'s guest-allowed list — a logged-out tap lands
/// on `/login` via the ordinary redirect, matching "login required only at
/// checkout" from the Phase 2 plan without any manual auth check here.
class StorefrontCartTab extends ConsumerWidget {
  const StorefrontCartTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(storefrontCartProvider);

    if (cart.isEmpty) {
      return const Center(child: Text('Savat boʻsh'));
    }

    final currency = cart.lines.values.first.product.currency;

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: cart.lines.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final line = cart.lines.values.elementAt(index);
              return ListTile(
                title: Text(line.product.name),
                subtitle: Text(CurrencyFormatter.format(line.product.price, line.product.currency)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => ref
                          .read(storefrontCartProvider.notifier)
                          .updateQuantity(line.product.id, line.quantity - 1),
                    ),
                    Text(line.quantity.toStringAsFixed(0)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => ref
                          .read(storefrontCartProvider.notifier)
                          .updateQuantity(line.product.id, line.quantity + 1),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Jami', style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      CurrencyFormatter.format(cart.total, currency),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => context.push(RouteNames.customerCartReview),
                  style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: const Text('Buyurtma berish'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
