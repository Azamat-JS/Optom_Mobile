import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/features/agents/presentation/screens/agent_dashboard_tab.dart';
import 'package:bsmart/features/agents/presentation/screens/agent_debts_tab.dart';
import 'package:bsmart/features/agents/presentation/screens/agent_sales_tab.dart';
import 'package:bsmart/features/agents/presentation/screens/agent_sell_tab.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/storefront/presentation/widgets/storefront_bottom_nav.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// The shell for lead and staff agents (Optom_Savdo CLAUDE.md "Agents (Dillers)"): home, sell,
/// sales, debtors. Same `IndexedStack` + storefront tab bar as `WaiterHomeScreen`. The lead
/// agent's management screens (its account with the owner, transfers, staff) open from home.
class AgentHomeScreen extends ConsumerStatefulWidget {
  const AgentHomeScreen({super.key});

  @override
  ConsumerState<AgentHomeScreen> createState() => _AgentHomeScreenState();
}

class _AgentHomeScreenState extends ConsumerState<AgentHomeScreen> {
  int _index = 0;

  void _open(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final titles = [l10n.agentTabHome, l10n.agentTabSell, l10n.agentTabSales, l10n.agentTabDebts];
    return DashPage(
      title: titles[_index],
      showBack: false,
      actions: [
        DashRoundButton(
          icon: Icons.settings_outlined,
          tooltip: l10n.commonSettings,
          onTap: () => context.push(RouteNames.settings),
        ),
        DashRoundButton(
          icon: Icons.logout_rounded,
          tooltip: l10n.commonLogout,
          onTap: () => ref.read(sessionNotifierProvider.notifier).logout(),
        ),
      ],
      bottomBar: StorefrontBottomNav(
        selectedIndex: _index,
        onSelected: _open,
        items: [
          StorefrontNavItem(icon: Icons.home_outlined, selectedIcon: Icons.home_rounded, label: titles[0]),
          StorefrontNavItem(icon: Icons.storefront_outlined, selectedIcon: Icons.storefront_rounded, label: titles[1]),
          StorefrontNavItem(
            icon: Icons.receipt_long_outlined,
            selectedIcon: Icons.receipt_long_rounded,
            label: titles[2],
          ),
          StorefrontNavItem(
            icon: Icons.account_balance_wallet_outlined,
            selectedIcon: Icons.account_balance_wallet_rounded,
            label: titles[3],
          ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: [
          AgentDashboardTab(onOpenTab: _open),
          const AgentSellTab(),
          const AgentSalesTab(),
          const AgentDebtsTab(),
        ],
      ),
    );
  }
}
