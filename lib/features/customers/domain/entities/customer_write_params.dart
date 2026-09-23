/// Mirrors `CreateCustomerDto` field-for-field.
class CreateCustomerParams {
  const CreateCustomerParams({
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.address,
    this.notes,
    this.isActive,
  });

  final String firstName;
  final String lastName;
  final String phone;
  final String? address;
  final String? notes;
  final bool? isActive;

  Map<String, dynamic> toRequestBody() => {
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        if (address != null && address!.isNotEmpty) 'address': address,
        if (notes != null && notes!.isNotEmpty) 'notes': notes,
        if (isActive != null) 'isActive': isActive,
      };
}

/// Mirrors `UpdateCustomerDto` (a `PartialType` of the create DTO) — every
/// field optional, only non-null ones are sent.
class UpdateCustomerParams {
  const UpdateCustomerParams({this.firstName, this.lastName, this.phone, this.address, this.notes});

  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? address;
  final String? notes;

  Map<String, dynamic> toRequestBody() => {
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (phone != null) 'phone': phone,
        if (address != null) 'address': address,
        if (notes != null) 'notes': notes,
      };
}
