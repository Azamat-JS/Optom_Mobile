import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

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
    final saved = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => AdminFormScreen(editingAdmin: editing)));
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

    return DashPage(
      title: context.l10n.staffTitle,
      floatingActionButton: FloatingActionButton(
        tooltip: context.l10n.staffNewTitle,
        onPressed: () => _openForm(context, ref),
        child: const Icon(Icons.person_add_alt_1_rounded),
      ),
      body: adminsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            DashEmptyState(icon: Icons.cloud_off_rounded, text: context.l10n.commonErrorWith('$error')),
        data: (admins) {
          final storeNames = {for (final s in storesAsync.valueOrNull ?? []) s.id: s.name};
          final items = admins;
          return RefreshIndicator(
            color: AppColors.onBrand,
            backgroundColor: AppColors.brandYellow,
            onRefresh: () => ref.read(adminsListProvider.notifier).refresh(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
              children: [
                if (items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: Text(
                      context.l10n.staffNotFound,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: BrandColors.of(context).textSecondary, fontWeight: FontWeight.w600),
                    ),
                  ),
                for (final (i, admin) in items.indexed) ...[
                  if (i > 0) const SizedBox(height: 10),
                  DashListCard(
                    dimmed: !admin.isActive,
                    leading: DashAvatar(name: admin.firstName, active: admin.isActive),
                    title: admin.fullName,
                    subtitle: [admin.phone, storeNames[admin.storeId] ?? admin.storeId].join(' · '),
                    trailing: DashMenuButton(
                      items: [
                        (value: 'edit', icon: Icons.edit_rounded, label: context.l10n.commonEdit, destructive: false),
                        (
                          value: 'toggle',
                          icon: admin.isActive ? Icons.block_rounded : Icons.check_circle_rounded,
                          label: admin.isActive ? context.l10n.commonDeactivate : context.l10n.commonActivate,
                          destructive: false,
                        ),
                        (
                          value: 'delete',
                          icon: Icons.delete_outline_rounded,
                          label: context.l10n.commonDelete,
                          destructive: true,
                        ),
                      ],
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
                    ),
                    onTap: () => _openForm(context, ref, editing: admin),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
