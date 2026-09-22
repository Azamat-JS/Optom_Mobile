import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/products/domain/repositories/products_repository.dart';

class GetNextPluUseCase {
  GetNextPluUseCase(this._repository);

  final ProductsRepository _repository;

  Future<Result<String>> call() => _repository.nextPlu();
}
