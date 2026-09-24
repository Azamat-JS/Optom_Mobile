import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/courier/domain/entities/courier.dart';
import 'package:bsmart/features/courier/domain/repositories/courier_repository.dart';

class SetCourierActiveUseCase {
  SetCourierActiveUseCase(this._repository);

  final CourierRepository _repository;

  Future<Result<Courier>> call(String id, bool isActive) => _repository.setActive(id, isActive);
}
