import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/favorites/presentation/providers/favorite_ids_notifier.dart';
import 'package:bsmart/features/storefront/domain/entities/storefront_branch.dart';
import 'package:bsmart/features/storefront/domain/entities/storefront_product.dart';
import 'package:bsmart/features/storefront/presentation/providers/storefront_cart_notifier.dart';
import 'package:bsmart/features/storefront/presentation/providers/storefront_shop_providers.dart';
import 'package:bsmart/features/storefront/presentation/widgets/storefront_search_parts.dart';
import 'package:bsmart/features/storefront/presentation/widgets/storefront_shop_parts.dart';

enum _Sort { relevance, priceLow, priceHigh, name }

/// A shop's page (Phase 9 U2c, Swiggy restaurant page reference),
/// guest-eligible. Route `/customer/shops/:sellerId?storeId=&name=`.
///
/// Dark header with the shop card (branch picker when the owner has several
/// branches, call button), a pinned search + filter bar, then the products
/// grouped into collapsible category sections. The
/// "MENYU" button lists the sections and scrolls to the chosen one.
///
/// Search, filters and sorting run on the device over the whole loaded list
/// ([shopProductsProvider]).
class StorefrontShopScreen extends StatelessWidget {
  const StorefrontShopScreen({required this.sellerId, this.storeId, this.name, super.key});

  final String sellerId;
  final String? storeId;

  /// Shown until the products (and so the real name) have loaded.
  final String? name;

  @override
  Widget build(BuildContext context) => Theme(
    data: BrandTheme.of(context),
    child: _ShopBody(sellerId: sellerId, storeId: storeId, name: name),
  );
}

class _ShopBody extends ConsumerStatefulWidget {
  const _ShopBody({required this.sellerId, required this.storeId, required this.name});

  final String sellerId;
  final String? storeId;
  final String? name;

  @override
  ConsumerState<_ShopBody> createState() => _ShopBodyState();
}

class _ShopBodyState extends ConsumerState<_ShopBody> {
  static const _gridPadding = 16.0;
  static const _gridSpacing = 12.0;
  static const _rowSpacing = 18.0;
  static const _gridTop = 4.0;
  static const _gridBottom = 22.0;

  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  final _heroKey = GlobalKey();
  final _pastHero = ValueNotifier(false);

