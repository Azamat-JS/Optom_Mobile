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
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/favorites/presentation/providers/favorites_list_notifier.dart';
import 'package:bsmart/features/storefront/domain/entities/storefront_product.dart';
import 'package:bsmart/features/storefront/domain/entities/storefront_shop.dart';
import 'package:bsmart/features/storefront/presentation/providers/storefront_categories_notifier.dart';
import 'package:bsmart/features/storefront/presentation/providers/storefront_products_notifier.dart';
import 'package:bsmart/features/storefront/presentation/widgets/storefront_category_circles.dart';
import 'package:bsmart/features/storefront/presentation/widgets/storefront_hero.dart';
import 'package:bsmart/features/storefront/presentation/widgets/storefront_product_card.dart';
import 'package:bsmart/features/storefront/presentation/widgets/storefront_product_rail.dart';
import 'package:bsmart/features/storefront/presentation/widgets/storefront_skeleton.dart';

/// The "Katalog" tab of the storefront — guest-eligible product feed
/// (`GET /public/catalog/products?sellerRole=RETAILER`), no seller-picker step
/// (see `StorefrontProductsNotifier`'s doc comment for why this differs from
/// the B2B catalog browse).
///
/// Layout (Phase 9 U2a, Swiggy home reference): dark hero with top-level
/// category tabs, a search button (→ `StorefrontSearchScreen`) and a shop strip; a "new / favourites" rail; pinned
/// subcategory circles; the full feed as big cards. Filters: top category →
/// subcategory (sent as one `categoryId`); a shop card opens the shop page.
///
/// Must sit under a [BrandTheme] (`CustomerHomeScreen` provides it).
class StorefrontCatalogTab extends ConsumerStatefulWidget {
  const StorefrontCatalogTab({required this.onOpenProfile, super.key});

  final VoidCallback onOpenProfile;

  @override
  ConsumerState<StorefrontCatalogTab> createState() => _StorefrontCatalogTabState();
}

class _StorefrontCatalogTabState extends ConsumerState<StorefrontCatalogTab> {
  final _scrollController = ScrollController();
  final _heroKey = GlobalKey();

  /// True once the dark hero has scrolled away — flips the status bar strip
  /// and icons to the light content below.
  final _pastHero = ValueNotifier(false);

  String? _rootCategoryId;
  String? _subCategoryId;

