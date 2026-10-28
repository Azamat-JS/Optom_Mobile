import 'package:flutter/material.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/features/agents/domain/entities/agent_requests.dart';
import 'package:bsmart/features/agents/domain/entities/agent_stock_item.dart';
import 'package:bsmart/features/agents/domain/usecases/list_agent_stock_usecase.dart';
import 'package:bsmart/features/agents/domain/usecases/send_agent_return_usecase.dart';
import 'package:bsmart/features/agents/presentation/widgets/agent_format.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// "Mahsulot qaytarish": a quantity per product the lead agent holds, one currency per return.
/// The units leave its stock as soon as the request is sent (the owner confirms or rejects it).
/// Pops `true` once sent.
class ReturnGoodsScreen extends StatefulWidget {
  const ReturnGoodsScreen({super.key});

  @override
  State<ReturnGoodsScreen> createState() => _ReturnGoodsScreenState();
}

class _ReturnGoodsScreenState extends State<ReturnGoodsScreen> {
  final _notes = TextEditingController();
  final Map<String, TextEditingController> _qty = {};
  List<AgentStockItem>? _items;
  Object? _loadError;
  Currency? _currency;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _notes.dispose();
    for (final c in _qty.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    // Its own fetch, not the Sell tab's provider: that one may be narrowed by a search.
    final result = await getIt<ListAgentStockUseCase>().call(limit: 200);
    if (!mounted) return;
    setState(
      () => result.fold((page) {
        _items = page.data;
        _currency = page.data.isEmpty ? null : page.data.first.currency;
      }, (failure) => _loadError = failure),
    );
  }

  TextEditingController _controllerFor(String id) => _qty.putIfAbsent(id, () {
        final c = TextEditingController();
        // Re-count the button label; an earlier error no longer applies once a quantity changes.
        c.addListener(() => setState(() => _error = null));
        return c;
      });

  double? _parse(String id) => double.tryParse((_qty[id]?.text ?? '').trim().replaceAll(',', '.'));

  List<AgentStockItem> get _shown => [
        for (final item in _items ?? const <AgentStockItem>[])
          if (item.currency == _currency) item,
      ];

  int get _pickedCount => _shown.where((i) => (_parse(i.id) ?? 0) > 0).length;

  Future<void> _submit() async {
    final l10n = context.l10n;
    final lines = <AgentReturnLineParams>[];
    for (final item in _shown) {
      final text = _qty[item.id]?.text.trim() ?? '';
      if (text.isEmpty) continue;
      final qty = _parse(item.id);
      if (qty == null || qty < 0) return setState(() => _error = l10n.agentQtyInvalid(item.product.name));
      if (qty == 0) continue;
      if (qty > item.stock + 0.0005) {
        return setState(() => _error = l10n.agentQtyTooMuch(item.product.name, agentQty(item.stock, item.product.unit)));
      }
      lines.add(AgentReturnLineParams(agentProductId: item.id, quantity: qty));
    }
    if (lines.isEmpty) return setState(() => _error = l10n.agentReturnPickOne);

    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await getIt<SendAgentReturnUseCase>().call(lines, notes: _notes.text.trim());
    if (!mounted) return;
    result.fold(
      (_) => Navigator.of(context).pop(true),
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
    final items = _items;
    final currencies = {for (final i in items ?? const <AgentStockItem>[]) i.currency}.toList()
      ..sort((a, b) => a.index.compareTo(b.index));

    return DashPage(
      title: l10n.agentReturnGoods,
      bottomBar: items == null || items.isEmpty
          ? null
          : DashBottomButton(
              label: l10n.agentReturnSend(_pickedCount),
              icon: Icons.assignment_return_rounded,
              busy: _busy,
              onPressed: _submit,
            ),
      body: items == null
          ? (_loadError != null
                ? DashEmptyState(icon: Icons.cloud_off_rounded, text: l10n.commonErrorWith('$_loadError'))
                : const Center(child: CircularProgressIndicator()))
          : items.isEmpty
          ? DashEmptyState(icon: Icons.inventory_2_outlined, text: l10n.agentNoStock)
          : DashFormTheme(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                children: [
                  Text(l10n.agentReturnHint, style: TextStyle(color: colors.textSecondary)),
                  if (currencies.length > 1) ...[
                    const SizedBox(height: 12),
                    PillToggle<Currency>(
                      values: currencies,
                      selected: _currency!,
                      expand: true,
                      label: (c) => c.toWire(),
                      onChanged: (c) => setState(() {
                        _currency = c;
                        _error = null;
                      }),
                    ),
                  ],
                  const SizedBox(height: 12),
                  for (final item in _shown) ...[
                    DashCard(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          DashThumb(url: item.product.imageUrl, size: 44),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  l10n.agentStockLeft(agentQty(item.stock, item.product.unit)),
                                  style: TextStyle(fontSize: 12, color: colors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 96,
                            child: TextField(
                              controller: _controllerFor(item.id),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                              // No label (it doesn't fit); the grey fill sets it apart from the card.
                              decoration: InputDecoration(
                                hintText: '0',
                                filled: true,
                                fillColor: DashColors.page(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  TextField(
                    controller: _notes,
                    decoration: InputDecoration(labelText: l10n.commonNoteOptional),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ],
                ],
              ),
            ),
    );
  }
}
