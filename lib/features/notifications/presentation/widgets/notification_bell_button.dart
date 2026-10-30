import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/features/notifications/presentation/providers/notifications_providers.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';

/// Round bell for a home header, with the unread count. While it's on screen it refreshes the
/// count every minute and when the app comes back to the foreground (no push until C7).
class NotificationBellButton extends ConsumerStatefulWidget {
  const NotificationBellButton({super.key});

  @override
  ConsumerState<NotificationBellButton> createState() => _NotificationBellButtonState();
}

class _NotificationBellButtonState extends ConsumerState<NotificationBellButton> {
  Timer? _timer;
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    Future.microtask(_refresh);
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _refresh());
    _lifecycle = AppLifecycleListener(onResume: _refresh);
  }

  void _refresh() {
    if (mounted) ref.read(unreadNotificationsProvider.notifier).refresh();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unread = ref.watch(unreadNotificationsProvider);
    final l10n = context.l10n;
    return Badge(
      isLabelVisible: unread > 0,
      label: Text(unread > 99 ? '99+' : '$unread'),
      offset: const Offset(-2, 2),
      child: DashRoundButton(
        icon: unread > 0 ? Icons.notifications_rounded : Icons.notifications_none_rounded,
        tooltip: l10n.notifTitle,
        onTap: () async {
          await context.push(RouteNames.notifications);
          _refresh();
        },
      ),
    );
  }
}
