import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/features/restaurant_pos/presentation/providers/restaurant_pos_providers.dart';
import 'package:bsmart/features/restaurant_pos/presentation/restaurant_pos_actions.dart';
import 'package:bsmart/features/restaurant_pos/presentation/screens/pos_other_orders_screen.dart';
import 'package:bsmart/features/restaurant_pos/presentation/screens/pos_table_screen.dart';
import 'package:bsmart/features/restaurant_pos/presentation/widgets/pos_table_card.dart';
import 'package:bsmart/features/restaurant_tables/domain/entities/restaurant_table.dart';
import 'package:bsmart/features/restaurant_tables/presentation/providers/restaurant_tables_list_notifier.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// How often the floor reloads while it's on screen — a waiter's new order or the kitchen's
/// status shows within this (the app has no live socket for restaurant orders).
const _pollEvery = Duration(seconds: 15);

enum _Filter { all, busy, free, ready, unpaid }

/// A restaurant's Kassa (Optom_Savdo "Restaurant POS"): the tables instead of the product grid and
/// cart. Tapping a busy table opens its bills (remove/add dishes, discount, "To'lovga o'tish");
/// a free one goes straight to the menu. "Olib ketish" sells to a walk-in customer, and "Boshqa
/// buyurtmalar" holds deliveries and unpaid takeaways.
class RestaurantPosScreen extends ConsumerStatefulWidget {
  const RestaurantPosScreen({super.key});

  @override
  ConsumerState<RestaurantPosScreen> createState() => _RestaurantPosScreenState();
}

class _RestaurantPosScreenState extends ConsumerState<RestaurantPosScreen> with WidgetsBindingObserver {
  Timer? _poll;
  DateTime _now = DateTime.now();
  _Filter _filter = _Filter.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _poll = Timer.periodic(_pollEvery, (_) => _refresh(silent: true));
    // The unpaid list may be cached from an earlier visit: always start fresh.
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh(silent: true));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _poll?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh(silent: true);
  }

  Future<void> _refresh({bool silent = false}) async {
    if (!mounted) return;
    setState(() => _now = DateTime.now());
    if (!silent) ref.read(restaurantTablesListProvider.notifier).refresh();
    await ref.read(unpaidRestaurantOrdersProvider.notifier).refresh();
  }

  Future<void> _openTable(PosTableView view) async {
    final table = view.table;
    if (!view.occupied) {
      final saved = await takeTableOrder(context, ref, table);
      if (!saved || !mounted) return;
    }
    await _pushTable(table);
  }

  Future<void> _pushTable(RestaurantTable table) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => PosTableScreen(table: table)));

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final tablesAsync = ref.watch(restaurantTablesListProvider);
    final ordersAsync = ref.watch(unpaidRestaurantOrdersProvider);
    final tables = tablesAsync.valueOrNull;
    final orders = ordersAsync.valueOrNull;

    final views = buildPosTableViews(tables ?? const [], orders ?? const []);
    final otherCount = otherPosOrders(orders ?? const []).length;
    int count(_Filter f) => views.where((v) => _matches(v, f)).length;
    final visible = views.where((v) => _matches(v, _filter)).toList();

    final Widget body;
    if (tablesAsync.hasError && tables == null) {
      body = _message(Icons.cloud_off_rounded, '${tablesAsync.error}', retry: true);
    } else if (ordersAsync.hasError && orders == null) {
      body = _message(Icons.cloud_off_rounded, '${ordersAsync.error}', retry: true);
    } else if (tables == null || orders == null) {
      body = const Center(child: CircularProgressIndicator());
    } else if (views.isEmpty) {
      body = _message(Icons.table_restaurant_rounded, '${l10n.rposNoTables}\n${l10n.rposNoTablesHint}');
    } else if (visible.isEmpty) {
      body = _message(Icons.filter_alt_off_rounded, l10n.rposNoMatches);
    } else {
      final scale = MediaQuery.textScalerOf(context).scale(1);
      body = LayoutBuilder(
        builder: (context, constraints) => GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: constraints.maxWidth >= 600 ? 3 : 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            mainAxisExtent: 120 + 72 * scale,
          ),
          itemCount: visible.length,
          itemBuilder: (context, index) => PosTableCard(
            view: visible[index],
            now: _now,
            onTap: () => _openTable(visible[index]),
          ).animate().fadeIn(delay: (20 * (index % 12)).ms, duration: AppMotion.standard),
        ),
      );
    }

    return DashPage(
      title: l10n.posTitle,
      actions: [
        DashRoundButton(
          icon: Icons.refresh_rounded,
          tooltip: l10n.commonRetry,
          onTap: () => _refresh(),
        ),
      ],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => startTakeaway(context, ref),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: const Color(0xFF16834F),
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.shopping_bag_rounded),
                    label: FittedBox(fit: BoxFit.scaleDown, child: Text(l10n.rposTakeaway)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Badge(
                    isLabelVisible: otherCount > 0,
                    label: Text('$otherCount'),
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(
                        context,
                      ).push(MaterialPageRoute(builder: (_) => const PosOtherOrdersScreen())),
                      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                      icon: const Icon(Icons.receipt_long_rounded),
                      label: FittedBox(fit: BoxFit.scaleDown, child: Text(l10n.rposOtherOrders)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                for (final f in _Filter.values) ...[
                  _Chip(
                    label: _label(context, f),
                    count: count(f),
                    selected: _filter == f,
                    highlight: (f == _Filter.ready || f == _Filter.unpaid) && count(f) > 0,
                    onTap: () => setState(() => _filter = f),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.onBrand,
              backgroundColor: AppColors.brandYellow,
              onRefresh: _refresh,
              child: body,
            ),
          ),
          if (ordersAsync.hasError && orders != null)
            Container(
              width: double.infinity,
              color: Theme.of(context).colorScheme.errorContainer,
              padding: const EdgeInsets.all(8),
              child: Text(
                '${ordersAsync.error}',
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.textPrimary, fontSize: 12.5),
              ),
            ),
        ],
      ),
    );
  }

  static bool _matches(PosTableView v, _Filter f) => switch (f) {
    _Filter.all => true,
    _Filter.busy => v.occupied,
    _Filter.free => !v.occupied,
    _Filter.ready => v.state == PosTableState.ready,
    _Filter.unpaid => v.state == PosTableState.unpaid,
  };

  static String _label(BuildContext context, _Filter f) => switch (f) {
    _Filter.all => context.l10n.rposFilterAll,
    _Filter.busy => context.l10n.rposFilterBusy,
    _Filter.free => context.l10n.rposFilterFree,
    _Filter.ready => context.l10n.rposFilterReady,
    _Filter.unpaid => context.l10n.rposFilterUnpaid,
  };

  Widget _message(IconData icon, String text, {bool retry = false}) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    children: [
      const SizedBox(height: 60),
      DashEmptyState(
        icon: icon,
        text: text,
        action: retry ? TextButton(onPressed: _refresh, child: Text(context.l10n.commonRetry)) : null,
      ),
    ],
  );
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.count,
    required this.selected,
    required this.highlight,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final bool highlight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? AppColors.brandYellow : DashColors.card(context),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? AppColors.onBrand : colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                  decoration: BoxDecoration(
                    color: highlight && !selected
                        ? posTableColor(PosTableState.unpaid)
                        : (selected ? Colors.black.withValues(alpha: 0.12) : DashColors.inset(context)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      color: highlight && !selected ? Colors.white : (selected ? AppColors.onBrand : colors.textSecondary),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
