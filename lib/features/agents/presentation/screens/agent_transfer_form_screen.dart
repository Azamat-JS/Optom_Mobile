import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/agents/domain/entities/owner_agent.dart';
import 'package:bsmart/features/agents/domain/usecases/create_agent_transfer_usecase.dart';
import 'package:bsmart/features/agents/domain/usecases/list_transferable_products_usecase.dart';
import 'package:bsmart/features/agents/presentation/widgets/agent_format.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

double? _num(TextEditingController c) => double.tryParse(c.text.trim().replaceAll(',', '.'));

/// Fields here sit on white cards, so they take the grey page fill to stay visible.
InputDecoration _inCard(BuildContext context, String label, {String? hint}) =>
    InputDecoration(labelText: label, hintText: hint, filled: true, fillColor: DashColors.page(context));

/// One picked product: quantity and the selling range, prefilled with the lead agent's current
/// range for it, else its stock price.
class _Line {
  _Line(this.product)
    : qty = TextEditingController(),
      min = TextEditingController(text: agentQty(product.agentMinPrice ?? product.price)),
      max = TextEditingController(text: agentQty(product.agentMaxPrice ?? product.price));

  final TransferableProduct product;
  final TextEditingController qty;
  final TextEditingController min;
  final TextEditingController max;

  void dispose() {
    qty.dispose();
    min.dispose();
    max.dispose();
  }
}

/// "Mahsulot berish" (owner): pick several products of the lead agent's store (one currency per
/// transfer), a quantity and a min–max selling price for each, and how much was paid now. The lead
/// agent owes each product's stock price; the unpaid rest becomes its debt. Pops `true` once given.
class AgentTransferFormScreen extends StatefulWidget {
  const AgentTransferFormScreen({required this.leadId, required this.leadName, super.key});

  final String leadId;
  final String leadName;

  @override
  State<AgentTransferFormScreen> createState() => _AgentTransferFormScreenState();
}

class _AgentTransferFormScreenState extends State<AgentTransferFormScreen> {
  final _search = TextEditingController();
  final _paid = TextEditingController();
  final _notes = TextEditingController();
  final List<_Line> _lines = [];
  List<TransferableProduct>? _results;
  Object? _loadError;
  Timer? _debounce;
  bool _busy = false;
  String? _error;

  Currency? get _currency => _lines.isEmpty ? null : _lines.first.product.currency;

  double get _total => _lines.fold(0, (sum, l) => sum + (_num(l.qty) ?? 0) * l.product.price);

  @override
  void initState() {
    super.initState();
    _load('');
    _paid.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    _paid.dispose();
    _notes.dispose();
    for (final l in _lines) {
      l.dispose();
    }
    super.dispose();
  }

  Future<void> _load(String search) async {
    final result = await getIt<ListTransferableProductsUseCase>().call(widget.leadId, search: search);
    if (!mounted) return;
    setState(
      () => result.fold((page) {
        _results = page.data;
        _loadError = null;
      }, (failure) => _loadError = failure),
    );
  }

