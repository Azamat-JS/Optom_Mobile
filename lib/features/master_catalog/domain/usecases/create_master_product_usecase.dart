import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/master_catalog/domain/entities/master_product.dart';
import 'package:bsmart/features/master_catalog/domain/entities/master_product_write_params.dart';
import 'package:bsmart/features/master_catalog/domain/repositories/master_catalog_repository.dart';

class CreateMasterProductUseCase {
  CreateMasterProductUseCase(this._repository);

  final MasterCatalogRepository _repository;

  Future<Result<MasterProduct>> call(CreateMasterProductParams params) => _repository.create(params);
}
