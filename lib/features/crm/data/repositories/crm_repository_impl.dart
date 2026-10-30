import 'package:dio/dio.dart';

import 'package:bsmart/core/network/dio_error_mapper.dart';
import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/crm/data/datasources/crm_remote_data_source.dart';
import 'package:bsmart/features/crm/domain/entities/crm_driver.dart';
import 'package:bsmart/features/crm/domain/entities/crm_params.dart';
import 'package:bsmart/features/crm/domain/entities/crm_visit.dart';
import 'package:bsmart/features/crm/domain/repositories/crm_repository.dart';

class CrmRepositoryImpl implements CrmRepository {
  CrmRepositoryImpl(this._remote);

  final CrmRemoteDataSource _remote;

  Future<Result<T>> _guard<T>(Future<T> Function() call) async {
    try {
      return Result.ok(await call());
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<PaginatedResult<CrmDriver>>> listDrivers(CrmDriverQuery query) => _guard(() => _remote.listDrivers(query));

  @override
  Future<Result<CrmDriver>> getDriver(String id) => _guard(() => _remote.getDriver(id));

  @override
  Future<Result<CrmDriver>> createDriver(CreateCrmDriverParams params) => _guard(() => _remote.createDriver(params));

  @override
  Future<Result<CrmDriver>> updateDriver(String id, UpdateCrmDriverParams params) => _guard(() => _remote.updateDriver(id, params));

  @override
  Future<Result<void>> deleteDriver(String id) => _guard(() => _remote.deleteDriver(id));

  @override
  Future<Result<CrmDriver>> uploadDriverPhoto(String id, {required String filePath}) => _guard(() => _remote.uploadDriverPhoto(id, filePath: filePath));

  @override
  Future<Result<CrmDriver>> removeDriverPhoto(String id) => _guard(() => _remote.removeDriverPhoto(id));

  @override
  Future<Result<CrmTelegramStatus>> getDriverTelegram(String id) => _guard(() => _remote.getDriverTelegram(id));

  @override
  Future<Result<void>> addVehicle(String driverId, CrmVehicleParams params) => _guard(() => _remote.addVehicle(driverId, params));

  @override
  Future<Result<void>> updateVehicle(String id, CrmVehicleParams params) => _guard(() => _remote.updateVehicle(id, params));

  @override
  Future<Result<void>> deleteVehicle(String id) => _guard(() => _remote.deleteVehicle(id));

  @override
  Future<Result<CrmVisit>> createVisit(CreateCrmVisitParams params) => _guard(() => _remote.createVisit(params));

  @override
  Future<Result<PaginatedResult<CrmVisit>>> listVisits({required String driverId, int page = 1, int limit = 10}) => _guard(() => _remote.listVisits(driverId: driverId, page: page, limit: limit));

  @override
  Future<Result<CrmReminderPage>> listReminders(CrmReminderQuery query) => _guard(() => _remote.listReminders(query));

  @override
  Future<Result<void>> updateReminder(String id, {CrmItemStatus? status, DateTime? dueDate}) => _guard(() => _remote.updateReminder(id, status: status, dueDate: dueDate));
}
