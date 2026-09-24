import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/categories/domain/entities/category.dart';
import 'package:bsmart/features/categories/domain/entities/category_query.dart';
import 'package:bsmart/features/categories/domain/repositories/categories_repository.dart';

class ListCategoriesPaginatedUseCase {
  ListCategoriesPaginatedUseCase(this._repository);

  final CategoriesRepository _repository;

  Future<Result<PaginatedResult<Category>>> call(CategoryQuery query) => _repository.list(query);
}
