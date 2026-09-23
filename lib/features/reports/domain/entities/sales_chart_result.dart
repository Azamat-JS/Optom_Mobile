/// One `{date, amount}` point on `/reports/sales-chart`'s per-currency series.
class AmountPoint {
  const AmountPoint({required this.date, required this.amount});
  final String date;
  final double amount;

  factory AmountPoint.fromJson(Map<String, dynamic> json) =>
      AmountPoint(date: json['date'] as String, amount: (json['amount'] as num).toDouble());
}

class AmountSeriesByCurrency {
  const AmountSeriesByCurrency({required this.uzs, required this.usd});
  final List<AmountPoint> uzs;
  final List<AmountPoint> usd;

  factory AmountSeriesByCurrency.fromJson(Map<String, dynamic> json) => AmountSeriesByCurrency(
        uzs: (json['uzs'] as List).map((e) => AmountPoint.fromJson(e as Map<String, dynamic>)).toList(),
        usd: (json['usd'] as List).map((e) => AmountPoint.fromJson(e as Map<String, dynamic>)).toList(),
      );
}

/// `GET /reports/sales-chart` — day-by-day revenue series for a
/// caller-selected window (trailing 30 days, or a calendar month).
class SalesChartResult {
  const SalesChartResult({required this.from, required this.to, required this.salesChart});

  final DateTime from;
  final DateTime to;
  final AmountSeriesByCurrency salesChart;

  factory SalesChartResult.fromJson(Map<String, dynamic> json) => SalesChartResult(
        from: DateTime.parse(json['from'] as String),
        to: DateTime.parse(json['to'] as String),
        salesChart: AmountSeriesByCurrency.fromJson(json['salesChart'] as Map<String, dynamic>),
      );
}
