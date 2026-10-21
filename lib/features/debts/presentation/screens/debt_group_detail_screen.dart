import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/enums/payment_method.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/debts/domain/entities/payment_write_params.dart';
import 'package:bsmart/features/debts/domain/usecases/close_debt_usecase.dart';
import 'package:bsmart/features/debts/domain/usecases/get_debt_usecase.dart';
import 'package:bsmart/features/debts/domain/usecases/get_sale_debt_usecase.dart';
import 'package:bsmart/features/debts/domain/usecases/pay_down_usecase.dart';
import 'package:bsmart/features/debts/presentation/widgets/debt_like.dart';
import 'package:bsmart/features/debts/presentation/widgets/debt_status_badge.dart';
import 'package:bsmart/features/debts/presentation/widgets/record_payment_sheet.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';
import 'package:bsmart/shared/widgets/payment_method_tiles.dart';

/// One person's (or notes-identified debtor's) aggregated debts in one
/// currency. Two ways to pay: a lump sum via FIFO (`POST /payments/pay-down`,
/// oldest debt first — this screen mirrors the backend's exact allocation
/// order client-side so the "preview" shown before confirming is always
/// correct, not just illustrative) or a payment against one specific debt
/// (`RecordPaymentSheet`, `POST /payments`).
///
/// Phase 9 U4c3: balance card, pay-down (amount with "Barchasi", method
/// tiles, allocation preview with "yopiladi" tags), one card per debt.
class DebtGroupDetailScreen extends StatefulWidget {
  const DebtGroupDetailScreen({super.key, required this.group});

  final DebtGroup group;

  @override
  State<DebtGroupDetailScreen> createState() => _DebtGroupDetailScreenState();
}

class _DebtGroupDetailScreenState extends State<DebtGroupDetailScreen> {
  late DebtGroup _group = widget.group;
  final _payDownAmountController = TextEditingController();
  PaymentMethod _payDownMethod = PaymentMethod.cash;
  bool _isPayingDown = false;
  String? _payDownError;

  @override
  void dispose() {
    _payDownAmountController.dispose();
    super.dispose();
  }

  List<DebtLike> get _activeItemsOldestFirst {
    final active = _group.items.where((i) => !i.isSettled).toList();
    active.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return active;
  }

  /// Mirrors `PaymentService.payDown()`'s allocation loop exactly (oldest
  /// debt first, applied up to each row's own balance) — see
  /// `payment.service.ts`. Purely a client-side preview; the server
  /// re-runs this same logic authoritatively on submit.
  List<(DebtLike, double)> _previewAllocation(double amount) {
    var remaining = amount;
    final allocations = <(DebtLike, double)>[];
    for (final item in _activeItemsOldestFirst) {
      if (remaining <= 0) break;
      final applied = remaining < item.balance ? remaining : item.balance;
      if (applied <= 0) continue;
      allocations.add((item, applied));
      remaining -= applied;
    }
    return allocations;
  }

  Future<void> _refreshGroup() async {
    final updatedItems = <DebtLike>[];
    for (final item in _group.items) {
      if (item.kind == DebtKind.b2b) {
        final result = await getIt<GetDebtUseCase>().call(item.id);
        result.fold((debt) => updatedItems.add(DebtLike.fromDebt(debt)), (_) => updatedItems.add(item));
      } else {
        final result = await getIt<GetSaleDebtUseCase>().call(item.id);
        result.fold((debt) => updatedItems.add(DebtLike.fromSaleDebt(debt)), (_) => updatedItems.add(item));
      }
    }
    if (!mounted) return;
    setState(() {
      _group = DebtGroup(
        kind: _group.kind,
        personId: _group.personId,
        personNotesKey: _group.personNotesKey,
        personName: _group.personName,
        personPhone: _group.personPhone,
        currency: _group.currency,
        items: updatedItems,
        viewerIsDebtor: _group.viewerIsDebtor,
      );
    });
  }

