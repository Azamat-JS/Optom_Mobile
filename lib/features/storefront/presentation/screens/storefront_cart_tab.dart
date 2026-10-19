import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/storefront/domain/entities/storefront_product.dart';
import 'package:bsmart/features/storefront/presentation/providers/storefront_cart_notifier.dart';
import 'package:bsmart/features/storefront/presentation/providers/storefront_shop_providers.dart';
import 'package:bsmart/features/storefront/presentation/widgets/checkout_parts.dart';
import 'package:bsmart/features/storefront/presentation/widgets/storefront_actions.dart';
import 'package:bsmart/features/storefront/presentation/widgets/storefront_image.dart';
import 'package:bsmart/features/storefront/presentation/widgets/storefront_search_parts.dart';

/// The "Savat" tab — local cart state, guest-editable. "Rasmiylashtirish"
/// pushes `RouteNames.customerCartReview`, which is deliberately *not* in
/// `app_router.dart`'s guest-allowed list — a logged-out tap lands on
/// `/login` via the ordinary redirect, matching "login required only at
/// checkout" from the Phase 2 plan without any manual auth check here.
///
/// Phase 9 U3a (Swiggy cart reference): shop card, item rows with the shared
/// stepper, "more from this shop", bill card, a note on how ordering works
/// (the shop confirms and agrees payment/delivery — there are no fees,
/// coupons or online payment in this backend), and a sticky checkout bar.
///
/// Must sit under a [BrandTheme] (`CustomerHomeScreen` provides it).
class StorefrontCartTab extends ConsumerWidget {
  const StorefrontCartTab({required this.onStartShopping, super.key});

  /// Switches the shell back to the catalog tab.
  final VoidCallback onStartShopping;

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.cartClear),
        content: Text(l10n.cartClearConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(l10n.cartClear)),
        ],
      ),
    );
    if (ok ?? false) ref.read(storefrontCartProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(storefrontCartProvider);
    final colors = BrandColors.of(context);
    final l10n = context.l10n;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark).copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: ColoredBox(
        // Grey page, white cards (the reference's layout).
        color: dark ? colors.sheet : const Color(0xFFF2F3F6),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              SizedBox(
                height: 60,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 8, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.navCart,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),
                      if (!cart.isEmpty)
                        IconButton(
                          tooltip: l10n.cartClear,
                          onPressed: () => _confirmClear(context, ref),
                          icon: Icon(Icons.delete_outline_rounded, color: colors.textSecondary),
                        ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: AppMotion.standard,
                  child: cart.isEmpty
                      ? _EmptyCart(key: const ValueKey('empty'), onStartShopping: onStartShopping)
                      : _CartContent(key: const ValueKey('cart'), cart: cart),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.onStartShopping, super.key});

  final VoidCallback onStartShopping;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(color: AppColors.brandYellow.withValues(alpha: 0.2), shape: BoxShape.circle),
              child: const Icon(Icons.shopping_bag_outlined, size: 56, color: AppColors.brandAmber),
            ).animate().scale(begin: const Offset(0.85, 0.85), duration: AppMotion.slow, curve: AppMotion.emphasized),
            const SizedBox(height: 22),
            Text(
              l10n.cartEmptyTitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textPrimary, fontSize: 21, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.cartEmptyHint,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textSecondary, fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: onStartShopping,
              style: FilledButton.styleFrom(minimumSize: const Size(200, 52)),
              icon: const Icon(Icons.storefront_rounded),
              label: Text(l10n.cartStartShopping),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartContent extends ConsumerWidget {
  const _CartContent({required this.cart, super.key});

  final StorefrontCartState cart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = BrandColors.of(context);
    final l10n = context.l10n;
    final lines = cart.lines.values.toList();
    final first = lines.first.product;
    final currency = first.currency;
    final shop = shopNameOf(first);
    void openShop() => context.push(RouteNames.customerShop(first.sellerId, storeId: first.storeId, name: shop));
    final suggestions = ref
        .watch(shopProductsProvider((sellerId: first.sellerId, storeId: first.storeId)))
        .valueOrNull
        ?.where((p) => !cart.lines.containsKey(p.id) && p.stock > 0)
        .take(10)
        .toList();

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
            children: [
              CheckoutCard(
                padding: const EdgeInsets.all(14),
                onTap: openShop,
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(color: AppColors.brandYellow, borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.storefront_rounded, color: AppColors.onBrand),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shop,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: colors.textPrimary, fontSize: 17, fontWeight: FontWeight.w800),
                          ),
                          Text(
                            l10n.commonProductCount(lines.length),
                            style: TextStyle(color: colors.textSecondary, fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: colors.textSecondary, size: 28),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              CheckoutCard(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < lines.length; i++) ...[
                      if (i > 0) DashedDivider(color: colors.outline),
                      _LineRow(line: lines[i]),
                    ],
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: openShop,
                      style: OutlinedButton.styleFrom(minimumSize: const Size(0, 46)),
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: Text(l10n.cartAddMore),
                    ),
                  ],
                ),
              ),
              if (suggestions != null && suggestions.isNotEmpty) ...[
                const SizedBox(height: 14),
                CheckoutCard(
                  padding: const EdgeInsets.fromLTRB(16, 0, 0, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: SearchSectionLabel(text: l10n.sfMoreFromShop),
                      ),
                      SizedBox(
                        height: 212,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(right: 16),
                          itemCount: suggestions.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 12),
                          itemBuilder: (context, i) => _SuggestionCard(
                            product: suggestions[i],
                          ).animate().fadeIn(delay: (40 * i).ms, duration: AppMotion.standard),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 14),
              CheckoutCard(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SearchSectionLabel(text: l10n.cartBillTitle),
                    BillRow(
                      label: '${l10n.cartItemsTotal} (${lines.length})',
                      value: CurrencyFormatter.format(cart.total, currency),
                    ),
                    const SizedBox(height: 10),
                    BillRow(label: l10n.cartDelivery, value: l10n.cartDeliveryAgreed, muted: true),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: DashedDivider(color: colors.outline),
                    ),
                    BillRow(label: l10n.cartToPay, value: CurrencyFormatter.format(cart.total, currency), strong: true),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              CheckoutCard(
                padding: const EdgeInsets.all(16),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${l10n.cartNoteLabel} ',
                        style: TextStyle(color: colors.accentText, fontWeight: FontWeight.w800),
                      ),
                      TextSpan(text: l10n.cartNote),
                    ],
                  ),
                  style: TextStyle(color: colors.textSecondary, fontSize: 14.5, height: 1.45),
                ),
              ),
            ],
          ),
        ),
        _CheckoutBar(total: cart.total, currency: currency),
      ],
    );
  }
}

