import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/features/crm/domain/crm_due.dart';
import 'package:bsmart/features/crm/domain/entities/crm_driver.dart';
import 'package:bsmart/features/crm/presentation/providers/crm_providers.dart';
import 'package:bsmart/features/crm/presentation/screens/crm_driver_form_screen.dart';
import 'package:bsmart/features/crm/presentation/widgets/crm_widgets.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

enum _ActiveFilter { all, active, inactive }

/// CRM drivers of the active store (auto-parts businesses, Optom_Savdo "CRM"): search by name,
/// phone or plate, all/active/inactive. A row opens the driver.
class CrmDriversListScreen extends ConsumerStatefulWidget {
  const CrmDriversListScreen({super.key});

  @override
  ConsumerState<CrmDriversListScreen> createState() => _CrmDriversListScreenState();
}

class _CrmDriversListScreenState extends ConsumerState<CrmDriversListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        ref.read(crmDriversListProvider.notifier).loadMore();
      }
    });
    // The provider is app-wide and keeps its filters; show them again.
    _searchController.text = ref.read(crmDriversListProvider).valueOrNull?.query.search ?? '';
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => ref.read(crmDriversListProvider.notifier).search(value));
  }

  Future<void> _create() async {
    final saved = await Navigator.of(context).push<CrmDriver>(
      MaterialPageRoute(builder: (_) => const CrmDriverFormScreen()),
    );
    if (saved == null || !mounted) return;
    ref.read(crmDriversListProvider.notifier).refresh();
    context.push(RouteNames.crmDriverDetail(saved.id));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final listState = ref.watch(crmDriversListProvider);
    final activeOnly = listState.valueOrNull?.query.activeOnly;
    final filter = activeOnly == null ? _ActiveFilter.all : (activeOnly ? _ActiveFilter.active : _ActiveFilter.inactive);

    return DashPage(
      title: l10n.navCrmDrivers,
      actions: [
        DashRoundButton(
          icon: Icons.notifications_active_outlined,
          tooltip: l10n.navCrmReminders,
          onTap: () => context.push(RouteNames.crmReminders),
        ),
      ],
      header: Column(
        children: [
          DashSearchField(controller: _searchController, hint: l10n.crmDriversSearchHint, onChanged: _onSearchChanged),
          const SizedBox(height: 10),
          DashChoiceChips<_ActiveFilter>(
            values: _ActiveFilter.values,
            selected: filter,
            label: (f) => switch (f) {
              _ActiveFilter.all => l10n.commonAll,
              _ActiveFilter.active => l10n.commonActive,
              _ActiveFilter.inactive => l10n.commonInactive,
            },
            onSelected: (f) => ref.read(crmDriversListProvider.notifier).setActiveFilter(switch (f) {
              _ActiveFilter.all => null,
              _ActiveFilter.active => true,
              _ActiveFilter.inactive => false,
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.crmAddDriver,
        onPressed: _create,
        child: const Icon(Icons.person_add_alt_1_rounded),
      ),
      body: listState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => DashEmptyState(
          icon: Icons.lock_outline_rounded,
          text: crmErrorText(context, error),
          action: TextButton(onPressed: () => ref.invalidate(crmDriversListProvider), child: Text(l10n.commonRetry)),
        ),
        data: (state) => RefreshIndicator(
          color: AppColors.onBrand,
          backgroundColor: AppColors.brandYellow,
          onRefresh: () => ref.read(crmDriversListProvider.notifier).refresh(),
          child: state.items.isEmpty
              ? DashEmptyState(
                  icon: Icons.directions_car_rounded,
                  text: (state.query.search?.isNotEmpty ?? false) ? l10n.commonNothingFound : l10n.crmDriversEmpty,
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                  itemCount: state.items.length + (state.hasNext ? 1 : 0),
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    if (index >= state.items.length) {
                      return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
                    }
                    final driver = state.items[index];
                    return DashListCard(
                      dimmed: !driver.isActive,
                      leading: DriverPhoto(name: driver.fullName, url: driver.imageUrl, active: driver.isActive),
                      title: driver.fullName,
                      subtitle: [
                        driver.phone,
                        for (final v in driver.vehicles) '${formatPlate(v.plateNumber)} ${v.model}',
                      ].join(' · '),
                      trailing: driver.isActive
                          ? const Icon(Icons.chevron_right_rounded)
                          : DashTag(label: l10n.commonInactive, color: Theme.of(context).colorScheme.error),
                      onTap: () => context.push(RouteNames.crmDriverDetail(driver.id)),
                    ).animate().fadeIn(delay: (25 * (index % 12)).ms, duration: AppMotion.standard);
                  },
                ),
        ),
      ),
    );
  }
}
