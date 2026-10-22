import 'package:flutter/material.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/enums/business_type.dart';
import 'package:bsmart/core/enums/user_role.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/features/platform_users/domain/entities/platform_user.dart';
import 'package:bsmart/features/platform_users/domain/entities/platform_user_write_params.dart';
import 'package:bsmart/features/platform_users/domain/usecases/create_platform_user_usecase.dart';
import 'package:bsmart/features/platform_users/domain/usecases/update_platform_user_usecase.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

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
    final l10n = context.l10n;
    return DashPage(
      title: _isEditing ? l10n.usersEditTitle : l10n.usersNewTitle,
      bottomBar: DashBottomButton(label: l10n.commonSave, busy: _isSaving, onPressed: _submit),
      body: DashFormTheme(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              if (!_isEditing) ...[
                DropdownButtonFormField<UserRole>(
                  initialValue: _role,
                  decoration: InputDecoration(
                    labelText: l10n.usersRoleRequired,
                    prefixIcon: const Icon(Icons.badge_rounded),
                  ),
                  items: [for (final role in UserRole.values) DropdownMenuItem(value: role, child: Text(role.label))],
                  onChanged: (value) => setState(() => _role = value ?? _role),
                ),
                const SizedBox(height: 12),
              ],
              if (_role == UserRole.retailer) ...[
                DropdownButtonFormField<BusinessType>(
                  initialValue: _businessType ?? BusinessType.general,
                  decoration: InputDecoration(
                    labelText: l10n.usersVerticalRequired,
                    prefixIcon: const Icon(Icons.storefront_rounded),
                  ),
                  items: [
                    for (final type in BusinessType.values) DropdownMenuItem(value: type, child: Text(type.label)),
                  ],
                  onChanged: (value) => setState(() => _businessType = value),
                ),
                const SizedBox(height: 12),
              ],
              DashSectionTitle(l10n.formBasics, padding: const EdgeInsets.fromLTRB(4, 8, 4, 10)),
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: l10n.commonFirstNameRequired),
                validator: (v) => (v == null || v.trim().isEmpty) ? l10n.commonFirstNameMissing : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: l10n.commonLastNameRequired),
                validator: (v) => (v == null || v.trim().isEmpty) ? l10n.commonLastNameMissing : null,
              ),
              if (_role == UserRole.seller || _role == UserRole.retailer) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _shopNameController,
                  decoration: InputDecoration(labelText: l10n.usersShopName),
                ),
              ],
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
                  if (!RegExp(r'^\+998\d{9}$').hasMatch(v.trim())) return l10n.authPhoneFormat;
                  return null;
                },
              ),
              if (!_isEditing) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.commonPasswordRequired,
                    prefixIcon: const Icon(Icons.lock_rounded),
                  ),
                  validator: (v) => (v == null || v.length < 6) ? l10n.loginPasswordMinLength : null,
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
