import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/utils/decimal_parser.dart';
import 'package:bsmart/features/favorites/domain/entities/favorite_product.dart';

FavoriteProduct favoriteProductFromJson(Map<String, dynamic> json) {
  final category = json['category'] as Map<String, dynamic>?;
  final images = json['images'] as List<dynamic>? ?? const [];
  String? imageUrl;
  for (final image in images) {
    final map = image as Map<String, dynamic>;
    if (map['isPrimary'] as bool? ?? false) {
      imageUrl = map['url'] as String?;
      break;
    }
  }
  imageUrl ??= images.isNotEmpty ? (images.first as Map<String, dynamic>)['url'] as String? : null;

  return FavoriteProduct(
    id: json['id'] as String,
    name: json['name'] as String? ?? '',
    price: parseDecimal(json['price']),
    currency: Currency.fromWire(json['currency'] as String? ?? 'UZS'),
    categoryName: category?['name'] as String?,
    imageUrl: imageUrl,
  );
}
