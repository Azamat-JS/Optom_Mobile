import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/courier/domain/entities/courier.dart';
import 'package:bsmart/features/courier/domain/entities/courier_write_params.dart';
import 'package:bsmart/features/courier/domain/repositories/courier_repository.dart';

class UpdateCourierUseCase {
  UpdateCourierUseCase(this._repository);

  final CourierRepository _repository;

  Future<Result<Courier>> call(String id, UpdateCourierParams params) => _repository.update(id, params);
}
