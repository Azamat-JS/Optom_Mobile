import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/products/domain/product_move_targets.dart';
import 'package:bsmart/features/products/domain/repositories/products_repository.dart';

/// The active store and the stores its products may be sent to (owner/admin).
class GetProductMoveTargetsUseCase {
  GetProductMoveTargetsUseCase(this._repository);

  final ProductsRepository _repository;

  Future<Result<ProductMoveTargets>> call() => _repository.moveTargets();
}
