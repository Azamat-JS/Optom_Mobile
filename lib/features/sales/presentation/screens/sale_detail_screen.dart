import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/sales/domain/entities/sale.dart';
import 'package:bsmart/features/sales/domain/usecases/get_sale_usecase.dart';
import 'package:bsmart/features/sales/presentation/screens/sale_return_screen.dart';
import 'package:bsmart/features/sales/presentation/widgets/sale_status_badge.dart';

/// A sale's receipt-like detail — items, totals, payment(s)/debt, and
/// (while [Sale.canReturn]) a "Qaytarish" action. There is no separate
/// `Receipt` model server-side — this screen *is* the receipt, regenerated
/// on demand from `GET /sales/:id` (see `CLAUDE.md`'s reference doc note).
class SaleDetailScreen extends ConsumerStatefulWidget {
  const SaleDetailScreen({super.key, required this.saleId, this.justCreated = false});

  final String saleId;
  final bool justCreated;

  @override
  ConsumerState<SaleDetailScreen> createState() => _SaleDetailScreenState();
}

class _SaleDetailScreenState extends ConsumerState<SaleDetailScreen> {
  Sale? _sale;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _errorMessage = null);
    final result = await getIt<GetSaleUseCase>().call(widget.saleId);
    if (!mounted) return;
    result.fold((sale) => setState(() => _sale = sale), (failure) => setState(() => _errorMessage = failure.message));
  }

  Future<void> _openReturn() async {
    final sale = _sale;
    if (sale == null) return;
    final returned = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => SaleReturnScreen(sale: sale)),
    );
    if (returned == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final sale = _sale;
    return Scaffold(
      appBar: AppBar(title: Text(sale?.saleNumber ?? 'Sotuv')),
      body: _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : sale == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (widget.justCreated)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 8),
                            Text('Sotuv yaratildi', style: Theme.of(context).textTheme.titleMedium),
                          ],
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(sale.saleNumber, style: Theme.of(context).textTheme.titleLarge),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SaleTypeBadge(type: sale.type),
                            const SizedBox(height: 4),
                            SaleStatusBadge(status: sale.status),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${sale.createdAt.toLocal()}'.split('.').first,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    if (sale.customer != null)
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.person_outline),
                          title: Text(sale.customer!.fullName),
                          subtitle: Text(sale.customer!.phone ?? ''),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Mahsulotlar', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            for (final item in sale.items)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(item.productName),
                                          Text(
                                            '${item.quantity.toStringAsFixed(item.quantity.truncateToDouble() == item.quantity ? 0 : 3)} x ${CurrencyFormatter.format(item.unitPrice, sale.currency)}'
                                            '${item.returnedQuantity > 0 ? ' · qaytarilgan: ${item.returnedQuantity.toStringAsFixed(0)}' : ''}',
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(CurrencyFormatter.format(item.total, sale.currency)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            _TotalRow(label: 'Oraliq summa', value: CurrencyFormatter.format(sale.subtotal, sale.currency)),
                            if (sale.discount > 0)
                              _TotalRow(label: 'Chegirma', value: '-${CurrencyFormatter.format(sale.discount, sale.currency)}'),
                            const Divider(),
                            _TotalRow(
                              label: 'Jami',
                              value: CurrencyFormatter.format(sale.total, sale.currency),
                              bold: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (sale.debt != null) ...[
                      const SizedBox(height: 16),
                      Card(
                        color: Theme.of(context).colorScheme.errorContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Qarz', style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 4),
                              _TotalRow(
                                label: "To'langan",
                                value: CurrencyFormatter.format(sale.debt!.paidAmount, sale.currency),
                              ),
                              _TotalRow(
                                label: 'Qoldiq',
                                value: CurrencyFormatter.format(sale.debt!.balance, sale.currency),
                                bold: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (sale.payments.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("To'lovlar", style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 8),
                              for (final payment in sale.payments)
                                _TotalRow(
                                  label: payment.method.label,
                                  value: CurrencyFormatter.format(payment.amount, sale.currency),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (sale.canReturn) ...[
                      const SizedBox(height: 20),
                      OutlinedButton.icon(
                        onPressed: _openReturn,
                        icon: const Icon(Icons.undo),
                        label: const Text('Qaytarish'),
                      ),
                    ],
                  ],
                ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.label, required this.value, this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: style), Text(value, style: style)],
      ),
    );
  }
}
