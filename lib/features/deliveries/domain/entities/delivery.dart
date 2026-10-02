/// Mirrors the backend `DeliveryStatus` enum (Optom_Savdo CLAUDE.md "Deliveries — T4").
/// ACCEPTED = courier heading to pickup; PICKED_UP = in transit to the customer.
enum DeliveryStatus {
  pending('PENDING', 'Kutilmoqda'),
  assigned('ASSIGNED', 'Biriktirilgan'),
  accepted('ACCEPTED', 'Qabul qilingan'),
  pickedUp('PICKED_UP', 'Yo\'lda'),
  arrived('ARRIVED', 'Yetib keldi'),
  delivered('DELIVERED', 'Topshirildi'),
  cancelled('CANCELLED', 'Bekor qilingan');

  const DeliveryStatus(this.wire, this.label);

  final String wire;
  final String label;

  static DeliveryStatus fromWire(String value) =>
      values.firstWhere((s) => s.wire == value, orElse: () => DeliveryStatus.pending);

  bool get isOffer => this == pending || this == assigned;

  /// Courier's location is streamed to viewers only in these states.
  bool get isActive => this == accepted || this == pickedUp || this == arrived;

  bool get isTerminal => this == delivered || this == cancelled;
}

enum DeliverySource { order, restaurantOrder }

class LatLngPoint {
  const LatLngPoint(this.lat, this.lng);

  final double lat;
  final double lng;
}

class DeliveryCourier {
  const DeliveryCourier({required this.id, required this.firstName, required this.lastName, this.phone});

  final String? id;
  final String firstName;
  final String lastName;
  final String? phone;

  String get fullName => '$firstName $lastName'.trim();
}

class DeliveryEta {
  const DeliveryEta({required this.seconds, this.distanceMeters});

  final int seconds;
  final int? distanceMeters;
}

/// A courier delivery as returned by `GET /deliveries[/:id]` (staff/courier audience).
class Delivery {
  const Delivery({
    required this.id,
    required this.status,
    required this.source,
    required this.createdAt,
    this.orderNumber,
    this.pickup,
    this.dropoff,
    this.dropoffAddress,
    this.storeName,
    this.courierId,
    this.courier,
    this.customerName,
    this.customerPhone,
    this.eta,
    this.acceptedAt,
    this.pickedUpAt,
    this.arrivedAt,
    this.deliveredAt,
  });

  final String id;
  final DeliveryStatus status;
  final DeliverySource source;
  final String? orderNumber;
  final LatLngPoint? pickup;
  final LatLngPoint? dropoff;
  final String? dropoffAddress;
  final String? storeName;
  final String? courierId;
  final DeliveryCourier? courier;
  final String? customerName;
  final String? customerPhone;
  final DeliveryEta? eta;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? pickedUpAt;
  final DateTime? arrivedAt;
  final DateTime? deliveredAt;

  /// Short label for notifications/sheets: "#ORD-123".
  String get label => orderNumber != null ? '#$orderNumber' : 'Yetkazish';

  /// Where the courier should drive next: the store until pickup, then the customer.
  LatLngPoint? get nextStop => status.isOffer || status == DeliveryStatus.accepted ? pickup : dropoff;
}
