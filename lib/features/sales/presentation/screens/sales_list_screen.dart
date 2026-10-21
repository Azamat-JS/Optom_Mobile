import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/enums/sale_enums.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/sales/presentation/providers/sales_list_notifier.dart';
import 'package:bsmart/features/sales/presentation/screens/sale_detail_screen.dart';
import 'package:bsmart/features/sales/presentation/widgets/sale_status_badge.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// POS sale history — every B2C register sale, filterable by type
/// (PAID/DEBT). Reused by both SELLER's and RETAILER's own register, since
/// `sale.controller.ts` scopes `GET /sales` by the caller's own tenant.
class SalesListScreen extends ConsumerStatefulWidget {
  const SalesListScreen({super.key});

  @override
  ConsumerState<SalesListScreen> createState() => _SalesListScreenState();
}

class _SalesListScreenState extends ConsumerState<SalesListScreen> {
  final _scrollController = ScrollController();
  SaleType? _typeFilter;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(salesListProvider.notifier).loadMore();
    }
  }

  // Client-side filter over the already-fetched/paginated list — simpler
  // than re-querying the server per chip, and the working set (recent
  // register sales) is small enough that this stays snappy.
  void _filterByType(SaleType? type) => setState(() => _typeFilter = type);

  static final _dateFormat = DateFormat('dd.MM.yyyy HH:mm');

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final listState = ref.watch(salesListProvider);

    return DashPage(
      title: l10n.salesHistoryTitle,
      header: DashChoiceChips<SaleType?>(
        values: const [null, SaleType.paid, SaleType.debt],
        selected: _typeFilter,
        label: (t) => switch (t) {
          null => l10n.commonAll,
          SaleType.paid => l10n.commonPaid,
          SaleType.debt => l10n.commonOnCredit,
        },
        onSelected: _filterByType,
      ),
      body: listState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => DashEmptyState(
          icon: Icons.cloud_off_rounded,
          text: l10n.commonErrorWith('$error'),
          action: TextButton(onPressed: () => ref.invalidate(salesListProvider), child: Text(l10n.commonRetry)),
        ),
        data: (state) {
          final items = _typeFilter == null ? state.items : state.items.where((s) => s.type == _typeFilter).toList();
          return RefreshIndicator(
            color: AppColors.onBrand,
            backgroundColor: AppColors.brandYellow,
            onRefresh: () => ref.read(salesListProvider.notifier).refresh(),
            child: items.isEmpty
                ? DashEmptyState(icon: Icons.receipt_rounded, text: l10n.salesNotFound)
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                    itemCount: items.length + (state.hasNext ? 1 : 0),
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      if (index >= items.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final sale = items[index];
                      final tint = sale.type == SaleType.paid ? AppColors.success : colors.accentText;
                      return DashListCard(
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: tint.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            sale.type == SaleType.paid ? Icons.receipt_rounded : Icons.request_quote_rounded,
                            color: tint,
                          ),
                        ),
                        title: sale.customer?.fullName ?? sale.saleNumber,
                        subtitle: '${_dateFormat.format(sale.createdAt.toLocal())} · ${sale.saleNumber}',
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              CurrencyFormatter.format(sale.total, sale.currency),
                              style: TextStyle(color: colors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            // Returns matter more than the type once they happen.
                            sale.status == SaleStatus.completed
                                ? SaleTypeBadge(type: sale.type)
                                : SaleStatusBadge(status: sale.status),
                          ],
                        ),
                        onTap: () => Navigator.of(
                          context,
                        ).push(MaterialPageRoute(builder: (_) => SaleDetailScreen(saleId: sale.id))),
                      ).animate().fadeIn(delay: (25 * (index % 12)).ms, duration: AppMotion.standard);
                    },
                  ),
          );
        },
      ),
    );
  }
}
