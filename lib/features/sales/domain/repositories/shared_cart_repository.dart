import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/sales/domain/entities/shared_cart.dart';
import 'package:bsmart/features/sales/domain/entities/shared_cart_write_params.dart';

abstract class SharedCartRepository {
  Future<Result<List<SharedCart>>> list();

  Future<Result<SharedCart>> park(CreateSharedCartParams params);

  /// Atomic pop — deletes the parked cart server-side and returns the row
  /// that was deleted, so the caller can rebuild a cart from it in one call.
  Future<Result<SharedCart>> remove(String id);
}
