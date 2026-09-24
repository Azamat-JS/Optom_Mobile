import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/categories/domain/entities/category.dart';
import 'package:bsmart/features/categories/domain/repositories/categories_repository.dart';

class UploadCategoryImageUseCase {
  UploadCategoryImageUseCase(this._repository);

  final CategoriesRepository _repository;

  Future<Result<Category>> call(String id, {required String filePath}) =>
      _repository.uploadImage(id, filePath: filePath);
}
