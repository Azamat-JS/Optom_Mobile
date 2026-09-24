/// Mirrors `CreateRestaurantTableDto` — `storeId` is deliberately absent:
/// the backend derives it from the caller's active store
/// (`TenantFilter.requireStore`, the same `X-Store-Id` mechanism the app's
/// main Dio interceptor already attaches for owner roles), not from the
/// request body.
class CreateRestaurantTableParams {
  const CreateRestaurantTableParams({required this.name, required this.percent});

  final String name;
  final double percent;

  Map<String, dynamic> toRequestBody() => {'name': name, 'percent': percent};
}

/// Mirrors `UpdateRestaurantTableDto`.
class UpdateRestaurantTableParams {
  const UpdateRestaurantTableParams({this.name, this.percent});

  final String? name;
  final double? percent;

  Map<String, dynamic> toRequestBody() => {
        if (name != null) 'name': name,
        if (percent != null) 'percent': percent,
      };
}
