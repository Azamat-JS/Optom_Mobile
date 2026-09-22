import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/features/categories/domain/entities/category.dart';
import 'package:bsmart/features/categories/domain/usecases/get_categories_usecase.dart';

/// The full category tree, loaded once and kept for the app session —
/// categories change rarely (SUPER_ADMIN-managed) and are reused across the
/// product list filter, product form's category picker, and (once built)
/// master-catalog browsing.
class CategoriesNotifier extends AsyncNotifier<List<Category>> {
  @override
  Future<List<Category>> build() async {
    final result = await getIt<GetCategoriesUseCase>().call();
    return result.fold((categories) => categories, (failure) => throw failure);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await getIt<GetCategoriesUseCase>().call();
      return result.fold((categories) => categories, (failure) => throw failure);
    });
  }
}

final categoriesProvider = AsyncNotifierProvider<CategoriesNotifier, List<Category>>(
  CategoriesNotifier.new,
);
