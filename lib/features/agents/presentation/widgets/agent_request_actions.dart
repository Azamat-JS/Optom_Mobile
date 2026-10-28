import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/features/agents/presentation/providers/agent_dashboard_providers.dart';
import 'package:bsmart/features/agents/presentation/providers/agent_stock_notifier.dart';
import 'package:bsmart/features/agents/presentation/providers/lead_agent_providers.dart';

/// "So'rov bekor qilinsinmi?" — true when the lead agent confirms withdrawing a pending request.
Future<bool> confirmAgentRequestCancel(BuildContext context) async {
  final l10n = context.l10n;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.agentCancelRequestConfirm),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.commonCancel)),
        FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.agentCancelRequest)),
      ],
    ),
  );
  return confirmed == true;
}

/// After a request is sent or withdrawn: the account cards, both request lists, and — since a
/// return reserves units at once — the stock the Sell tab shows and the dashboard's stock value.
void refreshAfterAgentRequest(WidgetRef ref, {bool stockChanged = false}) {
  ref.read(leadAccountProvider.notifier).refresh();
  ref.read(leadPaymentRequestsProvider.notifier).refresh();
  ref.read(leadReturnsProvider.notifier).refresh();
  if (stockChanged) {
    ref.read(agentStockProvider.notifier).refresh();
    ref.read(agentSummaryProvider.notifier).refresh();
  }
}
