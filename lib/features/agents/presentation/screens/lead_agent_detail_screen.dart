import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/agents/domain/entities/agent_account_user.dart';
import 'package:bsmart/features/agents/domain/entities/agent_requests.dart';
import 'package:bsmart/features/agents/domain/entities/agent_stock_item.dart';
import 'package:bsmart/features/agents/domain/entities/owner_agent.dart';
import 'package:bsmart/features/agents/domain/usecases/confirm_agent_payment_usecase.dart';
import 'package:bsmart/features/agents/domain/usecases/list_lead_payments_usecase.dart';
import 'package:bsmart/features/agents/domain/usecases/list_lead_returns_usecase.dart';
import 'package:bsmart/features/agents/domain/usecases/list_lead_stock_usecase.dart';
import 'package:bsmart/features/agents/domain/usecases/list_lead_transfers_usecase.dart';
import 'package:bsmart/features/agents/domain/usecases/list_team_debts_usecase.dart';
import 'package:bsmart/features/agents/domain/usecases/list_team_sales_usecase.dart';
import 'package:bsmart/features/agents/domain/usecases/reject_agent_payment_usecase.dart';
import 'package:bsmart/features/agents/domain/usecases/update_agent_price_range_usecase.dart';
import 'package:bsmart/features/agents/presentation/providers/owner_agent_providers.dart';
import 'package:bsmart/features/agents/presentation/screens/agent_debts_tab.dart';
import 'package:bsmart/features/agents/presentation/screens/agent_return_detail_screen.dart';
import 'package:bsmart/features/agents/presentation/screens/agent_sales_tab.dart';
import 'package:bsmart/features/agents/presentation/screens/agent_transfer_detail_screen.dart';
import 'package:bsmart/features/agents/presentation/screens/agent_transfer_form_screen.dart';
import 'package:bsmart/features/agents/presentation/widgets/agent_format.dart';
import 'package:bsmart/features/agents/presentation/widgets/agent_money.dart';
import 'package:bsmart/features/agents/presentation/widgets/agent_paged_column.dart';
import 'package:bsmart/features/agents/presentation/widgets/agent_request_cards.dart';
import 'package:bsmart/features/agents/presentation/widgets/owner_decision_dialogs.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

enum _Tab { stock, transfers, payments, returns, sales, debts }

/// One lead agent, as its business owner sees it: what it owes and holds, its team's sales and
/// customer debts (read-only), handing it products, its price ranges, and deciding on its
/// payments and returns.
class LeadAgentDetailScreen extends ConsumerStatefulWidget {
  const LeadAgentDetailScreen({required this.lead, super.key});

  final AgentAccountUser lead;

  @override
  ConsumerState<LeadAgentDetailScreen> createState() => _LeadAgentDetailScreenState();
}

class _LeadAgentDetailScreenState extends ConsumerState<LeadAgentDetailScreen> {
  _Tab _tab = _Tab.stock;
  bool _openDebtsOnly = true;

  /// Bumped after any change, so the open tab reloads from page 1.
  int _tick = 0;

  String get _id => widget.lead.id;

