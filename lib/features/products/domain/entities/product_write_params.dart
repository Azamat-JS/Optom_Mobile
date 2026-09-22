import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/product_unit.dart';

/// Mirrors `CreateProductDto`. Images are deliberately not included here —
/// they're uploaded as separate multipart requests via `ProductsRepository
/// .uploadImage` after the product exists (native file picks have no URL
/// until uploaded; the JSON `images: [{url}]` field on the DTO is for a
/// masterProduct-style pre-hosted-URL flow this app doesn't use).
class CreateProductParams {
  const CreateProductParams({
    this.name,
    this.masterProductId,
    this.description,
    required this.price,
    this.costPrice,
    this.currency = Currency.uzs,
    this.stock = 0,
    this.unit,
    this.sku,
    this.barcode,
    this.plu,
    this.categoryId,
    this.isActive = true,
    this.expiryDate,
  });

  final String? name;
  final String? masterProductId;
  final String? description;
  final double price;
  final double? costPrice;
  final Currency currency;
  final double stock;
  final ProductUnit? unit;
  final String? sku;
  final String? barcode;
  final String? plu;
  final String? categoryId;
  final bool isActive;
  final DateTime? expiryDate;

  Map<String, dynamic> toRequestBody() {
    final body = <String, dynamic>{
      'price': price,
      'currency': currency.toWire(),
      'stock': stock,
      'isActive': isActive,
    };
    if (masterProductId != null) {
      body['masterProductId'] = masterProductId;
    } else {
      body['name'] = name;
    }
    if (description != null) body['description'] = description;
    if (costPrice != null) body['costPrice'] = costPrice;
    if (unit != null) body['unit'] = unit!.toWire();
    if (sku != null) body['sku'] = sku;
    if (barcode != null) body['barcode'] = barcode;
    if (plu != null) body['plu'] = plu;
    if (categoryId != null) body['categoryId'] = categoryId;
    if (expiryDate != null) body['expiryDate'] = expiryDate!.toIso8601String();
    return body;
  }
}

/// Mirrors `UpdateProductDto` = `PartialType(OmitType(CreateProductDto,
/// ['masterProductId','currency']))` — currency and the catalog link can
/// never change after creation, so they're not fields here at all.
class UpdateProductParams {
  const UpdateProductParams({
    this.name,
    this.description,
    this.price,
    this.costPrice,
    this.stock,
    this.unit,
    this.sku,
    this.barcode,
    this.plu,
    this.categoryId,
    this.isActive,
    this.expiryDate,
    this.clearExpiryDate = false,
  });

  final String? name;
  final String? description;
  final double? price;
  final double? costPrice;
  final double? stock;
  final ProductUnit? unit;
  final String? sku;
  final String? barcode;
  final String? plu;
  final String? categoryId;
  final bool? isActive;
  final DateTime? expiryDate;

  /// `expiryDate: null` is only sent when this is true — omitting the field
  /// entirely means "leave unchanged" (this codebase's established
  /// null-vs-omitted convention, confirmed against the reference backend).
  final bool clearExpiryDate;

  Map<String, dynamic> toRequestBody() => {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (price != null) 'price': price,
        if (costPrice != null) 'costPrice': costPrice,
        if (stock != null) 'stock': stock,
        if (unit != null) 'unit': unit!.toWire(),
        if (sku != null) 'sku': sku,
        if (barcode != null) 'barcode': barcode,
        if (plu != null) 'plu': plu,
        if (categoryId != null) 'categoryId': categoryId,
        if (isActive != null) 'isActive': isActive,
        if (clearExpiryDate)
          'expiryDate': null
        else if (expiryDate != null)
          'expiryDate': expiryDate!.toIso8601String(),
      };
}

/// Mirrors `ReceiveStockDto` — backs the quick stock-adjust sheet (separate
/// from the full edit form, per the implementation plan).
class ReceiveStockParams {
  const ReceiveStockParams({
    required this.quantity,
    this.price,
    this.costPrice,
    this.paidAmount,
    this.fullyPaid,
    this.stockCorrection,
  });

  /// Positive amount added to stock (e.g. a new delivery received).
  final double quantity;
  final double? price;
  final double? costPrice;
  final double? paidAmount;
  final bool? fullyPaid;

  /// A separate manual adjustment (can be negative) added on top of
  /// [quantity] — not factored into cost/debt math.
  final double? stockCorrection;

  Map<String, dynamic> toRequestBody() => {
        'quantity': quantity,
        if (price != null) 'price': price,
        if (costPrice != null) 'costPrice': costPrice,
        if (paidAmount != null) 'paidAmount': paidAmount,
        if (fullyPaid != null) 'fullyPaid': fullyPaid,
        if (stockCorrection != null) 'stockCorrection': stockCorrection,
      };
}
