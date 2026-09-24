import 'package:bsmart/core/enums/business_type.dart';
import 'package:bsmart/core/enums/user_role.dart';

/// Mirrors `CreateUserDto`.
class CreatePlatformUserParams {
  const CreatePlatformUserParams({
    required this.firstName,
    required this.lastName,
    this.shopName,
    required this.phone,
    required this.password,
    required this.role,
    this.businessType,
  });

  final String firstName;
  final String lastName;
  final String? shopName;
  final String phone;
  final String password;
  final UserRole role;
  final BusinessType? businessType;

  Map<String, dynamic> toRequestBody() => {
        'firstName': firstName,
        'lastName': lastName,
        if (shopName != null) 'shopName': shopName,
        'phone': phone,
        'password': password,
        'role': role.toWire(),
        if (businessType != null) 'businessType': businessType!.toWire(),
      };
}

/// Mirrors `UpdateUserDto` — `password` deliberately absent (the backend DTO
/// omits it entirely; there is no admin-resets-a-user's-password flow).
class UpdatePlatformUserParams {
  const UpdatePlatformUserParams({
    this.firstName,
    this.lastName,
    this.shopName,
    this.phone,
    this.businessType,
    this.canAccessPos,
    this.courierFeatureEnabled,
    this.courierLimit,
    this.waiterLimit,
  });

  final String? firstName;
  final String? lastName;
  final String? shopName;
  final String? phone;
  final BusinessType? businessType;
  final bool? canAccessPos;
  final bool? courierFeatureEnabled;
  final int? courierLimit;
  final int? waiterLimit;

  Map<String, dynamic> toRequestBody() => {
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (shopName != null) 'shopName': shopName,
        if (phone != null) 'phone': phone,
        if (businessType != null) 'businessType': businessType!.toWire(),
        if (canAccessPos != null) 'canAccessPos': canAccessPos,
        if (courierFeatureEnabled != null) 'courierFeatureEnabled': courierFeatureEnabled,
        if (courierLimit != null) 'courierLimit': courierLimit,
        if (waiterLimit != null) 'waiterLimit': waiterLimit,
      };
}
