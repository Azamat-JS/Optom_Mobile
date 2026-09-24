import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/restaurant_staff/domain/repositories/restaurant_staff_repository.dart';

class DeleteWaiterUseCase {
  DeleteWaiterUseCase(this._repository);

  final RestaurantStaffRepository _repository;

  Future<Result<void>> call(String id) => _repository.delete(id);
}
