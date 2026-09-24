import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/features/categories/domain/entities/category.dart';
import 'package:bsmart/features/categories/domain/entities/category_query.dart';
import 'package:bsmart/features/categories/domain/usecases/list_categories_paginated_usecase.dart';

/// The SUPER_ADMIN admin-management list — flat (not the 2-level tree the
/// product-form picker uses), includes inactive categories, and always
/// fetched in one page since the total category count is small by design
/// (a handful of root categories, each with a handful of children) — same
/// simplifying assumption `AdminsListNotifier` makes for panel staff.
class CategoriesAdminListNotifier extends AsyncNotifier<List<Category>> {
  @override
  Future<List<Category>> build() => _fetch();

  Future<List<Category>> _fetch() async {
    final result = await getIt<ListCategoriesPaginatedUseCase>().call(const CategoryQuery(limit: 100));
    return result.fold((page) => page.data, (failure) => throw failure);
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(_fetch);
  }
}

final categoriesAdminListProvider = AsyncNotifierProvider<CategoriesAdminListNotifier, List<Category>>(
  CategoriesAdminListNotifier.new,
);
