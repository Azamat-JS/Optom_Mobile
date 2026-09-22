import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';

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
  const CategoryPickerField({super.key, required this.formControlName, this.labelText = 'Kategoriya'});

  final String formControlName;
  final String labelText;

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
                    builder: (_) => _CategoryPickerSheet(categories: _leafCategories(tree)),
                  );
                  if (picked != null) field.control.value = picked.id;
                },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: labelText,
              border: const OutlineInputBorder(),
              suffixIcon: const Icon(Icons.arrow_drop_down),
              errorText: field.errorText,
            ),
            child: categoriesAsync.isLoading
                ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(label ?? 'Tanlanmagan', style: label == null ? TextStyle(color: Theme.of(context).hintColor) : null),
          ),
        );
      },
    );
  }
}

class _CategoryPickerSheet extends StatefulWidget {
  const _CategoryPickerSheet({required this.categories});

  final List<Category> categories;

  @override
  State<_CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends State<_CategoryPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = _query.isEmpty
        ? widget.categories
        : widget.categories
            .where((c) => _displayLabel(c).toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      expand: false,
      builder: (context, scrollController) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                autofocus: false,
                decoration: const InputDecoration(
                  hintText: 'Qidirish...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(child: Text('Kategoriya topilmadi'))
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final category = filtered[index];
                        return ListTile(
                          title: Text(category.name),
                          subtitle: category.parentName != null ? Text(category.parentName!) : null,
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
