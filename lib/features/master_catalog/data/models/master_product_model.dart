import 'package:bsmart/core/enums/master_product_status.dart';
import 'package:bsmart/core/enums/product_unit.dart';
import 'package:bsmart/features/master_catalog/domain/entities/master_product.dart';

MasterProduct masterProductFromJson(Map<String, dynamic> json) {
  final category = json['category'] as Map<String, dynamic>?;
  final imagesJson = json['images'] as List<dynamic>? ?? const [];

  return MasterProduct(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String?,
    brand: json['brand'] as String?,
    barcode: json['barcode'] as String?,
    unit: json['unit'] != null ? ProductUnit.fromWire(json['unit'] as String) : null,
    status: MasterProductStatus.fromWire(json['status'] as String? ?? 'APPROVED'),
    isActive: json['isActive'] as bool? ?? true,
    categoryId: category?['id'] as String?,
    categoryName: category?['name'] as String?,
    images: imagesJson
        .map(
          (e) => MasterProductImageRef(
            id: e['id'] as String,
            url: e['url'] as String,
            isPrimary: e['isPrimary'] as bool? ?? false,
          ),
        )
        .toList(),
  );
}
