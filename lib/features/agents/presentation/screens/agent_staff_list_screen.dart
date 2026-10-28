import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/features/agents/domain/entities/agent_account_user.dart';
import 'package:bsmart/features/agents/domain/usecases/delete_agent_staff_usecase.dart';
import 'package:bsmart/features/agents/domain/usecases/set_agent_staff_active_usecase.dart';
import 'package:bsmart/features/agents/presentation/providers/lead_agent_providers.dart';
import 'package:bsmart/features/agents/presentation/screens/agent_staff_form_screen.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// "Agentlar" (lead agent only): its staff agents — add, edit, (de)activate, remove. They sell from
/// the lead agent's shared stock; a deactivated one can't log in.
class AgentStaffListScreen extends ConsumerWidget {
  const AgentStaffListScreen({super.key});

  Future<void> _openForm(BuildContext context, WidgetRef ref, {AgentAccountUser? editing}) async {
    final saved = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => AgentStaffFormScreen(editing: editing)));
    if (saved == true) ref.read(agentStaffListProvider.notifier).refresh();
  }

  Future<void> _toggleActive(BuildContext context, WidgetRef ref, AgentAccountUser agent) async {
    final result = await getIt<SetAgentStaffActiveUseCase>().call(agent.id, !agent.isActive);
    if (!context.mounted) return;
    result.fold(
      (_) => ref.read(agentStaffListProvider.notifier).refresh(),
      (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, AgentAccountUser agent) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.agentStaffDeleteTitle),
        content: Text(context.l10n.commonDeletePermanentlyConfirm(agent.fullName)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(context.l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(context.l10n.commonDelete)),
        ],
      ),
    );
    if (confirmed != true) return;
    final result = await getIt<DeleteAgentStaffUseCase>().call(agent.id);
    if (!context.mounted) return;
    result.fold(
      (_) => ref.read(agentStaffListProvider.notifier).refresh(),
      (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final staffAsync = ref.watch(agentStaffListProvider);

    return DashPage(
      title: l10n.agentStaffTitle,
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.agentStaffNew,
        onPressed: () => _openForm(context, ref),
        child: const Icon(Icons.person_add_alt_1_rounded),
      ),
      body: staffAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => DashEmptyState(icon: Icons.cloud_off_rounded, text: l10n.commonErrorWith('$error')),
        data: (items) => RefreshIndicator(
          color: AppColors.onBrand,
          backgroundColor: AppColors.brandYellow,
          onRefresh: () => ref.read(agentStaffListProvider.notifier).refresh(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
            children: [
              if (items.isEmpty) DashEmptyState(icon: Icons.groups_outlined, text: l10n.agentStaffEmpty),
              for (final (i, agent) in items.indexed) ...[
                if (i > 0) const SizedBox(height: 10),
                DashListCard(
                  dimmed: !agent.isActive,
                  leading: DashAvatar(name: agent.firstName, active: agent.isActive),
                  title: agent.fullName,
                  subtitle: [agent.phone, if (!agent.isActive) l10n.commonInactive].join(' · '),
                  trailing: DashMenuButton(
                    items: [
                      (value: 'edit', icon: Icons.edit_rounded, label: l10n.commonEdit, destructive: false),
                      (
                        value: 'toggle',
                        icon: agent.isActive ? Icons.block_rounded : Icons.check_circle_rounded,
                        label: agent.isActive ? l10n.commonDeactivate : l10n.commonActivate,
                        destructive: false,
                      ),
                      (value: 'delete', icon: Icons.delete_outline_rounded, label: l10n.commonDelete, destructive: true),
                    ],
                    onSelected: (action) {
                      switch (action) {
                        case 'edit':
                          _openForm(context, ref, editing: agent);
                        case 'toggle':
                          _toggleActive(context, ref, agent);
                        case 'delete':
                          _delete(context, ref, agent);
                      }
                    },
                  ),
                  onTap: () => _openForm(context, ref, editing: agent),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
