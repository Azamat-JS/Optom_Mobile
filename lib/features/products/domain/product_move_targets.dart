import 'package:bsmart/core/enums/business_type.dart';
import 'package:bsmart/core/enums/user_role.dart';
import 'package:bsmart/features/stores/domain/entities/store.dart';

/// Where the selected products would leave from, and the stores they may go
/// to ("Boshqa do'konga yuborish", Optom_Savdo CLAUDE.md "Moving Products
/// Between Stores").
typedef ProductMoveTargets = ({Store? source, List<Store> targets});

const ProductMoveTargets noProductMoveTargets = (source: null, targets: <Store>[]);

/// Only the business owner (SELLER/RETAILER, not their admins or other staff;
/// the server refuses them too), and not a restaurant (it doesn't need it, user
/// decision 2026-11-04). The source is the active store, falling back the way
/// the server does when none is saved: the default store, else the first one.
/// Targets are the owner's other *active* stores — empty means the action
/// doesn't show (e.g. a single-store owner).
ProductMoveTargets productMoveTargets({
  required UserRole role,
  required bool isStaff,
  required BusinessType? businessType,
  required List<Store> stores,
  required String? activeStoreId,
}) {
  final isOwner = !isStaff && (role == UserRole.seller || role == UserRole.retailer);
  if (!isOwner || businessType == BusinessType.restaurant || stores.isEmpty) return noProductMoveTargets;

  final source =
      stores.where((s) => s.id == activeStoreId).firstOrNull ??
      stores.where((s) => s.isDefault).firstOrNull ??
      stores.first;
  return (source: source, targets: stores.where((s) => s.id != source.id && s.isActive).toList());
}
