import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/features/categories/domain/entities/category.dart';
import 'package:bsmart/features/categories/domain/entities/category_write_params.dart';
import 'package:bsmart/features/categories/domain/usecases/create_category_usecase.dart';
import 'package:bsmart/features/categories/domain/usecases/update_category_usecase.dart';
import 'package:bsmart/features/categories/domain/usecases/upload_category_image_usecase.dart';
import 'package:bsmart/features/categories/presentation/providers/categories_provider.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// Create/edit a category — SUPER_ADMIN only. The parent picker only offers
/// root categories (a subcategory can't itself have children, matching the
/// backend's max-2-level enforcement), and is hidden entirely when editing
/// an existing root category with children (changing it would orphan them
/// — the backend rejects that with a 400 "circular reference" style error
/// regardless, this just avoids the round-trip).
class CategoryFormScreen extends ConsumerStatefulWidget {
  const CategoryFormScreen({super.key, this.editingCategory});

  final Category? editingCategory;

  @override
  ConsumerState<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends ConsumerState<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.editingCategory?.name);
  late final _sortOrderController = TextEditingController(text: (widget.editingCategory?.sortOrder ?? 0).toString());
  String? _parentId;
  bool _isActive = true;
  bool _isSaving = false;
  bool _isUploadingImage = false;
  String? _errorMessage;
  String? _createdId;
  String? _imageUrl;

  bool get _isEditing => widget.editingCategory != null;

  @override
  void initState() {
    super.initState();
    _parentId = widget.editingCategory?.parentId;
    _isActive = widget.editingCategory?.isActive ?? true;
    _imageUrl = widget.editingCategory?.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final targetId = _createdId ?? widget.editingCategory?.id;
    if (targetId == null) return;
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;

    setState(() => _isUploadingImage = true);
    final result = await getIt<UploadCategoryImageUseCase>().call(targetId, filePath: picked.path);
    if (!mounted) return;
    setState(() {
      _isUploadingImage = false;
      result.fold((category) => _imageUrl = category.imageUrl, (failure) => _errorMessage = failure.message);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final sortOrder = int.tryParse(_sortOrderController.text.trim()) ?? 0;
    final result = _isEditing
        ? await getIt<UpdateCategoryUseCase>().call(
            widget.editingCategory!.id,
            UpdateCategoryParams(
              name: _nameController.text.trim(),
              sortOrder: sortOrder,
              isActive: _isActive,
              parentId: _parentId,
              clearParentId: _parentId == null,
            ),
          )
        : await getIt<CreateCategoryUseCase>().call(
            CreateCategoryParams(
              name: _nameController.text.trim(),
              sortOrder: sortOrder,
              isActive: _isActive,
              parentId: _parentId,
            ),
          );
    if (!mounted) return;
    result.fold(
      (category) {
        if (_isEditing) {
          Navigator.of(context).pop(true);
        } else {
          // Stay on the form so the image picker (which needs a real id)
          // becomes available, mirroring `ProductFormScreen`'s create-then-
          // upload-image flow.
          setState(() {
            _isSaving = false;
            _createdId = category.id;
          });
        }
      },
      (failure) => setState(() {
        _isSaving = false;
        _errorMessage = failure.message;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final rootCategories = (ref.watch(categoriesProvider).valueOrNull ?? const [])
        .where((c) => c.isRoot && c.id != widget.editingCategory?.id)
        .toList();
    final canPickImage = _isEditing || _createdId != null;

    return DashPage(
      title: _isEditing ? l10n.categoriesEditTitle : l10n.categoriesNewTitle,
      // After creating, the form stays open for the image; the button then just closes it.
      bottomBar: DashBottomButton(
        label: _createdId != null ? l10n.commonDone : l10n.commonSave,
        busy: _isSaving,
        onPressed: _createdId != null ? () => Navigator.of(context).pop(true) : _submit,
      ),
      body: DashFormTheme(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              if (canPickImage) ...[
                Center(
                  child: Material(
                    color: DashColors.card(context),
                    borderRadius: BorderRadius.circular(28),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: _isUploadingImage ? null : _pickImage,
                      child: SizedBox(
                        width: 104,
                        height: 104,
                        child: _isUploadingImage
                            ? const Center(child: CircularProgressIndicator())
                            : _imageUrl != null
                            ? CachedNetworkImage(imageUrl: _imageUrl!, fit: BoxFit.cover)
                            : Icon(Icons.add_a_photo_rounded, color: colors.textSecondary, size: 30),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: l10n.commonNameRequired),
                validator: (v) => (v == null || v.trim().isEmpty) ? l10n.commonNameMissing : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue: _parentId,
                decoration: InputDecoration(labelText: l10n.categoriesParent),
                items: [
                  DropdownMenuItem(value: null, child: Text(l10n.categoriesNoParent)),
                  for (final c in rootCategories) DropdownMenuItem(value: c.id, child: Text(c.name)),
                ],
                onChanged: (value) => setState(() => _parentId = value),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _sortOrderController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.categoriesSortOrder),
              ),
              const SizedBox(height: 12),
              DashCard(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: SwitchListTile(
                  title: Text(l10n.commonActive),
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
