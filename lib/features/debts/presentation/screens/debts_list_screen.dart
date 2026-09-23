import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/enums/user_role.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/debts/presentation/providers/debts_list_notifier.dart';
import 'package:bsmart/features/debts/presentation/providers/sale_debts_list_notifier.dart';
import 'package:bsmart/features/debts/presentation/screens/debt_group_detail_screen.dart';
import 'package:bsmart/features/debts/presentation/widgets/debt_like.dart';

/// The Debts hub — two tabs mirroring the two backend debt models: "B2B"
/// (`Debt`, wholesaler↔retailer) and "Mijozlar" (`SaleDebt`, B2C, always
/// created by a POS DEBT sale). Each tab groups the flat list client-side by
/// person+currency (the FIFO pay-down's natural unit) rather than showing
/// raw individual debt rows.
class DebtsListScreen extends ConsumerStatefulWidget {
  const DebtsListScreen({super.key});

  @override
  ConsumerState<DebtsListScreen> createState() => _DebtsListScreenState();
}

class _DebtsListScreenState extends ConsumerState<DebtsListScreen> with SingleTickerProviderStateMixin {
  late final _tabController = TabController(length: 2, vsync: this);
  String? _b2bRole;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool get _isRetailer {
    final role = ref.read(sessionNotifierProvider).valueOrNull?.session?.role;
    return role == UserRole.retailer || role == UserRole.retailerAdmin;
  }

  void _openGroup(DebtGroup group) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DebtGroupDetailScreen(group: group)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Qarzlar'),
        bottom: TabBar(controller: _tabController, tabs: const [Tab(text: 'B2B'), Tab(text: 'Mijozlar')]),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildB2bTab(), _buildSaleDebtsTab()],
      ),
    );
  }

  Widget _buildB2bTab() {
    final debtsAsync = ref.watch(debtsListProvider);
    return Column(
      children: [
        if (_isRetailer)
          Padding(
            padding: const EdgeInsets.all(12),
            child: SegmentedButton<String?>(
              segments: const [
                ButtonSegment(value: null, label: Text('Menga')),
                ButtonSegment(value: 'debtor', label: Text('Mening qarzim')),
              ],
              selected: {_b2bRole},
              onSelectionChanged: (selection) {
                setState(() => _b2bRole = selection.first);
                ref.read(debtsListProvider.notifier).setRole(selection.first);
              },
            ),
          ),
        Expanded(
          child: debtsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Xatolik: $error')),
            data: (debts) {
              final currentUserId = ref.read(sessionNotifierProvider).valueOrNull?.session?.userId ?? '';
              final groups = groupDebts(debts, currentUserId: currentUserId);
              if (groups.isEmpty) return const Center(child: Text('Qarzlar topilmadi'));
              return RefreshIndicator(
                onRefresh: () => ref.read(debtsListProvider.notifier).refresh(),
                child: _buildGroupList(groups),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSaleDebtsTab() {
    final saleDebtsAsync = ref.watch(saleDebtsListProvider);
    return saleDebtsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Xatolik: $error')),
      data: (saleDebts) {
        final groups = groupSaleDebts(saleDebts);
        if (groups.isEmpty) return const Center(child: Text('Mijoz qarzlari topilmadi'));
        return RefreshIndicator(
          onRefresh: () => ref.read(saleDebtsListProvider.notifier).refresh(),
          child: _buildGroupList(groups),
        );
      },
    );
  }

  Widget _buildGroupList(List<DebtGroup> groups) {
    return ListView.separated(
      // A short list (e.g. one group) doesn't fill the viewport, and Android's
      // default ClampingScrollPhysics then never overscrolls — RefreshIndicator
      // needs that overscroll to trigger, so pull-to-refresh silently does
      // nothing without this. Confirmed live: pull-to-refresh had no effect
      // with a single debt group until this was added.
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: groups.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final group = groups[index];
        return ListTile(
          leading: CircleAvatar(child: Text(group.personName.characters.firstOrNull ?? '?')),
          title: Text(group.personName),
          subtitle: Text('${group.activeCount} ta faol qarz${group.personPhone != null ? ' · ${group.personPhone}' : ''}'),
          trailing: Text(
            CurrencyFormatter.format(group.totalBalance, group.currency),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          onTap: () => _openGroup(group),
        );
      },
    );
  }
}
