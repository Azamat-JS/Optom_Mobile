import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/favorites/presentation/providers/favorite_ids_notifier.dart';
import 'package:bsmart/features/storefront/domain/entities/storefront_product.dart';
import 'package:bsmart/features/storefront/presentation/providers/storefront_cart_notifier.dart';

/// Adds [product] to the storefront cart, with the same one-shop rule and
/// toasts everywhere in the storefront.
void addToStorefrontCart(BuildContext context, WidgetRef ref, StorefrontProduct product) {
  final l10n = context.l10n;
  final added = ref.read(storefrontCartProvider.notifier).addProduct(product);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(added ? l10n.sfAddedToCart(product.name) : l10n.sfCartOtherShop),
        duration: Duration(milliseconds: added ? 900 : 2500),
      ),
    );
}

/// "Qoldi: 12 dona" — stock with its unit.
String stockLabel(StorefrontProduct product) {
  final stock = product.stock;
  final quantity = stock == stock.roundToDouble() ? stock.toInt().toString() : stock.toStringAsFixed(1);
  final unit = product.unit?.shortLabel;
  return unit == null ? quantity : '$quantity $unit';
}

/// Outlined "QO'SHISH" button (the reference's green ADD) that turns into a
/// − qty + stepper once the product is in the cart.
class AddToCartButton extends ConsumerWidget {
  const AddToCartButton({required this.product, this.width = 116, super.key});

  final StorefrontProduct product;
  final double width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = BrandColors.of(context);
    final line = ref.watch(storefrontCartProvider.select((cart) => cart.lines[product.id]));
    final outOfStock = product.stock <= 0;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: colors.outline, width: 1.2),
    );

    if (line == null) {
      return SizedBox(
        width: width,
        height: 42,
        child: Material(
          color: colors.sheet,
          shape: shape,
          elevation: 0,
          child: InkWell(
            customBorder: shape,
            onTap: outOfStock ? null : () => addToStorefrontCart(context, ref, product),
            child: Center(
              child: Text(
                outOfStock ? context.l10n.sfOutOfStock : context.l10n.sfAdd,
                style: TextStyle(
                  fontFamily: BrandTheme.fontFamily,
                  fontSize: outOfStock ? 13 : 15,
                  fontWeight: FontWeight.w800,
                  color: outOfStock ? colors.disabledText : colors.success,
                ),
              ),
            ),
          ),
        ),
      );
    }

    final notifier = ref.read(storefrontCartProvider.notifier);
    final quantity = line.quantity == line.quantity.roundToDouble()
        ? line.quantity.toInt().toString()
        : line.quantity.toStringAsFixed(1);
    return Container(
      width: width,
      height: 42,
      decoration: ShapeDecoration(
        color: AppColors.brandYellow,
        shape: shape.copyWith(side: BorderSide.none),
      ),
      child: Row(
        children: [
          _StepperIcon(icon: Icons.remove_rounded, onTap: () => notifier.updateQuantity(product.id, line.quantity - 1)),
          Expanded(
            child: Text(
              quantity,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: BrandTheme.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.onBrand,
              ),
            ),
          ),
          _StepperIcon(
            icon: Icons.add_rounded,
            onTap: line.quantity >= product.stock ? null : () => notifier.updateQuantity(product.id, line.quantity + 1),
          ),
        ],
      ),
    );
  }
}

class _StepperIcon extends StatelessWidget {
  const _StepperIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 38,
        height: 42,
        child: Icon(icon, size: 20, color: AppColors.onBrand.withValues(alpha: onTap == null ? 0.3 : 1)),
      ),
    );
  }
}

/// Heart toggle drawn over product photos. Guests are sent to login.
class FavoriteHeart extends ConsumerWidget {
  const FavoriteHeart({required this.productId, this.size = 22, super.key});

  final String productId;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loggedIn = ref.watch(sessionNotifierProvider.select((s) => s.valueOrNull?.isAuthenticated ?? false));
    final favorited =
        loggedIn && ref.watch(favoriteIdsProvider.select((ids) => ids.valueOrNull?.contains(productId) ?? false));
    return Material(
      color: Colors.black.withValues(alpha: 0.28),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () =>
            loggedIn ? ref.read(favoriteIdsProvider.notifier).toggle(productId) : context.push(RouteNames.login),
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
            child: Icon(
              favorited ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              key: ValueKey(favorited),
              size: size,
              color: favorited ? const Color(0xFFFF4D6D) : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
