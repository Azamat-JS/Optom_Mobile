/// Mirrors `CreateRestaurantStaffDto`.
class CreateWaiterParams {
  const CreateWaiterParams({
    required this.storeId,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.password,
    this.commissionPercent,
  });

  final String storeId;
  final String firstName;
  final String lastName;
  final String phone;
  final String password;
  final double? commissionPercent;

  Map<String, dynamic> toRequestBody() => {
        'storeId': storeId,
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'password': password,
        if (commissionPercent != null) 'commissionPercent': commissionPercent,
      };
}

/// Mirrors `UpdateRestaurantStaffDto`.
class UpdateWaiterParams {
  const UpdateWaiterParams({this.storeId, this.firstName, this.lastName, this.phone, this.commissionPercent});

  final String? storeId;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final double? commissionPercent;

  Map<String, dynamic> toRequestBody() => {
        if (storeId != null) 'storeId': storeId,
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (phone != null) 'phone': phone,
        if (commissionPercent != null) 'commissionPercent': commissionPercent,
      };
}