  void _snack(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _refresh() async {
    ref.invalidate(leadAgentSummaryProvider(_id));
    ref.invalidate(leadTeamSummaryProvider(_id));
    setState(() => _tick++);
    try {
      await ref.read(leadAgentSummaryProvider(_id).future);
    } catch (_) {
      // Shown by the page's error state.
    }
  }

  Future<void> _give() async {
    final given = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AgentTransferFormScreen(leadId: _id, leadName: widget.lead.fullName),
      ),
    );
    if (given != true || !mounted) return;
    setState(() => _tab = _Tab.transfers);
    await _refresh();
  }

  Future<void> _editRange(AgentStockItem item) async {
    final l10n = context.l10n;
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _PriceRangeDialog(leadId: _id, item: item),
    );
    if (saved == true && mounted) {
      _snack(l10n.ownerRangeUpdated);
      setState(() => _tick++);
    }
  }

  Future<void> _decidePayment(AgentPaymentRequest p, {required bool confirm}) async {
    final l10n = context.l10n;
    Result<void> result;
    if (confirm) {
      final ok = await askOwnerConfirm(
        context,
        title: l10n.ownerConfirmPaymentTitle,
        text: l10n.ownerConfirmPaymentText(widget.lead.fullName, CurrencyFormatter.format(p.amount, p.currency)),
      );
      if (!ok) return;
      result = await getIt<ConfirmAgentPaymentUseCase>().call(p.id);
    } else {
      final reason = await askRejectReason(context);
      if (reason == null) return;
      result = await getIt<RejectAgentPaymentUseCase>().call(p.id, reason: reason);
    }
    if (!mounted) return;
    result.fold((_) {
      _snack(confirm ? l10n.ownerConfirmed : l10n.ownerRejected);
      _refresh();
    }, (failure) => _snack(failure.message));
  }

  Future<void> _openReturn(AgentReturn r, LeadAgentSummary summary) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AgentReturnDetailScreen(returnId: r.id, ownerDebt: summary.debt),
      ),
    );
    if (changed == true && mounted) await _refresh();
  }

  static Never _fail(Object failure) => throw failure;

  Widget _tabContent(LeadAgentSummary summary) {
    final l10n = context.l10n;
    final key = ValueKey('${_tab.name}-$_tick-$_openDebtsOnly');
    switch (_tab) {
      case _Tab.stock:
        return AgentPagedColumn<AgentStockItem>(
          key: key,
          load: (page) async => (await getIt<ListLeadStockUseCase>().call(
            _id,
            page: page,
          )).fold((r) => (items: r.data, hasNext: r.meta.hasNext), _fail),
          emptyIcon: Icons.inventory_2_outlined,
          emptyText: l10n.ownerStockEmpty,
          itemBuilder: (context, item) => _StockCard(item: item, onEdit: () => _editRange(item)),
        );
      case _Tab.transfers:
        return AgentPagedColumn(
          key: key,
          load: (page) async => (await getIt<ListLeadTransfersUseCase>().call(
            _id,
            page: page,
          )).fold((r) => (items: r.data, hasNext: r.meta.hasNext), _fail),
          emptyIcon: Icons.local_shipping_outlined,
          emptyText: l10n.agentTransfersEmpty,
          itemBuilder: (context, t) => AgentTransferCard(
            transfer: t,
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute<void>(builder: (_) => AgentTransferDetailScreen(transferId: t.id))),
          ),
        );
      case _Tab.payments:
        return AgentPagedColumn<AgentPaymentRequest>(
          key: key,
          load: (page) async => (await getIt<ListLeadPaymentsUseCase>().call(
            _id,
            page: page,
          )).fold((r) => (items: r.data, hasNext: r.meta.hasNext), _fail),
          emptyIcon: Icons.payments_outlined,
          emptyText: l10n.agentPaymentsEmpty,
          itemBuilder: (context, p) => AgentPaymentRequestCard(
            request: p,
            actions: [
              if (p.status == AgentRequestStatus.pending) ...[
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                  onPressed: () => _decidePayment(p, confirm: false),
                  child: Text(l10n.ownerReject),
                ),
                FilledButton(onPressed: () => _decidePayment(p, confirm: true), child: Text(l10n.ownerConfirm)),
              ],
            ],
          ),
        );
      case _Tab.returns:
        return AgentPagedColumn<AgentReturn>(
          key: key,
          load: (page) async => (await getIt<ListLeadReturnsUseCase>().call(
            _id,
            page: page,
          )).fold((r) => (items: r.data, hasNext: r.meta.hasNext), _fail),
          emptyIcon: Icons.assignment_return_outlined,
          emptyText: l10n.agentReturnsEmpty,
          itemBuilder: (context, r) => AgentReturnCard(ret: r, onTap: () => _openReturn(r, summary)),
        );
      case _Tab.sales:
        return AgentPagedColumn(
          key: key,
          load: (page) async => (await getIt<ListTeamSalesUseCase>().call(
            _id,
            page: page,
          )).fold((r) => (items: r.data, hasNext: r.meta.hasNext), _fail),
          emptyIcon: Icons.receipt_long_outlined,
          emptyText: l10n.agentSalesEmpty,
          itemBuilder: (context, sale) => AgentSaleCard(sale: sale, showSeller: true, leadAgentId: _id),
        );
      case _Tab.debts:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PillToggle<bool>(
              values: const [true, false],
              selected: _openDebtsOnly,
              expand: true,
              label: (open) => open ? l10n.agentDebtsOpen : l10n.agentDebtsAll,
              onChanged: (open) => setState(() => _openDebtsOnly = open),
            ),
            const SizedBox(height: 12),
            AgentPagedColumn(
              key: key,
              load: (page) async => (await getIt<ListTeamDebtsUseCase>().call(
                _id,
                openOnly: _openDebtsOnly,
                page: page,
              )).fold((r) => (items: r.items, hasNext: r.hasNext), _fail),
              emptyIcon: Icons.receipt_long_outlined,
              emptyText: l10n.agentDebtsEmpty,
              itemBuilder: (context, debt) => AgentDebtCard(debt: debt, showSeller: true, leadAgentId: _id),
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final summaryAsync = ref.watch(leadAgentSummaryProvider(_id));
    final summary = summaryAsync.valueOrNull;

    String tabLabel(_Tab t) => switch (t) {
      _Tab.stock => l10n.ownerTabStock,
      _Tab.transfers => l10n.ownerTabTransfers,
      _Tab.payments =>
        (summary?.pendingPayments ?? 0) > 0
            ? '${l10n.agentTabPayments} (${summary!.pendingPayments})'
            : l10n.agentTabPayments,
      _Tab.returns =>
        (summary?.pendingReturns ?? 0) > 0
            ? '${l10n.agentTabReturns} (${summary!.pendingReturns})'
            : l10n.agentTabReturns,
      _Tab.sales => l10n.agentTabSales,
      _Tab.debts => l10n.ownerTabCustomerDebts,
    };

    return DashPage(
      title: widget.lead.fullName,
      body: RefreshIndicator(
        color: AppColors.onBrand,
        backgroundColor: AppColors.brandYellow,
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
          children: [
            if (summary == null)
              summaryAsync.hasError
                  ? DashEmptyState(icon: Icons.cloud_off_rounded, text: l10n.commonErrorWith('${summaryAsync.error}'))
                  : const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()),
                    )
            else ...[
              _SummaryCard(summary: summary),
              const SizedBox(height: 12),
              FilledButton.icon(
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                onPressed: summary.isActive ? _give : null,
                icon: const Icon(Icons.local_shipping_rounded),
                label: Text(l10n.ownerGiveProducts),
              ),
              DashSectionTitle(l10n.ownerTeamTitle),
              _TeamCard(leadId: _id),
              const SizedBox(height: 18),
              DashChoiceChips<_Tab>(
                values: _Tab.values,
                selected: _tab,
                label: tabLabel,
                onSelected: (t) => setState(() => _tab = t),
              ),
              const SizedBox(height: 12),
              _tabContent(summary),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final LeadAgentSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final owes = summary.debt.uzs > 0 || summary.debt.usd > 0;
    return DashCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            [summary.phone, ?summary.storeName].join(' · '),
            style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.ownerLeadOwes,
            style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            agentMoneyBoth(summary.debt),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: owes ? Theme.of(context).colorScheme.error : colors.success,
            ),
          ),
          const SizedBox(height: 10),
          BillRow(label: l10n.ownerLeadStock, value: agentMoneyBoth(summary.stockValue)),
          BillRow(label: l10n.ownerLeadStaff, value: '${summary.staffCount}', muted: true),
        ],
      ),
    );
  }
}

