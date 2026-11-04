import 'package:bsmart/core/enums/business_type.dart';
import 'package:bsmart/core/enums/user_role.dart';

/// A store in the "Boshqa do'konga yuborish" picker (Optom_Savdo CLAUDE.md
/// "Moving Products Between Stores"). Comes from
/// `GET /products/move-to-store/targets`, which admins may call — unlike
/// `GET /stores`, which is owner-only.
class ProductMoveStore {
  const ProductMoveStore({required this.id, required this.name, this.address, this.isDefault = false});

  final String id;
  final String name;
  final String? address;
  final bool isDefault;

  factory ProductMoveStore.fromJson(Map<String, dynamic> json) => ProductMoveStore(
    id: json['id'] as String,
    name: json['name'] as String,
    address: json['address'] as String?,
    isDefault: json['isDefault'] as bool? ?? false,
  );
}

/// Where the selected products leave from (the active store; an admin's own
/// store) and the owner's other active stores they may go to. No targets →
/// the action doesn't show.
typedef ProductMoveTargets = ({ProductMoveStore? source, List<ProductMoveStore> targets});

const ProductMoveTargets noProductMoveTargets = (source: null, targets: <ProductMoveStore>[]);

ProductMoveTargets productMoveTargetsFromJson(Map<String, dynamic> json) {
  final source = json['source'];
  return (
    source: source is Map<String, dynamic> ? ProductMoveStore.fromJson(source) : null,
    targets: [for (final t in json['targets'] as List<dynamic>? ?? const []) ProductMoveStore.fromJson(t as Map<String, dynamic>)],
  );
}

/// Business owners and their admins (user decision 2026-11-04; an admin sends
/// from the store it is locked to), never waiters/couriers/agents (the server
/// refuses them too), and not restaurants (they don't need it, user decision
/// 2026-11-04 — an admin inherits its owner's business type).
bool canMoveProducts({required UserRole role, required BusinessType? businessType}) {
  const roles = {UserRole.seller, UserRole.sellerAdmin, UserRole.retailer, UserRole.retailerAdmin};
  return roles.contains(role) && businessType != BusinessType.restaurant;
}
