import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/features/crm/domain/crm_due.dart';
import 'package:bsmart/features/crm/domain/entities/crm_driver.dart';
import 'package:bsmart/features/crm/domain/entities/crm_params.dart';
import 'package:bsmart/features/crm/domain/usecases/add_crm_vehicle_usecase.dart';
import 'package:bsmart/features/crm/domain/usecases/create_crm_driver_usecase.dart';
import 'package:bsmart/features/crm/domain/usecases/update_crm_driver_usecase.dart';
import 'package:bsmart/features/crm/domain/usecases/update_crm_vehicle_usecase.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

String? _dailyKmError(BuildContext context, String? v) {
  final text = v?.trim() ?? '';
  if (text.isEmpty) return null;
  final n = int.tryParse(text);
  return n == null || n < 1 || n > 3000 ? context.l10n.crmDailyKmInvalid : null;
}

/// Plate, model and daily km — shared by the driver form's first car and the car form. With
/// [optional], all three may stay empty; once a plate or model is typed both are needed.
class CrmVehicleFields extends StatelessWidget {
  const CrmVehicleFields({
    required this.plate,
    required this.model,
    required this.dailyKm,
    this.optional = false,
    super.key,
  });

  final TextEditingController plate;
  final TextEditingController model;
  final TextEditingController dailyKm;
  final bool optional;

  bool get _empty => plate.text.trim().isEmpty && model.text.trim().isEmpty && dailyKm.text.trim().isEmpty;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        TextFormField(
          controller: plate,
          textCapitalization: TextCapitalization.characters,
          style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w700, letterSpacing: 0.6),
          decoration: InputDecoration(
            labelText: optional ? l10n.crmPlate : '${l10n.crmPlate} *',
            hintText: '01 A 123 BC',
            prefixIcon: const Icon(Icons.pin_rounded),
          ),
          validator: (v) {
            if (optional && _empty) return null;
            if (v == null || v.trim().isEmpty) return l10n.crmPlateMissing;
            return isValidPlate(v) ? null : l10n.crmPlateInvalid;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: model,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: optional ? l10n.crmModel : '${l10n.crmModel} *',
            hintText: 'Chevrolet Cobalt',
            prefixIcon: const Icon(Icons.directions_car_rounded),
          ),
          validator: (v) {
            if (optional && _empty) return null;
            return (v == null || v.trim().isEmpty) ? l10n.crmModelMissing : null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: dailyKm,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: l10n.crmDailyKm,
            helperText: l10n.crmDailyKmHint,
            helperMaxLines: 2,
            prefixIcon: const Icon(Icons.speed_rounded),
          ),
          validator: (v) => _dailyKmError(context, v),
        ),
      ],
    );
  }
}

/// Create (with an optional first car) or edit a driver. Pops the saved [CrmDriver].
class CrmDriverFormScreen extends ConsumerStatefulWidget {
  const CrmDriverFormScreen({this.editing, super.key});

  final CrmDriver? editing;

  @override
  ConsumerState<CrmDriverFormScreen> createState() => _CrmDriverFormScreenState();
}

