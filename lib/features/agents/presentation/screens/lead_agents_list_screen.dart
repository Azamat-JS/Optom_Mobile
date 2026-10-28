import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/features/agents/domain/entities/agent_account_user.dart';
import 'package:bsmart/features/agents/domain/usecases/delete_lead_agent_usecase.dart';
import 'package:bsmart/features/agents/domain/usecases/set_lead_agent_active_usecase.dart';
import 'package:bsmart/features/agents/presentation/providers/owner_agent_providers.dart';
import 'package:bsmart/features/agents/presentation/screens/lead_agent_detail_screen.dart';
import 'package:bsmart/features/agents/presentation/screens/lead_agent_form_screen.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// "Dillerlar" (business owner only): its lead agents with their store, staff count and requests
/// waiting for a decision. A row opens the lead agent's page.
class LeadAgentsListScreen extends ConsumerWidget {
  const LeadAgentsListScreen({super.key});

  Future<void> _openForm(BuildContext context, WidgetRef ref, {AgentAccountUser? editing}) async {
    final saved = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => LeadAgentFormScreen(editing: editing)));
    if (saved == true) ref.read(leadAgentsListProvider.notifier).refresh();
  }

  Future<void> _open(BuildContext context, WidgetRef ref, AgentAccountUser lead) async {
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => LeadAgentDetailScreen(lead: lead)));
    // Decisions and transfers made there change the pending count.
    ref.read(leadAgentsListProvider.notifier).refresh();
  }

  Future<void> _toggleActive(BuildContext context, WidgetRef ref, AgentAccountUser lead) async {
    final result = await getIt<SetLeadAgentActiveUseCase>().call(lead.id, !lead.isActive);
    if (!context.mounted) return;
    result.fold(
      (_) => ref.read(leadAgentsListProvider.notifier).refresh(),
      (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, AgentAccountUser lead) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.ownerLeadDeleteTitle),
        content: Text(context.l10n.commonDeletePermanentlyConfirm(lead.fullName)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(context.l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(context.l10n.commonDelete)),
        ],
      ),
    );
    if (confirmed != true) return;
    final result = await getIt<DeleteLeadAgentUseCase>().call(lead.id);
    if (!context.mounted) return;
    result.fold(
      (_) => ref.read(leadAgentsListProvider.notifier).refresh(),
      // Refused while it holds stock, owes money, has staff or pending requests — the server says which.
      (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final leadsAsync = ref.watch(leadAgentsListProvider);

    return DashPage(
      title: l10n.navLeadAgents,
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.ownerLeadNew,
        onPressed: () => _openForm(context, ref),
        child: const Icon(Icons.person_add_alt_1_rounded),
      ),
      body: leadsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => DashEmptyState(icon: Icons.cloud_off_rounded, text: l10n.commonErrorWith('$error')),
        data: (items) => RefreshIndicator(
          color: AppColors.onBrand,
          backgroundColor: AppColors.brandYellow,
          onRefresh: () => ref.read(leadAgentsListProvider.notifier).refresh(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
            children: [
              if (items.isEmpty) DashEmptyState(icon: Icons.handshake_outlined, text: l10n.ownerLeadsEmpty),
              for (final (i, lead) in items.indexed) ...[
                if (i > 0) const SizedBox(height: 10),
                DashListCard(
                  dimmed: !lead.isActive,
                  leading: DashAvatar(name: lead.firstName, active: lead.isActive),
                  title: lead.fullName,
                  // No phone here (it's on the lead agent's page): next to the request tag it pushed the
                  // store name off the line.
                  subtitle: [
                    ?lead.storeName,
                    if (lead.staffCount != null) l10n.ownerLeadStaffCount(lead.staffCount!),
                    if (!lead.isActive) l10n.commonInactive,
                  ].join(' · '),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if ((lead.pendingCount ?? 0) > 0)
                        DashTag(
                          label: l10n.ownerLeadPendingCount(lead.pendingCount!),
                          color: BrandColors.of(context).accentText,
                        ),
                      DashMenuButton(
                        items: [
                          (value: 'edit', icon: Icons.edit_rounded, label: l10n.commonEdit, destructive: false),
                          (
                            value: 'toggle',
                            icon: lead.isActive ? Icons.block_rounded : Icons.check_circle_rounded,
                            label: lead.isActive ? l10n.commonDeactivate : l10n.commonActivate,
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
                              _openForm(context, ref, editing: lead);
                            case 'toggle':
                              _toggleActive(context, ref, lead);
                            case 'delete':
                              _delete(context, ref, lead);
                          }
                        },
                      ),
                    ],
                  ),
                  onTap: () => _open(context, ref, lead),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
