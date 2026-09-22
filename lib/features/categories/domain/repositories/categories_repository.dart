import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/categories/domain/entities/category.dart';

abstract class CategoriesRepository {
  /// The full 2-level category tree (root categories with their
  /// subcategories embedded) — used to build a picker when creating/editing
  /// a product. Read-only: see [Category]'s doc comment on why there's no
  /// create/update/delete here.
  Future<Result<List<Category>>> getRootCategoriesWithChildren({String? search});
}
