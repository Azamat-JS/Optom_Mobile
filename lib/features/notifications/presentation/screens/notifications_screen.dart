import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:bsmart/core/enums/user_role.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/notifications/domain/entities/app_notification.dart';
import 'package:bsmart/features/notifications/presentation/providers/notifications_providers.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

final _dayFormat = DateFormat('dd.MM.yyyy');
final _whenFormat = DateFormat('dd.MM, HH:mm');

/// The in-app inbox (Optom_Savdo "CRM" → C5), any role. Opening an entry marks it read; a staff
/// service reminder also opens the driver for the store's owner/admins.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final listState = ref.watch(notificationsProvider);
    final unread = ref.watch(unreadNotificationsProvider);
    final role = ref.watch(sessionNotifierProvider).valueOrNull?.session?.role;
    final canOpenDriver = role == UserRole.retailer || role == UserRole.retailerAdmin;

    void open(AppNotification n) {
      ref.read(notificationsProvider.notifier).markRead(n);
      final due = n.serviceDue;
      if (due != null && !due.forDriver && canOpenDriver && due.driverId.isNotEmpty) {
        context.push(RouteNames.crmDriverDetail(due.driverId));
      }
    }

    return DashPage(
      title: l10n.notifTitle,
      actions: [
        if (unread > 0)
          DashRoundButton(
            icon: Icons.done_all_rounded,
            tooltip: l10n.notifReadAll,
            onTap: () async {
              try {
                await ref.read(notificationsProvider.notifier).markAllRead();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonErrorWith('$e'))));
                }
              }
            },
          ),
      ],
      body: listState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => DashEmptyState(
          icon: Icons.cloud_off_rounded,
          text: l10n.commonErrorWith('$error'),
          action: TextButton(onPressed: () => ref.invalidate(notificationsProvider), child: Text(l10n.commonRetry)),
        ),
        data: (state) => RefreshIndicator(
          color: AppColors.onBrand,
          backgroundColor: AppColors.brandYellow,
          onRefresh: () async => ref.invalidate(notificationsProvider),
          child: state.items.isEmpty
              ? DashEmptyState(icon: Icons.notifications_none_rounded, text: l10n.notifEmpty)
              : NotificationListener<ScrollNotification>(
                  onNotification: (n) {
                    if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
                      ref.read(notificationsProvider.notifier).loadMore();
                    }
                    return false;
                  },
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                    itemCount: state.items.length + (state.hasNext ? 1 : 0),
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      if (index >= state.items.length) {
                        return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
                      }
                      final n = state.items[index];
                      return _NotificationCard(notification: n, onTap: () => open(n))
                          .animate()
                          .fadeIn(delay: (20 * (index % 12)).ms, duration: AppMotion.standard);
                    },
                  ),
                ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final due = notification.serviceDue;
    final unread = !notification.isRead;
    final parts = due?.items.map((i) => '${i.name} (${_dayFormat.format(i.dueDate)})').join(', ') ?? '';

    final title = due == null
        ? l10n.notifUnknown
        : due.forDriver
            ? l10n.notifServiceDueDriver(due.storeName)
            : l10n.notifServiceDueStaff(due.plate, due.driverName);
    final lines = <(String, Color?)>[
      if (due != null && due.forDriver) ('${due.plate}: $parts', null),
      if (due != null && !due.forDriver) (parts, null),
      if (due != null && !due.forDriver)
        due.driverNotified == true
            ? (l10n.notifDriverNotified, null)
            : (l10n.notifCallDriver(due.driverPhone), const Color(0xFFB86E00)),
    ];

    return DashCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: unread ? AppColors.brandYellow : DashColors.inset(context),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.car_repair_rounded, size: 21, color: unread ? AppColors.onBrand : colors.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: unread ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 14.5,
                  ),
                ),
                for (final (text, color) in lines)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(text, style: TextStyle(color: color ?? colors.textSecondary, fontSize: 13)),
                  ),
                const SizedBox(height: 4),
                Text(
                  _whenFormat.format(notification.createdAt.toLocal()),
                  style: TextStyle(color: colors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          if (unread)
            Container(
              margin: const EdgeInsets.only(top: 6, left: 8),
              width: 9,
              height: 9,
              decoration: const BoxDecoration(color: AppColors.goldInk, shape: BoxShape.circle),
            ),
        ],
      ),
    );
  }
}
