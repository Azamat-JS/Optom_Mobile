import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/utils/decimal_parser.dart';
import 'package:bsmart/features/crm/domain/entities/crm_driver.dart';
import 'package:bsmart/features/crm/domain/entities/crm_visit.dart';

// Parsers for `/crm/*` responses, checked against `crm-driver.service.ts` (DRIVER_INCLUDE,
// VEHICLE_SELECT) and `crm-visit.service.ts` (ITEM_SELECT, VISIT_INCLUDE). Decimals arrive as
// strings; days as "2026-12-11T00:00:00.000Z" (kept in UTC, never `toLocal()`ed).

String _name(Map<String, dynamic> json) => '${json['firstName']} ${json['lastName'] ?? ''}'.trim();

CrmDriver crmDriverFromJson(Map<String, dynamic> json) {
  final customer = json['customer'] as Map<String, dynamic>?;
  return CrmDriver(
    id: json['id'] as String,
    firstName: json['firstName'] as String,
    lastName: json['lastName'] as String? ?? '',
    phone: json['phone'] as String,
    notes: json['notes'] as String?,
    imageUrl: json['imageUrl'] as String?,
    isActive: json['isActive'] as bool? ?? true,
    customer: customer == null
        ? null
        : CrmLinkedCustomer(
            id: customer['id'] as String,
            fullName: _name(customer),
            phone: customer['phone'] as String?,
            isActive: customer['isActive'] as bool? ?? true,
          ),
    vehicles: [for (final v in (json['vehicles'] as List? ?? const [])) crmVehicleFromJson(v as Map<String, dynamic>)],
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}

CrmVehicle crmVehicleFromJson(Map<String, dynamic> json) {
  final next = (json['visitItems'] as List?)?.cast<Map<String, dynamic>>();
  final due = next != null && next.isNotEmpty && next.first['dueDate'] != null ? next.first : null;
  return CrmVehicle(
    id: json['id'] as String,
    plateNumber: json['plateNumber'] as String,
    model: json['model'] as String,
    dailyKm: (json['dailyKm'] as num?)?.toInt(),
    notes: json['notes'] as String?,
    driverId: json['driverId'] as String,
    nextDue: due == null
        ? null
        : CrmNextDue(
            id: due['id'] as String,
            productName: due['productName'] as String,
            dueDate: DateTime.parse(due['dueDate'] as String),
            dueOdometerKm: (due['dueOdometerKm'] as num?)?.toInt(),
          ),
  );
}

CrmTelegramStatus crmTelegramStatusFromJson(Map<String, dynamic> json) => CrmTelegramStatus(
      botUsername: json['botUsername'] as String?,
      linked: json['linked'] as bool? ?? false,
      blocked: json['blocked'] as bool? ?? false,
    );

CrmVisitItem crmVisitItemFromJson(Map<String, dynamic> json) => CrmVisitItem(
      id: json['id'] as String,
      productId: json['productId'] as String?,
      productName: json['productName'] as String,
      quantity: parseDecimal(json['quantity']),
      unitPrice: parseNullableDecimal(json['unitPrice']),
      intervalKm: (json['intervalKm'] as num?)?.toInt(),
      dueOdometerKm: (json['dueOdometerKm'] as num?)?.toInt(),
      dueDate: json['dueDate'] == null ? null : DateTime.parse(json['dueDate'] as String),
      dueDateManual: json['dueDateManual'] as bool? ?? false,
      status: CrmItemStatus.fromWire(json['status'] as String),
      closedByVisitId: json['closedByVisitId'] as String?,
    );

CrmVehicleRef _vehicleRef(Map<String, dynamic> json) => CrmVehicleRef(
      id: json['id'] as String,
      plateNumber: json['plateNumber'] as String,
      model: json['model'] as String,
      dailyKm: (json['dailyKm'] as num?)?.toInt(),
    );

CrmVisit crmVisitFromJson(Map<String, dynamic> json) {
  final sale = json['sale'] as Map<String, dynamic>?;
  final debt = sale?['debt'] as Map<String, dynamic>?;
  return CrmVisit(
    id: json['id'] as String,
    serviceDate: DateTime.parse(json['serviceDate'] as String),
    odometerKm: (json['odometerKm'] as num?)?.toInt(),
    notes: json['notes'] as String?,
    vehicle: _vehicleRef(json['vehicle'] as Map<String, dynamic>),
    items: [for (final i in (json['items'] as List)) crmVisitItemFromJson(i as Map<String, dynamic>)],
    sale: sale == null
        ? null
        : CrmVisitSale(
            id: sale['id'] as String,
            saleNumber: sale['saleNumber'] as String,
            isDebt: sale['type'] == 'DEBT',
            total: parseDecimal(sale['total']),
            currency: Currency.fromWire(sale['currency'] as String),
            debtBalance: debt == null ? null : parseDecimal(debt['balance']),
          ),
  );
}

CrmReminder crmReminderFromJson(Map<String, dynamic> json) {
  final vehicle = json['vehicle'] as Map<String, dynamic>;
  final driver = vehicle['driver'] as Map<String, dynamic>;
  return CrmReminder(
    item: crmVisitItemFromJson(json),
    serviceDate: DateTime.parse((json['visit'] as Map<String, dynamic>)['serviceDate'] as String),
    vehicle: _vehicleRef(vehicle),
    driver: CrmReminderDriver(
      id: driver['id'] as String,
      fullName: _name(driver),
      phone: driver['phone'] as String,
      imageUrl: driver['imageUrl'] as String?,
    ),
  );
}

CrmReminderPage crmReminderPageFromJson(Map<String, dynamic> json) {
  final counts = (json['meta'] as Map<String, dynamic>)['counts'] as Map<String, dynamic>? ?? const {};
  return CrmReminderPage(
    page: PaginatedResult.fromJson(json, crmReminderFromJson),
    overdueCount: (counts['overdue'] as num?)?.toInt() ?? 0,
    soonCount: (counts['soon'] as num?)?.toInt() ?? 0,
  );
}
