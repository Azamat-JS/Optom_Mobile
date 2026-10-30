import 'package:bsmart/core/enums/sale_enums.dart';
import 'package:bsmart/features/crm/domain/crm_due.dart';

/// `GET /crm/drivers` filters (`CrmDriverQueryDto`).
class CrmDriverQuery {
  const CrmDriverQuery({this.page = 1, this.limit = 20, this.search, this.activeOnly});

  final int page;
  final int limit;
  final String? search;

  /// true = active, false = inactive, null = all.
  final bool? activeOnly;

  CrmDriverQuery copyWith({int? page, String? search, bool? activeOnly, bool clearActive = false}) => CrmDriverQuery(
        page: page ?? this.page,
        limit: limit,
        search: search ?? this.search,
        activeOnly: clearActive ? null : (activeOnly ?? this.activeOnly),
      );

  Map<String, dynamic> toQueryParameters() => {
        'page': page,
        'limit': limit,
        if (search != null && search!.trim().isNotEmpty) 'search': search!.trim(),
        if (activeOnly != null) 'status': activeOnly! ? 'active' : 'inactive',
      };
}

/// Which reminders: overdue, due within 7 days, or all (`CrmReminderQueryDto.when`).
enum CrmReminderWhen {
  all('all'),
  overdue('overdue'),
  soon('soon');

  const CrmReminderWhen(this.wire);
  final String wire;
}

class CrmReminderQuery {
  const CrmReminderQuery({this.page = 1, this.limit = 20, this.search, this.when = CrmReminderWhen.all});

  final int page;
  final int limit;
  final String? search;
  final CrmReminderWhen when;

  CrmReminderQuery copyWith({int? page, String? search, CrmReminderWhen? when}) =>
      CrmReminderQuery(page: page ?? this.page, limit: limit, search: search ?? this.search, when: when ?? this.when);

  Map<String, dynamic> toQueryParameters() => {
        'page': page,
        'limit': limit,
        'when': when.wire,
        if (search != null && search!.trim().isNotEmpty) 'search': search!.trim(),
      };
}

/// A car's fields, for create and edit. Every key is sent, so clearing daily km sends `null`.
class CrmVehicleParams {
  const CrmVehicleParams({required this.plateNumber, required this.model, this.dailyKm, this.notes});

  final String plateNumber;
  final String model;
  final int? dailyKm;
  final String? notes;

  Map<String, dynamic> toRequestBody() => {
        'plateNumber': plateNumber.trim(),
        'model': model.trim(),
        'dailyKm': dailyKm,
        'notes': (notes?.trim().isEmpty ?? true) ? null : notes!.trim(),
      };
}

class CreateCrmDriverParams {
  const CreateCrmDriverParams({
    required this.firstName,
    this.lastName = '',
    required this.phone,
    this.notes,
    this.vehicles = const [],
  });

  final String firstName;
  final String lastName;
  final String phone;
  final String? notes;
  final List<CrmVehicleParams> vehicles;

  Map<String, dynamic> toRequestBody() => {
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'phone': phone.trim(),
        if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
        if (vehicles.isNotEmpty) 'vehicles': [for (final v in vehicles) v.toRequestBody()],
      };
}

class UpdateCrmDriverParams {
  const UpdateCrmDriverParams({
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.notes,
    required this.isActive,
  });

  final String firstName;
  final String lastName;
  final String phone;
  final String? notes;
  final bool isActive;

  Map<String, dynamic> toRequestBody() => {
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'phone': phone.trim(),
        'notes': (notes?.trim().isEmpty ?? true) ? null : notes!.trim(),
        'isActive': isActive,
      };
}

/// One line of a visit: a store product, or a typed name (labour, the driver's own oil …).
class CrmVisitItemParams {
  const CrmVisitItemParams({
    this.productId,
    this.productName,
    required this.quantity,
    this.unitPrice,
    this.intervalKm,
    this.dueDate,
  });

  final String? productId;
  final String? productName;
  final double quantity;
  final double? unitPrice;
  final int? intervalKm;

  /// Set by hand (wins over the km estimate).
  final DateTime? dueDate;

  Map<String, dynamic> toRequestBody() => {
        if (productId != null) 'productId': productId else 'productName': productName?.trim(),
        'quantity': quantity,
        if (unitPrice != null && unitPrice! > 0) 'unitPrice': unitPrice,
        if (intervalKm != null) 'intervalKm': intervalKm,
        if (dueDate != null) 'dueDate': dayWire(dueDate!),
      };
}

class CreateCrmVisitParams {
  const CreateCrmVisitParams({
    required this.vehicleId,
    required this.serviceDate,
    this.odometerKm,
    this.notes,
    required this.recordSale,
    this.saleType = SaleType.paid,
    this.paidAmount,
    required this.items,
  });

  final String vehicleId;
  final DateTime serviceDate;
  final int? odometerKm;
  final String? notes;

  /// false: track the parts only (no stock, no money).
  final bool recordSale;
  final SaleType saleType;

  /// Debt only: paid up front.
  final double? paidAmount;
  final List<CrmVisitItemParams> items;

  Map<String, dynamic> toRequestBody() => {
        'vehicleId': vehicleId,
        'serviceDate': dayWire(serviceDate),
        if (odometerKm != null) 'odometerKm': odometerKm,
        if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
        'recordSale': recordSale,
        if (recordSale) 'paymentType': saleType == SaleType.debt ? 'DEBT' : 'PAID',
        if (recordSale && saleType == SaleType.debt && (paidAmount ?? 0) > 0) 'paidAmount': paidAmount,
        'items': [for (final i in items) i.toRequestBody()],
      };
}
