import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/master_catalog/domain/repositories/master_catalog_repository.dart';

class DeleteMasterProductUseCase {
  DeleteMasterProductUseCase(this._repository);

  final MasterCatalogRepository _repository;

  Future<Result<void>> call(String id) => _repository.delete(id);
}
