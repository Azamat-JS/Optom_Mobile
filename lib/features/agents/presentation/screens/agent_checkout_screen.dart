import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/agents/domain/entities/agent_sale_params.dart';
import 'package:bsmart/features/agents/domain/usecases/create_agent_sale_usecase.dart';
import 'package:bsmart/features/agents/presentation/providers/agent_cart_notifier.dart';
import 'package:bsmart/features/agents/presentation/providers/agent_dashboard_providers.dart';
import 'package:bsmart/features/agents/presentation/providers/agent_debts_list_notifier.dart';
import 'package:bsmart/features/agents/presentation/providers/agent_sales_list_notifier.dart';
import 'package:bsmart/features/agents/presentation/providers/agent_stock_notifier.dart';
import 'package:bsmart/features/agents/presentation/widgets/agent_format.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// Checkout for an agent sale: quantity and price per line (price within the owner's range,
/// re-checked by the server), cash or debt, and the buyer — required on debt, where a phone
/// already on file reuses that customer. A debt can be partly paid up front (cash), like the
/// owner's POS; only the rest is owed.
class AgentCheckoutScreen extends ConsumerStatefulWidget {
  const AgentCheckoutScreen({super.key});

  @override
  ConsumerState<AgentCheckoutScreen> createState() => _AgentCheckoutScreenState();
}

class _AgentCheckoutScreenState extends ConsumerState<AgentCheckoutScreen> {
  final _qty = <String, TextEditingController>{};
  final _price = <String, TextEditingController>{};
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _phone = TextEditingController(text: '+998');
  final _notes = TextEditingController();
  final _paid = TextEditingController();
  AgentPaymentType _type = AgentPaymentType.cash;
  bool _busy = false;

