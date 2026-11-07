import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/enums/restaurant_order_enums.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/features/restaurant_orders/domain/entities/restaurant_order.dart';
import 'package:bsmart/features/restaurant_orders/domain/entities/restaurant_order_write_params.dart';
import 'package:bsmart/features/restaurant_orders/domain/usecases/create_restaurant_order_usecase.dart';
import 'package:bsmart/features/restaurant_orders/domain/usecases/get_restaurant_order_usecase.dart';
import 'package:bsmart/features/restaurant_orders/presentation/providers/open_restaurant_orders_notifier.dart';
import 'package:bsmart/features/restaurant_pos/presentation/providers/restaurant_pos_providers.dart';
import 'package:bsmart/features/restaurant_pos/presentation/screens/dish_picker_screen.dart';
import 'package:bsmart/features/restaurant_pos/presentation/screens/restaurant_checkout_screen.dart';
import 'package:bsmart/features/restaurant_tables/domain/entities/restaurant_table.dart';

void _snack(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}

/// Reloads every Kassa list after a change (the waiters' board too).
Future<void> refreshRestaurantPos(WidgetRef ref) async {
  ref.invalidate(openRestaurantOrdersProvider);
  await ref.read(unpaidRestaurantOrdersProvider.notifier).refresh();
}

/// Takes a new order (or a second bill) for [table] at the Kassa. True once it's saved.
Future<bool> takeTableOrder(BuildContext context, WidgetRef ref, RestaurantTable table, {bool separate = false}) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final saved = await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (_) => DishPickerScreen(
        title: separate ? l10n.rposNewBill : l10n.rposNewOrderFor(table.name),
        subtitle: separate ? table.name : null,
        submitLabel: l10n.rposSendToKitchen,
        onSubmit: (items, note) async {
          final result = await getIt<CreateRestaurantOrderUseCase>().call(
            CreateRestaurantOrderParams(
              type: RestaurantOrderType.dineIn,
              tableId: table.id,
              notes: note,
              items: items,
            ),
          );
          return result.fold((_) {
            messenger.showSnackBar(SnackBar(content: Text(l10n.rposOrderSent(table.name))));
            return true;
          }, (failure) {
            messenger.showSnackBar(SnackBar(content: Text(failure.message)));
            return false;
          });
        },
      ),
    ),
  );
  if (saved == true) await refreshRestaurantPos(ref);
  return saved == true;
}

/// A walk-in customer at the counter: pick dishes, save the takeaway, then pay at once. If the
/// payment is abandoned it waits in "Boshqa buyurtmalar"; the kitchen gets it once it's paid.
Future<void> startTakeaway(BuildContext context, WidgetRef ref) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  RestaurantOrder? created;
  await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (_) => DishPickerScreen(
        title: l10n.rposTakeawayTitle,
        subtitle: l10n.rposTakeawayHint,
        submitLabel: l10n.rposPay,
        onSubmit: (items, note) async {
          final result = await getIt<CreateRestaurantOrderUseCase>().call(
            CreateRestaurantOrderParams(type: RestaurantOrderType.dineIn, takeaway: true, notes: note, items: items),
          );
          return result.fold((order) {
            created = order;
            return true;
          }, (failure) {
            messenger.showSnackBar(SnackBar(content: Text(failure.message)));
            return false;
          });
        },
      ),
    ),
  );
  final order = created;
  if (order == null || !context.mounted) return;
  await Navigator.of(context).push(MaterialPageRoute(builder: (_) => RestaurantCheckoutScreen(order: order)));
  await refreshRestaurantPos(ref);
}

/// "To'lovga o'tish": reads a fresh copy of the bill (someone may have changed it since), then
/// opens the checkout. Returns when the checkout is closed or replaced by the receipt (a paid
/// bill's receipt is still on screen then), so callers must not pop anything on return.
Future<void> payRestaurantOrder(BuildContext context, WidgetRef ref, RestaurantOrder order, {double? discount}) async {
  final l10n = context.l10n;
  final result = await getIt<GetRestaurantOrderUseCase>().call(order.id);
  if (!context.mounted) return;
  final fresh = result.fold<RestaurantOrder?>((o) => o, (failure) {
    _snack(context, failure.message);
    return null;
  });
  if (fresh == null) return;
  if (fresh.saleId != null) {
    _snack(context, l10n.rposAlreadyPaid);
    await refreshRestaurantPos(ref);
    return;
  }
  await Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => RestaurantCheckoutScreen(order: fresh, discount: discount)));
  await refreshRestaurantPos(ref);
}