  /// Picked in the branch sheet; null = the route's branch (or the default).
  String? _pickedStoreId;
  String _query = '';
  bool _inStockOnly = false;
  bool _favoritesOnly = false;
  _Sort _sort = _Sort.relevance;
  final Set<String> _collapsed = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _pastHero.dispose();
    super.dispose();
  }

  void _onScroll() {
    final heroHeight = _heroKey.currentContext?.size?.height ?? 0;
    _pastHero.value = heroHeight > 0 && _scrollController.offset > heroHeight - MediaQuery.paddingOf(context).top;
  }

  /// The branch whose products are shown. A multi-branch owner opened without
  /// a branch shows its default (first) one rather than everything mixed.
  String? _effectiveStoreId(List<StorefrontBranch> branches) =>
      _pickedStoreId ?? widget.storeId ?? (branches.length > 1 ? branches.first.id : null);

  List<ShopSection> _sections(List<StorefrontProduct> products, Set<String> favoriteIds, String otherTitle) {
    final needle = _query.trim().toLowerCase();
    final visible = products
        .where(
          (p) =>
              (needle.isEmpty || p.name.toLowerCase().contains(needle)) &&
              (!_inStockOnly || p.stock > 0) &&
              (!_favoritesOnly || favoriteIds.contains(p.id)),
        )
        .toList();
    switch (_sort) {
      case _Sort.relevance:
        break;
      case _Sort.priceLow:
        visible.sort((a, b) => a.price.compareTo(b.price));
      case _Sort.priceHigh:
        visible.sort((a, b) => b.price.compareTo(a.price));
      case _Sort.name:
        visible.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }
    final groups = <String, List<StorefrontProduct>>{};
    for (final p in visible) {
      groups.putIfAbsent(p.categoryName ?? otherTitle, () => []).add(p);
    }
    final sections = groups.entries.map((e) => ShopSection(title: e.key, products: e.value)).toList()
      ..sort((a, b) {
        if (a.title == otherTitle) return 1;
        if (b.title == otherTitle) return -1;
        final byCount = b.products.length.compareTo(a.products.length);
        return byCount != 0 ? byCount : a.title.compareTo(b.title);
      });
    return sections;
  }

  double _cardWidth(BuildContext context) => (MediaQuery.sizeOf(context).width - _gridPadding * 2 - _gridSpacing) / 2;

  /// Scrolls so section [index]'s header sits right under the pinned search
  /// bar. Every block has a known height (fixed card extent), so the offset
  /// is computed instead of waiting for lazily built sections.
  void _scrollToSection(List<ShopSection> sections, int index) {
    final heroHeight = _heroKey.currentContext?.size?.height ?? 0;
    final cardHeight = ShopProductCard.heightFor(_cardWidth(context));
    var offset = heroHeight;
    for (var i = 0; i < index; i++) {
      offset += ShopSectionHeader.height;
      if (!_collapsed.contains(sections[i].title)) {
        final rows = (sections[i].products.length / 2).ceil();
        offset += _gridTop + rows * cardHeight + (rows - 1) * _rowSpacing + _gridBottom;
      }
    }
    final position = _scrollController.position;
    _scrollController.animateTo(
      offset.clamp(0, position.maxScrollExtent),
      duration: AppMotion.slow,
      curve: AppMotion.emphasized,
    );
  }

  Future<void> _openMenu(List<ShopSection> sections) async {
    final picked = await showGeneralDialog<int>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: AppMotion.standard,
      pageBuilder: (dialogContext, _, _) => SafeArea(
        child: Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(40, 0, 18, 110),
            child: Theme(
              data: BrandTheme.of(context),
              child: ShopMenuPanel(sections: sections),
            ),
          ),
        ),
      ),
      transitionBuilder: (_, animation, _, child) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          alignment: Alignment.bottomRight,
          scale: Tween(begin: 0.9, end: 1.0).animate(CurvedAnimation(parent: animation, curve: AppMotion.emphasized)),
          child: child,
        ),
      ),
    );
    if (picked != null && mounted) _scrollToSection(sections, picked);
  }

  Future<void> _pickBranch(List<StorefrontBranch> branches, String? currentId) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => Theme(
        data: BrandTheme.of(context),
        child: BranchSheet(branches: branches, currentId: currentId),
      ),
    );
    if (picked == null || picked == currentId || !mounted) return;
    setState(() {
      _pickedStoreId = picked;
      _collapsed.clear();
    });
    _scrollController.jumpTo(0);
  }

  Future<void> _pickSort() async {
    final l10n = context.l10n;
    final labels = _sortLabels(l10n);
    final picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) => Theme(
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

  Future<void> _call(String phone) async {
    final opened = await launchUrl(Uri(scheme: 'tel', path: phone));
    if (!opened && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(context.l10n.sfCallFailed)));
    }
  }

  void _toggleFavoritesOnly(bool loggedIn) {
    if (!loggedIn) {
      context.push(RouteNames.login);
      return;
    }
    setState(() => _favoritesOnly = !_favoritesOnly);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final branches = ref.watch(shopBranchesProvider(widget.sellerId)).valueOrNull ?? const <StorefrontBranch>[];
    final storeId = _effectiveStoreId(branches);
    final productsAsync = ref.watch(shopProductsProvider((sellerId: widget.sellerId, storeId: storeId)));
    final products = productsAsync.valueOrNull ?? const <StorefrontProduct>[];
    final loggedIn = ref.watch(sessionNotifierProvider.select((s) => s.valueOrNull?.isAuthenticated ?? false));
    final favoriteIds = loggedIn ? ref.watch(favoriteIdsProvider).valueOrNull ?? const <String>{} : const <String>{};
    final cartSellerId = ref.watch(storefrontCartProvider.select((c) => c.sellerId));

    final branch = branches.where((b) => b.id == storeId).firstOrNull ?? branches.firstOrNull;
    final first = products.firstOrNull;
    final title =
        branch?.name ??
        (first?.storeName?.trim().isNotEmpty ?? false ? first!.storeName! : null) ??
        widget.name ??
        first?.sellerName ??
        '';
    final sections = _sections(products, favoriteIds, l10n.sfOtherCategory);
    final allSections = _sections(products, const {}, l10n.sfOtherCategory);
    final canPickBranch = branches.length > 1;
    final String? notice;
    if (cartSellerId != null && cartSellerId != widget.sellerId) {
      notice = l10n.sfCartHasOtherShop;
    } else if (canPickBranch) {
      notice = l10n.sfBranchesCount(branches.length);
    } else {
      notice = null;
    }
    final cardWidth = _cardWidth(context);
    final topInset = MediaQuery.paddingOf(context).top;
    final filtersActive = _query.isNotEmpty || _inStockOnly || _favoritesOnly;

    return ValueListenableBuilder<bool>(
      valueListenable: _pastHero,
      builder: (context, pastHero, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value:
            (pastHero && Theme.of(context).brightness == Brightness.light
                    ? SystemUiOverlayStyle.dark
                    : SystemUiOverlayStyle.light)
                .copyWith(statusBarColor: Colors.transparent),
        child: child!,
      ),
      child: Scaffold(
        backgroundColor: colors.sheet,
        body: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverToBoxAdapter(
                  child: ShopHeader(
                    key: _heroKey,
                    name: title,
                    categoriesLine: allSections.isEmpty ? null : allSections.take(3).map((s) => s.title).join(' · '),
                    branchName: branch?.address ?? (canPickBranch ? l10n.sfChooseBranch : null),
                    branchAddress: null,
                    canPickBranch: canPickBranch,
                    onPickBranch: () => _pickBranch(branches, storeId ?? branch?.id),
                    productCount: productsAsync.hasValue ? products.length : null,
                    ownerName: first?.sellerName,
                    ownerPhone: first?.sellerPhone,
                    onCall: (first?.sellerPhone.isNotEmpty ?? false) ? () => _call(first!.sellerPhone) : null,
                    notice: notice,
                    onNoticeTap: canPickBranch && notice == l10n.sfBranchesCount(branches.length)
                        ? () => _pickBranch(branches, storeId ?? branch?.id)
                        : null,
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: ShopSearchHeader(
                    topInset: topInset,
                    background: colors.sheet,
                    child: _searchBar(title, loggedIn),
                  ),
                ),
                ...productsAsync.when(
                  loading: () => [SliverToBoxAdapter(child: _GridSkeleton(cardWidth: cardWidth))],
                  error: (_, _) => [
                    SliverToBoxAdapter(
                      child: _ShopMessage(
                        icon: Icons.wifi_off_rounded,
                        title: l10n.commonUnknownError,
                        actionLabel: l10n.commonRetry,
                        onAction: () =>
                            ref.invalidate(shopProductsProvider((sellerId: widget.sellerId, storeId: storeId))),
                      ),
                    ),
                  ],
                  data: (_) => [
                    if (products.isEmpty)
                      SliverToBoxAdapter(
                        child: _ShopMessage(icon: Icons.inventory_2_outlined, title: l10n.sfShopEmpty),
                      )
                    else if (sections.isEmpty)
                      SliverToBoxAdapter(
                        child: _ShopMessage(
                          icon: Icons.search_off_rounded,
                          title: l10n.sfNoProducts,
                          actionLabel: filtersActive ? l10n.sfRemoveFilter : null,
                          onAction: () {
                            _searchController.clear();
                            setState(() {
                              _query = '';
                              _inStockOnly = false;
                              _favoritesOnly = false;
                            });
                          },
                        ),
                      )
                    else
                      for (final section in sections) ...[
                        SliverToBoxAdapter(
                          child: ShopSectionHeader(
                            title: section.title,
                            count: section.products.length,
                            expanded: !_collapsed.contains(section.title),
                            onToggle: () => setState(() {
                              _collapsed.contains(section.title)
                                  ? _collapsed.remove(section.title)
                                  : _collapsed.add(section.title);
                            }),
                          ),
                        ),
                        if (!_collapsed.contains(section.title))
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(_gridPadding, _gridTop, _gridPadding, _gridBottom),
                            sliver: SliverGrid.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: _gridSpacing,
                                mainAxisSpacing: _rowSpacing,
                                mainAxisExtent: ShopProductCard.heightFor(cardWidth),
                              ),
                              itemCount: section.products.length,
                              itemBuilder: (context, index) => ShopProductCard(
                                product: section.products[index],
                                query: _query,
                                width: cardWidth,
                              ).animate().fadeIn(duration: AppMotion.standard),
                            ),
                          ),
                      ],
                  ],
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
            if (sections.length > 1)
              Positioned(
                right: 18,
                bottom: 18 + MediaQuery.paddingOf(context).bottom,
                child: ShopMenuButton(onPressed: () => _openMenu(sections)).animate().scale(
                  begin: const Offset(0.6, 0.6),
                  duration: AppMotion.standard,
                  curve: AppMotion.emphasized,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _searchBar(String shopName, bool loggedIn) {
    final colors = BrandColors.of(context);
    final l10n = context.l10n;
    final sortLabel = _sort == _Sort.relevance ? l10n.sfSort : _sortLabels(l10n)[_sort]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Container(
            height: 54,
            decoration: BoxDecoration(color: colors.field, borderRadius: BorderRadius.circular(18)),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Icon(Icons.search_rounded, color: colors.textSecondary, size: 26),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                    textInputAction: TextInputAction.search,
                    cursorColor: colors.accentText,
                    style: TextStyle(color: colors.textPrimary, fontSize: 16.5, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: l10n.sfSearchInShop(shopName),
                      hintMaxLines: 1,
                      hintStyle: TextStyle(color: colors.textMuted, fontSize: 16.5, fontWeight: FontWeight.w500),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isCollapsed: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
                if (_query.isNotEmpty)
                  IconButton(
                    tooltip: l10n.authClear,
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                    icon: Icon(Icons.close_rounded, color: colors.textSecondary),
                  )
                else
                  const SizedBox(width: 12),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 74,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            children: [
              ResultFilterChip(
                label: l10n.sfInStockOnly,
                icon: _inStockOnly ? Icons.check_rounded : Icons.inventory_2_outlined,
                selected: _inStockOnly,
                onTap: () => setState(() => _inStockOnly = !_inStockOnly),
              ),
              const SizedBox(width: 10),
              ResultFilterChip(
                label: l10n.navFavorites,
                icon: _favoritesOnly ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                selected: _favoritesOnly,
                onTap: () => _toggleFavoritesOnly(loggedIn),
              ),
              const SizedBox(width: 10),
              ResultFilterChip(
                label: sortLabel,
                trailingIcon: Icons.keyboard_arrow_down_rounded,
                selected: _sort != _Sort.relevance,
                onTap: _pickSort,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GridSkeleton extends StatelessWidget {
  const _GridSkeleton({required this.cardWidth});

  final double cardWidth;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    Widget box(double w, double h) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(color: colors.field, borderRadius: BorderRadius.circular(18)),
    );
    Widget card() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        box(cardWidth, cardWidth),
        const SizedBox(height: 10),
        box(cardWidth * 0.8, 16),
        const SizedBox(height: 8),
        box(cardWidth * 0.5, 16),
      ],
    );
    return Shimmer.fromColors(
      baseColor: colors.field,
      highlightColor: colors.sheet,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            box(160, 24),
            const SizedBox(height: 16),
            for (var row = 0; row < 2; row++) ...[
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [card(), card()]),
              const SizedBox(height: 18),
            ],
          ],
        ),
      ),
    );
  }
}

class _ShopMessage extends StatelessWidget {
  const _ShopMessage({required this.icon, required this.title, this.actionLabel, this.onAction});

  final IconData icon;
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 40, 32, 16),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(color: colors.field, shape: BoxShape.circle),
            child: Icon(icon, size: 38, color: colors.textSecondary),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.textPrimary, fontSize: 17, fontWeight: FontWeight.w700),
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 8),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
