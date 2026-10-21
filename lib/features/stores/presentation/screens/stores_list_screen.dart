import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/entities/geo_point.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/stores/domain/entities/store.dart';
import 'package:bsmart/features/stores/domain/entities/store_write_params.dart';
import 'package:bsmart/features/stores/domain/usecases/create_store_usecase.dart';
import 'package:bsmart/features/stores/domain/usecases/delete_store_usecase.dart';
import 'package:bsmart/features/stores/domain/usecases/set_store_active_usecase.dart';
import 'package:bsmart/features/stores/domain/usecases/update_store_usecase.dart';
import 'package:bsmart/features/stores/presentation/providers/stores_list_notifier.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';
import 'package:bsmart/shared/widgets/location_picker_field.dart';

/// Owner-only store/branch roster — create, rename, activate/deactivate,
/// delete. The backend refuses to deactivate/delete the sole active/only
/// store (see `store.service.ts`'s `setActive`/`remove`); this screen
/// surfaces that refusal via a toast rather than pre-emptively disabling the
/// action, since "which store is the sole one" can change from other
/// clients/sessions at any moment.
class StoresListScreen extends ConsumerWidget {
  const StoresListScreen({super.key});

  Future<void> _openForm(BuildContext context, WidgetRef ref, {Store? editing}) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => _StoreFormDialog(
        editing: editing,
        // The handover-code switch only matters to an owner with couriers.
        showHandoverSetting: ref.read(sessionNotifierProvider).valueOrNull?.user?.courierFeatureEnabled ?? false,
      ),
    );
    if (saved == true) ref.read(storesListProvider.notifier).refresh();
  }

  Future<void> _toggleActive(BuildContext context, WidgetRef ref, Store store) async {
    final result = await getIt<SetStoreActiveUseCase>().call(store.id, !store.isActive);
    if (!context.mounted) return;
    result.fold(
      (_) => ref.read(storesListProvider.notifier).refresh(),
      (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Store store) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.storesDeleteTitle),
        content: Text(context.l10n.commonDeletePermanentlyConfirm(store.name)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(context.l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(context.l10n.commonDelete)),
        ],
      ),
    );
    if (confirmed != true) return;
    final result = await getIt<DeleteStoreUseCase>().call(store.id);
    if (!context.mounted) return;
    result.fold(
      (_) => ref.read(storesListProvider.notifier).refresh(),
      (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storesAsync = ref.watch(storesListProvider);

    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    return DashPage(
      title: l10n.storesTitle,
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.storesNewTitle,
        onPressed: () => _openForm(context, ref),
        child: const Icon(Icons.add_business_rounded),
      ),
      body: storesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => DashEmptyState(icon: Icons.cloud_off_rounded, text: l10n.commonErrorWith('$error')),
        data: (stores) => RefreshIndicator(
          color: AppColors.onBrand,
          backgroundColor: AppColors.brandYellow,
          onRefresh: () => ref.read(storesListProvider.notifier).refresh(),
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
            itemCount: stores.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final store = stores[index];
              return DashListCard(
                dimmed: !store.isActive,
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: store.isDefault ? AppColors.brandYellow : DashColors.inset(context),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.storefront_rounded,
                    color: store.isDefault ? AppColors.onBrand : colors.textSecondary,
                  ),
                ),
                title: store.name,
                subtitle: [
                  if (store.isDefault) l10n.storesDefault,
                  if (!store.isActive) l10n.commonInactiveShort,
                  store.address ?? '—',
                ].join(' · '),
                trailing: DashMenuButton(
                  items: [
                    (value: 'edit', icon: Icons.edit_rounded, label: l10n.commonEdit, destructive: false),
                    (
                      value: 'toggle',
                      icon: store.isActive ? Icons.block_rounded : Icons.check_circle_rounded,
                      label: store.isActive ? l10n.commonDeactivate : l10n.commonActivate,
                      destructive: false,
                    ),
                    (value: 'delete', icon: Icons.delete_outline_rounded, label: l10n.commonDelete, destructive: true),
                  ],
                  onSelected: (action) {
                    switch (action) {
                      case 'edit':
                        _openForm(context, ref, editing: store);
                      case 'toggle':
                        _toggleActive(context, ref, store);
                      case 'delete':
                        _delete(context, ref, store);
                    }
                  },
                ),
                onTap: () => _openForm(context, ref, editing: store),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StoreFormDialog extends StatefulWidget {
  const _StoreFormDialog({this.editing, this.showHandoverSetting = false});

  final Store? editing;
  final bool showHandoverSetting;

  @override
  State<_StoreFormDialog> createState() => _StoreFormDialogState();
}

class _StoreFormDialogState extends State<_StoreFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.editing?.name);
  late final _addressController = TextEditingController(text: widget.editing?.address);
  late GeoPoint? _location = widget.editing?.location;
  late bool _requireHandoverCode = widget.editing?.requireHandoverCode ?? false;
  bool _isSaving = false;
  String? _errorMessage;

  bool get _isEditing => widget.editing != null;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final result = _isEditing
        ? await getIt<UpdateStoreUseCase>().call(
            widget.editing!.id,
            UpdateStoreParams(
              name: _nameController.text.trim(),
              address: _addressController.text.trim(),
              location: _location,
              requireHandoverCode: widget.showHandoverSetting ? _requireHandoverCode : null,
            ),
          )
        : await getIt<CreateStoreUseCase>().call(
            CreateStoreParams(
              name: _nameController.text.trim(),
              address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
              location: _location,
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
    return DashFormTheme(
      onSheet: true,
      child: AlertDialog(
        scrollable: true,
        title: Text(_isEditing ? context.l10n.storesEditTitle : context.l10n.storesNewTitle),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: context.l10n.commonNameRequired),
                validator: (v) => (v == null || v.trim().isEmpty) ? context.l10n.commonNameMissing : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: context.l10n.commonAddress),
              ),
              const SizedBox(height: 12),
              LocationPickerField(
                value: _location,
                onChanged: (p) => setState(() => _location = p),
                label: context.l10n.storesMapLocation,
                pickerTitle: context.l10n.storesLocationTitle,
                helper: context.l10n.storesLocationHint,
              ),
              // Only on edit: the backend sets it via UpdateStoreDto (new stores start with it off).
              if (_isEditing && widget.showHandoverSetting)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _requireHandoverCode,
                  onChanged: (v) => setState(() => _requireHandoverCode = v),
                  title: Text(context.l10n.storesHandoverCode),
                  subtitle: Text(context.l10n.storesHandoverCodeHint),
                ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(context.l10n.commonCancel)),
          FilledButton(
            onPressed: _isSaving ? null : _submit,
            child: _isSaving
                ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(context.l10n.commonSave),
          ),
        ],
      ),
    );
  }
}
