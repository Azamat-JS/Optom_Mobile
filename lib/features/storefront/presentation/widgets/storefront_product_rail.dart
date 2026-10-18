import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/favorites/presentation/providers/favorites_list_notifier.dart';
import 'package:bsmart/features/storefront/domain/entities/storefront_product.dart';
import 'package:bsmart/features/storefront/presentation/widgets/storefront_actions.dart';
import 'package:bsmart/features/storefront/presentation/widgets/storefront_image.dart';

/// "YANGI KELGANLAR | SEVIMLILAR" switch over a horizontal row of photo cards
/// (the reference's "Top rated | Food in 15 mins").
class StorefrontProductRail extends ConsumerStatefulWidget {
  const StorefrontProductRail({required this.newest, super.key});

  /// First products of the current feed (newest first).
  final List<StorefrontProduct> newest;

  @override
  ConsumerState<StorefrontProductRail> createState() => _StorefrontProductRailState();
}

class _StorefrontProductRailState extends ConsumerState<StorefrontProductRail> {
  bool _showFavorites = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _Segmented(
            labels: [l10n.sfNewArrivals, l10n.navFavorites],
            selected: _showFavorites ? 1 : 0,
            onChanged: (index) => setState(() => _showFavorites = index == 1),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 256,
          child: AnimatedSwitcher(
            duration: AppMotion.standard,
            child: _showFavorites ? const _FavoritesRow(key: ValueKey('fav')) : _row(widget.newest),
          ),
        ),
      ],
    );
  }

  Widget _row(List<StorefrontProduct> products) {
    final items = products
        .map(
          (p) => _RailItem(
            id: p.id,
            name: p.name,
            subtitle: p.storeName ?? p.sellerName,
            imageUrl: p.imageUrl,
            price: p.price,
            currency: p.currency,
          ),
        )
        .toList();
    return _RailList(key: const ValueKey('new'), items: items);
  }
}

class _FavoritesRow extends ConsumerWidget {
  const _FavoritesRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final loggedIn = ref.watch(sessionNotifierProvider.select((s) => s.valueOrNull?.isAuthenticated ?? false));
    if (!loggedIn) {
      return _RailMessage(
        icon: Icons.favorite_border_rounded,
        text: l10n.sfFavoritesLogin,
        action: FilledButton(
          onPressed: () => context.push(RouteNames.login),
          style: FilledButton.styleFrom(minimumSize: const Size(140, 46)),
          child: Text(l10n.commonLogin),
        ),
      );
    }
    final favorites = ref.watch(favoritesListProvider);
    return favorites.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => _RailMessage(
        icon: Icons.error_outline_rounded,
        text: l10n.commonUnknownError,
        action: TextButton(onPressed: () => ref.invalidate(favoritesListProvider), child: Text(l10n.commonRetry)),
      ),
      data: (list) => list.isEmpty
          ? _RailMessage(icon: Icons.favorite_border_rounded, text: l10n.sfFavoritesEmpty)
          : _RailList(
              items: list
                  .map(
                    (f) => _RailItem(
                      id: f.id,
                      name: f.name,
                      subtitle: f.categoryName,
                      imageUrl: f.imageUrl,
                      price: f.price,
                      currency: f.currency,
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class _RailItem {
  const _RailItem({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.imageUrl,
    required this.price,
    required this.currency,
  });

  final String id;
  final String name;
  final String? subtitle;
  final String? imageUrl;
  final double price;
  final Currency currency;
}

class _RailList extends StatelessWidget {
  const _RailList({required this.items, super.key});

  final List<_RailItem> items;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(width: 12),
      itemBuilder: (context, index) => _RailCard(item: items[index])
          .animate()
          .fadeIn(delay: (50 * index).ms, duration: AppMotion.standard)
          .slideX(begin: 0.08, end: 0, curve: AppMotion.emphasized),
    );
  }
}

class _RailCard extends StatelessWidget {
  const _RailCard({required this.item});

  final _RailItem item;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    return GestureDetector(
      onTap: () => context.push(RouteNames.customerProductDetail(item.id)),
      child: SizedBox(
        width: 168,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                height: 186,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    StorefrontImage(url: item.imageUrl),
                    // Dark fade so the price reads on any photo.
                    if (item.imageUrl != null)
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: [0.45, 1],
                            colors: [Colors.transparent, Color(0xDD000000)],
                          ),
                        ),
                      ),
                    Positioned(top: 8, right: 8, child: FavoriteHeart(productId: item.id, size: 20)),
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 10,
                      child: Text(
                        CurrencyFormatter.format(item.price, item.currency),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: BrandTheme.fontFamily,
                          color: item.imageUrl != null ? Colors.white : colors.textPrimary,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: colors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800),
            ),
            if (item.subtitle != null)
              Text(
                item.subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: colors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
              ),
          ],
        ),
      ),
    );
  }
}

class _RailMessage extends StatelessWidget {
  const _RailMessage({required this.icon, required this.text, this.action});

  final IconData icon;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(color: colors.field, borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: colors.accentText),
            const SizedBox(height: 10),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w600, height: 1.35),
            ),
            if (action != null) ...[const SizedBox(height: 14), action!],
          ],
        ),
      ),
    );
  }
}

/// Pill-shaped two-way switch; the selected half is a raised white chip.
class _Segmented extends StatelessWidget {
  const _Segmented({required this.labels, required this.selected, required this.onChanged});

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    return Container(
      height: 52,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(color: colors.field, borderRadius: BorderRadius.circular(26)),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: AppMotion.standard,
            curve: AppMotion.emphasized,
            alignment: selected == 0 ? Alignment.centerLeft : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 1 / labels.length,
              child: Container(
                decoration: BoxDecoration(
                  color: colors.sheet,
                  borderRadius: BorderRadius.circular(21),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              for (var i = 0; i < labels.length; i++)
                Expanded(
                  child: Semantics(
                    selected: i == selected,
                    button: true,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onChanged(i),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: AppMotion.standard,
                          style: TextStyle(
                            fontFamily: BrandTheme.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                            color: i == selected ? colors.accentText : colors.textPrimary,
                          ),
                          child: Text(labels[i].toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
