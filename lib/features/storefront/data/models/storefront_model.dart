import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/product_unit.dart';
import 'package:bsmart/core/utils/decimal_parser.dart';
import 'package:bsmart/features/storefront/domain/entities/storefront_product.dart';

StorefrontCategory storefrontCategoryFromJson(Map<String, dynamic> json) => StorefrontCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String?,
      icon: json['icon'] as String?,
      parentId: json['parentId'] as String?,
    );

/// Parses one row of `GET /public/catalog/products`'s `data[]` (and the
/// single-product `GET /public/catalog/products/:id` response) — same
/// `costPrice`-stripped, `seller`/`store`-embedded shape as the authenticated
/// `/catalog` endpoint (see `StorefrontProduct`'s doc comment).
StorefrontProduct storefrontProductFromJson(Map<String, dynamic> json) {
  final category = json['category'] as Map<String, dynamic>?;
  final store = json['store'] as Map<String, dynamic>?;
  final seller = json['seller'] as Map<String, dynamic>;
  final imagesJson = json['images'] as List<dynamic>? ?? const [];

  final images = <String>[];
  String? primaryImageUrl;
  for (final image in imagesJson) {
    final map = image as Map<String, dynamic>;
    final url = map['url'] as String?;
    if (url == null) continue;
    images.add(url);
    if (map['isPrimary'] as bool? ?? false) primaryImageUrl ??= url;
  }
  primaryImageUrl ??= images.isNotEmpty ? images.first : null;

  return StorefrontProduct(
    id: json['id'] as String,
    name: json['name'] as String? ?? '',
    description: json['description'] as String?,
    price: parseDecimal(json['price']),
    currency: Currency.fromWire(json['currency'] as String? ?? 'UZS'),
    stock: parseDecimal(json['stock'] ?? 0),
    unit: json['unit'] != null ? ProductUnit.fromWire(json['unit'] as String) : null,
    categoryId: category?['id'] as String?,
    categoryName: category?['name'] as String?,
    sellerId: seller['id'] as String,
    sellerName: '${seller['firstName']} ${seller['lastName']}'.trim(),
    sellerPhone: seller['phone'] as String,
    storeId: store?['id'] as String?,
    storeName: store?['name'] as String?,
    imageUrl: primaryImageUrl,
    images: images,
  );
}
