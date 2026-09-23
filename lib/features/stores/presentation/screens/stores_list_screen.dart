import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/features/stores/domain/entities/store.dart';
import 'package:bsmart/features/stores/domain/entities/store_write_params.dart';
import 'package:bsmart/features/stores/domain/usecases/create_store_usecase.dart';
import 'package:bsmart/features/stores/domain/usecases/delete_store_usecase.dart';
import 'package:bsmart/features/stores/domain/usecases/set_store_active_usecase.dart';
import 'package:bsmart/features/stores/domain/usecases/update_store_usecase.dart';
import 'package:bsmart/features/stores/presentation/providers/stores_list_notifier.dart';

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
      builder: (context) => _StoreFormDialog(editing: editing),
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
        title: const Text("Do'konni o'chirish"),
        content: Text('${store.name} butunlay o\'chirilsinmi?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Bekor qilish')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text("O'chirish")),
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

    return Scaffold(
      appBar: AppBar(title: const Text("Do'konlar")),
      body: storesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Xatolik: $error')),
        data: (stores) => RefreshIndicator(
          onRefresh: () => ref.read(storesListProvider.notifier).refresh(),
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: stores.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final store = stores[index];
              return ListTile(
                leading: Icon(
                  Icons.storefront_outlined,
                  color: store.isActive ? null : Theme.of(context).disabledColor,
                ),
                title: Row(
                  children: [
                    Flexible(child: Text(store.name)),
                    if (store.isDefault) ...[
                      const SizedBox(width: 6),
                      const Chip(label: Text('Asosiy'), visualDensity: VisualDensity.compact),
                    ],
                  ],
                ),
                subtitle: Text(store.address ?? '—'),
                trailing: PopupMenuButton<String>(
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
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Tahrirlash')),
                    PopupMenuItem(value: 'toggle', child: Text(store.isActive ? 'Faolsizlantirish' : 'Faollashtirish')),
                    const PopupMenuItem(value: 'delete', child: Text("O'chirish")),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _StoreFormDialog extends StatefulWidget {
  const _StoreFormDialog({this.editing});

  final Store? editing;

  @override
  State<_StoreFormDialog> createState() => _StoreFormDialogState();
}

class _StoreFormDialogState extends State<_StoreFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.editing?.name);
  late final _addressController = TextEditingController(text: widget.editing?.address);
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
            UpdateStoreParams(name: _nameController.text.trim(), address: _addressController.text.trim()),
          )
        : await getIt<CreateStoreUseCase>().call(
            CreateStoreParams(
              name: _nameController.text.trim(),
              address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
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
    return AlertDialog(
      title: Text(_isEditing ? "Do'konni tahrirlash" : "Yangi do'kon"),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nomi *'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Nomini kiriting' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Manzil'),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Bekor qilish')),
        FilledButton(
          onPressed: _isSaving ? null : _submit,
          child: _isSaving
              ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Saqlash'),
        ),
      ],
    );
  }
}
