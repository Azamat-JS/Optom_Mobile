/// Mirrors `CreateCourierDto`.
class CreateCourierParams {
  const CreateCourierParams({
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

/// Mirrors `UpdateCourierDto`.
class UpdateCourierParams {
  const UpdateCourierParams({this.storeId, this.firstName, this.lastName, this.phone});

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
