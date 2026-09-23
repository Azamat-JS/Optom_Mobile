import 'package:bsmart/core/enums/expenditure_type.dart';
import 'package:bsmart/core/utils/decimal_parser.dart';
import 'package:bsmart/features/expenditures/domain/entities/expenditure.dart';
import 'package:bsmart/features/expenditures/domain/entities/expenditure_list_result.dart';

ExpenditureActorRef? _actorRefFromJson(dynamic json) {
  if (json == null) return null;
  final map = json as Map<String, dynamic>;
  return ExpenditureActorRef(
    id: map['id'] as String,
    firstName: map['firstName'] as String,
    lastName: map['lastName'] as String,
  );
}

Expenditure expenditureFromJson(Map<String, dynamic> json) => Expenditure(
      id: json['id'] as String,
      type: ExpenditureType.fromWire(json['type'] as String),
      amount: parseDecimal(json['amount']),
      date: DateTime.parse(json['date'] as String),
      notes: json['notes'] as String?,
      createdBy: _actorRefFromJson(json['createdBy']),
      updatedBy: _actorRefFromJson(json['updatedBy']),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

ExpenditureListResult expenditureListResultFromJson(Map<String, dynamic> json) {
  final meta = json['meta'] as Map<String, dynamic>;
  return ExpenditureListResult(
    data: (json['data'] as List).map((e) => expenditureFromJson(e as Map<String, dynamic>)).toList(),
    total: meta['total'] as int,
    page: meta['page'] as int,
    limit: meta['limit'] as int,
    totalPages: meta['totalPages'] as int,
    hasNext: meta['hasNext'] as bool,
    hasPrev: meta['hasPrev'] as bool,
    totalAmount: parseDecimal(meta['totalAmount']),
  );
}
