import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/sales/domain/entities/shared_cart.dart';
import 'package:bsmart/features/sales/domain/entities/shared_cart_write_params.dart';
import 'package:bsmart/features/sales/domain/usecases/park_cart_usecase.dart';
import 'package:bsmart/features/sales/domain/usecases/remove_shared_cart_usecase.dart';
import 'package:bsmart/features/sales/presentation/providers/pos_cart_notifier.dart';
import 'package:bsmart/features/sales/presentation/providers/shared_carts_notifier.dart';
import 'package:bsmart/features/products/domain/usecases/get_product_usecase.dart';

/// A bottom sheet for POS's "park/resume cart" feature (`/shared-cart`) — an
/// in-progress register transaction saved for later, shared by the owner and
/// every admin under the same tenant (see `SharedCart`'s doc comment).
/// Mirrors the reference web app's `SharedCartDialog`: park blocks on an
/// empty current cart, restore blocks on a *non*-empty current cart (no
/// silent overwrite/merge), delete is a permanent confirm-then-remove.
class SharedCartSheet extends ConsumerStatefulWidget {
  const SharedCartSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const SharedCartSheet(),
    );
  }

  @override
  ConsumerState<SharedCartSheet> createState() => _SharedCartSheetState();
}

class _SharedCartSheetState extends ConsumerState<SharedCartSheet> {
  static final _timeFormat = DateFormat('HH:mm');

  bool _isParking = false;
  String? _restoringId;

  Future<void> _parkCurrentCart() async {
    final cart = ref.read(posCartProvider);
    if (cart.isEmpty) return;

    setState(() => _isParking = true);
    final result = await getIt<ParkCartUseCase>().call(
      CreateSharedCartParams(
        currency: cart.currency!,
        items: [
          for (final line in cart.lines.values)
            CreateSharedCartItemParams(
              productId: line.product.id,
              productName: line.product.name,
              quantity: line.quantity,
              unitPrice: line.product.price,
              discount: line.discount,
            ),
        ],
        saleDiscount: cart.saleDiscount,
      ),
    );
    if (!mounted) return;
    setState(() => _isParking = false);
    result.fold(
      (_) {
        ref.read(posCartProvider.notifier).clear();
        ref.read(sharedCartsProvider.notifier).refresh();
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(context.l10n.cartsSaved)));
      },
      (failure) => ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }

  Future<void> _restore(SharedCart sharedCart) async {
    if (!ref.read(posCartProvider).isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(context.l10n.cartsSaveOrClearFirst)));
      return;
    }

    setState(() => _restoringId = sharedCart.id);
    // Atomic pop — the server deletes and returns the row in one call.
    final removed = await getIt<RemoveSharedCartUseCase>().call(sharedCart.id);
    if (!mounted) return;

    await removed.fold(
      (popped) async {
        // Each item is a frozen name/price snapshot, not a live Product — a
        // parked product may since have been deleted, so re-fetches are
        // error-tolerant (skip, don't fail the whole restore), mirroring the
        // reference web app's `Promise.allSettled` approach.
        final productResults = await Future.wait(
          popped.items.map((item) => getIt<GetProductUseCase>().call(item.productId)),
        );

        final lines = <PosCartLine>[];
        var skipped = 0;
        for (var i = 0; i < popped.items.length; i++) {
          final item = popped.items[i];
          productResults[i].fold(
            (product) => lines.add(PosCartLine(product: product, quantity: item.quantity, discount: item.discount)),
            (_) => skipped++,
          );
        }

        ref.read(posCartProvider.notifier).loadCart(lines, saleDiscount: popped.saleDiscount);
        ref.read(sharedCartsProvider.notifier).refresh();
        if (!mounted) return;
        if (skipped > 0) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(context.l10n.cartsSkipped(skipped))));
        }
        Navigator.of(context).pop();
      },
      (failure) async {
        setState(() => _restoringId = null);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(failure.message)));
      },
    );
  }

  Future<void> _delete(SharedCart sharedCart) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.cartsDeleteTitle),
        content: Text(context.l10n.cartsDeleteConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(context.l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(context.l10n.commonDelete)),
        ],
      ),
    );
    if (confirmed != true) return;

    final result = await getIt<RemoveSharedCartUseCase>().call(sharedCart.id);
    if (!mounted) return;
    result.fold(
      (_) => ref.read(sharedCartsProvider.notifier).refresh(),
      (failure) => ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final cart = ref.watch(posCartProvider);
    final sharedCartsAsync = ref.watch(sharedCartsProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.posSavedCarts,
                      style: TextStyle(color: colors.textPrimary, fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FilledButton.icon(
                    onPressed: cart.isEmpty || _isParking ? null : _parkCurrentCart,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    icon: _isParking
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.bookmark_add_rounded),
                    label: Text(cart.isEmpty ? l10n.cartsCurrentEmpty : l10n.cartsSaveCurrent(cart.itemCount)),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: sharedCartsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Center(child: Text(l10n.commonErrorWith('$error'))),
                    data: (carts) {
                      if (carts.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(color: colors.field, shape: BoxShape.circle),
                                child: Icon(Icons.shopping_basket_rounded, size: 30, color: colors.textMuted),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                l10n.cartsNone,
                                style: TextStyle(
                                  color: colors.textSecondary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: carts.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) => _SharedCartRow(
                          sharedCart: carts[index],
                          time: _timeFormat.format(carts[index].createdAt.toLocal()),
                          restoring: _restoringId == carts[index].id,
                          onRestore: () => _restore(carts[index]),
                          onDelete: () => _delete(carts[index]),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// One parked cart: total, time + first product names, restore / delete.
class _SharedCartRow extends StatelessWidget {
  const _SharedCartRow({
    required this.sharedCart,
    required this.time,
    required this.restoring,
    required this.onRestore,
    required this.onDelete,
  });

  final SharedCart sharedCart;
  final String time;
  final bool restoring;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final names = sharedCart.items.take(3).map((i) => i.productName).join(', ');
    final extra = sharedCart.items.length > 3 ? ' ${l10n.cartsMore(sharedCart.items.length - 3)}' : '';
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 6, 12),
      decoration: BoxDecoration(color: colors.field, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.brandYellow.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.shopping_basket_rounded, color: colors.accentText),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  CurrencyFormatter.format(sharedCart.total, sharedCart.currency),
                  style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  '$time · $names$extra',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.textMuted, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          restoring
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : IconButton.filled(
                  tooltip: l10n.cartsRestore,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.brandYellow,
                    foregroundColor: AppColors.onBrand,
                  ),
                  icon: const Icon(Icons.restore_rounded),
                  onPressed: onRestore,
                ),
          IconButton(
            tooltip: l10n.commonDelete,
            icon: Icon(Icons.delete_outline_rounded, color: Theme.of(context).colorScheme.error),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
