import 'package:bsmart/features/staff_admins/domain/entities/admin.dart';

Admin adminFromJson(Map<String, dynamic> json) => Admin(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phone: json['phone'] as String,
      isActive: json['isActive'] as bool? ?? true,
      storeId: json['storeId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
