/// Mirrors the backend's Prisma `BusinessType` enum. Only meaningful for
/// [UserRole.retailer]/[UserRole.retailerAdmin] — all 8 verticals share
/// identical RETAILER logic server-side and differ only in nav/copy.
enum BusinessType {
  general,
  restaurant,
  applianceStore,
  constructionTools,
  toyStore,
  autoParts,
  pharmacy,
  clothingStore;

  static BusinessType fromWire(String value) => switch (value) {
        'GENERAL' => BusinessType.general,
        'RESTAURANT' => BusinessType.restaurant,
        'APPLIANCE_STORE' => BusinessType.applianceStore,
        'CONSTRUCTION_TOOLS' => BusinessType.constructionTools,
        'TOY_STORE' => BusinessType.toyStore,
        'AUTO_PARTS' => BusinessType.autoParts,
        'PHARMACY' => BusinessType.pharmacy,
        'CLOTHING_STORE' => BusinessType.clothingStore,
        _ => throw ArgumentError('Unknown BusinessType from backend: $value'),
      };

  String toWire() => switch (this) {
        BusinessType.general => 'GENERAL',
        BusinessType.restaurant => 'RESTAURANT',
        BusinessType.applianceStore => 'APPLIANCE_STORE',
        BusinessType.constructionTools => 'CONSTRUCTION_TOOLS',
        BusinessType.toyStore => 'TOY_STORE',
        BusinessType.autoParts => 'AUTO_PARTS',
        BusinessType.pharmacy => 'PHARMACY',
        BusinessType.clothingStore => 'CLOTHING_STORE',
      };

  /// Uzbek display label, matching the reference web app's copy.
  String get label => switch (this) {
        BusinessType.general => "Do'kon",
        BusinessType.restaurant => 'Restoran',
        BusinessType.applianceStore => 'Maishiy texnika',
        BusinessType.constructionTools => 'Qurilish mollari',
        BusinessType.toyStore => "O'yinchoqlar",
        BusinessType.autoParts => 'Avto ehtiyot qismlar',
        BusinessType.pharmacy => 'Dorixona',
        BusinessType.clothingStore => 'Kiyim-kechak',
      };
}
