import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/favorites/presentation/providers/favorites_list_notifier.dart';

/// The "Sevimlilar" tab — authenticated only (`favorite.controller.ts` is
/// `CUSTOMER, RETAILER` only). A guest sees a login prompt instead of the
/// list ever attempting an unauthenticated fetch.
class FavoritesTab extends ConsumerWidget {
  const FavoritesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(sessionNotifierProvider).valueOrNull?.isAuthenticated ?? false;

    if (!isLoggedIn) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.favorite_border, size: 48),
              const SizedBox(height: 12),
              const Text('Sevimlilarni koʻrish uchun tizimga kiring', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: () => context.push(RouteNames.login), child: const Text('Kirish')),
            ],
          ),
        ),
      );
    }

    final favoritesAsync = ref.watch(favoritesListProvider);

    return favoritesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Xatolik: $error')),
      data: (favorites) {
        if (favorites.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => ref.read(favoritesListProvider.notifier).refresh(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                Padding(padding: EdgeInsets.only(top: 96), child: Center(child: Text("Sevimlilar ro'yxati bo'sh"))),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () => ref.read(favoritesListProvider.notifier).refresh(),
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.8,
            ),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final product = favorites[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => context.push(RouteNames.customerProductDetail(product.id)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: product.imageUrl != null
                            ? CachedNetworkImage(imageUrl: product.imageUrl!, fit: BoxFit.cover)
                            : Container(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                child: const Icon(Icons.inventory_2_outlined, size: 32),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text(
                              CurrencyFormatter.format(product.price, product.currency),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
