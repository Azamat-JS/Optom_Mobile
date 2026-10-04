/// Mirrors the backend `DeliveryStatus` enum (Optom_Savdo CLAUDE.md "Deliveries — T4").
/// ACCEPTED = courier heading to pickup; PICKED_UP = in transit to the customer.
enum DeliveryStatus {
  pending('PENDING', 'Kutilmoqda'),
  assigned('ASSIGNED', 'Biriktirilgan'),
  accepted('ACCEPTED', 'Qabul qilingan'),
  pickedUp('PICKED_UP', 'Yo\'lda'),
  arrived('ARRIVED', 'Yetib keldi'),
  delivered('DELIVERED', 'Topshirildi'),
  cancelled('CANCELLED', 'Bekor qilingan'),
  // Phase 7 N2: the courier tried and couldn't hand it over (see [Delivery.failReason]).
  failed('FAILED', "Yetkazib bo'lmadi");

  const DeliveryStatus(this.wire, this.label);

  final String wire;
  final String label;

  static DeliveryStatus fromWire(String value) =>
      values.firstWhere((s) => s.wire == value, orElse: () => DeliveryStatus.pending);

  bool get isOffer => this == pending || this == assigned;

  /// Courier's location is streamed to viewers only in these states.
  bool get isActive => this == accepted || this == pickedUp || this == arrived;

  bool get isTerminal => this == delivered || this == cancelled || this == failed;

  /// Courier still has the order: it can be completed or failed from here.
  bool get isWithCourier => this == pickedUp || this == arrived;
}

/// Why the courier couldn't hand it over (`PATCH /deliveries/:id/fail`).
enum DeliveryFailReason {
  notHome('NOT_HOME', "Mijoz manzilda yo'q"),
  refused('REFUSED', 'Mijoz qabul qilmadi'),
  wrongAddress('WRONG_ADDRESS', "Manzil noto'g'ri"),
  other('OTHER', 'Boshqa sabab');

  const DeliveryFailReason(this.wire, this.label);

  final String wire;
  final String label;

  static DeliveryFailReason? fromWire(Object? value) =>
      values.where((r) => r.wire == value).firstOrNull;
}

/// The customer's 4-digit handover code (Phase 7 N2). Staff and the courier get the status only;
/// the customer gets [code] — and only while the courier has the order.
class DeliveryHandover {
  const DeliveryHandover({
    this.required = false,
    this.pending = false,
    this.attemptsLeft = 5,
    this.locked = false,
    this.waived = false,
    this.code,
  });

  final bool required;

  /// Completing still needs the code (required, not entered, not waived).
  final bool pending;
  final int attemptsLeft;

  /// Too many wrong tries — only a staff waiver unlocks it.
  final bool locked;
  final bool waived;

  /// Customer view only.
  final String? code;

  static const none = DeliveryHandover();
}

/// Where the courier was when they completed / failed it (staff view).
class DeliveryOutcomeLocation {
  const DeliveryOutcomeLocation({required this.point, this.at, this.distanceToDropoffMeters});

  final LatLngPoint point;
  final DateTime? at;
  final int? distanceToDropoffMeters;
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
    this.failedAt,
    this.failReason,
    this.failNote,
    this.cancelReason,
    this.handover = DeliveryHandover.none,
    this.outcomeLocation,
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
  final DateTime? failedAt;
  final DeliveryFailReason? failReason;

  /// Courier's own words — staff/courier view only.
  final String? failNote;

  /// Staff-only.
  final String? cancelReason;
  final DeliveryHandover handover;
  final DeliveryOutcomeLocation? outcomeLocation;

  /// Short label for notifications/sheets: "#ORD-123".
  String get label => orderNumber != null ? '#$orderNumber' : 'Yetkazish';

  /// Where the courier should drive next: the store until pickup, then the customer.
  LatLngPoint? get nextStop => status.isOffer || status == DeliveryStatus.accepted ? pickup : dropoff;
}
