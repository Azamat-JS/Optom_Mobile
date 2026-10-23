import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/features/categories/domain/entities/category.dart';
import 'package:bsmart/features/categories/presentation/providers/categories_provider.dart';

/// Leaf categories only — a root category that already has subcategories is
/// a grouping node, not itself selectable (mirrors the reference web app's
/// `CategorySelectField` rule exactly: products always file under the most
/// specific category available).
List<Category> _leafCategories(List<Category> tree) {
  final leaves = <Category>[];
  for (final root in tree) {
    if (root.children.isEmpty) {
      leaves.add(root);
    } else {
      leaves.addAll(root.children);
    }
  }
  return leaves;
}

String _displayLabel(Category category) =>
    category.parentName != null ? '${category.parentName} — ${category.name}' : category.name;

/// A reactive_forms-bound category picker: tapping it opens a searchable
/// bottom sheet of leaf categories. Stores the selected category's id as the
/// form control's value.
class CategoryPickerField extends ConsumerWidget {
  const CategoryPickerField({super.key, required this.formControlName, this.labelText});

  final String formControlName;

  /// Defaults to the localized "Category".
  final String? labelText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return ReactiveFormField<String, String>(
      formControlName: formControlName,
      builder: (field) {
        final selectedId = field.value;
        final leaves = _leafCategories(categoriesAsync.valueOrNull ?? const []);
        Category? selected;
        for (final c in leaves) {
          if (c.id == selectedId) {
            selected = c;
            break;
          }
        }
        final label = selected == null ? null : _displayLabel(selected);

        return InkWell(
          onTap: categoriesAsync.isLoading
              ? null
              : () async {
                  final tree = categoriesAsync.valueOrNull ?? const [];
                  final picked = await showModalBottomSheet<Category>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => _CategoryPickerSheet(categories: _leafCategories(tree), selectedId: selectedId),
                  );
                  if (picked != null) field.control.value = picked.id;
                },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: labelText ?? context.l10n.commonCategory,
              suffixIcon: const Icon(Icons.expand_more_rounded),
              errorText: field.errorText,
            ),
            child: categoriesAsync.isLoading
                ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(
                    label ?? context.l10n.commonNotSelected,
                    style: label == null ? TextStyle(color: Theme.of(context).hintColor) : null,
                  ),
          ),
        );
      },
    );
  }
}

class _CategoryPickerSheet extends StatefulWidget {
  const _CategoryPickerSheet({required this.categories, this.selectedId});

  final List<Category> categories;
  final String? selectedId;

  @override
  State<_CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends State<_CategoryPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final filtered = _query.isEmpty
        ? widget.categories
        : widget.categories.where((c) => _displayLabel(c).toLowerCase().contains(_query.toLowerCase())).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.categoriesPickerTitle,
                  style: TextStyle(color: colors.textPrimary, fontSize: 20, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: l10n.commonSearchHint,
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: colors.field,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        l10n.categoriesPickerNotFound,
                        style: TextStyle(color: colors.textMuted, fontWeight: FontWeight.w600),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final category = filtered[index];
                        final selected = category.id == widget.selectedId;
                        return ListTile(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          selected: selected,
                          selectedTileColor: AppColors.brandYellow.withValues(alpha: 0.14),
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: selected ? AppColors.brandYellow : colors.field,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.category_rounded,
                              size: 20,
                              color: selected ? AppColors.onBrand : colors.textSecondary,
                            ),
                          ),
                          title: Text(
                            category.name,
                            style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w700),
                          ),
                          subtitle: category.parentName != null
                              ? Text(category.parentName!, style: TextStyle(color: colors.textMuted))
                              : null,
                          trailing: selected ? Icon(Icons.check_circle_rounded, color: colors.accentText) : null,
                          onTap: () => Navigator.of(context).pop(category),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
