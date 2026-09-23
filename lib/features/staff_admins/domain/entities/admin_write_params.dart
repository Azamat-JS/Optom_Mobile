/// Mirrors `CreateAdminDto` — `storeId` locks this admin to one of the
/// owner's stores at creation, immutable from the admin's own side
/// afterward (only the owner can reassign it via [UpdateAdminParams]).
class CreateAdminParams {
  const CreateAdminParams({
    required this.storeId,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.password,
  });

  final String storeId;
  final String firstName;
  final String lastName;
  final String phone;
  final String password;

  Map<String, dynamic> toRequestBody() => {
        'storeId': storeId,
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'password': password,
      };
}

/// Mirrors `UpdateAdminDto`.
class UpdateAdminParams {
  const UpdateAdminParams({this.storeId, this.firstName, this.lastName, this.phone});

  final String? storeId;
  final String? firstName;
  final String? lastName;
  final String? phone;

  Map<String, dynamic> toRequestBody() => {
        if (storeId != null) 'storeId': storeId,
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (phone != null) 'phone': phone,
      };
}
