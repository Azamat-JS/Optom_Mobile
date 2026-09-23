import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/storefront/domain/entities/storefront_product.dart';
import 'package:bsmart/features/storefront/domain/repositories/storefront_repository.dart';

class GetStorefrontProductUseCase {
  GetStorefrontProductUseCase(this._repository);

  final StorefrontRepository _repository;

  Future<Result<StorefrontProduct>> call(String id) => _repository.getProduct(id);
}
