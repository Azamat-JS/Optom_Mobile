/// Mirrors the backend's Prisma `ExpenditureType` enum.
enum ExpenditureType {
  electricity,
  gas,
  water,
  taxes,
  renting,
  other;

  static ExpenditureType fromWire(String value) => switch (value) {
        'ELECTRICITY' => ExpenditureType.electricity,
        'GAS' => ExpenditureType.gas,
        'WATER' => ExpenditureType.water,
        'TAXES' => ExpenditureType.taxes,
        'RENTING' => ExpenditureType.renting,
        'OTHER' => ExpenditureType.other,
        _ => throw ArgumentError('Unknown ExpenditureType from backend: $value'),
      };

  String toWire() => switch (this) {
        ExpenditureType.electricity => 'ELECTRICITY',
        ExpenditureType.gas => 'GAS',
        ExpenditureType.water => 'WATER',
        ExpenditureType.taxes => 'TAXES',
        ExpenditureType.renting => 'RENTING',
        ExpenditureType.other => 'OTHER',
      };

  String get label => switch (this) {
        ExpenditureType.electricity => 'Elektr energiyasi',
        ExpenditureType.gas => 'Gaz',
        ExpenditureType.water => 'Suv',
        ExpenditureType.taxes => 'Soliqlar',
        ExpenditureType.renting => 'Ijara',
        ExpenditureType.other => 'Boshqa',
      };
}
