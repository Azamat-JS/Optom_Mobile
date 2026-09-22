import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/categories/domain/entities/category.dart';
import 'package:bsmart/features/categories/domain/repositories/categories_repository.dart';

class GetCategoriesUseCase {
  GetCategoriesUseCase(this._repository);

  final CategoriesRepository _repository;

  Future<Result<List<Category>>> call({String? search}) {
    return _repository.getRootCategoriesWithChildren(search: search);
  }
}
