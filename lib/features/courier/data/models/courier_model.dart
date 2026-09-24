import 'package:bsmart/features/courier/domain/entities/courier.dart';

Courier courierFromJson(Map<String, dynamic> json) => Courier(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phone: json['phone'] as String,
      isActive: json['isActive'] as bool? ?? true,
      storeId: json['storeId'] as String,
      todayOrderCount: (json['todayOrderCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
