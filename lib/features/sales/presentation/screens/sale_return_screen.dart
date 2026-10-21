import 'package:flutter/material.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/enums/payment_method.dart';
import 'package:bsmart/core/enums/sale_enums.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/sales/domain/entities/sale.dart';
import 'package:bsmart/features/sales/domain/entities/sale_write_params.dart';
import 'package:bsmart/features/sales/domain/usecases/create_sale_return_usecase.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';
import 'package:bsmart/shared/widgets/payment_method_tiles.dart';

/// Return part or all of a sale — mirrors `CreateSaleReturnDto` exactly.
/// `refundMethod` is required only when the original sale was PAID (a DEBT
/// sale's return just reduces the linked `SaleDebt` balance, see
/// `sale.service.ts#createReturn`).
///
/// Phase 9 U4c4: sale card, item steppers (capped at what is still
/// returnable), refund-method tiles for paid sales, reason, the return total.
class SaleReturnScreen extends StatefulWidget {
  const SaleReturnScreen({super.key, required this.sale});

  final Sale sale;

  @override
  State<SaleReturnScreen> createState() => _SaleReturnScreenState();
}

class _SaleReturnScreenState extends State<SaleReturnScreen> {
  final _quantities = <String, double>{};
  final _reasonController = TextEditingController();
  PaymentMethod _refundMethod = PaymentMethod.cash;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  double get _totalReturnAmount {
    double sum = 0;
    for (final item in widget.sale.items) {
      final qty = _quantities[item.id] ?? 0;
      if (qty <= 0) continue;
      final unitValue = item.total / item.quantity;
      sum += unitValue * qty;
    }
    return sum;
  }

  Future<void> _submit() async {
    final items = [
      for (final item in widget.sale.items)
        if ((_quantities[item.id] ?? 0) > 0)
          CreateSaleReturnItemParams(saleItemId: item.id, quantity: _quantities[item.id]!),
    ];
    if (items.isEmpty) {
      setState(() => _errorMessage = context.l10n.salesPickReturnItem);
      return;
    }
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final result = await getIt<CreateSaleReturnUseCase>().call(
      widget.sale.id,
      CreateSaleReturnParams(
        items: items,
        reason: _reasonController.text.trim().isEmpty ? null : _reasonController.text.trim(),
        refundMethod: widget.sale.type == SaleType.paid ? _refundMethod : null,
      ),
    );
    if (!mounted) return;
    result.fold(
      (_) => Navigator.of(context).pop(true),
      (failure) => setState(() {
        _isSubmitting = false;
        _errorMessage = failure.message;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final sale = widget.sale;
    final returnableItems = sale.items.where((i) => i.remainingReturnable > 0).toList();
    String qty(double v) => v.toStringAsFixed(v == v.truncateToDouble() ? 0 : 2);

    return DashPage(
      title: l10n.salesReturn,
      bottomBar: DashBottomButton(
        label: l10n.salesConfirmReturn,
        icon: Icons.undo_rounded,
        busy: _isSubmitting,
        onPressed: _totalReturnAmount > 0 ? _submit : null,
      ),
      body: DashFormTheme(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            DashListCard(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: DashColors.inset(context), borderRadius: BorderRadius.circular(14)),
                child: Icon(Icons.receipt_rounded, color: colors.textSecondary),
              ),
              title: sale.customer?.fullName ?? sale.saleNumber,
              subtitle: sale.saleNumber,
              trailing: Text(
                CurrencyFormatter.format(sale.total, sale.currency),
                style: TextStyle(color: colors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800),
              ),
            ),
            DashSectionTitle(l10n.commonProducts),
            DashCard(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                children: [
                  for (final (i, item) in returnableItems.indexed) ...[
                    if (i > 0) Divider(height: 1, indent: 16, color: colors.outline),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.productName,
                                  style: TextStyle(
                                    color: colors.textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '${CurrencyFormatter.format(item.total / item.quantity, sale.currency)} · '
                                  '${l10n.salesReturnableLeft(qty(item.remainingReturnable))}',
                                  style: TextStyle(
                                    color: colors.textMuted,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          DashStepper(
                            value: qty(_quantities[item.id] ?? 0),
                            onMinus: () {
                              final current = _quantities[item.id] ?? 0;
                              if (current > 0) setState(() => _quantities[item.id] = current - 1);
                            },
                            onPlus: () {
                              final current = _quantities[item.id] ?? 0;
                              if (current < item.remainingReturnable) {
                                setState(() => _quantities[item.id] = current + 1);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (sale.type == SaleType.paid) ...[
              DashSectionTitle(l10n.salesRefundMethod),
              PaymentMethodTiles(selected: _refundMethod, onSelected: (m) => setState(() => _refundMethod = m)),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              decoration: InputDecoration(
                labelText: l10n.commonReasonOptional,
                prefixIcon: const Icon(Icons.edit_note_rounded),
              ),
            ),
            const SizedBox(height: 16),
            DashCard(
              padding: const EdgeInsets.all(18),
              child: BillRow(
                label: l10n.salesReturn,
                value: CurrencyFormatter.format(_totalReturnAmount, sale.currency),
                strong: true,
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w700),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
