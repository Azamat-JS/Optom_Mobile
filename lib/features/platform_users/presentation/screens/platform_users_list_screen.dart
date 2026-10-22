import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/enums/business_type.dart';
import 'package:bsmart/core/enums/user_role.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/features/platform_users/domain/entities/platform_user.dart';
import 'package:bsmart/features/platform_users/domain/usecases/delete_platform_user_usecase.dart';
import 'package:bsmart/features/platform_users/domain/usecases/set_platform_user_active_usecase.dart';
import 'package:bsmart/features/platform_users/presentation/providers/platform_users_list_notifier.dart';
import 'package:bsmart/features/platform_users/presentation/screens/platform_user_form_screen.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

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
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // The list provider is app-wide and keeps its filters after this screen
    // closes; show the search again instead of an empty field over a filtered list.
    _searchController.text = ref.read(platformUsersListProvider).valueOrNull?.query.search ?? '';
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(platformUsersListProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(platformUsersListProvider.notifier).search(value.trim());
    });
  }

  Future<void> _openForm({PlatformUser? editing}) async {
    final saved = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => PlatformUserFormScreen(editingUser: editing)));
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
        title: Text(context.l10n.usersDeleteTitle),
        content: Text(context.l10n.usersDeleteConfirm(user.fullName)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(context.l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(context.l10n.commonDelete)),
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
    final l10n = context.l10n;
    final listState = ref.watch(platformUsersListProvider);
    final query = listState.valueOrNull?.query;

    return DashPage(
      title: l10n.navUsers,
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.commonAdd,
        onPressed: () => _openForm(),
        child: const Icon(Icons.person_add_alt_1_rounded),
      ),
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DashSearchField(controller: _searchController, hint: l10n.usersSearchHint, onChanged: _onSearchChanged),
          const SizedBox(height: 10),
          DashChoiceChips<UserRole?>(
            values: const [null, ...UserRole.values],
            selected: query?.role,
            label: (r) => r?.label ?? l10n.commonAll,
            onSelected: (r) => ref.read(platformUsersListProvider.notifier).setRole(r),
          ),
          if (query?.role == UserRole.retailer) ...[
            const SizedBox(height: 8),
            DashChoiceChips<BusinessType?>(
              values: const [null, ...BusinessType.values],
              selected: query?.businessType,
              label: (t) => t?.label ?? l10n.commonAll,
              onSelected: (t) => ref.read(platformUsersListProvider.notifier).setBusinessType(t),
            ),
          ],
        ],
      ),
      body: listState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => DashEmptyState(
          icon: Icons.cloud_off_rounded,
          text: l10n.commonErrorWith('$error'),
          action: TextButton(onPressed: () => ref.invalidate(platformUsersListProvider), child: Text(l10n.commonRetry)),
        ),
        data: (state) => RefreshIndicator(
          color: AppColors.onBrand,
          backgroundColor: AppColors.brandYellow,
          onRefresh: () => ref.read(platformUsersListProvider.notifier).refresh(),
          child: state.items.isEmpty
              ? DashEmptyState(icon: Icons.groups_rounded, text: l10n.usersNotFound)
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
                    final user = state.items[index];
                    return DashListCard(
                      dimmed: !user.isActive,
                      leading: DashAvatar(name: user.firstName, active: user.isActive),
                      title: user.shopName?.isNotEmpty == true ? user.shopName! : user.fullName,
                      subtitle: [
                        user.phone,
                        user.role.label,
                        if (user.businessType != null) user.businessType!.label,
                        if (!user.isActive) l10n.commonInactiveShort,
                      ].join(' · '),
                      trailing: DashMenuButton(
                        items: [
                          (value: 'edit', icon: Icons.edit_rounded, label: l10n.commonEdit, destructive: false),
                          (
                            value: 'toggle',
                            icon: user.isActive ? Icons.block_rounded : Icons.check_circle_rounded,
                            label: user.isActive ? l10n.commonDeactivate : l10n.commonActivate,
                            destructive: false,
                          ),
                          (
                            value: 'delete',
                            icon: Icons.delete_outline_rounded,
                            label: l10n.commonDelete,
                            destructive: true,
                          ),
                        ],
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
                      ),
                      onTap: () => _openForm(editing: user),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
