import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/enums/product_unit.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/features/categories/presentation/providers/categories_provider.dart';
import 'package:bsmart/features/master_catalog/domain/entities/master_product.dart';
import 'package:bsmart/features/master_catalog/domain/entities/master_product_write_params.dart';
import 'package:bsmart/features/master_catalog/domain/usecases/create_master_product_usecase.dart';
import 'package:bsmart/features/master_catalog/domain/usecases/get_master_product_usecase.dart';
import 'package:bsmart/features/master_catalog/domain/usecases/remove_master_product_image_usecase.dart';
import 'package:bsmart/features/master_catalog/domain/usecases/update_master_product_usecase.dart';
import 'package:bsmart/features/master_catalog/domain/usecases/upload_master_product_image_usecase.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// Create/edit a shared catalog entry — SUPER_ADMIN only. Image
/// upload/delete only becomes available once the entry exists (create
/// first, then manage images), same two-step flow as
/// `CategoryFormScreen`/`ProductFormScreen`.
class MasterProductFormScreen extends ConsumerStatefulWidget {
  const MasterProductFormScreen({super.key, this.editingProduct});

  final MasterProduct? editingProduct;

  @override
  ConsumerState<MasterProductFormScreen> createState() => _MasterProductFormScreenState();
}

class _MasterProductFormScreenState extends ConsumerState<MasterProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.editingProduct?.name);
  late final _descriptionController = TextEditingController(text: widget.editingProduct?.description);
  late final _brandController = TextEditingController(text: widget.editingProduct?.brand);
  late final _barcodeController = TextEditingController(text: widget.editingProduct?.barcode);
  String? _categoryId;
  ProductUnit? _unit;
  bool _isActive = true;
  bool _isSaving = false;
  bool _isUploadingImage = false;
  String? _errorMessage;
  MasterProduct? _current;

  bool get _isEditing => widget.editingProduct != null;

  @override
  void initState() {
    super.initState();
    _current = widget.editingProduct;
    _categoryId = widget.editingProduct?.categoryId;
    _unit = widget.editingProduct?.unit;
    _isActive = widget.editingProduct?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _brandController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final targetId = _current?.id;
    if (targetId == null) return;
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;

    setState(() => _isUploadingImage = true);
    final result = await getIt<UploadMasterProductImageUseCase>().call(
      targetId,
      filePath: picked.path,
      isPrimary: _current?.images.isEmpty ?? true,
    );
    if (!mounted) return;
    if (result.isOk) {
      final refreshed = await getIt<GetMasterProductUseCase>().call(targetId);
      if (!mounted) return;
      setState(() {
        _isUploadingImage = false;
        refreshed.fold((p) => _current = p, (failure) => _errorMessage = failure.message);
      });
    } else {
      setState(() {
        _isUploadingImage = false;
        result.fold((_) {}, (failure) => _errorMessage = failure.message);
      });
    }
  }

  Future<void> _deleteImage(String imageId) async {
    final targetId = _current?.id;
    if (targetId == null) return;
    setState(() => _isUploadingImage = true);
    final result = await getIt<RemoveMasterProductImageUseCase>().call(targetId, imageId);
    if (!mounted) return;
    if (result.isOk) {
      final refreshed = await getIt<GetMasterProductUseCase>().call(targetId);
      if (!mounted) return;
      setState(() {
        _isUploadingImage = false;
        refreshed.fold((p) => _current = p, (failure) => _errorMessage = failure.message);
      });
    } else {
      setState(() {
        _isUploadingImage = false;
        result.fold((_) {}, (failure) => _errorMessage = failure.message);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final result = _isEditing
        ? await getIt<UpdateMasterProductUseCase>().call(
            widget.editingProduct!.id,
            UpdateMasterProductParams(
              name: _nameController.text.trim(),
              description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
              brand: _brandController.text.trim().isEmpty ? null : _brandController.text.trim(),
              barcode: _barcodeController.text.trim().isEmpty ? null : _barcodeController.text.trim(),
              categoryId: _categoryId,
              unit: _unit,
              isActive: _isActive,
            ),
          )
        : await getIt<CreateMasterProductUseCase>().call(
            CreateMasterProductParams(
              name: _nameController.text.trim(),
              description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
              brand: _brandController.text.trim().isEmpty ? null : _brandController.text.trim(),
              barcode: _barcodeController.text.trim().isEmpty ? null : _barcodeController.text.trim(),
              categoryId: _categoryId,
              unit: _unit,
              isActive: _isActive,
            ),
          );
    if (!mounted) return;
    result.fold(
      (product) {
        if (_isEditing) {
          Navigator.of(context).pop(true);
        } else {
          setState(() {
            _isSaving = false;
            _current = product;
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
    final categories = (ref.watch(categoriesProvider).valueOrNull ?? const [])
        .expand((c) => [c, ...c.children])
        .toList();
    final createdButNotEditing = !_isEditing && _current != null;

    return DashPage(
      title: _isEditing ? l10n.masterEditTitle : l10n.masterNewTitle,
      // After creating, the form stays open for the photos; the button then just closes it.
      bottomBar: DashBottomButton(
        label: createdButNotEditing ? l10n.commonDone : l10n.commonSave,
        busy: _isSaving,
        onPressed: createdButNotEditing ? () => Navigator.of(context).pop(true) : _submit,
      ),
      body: DashFormTheme(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              if (_current != null) ...[_buildImageStrip(_current!), const SizedBox(height: 4)],
              DashSectionTitle(l10n.formBasics, padding: const EdgeInsets.fromLTRB(4, 8, 4, 10)),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: l10n.commonNameRequired),
                validator: (v) => (v == null || v.trim().isEmpty) ? l10n.commonNameMissing : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _brandController,
                decoration: InputDecoration(labelText: l10n.commonBrand),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: l10n.commonDescription),
                maxLines: 3,
              ),
              DashSectionTitle(l10n.formExtra),
              TextFormField(
                controller: _barcodeController,
                decoration: InputDecoration(
                  labelText: l10n.commonBarcode,
                  prefixIcon: const Icon(Icons.qr_code_rounded),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue: _categoryId,
                isExpanded: true,
                decoration: InputDecoration(labelText: l10n.commonCategory),
                items: [
                  DropdownMenuItem(value: null, child: Text(l10n.commonNotSelectedDash)),
                  for (final c in categories) DropdownMenuItem(value: c.id, child: Text(c.name)),
                ],
                onChanged: (value) => setState(() => _categoryId = value),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ProductUnit?>(
                initialValue: _unit,
                decoration: InputDecoration(labelText: l10n.commonUnit),
                items: [
                  DropdownMenuItem(value: null, child: Text(l10n.commonNotSelectedDash)),
                  for (final u in ProductUnit.values) DropdownMenuItem(value: u, child: Text(u.label)),
                ],
                onChanged: (value) => setState(() => _unit = value),
              ),
              const SizedBox(height: 12),
              DashCard(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: SwitchListTile(
                  title: Text(l10n.masterActiveVisible),
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

  /// Photos with a remove badge each, plus an add tile (same strip as the
  /// product detail screen).
  Widget _buildImageStrip(MasterProduct product) {
    final colors = BrandColors.of(context);
    return SizedBox(
      height: 104,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final image in product.images)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Stack(
                children: [
                  DashThumb(url: image.url, size: 104),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Material(
                      color: Colors.black54,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: _isUploadingImage ? null : () => _deleteImage(image.id),
                        child: Tooltip(
                          message: context.l10n.commonDelete,
                          child: const SizedBox(
                            width: 28,
                            height: 28,
                            child: Icon(Icons.close_rounded, size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Material(
            color: DashColors.card(context),
            borderRadius: BorderRadius.circular(28),
            child: InkWell(
              onTap: _isUploadingImage ? null : _pickImage,
              borderRadius: BorderRadius.circular(28),
              child: SizedBox(
                width: 104,
                height: 104,
                child: _isUploadingImage
                    ? const Center(child: CircularProgressIndicator())
                    : Icon(Icons.add_a_photo_rounded, color: colors.textSecondary, size: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
