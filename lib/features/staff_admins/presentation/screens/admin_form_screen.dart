import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/features/staff_admins/domain/entities/admin.dart';
import 'package:bsmart/features/staff_admins/domain/entities/admin_write_params.dart';
import 'package:bsmart/features/staff_admins/domain/usecases/create_admin_usecase.dart';
import 'package:bsmart/features/staff_admins/domain/usecases/update_admin_usecase.dart';
import 'package:bsmart/features/stores/presentation/providers/stores_list_notifier.dart';

/// Create/edit a panel admin. The store picker is mandatory and prominent
/// (first field, per the original milestone plan) — locking a new admin to
/// a store is one-way from their own side; only the owner can reassign it
/// later via this same form's edit mode.
class AdminFormScreen extends ConsumerStatefulWidget {
  const AdminFormScreen({super.key, this.editingAdmin});

  final Admin? editingAdmin;

  @override
  ConsumerState<AdminFormScreen> createState() => _AdminFormScreenState();
}

class _AdminFormScreenState extends ConsumerState<AdminFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _firstNameController = TextEditingController(text: widget.editingAdmin?.firstName);
  late final _lastNameController = TextEditingController(text: widget.editingAdmin?.lastName);
  late final _phoneController = TextEditingController(text: widget.editingAdmin?.phone);
  final _passwordController = TextEditingController();
  String? _selectedStoreId;
  bool _isSaving = false;
  String? _errorMessage;

  bool get _isEditing => widget.editingAdmin != null;

  @override
  void initState() {
    super.initState();
    _selectedStoreId = widget.editingAdmin?.storeId;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStoreId == null) {
      setState(() => _errorMessage = context.l10n.staffStoreRequired);
      return;
    }
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final result = _isEditing
        ? await getIt<UpdateAdminUseCase>().call(
            widget.editingAdmin!.id,
            UpdateAdminParams(
              storeId: _selectedStoreId,
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              phone: _phoneController.text.trim(),
            ),
          )
        : await getIt<CreateAdminUseCase>().call(
            CreateAdminParams(
              storeId: _selectedStoreId!,
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              phone: _phoneController.text.trim(),
              password: _passwordController.text,
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
      appBar: AppBar(title: Text(_isEditing ? context.l10n.staffEditTitle : context.l10n.staffNewTitle)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            storesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text(context.l10n.commonErrorWith('$error')),
              data: (stores) => DropdownButtonFormField<String>(
                initialValue: _selectedStoreId,
                decoration: InputDecoration(labelText: context.l10n.staffStoreLabel, border: OutlineInputBorder()),
                items: [
                  for (final store in stores) DropdownMenuItem(value: store.id, child: Text(store.name)),
                ],
                onChanged: (value) => setState(() => _selectedStoreId = value),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _firstNameController,
              decoration: InputDecoration(labelText: context.l10n.commonFirstNameRequired, border: OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().isEmpty) ? context.l10n.commonFirstNameMissing : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _lastNameController,
              decoration: InputDecoration(labelText: context.l10n.commonLastNameRequired, border: OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().isEmpty) ? context.l10n.commonLastNameMissing : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: context.l10n.commonPhoneRequired,
                hintText: '+998901234567',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return context.l10n.commonPhoneMissing;
                if (!RegExp(r'^\+998\d{9}$').hasMatch(v.trim())) return context.l10n.authPhoneFormat;
                return null;
              },
            ),
            if (!_isEditing) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: context.l10n.commonPasswordRequired, border: OutlineInputBorder()),
                validator: (v) => (v == null || v.length < 6) ? context.l10n.loginPasswordMinLength : null,
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
                  : Text(context.l10n.commonSave),
            ),
          ],
        ),
      ),
    );
  }
}
