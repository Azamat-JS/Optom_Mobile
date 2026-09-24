import 'package:bsmart/core/enums/product_unit.dart';

/// Mirrors `CreateMasterProductDto` — `images` is deliberately omitted here
/// (a separate multipart upload endpoint handles each image, same pattern
/// as `features/products`' own image upload, not an inline array of URLs).
class CreateMasterProductParams {
  const CreateMasterProductParams({
    required this.name,
    this.description,
    this.brand,
    this.barcode,
    this.categoryId,
    this.unit,
    this.isActive,
  });

  final String name;
  final String? description;
  final String? brand;
  final String? barcode;
  final String? categoryId;
  final ProductUnit? unit;
  final bool? isActive;

  Map<String, dynamic> toRequestBody() => {
        'name': name,
        if (description != null) 'description': description,
        if (brand != null) 'brand': brand,
        if (barcode != null) 'barcode': barcode,
        if (categoryId != null) 'categoryId': categoryId,
        if (unit != null) 'unit': unit!.toWire(),
        if (isActive != null) 'isActive': isActive,
      };
}

/// Mirrors `UpdateMasterProductDto`.
class UpdateMasterProductParams {
  const UpdateMasterProductParams({
    this.name,
    this.description,
    this.brand,
    this.barcode,
    this.categoryId,
    this.unit,
    this.isActive,
  });

  final String? name;
  final String? description;
  final String? brand;
  final String? barcode;
  final String? categoryId;
  final ProductUnit? unit;
  final bool? isActive;

  Map<String, dynamic> toRequestBody() => {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (brand != null) 'brand': brand,
        if (barcode != null) 'barcode': barcode,
        if (categoryId != null) 'categoryId': categoryId,
        if (unit != null) 'unit': unit!.toWire(),
        if (isActive != null) 'isActive': isActive,
      };
}
