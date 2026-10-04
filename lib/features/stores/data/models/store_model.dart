import 'package:bsmart/core/entities/geo_point.dart';
import 'package:bsmart/core/utils/decimal_parser.dart';
import 'package:bsmart/features/stores/domain/entities/store.dart';

Store storeFromJson(Map<String, dynamic> json) => Store(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String?,
      // Prisma Decimal → JSON string.
      location: json['latitude'] != null && json['longitude'] != null
          ? GeoPoint(parseDecimal(json['latitude']), parseDecimal(json['longitude']))
          : null,
      isActive: json['isActive'] as bool? ?? true,
      isDefault: json['isDefault'] as bool? ?? false,
      requireHandoverCode: json['requireHandoverCode'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
