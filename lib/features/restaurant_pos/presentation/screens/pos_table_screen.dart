import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/restaurant_order_enums.dart';
import 'package:bsmart/core/enums/user_role.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/restaurant_orders/domain/entities/restaurant_order.dart';
import 'package:bsmart/features/restaurant_orders/domain/entities/restaurant_order_item.dart';
import 'package:bsmart/features/restaurant_orders/domain/usecases/add_restaurant_order_items_usecase.dart';
import 'package:bsmart/features/restaurant_orders/domain/usecases/remove_restaurant_order_item_usecase.dart';
import 'package:bsmart/features/restaurant_orders/domain/usecases/update_restaurant_order_status_usecase.dart';
import 'package:bsmart/features/restaurant_pos/presentation/providers/restaurant_pos_providers.dart';
import 'package:bsmart/features/restaurant_pos/presentation/restaurant_pos_actions.dart';
import 'package:bsmart/features/restaurant_pos/presentation/screens/dish_picker_screen.dart';
import 'package:bsmart/features/restaurant_pos/presentation/widgets/pos_bill_card.dart';
import 'package:bsmart/features/restaurant_tables/domain/entities/restaurant_table.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// One table at the restaurant Kassa (Optom_Savdo "Restaurant POS"): each unpaid bill with what was
/// ordered and how much, taking dishes off, adding more, the kitchen status, a discount and
/// "To'lovga o'tish"; plus a second bill. Reads the shared unpaid list, so a waiter's change shows
/// on the next refresh of the tables screen behind it.
class PosTableScreen extends ConsumerStatefulWidget {
  const PosTableScreen({required this.table, super.key});

  final RestaurantTable table;

  @override
  ConsumerState<PosTableScreen> createState() => _PosTableScreenState();
}

class _PosTableScreenState extends ConsumerState<PosTableScreen> {
  String? _busyId;
  DateTime _now = DateTime.now();

  /// The table had bills while this screen was open — once they're all paid or cancelled and the
  /// screen is on top again (the receipt closed), it goes back to the floor by itself.
  bool _hadOrders = false;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 30), (_) => setState(() => _now = DateTime.now()));
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _run(RestaurantOrder order, Future<String?> Function() action) async {
    setState(() => _busyId = order.id);
    final message = await action();
    await refreshRestaurantPos(ref);
    if (!mounted) return;
    setState(() => _busyId = null);
    if (message != null) _snack(message);
  }

  Future<void> _remove(RestaurantOrder order, RestaurantOrderItem item, int quantity) {
    final l10n = context.l10n;
    return _run(order, () async {
      final result = await getIt<RemoveRestaurantOrderItemUseCase>().call(order.id, item.id, quantity: quantity);
      return result.fold((_) => l10n.rposRemoved(item.productName, quantity), (f) => f.message);
    });
  }

  Future<void> _status(RestaurantOrder order, RestaurantOrderStatus status) {
    return _run(order, () async {
      final result = await getIt<UpdateRestaurantOrderStatusUseCase>().call(order.id, status);
      return result.fold((_) => '${order.orderNumber}: ${status.label}', (f) => f.message);
    });
  }

  Future<void> _addDishes(RestaurantOrder order) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => DishPickerScreen(
          title: l10n.rposAddDishesTo(order.orderNumber),
          subtitle: widget.table.name,
          submitLabel: l10n.rposAddToOrder,
          askNote: false,
          onSubmit: (items, _) async {
            final result = await getIt<AddRestaurantOrderItemsUseCase>().call(order.id, items);
            return result.fold((_) {
              messenger.showSnackBar(SnackBar(content: Text(l10n.rposItemsAdded(order.orderNumber))));
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
  }

  Future<void> _pay(RestaurantOrder order, double discount) async {
    setState(() => _busyId = order.id);
    await payRestaurantOrder(context, ref, order, discount: discount);
    if (mounted) setState(() => _busyId = null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final session = ref.watch(sessionNotifierProvider).valueOrNull?.session;
    final role = session?.role ?? UserRole.retailer;
    final userId = session?.userId ?? '';
    final ordersAsync = ref.watch(unpaidRestaurantOrdersProvider);
    final orders =
        (ordersAsync.valueOrNull ?? const <RestaurantOrder>[])
            .where((o) => o.isTableOrder && o.table!.id == widget.table.id)
            .toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final total = orders.fold<double>(0, (sum, o) => sum + o.grandTotal);
    // ModalRoute.of also rebuilds this when the screen comes back on top (e.g. the receipt closed).
    final onTop = ModalRoute.of(context)?.isCurrent ?? false;
    if (orders.isNotEmpty) {
      _hadOrders = true;
    } else if (_hadOrders && ordersAsync.hasValue && onTop) {
      _hadOrders = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).maybePop();
      });
    }

    return DashPage(
      title: widget.table.name,
      bottomBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
          child: OutlinedButton.icon(
            onPressed: _busyId != null ? null : () => takeTableOrder(context, ref, widget.table, separate: orders.isNotEmpty),
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            icon: const Icon(Icons.add_rounded),
            label: Text(orders.isEmpty ? l10n.rposTapToOrder : l10n.rposNewBill),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => refreshRestaurantPos(ref),
        child: orders.isEmpty
            ? ordersAsync.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : DashEmptyState(icon: Icons.table_restaurant_rounded, text: l10n.rposStateFree)
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
                    child: Text(
                      '${l10n.rposBills(orders.length)} · ${CurrencyFormatter.format(total, Currency.uzs)}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  for (final order in orders) ...[
                    PosBillCard(
                      key: ValueKey('${order.id}:${order.discount}'),
                      order: order,
                      role: role,
                      userId: userId,
                      now: _now,
                      busy: _busyId == order.id,
                      onAddDishes: () => _addDishes(order),
                      onRemove: (item, quantity) => _remove(order, item, quantity),
                      onStatus: (status) => _status(order, status),
                      onPay: (discount) => _pay(order, discount),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
      ),
    );
  }
}
