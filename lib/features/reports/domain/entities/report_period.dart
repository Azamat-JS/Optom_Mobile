/// The window selector shared by `/reports/period-stats` and
/// `/reports/sales-chart` — deliberately only exposes the two values both
/// endpoints accept in common (`period-stats` also accepts `last7`, but
/// `sales-chart`/`sales-trend` don't, and mixing windows between this
/// screen's stats section and its chart would be confusing) so one selector
/// drives every section of the Reports hub consistently.
enum ReportPeriod {
  last30,
  month;

  String toWire() => switch (this) {
        ReportPeriod.last30 => 'last30',
        ReportPeriod.month => 'month',
      };

  String get label => switch (this) {
        ReportPeriod.last30 => "So'nggi 30 kun",
        ReportPeriod.month => 'Bu oy',
      };
}
