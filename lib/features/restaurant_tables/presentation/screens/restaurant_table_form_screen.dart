import 'package:flutter/material.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/features/restaurant_tables/domain/entities/restaurant_table.dart';
import 'package:bsmart/features/restaurant_tables/domain/entities/restaurant_table_write_params.dart';
import 'package:bsmart/features/restaurant_tables/domain/usecases/create_restaurant_table_usecase.dart';
import 'package:bsmart/features/restaurant_tables/domain/usecases/update_restaurant_table_usecase.dart';

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
    text: widget.editingTable != null ? widget.editingTable!.percent.toString() : '0',
  );
  bool _isSaving = false;
  String? _errorMessage;

  bool get _isEditing => widget.editingTable != null;

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
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Stolni tahrirlash' : 'Yangi stol')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nomi *', hintText: '5', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Nomini kiriting' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _percentController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Xizmat haqi (%) *',
                hintText: '10',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                final value = double.tryParse((v ?? '').trim());
                if (value == null) return 'Foizni kiriting';
                if (value < 0 || value > 100) return '0 dan 100 gacha bo\'lishi kerak';
                return null;
              },
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
