import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/courier/domain/entities/courier.dart';
import 'package:bsmart/features/courier/domain/entities/courier_list_result.dart';
import 'package:bsmart/features/courier/domain/entities/courier_write_params.dart';

abstract class CourierRepository {
  Future<Result<CourierListResult>> list({String? search});

  Future<Result<Courier>> create(CreateCourierParams params);

  Future<Result<Courier>> update(String id, UpdateCourierParams params);

  Future<Result<Courier>> setActive(String id, bool isActive);

  Future<Result<void>> delete(String id);
}
