import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/products/domain/entities/product.dart';
import 'package:bsmart/features/products/domain/entities/product_query.dart';
import 'package:bsmart/features/products/domain/usecases/list_products_usecase.dart';
import 'package:bsmart/features/sales/presentation/providers/pos_cart_notifier.dart';
import 'package:bsmart/features/sales/presentation/screens/checkout_screen.dart';
import 'package:bsmart/shared/widgets/barcode_scanner_screen.dart';

/// The POS Sell tab — search/scan the tenant's own active inventory
/// (`GET /products`, never the buyer-facing `catalog` module — a cashier is
/// selling their own stock, not browsing another seller's) and build a cart.
/// Checkout is a separate pushed screen (`CheckoutScreen`), not a sheet,
/// since it has its own multi-step customer/payment form.
class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;

  List<Product> _products = const [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasNext = false;
  int _page = 1;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
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

  Future<void> _loadProducts({bool resetPage = false, String? barcode}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      if (resetPage) _page = 1;
    });

    final result = await getIt<ListProductsUseCase>().call(
      ProductQuery(
        page: _page,
        isActive: true,
        barcode: barcode,
        search: barcode == null && _searchController.text.trim().isNotEmpty ? _searchController.text.trim() : null,
      ),
    );
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      result.fold((page) {
        _products = page.data;
        _hasNext = page.meta.hasNext;
      }, (failure) => _errorMessage = failure.message);
    });
  }

  Future<void> _loadMore() async {
    if (!_hasNext || _isLoadingMore || _isLoading) return;
    setState(() => _isLoadingMore = true);
    final result = await getIt<ListProductsUseCase>().call(
      ProductQuery(
        page: _page + 1,
        isActive: true,
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

  Future<void> _scanBarcode() async {
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen(title: 'Mahsulotni skanerlash')),
    );
    if (code == null || !mounted) return;
    await _loadProducts(resetPage: true, barcode: code);
    if (!mounted) return;
    if (_products.length == 1) {
      _addToCart(_products.first);
    } else if (_products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bu shtrix-kod bo\'yicha mahsulot topilmadi')));
    }
  }

  void _addToCart(Product product) {
    final added = ref.read(posCartProvider.notifier).addProduct(product);
    if (!added) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text("Bitta sotuvda faqat bitta valyutadagi mahsulotlar bo'lishi mumkin")));
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('${product.name} savatga qo\'shildi'), duration: const Duration(milliseconds: 600)));
  }

  Future<void> _openCheckout() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const CheckoutScreen()),
    );
    if (result == true) _loadProducts(resetPage: true);
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(posCartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kassa'),
        actions: [IconButton(icon: const Icon(Icons.qr_code_scanner), onPressed: _scanBarcode)],
      ),
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
          Expanded(child: _buildProductList(cart)),
        ],
      ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: FilledButton(
                  onPressed: _openCheckout,
                  style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: Text(
                    '${cart.itemCount} ta mahsulot — ${CurrencyFormatter.format(cart.total, cart.currency!)}',
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildProductList(PosCartState cart) {
    if (_errorMessage != null) return Center(child: Text(_errorMessage!));
    if (_isLoading) return const Center(child: CircularProgressIndicator());
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
          title: Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            '${CurrencyFormatter.format(product.price, product.currency)} · Qoldiq: ${product.stock.toStringAsFixed(product.unit?.isWeighable == true ? 2 : 0)}',
          ),
          trailing: inCart != null
              ? Chip(label: Text('${inCart.quantity.toStringAsFixed(0)} ta'))
              : IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => _addToCart(product)),
          onTap: () => _addToCart(product),
        );
      },
    );
  }
}