  void _onSearch(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _load(text.trim()));
  }

  void _toggle(TransferableProduct p) {
    final i = _lines.indexWhere((l) => l.product.product.id == p.product.id);
    setState(() {
      _error = null;
      if (i >= 0) {
        _lines.removeAt(i).dispose();
      } else {
        HapticFeedback.selectionClick();
        final line = _Line(p);
        line.qty.addListener(() => setState(() {}));
        line.min.addListener(() => setState(() {}));
        _lines.add(line);
      }
    });
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    if (_lines.isEmpty) return setState(() => _error = l10n.ownerTransferPickOne);
    final params = <AgentTransferLineParams>[];
    for (final l in _lines) {
      final name = l.product.product.name;
      final qty = _num(l.qty);
      if (qty == null || qty <= 0) return setState(() => _error = l10n.agentQtyInvalid(name));
      if (qty > l.product.stock + 0.0005) {
        return setState(() => _error = l10n.agentQtyTooMuch(name, agentQty(l.product.stock, l.product.product.unit)));
      }
      final min = _num(l.min);
      final max = _num(l.max);
      if (min == null || max == null || min <= 0 || max <= 0) {
        return setState(() => _error = l10n.ownerPriceInvalid(name));
      }
      if (min > max) return setState(() => _error = l10n.ownerRangeInvalid(name));
      params.add(AgentTransferLineParams(productId: l.product.product.id, quantity: qty, minPrice: min, maxPrice: max));
    }
    final paid = _paid.text.trim().isEmpty ? 0.0 : _num(_paid);
    if (paid == null || paid < 0) return setState(() => _error = l10n.agentPayInvalid);
    if (paid > _total + 0.0005) return setState(() => _error = l10n.ownerTransferPaidTooMuch);

    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await getIt<CreateAgentTransferUseCase>().call(
      CreateAgentTransferParams(leadAgentId: widget.leadId, lines: params, paidAmount: paid, notes: _notes.text.trim()),
    );
    if (!mounted) return;
    result.fold(
      (_) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.ownerTransferDone)));
        Navigator.of(context).pop(true);
      },
      (failure) => setState(() {
        _busy = false;
        _error = failure.message;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final currency = _currency;
    final results = _results;
    String money(double v, Currency c) => CurrencyFormatter.format(v, c);
    final debt = (_total - (_num(_paid) ?? 0)).clamp(0, double.infinity).toDouble();

    return DashPage(
      title: l10n.ownerGiveProducts,
      bottomBar: DashBottomButton(
        label: l10n.ownerTransferSubmit(_lines.length),
        icon: Icons.local_shipping_rounded,
        busy: _busy,
        onPressed: _submit,
      ),
      body: DashFormTheme(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            Text(
              widget.leadName,
              style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w600),
            ),
            if (_lines.isNotEmpty) ...[
              DashSectionTitle(l10n.ownerTransferPicked),
              for (final line in _lines) ...[
                _LineEditor(line: line, onRemove: () => _toggle(line.product)),
                const SizedBox(height: 10),
              ],
              DashCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BillRow(label: l10n.commonTotal, value: money(_total, currency!), strong: true),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _paid,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: _inCard(context, l10n.ownerTransferPaid, hint: '0'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.ownerTransferDebtLine(money(debt, currency)),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: debt > 0 ? Theme.of(context).colorScheme.error : colors.success,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(controller: _notes, decoration: _inCard(context, l10n.commonNoteOptional)),
                  ],
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
            ],
            const SizedBox(height: 16),
            DashSearchField(controller: _search, hint: l10n.commonSearchHint, onChanged: _onSearch),
            if (currency != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
                child: Text(l10n.ownerTransferOneCurrency, style: TextStyle(fontSize: 12, color: colors.textMuted)),
              ),
            const SizedBox(height: 10),
            if (results == null)
              _loadError != null
                  ? DashEmptyState(icon: Icons.cloud_off_rounded, text: l10n.commonErrorWith('$_loadError'))
                  : const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: CircularProgressIndicator()),
                    )
            else if (results.isEmpty)
              DashEmptyState(icon: Icons.inventory_2_outlined, text: l10n.ownerTransferEmpty)
            else
              for (final p in results) ...[
                _ProductRow(
                  product: p,
                  picked: _lines.any((l) => l.product.product.id == p.product.id),
                  enabled: currency == null || p.currency == currency,
                  onTap: () => _toggle(p),
                ),
                const SizedBox(height: 8),
              ],
            if (_lines.isEmpty && _error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.product, required this.picked, required this.enabled, required this.onTap});

  final TransferableProduct product;
  final bool picked;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final p = product;
    final unit = p.product.unit;
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: DashCard(
        padding: const EdgeInsets.all(12),
        onTap: enabled ? onTap : null,
        child: Row(
          children: [
            DashThumb(url: p.product.imageUrl, size: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    [
                      CurrencyFormatter.format(p.price, p.currency),
                      l10n.ownerTransferInStock(agentQty(p.stock, unit)),
                      if ((p.agentStock ?? 0) > 0) l10n.ownerTransferHeld(agentQty(p.agentStock!, unit)),
                    ].join(' · '),
                    style: TextStyle(fontSize: 12, color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(
              picked ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
              color: picked ? colors.success : colors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _LineEditor extends StatelessWidget {
  const _LineEditor({required this.line, required this.onRemove});

  final _Line line;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final p = line.product;
    String money(double v) => CurrencyFormatter.format(v, p.currency);
    final min = _num(line.min);
    final belowPrice = min != null && min < p.price;
    final qty = _num(line.qty) ?? 0;

    return DashCard(
      padding: const EdgeInsets.fromLTRB(14, 10, 6, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  p.product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: Icon(Icons.close_rounded, color: colors.textSecondary),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              [
                l10n.agentTransferOwed(money(p.price)),
                l10n.ownerTransferInStock(agentQty(p.stock, p.product.unit)),
                if (qty > 0) money(qty * p.price),
              ].join(' · '),
              style: TextStyle(fontSize: 12, color: colors.textSecondary),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: line.qty,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: _inCard(context, l10n.agentQuantity),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: line.min,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: _inCard(context, l10n.ownerMinPrice),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: line.max,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: _inCard(context, l10n.ownerMaxPrice),
                      ),
                    ),
                  ],
                ),
                if (belowPrice) ...[
                  const SizedBox(height: 6),
                  Text(l10n.ownerMinBelowPrice, style: TextStyle(fontSize: 12, color: colors.accentText)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
