import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/enums/expenditure_type.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/features/expenditures/domain/entities/expenditure.dart';
import 'package:bsmart/features/expenditures/domain/entities/expenditure_write_params.dart';
import 'package:bsmart/features/expenditures/domain/usecases/create_expenditure_usecase.dart';
import 'package:bsmart/features/expenditures/domain/usecases/update_expenditure_usecase.dart';
import 'package:bsmart/features/expenditures/presentation/widgets/expenditure_visuals.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// Create/edit form for a single overhead-spending entry.
class ExpenditureFormScreen extends ConsumerStatefulWidget {
  const ExpenditureFormScreen({super.key, this.editingExpenditure});

  final Expenditure? editingExpenditure;

  @override
  ConsumerState<ExpenditureFormScreen> createState() => _ExpenditureFormScreenState();
}

class _ExpenditureFormScreenState extends ConsumerState<ExpenditureFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _amountController = TextEditingController(text: widget.editingExpenditure?.amount.toStringAsFixed(0));
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
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    return DashPage(
      title: _isEditing ? l10n.expensesEditTitle : l10n.expensesNewTitle,
      bottomBar: DashBottomButton(label: l10n.commonSave, busy: _isSaving, onPressed: _submit),
      body: DashFormTheme(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              DashSectionTitle(l10n.expensesTypeRequired, padding: const EdgeInsets.fromLTRB(4, 8, 4, 10)),
              LayoutBuilder(
                builder: (context, constraints) {
                  const gap = 8.0;
                  final width = (constraints.maxWidth - 2 * gap) / 3;
                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      for (final type in ExpenditureType.values)
                        SizedBox(
                          width: width,
                          child: Semantics(
                            selected: type == _type,
                            button: true,
                            child: Material(
                              color: type == _type ? AppColors.brandYellow : DashColors.card(context),
                              borderRadius: BorderRadius.circular(16),
                              child: InkWell(
                                onTap: () => setState(() => _type = type),
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                                  child: Column(
                                    children: [
                                      Icon(
                                        expenditureIcon(type),
                                        color: type == _type ? AppColors.onBrand : expenditureColor(type),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        type.label,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: type == _type ? AppColors.onBrand : colors.textPrimary,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: colors.textPrimary, fontSize: 17, fontWeight: FontWeight.w700),
                decoration: InputDecoration(
                  labelText: l10n.expensesAmountRequired,
                  prefixIcon: const Icon(Icons.payments_rounded),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return l10n.expensesAmountMissing;
                  final parsed = double.tryParse(v.trim());
                  if (parsed == null || parsed <= 0) return l10n.expensesAmountInvalid;
                  return null;
                },
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(18),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.commonDateRequired,
                    prefixIcon: const Icon(Icons.calendar_today_rounded),
                  ),
                  child: Text(DateFormat('dd.MM.yyyy').format(_date)),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: l10n.commonNote,
                  prefixIcon: const Icon(Icons.edit_note_rounded),
                ),
                maxLines: 2,
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 14),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w700),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
