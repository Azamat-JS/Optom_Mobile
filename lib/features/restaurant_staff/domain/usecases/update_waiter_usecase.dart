import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/restaurant_staff/domain/entities/waiter.dart';
import 'package:bsmart/features/restaurant_staff/domain/entities/waiter_write_params.dart';
import 'package:bsmart/features/restaurant_staff/domain/repositories/restaurant_staff_repository.dart';

class UpdateWaiterUseCase {
  UpdateWaiterUseCase(this._repository);

  final RestaurantStaffRepository _repository;

  Future<Result<Waiter>> call(String id, UpdateWaiterParams params) => _repository.update(id, params);
}
