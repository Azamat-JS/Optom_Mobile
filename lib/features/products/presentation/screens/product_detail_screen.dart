import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/products/domain/entities/product.dart';
import 'package:bsmart/features/products/domain/usecases/assign_barcode_usecase.dart';
import 'package:bsmart/features/products/domain/usecases/delete_product_image_usecase.dart';
import 'package:bsmart/features/products/domain/usecases/delete_product_usecase.dart';
import 'package:bsmart/features/products/domain/usecases/get_product_usecase.dart';
import 'package:bsmart/features/products/domain/usecases/share_to_catalog_usecase.dart';
import 'package:bsmart/features/products/domain/usecases/upload_product_image_usecase.dart';
import 'package:bsmart/features/products/presentation/widgets/stock_adjust_sheet.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// One product: photos, price (+ cost and profit), stock with a quick
/// "add stock" sheet, details, and barcode / share-to-catalog actions.
/// Phase 9 U4c1: `DashPage` + cards.
class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _product;
  String? _errorMessage;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isBusy = true;
      _errorMessage = null;
    });
    final result = await getIt<GetProductUseCase>().call(widget.productId);
    if (!mounted) return;
    setState(() {
      _isBusy = false;
      result.fold((product) => _product = product, (failure) => _errorMessage = failure.message);
    });
  }

  Future<void> _openStockSheet() async {
    final product = _product;
    if (product == null) return;
    final updated = await showModalBottomSheet<Product>(
      context: context,
      isScrollControlled: true,
      builder: (_) => StockAdjustSheet(product: product),
    );
    if (updated != null) setState(() => _product = updated);
  }

  Future<void> _assignBarcode() async {
    setState(() => _isBusy = true);
    final result = await getIt<AssignBarcodeUseCase>().call(widget.productId);
    if (!mounted) return;
    setState(() {
      _isBusy = false;
      result.fold((product) => _product = product, (failure) => _showError(failure.message));
    });
  }

  Future<void> _shareToCatalog() async {
    setState(() => _isBusy = true);
    final result = await getIt<ShareToCatalogUseCase>().call(widget.productId);
    if (!mounted) return;
    setState(() => _isBusy = false);
    result.fold(
      (_) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.productsSentToCatalog))),
      (failure) => _showError(failure.message),
    );
  }

  Future<void> _addImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;

    setState(() => _isBusy = true);
    final result = await getIt<UploadProductImageUseCase>().call(
      widget.productId,
      filePath: picked.path,
      isPrimary: _product?.images.isEmpty ?? true,
    );
    if (!mounted) return;
    setState(() => _isBusy = false);
    result.fold((_) => _load(), (failure) => _showError(failure.message));
  }

  Future<void> _deleteImage(String imageId) async {
    setState(() => _isBusy = true);
    final result = await getIt<DeleteProductImageUseCase>().call(widget.productId, imageId);
    if (!mounted) return;
    setState(() => _isBusy = false);
    result.fold((_) => _load(), (failure) => _showError(failure.message));
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.productsDeleteTitle),
        content: Text(context.l10n.productsDeleteConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(context.l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(context.l10n.commonDelete)),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isBusy = true);
    final result = await getIt<DeleteProductUseCase>().call(widget.productId);
    if (!mounted) return;
    result.fold((_) => context.pop(), (failure) {
      setState(() => _isBusy = false);
      _showError(failure.message);
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final product = _product;
    return DashPage(
      title: product?.name ?? l10n.productsProduct,
      actions: [
        if (product != null)
          DashRoundButton(
            icon: Icons.edit_rounded,
            tooltip: l10n.commonEdit,
            onTap: () async {
              final changed = await context.push<bool>(RouteNames.productEdit(product.id), extra: product);
              if (changed == true) _load();
            },
          ),
        DashRoundButton(icon: Icons.delete_outline_rounded, tooltip: l10n.commonDelete, onTap: _confirmDelete),
      ],
      body: _errorMessage != null
          ? DashEmptyState(
              icon: Icons.cloud_off_rounded,
              text: _errorMessage!,
              action: TextButton(onPressed: _load, child: Text(l10n.commonRetry)),
            )
          : product == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              color: AppColors.onBrand,
              backgroundColor: AppColors.brandYellow,
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                children: [
                  _buildImageGallery(product),
                  const SizedBox(height: 14),
                  _buildPriceCard(product),
                  const SizedBox(height: 12),
                  _buildStockCard(product),
                  DashSectionTitle(l10n.productsDetails),
                  _buildInfoCard(product),
                  const SizedBox(height: 16),
                  _buildActions(product),
                ],
              ),
            ),
    );
  }

  Widget _buildImageGallery(Product product) {
    final colors = BrandColors.of(context);
    return SizedBox(
      height: 112,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final image in product.images)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Stack(
                children: [
                  DashThumb(url: image.url, size: 112),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Material(
                      color: Colors.black54,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: _isBusy ? null : () => _deleteImage(image.id),
                        child: Tooltip(
                          message: context.l10n.commonDelete,
                          child: const SizedBox(
                            width: 28,
                            height: 28,
                            child: Icon(Icons.close_rounded, size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (!product.isCatalogLinked)
            Material(
              color: DashColors.card(context),
              borderRadius: BorderRadius.circular(30),
              child: InkWell(
                onTap: _isBusy ? null : _addImage,
                borderRadius: BorderRadius.circular(30),
                child: SizedBox(
                  width: 112,
                  height: 112,
                  child: _isBusy
                      ? const Center(child: CircularProgressIndicator())
                      : Icon(Icons.add_a_photo_rounded, color: colors.textSecondary, size: 30),
                ),
              ),
            )
          else if (product.images.isEmpty)
            const DashThumb(size: 112),
        ],
      ),
    );
  }

  Widget _buildPriceCard(Product product) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    String money(double v) => CurrencyFormatter.format(v, product.currency);
    final cost = product.costPrice;
    final profit = cost == null ? null : product.price - cost;
    return DashCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.commonPrice,
                  style: TextStyle(color: colors.textSecondary, fontSize: 14.5, fontWeight: FontWeight.w700),
                ),
              ),
              if (!product.isActive) DashTag(label: l10n.commonInactive, color: Theme.of(context).colorScheme.error),
              if (product.isCatalogLinked) ...[
                const SizedBox(width: 6),
                DashTag(label: l10n.navCatalog, color: colors.accentText),
              ],
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              money(product.price),
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
              ),
            ),
          ),
          if (cost != null) ...[
            const SizedBox(height: 4),
            Text(
              l10n.productsCostPriceWith(money(cost)),
              style: TextStyle(color: colors.textMuted, fontSize: 13.5, fontWeight: FontWeight.w600),
            ),
            if (profit != null && product.price > 0) ...[
              const SizedBox(height: 8),
              DashTag(
                label: l10n.productsProfitWith(money(profit), (profit / product.price * 100).toStringAsFixed(0)),
                color: profit >= 0 ? AppColors.success : Theme.of(context).colorScheme.error,
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildStockCard(Product product) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final weighable = product.unit?.isWeighable ?? false;
    final out = product.stock <= 0;
    final tint = out ? Theme.of(context).colorScheme.error : colors.accentText;
    return DashCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(color: tint.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
            child: Icon(Icons.warehouse_rounded, color: tint),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.commonStock,
                  style: TextStyle(color: colors.textSecondary, fontSize: 13.5, fontWeight: FontWeight.w700),
                ),
                Text(
                  out
                      ? l10n.posOutOfStock
                      : '${product.stock.toStringAsFixed(weighable ? 2 : 0)} ${product.unit?.shortLabel ?? ''}',
                  style: TextStyle(color: out ? tint : colors.textPrimary, fontSize: 20, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: _isBusy ? null : _openStockSheet,
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 44),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.add_rounded, size: 20),
            label: Text(l10n.productsAddStock),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(Product product) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final expiry = product.expiryDate;
    return DashCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (product.category != null) DashInfoRow(label: l10n.commonCategory, value: product.category!.name),
          if (product.unit != null) DashInfoRow(label: l10n.commonUnit, value: product.unit!.label),
          if (product.brand != null) DashInfoRow(label: l10n.commonBrand, value: product.brand!),
          DashInfoRow(label: l10n.commonBarcode, value: product.barcode ?? l10n.commonNone),
          if (product.plu != null) DashInfoRow(label: 'PLU', value: product.plu!),
          if (product.sku != null) DashInfoRow(label: 'SKU', value: product.sku!),
          if (expiry != null)
            DashInfoRow(label: l10n.productsExpiry, value: DateFormat('dd.MM.yyyy').format(expiry.toLocal())),
          if (product.description != null && product.description!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              product.description!,
              style: TextStyle(color: colors.textSecondary, fontSize: 14.5, fontWeight: FontWeight.w500, height: 1.4),
            ),
            const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }

  Widget _buildActions(Product product) {
    final l10n = context.l10n;
    final style = OutlinedButton.styleFrom(
      minimumSize: const Size.fromHeight(52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (product.barcode == null) ...[
          OutlinedButton.icon(
            onPressed: _isBusy ? null : _assignBarcode,
            style: style,
            icon: const Icon(Icons.qr_code_rounded),
            label: Text(l10n.productsCreateBarcode),
          ),
          const SizedBox(height: 10),
        ],
        if (!product.isCatalogLinked)
          OutlinedButton.icon(
            onPressed: _isBusy ? null : _shareToCatalog,
            style: style,
            icon: const Icon(Icons.share_rounded),
            label: Text(l10n.productsShareToCatalog),
          ),
      ],
    );
  }
}
