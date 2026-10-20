import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/products/domain/entities/product.dart';
import 'package:bsmart/features/products/domain/entities/product_query.dart';
import 'package:bsmart/features/products/domain/usecases/list_products_usecase.dart';
import 'package:bsmart/features/sales/presentation/providers/pos_cart_notifier.dart';
import 'package:bsmart/features/sales/presentation/screens/checkout_screen.dart';
import 'package:bsmart/features/sales/presentation/widgets/shared_cart_sheet.dart';
import 'package:bsmart/shared/widgets/barcode_scanner_screen.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';

/// The POS Sell tab — search/scan the tenant's own active inventory
/// (`GET /products`, never the buyer-facing `catalog` module — a cashier is
/// selling their own stock, not browsing another seller's) and build a cart.
/// Checkout is a separate pushed screen (`CheckoutScreen`), not a sheet,
/// since it has its own multi-step customer/payment form.
///
/// Phase 9 U4b (no reference; matched to the U4a home): grey page, large
/// title with round buttons (parked carts, clear, scan), a white search pill,
/// a 2-column product grid where a tapped card gets a quantity badge and a
/// yellow stepper, and a dark cart bar leading to checkout.
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
    setState(() {}); // clear button visibility
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _loadProducts(resetPage: true));
  }

  void _clearSearch() {
    _searchController.clear();
    _debounce?.cancel();
    _loadProducts(resetPage: true);
  }

  Future<void> _scanBarcode() async {
    final code = await Navigator.of(
      context,
    ).push<String>(MaterialPageRoute(builder: (_) => BarcodeScannerScreen(title: context.l10n.posScanProduct)));
    if (code == null || !mounted) return;
    await _loadProducts(resetPage: true, barcode: code);
    if (!mounted) return;
    if (_products.length == 1) {
      _addToCart(_products.first);
    } else if (_products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.posBarcodeNotFound)));
    }
  }

  /// The card's badge and stepper confirm an add, so only a refusal (mixed
  /// currencies) shows a message.
  void _addToCart(Product product) {
    final added = ref.read(posCartProvider.notifier).addProduct(product);
    if (!added) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(context.l10n.posSingleCurrency)));
      return;
    }
    HapticFeedback.selectionClick();
  }

  Future<void> _confirmClear() async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.cartClear),
        content: Text(l10n.cartClearConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.commonDelete)),
        ],
      ),
    );
    if (ok == true) ref.read(posCartProvider.notifier).clear();
  }

  Future<void> _openCheckout() async {
    await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => const CheckoutScreen()));
    // Checkout replaces itself with the receipt, so no result comes back;
    // reload anyway so the stock figures include the sale just made.
    if (mounted) _loadProducts(resetPage: true);
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(posCartProvider);
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark).copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: DashColors.page(context),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    DashRoundButton(
                      icon: Icons.arrow_back_rounded,
                      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.posTitle,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.6,
                        ),
                      ),
                    ),
                    if (!cart.isEmpty) ...[
                      DashRoundButton(icon: Icons.delete_sweep_rounded, tooltip: l10n.cartClear, onTap: _confirmClear),
                      const SizedBox(width: 8),
                    ],
                    DashRoundButton(
                      icon: Icons.hourglass_top_rounded,
                      tooltip: l10n.posSavedCarts,
                      onTap: () => SharedCartSheet.show(context),
                    ),
                    const SizedBox(width: 8),
                    DashRoundButton(
                      icon: Icons.qr_code_scanner_rounded,
                      tooltip: l10n.posScanProduct,
                      highlight: true,
                      onTap: _scanBarcode,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: _SearchPill(
                  controller: _searchController,
                  hint: l10n.ordersSearchProduct,
                  onChanged: _onSearchChanged,
                  onClear: _clearSearch,
                ),
              ),
              Expanded(child: _buildProductGrid(cart)),
            ],
          ),
        ),
        bottomNavigationBar: AnimatedSwitcher(
          duration: AppMotion.standard,
          transitionBuilder: (child, animation) => SizeTransition(sizeFactor: animation, child: child),
          child: cart.isEmpty ? const SizedBox.shrink() : _CartBar(cart: cart, onCheckout: _openCheckout),
        ),
      ),
    );
  }

  Widget _buildProductGrid(PosCartState cart) {
    final colors = BrandColors.of(context);
    Widget message(IconData icon, String text) => ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 80),
        Icon(icon, size: 48, color: colors.textMuted),
        const SizedBox(height: 10),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w600),
        ),
      ],
    );

    final Widget body;
    if (_errorMessage != null) {
      body = message(Icons.cloud_off_rounded, _errorMessage!);
    } else if (_isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_products.isEmpty) {
      body = message(Icons.search_off_rounded, context.l10n.productsNotFound);
    } else {
      final scale = MediaQuery.textScalerOf(context).scale(1);
      body = GridView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          // Photo + paddings are fixed; the three text lines and the stepper
          // grow with the text scale.
          mainAxisExtent: 176 + 82 * scale,
        ),
        itemCount: _products.length + (_hasNext ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _products.length) return const Center(child: CircularProgressIndicator());
          final product = _products[index];
          return _PosProductCard(
            product: product,
            line: cart.lines[product.id],
            onAdd: () => _addToCart(product),
            onQuantity: (q) => ref.read(posCartProvider.notifier).updateQuantity(product.id, q),
          ).animate().fadeIn(delay: (20 * (index % 10)).ms, duration: AppMotion.standard);
        },
      );
    }
    return RefreshIndicator(
      color: AppColors.onBrand,
      backgroundColor: AppColors.brandYellow,
      onRefresh: () => _loadProducts(resetPage: true),
      child: body,
    );
  }
}

