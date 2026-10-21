import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/debts/domain/entities/debt.dart';
import 'package:bsmart/features/debts/presentation/providers/sale_debts_list_notifier.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/auth/presentation/widgets/verify_phone_banner.dart';
import 'package:bsmart/features/debts/presentation/widgets/debt_status_badge.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

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
    // Verifying the phone (VerifyPhoneBanner) unlocks phone-matched debts server-side — refetch.
    ref.listen(sessionNotifierProvider.select((s) => s.valueOrNull?.user?.phoneVerified), (previous, next) {
      if (previous == false && next == true) ref.invalidate(saleDebtsListProvider);
    });

    return DashPage(title: 'Qarzlarim', body: _body(context, ref, debtsAsync));
  }

  Widget _body(BuildContext context, WidgetRef ref, AsyncValue<List<SaleDebt>> debtsAsync) {
    final banner = VerifyPhoneBanner(message: context.l10n.verifyBannerDebts);
    return debtsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => DashEmptyState(icon: Icons.cloud_off_rounded, text: 'Xatolik: $error'),
      data: (debts) {
        // Never summed across currencies: one total per currency, active debts only.
        final totals = <Currency, double>{};
        for (final d in debts) {
          if (d.balance > 0) totals[d.currency] = (totals[d.currency] ?? 0) + d.balance;
        }
        return RefreshIndicator(
          color: AppColors.onBrand,
          backgroundColor: AppColors.brandYellow,
          onRefresh: () => ref.read(saleDebtsListProvider.notifier).refresh(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            children: [
              banner,
              if (debts.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 80),
                  child: Column(
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(color: DashColors.card(context), shape: BoxShape.circle),
                        child: const Icon(Icons.check_circle_rounded, size: 38, color: AppColors.success),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Qarzlar topilmadi',
                        style: TextStyle(
                          color: BrandColors.of(context).textSecondary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                if (totals.isNotEmpty) ...[const SizedBox(height: 12), _TotalCard(totals: totals)],
                const SizedBox(height: 12),
                for (final (i, debt) in debts.indexed) ...[
                  if (i > 0) const SizedBox(height: 10),
                  _DebtTile(debt: debt),
                ],
              ],
            ],
          ),
        );
      },
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.totals});

  final Map<Currency, double> totals;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.ink, Color(0xFF2A1210)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.debtsSummaryTotal,
            style: TextStyle(
              fontFamily: BrandTheme.fontFamily,
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          for (final entry in totals.entries)
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                CurrencyFormatter.format(entry.value, entry.key),
                style: const TextStyle(
                  fontFamily: BrandTheme.fontFamily,
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DebtTile extends StatelessWidget {
  const _DebtTile({required this.debt});

  final SaleDebt debt;

  static final _dateFormat = DateFormat('dd.MM.yyyy');

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    final open = debt.balance > 0;
    final error = Theme.of(context).colorScheme.error;
    return DashListCard(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: (open ? error : AppColors.success).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(Icons.storefront_rounded, color: open ? error : AppColors.success),
      ),
      title: debt.owner?.fullName ?? "Noma'lum do'kon",
      subtitle: _dateFormat.format(debt.createdAt.toLocal()),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            CurrencyFormatter.format(debt.balance, debt.currency),
            style: TextStyle(color: open ? error : colors.textMuted, fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          DebtStatusBadge(status: debt.status),
        ],
      ),
    );
  }
}