class _TeamCard extends ConsumerWidget {
  const _TeamCard({required this.leadId});

  final String leadId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return DashCard(
      child: ref
          .watch(leadTeamSummaryProvider(leadId))
          .when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text(l10n.commonErrorWith('$error')),
            data: (team) => Column(
              children: [
                BillRow(
                  label: '${l10n.agentTodaySales} · ${l10n.agentSalesCount(team.todayCount)}',
                  value: agentMoneyBoth(team.todayRevenue),
                ),
                BillRow(
                  label: '${l10n.agentMonthSales} · ${l10n.agentSalesCount(team.monthCount)}',
                  value: agentMoneyBoth(team.monthRevenue),
                ),
                BillRow(
                  label: '${l10n.agentCustomersOwe} · ${l10n.agentOpenDebts(team.openDebtCount)}',
                  value: agentMoneyBoth(team.customerDebt),
                ),
              ],
            ),
          ),
    );
  }
}

class _StockCard extends StatelessWidget {
  const _StockCard({required this.item, required this.onEdit});

  final AgentStockItem item;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    String money(double v) => CurrencyFormatter.format(v, item.currency);
    return DashCard(
      padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
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
                Text(
                  l10n.agentTransferRange(l10n.agentPriceRange(money(item.minPrice), money(item.maxPrice))),
                  style: TextStyle(fontSize: 12, color: colors.textSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: l10n.ownerEditRange,
            onPressed: onEdit,
            icon: Icon(Icons.tune_rounded, color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// "Narx oralig'ini o'zgartirish": the lead agent's current min–max for one product. Pops `true`
/// once saved.
class _PriceRangeDialog extends StatefulWidget {
  const _PriceRangeDialog({required this.leadId, required this.item});

  final String leadId;
  final AgentStockItem item;

  @override
  State<_PriceRangeDialog> createState() => _PriceRangeDialogState();
}

class _PriceRangeDialogState extends State<_PriceRangeDialog> {
  late final _min = TextEditingController(text: agentQty(widget.item.minPrice));
  late final _max = TextEditingController(text: agentQty(widget.item.maxPrice));
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // An earlier error no longer applies once either price changes.
    void clear() {
      if (_error != null) setState(() => _error = null);
    }

    _min.addListener(clear);
    _max.addListener(clear);
  }

  @override
  void dispose() {
    _min.dispose();
    _max.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final name = widget.item.product.name;
    final min = double.tryParse(_min.text.trim().replaceAll(',', '.'));
    final max = double.tryParse(_max.text.trim().replaceAll(',', '.'));
    if (min == null || max == null || min <= 0 || max <= 0) {
      return setState(() => _error = l10n.ownerPriceInvalid(name));
    }
    if (min > max) return setState(() => _error = l10n.ownerRangeInvalid(name));
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await getIt<UpdateAgentPriceRangeUseCase>().call(widget.leadId, widget.item.id, min: min, max: max);
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
    return AlertDialog(
      title: Text(l10n.ownerEditRange),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.item.product.name, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          TextField(
            controller: _min,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: l10n.ownerMinPrice),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _max,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: l10n.ownerMaxPrice),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.commonCancel)),
        FilledButton(onPressed: _busy ? null : _save, child: Text(l10n.commonSave)),
      ],
    );
  }
}
