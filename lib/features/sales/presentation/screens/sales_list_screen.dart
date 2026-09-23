import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/enums/sale_enums.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/sales/presentation/providers/sales_list_notifier.dart';
import 'package:bsmart/features/sales/presentation/screens/sale_detail_screen.dart';
import 'package:bsmart/features/sales/presentation/widgets/sale_status_badge.dart';

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

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(salesListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sotuvlar tarixi')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Barchasi'),
                  selected: _typeFilter == null,
                  onSelected: (_) => _filterByType(null),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text("To'langan"),
                  selected: _typeFilter == SaleType.paid,
                  onSelected: (_) => _filterByType(SaleType.paid),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Qarzga'),
                  selected: _typeFilter == SaleType.debt,
                  onSelected: (_) => _filterByType(SaleType.debt),
                ),
              ],
            ),
          ),
          Expanded(
            child: listState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Xatolik: $error')),
              data: (state) {
                final items = _typeFilter == null ? state.items : state.items.where((s) => s.type == _typeFilter).toList();
                if (items.isEmpty) return const Center(child: Text('Sotuvlar topilmadi'));
                return RefreshIndicator(
                  onRefresh: () => ref.read(salesListProvider.notifier).refresh(),
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: _scrollController,
                    itemCount: items.length + (state.hasNext ? 1 : 0),
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      if (index >= items.length) {
                        return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
                      }
                      final sale = items[index];
                      return ListTile(
                        title: Text(sale.saleNumber),
                        subtitle: Text(sale.customer?.fullName ?? ''),
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(CurrencyFormatter.format(sale.total, sale.currency)),
                            const SizedBox(height: 4),
                            SaleTypeBadge(type: sale.type),
                          ],
                        ),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => SaleDetailScreen(saleId: sale.id)),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
