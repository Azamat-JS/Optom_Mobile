import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/enums/user_role.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/agents/domain/entities/agent_sale.dart';
import 'package:bsmart/features/agents/presentation/providers/agent_sales_list_notifier.dart';
import 'package:bsmart/features/agents/presentation/screens/agent_sale_detail_screen.dart';
import 'package:bsmart/features/agents/presentation/widgets/agent_format.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/sales/presentation/widgets/sale_status_badge.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// "Sotuvlar": a lead agent's whole team (with who sold each), or a staff agent's own sales.
class AgentSalesTab extends ConsumerStatefulWidget {
  const AgentSalesTab({super.key});

  @override
  ConsumerState<AgentSalesTab> createState() => _AgentSalesTabState();
}

class _AgentSalesTabState extends ConsumerState<AgentSalesTab> {
  final _search = TextEditingController();
  final _scroll = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
        ref.read(agentSalesListProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onSearch(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () => ref.read(agentSalesListProvider.notifier).search(text));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isLead = ref.watch(sessionNotifierProvider).valueOrNull?.session?.role == UserRole.leadAgent;
    final listAsync = ref.watch(agentSalesListProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: DashSearchField(controller: _search, hint: l10n.commonSearchHint, onChanged: _onSearch),
        ),
        Expanded(
          child: listAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => DashEmptyState(icon: Icons.cloud_off_rounded, text: l10n.commonErrorWith('$error')),
            data: (state) => RefreshIndicator(
              color: AppColors.onBrand,
              backgroundColor: AppColors.brandYellow,
              onRefresh: () => ref.read(agentSalesListProvider.notifier).refresh(),
              child: state.items.isEmpty
                  ? DashEmptyState(icon: Icons.receipt_long_outlined, text: l10n.agentSalesEmpty)
                  : ListView.separated(
                      controller: _scroll,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        if (i >= state.items.length) {
                          return const Padding(
                            padding: EdgeInsets.all(12),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        return _SaleCard(sale: state.items[i], showSeller: isLead);
                      },
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SaleCard extends StatelessWidget {
  const _SaleCard({required this.sale, required this.showSeller});

  final AgentSale sale;
  final bool showSeller;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    final l10n = context.l10n;
    final walkIn = sale.customer.phone == agentWalkInPhone;
    return DashCard(
      padding: const EdgeInsets.all(14),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => AgentSaleDetailScreen(saleId: sale.id)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sale.customer.fullName, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  [
                    agentDateFormat.format(sale.createdAt.toLocal()),
                    l10n.commonProductCount(sale.itemCount),
                    if (!walkIn && sale.customer.phone != null) sale.customer.phone!,
                  ].join(' · '),
                  style: TextStyle(fontSize: 12, color: colors.textSecondary),
                ),
                if (showSeller && sale.seller != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    l10n.agentSaleSeller(sale.seller!.fullName),
                    style: TextStyle(fontSize: 12, color: colors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.format(sale.total, sale.currency),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              SaleTypeBadge(type: sale.type),
            ],
          ),
        ],
      ),
    );
  }
}
