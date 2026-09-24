import 'package:bsmart/core/enums/business_type.dart';
import 'package:bsmart/core/enums/user_role.dart';

/// Mirrors `UserQueryDto`. A single generic list screen drives every
/// SUPER_ADMIN "management" view via [role]/[businessType] rather than one
/// screen per role/vertical — e.g. `role: retailer, businessType: pharmacy`
/// is the "Dorixonalar" list, `role: seller` is "Optomchilar", with no
/// separate screen built for either (per the plan: "one generic
/// BusinessType-filtered retailer-list screen, not 7 separate ones").
class PlatformUserQuery {
  const PlatformUserQuery({this.page = 1, this.limit = 20, this.search, this.role, this.businessType});

  final int page;
  final int limit;
  final String? search;
  final UserRole? role;
  final BusinessType? businessType;

  PlatformUserQuery copyWith({
    int? page,
    String? search,
    UserRole? role,
    bool clearRole = false,
    BusinessType? businessType,
    bool clearBusinessType = false,
  }) {
    return PlatformUserQuery(
      page: page ?? this.page,
      limit: limit,
      search: search ?? this.search,
      role: clearRole ? null : (role ?? this.role),
      businessType: clearBusinessType ? null : (businessType ?? this.businessType),
    );
  }

  Map<String, dynamic> toQueryParameters() => {
        'page': page,
        'limit': limit,
        if (search != null && search!.isNotEmpty) 'search': search,
        if (role != null) 'role': role!.toWire(),
        if (businessType != null) 'businessType': businessType!.toWire(),
      };
}
