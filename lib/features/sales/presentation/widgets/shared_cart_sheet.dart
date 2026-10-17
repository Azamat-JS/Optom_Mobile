import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/di/injection.dart';
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
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(context.l10n.commonDelete)),
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
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(context.l10n.posSavedCarts, style: Theme.of(context).textTheme.titleMedium),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: cart.isEmpty || _isParking ? null : _parkCurrentCart,
                      icon: _isParking
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(
                        cart.isEmpty ? context.l10n.cartsCurrentEmpty : context.l10n.cartsSaveCurrent(cart.itemCount),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(height: 1),
                Expanded(
                  child: sharedCartsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Center(child: Text(context.l10n.commonErrorWith('$error'))),
                    data: (carts) {
                      if (carts.isEmpty) {
                        return Center(child: Text(context.l10n.cartsNone));
                      }
                      return ListView.separated(
                        controller: scrollController,
                        itemCount: carts.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final sharedCart = carts[index];
                          final names = sharedCart.items.take(3).map((i) => i.productName).join(', ');
                          final extra = sharedCart.items.length > 3 ? ' ${context.l10n.cartsMore(sharedCart.items.length - 3)}' : '';
                          return ListTile(
                            title: Text(CurrencyFormatter.format(sharedCart.total, sharedCart.currency)),
                            subtitle: Text(
                              '${_timeFormat.format(sharedCart.createdAt.toLocal())} · $names$extra',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _restoringId == sharedCart.id
                                    ? const Padding(
                                        padding: EdgeInsets.all(12),
                                        child: SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                      )
                                    : IconButton(
                                        icon: const Icon(Icons.restore),
                                        tooltip: context.l10n.cartsRestore,
                                        onPressed: () => _restore(sharedCart),
                                      ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  tooltip: context.l10n.commonDelete,
                                  onPressed: () => _delete(sharedCart),
                                ),
                              ],
                            ),
                          );
                        },
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