class _LineRow extends ConsumerWidget {
  const _LineRow({required this.line});

  final StorefrontCartLine line;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = BrandColors.of(context);
    final l10n = context.l10n;
    final product = line.product;
    final unit = product.unit?.shortLabel;
    final unitPrice = CurrencyFormatter.format(product.price, product.currency);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => context.push(RouteNames.customerProductDetail(product.id)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(width: 64, height: 64, child: StorefrontImage(url: product.imageUrl, iconSize: 26)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700, height: 1.25),
                ),
                const SizedBox(height: 2),
                Text(
                  unit == null ? unitPrice : l10n.cartUnitPrice(unitPrice, unit),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.textSecondary, fontSize: 13.5, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => ref.read(storefrontCartProvider.notifier).removeProduct(product.id),
                  child: Text(
                    l10n.cartRemove,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationStyle: TextDecorationStyle.dotted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AddToCartButton(product: product, width: 108),
              const SizedBox(height: 8),
              Text(
                CurrencyFormatter.format(line.total, product.currency),
                style: TextStyle(color: colors.textPrimary, fontSize: 15.5, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SuggestionCard extends ConsumerWidget {
  const _SuggestionCard({required this.product});

  final StorefrontProduct product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = BrandColors.of(context);
    return SizedBox(
      width: 128,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: () => context.push(RouteNames.customerProductDetail(product.id)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(width: 128, height: 128, child: StorefrontImage(url: product.imageUrl)),
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: Material(
                  color: colors.sheet,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: AppColors.brandAmber, width: 1.5),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => addToStorefrontCart(context, ref, product),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(Icons.add_rounded, size: 22, color: colors.accentText),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colors.textPrimary, fontSize: 14.5, fontWeight: FontWeight.w700),
          ),
          Text(
            CurrencyFormatter.format(product.price, product.currency),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colors.textSecondary, fontSize: 13.5, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({required this.total, required this.currency});

  final double total;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    final l10n = context.l10n;
    return Container(
      decoration: BoxDecoration(
        color: colors.sheet,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 18, offset: const Offset(0, -4)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: FilledButton(
        onPressed: () => context.push(RouteNames.customerCartReview),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l10n.cartCheckout),
            const Text('  ·  '),
            Text(CurrencyFormatter.format(total, currency)),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward_rounded, size: 20),
          ],
        ),
      ),
    );
  }
}
