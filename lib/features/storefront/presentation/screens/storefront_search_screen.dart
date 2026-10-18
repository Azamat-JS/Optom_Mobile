import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/storefront/domain/entities/storefront_product.dart';
import 'package:bsmart/features/storefront/domain/entities/storefront_shop.dart';
import 'package:bsmart/features/storefront/presentation/providers/storefront_categories_notifier.dart';
import 'package:bsmart/features/storefront/presentation/providers/storefront_search_providers.dart';
import 'package:bsmart/features/storefront/presentation/widgets/storefront_search_parts.dart';

enum _Sort { relevance, priceLow, priceHigh, name }

/// Storefront search (Phase 9 U2b, Swiggy search reference), guest-eligible.
///
/// Three states, driven by the field:
/// - empty → recent searches (device-local) and category shortcuts;
/// - typing → live suggestions (debounced `GET /public/catalog/products?search=`):
///   a "search for this" row, matching shops, matching products;
/// - submitted → results with Mahsulotlar / Do'konlar tabs and filter chips.
///   Shop rows, banners, group headers and shop suggestions open the shop
///   page. Sorting and the chips run on the loaded results (the public catalog has
///   no sort); the "Natijalar: …" header scopes the request to a top category.
class StorefrontSearchScreen extends StatelessWidget {
  const StorefrontSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Light page: dark status bar icons (the home hero above uses light ones).
      value: (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark).copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Theme(data: BrandTheme.of(context), child: const _SearchBody()),
    );
  }
}

class _SearchBody extends ConsumerStatefulWidget {
  const _SearchBody();

  @override
  ConsumerState<_SearchBody> createState() => _SearchBodyState();
}

