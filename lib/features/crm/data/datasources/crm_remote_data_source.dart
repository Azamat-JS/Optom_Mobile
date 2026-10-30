import 'package:dio/dio.dart';

import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/features/crm/data/models/crm_models.dart';
import 'package:bsmart/features/crm/domain/crm_due.dart';
import 'package:bsmart/features/crm/domain/entities/crm_driver.dart';
import 'package:bsmart/features/crm/domain/entities/crm_params.dart';
import 'package:bsmart/features/crm/domain/entities/crm_visit.dart';

/// Raw `/crm/*` calls — the active store's drivers, cars, service visits and reminders.
class CrmRemoteDataSource {
  CrmRemoteDataSource(this._dio);

  final Dio _dio;

  Future<PaginatedResult<CrmDriver>> listDrivers(CrmDriverQuery query) async {
    final response = await _dio.get<Map<String, dynamic>>('/crm/drivers', queryParameters: query.toQueryParameters());
    return PaginatedResult.fromJson(response.data!, crmDriverFromJson);
  }

  Future<CrmDriver> getDriver(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/crm/drivers/$id');
    return crmDriverFromJson(response.data!);
  }

  Future<CrmDriver> createDriver(CreateCrmDriverParams params) async {
    final response = await _dio.post<Map<String, dynamic>>('/crm/drivers', data: params.toRequestBody());
    return crmDriverFromJson(response.data!);
  }

  Future<CrmDriver> updateDriver(String id, UpdateCrmDriverParams params) async {
    final response = await _dio.patch<Map<String, dynamic>>('/crm/drivers/$id', data: params.toRequestBody());
    return crmDriverFromJson(response.data!);
  }

  Future<void> deleteDriver(String id) => _dio.delete<void>('/crm/drivers/$id');

  Future<CrmDriver> uploadDriverPhoto(String id, {required String filePath}) async {
    final formData = FormData.fromMap({'image': await MultipartFile.fromFile(filePath)});
    final response = await _dio.post<Map<String, dynamic>>('/crm/drivers/$id/photo', data: formData);
    return crmDriverFromJson(response.data!);
  }

  Future<CrmDriver> removeDriverPhoto(String id) async {
    final response = await _dio.delete<Map<String, dynamic>>('/crm/drivers/$id/photo');
    return crmDriverFromJson(response.data!);
  }

  Future<CrmTelegramStatus> getDriverTelegram(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/crm/drivers/$id/telegram');
    return crmTelegramStatusFromJson(response.data!);
  }

  Future<void> addVehicle(String driverId, CrmVehicleParams params) =>
      _dio.post<void>('/crm/drivers/$driverId/vehicles', data: params.toRequestBody());

  Future<void> updateVehicle(String id, CrmVehicleParams params) =>
      _dio.patch<void>('/crm/vehicles/$id', data: params.toRequestBody());

  Future<void> deleteVehicle(String id) => _dio.delete<void>('/crm/vehicles/$id');

  Future<CrmVisit> createVisit(CreateCrmVisitParams params) async {
    final response = await _dio.post<Map<String, dynamic>>('/crm/visits', data: params.toRequestBody());
    return crmVisitFromJson(response.data!);
  }

  Future<PaginatedResult<CrmVisit>> listVisits({required String driverId, int page = 1, int limit = 10}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/crm/visits',
      queryParameters: {'driverId': driverId, 'page': page, 'limit': limit},
    );
    return PaginatedResult.fromJson(response.data!, crmVisitFromJson);
  }

  Future<CrmReminderPage> listReminders(CrmReminderQuery query) async {
    final response = await _dio.get<Map<String, dynamic>>('/crm/reminders', queryParameters: query.toQueryParameters());
    return crmReminderPageFromJson(response.data!);
  }

  Future<void> updateReminder(String id, {CrmItemStatus? status, DateTime? dueDate}) => _dio.patch<void>(
        '/crm/visit-items/$id',
        data: {
          if (status == CrmItemStatus.done) 'status': 'DONE',
          if (status == CrmItemStatus.cancelled) 'status': 'CANCELLED',
          if (dueDate != null) 'dueDate': dayWire(dueDate),
        },
      );
}
