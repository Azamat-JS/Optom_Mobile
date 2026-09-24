import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/courier/domain/entities/courier.dart';
import 'package:bsmart/features/courier/domain/entities/courier_write_params.dart';
import 'package:bsmart/features/courier/domain/repositories/courier_repository.dart';

class CreateCourierUseCase {
  CreateCourierUseCase(this._repository);

  final CourierRepository _repository;

  Future<Result<Courier>> call(CreateCourierParams params) => _repository.create(params);
}
