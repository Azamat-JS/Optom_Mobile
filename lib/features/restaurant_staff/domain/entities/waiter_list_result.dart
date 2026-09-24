import 'package:bsmart/features/restaurant_staff/domain/entities/waiter.dart';

/// `GET /restaurant-staff`'s envelope carries one extra field beyond the
/// standard 6-field pagination `meta` — `waiterLimit` (the SUPER_ADMIN-set
/// cap for this owner) — so this doesn't reuse the shared `PaginatedResult`.
class WaiterListResult {
  const WaiterListResult({required this.items, required this.waiterLimit});

  final List<Waiter> items;
  final int waiterLimit;
}