class _CrmDriverFormScreenState extends ConsumerState<CrmDriverFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _firstName = TextEditingController(text: widget.editing?.firstName);
  late final _lastName = TextEditingController(text: widget.editing?.lastName);
  late final _phone = TextEditingController(text: widget.editing?.phone);
  late final _notes = TextEditingController(text: widget.editing?.notes);
  final _plate = TextEditingController();
  final _model = TextEditingController();
  final _dailyKm = TextEditingController();
  late bool _isActive = widget.editing?.isActive ?? true;
  bool _saving = false;
  String? _error;

  bool get _isEditing => widget.editing != null;

  @override
  void dispose() {
    for (final c in [_firstName, _lastName, _phone, _notes, _plate, _model, _dailyKm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final plate = _plate.text.trim();
    final result = _isEditing
        ? await getIt<UpdateCrmDriverUseCase>().call(
            widget.editing!.id,
            UpdateCrmDriverParams(
              firstName: _firstName.text,
              lastName: _lastName.text,
              phone: _phone.text,
              notes: _notes.text,
              isActive: _isActive,
            ),
          )
        : await getIt<CreateCrmDriverUseCase>().call(
            CreateCrmDriverParams(
              firstName: _firstName.text,
              lastName: _lastName.text,
              phone: _phone.text,
              notes: _notes.text,
              vehicles: [
                if (plate.isNotEmpty)
                  CrmVehicleParams(
                    plateNumber: plate,
                    model: _model.text,
                    dailyKm: int.tryParse(_dailyKm.text.trim()),
                  ),
              ],
            ),
          );
    if (!mounted) return;
    result.fold(
      (driver) => Navigator.of(context).pop(driver),
      (failure) => setState(() {
        _saving = false;
        _error = failure.message;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    return DashPage(
      title: _isEditing ? l10n.crmEditDriver : l10n.crmNewDriver,
      bottomBar: DashBottomButton(label: l10n.commonSave, busy: _saving, onPressed: _submit),
      body: DashFormTheme(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              DashSectionTitle(l10n.formBasics, padding: const EdgeInsets.fromLTRB(4, 8, 4, 10)),
              TextFormField(
                controller: _firstName,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(labelText: l10n.commonFirstNameRequired, prefixIcon: const Icon(Icons.person_rounded)),
                validator: (v) => (v == null || v.trim().isEmpty) ? l10n.commonFirstNameMissing : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lastName,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(labelText: l10n.crmLastName, prefixIcon: const Icon(Icons.badge_rounded)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: l10n.commonPhoneRequired,
                  hintText: '+998901234567',
                  helperText: l10n.crmPhoneHint,
                  helperMaxLines: 2,
                  prefixIcon: const Icon(Icons.phone_rounded),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return l10n.commonPhoneMissing;
                  return RegExp(r'^\+?[0-9]{9,15}$').hasMatch(v.trim()) ? null : l10n.commonInvalidFormat;
                },
              ),
              if (!_isEditing) ...[
                DashSectionTitle(l10n.crmFirstCar),
                CrmVehicleFields(plate: _plate, model: _model, dailyKm: _dailyKm, optional: true),
              ],
              DashSectionTitle(l10n.formExtra),
              TextFormField(
                controller: _notes,
                decoration: InputDecoration(labelText: l10n.commonNote, prefixIcon: const Icon(Icons.edit_note_rounded)),
                maxLines: 2,
              ),
              if (_isEditing) ...[
                const SizedBox(height: 12),
                DashCard(
                  padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _isActive,
                    onChanged: (v) => setState(() => _isActive = v),
                    title: Text(l10n.commonActive, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(l10n.crmActiveHint, style: TextStyle(color: colors.textSecondary)),
                  ),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Add or edit one of a driver's cars. Pops true when saved.
class CrmVehicleFormScreen extends StatefulWidget {
  const CrmVehicleFormScreen({required this.driverId, this.editing, super.key});

  final String driverId;
  final CrmVehicle? editing;

  @override
  State<CrmVehicleFormScreen> createState() => _CrmVehicleFormScreenState();
}

class _CrmVehicleFormScreenState extends State<CrmVehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _plate = TextEditingController(text: widget.editing == null ? null : formatPlate(widget.editing!.plateNumber));
  late final _model = TextEditingController(text: widget.editing?.model);
  late final _dailyKm = TextEditingController(text: widget.editing?.dailyKm?.toString());
  late final _notes = TextEditingController(text: widget.editing?.notes);
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_plate, _model, _dailyKm, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final params = CrmVehicleParams(
      plateNumber: _plate.text,
      model: _model.text,
      dailyKm: int.tryParse(_dailyKm.text.trim()),
      notes: _notes.text,
    );
    final result = widget.editing == null
        ? await getIt<AddCrmVehicleUseCase>().call(widget.driverId, params)
        : await getIt<UpdateCrmVehicleUseCase>().call(widget.editing!.id, params);
    if (!mounted) return;
    result.fold(
      (_) => Navigator.of(context).pop(true),
      (failure) => setState(() {
        _saving = false;
        _error = failure.message;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DashPage(
      title: widget.editing == null ? l10n.crmAddVehicle : l10n.crmEditVehicle,
      bottomBar: DashBottomButton(label: l10n.commonSave, busy: _saving, onPressed: _submit),
      body: DashFormTheme(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              CrmVehicleFields(plate: _plate, model: _model, dailyKm: _dailyKm),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notes,
                decoration: InputDecoration(labelText: l10n.commonNote, prefixIcon: const Icon(Icons.edit_note_rounded)),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
