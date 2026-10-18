import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/storefront/domain/entities/storefront_branch.dart';
import 'package:bsmart/features/storefront/domain/repositories/storefront_repository.dart';

class ListShopBranchesUseCase {
  ListShopBranchesUseCase(this._repository);

  final StorefrontRepository _repository;

  Future<Result<List<StorefrontBranch>>> call(String sellerId) => _repository.listBranches(sellerId);
}
