import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/features/agents/domain/entities/agent_account_user.dart';
import 'package:bsmart/features/agents/domain/usecases/create_lead_agent_usecase.dart';
import 'package:bsmart/features/agents/domain/usecases/update_lead_agent_usecase.dart';
import 'package:bsmart/features/stores/presentation/providers/stores_list_notifier.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// Add / edit a lead agent (owner only). The store is where the goods it receives come from.
/// The password is set only on create. Pops `true` once saved.
class LeadAgentFormScreen extends ConsumerStatefulWidget {
  const LeadAgentFormScreen({this.editing, super.key});

  final AgentAccountUser? editing;

  @override
  ConsumerState<LeadAgentFormScreen> createState() => _LeadAgentFormScreenState();
}

class _LeadAgentFormScreenState extends ConsumerState<LeadAgentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _firstName = TextEditingController(text: widget.editing?.firstName);
  late final _lastName = TextEditingController(text: widget.editing?.lastName);
  late final _phone = TextEditingController(text: widget.editing?.phone);
  final _password = TextEditingController();
  late String? _storeId = widget.editing?.storeId;
  bool _isSaving = false;
  String? _errorMessage;

  bool get _isEditing => widget.editing != null;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_storeId == null) {
      setState(() => _errorMessage = context.l10n.staffStoreRequired);
      return;
    }
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final result = _isEditing
        ? await getIt<UpdateLeadAgentUseCase>().call(
            widget.editing!.id,
            UpdateAgentAccountParams(
              firstName: _firstName.text.trim(),
              lastName: _lastName.text.trim(),
              phone: _phone.text.trim(),
              storeId: _storeId,
            ),
          )
        : await getIt<CreateLeadAgentUseCase>().call(
            CreateAgentAccountParams(
              firstName: _firstName.text.trim(),
              lastName: _lastName.text.trim(),
              phone: _phone.text.trim(),
              password: _password.text,
              storeId: _storeId,
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
    final storesAsync = ref.watch(storesListProvider);

    return DashPage(
      title: _isEditing ? l10n.ownerLeadEdit : l10n.ownerLeadNew,
      bottomBar: DashBottomButton(label: l10n.commonSave, busy: _isSaving, onPressed: _submit),
      body: DashFormTheme(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              storesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Text(l10n.commonErrorWith('$error')),
                data: (stores) => DropdownButtonFormField<String>(
                  initialValue: _storeId,
                  decoration: InputDecoration(labelText: l10n.staffStoreBranchRequired),
                  items: [
                    for (final store in stores)
                      if (store.isActive || store.id == _storeId)
                        DropdownMenuItem(value: store.id, child: Text(store.name)),
                  ],
                  onChanged: (value) => setState(() => _storeId = value),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 6, 4, 0),
                child: Text(
                  l10n.ownerLeadStoreHint,
                  style: TextStyle(fontSize: 12, color: BrandColors.of(context).textSecondary),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _firstName,
                decoration: InputDecoration(labelText: l10n.commonFirstNameRequired),
                validator: (v) => (v == null || v.trim().isEmpty) ? l10n.commonFirstNameMissing : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lastName,
                decoration: InputDecoration(labelText: l10n.commonLastNameRequired),
                validator: (v) => (v == null || v.trim().isEmpty) ? l10n.commonLastNameMissing : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: l10n.commonPhoneRequired, hintText: '+998901234567'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return l10n.commonPhoneMissing;
                  if (!RegExp(r'^\+998\d{9}$').hasMatch(v.trim())) return l10n.authPhoneFormat;
                  return null;
                },
              ),
              if (!_isEditing) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _password,
                  obscureText: true,
                  decoration: InputDecoration(labelText: l10n.commonPasswordRequired),
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
