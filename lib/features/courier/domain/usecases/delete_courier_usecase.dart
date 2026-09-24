import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/courier/domain/repositories/courier_repository.dart';

class DeleteCourierUseCase {
  DeleteCourierUseCase(this._repository);

  final CourierRepository _repository;

  Future<Result<void>> call(String id) => _repository.delete(id);
}
