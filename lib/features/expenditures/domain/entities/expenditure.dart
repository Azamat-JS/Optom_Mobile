import 'package:bsmart/core/enums/expenditure_type.dart';

/// A minimal user reference embedded on an expenditure (`createdBy`/`updatedBy`).
class ExpenditureActorRef {
  const ExpenditureActorRef({required this.id, required this.firstName, required this.lastName});

  final String id;
  final String firstName;
  final String lastName;

  String get fullName => '$firstName $lastName'.trim();
}

/// A SELLER's/RETAILER's own business overhead spending (`GET /expenditures`
/// — owner-only, `SELLER_ADMIN`/`RETAILER_ADMIN` are rejected server-side,
/// see `CLAUDE.md` "Expenditures"). Deliberately no `Currency` field — an
/// expenditure is always paid in so'm, unlike `Product`/`Order`/`Sale`.
class Expenditure {
  const Expenditure({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    this.notes,
    this.createdBy,
    this.updatedBy,
    required this.createdAt,
  });

  final String id;
  final ExpenditureType type;
  final double amount;
  final DateTime date;
  final String? notes;
  final ExpenditureActorRef? createdBy;
  final ExpenditureActorRef? updatedBy;
  final DateTime createdAt;
}
