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
import 'package:bsmart/features/sales/domain/entities/sale_query.dart';
import 'package:bsmart/features/sales/presentation/providers/sales_list_notifier.dart';
import 'package:bsmart/features/sales/presentation/screens/manual_revenue_form_screen.dart';
import 'package:bsmart/features/sales/presentation/screens/sale_detail_screen.dart';
import 'package:bsmart/features/sales/presentation/widgets/sale_status_badge.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';
import 'package:bsmart/features/sales/presentation/widgets/sale_customer_name.dart';

/// The history chips: paid/debt filter the loaded page on the phone; "manual"
/// asks the server for manual revenues only (`?kind=manual`).
enum _SalesFilter { all, paid, debt, manual }

/// POS sale history — every B2C register sale, filterable by type
/// (PAID/DEBT) or to manual revenues. Reused by both SELLER's and RETAILER's
/// own register, since `sale.controller.ts` scopes `GET /sales` by the
/// caller's own tenant. "Daromad qo'shish" records a manual revenue
/// (Optom_Savdo "Manual Revenue").
class SalesListScreen extends ConsumerStatefulWidget {
  const SalesListScreen({super.key, this.manualOnly = false});

  /// Opened from the dashboard's manual revenue card: start on that filter.
  final bool manualOnly;

  @override
  ConsumerState<SalesListScreen> createState() => _SalesListScreenState();
}

class _SalesListScreenState extends ConsumerState<SalesListScreen> {
  final _scrollController = ScrollController();
  late _SalesFilter _filter = widget.manualOnly ? _SalesFilter.manual : _SalesFilter.all;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // The list provider is app-wide: line its server-side filter up with this screen's chip.
    Future.microtask(() => _applyKind());
  }

  void _applyKind() {
    if (!mounted) return;
    ref.read(salesListProvider.notifier).setKind(_filter == _SalesFilter.manual ? SaleKind.manual : null);
  }

  Future<void> _addRevenue() async {
    final saved = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const ManualRevenueFormScreen()));
    if (saved == true && _scrollController.hasClients) _scrollController.jumpTo(0);
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

  // Paid/debt: client-side filter over the already-fetched/paginated list —
  // simpler than re-querying the server per chip, and the working set (recent
  // register sales) is small enough that this stays snappy. Manual revenues
  // are filtered by the server, so their list pages correctly.
  void _onFilter(_SalesFilter filter) {
    setState(() => _filter = filter);
    _applyKind();
  }

  static final _dateFormat = DateFormat('dd.MM.yyyy HH:mm');

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final listState = ref.watch(salesListProvider);

    return DashPage(
      title: l10n.salesHistoryTitle,
      header: DashChoiceChips<_SalesFilter>(
        values: _SalesFilter.values,
        selected: _filter,
        label: (f) => switch (f) {
          _SalesFilter.all => l10n.commonAll,
          _SalesFilter.paid => l10n.commonPaid,
          _SalesFilter.debt => l10n.commonOnCredit,
          _SalesFilter.manual => l10n.manualRevenueFilter,
        },
        onSelected: _onFilter,
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('manualRevenueAdd'),
        onPressed: _addRevenue,
        icon: const Icon(Icons.add_card_rounded),
        label: Text(l10n.manualRevenueAdd),
      ),
      body: listState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => DashEmptyState(
          icon: Icons.cloud_off_rounded,
          text: l10n.commonErrorWith('$error'),
          action: TextButton(onPressed: () => ref.invalidate(salesListProvider), child: Text(l10n.commonRetry)),
        ),
        data: (state) {
          final type = switch (_filter) {
            _SalesFilter.paid => SaleType.paid,
            _SalesFilter.debt => SaleType.debt,
            _ => null,
          };
          // The server already narrowed it for "manual"; this also hides a stale page until it has.
          final items = state.items
              .where((s) => (type == null || s.type == type) && (_filter != _SalesFilter.manual || s.isManualRevenue))
              .toList();
          return RefreshIndicator(
            color: AppColors.onBrand,
            backgroundColor: AppColors.brandYellow,
            onRefresh: () => ref.read(salesListProvider.notifier).refresh(),
            child: items.isEmpty
                ? DashEmptyState(
                    icon: Icons.receipt_rounded,
                    text: _filter == _SalesFilter.manual ? l10n.manualRevenueEmpty : l10n.salesNotFound,
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: _scrollController,
                    // Room for the "Daromad qo'shish" button over the last row.
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
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
                            sale.isManualRevenue
                                ? Icons.add_card_rounded
                                : sale.type == SaleType.paid
                                ? Icons.receipt_rounded
                                : Icons.request_quote_rounded,
                            color: tint,
                          ),
                        ),
                        titleTrailing: sale.isManualRevenue
                            ? DashTag(label: l10n.manualRevenueTag, color: colors.accentText)
                            : null,
                        title: sale.customer == null ? sale.saleNumber : saleCustomerName(sale.customer!, l10n),
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
