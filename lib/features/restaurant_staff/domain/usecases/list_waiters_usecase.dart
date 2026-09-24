import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/restaurant_staff/domain/entities/waiter_list_result.dart';
import 'package:bsmart/features/restaurant_staff/domain/repositories/restaurant_staff_repository.dart';

class ListWaitersUseCase {
  ListWaitersUseCase(this._repository);

  final RestaurantStaffRepository _repository;

  Future<Result<WaiterListResult>> call({String? search}) => _repository.list(search: search);
}
