import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/favorites/presentation/providers/favorite_ids_notifier.dart';
import 'package:bsmart/features/storefront/domain/entities/storefront_product.dart';
import 'package:bsmart/features/storefront/domain/usecases/get_storefront_product_usecase.dart';
import 'package:bsmart/features/storefront/presentation/providers/storefront_cart_notifier.dart';

/// Guest-eligible — `GET /public/catalog/products/:id` needs no auth. The
/// favorite heart only appears once logged in (`favoriteIdsProvider` is
/// authenticated-only); a guest tapping it is prompted to log in instead of
/// the request silently 401ing.
class StorefrontProductDetailScreen extends ConsumerStatefulWidget {
  const StorefrontProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  ConsumerState<StorefrontProductDetailScreen> createState() => _StorefrontProductDetailScreenState();
}

class _StorefrontProductDetailScreenState extends ConsumerState<StorefrontProductDetailScreen> {
  StorefrontProduct? _product;
  String? _errorMessage;
  double _quantity = 1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await getIt<GetStorefrontProductUseCase>().call(widget.productId);
    if (!mounted) return;
    setState(() {
      result.fold((product) {
        _product = product;
        _quantity = product.unit?.isWeighable ?? false ? 1 : 1;
      }, (failure) => _errorMessage = failure.message);
    });
  }

  void _addToCart() {
    final product = _product;
    if (product == null) return;
    final added = ref.read(storefrontCartProvider.notifier).addProduct(product);
    if (!added) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Savatda faqat bitta doʻkondan mahsulot boʻlishi mumkin')),
        );
      return;
    }
    if (_quantity != 1) {
      ref.read(storefrontCartProvider.notifier).updateQuantity(product.id, _quantity);
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('${product.name} savatga qoʻshildi')));
  }

  void _toggleFavorite(bool isLoggedIn) {
    final product = _product;
    if (product == null) return;
    if (!isLoggedIn) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Sevimlilarga qoʻshish uchun tizimga kiring')));
      return;
    }
    ref.read(favoriteIdsProvider.notifier).toggle(product.id);
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;
    final isLoggedIn = ref.watch(sessionNotifierProvider).valueOrNull?.isAuthenticated ?? false;
    final favoriteIdsAsync = isLoggedIn ? ref.watch(favoriteIdsProvider) : null;
    final isFavorited = favoriteIdsAsync?.valueOrNull?.contains(widget.productId) ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(product?.name ?? 'Mahsulot'),
        actions: [
          IconButton(
            icon: Icon(isFavorited ? Icons.favorite : Icons.favorite_border, color: isFavorited ? Colors.red : null),
            onPressed: () => _toggleFavorite(isLoggedIn),
          ),
        ],
      ),
      body: _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : product == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.only(bottom: 100),
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: product.imageUrl != null
                          ? CachedNetworkImage(imageUrl: product.imageUrl!, fit: BoxFit.cover)
                          : Container(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              child: const Icon(Icons.inventory_2_outlined, size: 64),
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.name, style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.format(product.price, product.currency),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Card(
                            child: ListTile(
                              leading: const Icon(Icons.storefront_outlined),
                              title: Text(product.sellerName),
                              subtitle: Text(product.storeName ?? 'Doʻkon'),
                            ),
                          ),
                          if (product.description != null && product.description!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text('Tavsif', style: Theme.of(context).textTheme.titleSmall),
                            const SizedBox(height: 4),
                            Text(product.description!),
                          ],
                          const SizedBox(height: 12),
                          Text('Zaxira: ${product.stock.toStringAsFixed(0)} ${product.unit?.label ?? ''}'),
                        ],
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: product == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    IconButton.filledTonal(
                      onPressed: _quantity > 1 ? () => setState(() => _quantity -= 1) : null,
                      icon: const Icon(Icons.remove),
                    ),
                    SizedBox(
                      width: 48,
                      child: Text(_quantity.toStringAsFixed(0), textAlign: TextAlign.center),
                    ),
                    IconButton.filledTonal(
                      onPressed: () => setState(() => _quantity += 1),
                      icon: const Icon(Icons.add),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _addToCart,
                        style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                        child: const Text('Savatga qoʻshish'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
