import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/courier/domain/entities/courier_list_result.dart';
import 'package:bsmart/features/courier/domain/repositories/courier_repository.dart';

class ListCouriersUseCase {
  ListCouriersUseCase(this._repository);

  final CourierRepository _repository;

  Future<Result<CourierListResult>> call({String? search}) => _repository.list(search: search);
}
