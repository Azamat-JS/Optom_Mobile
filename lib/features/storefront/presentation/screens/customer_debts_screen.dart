import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/debts/domain/entities/debt.dart';
import 'package:bsmart/features/debts/presentation/providers/sale_debts_list_notifier.dart';
import 'package:bsmart/features/debts/presentation/widgets/debt_status_badge.dart';

/// "Qarzlarim" — a `CUSTOMER`'s own B2C debts. Reuses `features/debts`'
/// existing `saleDebtsListProvider` (`GET /sale-debts`, already scoped to
/// the caller's own phone-matched `Customer` records server-side — see
/// `sale-debt.service.ts`'s `CUSTOMER` branch) unchanged; this is a
/// deliberately simpler presentation than `DebtsListScreen` (no B2B tab, no
/// role toggle, no payment/close actions — a customer only ever *owes*
/// here, and only the creditor may record a payment, per Milestone 5's
/// finding).
class CustomerDebtsScreen extends ConsumerWidget {
  const CustomerDebtsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debtsAsync = ref.watch(saleDebtsListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Qarzlarim')),
      body: debtsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Xatolik: $error')),
        data: (debts) {
          if (debts.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => ref.read(saleDebtsListProvider.notifier).refresh(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  Padding(padding: EdgeInsets.only(top: 96), child: Center(child: Text('Qarzlar topilmadi'))),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(saleDebtsListProvider.notifier).refresh(),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: debts.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) => _DebtTile(debt: debts[index]),
            ),
          );
        },
      ),
    );
  }
}

class _DebtTile extends StatelessWidget {
  const _DebtTile({required this.debt});

  final SaleDebt debt;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.storefront_outlined),
      title: Text(debt.owner?.fullName ?? "Noma'lum do'kon"),
      subtitle: Text('${debt.createdAt.toLocal()}'.split(' ').first),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(CurrencyFormatter.format(debt.balance, debt.currency), style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          DebtStatusBadge(status: debt.status),
        ],
      ),
    );
  }
}
