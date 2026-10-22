import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/enums/master_product_status.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/features/master_catalog/domain/entities/master_product.dart';
import 'package:bsmart/features/master_catalog/domain/usecases/approve_master_product_usecase.dart';
import 'package:bsmart/features/master_catalog/domain/usecases/delete_master_product_usecase.dart';
import 'package:bsmart/features/master_catalog/domain/usecases/reject_master_product_usecase.dart';
import 'package:bsmart/features/master_catalog/presentation/providers/master_catalog_admin_list_notifier.dart';
import 'package:bsmart/features/master_catalog/presentation/screens/master_product_form_screen.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// SUPER_ADMIN catalog management. Filtering the status chips to "Kutilmoqda"
/// turns this into the moderation review queue for seller-submitted
/// share-to-catalog entries — the same screen, not a separate one, per the
/// plan's reusable-review-queue idea.
class MasterCatalogAdminListScreen extends ConsumerStatefulWidget {
  const MasterCatalogAdminListScreen({super.key});

  @override
  ConsumerState<MasterCatalogAdminListScreen> createState() => _MasterCatalogAdminListScreenState();
}

class _MasterCatalogAdminListScreenState extends ConsumerState<MasterCatalogAdminListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(masterCatalogAdminListProvider.notifier).loadMore();
    }
  }

  Future<void> _openForm({MasterProduct? editing}) async {
    final saved = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => MasterProductFormScreen(editingProduct: editing)));
    if (saved == true) ref.read(masterCatalogAdminListProvider.notifier).refresh();
  }

  Future<void> _approve(MasterProduct item) async {
    final result = await getIt<ApproveMasterProductUseCase>().call(item.id);
    if (!mounted) return;
    result.fold(
      (_) => ref.read(masterCatalogAdminListProvider.notifier).refresh(),
      (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }

  Future<void> _reject(MasterProduct item) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.commonReject),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: context.l10n.commonReasonOptional, border: OutlineInputBorder()),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(context.l10n.commonCancel)),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text(context.l10n.commonReject),
          ),
        ],
      ),
    );
    if (reason == null) return;
    final result = await getIt<RejectMasterProductUseCase>().call(item.id, reason: reason.isEmpty ? null : reason);
    if (!mounted) return;
    result.fold(
      (_) => ref.read(masterCatalogAdminListProvider.notifier).refresh(),
      (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }

  Future<void> _delete(MasterProduct item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.masterDeleteTitle),
        content: Text(context.l10n.commonDeleteWithDependentsConfirm(item.name)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(context.l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(context.l10n.commonDelete)),
        ],
      ),
    );
    if (confirmed != true) return;
    final result = await getIt<DeleteMasterProductUseCase>().call(item.id);
    if (!mounted) return;
    result.fold(
      (_) => ref.read(masterCatalogAdminListProvider.notifier).refresh(),
      (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }

  String _statusLabel(MasterProductStatus status) => switch (status) {
    MasterProductStatus.pending => context.l10n.masterStatusPending,
    MasterProductStatus.approved => context.l10n.masterStatusApproved,
    MasterProductStatus.rejected => context.l10n.masterStatusRejected,
  };

  Color _statusColor(MasterProductStatus status) => switch (status) {
    MasterProductStatus.pending => BrandColors.of(context).accentText,
    MasterProductStatus.approved => AppColors.success,
    MasterProductStatus.rejected => Theme.of(context).colorScheme.error,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final listState = ref.watch(masterCatalogAdminListProvider);

    return DashPage(
      title: l10n.masterReviewTitle,
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.commonAdd,
        onPressed: () => _openForm(),
        child: const Icon(Icons.add_rounded),
      ),
      header: DashChoiceChips<MasterProductStatus?>(
        values: const [null, ...MasterProductStatus.values],
        selected: listState.valueOrNull?.query.status,
        label: (s) => s == null ? l10n.commonAll : _statusLabel(s),
        onSelected: (s) => ref.read(masterCatalogAdminListProvider.notifier).setStatus(s),
      ),
      body: listState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => DashEmptyState(
          icon: Icons.cloud_off_rounded,
          text: l10n.commonErrorWith('$error'),
          action: TextButton(
            onPressed: () => ref.invalidate(masterCatalogAdminListProvider),
            child: Text(l10n.commonRetry),
          ),
        ),
        data: (state) => RefreshIndicator(
          color: AppColors.onBrand,
          backgroundColor: AppColors.brandYellow,
          onRefresh: () => ref.read(masterCatalogAdminListProvider.notifier).refresh(),
          child: state.items.isEmpty
              ? DashEmptyState(icon: Icons.inventory_2_rounded, text: l10n.commonNothingFound)
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                  itemCount: state.items.length + (state.hasNext ? 1 : 0),
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    if (index >= state.items.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final item = state.items[index];
                    final pending = item.status == MasterProductStatus.pending;
                    return DashListCard(
                      dimmed: !item.isActive,
                      leading: DashThumb(url: item.primaryImageUrl, size: 52),
                      title: item.name,
                      subtitle: [
                        if (item.brand != null) item.brand!,
                        if (item.categoryName != null) item.categoryName!,
                      ].join(' · '),
                      // Pending entries get the review actions right on the row (no status
                      // tag: the buttons already say it's waiting).
                      trailing: pending
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _ReviewButton(
                                  icon: Icons.check_rounded,
                                  color: AppColors.success,
                                  tooltip: l10n.commonConfirm,
                                  onTap: () => _approve(item),
                                ),
                                const SizedBox(width: 8),
                                _ReviewButton(
                                  icon: Icons.close_rounded,
                                  color: Theme.of(context).colorScheme.error,
                                  tooltip: l10n.commonReject,
                                  onTap: () => _reject(item),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                DashTag(label: _statusLabel(item.status), color: _statusColor(item.status)),
                                DashMenuButton(
                                  items: [
                                    (
                                      value: 'edit',
                                      icon: Icons.edit_rounded,
                                      label: l10n.commonEdit,
                                      destructive: false,
                                    ),
                                    (
                                      value: 'delete',
                                      icon: Icons.delete_outline_rounded,
                                      label: l10n.commonDelete,
                                      destructive: true,
                                    ),
                                  ],
                                  onSelected: (action) => action == 'edit' ? _openForm(editing: item) : _delete(item),
                                ),
                              ],
                            ),
                      onTap: () => _openForm(editing: item),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

/// Round tinted approve / reject button on a pending row.
class _ReviewButton extends StatelessWidget {
  const _ReviewButton({required this.icon, required this.color, required this.tooltip, required this.onTap});

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.12),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Tooltip(
          message: tooltip,
          child: SizedBox(width: 40, height: 40, child: Icon(icon, color: color, size: 22)),
        ),
      ),
    );
  }
}
