import 'package:bsmart/core/entities/geo_point.dart';

/// Mirrors `CreateStoreDto`.
class CreateStoreParams {
  const CreateStoreParams({required this.name, this.address, this.location});

  final String name;
  final String? address;
  final GeoPoint? location;

  Map<String, dynamic> toRequestBody() => {
        'name': name,
        if (address != null && address!.isNotEmpty) 'address': address,
        if (location != null) 'latitude': location!.lat,
        if (location != null) 'longitude': location!.lng,
      };
}

/// Mirrors `UpdateStoreDto`. The backend distinguishes an explicit `null`
/// address (clears it) from an omitted field (leaves it unchanged), but the
/// edit form always resubmits every field it shows — same simplified
/// convention already used by `UpdateCustomerParams` elsewhere in this app —
/// so an empty string here is sent as `null` to actually clear it.
class UpdateStoreParams {
  const UpdateStoreParams({this.name, this.address, this.location});

  final String? name;
  final String? address;

  /// Resubmitted like [address]: null clears the pickup pin.
  final GeoPoint? location;

  Map<String, dynamic> toRequestBody() => {
        if (name != null) 'name': name,
        'address': (address == null || address!.isEmpty) ? null : address,
        'latitude': location?.lat,
        'longitude': location?.lng,
      };
}
