/// The table embedded on a restaurant order — a live reference (unlike
/// `RestaurantOrder.tableNumber`, a point-in-time name snapshot), so its
/// `percent` reflects the table's *current* setting, not what was snapshotted
/// onto the order at creation (`RestaurantOrder.serviceChargePercent` is the
/// snapshot; this is just for display/context).
class RestaurantTableRef {
  const RestaurantTableRef({required this.id, required this.name, required this.percent});

  final String id;
  final String name;
  final double percent;
}
