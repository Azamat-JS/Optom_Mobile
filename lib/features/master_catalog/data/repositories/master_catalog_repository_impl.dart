import 'package:dio/dio.dart';

import 'package:bsmart/core/enums/master_product_status.dart';
import 'package:bsmart/core/network/dio_error_mapper.dart';
import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/master_catalog/data/datasources/master_catalog_remote_data_source.dart';
import 'package:bsmart/features/master_catalog/domain/entities/master_product.dart';
import 'package:bsmart/features/master_catalog/domain/entities/master_product_write_params.dart';
import 'package:bsmart/features/master_catalog/domain/repositories/master_catalog_repository.dart';

class MasterCatalogRepositoryImpl implements MasterCatalogRepository {
  MasterCatalogRepositoryImpl(this._remote);

  final MasterCatalogRemoteDataSource _remote;

  @override
  Future<Result<PaginatedResult<MasterProduct>>> search({
    String? search,
    String? categoryId,
    String? barcode,
    MasterProductStatus? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final result = await _remote.search(
        search: search,
        categoryId: categoryId,
        barcode: barcode,
        status: status,
        page: page,
        limit: limit,
      );
      return Result.ok(result);
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<MasterProduct>> getById(String id) async {
    try {
      return Result.ok(await _remote.getById(id));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<MasterProduct>> create(CreateMasterProductParams params) async {
    try {
      return Result.ok(await _remote.create(params));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<MasterProduct>> update(String id, UpdateMasterProductParams params) async {
    try {
      return Result.ok(await _remote.update(id, params));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<MasterProduct>> approve(String id) async {
    try {
      return Result.ok(await _remote.approve(id));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<MasterProduct>> reject(String id, {String? reason}) async {
    try {
      return Result.ok(await _remote.reject(id, reason: reason));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await _remote.delete(id);
      return const Result.ok(null);
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<MasterProductImageRef>> uploadImage(
    String id, {
    required String filePath,
    bool isPrimary = false,
  }) async {
    try {
      return Result.ok(await _remote.uploadImage(id, filePath: filePath, isPrimary: isPrimary));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<void>> removeImage(String id, String imageId) async {
    try {
      await _remote.removeImage(id, imageId);
      return const Result.ok(null);
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }
}
