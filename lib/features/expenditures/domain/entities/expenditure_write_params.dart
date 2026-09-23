import 'package:bsmart/core/enums/expenditure_type.dart';

/// Mirrors `CreateExpenditureDto` field-for-field.
class CreateExpenditureParams {
  const CreateExpenditureParams({required this.type, required this.amount, required this.date, this.notes});

  final ExpenditureType type;
  final double amount;
  final DateTime date;
  final String? notes;

  Map<String, dynamic> toRequestBody() => {
        'type': type.toWire(),
        'amount': amount,
        'date': date.toIso8601String().split('T').first,
        if (notes != null && notes!.isNotEmpty) 'notes': notes,
      };
}

/// Mirrors `UpdateExpenditureDto` (a `PartialType` of the create DTO) —
/// every field optional, only non-null ones are sent.
class UpdateExpenditureParams {
  const UpdateExpenditureParams({this.type, this.amount, this.date, this.notes});

  final ExpenditureType? type;
  final double? amount;
  final DateTime? date;
  final String? notes;

  Map<String, dynamic> toRequestBody() => {
        if (type != null) 'type': type!.toWire(),
        if (amount != null) 'amount': amount,
        if (date != null) 'date': date!.toIso8601String().split('T').first,
        if (notes != null) 'notes': notes,
      };
}
