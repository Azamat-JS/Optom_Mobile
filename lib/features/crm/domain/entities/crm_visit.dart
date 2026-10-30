import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/network/paginated_result.dart';

enum CrmItemStatus {
  active,
  done,
  cancelled;

  static CrmItemStatus fromWire(String value) => switch (value) {
        'DONE' => CrmItemStatus.done,
        'CANCELLED' => CrmItemStatus.cancelled,
        _ => CrmItemStatus.active,
      };
}

/// A part or oil installed at a visit, and when the car is due back for it.
class CrmVisitItem {
  const CrmVisitItem({
    required this.id,
    this.productId,
    required this.productName,
    required this.quantity,
    this.unitPrice,
    this.intervalKm,
    this.dueOdometerKm,
    this.dueDate,
    required this.dueDateManual,
    required this.status,
    this.closedByVisitId,
  });

  final String id;
  final String? productId;
  final String productName;
  final double quantity;
  final double? unitPrice;
  final int? intervalKm;
  final int? dueOdometerKm;

  /// A calendar day (UTC midnight); null = no reminder.
  final DateTime? dueDate;
  final bool dueDateManual;
  final CrmItemStatus status;

  /// Set when a later visit replaced it.
  final String? closedByVisitId;
}

/// The sale a visit was charged as.
class CrmVisitSale {
  const CrmVisitSale({
    required this.id,
    required this.saleNumber,
    required this.isDebt,
    required this.total,
    required this.currency,
    this.debtBalance,
  });

  final String id;
  final String saleNumber;
  final bool isDebt;
  final double total;
  final Currency currency;

  /// What the customer still owes on it (debt sales).
  final double? debtBalance;
}

class CrmVehicleRef {
  const CrmVehicleRef({required this.id, required this.plateNumber, required this.model, this.dailyKm});

  final String id;
  final String plateNumber;
  final String model;
  final int? dailyKm;
}

/// One service visit of a car.
class CrmVisit {
  const CrmVisit({
    required this.id,
    required this.serviceDate,
    this.odometerKm,
    this.notes,
    required this.vehicle,
    required this.items,
    this.sale,
  });

  final String id;

  /// A calendar day (UTC midnight).
  final DateTime serviceDate;
  final int? odometerKm;
  final String? notes;
  final CrmVehicleRef vehicle;
  final List<CrmVisitItem> items;

  /// Null when the visit was recorded without a sale.
  final CrmVisitSale? sale;
}

class CrmReminderDriver {
  const CrmReminderDriver({required this.id, required this.fullName, required this.phone, this.imageUrl});

  final String id;
  final String fullName;
  final String phone;
  final String? imageUrl;
}

/// An active reminder with its car and driver (the "Eslatmalar" list).
class CrmReminder {
  const CrmReminder({required this.item, required this.serviceDate, required this.vehicle, required this.driver});

  final CrmVisitItem item;
  final DateTime serviceDate;
  final CrmVehicleRef vehicle;
  final CrmReminderDriver driver;
}

/// One page of reminders plus the tab badges.
class CrmReminderPage {
  const CrmReminderPage({required this.page, required this.overdueCount, required this.soonCount});

  final PaginatedResult<CrmReminder> page;
  final int overdueCount;
  final int soonCount;
}
