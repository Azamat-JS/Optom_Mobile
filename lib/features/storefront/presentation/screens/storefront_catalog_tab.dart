import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/storefront/domain/entities/storefront_product.dart';
import 'package:bsmart/features/storefront/presentation/providers/storefront_cart_notifier.dart';
import 'package:bsmart/features/storefront/presentation/providers/storefront_categories_notifier.dart';
import 'package:bsmart/features/storefront/presentation/providers/storefront_products_notifier.dart';

/// The "Katalog" tab of the storefront — guest-eligible product feed
/// (`GET /public/catalog/products?sellerRole=RETAILER`), category chips +
/// search, no seller-picker step (see `StorefrontProductsNotifier`'s doc
/// comment for why this differs from the B2B catalog browse).
class StorefrontCatalogTab extends ConsumerStatefulWidget {
  const StorefrontCatalogTab({super.key});

  @override
  ConsumerState<StorefrontCatalogTab> createState() => _StorefrontCatalogTabState();
}

class _StorefrontCatalogTabState extends ConsumerState<StorefrontCatalogTab> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(storefrontProductsProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(storefrontProductsProvider.notifier).search(value);
    });
  }

  void _onCategorySelected(String? categoryId) {
    setState(() => _selectedCategoryId = categoryId);
    ref.read(storefrontProductsProvider.notifier).filterByCategory(categoryId);
  }

  void _addToCart(StorefrontProduct product) {
    final added = ref.read(storefrontCartProvider.notifier).addProduct(product);
    if (!added) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Savatda faqat bitta doʻkondan mahsulot boʻlishi mumkin')),
        );
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('${product.name} savatga qoʻshildi'), duration: const Duration(milliseconds: 800)),
      );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(storefrontCategoriesProvider);
    final productsAsync = ref.watch(storefrontProductsProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Mahsulot qidirish...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: _onSearchChanged,
          ),
        ),
        categoriesAsync.when(
          loading: () => const SizedBox(height: 44),
          error: (error, _) => const SizedBox.shrink(),
          data: (categories) => categories.isEmpty
              ? const SizedBox.shrink()
              : SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: const Text('Barchasi'),
                          selected: _selectedCategoryId == null,
                          onSelected: (_) => _onCategorySelected(null),
                        ),
                      ),
                      for (final category in categories)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: Text(category.name),
                            selected: _selectedCategoryId == category.id,
                            onSelected: (_) => _onCategorySelected(category.id),
                          ),
                        ),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: productsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Xatolik: $error', textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => ref.invalidate(storefrontProductsProvider),
                    child: const Text('Qayta urinish'),
                  ),
                ],
              ),
            ),
            data: (state) {
              if (state.items.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () => ref.read(storefrontProductsProvider.notifier).refresh(),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      Padding(padding: EdgeInsets.only(top: 96), child: Center(child: Text('Mahsulotlar topilmadi'))),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () => ref.read(storefrontProductsProvider.notifier).refresh(),
                child: GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: state.items.length,
                  itemBuilder: (context, index) {
                    final product = state.items[index];
                    return _ProductCard(
                      product: product,
                      onTap: () => context.push(RouteNames.customerProductDetail(product.id)),
                      onAddToCart: () => _addToCart(product),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.onTap, required this.onAddToCart});

  final StorefrontProduct product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
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
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(product.sellerName, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          CurrencyFormatter.format(product.price, product.currency),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      InkWell(
                        onTap: onAddToCart,
                        borderRadius: BorderRadius.circular(20),
                        child: const Padding(
                          padding: EdgeInsets.all(2),
                          child: Icon(Icons.add_circle, size: 26),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
