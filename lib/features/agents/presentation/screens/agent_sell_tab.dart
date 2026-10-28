import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/agents/domain/entities/agent_stock_item.dart';
import 'package:bsmart/features/agents/presentation/providers/agent_cart_notifier.dart';
import 'package:bsmart/features/agents/presentation/providers/agent_stock_notifier.dart';
import 'package:bsmart/features/agents/presentation/screens/agent_checkout_screen.dart';
import 'package:bsmart/features/agents/presentation/widgets/agent_format.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// "Sotish": the lead agent's shared stock with each product's price range. Tapping a product
/// puts it in the cart (or takes it out); the cart bar opens checkout.
class AgentSellTab extends ConsumerStatefulWidget {
  const AgentSellTab({super.key});

  @override
  ConsumerState<AgentSellTab> createState() => _AgentSellTabState();
}

class _AgentSellTabState extends ConsumerState<AgentSellTab> {
  final _search = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onSearch(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () => ref.read(agentStockProvider.notifier).search(text));
  }

  void _toggle(AgentStockItem item) {
    final cart = ref.read(agentCartProvider.notifier);
    if (ref.read(agentCartProvider).any((l) => l.item.id == item.id)) {
      cart.remove(item.id);
      return;
    }
    if (!cart.add(item)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.agentOtherCurrency)));
      return;
    }
    HapticFeedback.selectionClick();
  }

  Future<void> _checkout() async {
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const AgentCheckoutScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final stockAsync = ref.watch(agentStockProvider);
    final cart = ref.watch(agentCartProvider);
    final cartTotal = cart.fold<double>(0, (s, l) => s + l.total);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: DashSearchField(controller: _search, hint: l10n.commonSearchHint, onChanged: _onSearch),
        ),
        Expanded(
          child: stockAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => DashEmptyState(icon: Icons.cloud_off_rounded, text: l10n.commonErrorWith('$error')),
            data: (state) => RefreshIndicator(
              color: AppColors.onBrand,
              backgroundColor: AppColors.brandYellow,
              onRefresh: () => ref.read(agentStockProvider.notifier).refresh(),
              child: state.items.isEmpty
                  ? DashEmptyState(
                      icon: Icons.inventory_2_outlined,
                      text: '${l10n.agentNoStock}\n${l10n.agentNoStockHint}',
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      itemCount: state.items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final item = state.items[i];
                        final inCart = cart.any((l) => l.item.id == item.id);
                        return _StockCard(item: item, inCart: inCart, onTap: () => _toggle(item));
                      },
                    ),
            ),
          ),
        ),
        if (cart.isNotEmpty)
          DashCartBar(
            count: cart.length,
            countLabel: l10n.agentCartCount(cart.length),
            total: CurrencyFormatter.format(cartTotal, cart.first.item.currency),
            actionLabel: l10n.agentCheckout,
            onTap: _checkout,
          ),
      ],
    );
  }
}

class _StockCard extends StatelessWidget {
  const _StockCard({required this.item, required this.inCart, required this.onTap});

  final AgentStockItem item;
  final bool inCart;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    String money(double v) => CurrencyFormatter.format(v, item.currency);
    return DashCard(
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Row(
        children: [
          DashThumb(url: item.product.imageUrl),
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
                const SizedBox(height: 2),
                Text(
                  l10n.agentStockLeft(agentQty(item.stock, item.product.unit)),
                  style: TextStyle(fontSize: 12, color: colors.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.agentPriceRange(money(item.minPrice), money(item.maxPrice)),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: inCart ? AppColors.brandYellow : DashColors.inset(context),
              shape: BoxShape.circle,
            ),
            child: Icon(inCart ? Icons.check_rounded : Icons.add_rounded, color: AppColors.onBrand),
          ),
        ],
      ),
    );
  }
}
