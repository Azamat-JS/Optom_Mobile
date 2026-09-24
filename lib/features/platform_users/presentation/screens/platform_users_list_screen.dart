import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/enums/business_type.dart';
import 'package:bsmart/core/enums/user_role.dart';
import 'package:bsmart/features/platform_users/domain/entities/platform_user.dart';
import 'package:bsmart/features/platform_users/domain/usecases/delete_platform_user_usecase.dart';
import 'package:bsmart/features/platform_users/domain/usecases/set_platform_user_active_usecase.dart';
import 'package:bsmart/features/platform_users/presentation/providers/platform_users_list_notifier.dart';
import 'package:bsmart/features/platform_users/presentation/screens/platform_user_form_screen.dart';

/// The one generic, role/vertical-filterable user directory that backs
/// every SUPER_ADMIN "management" screen — wholesalers (`role: seller`),
/// each of the 8 retailer verticals (`role: retailer` + `businessType`),
/// customers (`role: customer`) — rather than 7+ separate screens, per the
/// plan's explicit "one generic BusinessType-filtered retailer-list screen"
/// design.
class PlatformUsersListScreen extends ConsumerStatefulWidget {
  const PlatformUsersListScreen({super.key});

  @override
  ConsumerState<PlatformUsersListScreen> createState() => _PlatformUsersListScreenState();
}

class _PlatformUsersListScreenState extends ConsumerState<PlatformUsersListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(platformUsersListProvider.notifier).loadMore();
    }
  }

  Future<void> _openForm({PlatformUser? editing}) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => PlatformUserFormScreen(editingUser: editing)),
    );
    if (saved == true) ref.read(platformUsersListProvider.notifier).refresh();
  }

  Future<void> _toggleActive(PlatformUser user) async {
    final result = await getIt<SetPlatformUserActiveUseCase>().call(user.id, !user.isActive);
    if (!mounted) return;
    result.fold(
      (_) => ref.read(platformUsersListProvider.notifier).refresh(),
      (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }

  Future<void> _delete(PlatformUser user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Foydalanuvchini o'chirish"),
        content: Text('${user.fullName} butunlay oʻchirilsinmi? Bu amalni bekor qilib boʻlmaydi.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Bekor qilish')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text("O'chirish")),
        ],
      ),
    );
    if (confirmed != true) return;
    final result = await getIt<DeletePlatformUserUseCase>().call(user.id);
    if (!mounted) return;
    result.fold(
      (_) => ref.read(platformUsersListProvider.notifier).refresh(),
      (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(platformUsersListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Foydalanuvchilar')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Ism, familiya yoki telefon...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (value) => ref.read(platformUsersListProvider.notifier).search(value),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<UserRole?>(
                    initialValue: listState.valueOrNull?.query.role,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Rol', isDense: true, border: OutlineInputBorder()),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Barchasi')),
                      for (final role in UserRole.values) DropdownMenuItem(value: role, child: Text(role.label)),
                    ],
                    onChanged: (value) => ref.read(platformUsersListProvider.notifier).setRole(value),
                  ),
                ),
                if (listState.valueOrNull?.query.role == UserRole.retailer) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<BusinessType?>(
                      initialValue: listState.valueOrNull?.query.businessType,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Yo\'nalish',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Barchasi')),
                        for (final type in BusinessType.values) DropdownMenuItem(value: type, child: Text(type.label)),
                      ],
                      onChanged: (value) => ref.read(platformUsersListProvider.notifier).setBusinessType(value),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: listState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Xatolik: $error')),
              data: (state) {
                if (state.items.isEmpty) {
                  return const Center(child: Text('Foydalanuvchilar topilmadi'));
                }
                return RefreshIndicator(
                  onRefresh: () => ref.read(platformUsersListProvider.notifier).refresh(),
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
                      final user = state.items[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: user.isActive ? null : Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: Text(user.firstName.isNotEmpty ? user.firstName.characters.first : '?'),
                        ),
                        title: Text(user.shopName?.isNotEmpty == true ? user.shopName! : user.fullName),
                        subtitle: Text(
                          [
                            user.phone,
                            user.role.label,
                            if (user.businessType != null) user.businessType!.label,
                            if (!user.isActive) 'Faolsiz',
                          ].join(' • '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (action) {
                            switch (action) {
                              case 'edit':
                                _openForm(editing: user);
                              case 'toggle':
                                _toggleActive(user);
                              case 'delete':
                                _delete(user);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'edit', child: Text('Tahrirlash')),
                            PopupMenuItem(
                              value: 'toggle',
                              child: Text(user.isActive ? 'Faolsizlantirish' : 'Faollashtirish'),
                            ),
                            const PopupMenuItem(value: 'delete', child: Text("O'chirish")),
                          ],
                        ),
                        onTap: () => _openForm(editing: user),
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
        child: const Icon(Icons.person_add_alt_1),
      ),
    );
  }
}
