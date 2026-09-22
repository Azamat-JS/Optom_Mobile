import 'package:bsmart/core/enums/master_product_status.dart';
import 'package:bsmart/core/enums/product_unit.dart';

class MasterProductImageRef {
  const MasterProductImageRef({required this.id, required this.url, required this.isPrimary});

  final String id;
  final String url;
  final bool isPrimary;
}

/// A SUPER_ADMIN-curated shared catalog entry. SELLER/RETAILER only ever
/// browse `APPROVED` entries here (the backend's `TenantFilter
/// .masterProduct` forces `isActive: true` for non-SUPER_ADMIN roles) — used
/// for the "Add from Catalog" product-creation flow. Moderation
/// (approve/reject/create/delete) is a Phase 3, SUPER_ADMIN-only concern.
class MasterProduct {
  const MasterProduct({
    required this.id,
    required this.name,
    this.description,
    this.brand,
    this.barcode,
    this.unit,
    required this.status,
    this.categoryId,
    this.categoryName,
    this.images = const [],
  });

  final String id;
  final String name;
  final String? description;
  final String? brand;
  final String? barcode;
  final ProductUnit? unit;
  final MasterProductStatus status;
  final String? categoryId;
  final String? categoryName;
  final List<MasterProductImageRef> images;

  String? get primaryImageUrl {
    for (final image in images) {
      if (image.isPrimary) return image.url;
    }
    return images.isEmpty ? null : images.first.url;
  }
}
