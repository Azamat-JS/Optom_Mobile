import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/stores/domain/entities/store.dart';
import 'package:bsmart/features/stores/domain/entities/store_write_params.dart';

abstract class StoresRepository {
  Future<Result<List<Store>>> list();

  Future<Result<Store>> create(CreateStoreParams params);

  Future<Result<Store>> update(String id, UpdateStoreParams params);

  Future<Result<Store>> setActive(String id, bool isActive);

  Future<Result<void>> delete(String id);
}
