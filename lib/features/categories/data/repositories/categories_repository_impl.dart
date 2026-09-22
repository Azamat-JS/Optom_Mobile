import 'package:dio/dio.dart';

import 'package:bsmart/core/network/dio_error_mapper.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/categories/data/datasources/categories_remote_data_source.dart';
import 'package:bsmart/features/categories/domain/entities/category.dart';
import 'package:bsmart/features/categories/domain/repositories/categories_repository.dart';

class CategoriesRepositoryImpl implements CategoriesRepository {
  CategoriesRepositoryImpl(this._remote);

  final CategoriesRemoteDataSource _remote;

  @override
  Future<Result<List<Category>>> getRootCategoriesWithChildren({String? search}) async {
    try {
      final result = await _remote.getRootCategories(search: search, isActive: true);
      return Result.ok(result.data);
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }
}
