import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/catalog/domain/entities/catalog_seller.dart';
import 'package:bsmart/features/catalog/domain/repositories/catalog_repository.dart';

class ListCatalogSellersUseCase {
  ListCatalogSellersUseCase(this._repository);

  final CatalogRepository _repository;

  Future<Result<List<CatalogSeller>>> call() => _repository.listSellers();
}
