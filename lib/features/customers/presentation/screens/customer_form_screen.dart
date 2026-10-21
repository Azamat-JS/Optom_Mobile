import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/features/customers/domain/entities/customer.dart';
import 'package:bsmart/features/customers/domain/entities/customer_write_params.dart';
import 'package:bsmart/features/customers/domain/usecases/create_customer_usecase.dart';
import 'package:bsmart/features/customers/domain/usecases/update_customer_usecase.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

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
    final l10n = context.l10n;
    return DashPage(
      title: _isEditing ? l10n.customersEditTitle : l10n.customersNewTitle,
      bottomBar: DashBottomButton(label: l10n.commonSave, busy: _isSaving, onPressed: _submit),
      body: DashFormTheme(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              DashSectionTitle(l10n.formBasics, padding: const EdgeInsets.fromLTRB(4, 8, 4, 10)),
              TextFormField(
                controller: _firstNameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: l10n.commonFirstNameRequired,
                  prefixIcon: const Icon(Icons.person_rounded),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? l10n.commonFirstNameMissing : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lastNameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: l10n.commonLastNameRequired,
                  prefixIcon: const Icon(Icons.badge_rounded),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? l10n.commonLastNameMissing : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: l10n.commonPhoneRequired,
                  hintText: '+998901234567',
                  prefixIcon: const Icon(Icons.phone_rounded),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return l10n.commonPhoneMissing;
                  if (!RegExp(r'^\+?[0-9]{9,15}$').hasMatch(v.trim())) return l10n.commonInvalidFormat;
                  return null;
                },
              ),
              DashSectionTitle(l10n.formExtra),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: l10n.commonAddress,
                  prefixIcon: const Icon(Icons.location_on_rounded),
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
