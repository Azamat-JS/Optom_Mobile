import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/products/domain/entities/product.dart';
import 'package:bsmart/features/products/domain/entities/product_image.dart';
import 'package:bsmart/features/products/domain/entities/product_query.dart';
import 'package:bsmart/features/products/domain/entities/product_write_params.dart';

abstract class ProductsRepository {
  Future<Result<PaginatedResult<Product>>> list(ProductQuery query);

  Future<Result<Product>> getById(String id);

  Future<Result<Product>> create(CreateProductParams params);

  Future<Result<Product>> update(String id, UpdateProductParams params);

  Future<Result<void>> delete(String id);

  /// Backs the quick stock-adjust sheet (separate from the full edit form).
  Future<Result<Product>> receiveStock(String id, ReceiveStockParams params);

  /// Generates a random, store-unique barcode server-side — the client never
  /// supplies the barcode value here (see the doc note on
  /// `ProductsRemoteDataSource.assignBarcode`).
  Future<Result<Product>> assignBarcode(String id);

  /// Submits this product to the SUPER_ADMIN-moderated shared catalog
  /// (`MasterProduct`, status `PENDING`).
  Future<Result<void>> shareToCatalog(String id);

  Future<Result<String>> nextPlu();

  Future<Result<List<Product>>> bestSelling({int limit});

  Future<Result<ProductImage>> uploadImage(
    String productId, {
    required String filePath,
    bool isPrimary,
  });

  Future<Result<void>> deleteImage(String productId, String imageId);
}