class _SearchBodyState extends ConsumerState<_SearchBody> with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  late final _tabs = TabController(length: 2, vsync: this);
  Timer? _debounce;

  /// Debounced field text that drives the suggestions.
  String _typed = '';
  List<StorefrontProduct> _lastSuggestions = const [];

  /// Top category the request is scoped to (null = everywhere).
  String? _scopeCategoryId;

  _Sort _sort = _Sort.relevance;
  bool _inStockOnly = false;
  String? _categoryChip;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    _tabs.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    // Editing after a search goes back to suggestions.
    if (ref.read(storefrontSearchResultsProvider).valueOrNull != null ||
        ref.read(storefrontSearchResultsProvider).isLoading) {
      ref.read(storefrontSearchResultsProvider.notifier).reset();
    }
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _typed = value.trim());
    });
  }

  void _submit(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty && _scopeCategoryId == null) return;
    _debounce?.cancel();
    _controller.value = TextEditingValue(
      text: trimmed,
      selection: TextSelection.collapsed(offset: trimmed.length),
    );
    _focusNode.unfocus();
    setState(() {
      _typed = trimmed;
      _sort = _Sort.relevance;
      _inStockOnly = false;
      _categoryChip = null;
    });
    _tabs.index = 0;
    if (trimmed.isNotEmpty) ref.read(recentSearchesProvider.notifier).add(trimmed);
    ref.read(storefrontSearchResultsProvider.notifier).submit(trimmed, categoryId: _scopeCategoryId);
  }

  void _openShop(String sellerId, String name) => context.push(RouteNames.customerShop(sellerId, name: name));

  void _clear() {
    _controller.clear();
    _debounce?.cancel();
    setState(() => _typed = '');
    ref.read(storefrontSearchResultsProvider.notifier).reset();
    _focusNode.requestFocus();
  }

  /// Category shortcut: everything in that top category.
  void _browseCategory(String categoryId) {
    setState(() => _scopeCategoryId = categoryId);
    _submit('');
  }

  Future<void> _pickScope(List<StorefrontCategory> roots) async {
    final l10n = context.l10n;
    final picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => Theme(
        data: BrandTheme.of(context),
        child: ChoiceSheet(
          title: l10n.sfChooseCategory,
          options: {'': l10n.sfAllCategories, for (final c in roots) c.id: c.name},
          selected: _scopeCategoryId ?? '',
        ),
      ),
    );
    if (picked == null) return;
    final scope = picked.isEmpty ? null : picked;
    if (scope == _scopeCategoryId) return;
    setState(() => _scopeCategoryId = scope);
    if (ref.read(storefrontSearchResultsProvider).valueOrNull != null) _submit(_controller.text);
  }

  Future<void> _pickSort() async {
    final l10n = context.l10n;
    final labels = _sortLabels(l10n);
    final picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => Theme(
        data: BrandTheme.of(context),
        child: ChoiceSheet(
          title: l10n.sfSort,
          options: {for (final s in _Sort.values) s.name: labels[s]!},
          selected: _sort.name,
        ),
      ),
    );
    if (picked != null) setState(() => _sort = _Sort.values.byName(picked));
  }

  Map<_Sort, String> _sortLabels(AppLocalizations l10n) => {
    _Sort.relevance: l10n.sfSortRelevance,
    _Sort.priceLow: l10n.sfSortPriceLow,
    _Sort.priceHigh: l10n.sfSortPriceHigh,
    _Sort.name: l10n.sfSortName,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final results = ref.watch(storefrontSearchResultsProvider);
    final categories = ref.watch(storefrontCategoriesProvider).valueOrNull ?? const <StorefrontCategory>[];
    final roots = categories.where((c) => c.parentId == null).toList();
    final showResults = results.isLoading || results.hasError || results.valueOrNull != null;
    final scopeName = _scopeCategoryId == null
        ? l10n.sfAllCategories
        : roots.where((c) => c.id == _scopeCategoryId).map((c) => c.name).firstOrNull ?? l10n.sfAllCategories;

    return Scaffold(
      backgroundColor: colors.sheet,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 56,
              child: Row(
                children: [
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: () => context.pop(),
                    tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                    icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary),
                  ),
                  Expanded(
                    child: Center(
                      child: showResults
                          ? InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => _pickScope(roots),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        l10n.sfResultsIn(scopeName),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: colors.textPrimary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    Icon(Icons.arrow_drop_down_rounded, color: colors.accentText, size: 30),
                                  ],
                                ),
                              ),
                            )
                          : Text(
                              l10n.sfSearchTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                  const SizedBox(width: 52),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: _SearchBox(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: !showResults,
                onChanged: _onChanged,
                onSubmitted: _submit,
                onClear: _clear,
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: AppMotion.standard,
                child: showResults
                    ? KeyedSubtree(key: const ValueKey('results'), child: _results(results))
                    : _typed.isEmpty
                    ? KeyedSubtree(key: const ValueKey('empty'), child: _emptyState(roots))
                    : KeyedSubtree(key: const ValueKey('suggest'), child: _suggestions()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(List<StorefrontCategory> roots) {
    final l10n = context.l10n;
    final recent = ref.watch(recentSearchesProvider).valueOrNull ?? const <String>[];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        if (recent.isNotEmpty) ...[
          SearchSectionLabel(
            text: l10n.sfRecentSearches,
            trailing: TextButton(
              onPressed: () => ref.read(recentSearchesProvider.notifier).clear(),
              style: TextButton.styleFrom(padding: const EdgeInsets.only(left: 12), minimumSize: const Size(0, 36)),
              child: Text(l10n.sfClearRecent),
            ),
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final term in recent)
                SearchPill(label: term, icon: Icons.history_rounded, onTap: () => _submit(term)),
            ],
          ),
        ],
        if (roots.isNotEmpty) ...[
          SearchSectionLabel(text: l10n.sfBrowseCategories),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final category in roots)
                SearchPill(
                  label: category.name,
                  icon: Icons.category_outlined,
                  onTap: () => _browseCategory(category.id),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _suggestions() {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final async = ref.watch(storefrontSuggestionsProvider(_typed));
    if (async.hasValue) _lastSuggestions = async.value!;
    final items = async.valueOrNull ?? _lastSuggestions;
    final shops = StorefrontShop.fromProducts(items, limit: 4);
    final countBySeller = <String, int>{};
    for (final p in items) {
      countBySeller[p.sellerId] = (countBySeller[p.sellerId] ?? 0) + 1;
    }

    return Column(
      children: [
        SizedBox(height: 2, child: async.isLoading ? const LinearProgressIndicator(color: AppColors.brandAmber) : null),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              SuggestionRow(
                title: _typed,
                query: _typed,
                subtitle: l10n.sfSuggestionProduct,
                imageUrl: items.map((p) => p.imageUrl).firstWhere((u) => u != null, orElse: () => null),
                icon: Icons.search_rounded,
                highlighted: true,
                trailing: Icon(Icons.search_rounded, color: colors.textSecondary, size: 28),
                onTap: () => _submit(_typed),
              ),
              if (shops.isNotEmpty) ...[
                SearchSectionLabel(text: l10n.sfShopsFor(_typed), caps: false),
                for (final shop in shops)
                  SuggestionRow(
                    title: shop.name,
                    query: _typed,
                    subtitle: l10n.sfShopMatches(countBySeller[shop.sellerId] ?? 0),
                    imageUrl: shop.imageUrl,
                    icon: Icons.storefront_rounded,
                    square: true,
                    onTap: () => _openShop(shop.sellerId, shop.name),
                  ),
              ],
              if (items.isNotEmpty) ...[
                SearchSectionLabel(text: l10n.sfMoreResults, caps: false),
                for (final product in items)
                  SuggestionRow(
                    title: product.name,
                    query: _typed,
                    subtitle: '${CurrencyFormatter.format(product.price, product.currency)} • ${shopNameOf(product)}',
                    imageUrl: product.imageUrl,
                    onTap: () => context.push(RouteNames.customerProductDetail(product.id)),
                  ),
              ] else if (async.hasValue)
                Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: Text(
                    l10n.sfNoResults(_typed),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _results(AsyncValue<StorefrontSearchResults?> results) {
    final l10n = context.l10n;
    if (results.isLoading) return const SearchingView();
    if (results.hasError) {
      return _Message(
        icon: Icons.wifi_off_rounded,
        title: l10n.commonUnknownError,
        actionLabel: l10n.commonRetry,
        onAction: () => _submit(_controller.text),
      );
    }
    final data = results.value!;
    final visible = _visible(data.items);
    final groups = SearchShopGroup.of(visible);
    final chips = data.items.map((p) => p.categoryName).whereType<String>().toSet().take(12).toList();
    final hasFilters = _inStockOnly || _categoryChip != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ResultTabs(controller: _tabs, labels: [l10n.navProducts, l10n.sfShops]),
        _filterBar(chips),
        Expanded(
          child: visible.isEmpty
              ? _Message(
                  icon: Icons.search_off_rounded,
                  title: l10n.sfNoResults(data.query.search ?? ''),
                  subtitle: l10n.sfNoResultsHint,
                  actionLabel: hasFilters ? l10n.sfRemoveFilter : null,
                  onAction: () => setState(() {
                    _inStockOnly = false;
                    _categoryChip = null;
                  }),
                )
              : NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification.metrics.extentAfter < 500) {
                      ref.read(storefrontSearchResultsProvider.notifier).loadMore();
                    }
                    return false;
                  },
                  child: TabBarView(controller: _tabs, children: [_productsTab(groups, data), _shopsTab(groups)]),
                ),
        ),
      ],
    );
  }

  List<StorefrontProduct> _visible(List<StorefrontProduct> items) {
    final filtered = items
        .where((p) => (!_inStockOnly || p.stock > 0) && (_categoryChip == null || p.categoryName == _categoryChip))
        .toList();
    switch (_sort) {
      case _Sort.relevance:
        break;
      case _Sort.priceLow:
        filtered.sort((a, b) => a.price.compareTo(b.price));
      case _Sort.priceHigh:
        filtered.sort((a, b) => b.price.compareTo(a.price));
      case _Sort.name:
        filtered.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }
    return filtered;
  }

  Widget _filterBar(List<String> categoryChips) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final sortLabel = _sort == _Sort.relevance ? l10n.sfSort : _sortLabels(l10n)[_sort]!;
    return ColoredBox(
      color: colors.field,
      child: SizedBox(
        height: 68,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            ResultFilterChip(
              label: sortLabel,
              trailingIcon: Icons.keyboard_arrow_down_rounded,
              selected: _sort != _Sort.relevance,
              onTap: _pickSort,
            ),
            const SizedBox(width: 10),
            ResultFilterChip(
              label: l10n.sfInStockOnly,
              icon: _inStockOnly ? Icons.check_rounded : Icons.inventory_2_outlined,
              selected: _inStockOnly,
              onTap: () => setState(() => _inStockOnly = !_inStockOnly),
            ),
            for (final chip in categoryChips) ...[
              const SizedBox(width: 10),
              ResultFilterChip(
                label: chip,
                accent: true,
                selected: _categoryChip == chip,
                onTap: () => setState(() => _categoryChip = _categoryChip == chip ? null : chip),
                onClear: _categoryChip == chip ? () => setState(() => _categoryChip = null) : null,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _productsTab(List<SearchShopGroup> groups, StorefrontSearchResults data) {
    final colors = BrandColors.of(context);
    final l10n = context.l10n;
    final query = data.query.search ?? '';
    return CustomScrollView(
      key: const PageStorageKey('search-products'),
      slivers: [
        for (final group in groups) ...[
          SliverToBoxAdapter(
            child: InkWell(
              onTap: () => _openShop(group.sellerId, group.name),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.sfShopMatches(group.products.length),
                            style: TextStyle(color: colors.textSecondary, fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Tooltip(
                      message: l10n.sfShopProducts,
                      child: Icon(Icons.arrow_forward_rounded, color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverList.builder(
            itemCount: group.products.length,
            itemBuilder: (context, index) => SearchProductCard(
              product: group.products[index],
              query: query,
            ).animate().fadeIn(duration: AppMotion.standard).slideY(begin: 0.05, end: 0, curve: AppMotion.emphasized),
          ),
        ],
        if (data.isLoadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  Widget _shopsTab(List<SearchShopGroup> groups) {
    final l10n = context.l10n;
    return ListView(
      key: const PageStorageKey('search-shops'),
      padding: const EdgeInsets.only(top: 18, bottom: 24),
      children: [
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: groups.length.clamp(0, 6),
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, index) => SearchShopBanner(
              group: groups[index],
              onTap: () => _openShop(groups[index].sellerId, groups[index].name),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SearchSectionLabel(text: l10n.sfFeaturedShops),
        ),
        for (final group in groups) SearchShopRow(group: group, onTap: () => _openShop(group.sellerId, group.name)),
      ],
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox({
    required this.controller,
    required this.focusNode,
    required this.autofocus,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool autofocus;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    final l10n = context.l10n;
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: colors.sheet,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outline, width: 1.2),
      ),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) => Row(
          children: [
            const SizedBox(width: 16),
            Icon(Icons.search_rounded, color: colors.textSecondary, size: 26),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                autofocus: autofocus,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
                textInputAction: TextInputAction.search,
                cursorColor: colors.accentText,
                style: TextStyle(color: colors.textPrimary, fontSize: 17, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: l10n.sfSearchFieldHint,
                  hintStyle: TextStyle(color: colors.textMuted, fontSize: 17, fontWeight: FontWeight.w500),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isCollapsed: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            if (value.text.isNotEmpty)
              IconButton(
                tooltip: l10n.authClear,
                onPressed: onClear,
                icon: Icon(Icons.close_rounded, color: colors.textSecondary, size: 26),
              )
            else
              const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}

/// Left-aligned underline tabs (the reference's "Restaurants | Dishes").
class _ResultTabs extends StatelessWidget {
  const _ResultTabs({required this.controller, required this.labels});

  final TabController controller;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    return TabBar(
      controller: controller,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      labelPadding: const EdgeInsets.symmetric(horizontal: 14),
      labelColor: colors.textPrimary,
      unselectedLabelColor: colors.textSecondary,
      labelStyle: const TextStyle(fontFamily: BrandTheme.fontFamily, fontSize: 18, fontWeight: FontWeight.w800),
      unselectedLabelStyle: const TextStyle(
        fontFamily: BrandTheme.fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: colors.textPrimary, width: 4),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      ),
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: Colors.transparent,
      tabs: [for (final label in labels) Tab(height: 52, text: label)],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.title, this.subtitle, this.actionLabel, this.onAction});

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(32, 48, 32, 24),
      children: [
        Center(
          child: Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(color: colors.field, shape: BoxShape.circle),
            child: Icon(icon, size: 40, color: colors.textSecondary),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(color: colors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.textSecondary, fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ],
        if (actionLabel != null) ...[
          const SizedBox(height: 12),
          Center(
            child: TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ),
        ],
      ],
    );
  }
}
