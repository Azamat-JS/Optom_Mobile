import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/enums/product_unit.dart';
import 'package:bsmart/features/categories/presentation/providers/categories_provider.dart';
import 'package:bsmart/features/master_catalog/domain/entities/master_product.dart';
import 'package:bsmart/features/master_catalog/domain/entities/master_product_write_params.dart';
import 'package:bsmart/features/master_catalog/domain/usecases/create_master_product_usecase.dart';
import 'package:bsmart/features/master_catalog/domain/usecases/get_master_product_usecase.dart';
import 'package:bsmart/features/master_catalog/domain/usecases/remove_master_product_image_usecase.dart';
import 'package:bsmart/features/master_catalog/domain/usecases/update_master_product_usecase.dart';
import 'package:bsmart/features/master_catalog/domain/usecases/upload_master_product_image_usecase.dart';

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
    final categories = (ref.watch(categoriesProvider).valueOrNull ?? const [])
        .expand((c) => [c, ...c.children])
        .toList();
    final createdButNotEditing = !_isEditing && _current != null;

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Katalog yozuvini tahrirlash' : 'Yangi katalog yozuvi')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_current != null) ...[
              SizedBox(
                height: 90,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final image in _current!.images)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: image.url,
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 2,
                              right: 2,
                              child: GestureDetector(
                                onTap: _isUploadingImage ? null : () => _deleteImage(image.id),
                                child: const CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.black54,
                                  child: Icon(Icons.close, size: 14, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    GestureDetector(
                      onTap: _isUploadingImage ? null : _pickImage,
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).colorScheme.outline),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _isUploadingImage
                            ? const Center(child: CircularProgressIndicator())
                            : const Icon(Icons.add_a_photo_outlined),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nomi *', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Nomini kiriting' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _brandController,
              decoration: const InputDecoration(labelText: 'Brend', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Tavsif', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _barcodeController,
              decoration: const InputDecoration(labelText: 'Shtrix-kod', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: _categoryId,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Kategoriya', border: OutlineInputBorder()),
              items: [
                const DropdownMenuItem(value: null, child: Text('— Tanlanmagan —')),
                for (final c in categories) DropdownMenuItem(value: c.id, child: Text(c.name)),
              ],
              onChanged: (value) => setState(() => _categoryId = value),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ProductUnit?>(
              initialValue: _unit,
              decoration: const InputDecoration(labelText: "O'lchov birligi", border: OutlineInputBorder()),
              items: [
                const DropdownMenuItem(value: null, child: Text('— Tanlanmagan —')),
                for (final u in ProductUnit.values) DropdownMenuItem(value: u, child: Text(u.name)),
              ],
              onChanged: (value) => setState(() => _unit = value),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Faol (katalogda ko\'rinadi)'),
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _isSaving
                  ? null
                  : (createdButNotEditing ? () => Navigator.of(context).pop(true) : _submit),
              child: _isSaving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(createdButNotEditing ? 'Tayyor' : 'Saqlash'),
            ),
          ],
        ),
      ),
    );
  }
}
