import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/enums/expenditure_type.dart';
import 'package:bsmart/features/expenditures/domain/entities/expenditure.dart';
import 'package:bsmart/features/expenditures/domain/entities/expenditure_write_params.dart';
import 'package:bsmart/features/expenditures/domain/usecases/create_expenditure_usecase.dart';
import 'package:bsmart/features/expenditures/domain/usecases/update_expenditure_usecase.dart';

/// Create/edit form for a single overhead-spending entry.
class ExpenditureFormScreen extends ConsumerStatefulWidget {
  const ExpenditureFormScreen({super.key, this.editingExpenditure});

  final Expenditure? editingExpenditure;

  @override
  ConsumerState<ExpenditureFormScreen> createState() => _ExpenditureFormScreenState();
}

class _ExpenditureFormScreenState extends ConsumerState<ExpenditureFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _amountController = TextEditingController(
    text: widget.editingExpenditure?.amount.toStringAsFixed(0),
  );
  late final _notesController = TextEditingController(text: widget.editingExpenditure?.notes);
  late ExpenditureType _type = widget.editingExpenditure?.type ?? ExpenditureType.other;
  late DateTime _date = widget.editingExpenditure?.date ?? DateTime.now();
  bool _isSaving = false;
  String? _errorMessage;

  bool get _isEditing => widget.editingExpenditure != null;

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final amount = double.parse(_amountController.text.trim());
    final notes = _notesController.text.trim();

    final result = _isEditing
        ? await getIt<UpdateExpenditureUseCase>().call(
            widget.editingExpenditure!.id,
            UpdateExpenditureParams(type: _type, amount: amount, date: _date, notes: notes),
          )
        : await getIt<CreateExpenditureUseCase>().call(
            CreateExpenditureParams(type: _type, amount: amount, date: _date, notes: notes.isEmpty ? null : notes),
          );

    if (!mounted) return;
    result.fold(
      (expenditure) => Navigator.of(context).pop(true),
      (failure) => setState(() {
        _isSaving = false;
        _errorMessage = failure.message;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Harajatni tahrirlash' : 'Yangi harajat')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<ExpenditureType>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Turi *', border: OutlineInputBorder()),
              items: [for (final t in ExpenditureType.values) DropdownMenuItem(value: t, child: Text(t.label))],
              onChanged: (v) {
                if (v != null) setState(() => _type = v);
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: "Summasi (so'm) *",
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Summani kiriting';
                final parsed = double.tryParse(v.trim());
                if (parsed == null || parsed <= 0) return "Noto'g'ri summa";
                return null;
              },
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Sana *', border: OutlineInputBorder()),
                child: Text(DateFormat('dd.MM.yyyy').format(_date)),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Izoh', border: OutlineInputBorder()),
              maxLines: 2,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _isSaving ? null : _submit,
              child: _isSaving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Saqlash'),
            ),
          ],
        ),
      ),
    );
  }
}
