import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/storefront/domain/entities/storefront_product.dart';
import 'package:bsmart/features/storefront/domain/repositories/storefront_repository.dart';

class ListStorefrontCategoriesUseCase {
  ListStorefrontCategoriesUseCase(this._repository);

  final StorefrontRepository _repository;

  Future<Result<List<StorefrontCategory>>> call() => _repository.listCategories();
}
