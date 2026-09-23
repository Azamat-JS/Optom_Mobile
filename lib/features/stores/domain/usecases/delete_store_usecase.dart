import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/stores/domain/repositories/stores_repository.dart';

class DeleteStoreUseCase {
  DeleteStoreUseCase(this._repository);

  final StoresRepository _repository;

  Future<Result<void>> call(String id) => _repository.delete(id);
}
