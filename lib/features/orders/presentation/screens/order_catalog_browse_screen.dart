import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/catalog/domain/entities/catalog_product.dart';
import 'package:bsmart/features/catalog/domain/entities/catalog_query.dart';
import 'package:bsmart/features/catalog/domain/entities/catalog_seller.dart';
import 'package:bsmart/features/catalog/domain/usecases/browse_catalog_usecase.dart';
import 'package:bsmart/features/catalog/domain/usecases/list_seller_stores_usecase.dart';
import 'package:bsmart/features/orders/presentation/providers/create_order_cart_notifier.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

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
      result.fold((page) {
        _products = page.data;
        _hasNext = page.meta.hasNext;
      }, (failure) => _errorMessage = failure.message);
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
        ..showSnackBar(SnackBar(content: Text(context.l10n.ordersSingleCurrency)));
      return;
    }
    // The row's stepper confirms the add; only a refusal shows a message.
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cart = ref.watch(createOrderCartProvider);
    final stores = _stores;
    // Placing the order clears the cart (and its seller) while this screen is
    // still under the review screen; it must not rebuild into a null check.
    final seller = cart.seller;
    if (seller == null) return Scaffold(backgroundColor: DashColors.page(context));

    return DashPage(
      title: seller.fullName,
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DashSearchField(controller: _searchController, hint: l10n.ordersSearchProduct, onChanged: _onSearchChanged),
          if (stores != null && stores.length > 1) ...[
            const SizedBox(height: 10),
            DashChoiceChips<CatalogStore?>(
              values: [null, ...stores],
              selected: stores.where((s) => s.id == cart.store?.id).firstOrNull,
              label: (store) => store?.name ?? l10n.ordersAllBranches,
              onSelected: _onStoreSelected,
            ),
          ],
        ],
      ),
      bottomBar: AnimatedSwitcher(
        duration: AppMotion.standard,
        transitionBuilder: (child, animation) => SizeTransition(sizeFactor: animation, child: child),
        child: cart.isEmpty
            ? const SizedBox.shrink()
            : DashCartBar(
                count: cart.itemCount,
                countLabel: l10n.commonProductCount(cart.itemCount),
                total: CurrencyFormatter.format(cart.total, cart.lines.values.first.product.currency),
                actionLabel: l10n.commonContinue,
                onTap: () => context.push(RouteNames.orderReview),
              ),
      ),
      body: _buildProductList(cart),
    );
  }

  Widget _buildProductList(CreateOrderCartState cart) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    if (_errorMessage != null) return DashEmptyState(icon: Icons.cloud_off_rounded, text: _errorMessage!);
    if (_isLoadingProducts) return const Center(child: CircularProgressIndicator());
    if (_products.isEmpty) return DashEmptyState(icon: Icons.inventory_2_rounded, text: l10n.productsNotFound);

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: _products.length + (_hasNext ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (index >= _products.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final product = _products[index];
        final line = cart.lines[product.id];
        final weighable = product.unit?.isWeighable ?? false;
        String qty(double v) => v.toStringAsFixed(weighable && v != v.truncateToDouble() ? 2 : 0);
        return DashListCard(
          leading: DashThumb(url: product.imageUrl, size: 52),
          title: product.name,
          subtitle: [
            CurrencyFormatter.format(product.price, product.currency),
            product.stock <= 0
                ? l10n.posOutOfStock
                : l10n.posStockLeft('${qty(product.stock)} ${product.unit?.shortLabel ?? ''}'.trim()),
          ].join(' · '),
          onTap: line == null ? () => _addToCart(product) : null,
          trailing: line != null
              ? DashStepper(
                  value: qty(line.quantity),
                  onMinus: () =>
                      ref.read(createOrderCartProvider.notifier).updateQuantity(product.id, line.quantity - 1),
                  onPlus: () =>
                      ref.read(createOrderCartProvider.notifier).updateQuantity(product.id, line.quantity + 1),
                )
              : Material(
                  color: DashColors.inset(context),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () => _addToCart(product),
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(width: 40, height: 34, child: Icon(Icons.add_rounded, color: colors.textPrimary)),
                  ),
                ),
        );
      },
    );
  }
}
