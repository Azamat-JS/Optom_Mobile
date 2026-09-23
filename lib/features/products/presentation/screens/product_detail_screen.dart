import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/products/domain/entities/product.dart';
import 'package:bsmart/features/products/domain/usecases/assign_barcode_usecase.dart';
import 'package:bsmart/features/products/domain/usecases/delete_product_image_usecase.dart';
import 'package:bsmart/features/products/domain/usecases/delete_product_usecase.dart';
import 'package:bsmart/features/products/domain/usecases/get_product_usecase.dart';
import 'package:bsmart/features/products/domain/usecases/share_to_catalog_usecase.dart';
import 'package:bsmart/features/products/domain/usecases/upload_product_image_usecase.dart';
import 'package:bsmart/features/products/presentation/widgets/stock_adjust_sheet.dart';

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
      (_) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ko'rib chiqish uchun katalogga yuborildi")),
      ),
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
        title: const Text("Mahsulotni o'chirish"),
        content: const Text("Bu mahsulotni o'chirishni tasdiqlaysizmi?"),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Bekor qilish')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text("O'chirish")),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isBusy = true);
    final result = await getIt<DeleteProductUseCase>().call(widget.productId);
    if (!mounted) return;
    result.fold(
      (_) => context.pop(),
      (failure) {
        setState(() => _isBusy = false);
        _showError(failure.message);
      },
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;
    return Scaffold(
      appBar: AppBar(
        title: Text(product?.name ?? 'Mahsulot'),
        actions: [
          if (product != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                final changed = await context.push<bool>(RouteNames.productEdit(product.id), extra: product);
                if (changed == true) _load();
              },
            ),
          IconButton(icon: const Icon(Icons.delete_outline), onPressed: _confirmDelete),
        ],
      ),
      body: _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : product == null
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildImageGallery(product),
                      const SizedBox(height: 16),
                      _buildInfoCard(product),
                      const SizedBox(height: 16),
                      _buildActions(product),
                    ],
                  ),
                ),
    );
  }

  Widget _buildImageGallery(Product product) {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final image in product.images)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(imageUrl: image.url, width: 100, height: 100, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: GestureDetector(
                      onTap: _isBusy ? null : () => _deleteImage(image.id),
                      child: const CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.black54,
                        child: Icon(Icons.close, size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (!product.isCatalogLinked)
            InkWell(
              onTap: _isBusy ? null : _addImage,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add_a_photo_outlined),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(Product product) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(CurrencyFormatter.format(product.price, product.currency),
                    style: Theme.of(context).textTheme.headlineSmall),
                if (!product.isActive)
                  Chip(label: const Text('Faol emas'), backgroundColor: Theme.of(context).colorScheme.errorContainer),
              ],
            ),
            if (product.costPrice != null)
              Text('Tannarx: ${CurrencyFormatter.format(product.costPrice!, product.currency)}'),
            const Divider(height: 24),
            _infoRow('Zaxira', '${product.stock.toStringAsFixed(product.unit?.isWeighable ?? false ? 2 : 0)} ${product.unit?.label ?? ''}'),
            if (product.category != null) _infoRow('Kategoriya', product.category!.name),
            if (product.brand != null) _infoRow('Brend', product.brand!),
            _infoRow('Barkod', product.barcode ?? "Yo'q"),
            if (product.plu != null) _infoRow('PLU', product.plu!),
            if (product.sku != null) _infoRow('SKU', product.sku!),
            if (product.description != null && product.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(product.description!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: Theme.of(context).hintColor)),
            Text(value),
          ],
        ),
      );

  Widget _buildActions(Product product) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilledButton.icon(
          onPressed: _isBusy ? null : _openStockSheet,
          icon: const Icon(Icons.add_box_outlined),
          label: const Text("Zaxira qo'shish"),
        ),
        if (product.barcode == null)
          OutlinedButton.icon(
            onPressed: _isBusy ? null : _assignBarcode,
            icon: const Icon(Icons.qr_code),
            label: const Text('Barkod yaratish'),
          ),
        if (!product.isCatalogLinked)
          OutlinedButton.icon(
            onPressed: _isBusy ? null : _shareToCatalog,
            icon: const Icon(Icons.share_outlined),
            label: const Text('Katalogga ulashish'),
          ),
      ],
    );
  }
}
