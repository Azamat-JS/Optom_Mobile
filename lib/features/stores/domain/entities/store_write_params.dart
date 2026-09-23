/// Mirrors `CreateStoreDto`.
class CreateStoreParams {
  const CreateStoreParams({required this.name, this.address});

  final String name;
  final String? address;

  Map<String, dynamic> toRequestBody() => {
        'name': name,
        if (address != null && address!.isNotEmpty) 'address': address,
      };
}

/// Mirrors `UpdateStoreDto`. The backend distinguishes an explicit `null`
/// address (clears it) from an omitted field (leaves it unchanged), but the
/// edit form always resubmits every field it shows — same simplified
/// convention already used by `UpdateCustomerParams` elsewhere in this app —
/// so an empty string here is sent as `null` to actually clear it.
class UpdateStoreParams {
  const UpdateStoreParams({this.name, this.address});

  final String? name;
  final String? address;

  Map<String, dynamic> toRequestBody() => {
        if (name != null) 'name': name,
        'address': (address == null || address!.isEmpty) ? null : address,
      };
}