  Future<void> _submitPayDown(double amount) async {
    setState(() {
      _isPayingDown = true;
      _payDownError = null;
    });

    final result = await getIt<PayDownUseCase>().call(
      PayDownParams(
        debtorId: _group.kind == DebtKind.b2b ? _group.personId : null,
        debtorNotes: _group.kind == DebtKind.b2b ? _group.personNotesKey : null,
        customerId: _group.kind == DebtKind.saleDebt ? _group.personId : null,
        amount: amount,
        currency: _group.currency,
        method: _payDownMethod,
      ),
    );
    if (!mounted) return;
    result.fold(
      (payDownResult) async {
        _payDownAmountController.clear();
        setState(() => _isPayingDown = false);
        await _refreshGroup();
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.debtsPaymentsApplied(payDownResult.paymentCount))));
      },
      (failure) => setState(() {
        _isPayingDown = false;
        _payDownError = failure.message;
      }),
    );
  }

  Future<void> _recordSinglePayment(DebtLike item) async {
    final saved = await RecordPaymentSheet.show(context, item);
    if (saved == true) _refreshGroup();
  }

  Future<void> _closeDebt(DebtLike item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.debtsCloseTitle),
        content: Text(context.l10n.debtsCloseConfirm(CurrencyFormatter.format(item.balance, item.currency))),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(context.l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(context.l10n.commonClose)),
        ],
      ),
    );
    if (confirmed != true) return;
    final result = await getIt<CloseDebtUseCase>().call(item.id, const CloseDebtParams());
    if (!mounted) return;
    result.fold(
      (_) => _refreshGroup(),
      (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }

  static final _dateFormat = DateFormat('dd.MM.yyyy');

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final error = Theme.of(context).colorScheme.error;
    final amount = double.tryParse(_payDownAmountController.text.trim());
    final preview = (amount != null && amount > 0) ? _previewAllocation(amount) : const <(DebtLike, double)>[];
    final totalActiveBalance = _activeItemsOldestFirst.fold<double>(0, (sum, i) => sum + i.balance);
    String money(double v) => CurrencyFormatter.format(v, _group.currency);
    final canPay = totalActiveBalance > 0 && !_group.viewerIsDebtor;

    return DashPage(
      title: _group.personName,
      body: DashFormTheme(
        child: RefreshIndicator(
          color: AppColors.onBrand,
          backgroundColor: AppColors.brandYellow,
          onRefresh: _refreshGroup,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              DashCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.commonBalance,
                      style: TextStyle(color: colors.textSecondary, fontSize: 14.5, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        money(totalActiveBalance),
                        style: TextStyle(
                          color: totalActiveBalance > 0 ? error : AppColors.success,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        l10n.debtsActiveCount(_activeItemsOldestFirst.length),
                        if (_group.personPhone != null) _group.personPhone!,
                      ].join(' · '),
                      style: TextStyle(color: colors.textMuted, fontSize: 13.5, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              if (canPay) ...[
                DashSectionTitle(l10n.debtsPayDownTitle),
                Text(
                  l10n.debtsPayDownHint,
                  style: TextStyle(color: colors.textMuted, fontSize: 13.5, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _payDownAmountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(color: colors.textPrimary, fontSize: 17, fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    labelText: l10n.commonAmount,
                    prefixIcon: const Icon(Icons.payments_rounded),
                    suffixIcon: TextButton(
                      onPressed: () => setState(
                        () => _payDownAmountController.text = totalActiveBalance.toStringAsFixed(
                          totalActiveBalance == totalActiveBalance.truncateToDouble() ? 0 : 2,
                        ),
                      ),
                      child: Text(l10n.commonAll),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                PaymentMethodTiles(selected: _payDownMethod, onSelected: (m) => setState(() => _payDownMethod = m)),
                if (preview.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  DashCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.debtsAllocation,
                          style: TextStyle(color: colors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        for (final (item, applied) in preview)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Text(
                                  _dateFormat.format(item.createdAt.toLocal()),
                                  style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w600),
                                ),
                                const Spacer(),
                                if (applied >= item.balance) ...[
                                  DashTag(label: l10n.debtsWillClose, color: AppColors.success),
                                  const SizedBox(width: 8),
                                ],
                                Text(
                                  money(applied),
                                  style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          ),
                        if (amount != null && amount > totalActiveBalance)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              l10n.debtsExceedsTotal,
                              style: TextStyle(color: error, fontWeight: FontWeight.w700),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
                if (_payDownError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _payDownError!,
                    style: TextStyle(color: error, fontWeight: FontWeight.w700),
                  ),
                ],
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: (_isPayingDown || amount == null || amount <= 0 || amount > totalActiveBalance)
                      ? null
                      : () => _submitPayDown(amount),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: _isPayingDown
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(l10n.debtsConfirmPayment),
                ),
              ],
              DashSectionTitle(l10n.debtsItemsTitle),
              for (final (i, item) in _group.items.indexed) ...[
                if (i > 0) const SizedBox(height: 10),
                _DebtItemCard(
                  item: item,
                  canAct: !item.isSettled && !_group.viewerIsDebtor,
                  onPay: () => _recordSinglePayment(item),
                  onClose: item.kind == DebtKind.b2b ? () => _closeDebt(item) : null,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// One debt: date + status, original amount, balance, due date, and (for the
/// creditor) "To'lov" / "Yopish".
class _DebtItemCard extends StatelessWidget {
  const _DebtItemCard({required this.item, required this.canAct, required this.onPay, this.onClose});

  final DebtLike item;
  final bool canAct;
  final VoidCallback onPay;
  final VoidCallback? onClose;

  static final _dateFormat = DateFormat('dd.MM.yyyy HH:mm');

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    String money(double v) => CurrencyFormatter.format(v, item.currency);
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));
    return DashCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _dateFormat.format(item.createdAt.toLocal()),
                  style: TextStyle(color: colors.textMuted, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
              DebtStatusBadge(status: item.status),
            ],
          ),
          const SizedBox(height: 10),
          BillRow(label: l10n.debtsOriginal, value: money(item.originalAmount), muted: true),
          const SizedBox(height: 4),
          BillRow(label: l10n.commonBalance, value: money(item.balance), strong: true),
          if (item.dueDate != null) ...[
            const SizedBox(height: 6),
            Text(
              l10n.commonDueWith(DateFormat('dd.MM.yyyy').format(item.dueDate!.toLocal())),
              style: TextStyle(color: colors.textMuted, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
          if (canAct) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onPay,
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(44), shape: shape),
                    icon: const Icon(Icons.payments_rounded, size: 18),
                    label: Text(l10n.debtsPayment),
                  ),
                ),
                if (onClose != null) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onClose,
                      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(44), shape: shape),
                      icon: const Icon(Icons.done_all_rounded, size: 18),
                      label: Text(l10n.commonClose),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
