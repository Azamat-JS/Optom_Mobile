import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/categories/domain/entities/category.dart';
import 'package:bsmart/features/categories/domain/entities/category_query.dart';
import 'package:bsmart/features/categories/domain/entities/category_write_params.dart';

abstract class CategoriesRepository {
  /// The full 2-level category tree (root categories with their
  /// subcategories embedded) — used to build a picker when creating/editing
  /// a product.
  Future<Result<List<Category>>> getRootCategoriesWithChildren({String? search});

  /// Flat admin-management list (Phase 3, SUPER_ADMIN only) — see
  /// [CategoryQuery]'s doc comment for how this differs from the tree above.
  Future<Result<PaginatedResult<Category>>> list(CategoryQuery query);

  Future<Result<Category>> create(CreateCategoryParams params);

  Future<Result<Category>> update(String id, UpdateCategoryParams params);

  Future<Result<Category>> uploadImage(String id, {required String filePath});

  Future<Result<void>> delete(String id);
}
