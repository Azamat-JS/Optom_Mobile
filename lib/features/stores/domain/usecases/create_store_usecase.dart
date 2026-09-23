import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/stores/domain/entities/store.dart';
import 'package:bsmart/features/stores/domain/entities/store_write_params.dart';
import 'package:bsmart/features/stores/domain/repositories/stores_repository.dart';

class CreateStoreUseCase {
  CreateStoreUseCase(this._repository);

  final StoresRepository _repository;

  Future<Result<Store>> call(CreateStoreParams params) => _repository.create(params);
}
