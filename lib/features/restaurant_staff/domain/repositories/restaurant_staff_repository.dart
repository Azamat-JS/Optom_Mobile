import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/restaurant_staff/domain/entities/waiter.dart';
import 'package:bsmart/features/restaurant_staff/domain/entities/waiter_list_result.dart';
import 'package:bsmart/features/restaurant_staff/domain/entities/waiter_write_params.dart';

abstract class RestaurantStaffRepository {
  Future<Result<WaiterListResult>> list({String? search});

  Future<Result<Waiter>> create(CreateWaiterParams params);

  Future<Result<Waiter>> update(String id, UpdateWaiterParams params);

  Future<Result<Waiter>> setActive(String id, bool isActive);

  Future<Result<void>> delete(String id);
}
