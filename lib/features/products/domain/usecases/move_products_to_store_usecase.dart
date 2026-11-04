import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/products/domain/entities/product_move_result.dart';
import 'package:bsmart/features/products/domain/repositories/products_repository.dart';

/// Owner only: moves products of the active store to another of the owner's
/// stores. All or nothing — on a refusal nothing moved and the failure carries
/// the server's reason (barcode/PLU taken there, product in a pending order…).
class MoveProductsToStoreUseCase {
  MoveProductsToStoreUseCase(this._repository);

  final ProductsRepository _repository;

  Future<Result<ProductMoveResult>> call(List<String> productIds, String targetStoreId) =>
      _repository.moveToStore(productIds, targetStoreId);
}
