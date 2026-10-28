import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/features/agents/presentation/providers/lead_agent_providers.dart';
import 'package:bsmart/features/agents/presentation/screens/agent_transfer_detail_screen.dart';
import 'package:bsmart/features/agents/presentation/widgets/agent_request_cards.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// "Kirimlar" (lead agent only): every hand-over from the owner, newest first, with what is still
/// owed on it. Pages in 20 at a time as the list is scrolled.
class ReceivedTransfersScreen extends ConsumerWidget {
  const ReceivedTransfersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final transfersAsync = ref.watch(receivedTransfersProvider);

    return DashPage(
      title: l10n.agentTransfersTitle,
      body: transfersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => DashEmptyState(icon: Icons.cloud_off_rounded, text: l10n.commonErrorWith('$error')),
        data: (state) => RefreshIndicator(
          color: AppColors.onBrand,
          backgroundColor: AppColors.brandYellow,
          onRefresh: () => ref.read(receivedTransfersProvider.notifier).refresh(),
          child: NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n.metrics.pixels > n.metrics.maxScrollExtent - 300) {
                ref.read(receivedTransfersProvider.notifier).loadMore();
              }
              return false;
            },
            child: state.items.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [DashEmptyState(icon: Icons.local_shipping_outlined, text: l10n.agentTransfersEmpty)],
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                    itemCount: state.items.length + (state.hasNext ? 1 : 0),
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      if (i >= state.items.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final t = state.items[i];
                      return AgentTransferCard(
                        transfer: t,
                        onTap: () => Navigator.of(
                          context,
                        ).push(MaterialPageRoute(builder: (_) => AgentTransferDetailScreen(transferId: t.id))),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}
