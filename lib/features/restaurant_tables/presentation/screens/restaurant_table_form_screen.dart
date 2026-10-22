import 'package:flutter/material.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/features/restaurant_tables/domain/entities/restaurant_table.dart';
import 'package:bsmart/features/restaurant_tables/domain/entities/restaurant_table_write_params.dart';
import 'package:bsmart/features/restaurant_tables/domain/usecases/create_restaurant_table_usecase.dart';
import 'package:bsmart/features/restaurant_tables/domain/usecases/update_restaurant_table_usecase.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

class RestaurantTableFormScreen extends StatefulWidget {
  const RestaurantTableFormScreen({super.key, this.editingTable});

  final RestaurantTable? editingTable;

  @override
  State<RestaurantTableFormScreen> createState() => _RestaurantTableFormScreenState();
}

class _RestaurantTableFormScreenState extends State<RestaurantTableFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.editingTable?.name);
  late final _percentController = TextEditingController(
    text: widget.editingTable != null ? _plain(widget.editingTable!.percent) : '0',
  );
  bool _isSaving = false;
  String? _errorMessage;

  bool get _isEditing => widget.editingTable != null;

  /// "10" rather than "10.0" in the field.
  static String _plain(double v) => v == v.truncateToDouble() ? v.toStringAsFixed(0) : v.toString();

  @override
  void dispose() {
    _nameController.dispose();
    _percentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final percent = double.tryParse(_percentController.text.trim()) ?? 0;
    final result = _isEditing
        ? await getIt<UpdateRestaurantTableUseCase>().call(
            widget.editingTable!.id,
            UpdateRestaurantTableParams(name: _nameController.text.trim(), percent: percent),
          )
        : await getIt<CreateRestaurantTableUseCase>().call(
            CreateRestaurantTableParams(name: _nameController.text.trim(), percent: percent),
          );
    if (!mounted) return;
    result.fold(
      (_) => Navigator.of(context).pop(true),
      (failure) => setState(() {
        _isSaving = false;
        _errorMessage = failure.message;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DashPage(
      title: _isEditing ? context.l10n.tablesEditTitle : context.l10n.tablesNewTitle,
      bottomBar: DashBottomButton(label: context.l10n.commonSave, busy: _isSaving, onPressed: _submit),
      body: DashFormTheme(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: context.l10n.commonNameRequired, hintText: '5'),
                validator: (v) => (v == null || v.trim().isEmpty) ? context.l10n.commonNameMissing : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _percentController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: context.l10n.tablesServiceChargeRequired,
                  hintText: '10',
                  suffixText: '%',
                ),
                validator: (v) {
                  final value = double.tryParse((v ?? '').trim());
                  if (value == null) return context.l10n.tablesPercentMissing;
                  if (value < 0 || value > 100) return context.l10n.tablesPercentRange;
                  return null;
                },
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
