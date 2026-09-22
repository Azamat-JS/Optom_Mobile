import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/product_unit.dart';
import 'package:bsmart/core/utils/decimal_parser.dart';
import 'package:bsmart/features/products/domain/entities/product.dart';
import 'package:bsmart/features/products/domain/entities/product_image.dart';

ProductImage productImageFromJson(Map<String, dynamic> json) => ProductImage(
      id: json['id'] as String,
      url: json['url'] as String,
      altText: json['altText'] as String?,
      sortOrder: json['sortOrder'] as int? ?? 0,
      isPrimary: json['isPrimary'] as bool? ?? false,
    );

/// Parses a Product row as returned by the `product` module — see the
/// verified backend contract: `price`/`costPrice`/`stock` are `Decimal`
/// fields serialized as JSON strings, `name`/`description`/`images`/`brand`
/// are already resolved server-side for catalog-linked rows.
Product productFromJson(Map<String, dynamic> json) {
  final category = json['category'] as Map<String, dynamic>?;
  final parent = category?['parent'] as Map<String, dynamic>?;
  final imagesJson = json['images'] as List<dynamic>? ?? const [];

  return Product(
    id: json['id'] as String,
    name: json['name'] as String? ?? '',
    description: json['description'] as String?,
    price: parseDecimal(json['price']),
    costPrice: parseNullableDecimal(json['costPrice']),
    currency: Currency.fromWire(json['currency'] as String? ?? 'UZS'),
    stock: parseDecimal(json['stock'] ?? 0),
    unit: json['unit'] != null ? ProductUnit.fromWire(json['unit'] as String) : null,
    sku: json['sku'] as String?,
    barcode: json['barcode'] as String?,
    plu: json['plu'] as String?,
    isActive: json['isActive'] as bool? ?? true,
    expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate'] as String) : null,
    categoryId: json['categoryId'] as String?,
    masterProductId: json['masterProductId'] as String?,
    brand: json['brand'] as String?,
    category: category == null
        ? null
        : ProductCategoryRef(
            id: category['id'] as String,
            name: category['name'] as String,
            parentName: parent?['name'] as String?,
          ),
    images: imagesJson.map((e) => productImageFromJson(e as Map<String, dynamic>)).toList(),
  );
}
