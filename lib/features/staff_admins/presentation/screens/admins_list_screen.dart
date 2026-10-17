import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/features/staff_admins/domain/entities/admin.dart';
import 'package:bsmart/features/staff_admins/domain/usecases/delete_admin_usecase.dart';
import 'package:bsmart/features/staff_admins/domain/usecases/set_admin_active_usecase.dart';
import 'package:bsmart/features/staff_admins/presentation/providers/admins_list_notifier.dart';
import 'package:bsmart/features/staff_admins/presentation/screens/admin_form_screen.dart';
import 'package:bsmart/features/stores/presentation/providers/stores_list_notifier.dart';

/// Owner-only panel-staff roster (`SELLER_ADMIN`/`RETAILER_ADMIN`). Never
/// reachable from an `_ADMIN`/`WAITER`/`COURIER` session — hidden from the
/// dashboard's overflow menu for those sessions (see `HomeScreen`), backed
/// server-side by `AdminService.assertIsOwner`.
class AdminsListScreen extends ConsumerWidget {
  const AdminsListScreen({super.key});

  Future<void> _openForm(BuildContext context, WidgetRef ref, {Admin? editing}) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AdminFormScreen(editingAdmin: editing)),
    );
    if (saved == true) ref.read(adminsListProvider.notifier).refresh();
  }

  Future<void> _toggleActive(BuildContext context, WidgetRef ref, Admin admin) async {
    final result = await getIt<SetAdminActiveUseCase>().call(admin.id, !admin.isActive);
    if (!context.mounted) return;
    result.fold(
      (_) => ref.read(adminsListProvider.notifier).refresh(),
      (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Admin admin) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.staffDeleteTitle),
        content: Text(context.l10n.commonDeletePermanentlyConfirm(admin.fullName)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(context.l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(context.l10n.commonDelete)),
        ],
      ),
    );
    if (confirmed != true) return;
    final result = await getIt<DeleteAdminUseCase>().call(admin.id);
    if (!context.mounted) return;
    result.fold(
      (_) => ref.read(adminsListProvider.notifier).refresh(),
      (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminsAsync = ref.watch(adminsListProvider);
    final storesAsync = ref.watch(storesListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.staffTitle)),
      body: adminsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(context.l10n.commonErrorWith('$error'))),
        data: (admins) {
          if (admins.isEmpty) return Center(child: Text(context.l10n.staffNotFound));
          final storeNames = {for (final s in storesAsync.valueOrNull ?? []) s.id: s.name};
          return RefreshIndicator(
            onRefresh: () => ref.read(adminsListProvider.notifier).refresh(),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: admins.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final admin = admins[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: admin.isActive ? null : Theme.of(context).disabledColor,
                    child: Text(admin.firstName.characters.first),
                  ),
                  title: Row(
                    children: [
                      Flexible(child: Text(admin.fullName)),
                      if (!admin.isActive) ...[
                        const SizedBox(width: 6),
                        Chip(label: Text(context.l10n.commonInactiveShort), visualDensity: VisualDensity.compact),
                      ],
                    ],
                  ),
                  subtitle: Text('${admin.phone} · ${storeNames[admin.storeId] ?? admin.storeId}'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (action) {
                      switch (action) {
                        case 'edit':
                          _openForm(context, ref, editing: admin);
                        case 'toggle':
                          _toggleActive(context, ref, admin);
                        case 'delete':
                          _delete(context, ref, admin);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 'edit', child: Text(context.l10n.commonEdit)),
                      PopupMenuItem(
                        value: 'toggle',
                        child: Text(admin.isActive ? context.l10n.commonDeactivate : context.l10n.commonActivate),
                      ),
                      PopupMenuItem(value: 'delete', child: Text(context.l10n.commonDelete)),
                    ],
                  ),
                  onTap: () => _openForm(context, ref, editing: admin),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context, ref),
        child: const Icon(Icons.person_add_alt_1),
      ),
    );
  }
}
