import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/l10n/l10n.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/features/restaurant_staff/domain/entities/waiter.dart';
import 'package:bsmart/features/restaurant_staff/domain/entities/waiter_write_params.dart';
import 'package:bsmart/features/restaurant_staff/domain/usecases/create_waiter_usecase.dart';
import 'package:bsmart/features/restaurant_staff/domain/usecases/update_waiter_usecase.dart';
import 'package:bsmart/features/stores/presentation/providers/stores_list_notifier.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

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
      setState(() => _errorMessage = context.l10n.staffStoreRequired);
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

    return DashPage(
      title: _isEditing ? context.l10n.waitersEditTitle : context.l10n.waitersNewTitle,
      bottomBar: DashBottomButton(label: context.l10n.commonSave, busy: _isSaving, onPressed: _submit),
      body: DashFormTheme(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              storesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Text(context.l10n.commonErrorWith('$error')),
                data: (stores) => DropdownButtonFormField<String>(
                  initialValue: _selectedStoreId,
                  decoration: InputDecoration(labelText: context.l10n.staffStoreBranchRequired),
                  items: [for (final store in stores) DropdownMenuItem(value: store.id, child: Text(store.name))],
                  onChanged: (value) => setState(() => _selectedStoreId = value),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: context.l10n.commonFirstNameRequired),
                validator: (v) => (v == null || v.trim().isEmpty) ? context.l10n.commonFirstNameMissing : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: context.l10n.commonLastNameRequired),
                validator: (v) => (v == null || v.trim().isEmpty) ? context.l10n.commonLastNameMissing : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: context.l10n.commonPhoneRequired, hintText: '+998901234567'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return context.l10n.commonPhoneMissing;
                  if (!RegExp(r'^\+998\d{9}$').hasMatch(v.trim())) return context.l10n.authPhoneFormat;
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _commissionController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: context.l10n.waitersCommissionOptional, hintText: '5'),
              ),
              if (!_isEditing) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: context.l10n.commonPasswordRequired),
                  validator: (v) => (v == null || v.length < 6) ? context.l10n.loginPasswordMinLength : null,
                ),
              ],
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
