import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/features/categories/domain/entities/category.dart';
import 'package:bsmart/features/categories/presentation/providers/categories_provider.dart';
import 'package:bsmart/features/products/presentation/providers/products_list_notifier.dart';
import 'package:bsmart/features/products/presentation/widgets/product_list_item.dart';
import 'package:bsmart/shared/widgets/barcode_scanner_screen.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// The tenant's own inventory. Phase 9 U4c1: `DashPage` with scan and
/// category-filter buttons, a search field, the active category as a
/// removable chip, product rows as cards, and a yellow add button.
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
    // The list provider is app-wide and keeps its filters after this screen
    // closes; show them again instead of an empty field over a filtered list.
    final query = ref.read(productsListProvider).valueOrNull?.query;
    _searchController.text = query?.search ?? '';
    _selectedCategoryId = query?.categoryId;
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
    final code = await Navigator.of(
      context,
    ).push<String>(MaterialPageRoute(builder: (_) => BarcodeScannerScreen(title: context.l10n.productsFindTitle)));
    if (code == null) return;
    _searchController.text = code;
    ref.read(productsListProvider.notifier).search(code);
  }

  void _setCategory(String? id) {
    if (id == _selectedCategoryId) return;
    setState(() => _selectedCategoryId = id);
    ref.read(productsListProvider.notifier).filterByCategory(id);
  }

  Future<void> _openCategoryFilter() async {
    final picked = await showModalBottomSheet<_Pick>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _CategoryFilterSheet(selectedId: _selectedCategoryId),
    );
    if (picked != null) _setCategory(picked.id);
  }

  String? _categoryName(String id) {
    for (final root in ref.watch(categoriesProvider).valueOrNull ?? const <Category>[]) {
      if (root.id == id) return root.name;
      for (final child in root.children) {
        if (child.id == id) return child.name;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final listState = ref.watch(productsListProvider);
    final selected = _selectedCategoryId;

    return DashPage(
      title: l10n.productsTitle,
      actions: [
        DashRoundButton(icon: Icons.qr_code_scanner_rounded, tooltip: l10n.productsFindTitle, onTap: _scanBarcode),
        DashRoundButton(
          icon: Icons.tune_rounded,
          tooltip: l10n.commonCategory,
          highlight: selected != null,
          onTap: _openCategoryFilter,
        ),
      ],
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashSearchField(controller: _searchController, hint: l10n.productsSearchHint, onChanged: _onSearchChanged),
          if (selected != null) ...[
            const SizedBox(height: 10),
            InputChip(
              label: Text(_categoryName(selected) ?? l10n.commonCategory),
              avatar: const Icon(Icons.category_rounded, size: 18),
              onDeleted: () => _setCategory(null),
              onPressed: _openCategoryFilter,
            ),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.productsNewTitle,
        onPressed: () => context.push(RouteNames.productNew),
        child: const Icon(Icons.add_rounded),
      ),
      body: listState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => DashEmptyState(
          icon: Icons.cloud_off_rounded,
          text: l10n.commonErrorWith('$error'),
          action: TextButton(onPressed: () => ref.invalidate(productsListProvider), child: Text(l10n.commonRetry)),
        ),
        data: (state) => RefreshIndicator(
          color: AppColors.onBrand,
          backgroundColor: AppColors.brandYellow,
          onRefresh: () => ref.read(productsListProvider.notifier).refresh(),
          child: state.items.isEmpty
              ? DashEmptyState(icon: Icons.inventory_2_rounded, text: l10n.productsNotFound)
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                  itemCount: state.items.length + (state.hasNext ? 1 : 0),
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
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
                    ).animate().fadeIn(delay: (25 * (index % 12)).ms, duration: AppMotion.standard);
                  },
                ),
        ),
      ),
    );
  }
}

/// Sheet result; wraps the id so "all" (null) differs from a dismissal.
class _Pick {
  const _Pick(this.id);

  final String? id;
}

/// Watches the category tree itself: reading it once used to show an empty
/// sheet when nothing had loaded the categories yet.
class _CategoryFilterSheet extends ConsumerWidget {
  const _CategoryFilterSheet({required this.selectedId});

  final String? selectedId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final categories = categoriesAsync.valueOrNull ?? const <Category>[];
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    Widget tile(String label, String? id, {bool header = false, bool enabled = true, double indent = 20}) {
      final isSelected = selectedId == id;
      return ListTile(
        contentPadding: EdgeInsets.only(left: indent, right: 16),
        title: Text(
          label,
          style: TextStyle(
            color: enabled ? colors.textPrimary : colors.textSecondary,
            fontWeight: header ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
        trailing: isSelected ? Icon(Icons.check_circle_rounded, color: colors.accentText) : null,
        onTap: enabled ? () => Navigator.of(context).pop(_Pick(id)) : null,
      );
    }

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.92,
      builder: (context, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              l10n.commonCategory,
              style: TextStyle(color: colors.textPrimary, fontSize: 20, fontWeight: FontWeight.w800),
            ),
          ),
          tile(l10n.commonAll, null, header: true),
          if (categoriesAsync.isLoading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          for (final root in categories) ...[
            tile(root.name, root.id, header: true, enabled: root.children.isEmpty),
            for (final child in root.children) tile(child.name, child.id, indent: 40),
          ],
        ],
      ),
    );
  }
}
