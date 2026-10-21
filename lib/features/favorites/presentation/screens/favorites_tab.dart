import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/favorites/domain/entities/favorite_product.dart';
import 'package:bsmart/features/favorites/presentation/providers/favorite_ids_notifier.dart';
import 'package:bsmart/features/favorites/presentation/providers/favorites_list_notifier.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// The "Sevimlilar" tab — authenticated only (`favorite.controller.ts` is
/// `CUSTOMER, RETAILER` only). A guest sees a login prompt instead of the
/// list ever attempting an unauthenticated fetch.
///
/// Phase 9 U4c6: large title, a 2-column grid of product cards with a red
/// heart that removes the favourite, and empty/guest states that lead back
/// to the catalog or to login.
class FavoritesTab extends ConsumerWidget {
  const FavoritesTab({super.key, this.onStartShopping});

  /// Switches the shell to the Katalog tab (empty state).
  final VoidCallback? onStartShopping;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isLoggedIn = ref.watch(sessionNotifierProvider).valueOrNull?.isAuthenticated ?? false;

    return DashPage(
      title: l10n.navFavorites,
      showBack: false,
      body: !isLoggedIn
          ? DashEmptyState(
              icon: Icons.favorite_rounded,
              text: 'Sevimlilarni koʻrish uchun tizimga kiring',
              action: FilledButton(
                onPressed: () => context.push(RouteNames.login),
                style: FilledButton.styleFrom(minimumSize: const Size(160, 48)),
                child: Text(l10n.commonLogin),
              ),
            )
          : _list(context, ref),
    );
  }

  Widget _list(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritesListProvider);
    return favoritesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => DashEmptyState(icon: Icons.cloud_off_rounded, text: 'Xatolik: $error'),
      data: (favorites) => RefreshIndicator(
        color: AppColors.onBrand,
        backgroundColor: AppColors.brandYellow,
        onRefresh: () => ref.read(favoritesListProvider.notifier).refresh(),
        child: favorites.isEmpty
            ? DashEmptyState(
                icon: Icons.favorite_border_rounded,
                text: "Sevimlilar ro'yxati bo'sh",
                action: onStartShopping == null
                    ? null
                    : FilledButton.icon(
                        onPressed: onStartShopping,
                        style: FilledButton.styleFrom(minimumSize: const Size(180, 48)),
                        icon: const Icon(Icons.storefront_rounded),
                        label: Text(context.l10n.navCatalog),
                      ),
              )
            : GridView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                itemCount: favorites.length,
                itemBuilder: (context, index) => _FavoriteCard(
                  product: favorites[index],
                ).animate().fadeIn(delay: (30 * (index % 10)).ms, duration: AppMotion.standard),
              ),
      ),
    );
  }
}

class _FavoriteCard extends ConsumerWidget {
  const _FavoriteCard({required this.product});

  final FavoriteProduct product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = BrandColors.of(context);
    return DashCard(
      padding: const EdgeInsets.all(10),
      onTap: () => context.push(RouteNames.customerProductDetail(product.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                LayoutBuilder(
                  builder: (context, c) => DashThumb(url: product.imageUrl, size: c.maxWidth, radius: 16),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Material(
                    color: DashColors.card(context),
                    shape: const CircleBorder(),
                    elevation: 1,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      // The notifier also refreshes this list (see its doc comment).
                      onTap: () => ref.read(favoriteIdsProvider.notifier).toggle(product.id),
                      child: const SizedBox(
                        width: 34,
                        height: 34,
                        child: Icon(Icons.favorite_rounded, color: Color(0xFFE5484D), size: 19),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (product.categoryName != null)
            Text(
              product.categoryName!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: colors.textMuted, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          Text(
            product.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colors.textPrimary, fontSize: 14.5, fontWeight: FontWeight.w700, height: 1.25),
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.format(product.price, product.currency),
            style: TextStyle(color: colors.textPrimary, fontSize: 15.5, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
