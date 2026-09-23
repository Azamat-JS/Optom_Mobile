import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/stores/domain/entities/store.dart';
import 'package:bsmart/features/stores/domain/repositories/stores_repository.dart';

class SetStoreActiveUseCase {
  SetStoreActiveUseCase(this._repository);

  final StoresRepository _repository;

  Future<Result<Store>> call(String id, bool isActive) => _repository.setActive(id, isActive);
}
