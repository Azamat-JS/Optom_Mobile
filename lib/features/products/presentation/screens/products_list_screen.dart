import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/features/categories/domain/entities/category.dart';
import 'package:bsmart/features/categories/presentation/providers/categories_provider.dart';
import 'package:bsmart/features/products/presentation/providers/products_list_notifier.dart';
import 'package:bsmart/features/products/presentation/widgets/product_list_item.dart';
import 'package:bsmart/shared/widgets/barcode_scanner_screen.dart';

class ProductsListScreen extends ConsumerStatefulWidget {
  const ProductsListScreen({super.key});

  @override
  ConsumerState<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends ConsumerState<ProductsListScreen> {
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
      ref.read(productsListProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(productsListProvider.notifier).search(value);
    });
  }

  Future<void> _scanBarcode() async {
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen(title: 'Mahsulotni topish')),
    );
    if (code == null) return;
    _searchController.text = code;
    ref.read(productsListProvider.notifier).search(code);
  }

  Future<void> _openCategoryFilter() async {
    final categories = ref.read(categoriesProvider).valueOrNull ?? const [];
    final picked = await showModalBottomSheet<String?>(
      context: context,
      builder: (context) => _CategoryFilterSheet(categories: categories, selectedId: _selectedCategoryId),
    );
    if (picked == _selectedCategoryId) return;
    setState(() => _selectedCategoryId = picked);
    ref.read(productsListProvider.notifier).filterByCategory(picked);
  }

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(productsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mahsulotlar'),
        actions: [
          IconButton(icon: const Icon(Icons.qr_code_scanner), onPressed: _scanBarcode),
          IconButton(
            icon: Icon(_selectedCategoryId != null ? Icons.filter_alt : Icons.filter_alt_outlined),
            onPressed: _openCategoryFilter,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Nomi yoki shtrix-kod bo\'yicha qidirish...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: listState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Xatolik: $error')),
              data: (state) {
                if (state.items.isEmpty) {
                  return const Center(child: Text('Mahsulotlar topilmadi'));
                }
                return RefreshIndicator(
                  onRefresh: () => ref.read(productsListProvider.notifier).refresh(),
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: _scrollController,
                    itemCount: state.items.length + (state.hasNext ? 1 : 0),
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      if (index >= state.items.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final product = state.items[index];
                      return ProductListItem(
                        product: product,
                        onTap: () => context.push(RouteNames.productDetail(product.id)),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RouteNames.productNew),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CategoryFilterSheet extends StatelessWidget {
  const _CategoryFilterSheet({required this.categories, required this.selectedId});

  final List<Category> categories;
  final String? selectedId;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            title: const Text('Barchasi'),
            trailing: selectedId == null ? const Icon(Icons.check) : null,
            onTap: () => Navigator.of(context).pop(null),
          ),
          for (final root in categories) ...[
            ListTile(
              title: Text(root.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: selectedId == root.id ? const Icon(Icons.check) : null,
              onTap: root.children.isEmpty ? () => Navigator.of(context).pop(root.id) : null,
            ),
            for (final child in root.children)
              ListTile(
                contentPadding: const EdgeInsets.only(left: 32, right: 16),
                title: Text(child.name),
                trailing: selectedId == child.id ? const Icon(Icons.check) : null,
                onTap: () => Navigator.of(context).pop(child.id),
              ),
          ],
        ],
      ),
    );
  }
}
