import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/categories/domain/repositories/categories_repository.dart';

class DeleteCategoryUseCase {
  DeleteCategoryUseCase(this._repository);

  final CategoriesRepository _repository;

  Future<Result<void>> call(String id) => _repository.delete(id);
}
