import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/features/customers/domain/entities/customer.dart';
import 'package:bsmart/features/customers/presentation/providers/customers_list_notifier.dart';
import 'package:bsmart/features/customers/presentation/screens/customer_form_screen.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// Full customer roster with search, create, and deactivate — a plain
/// full-screen list (pushed from the dashboard or picked from POS's
/// checkout sheet, see `CustomerPickerSheet`).
class CustomersListScreen extends ConsumerStatefulWidget {
  const CustomersListScreen({super.key});

  @override
  ConsumerState<CustomersListScreen> createState() => _CustomersListScreenState();
}

class _CustomersListScreenState extends ConsumerState<CustomersListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(customersListProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(customersListProvider.notifier).search(value);
    });
  }

  Future<void> _openForm({Customer? editing}) async {
    final saved = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => CustomerFormScreen(editingCustomer: editing)));
    if (saved == true) ref.read(customersListProvider.notifier).refresh();
  }

  Future<void> _deactivate(Customer customer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.customersDeactivateTitle),
        content: Text(context.l10n.customersDeactivateConfirm(customer.fullName)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(context.l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(context.l10n.commonDeactivate)),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(customersListProvider.notifier).deactivate(customer.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.commonErrorWith('$e'))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final listState = ref.watch(customersListProvider);

    return DashPage(
      title: l10n.customersTitle,
      header: DashSearchField(
        controller: _searchController,
        hint: l10n.customersSearchHint,
        onChanged: _onSearchChanged,
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.customersNewTitle,
        onPressed: () => _openForm(),
        child: const Icon(Icons.person_add_alt_1_rounded),
      ),
      body: listState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => DashEmptyState(
          icon: Icons.cloud_off_rounded,
          text: l10n.commonErrorWith('$error'),
          action: TextButton(onPressed: () => ref.invalidate(customersListProvider), child: Text(l10n.commonRetry)),
        ),
        data: (state) => RefreshIndicator(
          color: AppColors.onBrand,
          backgroundColor: AppColors.brandYellow,
          onRefresh: () => ref.read(customersListProvider.notifier).refresh(),
          child: state.items.isEmpty
              ? DashEmptyState(icon: Icons.groups_rounded, text: l10n.customersNotFound)
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
                    final customer = state.items[index];
                    return DashListCard(
                      dimmed: !customer.isActive,
                      leading: Container(
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: customer.isActive ? AppColors.brandYellow : DashColors.inset(context),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          customer.firstName.characters.firstOrNull?.toUpperCase() ?? '?',
                          style: TextStyle(
                            color: customer.isActive ? AppColors.onBrand : colors.textSecondary,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      title: customer.fullName,
                      subtitle: [
                        customer.phone ?? '—',
                        if (customer.address != null && customer.address!.isNotEmpty) customer.address!,
                      ].join(' · '),
                      trailing: customer.isActive
                          ? IconButton(
                              icon: Icon(Icons.block_rounded, color: colors.textMuted),
                              tooltip: l10n.commonDeactivate,
                              onPressed: () => _deactivate(customer),
                            )
                          : DashTag(label: l10n.commonInactive, color: Theme.of(context).colorScheme.error),
                      onTap: () => _openForm(editing: customer),
                    ).animate().fadeIn(delay: (25 * (index % 12)).ms, duration: AppMotion.standard);
                  },
                ),
        ),
      ),
    );
  }
}
