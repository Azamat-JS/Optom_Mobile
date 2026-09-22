import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/product_unit.dart';
import 'package:bsmart/core/utils/decimal_parser.dart';
import 'package:bsmart/features/catalog/domain/entities/catalog_product.dart';
import 'package:bsmart/features/catalog/domain/entities/catalog_seller.dart';

CatalogSeller catalogSellerFromJson(Map<String, dynamic> json) => CatalogSeller(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phone: json['phone'] as String,
      avatarUrl: json['avatarUrl'] as String?,
    );

CatalogStore catalogStoreFromJson(Map<String, dynamic> json) => CatalogStore(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String?,
    );

/// Parses one row of `GET /catalog`'s `data[]` — `costPrice` is never
/// present (stripped server-side), `seller`/`store` are always embedded.
CatalogProduct catalogProductFromJson(Map<String, dynamic> json) {
  final category = json['category'] as Map<String, dynamic>?;
  final store = json['store'] as Map<String, dynamic>?;
  final images = json['images'] as List<dynamic>? ?? const [];
  String? primaryImageUrl;
  for (final image in images) {
    final map = image as Map<String, dynamic>;
    if (map['isPrimary'] as bool? ?? false) {
      primaryImageUrl = map['url'] as String?;
      break;
    }
  }
  primaryImageUrl ??= images.isNotEmpty ? (images.first as Map<String, dynamic>)['url'] as String? : null;

  return CatalogProduct(
    id: json['id'] as String,
    name: json['name'] as String? ?? '',
    description: json['description'] as String?,
    price: parseDecimal(json['price']),
    currency: Currency.fromWire(json['currency'] as String? ?? 'UZS'),
    stock: parseDecimal(json['stock'] ?? 0),
    unit: json['unit'] != null ? ProductUnit.fromWire(json['unit'] as String) : null,
    categoryId: category?['id'] as String?,
    categoryName: category?['name'] as String?,
    seller: catalogSellerFromJson(json['seller'] as Map<String, dynamic>),
    storeId: store?['id'] as String?,
    storeName: store?['name'] as String?,
    imageUrl: primaryImageUrl,
  );
}