  /// Shop strip contents, kept while a shop filter narrows the feed to one
  /// shop (otherwise the strip would collapse to that single shop).
  List<StorefrontShop> _shops = const [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pastHero.dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 400) {
      ref.read(storefrontProductsProvider.notifier).loadMore();
    }
    final heroHeight = _heroKey.currentContext?.size?.height ?? 0;
    final topInset = MediaQuery.paddingOf(context).top;
    _pastHero.value = heroHeight > 0 && position.pixels > heroHeight - topInset;
  }

  void _selectRoot(String? id) {
    if (id == _rootCategoryId && _subCategoryId == null) return;
    setState(() {
      _rootCategoryId = id;
      _subCategoryId = null;
    });
    ref.read(storefrontProductsProvider.notifier).filterByCategory(id);
  }

  void _selectSub(String? id) {
    setState(() => _subCategoryId = id);
    ref.read(storefrontProductsProvider.notifier).filterByCategory(id ?? _rootCategoryId);
  }

  Future<void> _clearFilters() async {
    setState(() {
      _rootCategoryId = null;
      _subCategoryId = null;
    });
    await ref.read(storefrontProductsProvider.notifier).resetFilters();
  }

  Future<void> _refresh() async {
    ref.invalidate(storefrontCategoriesProvider);
    if (ref.read(sessionNotifierProvider).valueOrNull?.isAuthenticated ?? false) {
      ref.invalidate(favoritesListProvider);
    }
    await ref.read(storefrontProductsProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final categories = ref.watch(storefrontCategoriesProvider).valueOrNull ?? const <StorefrontCategory>[];
    final roots = categories.where((c) => c.parentId == null).toList();
    final subs = _rootCategoryId == null
        ? const <StorefrontCategory>[]
        : categories.where((c) => c.parentId == _rootCategoryId).toList();
    final productsAsync = ref.watch(storefrontProductsProvider);
    final feed = productsAsync.valueOrNull;
    if (feed != null && feed.query.sellerId == null && feed.items.isNotEmpty) {
      _shops = StorefrontShop.fromProducts(feed.items);
    }
    final firstName = ref.watch(sessionNotifierProvider.select((s) => s.valueOrNull?.user?.firstName.trim()));
    final greeting = (firstName?.isNotEmpty ?? false) ? l10n.sfGreeting(firstName!) : l10n.sfGreetingGuest;
    final hints = categories.map((c) => c.name).where((n) => n.trim().isNotEmpty).take(8).toList();

    return ValueListenableBuilder<bool>(
      valueListenable: _pastHero,
      builder: (context, pastHero, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value:
            (pastHero && Theme.of(context).brightness == Brightness.light
                    ? SystemUiOverlayStyle.dark
                    : SystemUiOverlayStyle.light)
                .copyWith(statusBarColor: Colors.transparent),
        child: Stack(
          children: [
            child!,
            // Status bar backdrop: hero black at the top, page colour after.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.paddingOf(context).top,
              child: AnimatedContainer(duration: AppMotion.fast, color: pastHero ? colors.sheet : AppColors.ink),
            ),
          ],
        ),
      ),
      child: ColoredBox(
        color: colors.sheet,
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: AppColors.onBrand,
          backgroundColor: AppColors.brandYellow,
          edgeOffset: MediaQuery.paddingOf(context).top,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverToBoxAdapter(
                child: StorefrontHero(
                  key: _heroKey,
                  greeting: greeting,
                  onProfile: widget.onOpenProfile,
                  categories: roots,
                  selectedCategoryId: _rootCategoryId,
                  onCategorySelected: _selectRoot,
                  onSearchTap: () => context.push(RouteNames.customerSearch),
                  searchHints: hints,
                  shops: _shops,
                  onShopTap: (shop) => context.push(RouteNames.customerShop(shop.sellerId, name: shop.name)),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 22)),
              if (feed != null && feed.items.isNotEmpty && !productsAsync.isLoading) ...[
                SliverToBoxAdapter(child: StorefrontProductRail(newest: feed.items.take(10).toList())),
                // The circles header brings its own status-bar-high top gap.
                if (subs.isEmpty) const SliverToBoxAdapter(child: SizedBox(height: 18)),
              ],
              if (subs.isNotEmpty)
                SliverPersistentHeader(
                  pinned: true,
                  delegate: StorefrontCategoryCirclesHeader(
                    categories: subs,
                    selectedId: _subCategoryId,
                    onSelected: _selectSub,
                    background: colors.sheet,
                    divider: colors.outline,
                    topInset: MediaQuery.paddingOf(context).top,
                  ),
                ),
              ...productsAsync.when(
                skipLoadingOnRefresh: true,
                loading: () => [
                  const SliverToBoxAdapter(
                    child: Padding(padding: EdgeInsets.only(top: 8), child: StorefrontFeedSkeleton()),
                  ),
                ],
                error: (error, _) => [
                  SliverToBoxAdapter(
                    child: _FeedMessage(
                      icon: Icons.wifi_off_rounded,
                      title: l10n.commonUnknownError,
                      actionLabel: l10n.commonRetry,
                      onAction: () => ref.invalidate(storefrontProductsProvider),
                    ),
                  ),
                ],
                data: (state) => [
                  SliverToBoxAdapter(child: _FeedHeader(total: state.total)),
                  if (state.items.isEmpty)
                    SliverToBoxAdapter(
                      child: _FeedMessage(
                        icon: Icons.search_off_rounded,
                        title: l10n.sfNoProducts,
                        actionLabel: _hasFilters(state) ? l10n.sfRemoveFilter : null,
                        onAction: _clearFilters,
                      ),
                    )
                  else
                    SliverList.builder(
                      itemCount: state.items.length,
                      itemBuilder: (context, index) => StorefrontProductCard(product: state.items[index])
                          .animate()
                          .fadeIn(duration: AppMotion.standard)
                          .slideY(begin: 0.04, end: 0, curve: AppMotion.emphasized),
                    ),
                  if (state.isLoadingMore)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                ],
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }

  bool _hasFilters(StorefrontProductsState state) =>
      state.query.categoryId != null || state.query.sellerId != null || (state.query.search?.isNotEmpty ?? false);
}

/// "12 ta mahsulot / Siz uchun saralangan mahsulotlar".
class _FeedHeader extends StatelessWidget {
  const _FeedHeader({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.commonProductCount(total),
            style: TextStyle(color: colors.textPrimary, fontSize: 21, fontWeight: FontWeight.w800, letterSpacing: -0.4),
          ),
          const SizedBox(height: 2),
          Text(
            l10n.sfProductsSubtitle,
            style: TextStyle(color: colors.textSecondary, fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _FeedMessage extends StatelessWidget {
  const _FeedMessage({required this.icon, required this.title, this.actionLabel, this.onAction});

  final IconData icon;
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 32, 32, 16),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(color: colors.field, shape: BoxShape.circle),
            child: Icon(icon, size: 34, color: colors.textSecondary),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 10),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
