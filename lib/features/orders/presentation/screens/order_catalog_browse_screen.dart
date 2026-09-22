import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/catalog/domain/entities/catalog_product.dart';
import 'package:bsmart/features/catalog/domain/entities/catalog_query.dart';
import 'package:bsmart/features/catalog/domain/entities/catalog_seller.dart';
import 'package:bsmart/features/catalog/domain/usecases/browse_catalog_usecase.dart';
import 'package:bsmart/features/catalog/domain/usecases/list_seller_stores_usecase.dart';
import 'package:bsmart/features/orders/presentation/providers/create_order_cart_notifier.dart';

/// Step 2 of the RETAILER create-order flow: browse the selected seller's
/// active products (`GET /catalog?sellerId=&storeId=`) and build a cart.
/// Shows a branch picker first only if the seller runs more than one store
/// (`GET /catalog/sellers/:id/stores`) — a single-store seller skips it
/// entirely, per that endpoint's own documented intent.
class OrderCatalogBrowseScreen extends ConsumerStatefulWidget {
  const OrderCatalogBrowseScreen({super.key});

  @override
  ConsumerState<OrderCatalogBrowseScreen> createState() => _OrderCatalogBrowseScreenState();
}

class _OrderCatalogBrowseScreenState extends ConsumerState<OrderCatalogBrowseScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;

  List<CatalogStore>? _stores;
  List<CatalogProduct> _products = const [];
  bool _isLoadingProducts = true;
  bool _isLoadingMore = false;
  bool _hasNext = false;
  int _page = 1;
  String? _errorMessage;

  CatalogSeller get _seller => ref.read(createOrderCartProvider).seller!;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadStores();
    _loadProducts(resetPage: true);
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
      _loadMore();
    }
  }

  Future<void> _loadStores() async {
    final result = await getIt<ListSellerStoresUseCase>().call(_seller.id);
    if (!mounted) return;
    result.fold((stores) => setState(() => _stores = stores), (_) => setState(() => _stores = const []));
  }

  Future<void> _loadProducts({bool resetPage = false}) async {
    setState(() {
      _isLoadingProducts = true;
      _errorMessage = null;
      if (resetPage) _page = 1;
    });

    final storeId = ref.read(createOrderCartProvider).store?.id;
    final result = await getIt<BrowseCatalogUseCase>().call(
      CatalogQuery(
        page: _page,
        sellerId: _seller.id,
        storeId: storeId,
        search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
      ),
    );
    if (!mounted) return;
    setState(() {
      _isLoadingProducts = false;
      result.fold(
        (page) {
          _products = page.data;
          _hasNext = page.meta.hasNext;
        },
        (failure) => _errorMessage = failure.message,
      );
    });
  }

  Future<void> _loadMore() async {
    if (!_hasNext || _isLoadingMore || _isLoadingProducts) return;
    setState(() => _isLoadingMore = true);
    final storeId = ref.read(createOrderCartProvider).store?.id;
    final result = await getIt<BrowseCatalogUseCase>().call(
      CatalogQuery(
        page: _page + 1,
        sellerId: _seller.id,
        storeId: storeId,
        search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
      ),
    );
    if (!mounted) return;
    setState(() {
      _isLoadingMore = false;
      result.fold((page) {
        _page += 1;
        _products = [..._products, ...page.data];
        _hasNext = page.meta.hasNext;
      }, (_) {});
    });
  }

  void _onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _loadProducts(resetPage: true));
  }

  void _onStoreSelected(CatalogStore? store) {
    ref.read(createOrderCartProvider.notifier).selectStore(store);
    _loadProducts(resetPage: true);
  }

  void _addToCart(CatalogProduct product) {
    final added = ref.read(createOrderCartProvider.notifier).addProduct(product);
    if (!added) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text("Bitta buyurtmada faqat bitta valyutadagi mahsulotlar bo'lishi mumkin")),
        );
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('${product.name} savatga qo\'shildi'), duration: const Duration(milliseconds: 800)));
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(createOrderCartProvider);

    return Scaffold(
      appBar: AppBar(title: Text(_seller.fullName)),
      body: Column(
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
          if (_stores != null && _stores!.length > 1)
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: const Text('Barcha filiallar'),
                      selected: cart.store == null,
                      onSelected: (_) => _onStoreSelected(null),
                    ),
                  ),
                  for (final store in _stores!)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(store.name),
                        selected: cart.store?.id == store.id,
                        onSelected: (_) => _onStoreSelected(store),
                      ),
                    ),
                ],
              ),
            ),
          Expanded(child: _buildProductList(cart)),
        ],
      ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: FilledButton(
                  onPressed: () => context.push(RouteNames.orderReview),
                  style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: Text(
                    '${cart.itemCount} ta mahsulot — ${CurrencyFormatter.format(cart.total, cart.lines.values.first.product.currency)}',
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildProductList(CreateOrderCartState cart) {
    if (_errorMessage != null) return Center(child: Text(_errorMessage!));
    if (_isLoadingProducts) return const Center(child: CircularProgressIndicator());
    if (_products.isEmpty) return const Center(child: Text('Mahsulotlar topilmadi'));

    return ListView.separated(
      controller: _scrollController,
      itemCount: _products.length + (_hasNext ? 1 : 0),
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        if (index >= _products.length) {
          return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
        }
        final product = _products[index];
        final inCart = cart.lines[product.id];
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 44,
              height: 44,
              child: product.imageUrl != null
                  ? CachedNetworkImage(imageUrl: product.imageUrl!, fit: BoxFit.cover)
                  : Container(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.inventory_2_outlined, size: 20),
                    ),
            ),
          ),
          title: Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(CurrencyFormatter.format(product.price, product.currency)),
          trailing: inCart != null
              ? Chip(label: Text('${inCart.quantity.toStringAsFixed(0)} ta'))
              : IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => _addToCart(product),
                ),
          onTap: () => _addToCart(product),
        );
      },
    );
  }
}
