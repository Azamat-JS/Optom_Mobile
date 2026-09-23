import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/features/storefront/domain/entities/storefront_product.dart';
import 'package:bsmart/features/storefront/domain/usecases/list_storefront_categories_usecase.dart';

class StorefrontCategoriesNotifier extends AsyncNotifier<List<StorefrontCategory>> {
  @override
  Future<List<StorefrontCategory>> build() async {
    final result = await getIt<ListStorefrontCategoriesUseCase>().call();
    return result.fold((d) => d, (failure) => throw failure);
  }
}

final storefrontCategoriesProvider = AsyncNotifierProvider<StorefrontCategoriesNotifier, List<StorefrontCategory>>(
  StorefrontCategoriesNotifier.new,
);
