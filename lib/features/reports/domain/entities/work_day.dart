import 'package:bsmart/features/reports/domain/entities/period_stats.dart';

enum WorkDayStatus {
  open,
  closed;

  static WorkDayStatus fromWire(String value) => switch (value) {
        'OPEN' => WorkDayStatus.open,
        'CLOSED' => WorkDayStatus.closed,
        _ => throw ArgumentError('Unknown WorkDayStatus from backend: $value'),
      };
}

/// A trading shift (`GET/POST /work-day/*`) — `summary` is the exact same
/// shape as `PeriodStats` (the backend's `WorkDayService.end()` stores a
/// `ShiftSummary` snapshot, the same type `periodStats()` returns), just
/// missing on an still-`OPEN` day.
class WorkDay {
  const WorkDay({
    required this.id,
    required this.status,
    required this.startedAt,
    this.endedAt,
    this.summary,
  });

  final String id;
  final WorkDayStatus status;
  final DateTime startedAt;
  final DateTime? endedAt;
  final PeriodStats? summary;

  factory WorkDay.fromJson(Map<String, dynamic> json) => WorkDay(
        id: json['id'] as String,
        status: WorkDayStatus.fromWire(json['status'] as String),
        startedAt: DateTime.parse(json['startedAt'] as String),
        endedAt: json['endedAt'] != null ? DateTime.parse(json['endedAt'] as String) : null,
        summary: json['summary'] != null ? PeriodStats.fromJson(json['summary'] as Map<String, dynamic>) : null,
      );
}

/// `GET /work-day/by-date` — every shift that started on the given calendar
/// date, plus a combined analytics summary for that date (an in-progress
/// `OPEN` shift is computed live server-side, a `CLOSED` one reuses its
/// stored snapshot — see `work-day.service.ts`).
class WorkDayByDateResult {
  const WorkDayByDateResult({required this.date, required this.workDays, this.summary});

  final DateTime date;
  final List<WorkDay> workDays;
  final PeriodStats? summary;

  factory WorkDayByDateResult.fromJson(Map<String, dynamic> json) => WorkDayByDateResult(
        date: DateTime.parse(json['date'] as String),
        workDays: (json['workDays'] as List).map((e) => WorkDay.fromJson(e as Map<String, dynamic>)).toList(),
        summary: json['summary'] != null ? PeriodStats.fromJson(json['summary'] as Map<String, dynamic>) : null,
      );
}
