import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/features/restaurant_tables/domain/entities/restaurant_table.dart';
import 'package:bsmart/features/restaurant_tables/domain/usecases/delete_restaurant_table_usecase.dart';
import 'package:bsmart/features/restaurant_tables/presentation/providers/restaurant_tables_list_notifier.dart';
import 'package:bsmart/features/restaurant_tables/presentation/screens/restaurant_table_form_screen.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// Table/room management — not owner-only (`RETAILER_ADMIN` gets it too,
/// operational config rather than owner-private data, mirroring
/// `StoresListScreen`'s access level, not `AdminsListScreen`'s).
class RestaurantTablesListScreen extends ConsumerWidget {
  const RestaurantTablesListScreen({super.key});

  Future<void> _openForm(BuildContext context, WidgetRef ref, {RestaurantTable? editing}) async {
    final saved = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => RestaurantTableFormScreen(editingTable: editing)));
    if (saved == true) ref.read(restaurantTablesListProvider.notifier).refresh();
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, RestaurantTable table) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.tablesDeleteTitle),
        content: Text(context.l10n.tablesDeleteConfirm(table.name)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(context.l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(context.l10n.commonDelete)),
        ],
      ),
    );
    if (confirmed != true) return;
    final result = await getIt<DeleteRestaurantTableUseCase>().call(table.id);
    if (!context.mounted) return;
    result.fold(
      (_) => ref.read(restaurantTablesListProvider.notifier).refresh(),
      (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tablesAsync = ref.watch(restaurantTablesListProvider);

    return DashPage(
      title: l10n.navTables,
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.commonAdd,
        onPressed: () => _openForm(context, ref),
        child: const Icon(Icons.add_rounded),
      ),
      body: tablesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => DashEmptyState(
          icon: Icons.cloud_off_rounded,
          text: l10n.commonErrorWith('$error'),
          action: TextButton(
            onPressed: () => ref.invalidate(restaurantTablesListProvider),
            child: Text(l10n.commonRetry),
          ),
        ),
        data: (tables) => RefreshIndicator(
          color: AppColors.onBrand,
          backgroundColor: AppColors.brandYellow,
          onRefresh: () => ref.read(restaurantTablesListProvider.notifier).refresh(),
          child: tables.isEmpty
              ? DashEmptyState(icon: Icons.table_restaurant_rounded, text: l10n.tablesNotFound)
              // A Wrap rather than a grid: cards take the height of their
              // text, so a long name or a large text scale never overflows.
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final width = (constraints.maxWidth - 32 - 10) / 2;
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                      children: [
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (final (i, table) in tables.indexed)
                              SizedBox(
                                width: width,
                                child: _TableCard(
                                  table: table,
                                  onTap: () => _openForm(context, ref, editing: table),
                                  onDelete: () => _delete(context, ref, table),
                                ),
                              ).animate().fadeIn(delay: (25 * (i % 12)).ms, duration: AppMotion.standard),
                          ],
                        ),
                      ],
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _TableCard extends StatelessWidget {
  const _TableCard({required this.table, required this.onTap, required this.onDelete});

  final RestaurantTable table;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final percent = table.percent % 1 == 0 ? table.percent.toStringAsFixed(0) : table.percent.toStringAsFixed(2);
    return DashCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(14, 12, 4, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: AppColors.brandYellow, borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.table_restaurant_rounded, color: AppColors.onBrand),
              ),
              const Spacer(),
              DashMenuButton(
                items: [
                  (value: 'edit', icon: Icons.edit_rounded, label: l10n.commonEdit, destructive: false),
                  (value: 'delete', icon: Icons.delete_outline_rounded, label: l10n.commonDelete, destructive: true),
                ],
                onSelected: (action) => action == 'edit' ? onTap() : onDelete(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            table.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            l10n.tablesServiceCharge(percent),
            style: TextStyle(color: colors.textMuted, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
