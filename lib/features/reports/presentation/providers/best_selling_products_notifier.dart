import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/features/products/domain/entities/product.dart';
import 'package:bsmart/features/products/domain/usecases/get_best_selling_products_usecase.dart';

/// The Reports hub's "Eng ko'p sotilgan mahsulotlar" section — reuses
/// `features/products`' own `bestSelling()` repository method (built but
/// never wired to a use case in Milestone 2) rather than duplicating the
/// fetch in `features/reports`.
class BestSellingProductsNotifier extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() async {
    final result = await getIt<GetBestSellingProductsUseCase>().call(limit: 10);
    return result.fold((d) => d, (failure) => throw failure);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final bestSellingProductsProvider = AsyncNotifierProvider<BestSellingProductsNotifier, List<Product>>(
  BestSellingProductsNotifier.new,
);
