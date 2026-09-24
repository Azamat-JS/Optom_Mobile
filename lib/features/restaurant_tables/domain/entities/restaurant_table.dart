/// A restaurant table/room (`RestaurantTable`) — just a name and a service
/// charge percent applied on top of a dine-in order's total at collection
/// time (e.g. a 10% table on an 18 000 so'm order → 19 800 due). Table/room
/// management is operational config, not owner-private — `RETAILER_ADMIN`
/// gets it too, unlike Waiter/Courier account management.
class RestaurantTable {
  const RestaurantTable({
    required this.id,
    required this.name,
    required this.percent,
    required this.storeId,
  });

  final String id;
  final String name;
  final double percent;
  final String storeId;
}
