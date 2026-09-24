import 'package:flutter/material.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/enums/business_type.dart';
import 'package:bsmart/core/enums/user_role.dart';
import 'package:bsmart/features/platform_users/domain/entities/platform_user.dart';
import 'package:bsmart/features/platform_users/domain/entities/platform_user_write_params.dart';
import 'package:bsmart/features/platform_users/domain/usecases/create_platform_user_usecase.dart';
import 'package:bsmart/features/platform_users/domain/usecases/update_platform_user_usecase.dart';

/// Create/edit any platform user, of any role — the SUPER_ADMIN-only
/// provisioning path for SELLER/RETAILER accounts (which, unlike CUSTOMER,
/// have no self-registration — see `CLAUDE.md` "Session / auth model").
class PlatformUserFormScreen extends StatefulWidget {
  const PlatformUserFormScreen({super.key, this.editingUser});

  final PlatformUser? editingUser;

  @override
  State<PlatformUserFormScreen> createState() => _PlatformUserFormScreenState();
}

class _PlatformUserFormScreenState extends State<PlatformUserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _firstNameController = TextEditingController(text: widget.editingUser?.firstName);
  late final _lastNameController = TextEditingController(text: widget.editingUser?.lastName);
  late final _shopNameController = TextEditingController(text: widget.editingUser?.shopName);
  late final _phoneController = TextEditingController(text: widget.editingUser?.phone);
  final _passwordController = TextEditingController();
  UserRole _role = UserRole.retailer;
  BusinessType? _businessType;
  bool _isSaving = false;
  String? _errorMessage;

  bool get _isEditing => widget.editingUser != null;

  @override
  void initState() {
    super.initState();
    if (widget.editingUser != null) {
      _role = widget.editingUser!.role;
      _businessType = widget.editingUser!.businessType;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _shopNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final result = _isEditing
        ? await getIt<UpdatePlatformUserUseCase>().call(
            widget.editingUser!.id,
            UpdatePlatformUserParams(
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              shopName: _shopNameController.text.trim().isEmpty ? null : _shopNameController.text.trim(),
              phone: _phoneController.text.trim(),
              businessType: _role == UserRole.retailer ? _businessType : null,
            ),
          )
        : await getIt<CreatePlatformUserUseCase>().call(
            CreatePlatformUserParams(
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              shopName: _shopNameController.text.trim().isEmpty ? null : _shopNameController.text.trim(),
              phone: _phoneController.text.trim(),
              password: _passwordController.text,
              role: _role,
              businessType: _role == UserRole.retailer ? (_businessType ?? BusinessType.general) : null,
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
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Foydalanuvchini tahrirlash' : 'Yangi foydalanuvchi')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (!_isEditing) ...[
              DropdownButtonFormField<UserRole>(
                initialValue: _role,
                decoration: const InputDecoration(labelText: 'Rol *', border: OutlineInputBorder()),
                items: [
                  for (final role in UserRole.values) DropdownMenuItem(value: role, child: Text(role.label)),
                ],
                onChanged: (value) => setState(() => _role = value ?? _role),
              ),
              const SizedBox(height: 12),
            ],
            if (_role == UserRole.retailer) ...[
              DropdownButtonFormField<BusinessType>(
                initialValue: _businessType ?? BusinessType.general,
                decoration: const InputDecoration(labelText: "Yo'nalish *", border: OutlineInputBorder()),
                items: [
                  for (final type in BusinessType.values) DropdownMenuItem(value: type, child: Text(type.label)),
                ],
                onChanged: (value) => setState(() => _businessType = value),
              ),
              const SizedBox(height: 12),
            ],
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
            if (_role == UserRole.seller || _role == UserRole.retailer) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _shopNameController,
                decoration: const InputDecoration(labelText: "Do'kon nomi", border: OutlineInputBorder()),
              ),
            ],
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
