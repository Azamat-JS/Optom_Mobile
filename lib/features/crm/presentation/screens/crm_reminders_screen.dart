import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/network/api_exception.dart';
import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/features/crm/domain/crm_due.dart';
import 'package:bsmart/features/crm/domain/entities/crm_params.dart';
import 'package:bsmart/features/crm/domain/entities/crm_visit.dart';
import 'package:bsmart/features/crm/presentation/providers/crm_providers.dart';
import 'package:bsmart/features/crm/presentation/widgets/crm_widgets.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// "Eslatmalar": the store's active service reminders, soonest first (overdue on top). Tabs for
/// overdue and due within 7 days carry counts; a card calls the driver, opens them, or closes /
/// moves the reminder.
class CrmRemindersScreen extends ConsumerStatefulWidget {
  const CrmRemindersScreen({super.key});

  @override
  ConsumerState<CrmRemindersScreen> createState() => _CrmRemindersScreenState();
}

class _CrmRemindersScreenState extends ConsumerState<CrmRemindersScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        ref.read(crmRemindersProvider.notifier).loadMore();
      }
    });
    _searchController.text = ref.read(crmRemindersProvider).valueOrNull?.query.search ?? '';
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _act(CrmReminder r, String action) async {
    final l10n = context.l10n;
    final notifier = ref.read(crmRemindersProvider.notifier);
    try {
      switch (action) {
        case 'done':
          await notifier.changeReminder(r.item.id, status: CrmItemStatus.done);
          _snack(l10n.crmReminderDone);
        case 'cancel':
          await notifier.changeReminder(r.item.id, status: CrmItemStatus.cancelled);
          _snack(l10n.crmReminderCancelled);
        case 'move':
          final first = asDay(r.serviceDate).add(const Duration(days: 1));
          final current = r.item.dueDate ?? first;
          final picked = await showDatePicker(
            context: context,
            initialDate: current.isBefore(first) ? first : current,
            firstDate: first,
            lastDate: first.add(const Duration(days: 365 * 3)),
          );
          if (picked == null) return;
          await notifier.changeReminder(r.item.id, dueDate: asDay(picked));
          _snack(l10n.crmDateMoved);
      }
    } on ApiException catch (e) {
      _snack(e.message);
    }
  }

  void _snack(String text) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final listState = ref.watch(crmRemindersProvider);
    final data = listState.valueOrNull;
    String tab(CrmReminderWhen w) => switch (w) {
          CrmReminderWhen.all => l10n.crmRemindersAll,
          CrmReminderWhen.overdue => '${l10n.crmRemindersOverdue}${(data?.overdueCount ?? 0) > 0 ? ' · ${data!.overdueCount}' : ''}',
          CrmReminderWhen.soon => '${l10n.crmRemindersSoon}${(data?.soonCount ?? 0) > 0 ? ' · ${data!.soonCount}' : ''}',
        };

    return DashPage(
      title: l10n.navCrmReminders,
      header: Column(
        children: [
          DashSearchField(
            controller: _searchController,
            hint: l10n.crmDriversSearchHint,
            onChanged: (v) {
              _debounce?.cancel();
              _debounce = Timer(const Duration(milliseconds: 400), () => ref.read(crmRemindersProvider.notifier).search(v));
            },
          ),
          const SizedBox(height: 10),
          DashChoiceChips<CrmReminderWhen>(
            values: CrmReminderWhen.values,
            selected: data?.query.when ?? CrmReminderWhen.all,
            label: tab,
            onSelected: (w) => ref.read(crmRemindersProvider.notifier).setWhen(w),
          ),
        ],
      ),
      body: listState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => DashEmptyState(
          icon: Icons.lock_outline_rounded,
          text: crmErrorText(context, error),
          action: TextButton(onPressed: () => ref.invalidate(crmRemindersProvider), child: Text(l10n.commonRetry)),
        ),
        data: (state) => RefreshIndicator(
          color: AppColors.onBrand,
          backgroundColor: AppColors.brandYellow,
          onRefresh: () => ref.read(crmRemindersProvider.notifier).refresh(),
          child: state.items.isEmpty
              ? DashEmptyState(icon: Icons.notifications_none_rounded, text: l10n.crmRemindersEmpty)
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                  itemCount: state.items.length + (state.hasNext ? 1 : 0),
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    if (index >= state.items.length) {
                      return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
                    }
                    final r = state.items[index];
                    return _ReminderCard(
                      reminder: r,
                      onOpen: () => context.push(RouteNames.crmDriverDetail(r.driver.id)),
                      onAction: (a) => _act(r, a),
                    ).animate().fadeIn(delay: (25 * (index % 12)).ms, duration: AppMotion.standard);
                  },
                ),
        ),
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({required this.reminder, required this.onOpen, required this.onAction});

  final CrmReminder reminder;
  final VoidCallback onOpen;
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final item = reminder.item;
    final details = [
      if (item.dueOdometerKm != null) l10n.crmAtKm(crmKmFormat.format(item.dueOdometerKm)),
      if (item.dueDateManual) l10n.crmDueManualShort,
      if (item.dueOdometerKm == null && !item.dueDateManual && item.intervalKm != null)
        l10n.crmEveryKm(crmKmFormat.format(item.intervalKm)),
    ];
    return DashCard(
      onTap: onOpen,
      padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DueText(dueDate: item.dueDate!, fontSize: 14, bold: true),
                const SizedBox(height: 4),
                Text(item.productName, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5, color: colors.textPrimary)),
                if (details.isNotEmpty)
                  Text(details.join(' · '), style: TextStyle(color: colors.textMuted, fontSize: 12.5)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    PlateBadge(plate: reminder.vehicle.plateNumber),
                    Text(reminder.vehicle.model, style: TextStyle(color: colors.textSecondary, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    DriverPhoto(name: reminder.driver.fullName, url: reminder.driver.imageUrl, size: 30),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        reminder.driver.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.w700, color: colors.textPrimary),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => launchUrl(Uri(scheme: 'tel', path: reminder.driver.phone)),
                      icon: const Icon(Icons.phone_rounded, size: 18),
                      label: Text(l10n.commonCall),
                    ),
                  ],
                ),
              ],
            ),
          ),
          DashMenuButton(
            items: [
              (value: 'done', icon: Icons.check_circle_outline_rounded, label: l10n.crmMarkDone, destructive: false),
              (value: 'move', icon: Icons.event_repeat_rounded, label: l10n.crmMoveDate, destructive: false),
              (value: 'cancel', icon: Icons.notifications_off_outlined, label: l10n.crmCancelReminder, destructive: true),
            ],
            onSelected: onAction,
          ),
        ],
      ),
    );
  }
}
