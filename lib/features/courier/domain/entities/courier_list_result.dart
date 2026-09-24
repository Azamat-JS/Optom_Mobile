import 'package:bsmart/features/courier/domain/entities/courier.dart';

/// `GET /courier`'s envelope carries one extra field beyond the standard
/// pagination `meta` — `courierLimit` (the SUPER_ADMIN-set seat cap).
class CourierListResult {
  const CourierListResult({required this.items, required this.courierLimit});

  final List<Courier> items;
  final int courierLimit;
}
