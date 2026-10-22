import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/features/categories/domain/entities/category.dart';
import 'package:bsmart/features/categories/domain/usecases/delete_category_usecase.dart';
import 'package:bsmart/features/categories/presentation/providers/categories_admin_list_notifier.dart';
import 'package:bsmart/features/categories/presentation/providers/categories_provider.dart';
import 'package:bsmart/features/categories/presentation/screens/category_form_screen.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// SUPER_ADMIN-only category management — full CRUD, unlike
/// `CategoryPickerField`'s read-only tree browse. One card per root category
/// with its subcategories indented inside (the backend enforces a max
/// 2-level depth).
class CategoriesAdminListScreen extends ConsumerWidget {
  const CategoriesAdminListScreen({super.key});

  Future<void> _openForm(BuildContext context, WidgetRef ref, {Category? editing}) async {
    final saved = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => CategoryFormScreen(editingCategory: editing)));
    if (saved == true) {
      ref.read(categoriesAdminListProvider.notifier).refresh();
      ref.invalidate(categoriesProvider);
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Category category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.categoriesDeleteTitle),
        content: Text(context.l10n.commonDeleteWithDependentsConfirm(category.name)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(context.l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(context.l10n.commonDelete)),
        ],
      ),
    );
    if (confirmed != true) return;
    final result = await getIt<DeleteCategoryUseCase>().call(category.id);
    if (!context.mounted) return;
    result.fold((_) {
      ref.read(categoriesAdminListProvider.notifier).refresh();
      ref.invalidate(categoriesProvider);
    }, (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final categoriesAsync = ref.watch(categoriesAdminListProvider);

    return DashPage(
      title: l10n.categoriesTitle,
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.commonAdd,
        onPressed: () => _openForm(context, ref),
        child: const Icon(Icons.add_rounded),
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => DashEmptyState(
          icon: Icons.cloud_off_rounded,
          text: l10n.commonErrorWith('$error'),
          action: TextButton(
            onPressed: () => ref.invalidate(categoriesAdminListProvider),
            child: Text(l10n.commonRetry),
          ),
        ),
        data: (categories) {
          // One card per root category with its own children inside, sorted
          // by sortOrder within each level. (A flat "roots, then every child"
          // order once dumped all children together regardless of their
          // root — caught live.)
          final roots = categories.where((c) => c.isRoot).toList()..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
          final childrenByParent = <String, List<Category>>{};
          for (final c in categories.where((c) => !c.isRoot)) {
            (childrenByParent[c.parentId!] ??= []).add(c);
          }
          for (final children in childrenByParent.values) {
            children.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
          }
          final rootIds = roots.map((r) => r.id).toSet();
          // A child whose parent isn't in the fetched page still shows, on its own.
          final orphanedChildren = childrenByParent.entries
              .where((e) => !rootIds.contains(e.key))
              .expand((e) => e.value);
          final groups = <(Category, List<Category>)>[
            for (final root in roots) (root, childrenByParent[root.id] ?? const []),
            for (final orphan in orphanedChildren) (orphan, const []),
          ];
          return RefreshIndicator(
            color: AppColors.onBrand,
            backgroundColor: AppColors.brandYellow,
            onRefresh: () => ref.read(categoriesAdminListProvider.notifier).refresh(),
            child: groups.isEmpty
                ? DashEmptyState(icon: Icons.category_rounded, text: l10n.categoriesNotFound)
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                    itemCount: groups.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final (root, children) = groups[index];
                      return DashCard(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          children: [
                            _CategoryRow(
                              category: root,
                              onEdit: () => _openForm(context, ref, editing: root),
                              onDelete: () => _delete(context, ref, root),
                            ),
                            for (final child in children)
                              _CategoryRow(
                                category: child,
                                nested: true,
                                onEdit: () => _openForm(context, ref, editing: child),
                                onDelete: () => _delete(context, ref, child),
                              ),
                          ],
                        ),
                      ).animate().fadeIn(delay: (25 * (index % 12)).ms, duration: AppMotion.standard);
                    },
                  ),
          );
        },
      ),
    );
  }
}

/// One category line inside its root's card; subcategories are indented
/// with a smaller thumbnail.
class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.category, required this.onEdit, required this.onDelete, this.nested = false});

  final Category category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool nested;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final subtitle = [
      if (!nested && !category.isRoot && category.parentName != null) category.parentName!,
      if (!category.isActive) l10n.commonInactiveShort,
    ].join(' · ');
    return InkWell(
      onTap: onEdit,
      child: Opacity(
        opacity: category.isActive ? 1 : 0.55,
        child: Padding(
          padding: EdgeInsets.fromLTRB(nested ? 34 : 12, 8, 4, 8),
          child: Row(
            children: [
              if (nested) ...[
                Icon(Icons.subdirectory_arrow_right_rounded, size: 18, color: colors.textMuted),
                const SizedBox(width: 6),
              ],
              DashThumb(
                url: category.imageUrl,
                icon: nested ? Icons.label_rounded : Icons.category_rounded,
                size: nested ? 36 : 48,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: nested ? 14.5 : 16,
                        fontWeight: nested ? FontWeight.w700 : FontWeight.w800,
                      ),
                    ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        style: TextStyle(color: colors.textMuted, fontSize: 12.5, fontWeight: FontWeight.w600),
                      ),
                  ],
                ),
              ),
              DashMenuButton(
                items: [
                  (value: 'edit', icon: Icons.edit_rounded, label: l10n.commonEdit, destructive: false),
                  (value: 'delete', icon: Icons.delete_outline_rounded, label: l10n.commonDelete, destructive: true),
                ],
                onSelected: (action) => action == 'edit' ? onEdit() : onDelete(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
