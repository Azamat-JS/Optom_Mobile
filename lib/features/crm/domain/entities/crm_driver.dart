/// CRM (vehicle-service profile, Optom_Savdo CLAUDE.md "CRM"): a driver who brings cars to an
/// auto-parts store, with their cars. Store-scoped, like customers.
class CrmDriver {
  const CrmDriver({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.notes,
    this.imageUrl,
    required this.isActive,
    this.customer,
    required this.vehicles,
    required this.createdAt,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final String? notes;
  final String? imageUrl;
  final bool isActive;

  /// The store customer with the driver's phone — services are recorded as this customer's sales.
  final CrmLinkedCustomer? customer;
  final List<CrmVehicle> vehicles;
  final DateTime createdAt;

  String get fullName => '$firstName $lastName'.trim();
}

class CrmLinkedCustomer {
  const CrmLinkedCustomer({required this.id, required this.fullName, this.phone, required this.isActive});

  final String id;
  final String fullName;
  final String? phone;
  final bool isActive;
}

/// One of a driver's cars. [plateNumber] is stored normalized ("01A123BC"); show it with
/// `formatPlate`.
class CrmVehicle {
  const CrmVehicle({
    required this.id,
    required this.plateNumber,
    required this.model,
    this.dailyKm,
    this.notes,
    required this.driverId,
    this.nextDue,
  });

  final String id;
  final String plateNumber;
  final String model;

  /// Average km per day; km-based due dates are counted from it. Null = due dates must be typed.
  final int? dailyKm;
  final String? notes;
  final String driverId;

  /// The car's soonest active reminder.
  final CrmNextDue? nextDue;
}

class CrmNextDue {
  const CrmNextDue({required this.id, required this.productName, required this.dueDate, this.dueOdometerKm});

  final String id;
  final String productName;

  /// A calendar day (UTC midnight).
  final DateTime dueDate;
  final int? dueOdometerKm;
}

/// Whether the store's Telegram bot can message the driver (they opened it and shared their phone).
class CrmTelegramStatus {
  const CrmTelegramStatus({this.botUsername, required this.linked, required this.blocked});

  /// Null when the store has no bot connected.
  final String? botUsername;
  final bool linked;
  final bool blocked;

  String? get botLink => botUsername == null ? null : 'https://t.me/$botUsername';
}
