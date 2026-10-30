import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/crm/domain/entities/crm_driver.dart';
import 'package:bsmart/features/crm/domain/entities/crm_params.dart';
import 'package:bsmart/features/crm/domain/entities/crm_visit.dart';

/// `/crm/*` (Optom_Savdo CLAUDE.md "CRM" C2–C4). Every call answers 403 while SUPER_ADMIN hasn't
/// switched CRM on for the business.
abstract class CrmRepository {
  Future<Result<PaginatedResult<CrmDriver>>> listDrivers(CrmDriverQuery query);

  Future<Result<CrmDriver>> getDriver(String id);

  Future<Result<CrmDriver>> createDriver(CreateCrmDriverParams params);

  Future<Result<CrmDriver>> updateDriver(String id, UpdateCrmDriverParams params);

  Future<Result<void>> deleteDriver(String id);

  Future<Result<CrmDriver>> uploadDriverPhoto(String id, {required String filePath});

  Future<Result<CrmDriver>> removeDriverPhoto(String id);

  Future<Result<CrmTelegramStatus>> getDriverTelegram(String id);

  Future<Result<void>> addVehicle(String driverId, CrmVehicleParams params);

  Future<Result<void>> updateVehicle(String id, CrmVehicleParams params);

  Future<Result<void>> deleteVehicle(String id);

  Future<Result<CrmVisit>> createVisit(CreateCrmVisitParams params);

  Future<Result<PaginatedResult<CrmVisit>>> listVisits({required String driverId, int page = 1, int limit = 10});

  Future<Result<CrmReminderPage>> listReminders(CrmReminderQuery query);

  /// Close an active reminder (`done`/`cancelled`) or move its date (it becomes hand-set).
  Future<Result<void>> updateReminder(String id, {CrmItemStatus? status, DateTime? dueDate});
}
