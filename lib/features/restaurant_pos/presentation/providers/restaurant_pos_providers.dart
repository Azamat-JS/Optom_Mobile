import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/enums/restaurant_order_enums.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/restaurant_orders/domain/entities/restaurant_order.dart';
import 'package:bsmart/features/restaurant_orders/domain/usecases/list_unpaid_restaurant_orders_usecase.dart';
import 'package:bsmart/features/restaurant_tables/domain/entities/restaurant_table.dart';

/// Everything still to be paid at the restaurant Kassa (`GET /restaurant-orders/unpaid`, owner and
/// admins): open orders plus dine-in ones a waiter marked served that nobody charged yet. Shared
/// by the tables screen, a table's screen and the "other orders" sheet, so a change made in one
/// shows in the others after a single [refresh].
class UnpaidRestaurantOrdersNotifier extends AsyncNotifier<List<RestaurantOrder>> {
  @override
  Future<List<RestaurantOrder>> build() {
    ref.watch(currentUserIdProvider);
    return _fetch();
  }

  Future<List<RestaurantOrder>> _fetch() async {
    final result = await getIt<ListUnpaidRestaurantOrdersUseCase>().call();
    return result.fold((orders) => orders, (failure) => throw failure);
  }

  /// Keeps the last good list while reloading (no spinner flash on a poll).
  Future<void> refresh() async {
    final next = await AsyncValue.guard(_fetch);
    if (next.hasError && state.hasValue) return;
    state = next;
  }
}

final unpaidRestaurantOrdersProvider =
    AsyncNotifierProvider<UnpaidRestaurantOrdersNotifier, List<RestaurantOrder>>(UnpaidRestaurantOrdersNotifier.new);

/// How a table card looks: free; being served; a READY order to carry out; or served by the
/// waiter with only the bill left.
enum PosTableState { free, open, ready, unpaid }

class PosTableView {
  PosTableView({required this.table, required this.orders});

  final RestaurantTable table;

  /// Its unpaid bills, oldest first.
  final List<RestaurantOrder> orders;

  bool get occupied => orders.isNotEmpty;

  PosTableState get state {
    if (orders.isEmpty) return PosTableState.free;
    if (orders.every((o) => o.status == RestaurantOrderStatus.served)) return PosTableState.unpaid;
    if (orders.any((o) => o.status == RestaurantOrderStatus.ready)) return PosTableState.ready;
    return PosTableState.open;
  }

  DateTime? get since => orders.isEmpty ? null : orders.first.createdAt;

  double get grandTotal => orders.fold(0, (sum, o) => sum + o.grandTotal);

  /// Dishes of every bill, merged by name.
  List<(String, int)> get dishes {
    final merged = <String, int>{};
    for (final o in orders) {
      for (final i in o.items) {
        merged[i.productName] = (merged[i.productName] ?? 0) + i.quantity;
      }
    }
    return [for (final e in merged.entries) (e.key, e.value)];
  }
}

/// Tables in natural name order ("2-stol" before "10-stol"), each with its unpaid bills.
List<PosTableView> buildPosTableViews(List<RestaurantTable> tables, List<RestaurantOrder> orders) {
  final byTable = <String, List<RestaurantOrder>>{};
  for (final o in orders) {
    if (!o.isTableOrder) continue;
    byTable.putIfAbsent(o.table!.id, () => []).add(o);
  }
  final sorted = [...tables]..sort((a, b) => _naturalCompare(a.name, b.name));
  return [
    for (final t in sorted)
      PosTableView(table: t, orders: (byTable[t.id] ?? [])..sort((a, b) => a.createdAt.compareTo(b.createdAt))),
  ];
}

/// Orders that aren't a table card: deliveries, takeaways, a seated order whose table is gone.
List<RestaurantOrder> otherPosOrders(List<RestaurantOrder> orders) =>
    orders.where((o) => !o.isTableOrder && !o.status.isTerminal).toList();

int _naturalCompare(String a, String b) {
  final re = RegExp(r'(\d+)|(\D+)');
  final pa = re.allMatches(a.toLowerCase()).map((m) => m.group(0)!).toList();
  final pb = re.allMatches(b.toLowerCase()).map((m) => m.group(0)!).toList();
  for (var i = 0; i < pa.length && i < pb.length; i++) {
    final na = int.tryParse(pa[i]);
    final nb = int.tryParse(pb[i]);
    final c = (na != null && nb != null) ? na.compareTo(nb) : pa[i].compareTo(pb[i]);
    if (c != 0) return c;
  }
  return pa.length.compareTo(pb.length);
}

/// "12 daq" style elapsed minutes since [since].
int elapsedMinutes(DateTime since, DateTime now) {
  final mins = now.difference(since).inMinutes;
  return mins < 0 ? 0 : mins;
}
