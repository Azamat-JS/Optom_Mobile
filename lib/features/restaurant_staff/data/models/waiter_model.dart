import 'package:bsmart/core/utils/decimal_parser.dart';
import 'package:bsmart/features/restaurant_staff/domain/entities/waiter.dart';

Waiter waiterFromJson(Map<String, dynamic> json) => Waiter(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phone: json['phone'] as String,
      isActive: json['isActive'] as bool? ?? true,
      storeId: json['storeId'] as String,
      commissionPercent: parseNullableDecimal(json['waiterCommissionPercent']),
      todayOrderCount: (json['todayOrderCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
