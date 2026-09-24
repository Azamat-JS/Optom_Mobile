import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/categories/domain/entities/category.dart';
import 'package:bsmart/features/categories/domain/entities/category_write_params.dart';
import 'package:bsmart/features/categories/domain/repositories/categories_repository.dart';

class UpdateCategoryUseCase {
  UpdateCategoryUseCase(this._repository);

  final CategoriesRepository _repository;

  Future<Result<Category>> call(String id, UpdateCategoryParams params) => _repository.update(id, params);
}
