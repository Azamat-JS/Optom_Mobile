import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/enums/master_product_status.dart';
import 'package:bsmart/features/master_catalog/domain/entities/master_product.dart';
import 'package:bsmart/features/master_catalog/domain/usecases/approve_master_product_usecase.dart';
import 'package:bsmart/features/master_catalog/domain/usecases/delete_master_product_usecase.dart';
import 'package:bsmart/features/master_catalog/domain/usecases/reject_master_product_usecase.dart';
import 'package:bsmart/features/master_catalog/presentation/providers/master_catalog_admin_list_notifier.dart';
import 'package:bsmart/features/master_catalog/presentation/screens/master_product_form_screen.dart';

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
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => MasterProductFormScreen(editingProduct: editing)),
    );
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
        title: const Text('Rad etish'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Sababi (ixtiyoriy)', border: OutlineInputBorder()),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Bekor qilish')),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Rad etish'),
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
        title: const Text("Katalog yozuvini o'chirish"),
        content: Text('${item.name} oʻchirilsinmi? Unga bogʻliq mahsulotlar boʻlsa, xatolik qaytadi.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Bekor qilish')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text("O'chirish")),
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
        MasterProductStatus.pending => 'Kutilmoqda',
        MasterProductStatus.approved => 'Tasdiqlangan',
        MasterProductStatus.rejected => 'Rad etilgan',
      };

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(masterCatalogAdminListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Katalog nazorati')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('Barchasi'),
                    selected: listState.valueOrNull?.query.status == null,
                    onSelected: (_) => ref.read(masterCatalogAdminListProvider.notifier).setStatus(null),
                  ),
                  const SizedBox(width: 8),
                  for (final status in MasterProductStatus.values) ...[
                    ChoiceChip(
                      label: Text(_statusLabel(status)),
                      selected: listState.valueOrNull?.query.status == status,
                      onSelected: (_) => ref.read(masterCatalogAdminListProvider.notifier).setStatus(status),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
          ),
          Expanded(
            child: listState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Xatolik: $error')),
              data: (state) {
                if (state.items.isEmpty) return const Center(child: Text('Hech narsa topilmadi'));
                return RefreshIndicator(
                  onRefresh: () => ref.read(masterCatalogAdminListProvider.notifier).refresh(),
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: _scrollController,
                    itemCount: state.items.length + (state.hasNext ? 1 : 0),
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      if (index >= state.items.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final item = state.items[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              item.primaryImageUrl != null ? CachedNetworkImageProvider(item.primaryImageUrl!) : null,
                          child: item.primaryImageUrl == null ? const Icon(Icons.inventory_2_outlined) : null,
                        ),
                        title: Text(item.name),
                        subtitle: Text(
                          [
                            if (item.brand != null) item.brand!,
                            if (item.categoryName != null) item.categoryName!,
                            _statusLabel(item.status),
                          ].join(' • '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: item.status == MasterProductStatus.pending
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.check_circle_outline),
                                    tooltip: 'Tasdiqlash',
                                    onPressed: () => _approve(item),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.cancel_outlined),
                                    tooltip: 'Rad etish',
                                    onPressed: () => _reject(item),
                                  ),
                                ],
                              )
                            : PopupMenuButton<String>(
                                onSelected: (action) {
                                  switch (action) {
                                    case 'edit':
                                      _openForm(editing: item);
                                    case 'delete':
                                      _delete(item);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(value: 'edit', child: Text('Tahrirlash')),
                                  const PopupMenuItem(value: 'delete', child: Text("O'chirish")),
                                ],
                              ),
                        onTap: () => _openForm(editing: item),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
