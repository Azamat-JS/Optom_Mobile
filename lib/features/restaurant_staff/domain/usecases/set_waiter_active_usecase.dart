import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/restaurant_staff/domain/entities/waiter.dart';
import 'package:bsmart/features/restaurant_staff/domain/repositories/restaurant_staff_repository.dart';

class SetWaiterActiveUseCase {
  SetWaiterActiveUseCase(this._repository);

  final RestaurantStaffRepository _repository;

  Future<Result<Waiter>> call(String id, bool isActive) => _repository.setActive(id, isActive);
}
