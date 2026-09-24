import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/features/restaurant_staff/domain/entities/waiter.dart';
import 'package:bsmart/features/restaurant_staff/domain/entities/waiter_write_params.dart';
import 'package:bsmart/features/restaurant_staff/domain/usecases/create_waiter_usecase.dart';
import 'package:bsmart/features/restaurant_staff/domain/usecases/update_waiter_usecase.dart';
import 'package:bsmart/features/stores/presentation/providers/stores_list_notifier.dart';

class WaiterFormScreen extends ConsumerStatefulWidget {
  const WaiterFormScreen({super.key, this.editingWaiter});

  final Waiter? editingWaiter;

  @override
  ConsumerState<WaiterFormScreen> createState() => _WaiterFormScreenState();
}

class _WaiterFormScreenState extends ConsumerState<WaiterFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _firstNameController = TextEditingController(text: widget.editingWaiter?.firstName);
  late final _lastNameController = TextEditingController(text: widget.editingWaiter?.lastName);
  late final _phoneController = TextEditingController(text: widget.editingWaiter?.phone);
  late final _commissionController = TextEditingController(
    text: widget.editingWaiter?.commissionPercent?.toString() ?? '',
  );
  final _passwordController = TextEditingController();
  String? _selectedStoreId;
  bool _isSaving = false;
  String? _errorMessage;

  bool get _isEditing => widget.editingWaiter != null;

  @override
  void initState() {
    super.initState();
    _selectedStoreId = widget.editingWaiter?.storeId;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _commissionController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStoreId == null) {
      setState(() => _errorMessage = "Do'kon tanlanishi shart");
      return;
    }
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final commission = double.tryParse(_commissionController.text.trim());
    final result = _isEditing
        ? await getIt<UpdateWaiterUseCase>().call(
            widget.editingWaiter!.id,
            UpdateWaiterParams(
              storeId: _selectedStoreId,
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              phone: _phoneController.text.trim(),
              commissionPercent: commission,
            ),
          )
        : await getIt<CreateWaiterUseCase>().call(
            CreateWaiterParams(
              storeId: _selectedStoreId!,
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              phone: _phoneController.text.trim(),
              password: _passwordController.text,
              commissionPercent: commission,
            ),
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
    final storesAsync = ref.watch(storesListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Ofitsiantni tahrirlash' : 'Yangi ofitsiant')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            storesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text('Xatolik: $error'),
              data: (stores) => DropdownButtonFormField<String>(
                initialValue: _selectedStoreId,
                decoration: const InputDecoration(labelText: "Do'kon (filial) *", border: OutlineInputBorder()),
                items: [
                  for (final store in stores) DropdownMenuItem(value: store.id, child: Text(store.name)),
                ],
                onChanged: (value) => setState(() => _selectedStoreId = value),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _firstNameController,
              decoration: const InputDecoration(labelText: 'Ism *', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Ismni kiriting' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: 'Familiya *', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Familiyani kiriting' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Telefon *',
                hintText: '+998901234567',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Telefon raqamini kiriting';
                if (!RegExp(r'^\+998\d{9}$').hasMatch(v.trim())) return 'Format: +998XXXXXXXXX';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _commissionController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Komissiya (%) — ixtiyoriy',
                hintText: '5',
                border: OutlineInputBorder(),
              ),
            ),
            if (!_isEditing) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Parol *', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.length < 6) ? 'Kamida 6 ta belgi' : null,
              ),
            ],
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
