import 'package:flutter/material.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/features/agents/domain/entities/agent_account_user.dart';
import 'package:bsmart/features/agents/domain/usecases/create_agent_staff_usecase.dart';
import 'package:bsmart/features/agents/domain/usecases/update_agent_staff_usecase.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// Add / edit a staff agent. No store field: a staff agent works from its lead agent's stock.
/// The password is set only on create. Pops `true` once saved.
class AgentStaffFormScreen extends StatefulWidget {
  const AgentStaffFormScreen({this.editing, super.key});

  final AgentAccountUser? editing;

  @override
  State<AgentStaffFormScreen> createState() => _AgentStaffFormScreenState();
}

class _AgentStaffFormScreenState extends State<AgentStaffFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _firstName = TextEditingController(text: widget.editing?.firstName);
  late final _lastName = TextEditingController(text: widget.editing?.lastName);
  late final _phone = TextEditingController(text: widget.editing?.phone);
  final _password = TextEditingController();
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
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final result = _isEditing
        ? await getIt<UpdateAgentStaffUseCase>().call(
            widget.editing!.id,
            UpdateAgentAccountParams(
              firstName: _firstName.text.trim(),
              lastName: _lastName.text.trim(),
              phone: _phone.text.trim(),
            ),
          )
        : await getIt<CreateAgentStaffUseCase>().call(
            CreateAgentAccountParams(
              firstName: _firstName.text.trim(),
              lastName: _lastName.text.trim(),
              phone: _phone.text.trim(),
              password: _password.text,
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
      title: _isEditing ? l10n.agentStaffEdit : l10n.agentStaffNew,
      bottomBar: DashBottomButton(label: l10n.commonSave, busy: _isSaving, onPressed: _submit),
      body: DashFormTheme(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
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