  @override
  void dispose() {
    for (final c in [..._qty.values, ..._price.values, _firstName, _lastName, _phone, _notes, _paid]) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _controller(Map<String, TextEditingController> map, String id, String initial) =>
      map.putIfAbsent(id, () => TextEditingController(text: initial));

  double? _num(TextEditingController c) => double.tryParse(c.text.trim().replaceAll(',', '.'));

  void _snack(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _submit(List<AgentCartLine> lines) async {
    final l10n = context.l10n;
    for (final line in lines) {
      final name = line.item.product.name;
      final qty = line.quantity;
      String money(double v) => CurrencyFormatter.format(v, line.item.currency);
      if (!(qty > 0)) return _snack(l10n.agentQtyInvalid(name));
      if (qty > line.item.stock + 0.0005) return _snack(l10n.agentQtyTooMuch(name, agentQty(line.item.stock)));
      if (!line.item.allows(line.unitPrice)) {
        return _snack(l10n.agentPriceOutOfRange(name, money(line.item.minPrice), money(line.item.maxPrice)));
      }
    }
    final phone = _phone.text.replaceAll(RegExp(r'[\s()-]'), '');
    final hasName = _firstName.text.trim().isNotEmpty;
    final phoneOk = RegExp(r'^\+?\d{9,15}$').hasMatch(phone);
    final typedCustomer = hasName || phone.replaceAll(RegExp(r'\D'), '').length > 3;
    if (_type == AgentPaymentType.debt && !(hasName && phoneOk)) return _snack(l10n.agentDebtNeedsCustomer);
    if (typedCustomer && !(hasName && phoneOk)) return _snack(l10n.agentPhoneInvalid);
    final isDebt = _type == AgentPaymentType.debt;
    final total = lines.fold<double>(0, (s, l) => s + l.total);
    final paid = _paid.text.trim().isEmpty ? 0.0 : _num(_paid);
    if (isDebt && (paid == null || paid < 0)) return _snack(l10n.agentPayInvalid);
    if (isDebt && paid! > total + 0.0005) return _snack(l10n.ownerTransferPaidTooMuch);

    setState(() => _busy = true);
    final result = await getIt<CreateAgentSaleUseCase>().call(
      CreateAgentSaleParams(
        lines: [
          for (final l in lines)
            AgentSaleLineParams(agentProductId: l.item.id, quantity: l.quantity, unitPrice: l.unitPrice),
        ],
        paymentType: _type,
        customer: hasName && phoneOk
            ? AgentSaleCustomerParams(firstName: _firstName.text.trim(), lastName: _lastName.text.trim(), phone: phone)
            : null,
        paidAmount: isDebt ? paid : null,
        notes: _notes.text.trim(),
      ),
    );
    if (!mounted) return;
    setState(() => _busy = false);
    result.fold((_) {
      HapticFeedback.mediumImpact();
      ref.read(agentCartProvider.notifier).clear();
      ref.read(agentStockProvider.notifier).refresh();
      ref.read(agentSalesListProvider.notifier).refresh();
      ref.read(agentDebtsListProvider.notifier).refresh();
      ref.read(agentSummaryProvider.notifier).refresh();
      ref.invalidate(agentProfitProvider);
      _snack(l10n.agentSold);
      Navigator.of(context).pop();
    }, (failure) => _snack(failure.message));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final lines = ref.watch(agentCartProvider);
    final cart = ref.read(agentCartProvider.notifier);
    if (lines.isEmpty) {
      // The last line was removed — nothing left to check out.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).maybePop();
      });
      return const SizedBox.shrink();
    }
    final currency = lines.first.item.currency;
    final total = lines.fold<double>(0, (s, l) => s + l.total);
    String money(double v) => CurrencyFormatter.format(v, currency);
    final isDebt = _type == AgentPaymentType.debt;
    final paidNow = isDebt ? (_num(_paid) ?? 0).clamp(0, total).toDouble() : 0.0;

    return DashPage(
      title: l10n.agentCheckoutTitle,
      bottomBar: DashBottomButton(
        label: l10n.agentSellNow(money(total)),
        busy: _busy,
        onPressed: _busy ? null : () => _submit(lines),
      ),
      body: DashFormTheme(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            for (final line in lines) ...[
              DashCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        DashThumb(url: line.item.product.imageUrl, size: 40),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            line.item.product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          tooltip: l10n.commonDelete,
                          onPressed: () => cart.remove(line.item.id),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller(_qty, line.item.id, agentQty(line.quantity)),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(labelText: l10n.agentQuantity),
                            onChanged: (_) => cart.update(line.item.id, quantity: _num(_qty[line.item.id]!) ?? 0),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _controller(_price, line.item.id, agentQty(line.unitPrice)),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(labelText: l10n.agentPrice),
                            onChanged: (_) => cart.update(line.item.id, unitPrice: _num(_price[line.item.id]!) ?? 0),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Full width: under a half-width field the range got cut off.
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.agentStockLeft(agentQty(line.item.stock, line.item.product.unit)),
                            style: TextStyle(fontSize: 12, color: colors.textSecondary),
                          ),
                        ),
                        Text(
                          l10n.agentPriceRange(money(line.item.minPrice), money(line.item.maxPrice)),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: line.item.allows(line.unitPrice)
                                ? colors.textSecondary
                                : Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 6),
            PillToggle<AgentPaymentType>(
              values: AgentPaymentType.values,
              selected: _type,
              expand: true,
              label: (t) => t == AgentPaymentType.cash ? l10n.agentCash : l10n.agentDebt,
              onChanged: (t) => setState(() => _type = t),
            ),
            if (isDebt) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _paid,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: l10n.salesDownPaymentOptional,
                  prefixIcon: const Icon(Icons.savings_rounded),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ],
            DashSectionTitle(l10n.agentCustomer),
            Text(
              _type == AgentPaymentType.debt ? l10n.agentReturningDebtorHint : l10n.agentCustomerOptional,
              style: TextStyle(fontSize: 12, color: colors.textSecondary),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _firstName,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(labelText: l10n.agentCustomerName),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _lastName,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(labelText: l10n.agentCustomerLastName),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: l10n.agentCustomerPhone),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _notes,
              maxLines: 2,
              decoration: InputDecoration(labelText: l10n.commonNote),
            ),
            const SizedBox(height: 16),
            DashCard(
              child: Column(
                children: [
                  if (isDebt) ...[
                    BillRow(label: l10n.commonPaid, value: money(paidNow), muted: true),
                    const SizedBox(height: 8),
                    BillRow(label: l10n.salesDebtLeft, value: money(total - paidNow), muted: true),
                    const SizedBox(height: 12),
                    DashedDivider(color: colors.outline),
                    const SizedBox(height: 12),
                  ],
                  BillRow(label: l10n.commonTotal, value: money(total), strong: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
