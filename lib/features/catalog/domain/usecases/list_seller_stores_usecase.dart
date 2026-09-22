import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/catalog/domain/entities/catalog_seller.dart';
import 'package:bsmart/features/catalog/domain/repositories/catalog_repository.dart';

class ListSellerStoresUseCase {
  ListSellerStoresUseCase(this._repository);

  final CatalogRepository _repository;

  Future<Result<List<CatalogStore>>> call(String sellerId) => _repository.listStoresForSeller(sellerId);
}
