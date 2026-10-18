import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/features/storefront/domain/entities/storefront_branch.dart';
import 'package:bsmart/features/storefront/domain/entities/storefront_product.dart';
import 'package:bsmart/features/storefront/domain/entities/storefront_query.dart';
import 'package:bsmart/features/storefront/domain/usecases/browse_storefront_usecase.dart';
import 'package:bsmart/features/storefront/domain/usecases/list_shop_branches_usecase.dart';

/// Which shop page: the owner, optionally narrowed to one branch.
typedef ShopKey = ({String sellerId, String? storeId});

/// Every product of a shop (or one branch of it), loaded page by page.
///
/// The shop page searches, filters and jumps between category sections on
/// the device, so it needs the whole list. Capped at [maxPages] × 100.
final shopProductsProvider = FutureProvider.autoDispose.family<List<StorefrontProduct>, ShopKey>((ref, key) async {
  const maxPages = 10;
  final products = <StorefrontProduct>[];
  var query = StorefrontQuery(sellerId: key.sellerId, storeId: key.storeId, limit: 100);
  for (var page = 1; page <= maxPages; page++) {
    final result = await getIt<BrowseStorefrontUseCase>().call(query);
    final pageData = result.fold((p) => p, (failure) => throw failure);
    products.addAll(pageData.data);
    if (!pageData.meta.hasNext) break;
    query = query.copyWith(page: page + 1);
  }
  return products;
});

/// A shop's active branches (default first). Empty on failure: the branch
/// picker is optional, the page works without it.
final shopBranchesProvider = FutureProvider.autoDispose.family<List<StorefrontBranch>, String>((ref, sellerId) async {
  final result = await getIt<ListShopBranchesUseCase>().call(sellerId);
  return result.fold((branches) => branches, (_) => const []);
});
