import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/features/categories/domain/entities/category.dart';
import 'package:bsmart/features/categories/domain/usecases/delete_category_usecase.dart';
import 'package:bsmart/features/categories/presentation/providers/categories_admin_list_notifier.dart';
import 'package:bsmart/features/categories/presentation/providers/categories_provider.dart';
import 'package:bsmart/features/categories/presentation/screens/category_form_screen.dart';

/// SUPER_ADMIN-only category management — full CRUD, unlike
/// `CategoryPickerField`'s read-only tree browse. Shown flat with an indent
/// for subcategories, since the backend enforces a max 2-level depth.
class CategoriesAdminListScreen extends ConsumerWidget {
  const CategoriesAdminListScreen({super.key});

  Future<void> _openForm(BuildContext context, WidgetRef ref, {Category? editing}) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => CategoryFormScreen(editingCategory: editing)),
    );
    if (saved == true) {
      ref.read(categoriesAdminListProvider.notifier).refresh();
      ref.invalidate(categoriesProvider);
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Category category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Kategoriyani o'chirish"),
        content: Text('${category.name} oʻchirilsinmi? Unga bogʻliq mahsulotlar boʻlsa, xatolik qaytadi.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Bekor qilish')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text("O'chirish")),
        ],
      ),
    );
    if (confirmed != true) return;
    final result = await getIt<DeleteCategoryUseCase>().call(category.id);
    if (!context.mounted) return;
    result.fold(
      (_) {
        ref.read(categoriesAdminListProvider.notifier).refresh();
        ref.invalidate(categoriesProvider);
      },
      (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesAdminListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Kategoriyalar')),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Xatolik: $error')),
        data: (categories) {
          if (categories.isEmpty) return const Center(child: Text('Kategoriyalar topilmadi'));
          // Group each root immediately followed by its own children (sorted
          // within each level by sortOrder) — a plain "roots first, then a
          // second flat block of every child" sort (an earlier version of
          // this) technically showed the right parent name as each child's
          // subtitle, but visually dumped all children together regardless
          // of which root they belonged to, which read as unsorted/broken
          // for any DB with more than one root category — caught live.
          final roots = categories.where((c) => c.isRoot).toList()
            ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
          final childrenByParent = <String, List<Category>>{};
          for (final c in categories.where((c) => !c.isRoot)) {
            (childrenByParent[c.parentId!] ??= []).add(c);
          }
          for (final children in childrenByParent.values) {
            children.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
          }
          final rootIds = roots.map((r) => r.id).toSet();
          final orphanedChildren = childrenByParent.entries
              .where((e) => !rootIds.contains(e.key))
              .expand((e) => e.value);
          final sorted = <Category>[
            for (final root in roots) ...[root, ...?childrenByParent[root.id]],
            ...orphanedChildren,
          ];
          return RefreshIndicator(
            onRefresh: () => ref.read(categoriesAdminListProvider.notifier).refresh(),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: sorted.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final category = sorted[index];
                return ListTile(
                  contentPadding: EdgeInsets.only(left: category.isRoot ? 16 : 40, right: 16),
                  leading: Icon(category.isRoot ? Icons.category_outlined : Icons.subdirectory_arrow_right),
                  title: Text(category.name),
                  subtitle: Text([
                    if (!category.isRoot && category.parentName != null) category.parentName!,
                    if (!category.isActive) 'Faolsiz',
                  ].join(' • ')),
                  trailing: PopupMenuButton<String>(
                    onSelected: (action) {
                      switch (action) {
                        case 'edit':
                          _openForm(context, ref, editing: category);
                        case 'delete':
                          _delete(context, ref, category);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Tahrirlash')),
                      const PopupMenuItem(value: 'delete', child: Text("O'chirish")),
                    ],
                  ),
                  onTap: () => _openForm(context, ref, editing: category),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}
