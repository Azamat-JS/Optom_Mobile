import 'package:flutter/material.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/features/agents/domain/entities/agent_requests.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// Pending / confirmed / rejected / cancelled pill for payment and return requests.
class AgentRequestStatusTag extends StatelessWidget {
  const AgentRequestStatusTag({required this.status, super.key});

  final AgentRequestStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final (label, color) = switch (status) {
      AgentRequestStatus.pending => (l10n.agentStatusPending, colors.accentText),
      AgentRequestStatus.confirmed => (l10n.agentStatusConfirmed, AppColors.success),
      AgentRequestStatus.rejected => (l10n.agentStatusRejected, Theme.of(context).colorScheme.error),
      AgentRequestStatus.cancelled => (l10n.agentStatusCancelled, colors.textMuted),
    };
    return DashTag(label: label, color: color);
  }
}
