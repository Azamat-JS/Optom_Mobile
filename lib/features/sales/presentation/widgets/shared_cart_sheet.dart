import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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
          ..showSnackBar(const SnackBar(content: Text('Savat saqlandi')));
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
        ..showSnackBar(const SnackBar(content: Text('Avval joriy savatni saqlang yoki tozalang')));
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
            ..showSnackBar(SnackBar(content: Text('$skipped ta mahsulot topilmadi, savatga qoʻshilmadi')));
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
        title: const Text("Saqlangan savatni o'chirish"),
        content: const Text("Bu amalni ortga qaytarib bo'lmaydi. Davom etasizmi?"),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Bekor qilish')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text("O'chirish")),
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
                  child: Text('Saqlangan savatlar', style: Theme.of(context).textTheme.titleMedium),
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
                        cart.isEmpty ? "Joriy savat bo'sh" : 'Joriy savatni saqlash (${cart.itemCount} ta)',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(height: 1),
                Expanded(
                  child: sharedCartsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Center(child: Text('Xatolik: $error')),
                    data: (carts) {
                      if (carts.isEmpty) {
                        return const Center(child: Text("Saqlangan savatlar yo'q"));
                      }
                      return ListView.separated(
                        controller: scrollController,
                        itemCount: carts.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final sharedCart = carts[index];
                          final names = sharedCart.items.take(3).map((i) => i.productName).join(', ');
                          final extra = sharedCart.items.length > 3 ? ' +${sharedCart.items.length - 3} ta' : '';
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
                                        tooltip: 'Qaytarib olish',
                                        onPressed: () => _restore(sharedCart),
                                      ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  tooltip: "O'chirish",
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
