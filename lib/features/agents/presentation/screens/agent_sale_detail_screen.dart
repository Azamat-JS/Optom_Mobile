import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/agents/domain/entities/agent_sale.dart';
import 'package:bsmart/features/agents/domain/usecases/get_agent_sale_usecase.dart';
import 'package:bsmart/features/agents/presentation/widgets/agent_format.dart';
import 'package:bsmart/features/sales/presentation/widgets/sale_status_badge.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

final _agentSaleProvider = FutureProvider.autoDispose.family<AgentSaleDetail, String>((ref, id) async {
  final result = await getIt<GetAgentSaleUseCase>().call(id);
  return result.fold((sale) => sale, (failure) => throw failure);
});

/// One agent sale: lines (the lead agent also sees its cost per line), the total and, on debt,
/// what is still owed.
class AgentSaleDetailScreen extends ConsumerWidget {
  const AgentSaleDetailScreen({required this.saleId, super.key});

  final String saleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final saleAsync = ref.watch(_agentSaleProvider(saleId));

    return DashPage(
      title: saleAsync.valueOrNull?.sale.saleNumber ?? l10n.agentCheckoutTitle,
      body: saleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => DashEmptyState(icon: Icons.cloud_off_rounded, text: l10n.commonErrorWith('$error')),
        data: (detail) {
          final sale = detail.sale;
          String money(double v) => CurrencyFormatter.format(v, sale.currency);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              DashCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SaleTypeBadge(type: sale.type),
                        const Spacer(),
                        Text(
                          agentDateFormat.format(sale.createdAt.toLocal()),
                          style: TextStyle(color: colors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(money(sale.total), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(
                      [
                        sale.customer.fullName,
                        if (sale.customer.phone != null && sale.customer.phone != agentWalkInPhone) sale.customer.phone!,
                      ].join(' · '),
                      style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w600),
                    ),
                    if (sale.seller != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        l10n.agentSaleSeller(sale.seller!.fullName),
                        style: TextStyle(color: colors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              DashCard(
                child: Column(
                  children: [
                    for (final line in detail.lines) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(line.productName, style: const TextStyle(fontWeight: FontWeight.w700)),
                                Text(
                                  '${agentQty(line.quantity, line.unit)} × ${money(line.unitPrice)}',
                                  style: TextStyle(fontSize: 12, color: colors.textSecondary),
                                ),
                                if (line.costPrice != null)
                                  Text(
                                    l10n.agentLineCost(money(line.costPrice!)),
                                    style: TextStyle(fontSize: 12, color: colors.textMuted),
                                  ),
                              ],
                            ),
                          ),
                          Text(money(line.total), style: const TextStyle(fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                    DashedDivider(color: colors.outline),
                    const SizedBox(height: 10),
                    BillRow(label: l10n.commonTotal, value: money(sale.total), strong: true),
                    if (sale.debtBalance != null) ...[
                      BillRow(label: l10n.agentDebtPaid, value: money(detail.debtPaid ?? 0), muted: true),
                      BillRow(label: l10n.agentDebtBalance, value: money(sale.debtBalance!)),
                    ],
                  ],
                ),
              ),
              if (detail.notes != null && detail.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                DashCard(child: Text(detail.notes!)),
              ],
            ],
          );
        },
      ),
    );
  }
}
