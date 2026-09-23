import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/features/customers/domain/entities/customer.dart';
import 'package:bsmart/features/customers/domain/entities/customer_write_params.dart';
import 'package:bsmart/features/customers/domain/usecases/create_customer_usecase.dart';
import 'package:bsmart/features/customers/domain/usecases/update_customer_usecase.dart';

/// Create/edit form, also used as a quick "Yangi mijoz" entry point from
/// POS's checkout customer picker (pushed for its `pop(true)`/`Customer`
/// result rather than only a plain `bool`, see `pushForResult`).
class CustomerFormScreen extends ConsumerStatefulWidget {
  const CustomerFormScreen({super.key, this.editingCustomer});

  final Customer? editingCustomer;

  @override
  ConsumerState<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends ConsumerState<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _firstNameController = TextEditingController(text: widget.editingCustomer?.firstName);
  late final _lastNameController = TextEditingController(text: widget.editingCustomer?.lastName);
  late final _phoneController = TextEditingController(text: widget.editingCustomer?.phone);
  late final _addressController = TextEditingController(text: widget.editingCustomer?.address);
  late final _notesController = TextEditingController(text: widget.editingCustomer?.notes);
  bool _isSaving = false;
  String? _errorMessage;

  bool get _isEditing => widget.editingCustomer != null;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final result = _isEditing
        ? await getIt<UpdateCustomerUseCase>().call(
            widget.editingCustomer!.id,
            UpdateCustomerParams(
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              phone: _phoneController.text.trim(),
              address: _addressController.text.trim(),
              notes: _notesController.text.trim(),
            ),
          )
        : await getIt<CreateCustomerUseCase>().call(
            CreateCustomerParams(
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              phone: _phoneController.text.trim(),
              address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
              notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
            ),
          );

    if (!mounted) return;
    result.fold(
      (customer) => Navigator.of(context).pop(customer),
      (failure) => setState(() {
        _isSaving = false;
        _errorMessage = failure.message;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Mijozni tahrirlash' : 'Yangi mijoz')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
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
                if (!RegExp(r'^\+?[0-9]{9,15}$').hasMatch(v.trim())) return "Noto'g'ri format";
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Manzil', border: OutlineInputBorder()),
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
