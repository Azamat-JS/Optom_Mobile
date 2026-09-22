import 'package:dio/dio.dart';

import 'package:bsmart/core/network/dio_error_mapper.dart';
import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/products/data/datasources/products_remote_data_source.dart';
import 'package:bsmart/features/products/domain/entities/product.dart';
import 'package:bsmart/features/products/domain/entities/product_image.dart';
import 'package:bsmart/features/products/domain/entities/product_query.dart';
import 'package:bsmart/features/products/domain/entities/product_write_params.dart';
import 'package:bsmart/features/products/domain/repositories/products_repository.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  ProductsRepositoryImpl(this._remote);

  final ProductsRemoteDataSource _remote;

  @override
  Future<Result<PaginatedResult<Product>>> list(ProductQuery query) async {
    try {
      return Result.ok(await _remote.list(query));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<Product>> getById(String id) async {
    try {
      return Result.ok(await _remote.getById(id));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<Product>> create(CreateProductParams params) async {
    try {
      return Result.ok(await _remote.create(params));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<Product>> update(String id, UpdateProductParams params) async {
    try {
      return Result.ok(await _remote.update(id, params));
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
  Future<Result<Product>> receiveStock(String id, ReceiveStockParams params) async {
    try {
      return Result.ok(await _remote.receiveStock(id, params));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<Product>> assignBarcode(String id) async {
    try {
      return Result.ok(await _remote.assignBarcode(id));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<void>> shareToCatalog(String id) async {
    try {
      await _remote.shareToCatalog(id);
      return const Result.ok(null);
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<String>> nextPlu() async {
    try {
      return Result.ok(await _remote.nextPlu());
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<List<Product>>> bestSelling({int limit = 18}) async {
    try {
      return Result.ok(await _remote.bestSelling(limit: limit));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<ProductImage>> uploadImage(
    String productId, {
    required String filePath,
    bool isPrimary = false,
  }) async {
    try {
      return Result.ok(await _remote.uploadImage(productId, filePath: filePath, isPrimary: isPrimary));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<void>> deleteImage(String productId, String imageId) async {
    try {
      await _remote.deleteImage(productId, imageId);
      return const Result.ok(null);
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }
}