class _SearchPill extends StatelessWidget {
  const _SearchPill({required this.controller, required this.hint, required this.onChanged, required this.onClear});

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    return Container(
      height: 52,
      decoration: BoxDecoration(color: DashColors.card(context), borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(Icons.search_rounded, color: colors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: colors.textMuted, fontWeight: FontWeight.w500),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                isCollapsed: true,
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            IconButton(
              tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
              icon: Icon(Icons.close_rounded, color: colors.textSecondary),
              onPressed: onClear,
            )
          else
            const SizedBox(width: 14),
        ],
      ),
    );
  }
}

/// Photo, name, price, stock; tap adds one. In the cart it shows a yellow
/// quantity badge and a full-width stepper.
class _PosProductCard extends StatelessWidget {
  const _PosProductCard({required this.product, required this.line, required this.onAdd, required this.onQuantity});

  final Product product;
  final PosCartLine? line;
  final VoidCallback onAdd;
  final ValueChanged<double> onQuantity;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final image = product.primaryImage?.url;
    final weighable = product.unit?.isWeighable == true;
    String qty(double v) => v.toStringAsFixed(weighable && v.truncateToDouble() != v ? 2 : 0);
    final unit = product.unit == null ? '' : ' ${product.unit!.shortLabel}';
    final outOfStock = product.stock <= 0;
    final inCart = line;

    return DashCard(
      padding: const EdgeInsets.all(10),
      onTap: onAdd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 104,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: ColoredBox(
                    color: DashColors.inset(context),
                    child: image == null
                        ? Icon(Icons.inventory_2_rounded, size: 36, color: colors.textMuted)
                        : CachedNetworkImage(
                            imageUrl: image,
                            fit: BoxFit.cover,
                            errorWidget: (_, _, _) =>
                                Icon(Icons.inventory_2_rounded, size: 36, color: colors.textMuted),
                          ),
                  ),
                ),
                if (inCart != null)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 28),
                      height: 28,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.brandYellow,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: DashColors.card(context), width: 2),
                      ),
                      child: Text(
                        qty(inCart.quantity),
                        style: const TextStyle(
                          fontFamily: BrandTheme.fontFamily,
                          color: AppColors.onBrand,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ).animate(key: ValueKey(inCart.quantity)).scaleXY(begin: 0.7, end: 1, duration: AppMotion.fast),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colors.textPrimary, fontSize: 14.5, fontWeight: FontWeight.w700, height: 1.25),
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              CurrencyFormatter.format(product.price, product.currency),
              style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ),
          Text(
            outOfStock ? l10n.posOutOfStock : l10n.posStockLeft('${qty(product.stock)}$unit'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: outOfStock ? Theme.of(context).colorScheme.error : colors.textMuted,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 34,
            child: inCart != null
                ? DashStepper(
                    expand: true,
                    value: qty(inCart.quantity),
                    onMinus: () => onQuantity(inCart.quantity - 1),
                    onPlus: () => onQuantity(inCart.quantity + 1),
                  )
                : Material(
                    color: DashColors.inset(context),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: onAdd,
                      borderRadius: BorderRadius.circular(12),
                      child: Center(child: Icon(Icons.add_rounded, color: colors.textPrimary, size: 22)),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Dark bar with the cart size and total; the yellow pill opens checkout.
class _CartBar extends StatelessWidget {
  const _CartBar({required this.cart, required this.onCheckout});

  final PosCartState cart;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
        child: Material(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            onTap: onCheckout,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 10, 12),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      '${cart.itemCount}',
                      style: const TextStyle(
                        fontFamily: BrandTheme.fontFamily,
                        color: AppColors.brandYellow,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.commonProductCount(cart.itemCount),
                          style: TextStyle(
                            fontFamily: BrandTheme.fontFamily,
                            color: Colors.white.withValues(alpha: 0.65),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            CurrencyFormatter.format(cart.total, cart.currency!),
                            style: const TextStyle(
                              fontFamily: BrandTheme.fontFamily,
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(color: AppColors.brandYellow, borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.posCheckout,
                          style: const TextStyle(
                            fontFamily: BrandTheme.fontFamily,
                            color: AppColors.onBrand,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_rounded, color: AppColors.onBrand, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
