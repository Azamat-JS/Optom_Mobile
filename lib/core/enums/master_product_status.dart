/// Mirrors the backend's Prisma `MasterProductStatus` enum. A SELLER/RETAILER
/// browsing the catalog only ever sees `approved` entries (the backend's
/// `TenantFilter.masterProduct` forces `isActive: true` for non-SUPER_ADMIN
/// roles) — `pending`/`rejected` only matter once the Phase 3 SUPER_ADMIN
/// moderation queue is built.
enum MasterProductStatus {
  pending,
  approved,
  rejected;

  static MasterProductStatus fromWire(String value) => switch (value) {
        'PENDING' => MasterProductStatus.pending,
        'APPROVED' => MasterProductStatus.approved,
        'REJECTED' => MasterProductStatus.rejected,
        _ => throw ArgumentError('Unknown MasterProductStatus from backend: $value'),
      };

  String toWire() => switch (this) {
        MasterProductStatus.pending => 'PENDING',
        MasterProductStatus.approved => 'APPROVED',
        MasterProductStatus.rejected => 'REJECTED',
      };
}
