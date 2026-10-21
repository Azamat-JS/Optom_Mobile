import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/enums/order_status.dart';
import 'package:bsmart/core/enums/user_role.dart';
import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/orders/presentation/providers/orders_list_notifier.dart';
import 'package:bsmart/features/orders/presentation/widgets/order_status_badge.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// The backend disambiguates by role server-side by default (see
/// `OrderQuery`'s doc comment) — a SELLER sees incoming B2B orders here,
/// every other role that can only ever *place* one (CUSTOMER — Phase 2 —
/// and WAITER/COURIER staff, who inherit their owner's orders) sees their
/// own outgoing ones. A RETAILER is the one role that plays both sides —
/// sourcing stock from a wholesaler (B2B, outgoing/buyer) *and* fulfilling
/// a CUSTOMER's storefront order (B2C, incoming/seller) — so it alone gets
/// the `view` toggle below, wired to `OrdersListNotifier.setView`.
///
/// Phase 9 U4c2: `DashPage`, the view toggle as a pill toggle, status filter
/// chips, order rows as cards (status-tinted icon, counterpart, number ·
/// items · date, total + status pill).
class OrdersListScreen extends ConsumerStatefulWidget {
  const OrdersListScreen({super.key});

  @override
  ConsumerState<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends ConsumerState<OrdersListScreen> {
  static final _dateFormat = DateFormat('dd.MM.yyyy');

  final _scrollController = ScrollController();
  String? _view;

  /// `null` = all statuses (the chips need a non-null value, see [_allStatuses]).
  OrderStatus? _status;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(ordersListProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final role = ref.watch(sessionNotifierProvider).valueOrNull?.session?.role;
    final isRetailer = role == UserRole.retailer || role == UserRole.retailerAdmin;
    // Whether *this screen instance* is currently showing the seller side of
    // the order graph — true for a SELLER always, and for a RETAILER only
    // while their incoming-orders toggle is selected. Never role-alone —a
    // RETAILER's own `Order.seller`/`.buyer` roles flip per order, not per
    // account (see the `view` toggle doc comment above).
    final isSellerView = role == UserRole.seller || role == UserRole.sellerAdmin || (isRetailer && _view == 'incoming');
    final listState = ref.watch(ordersListProvider);

    return DashPage(
      title: isSellerView ? l10n.ordersIncomingTitle : l10n.ordersMineTitle,
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isRetailer) ...[
            PillToggle<String>(
              values: const ['outgoing', 'incoming'],
              selected: _view ?? 'outgoing',
              expand: true,
              label: (v) => v == 'incoming' ? l10n.ordersTabIncoming : l10n.ordersTabOutgoing,
              onChanged: (v) {
                final view = v == 'incoming' ? 'incoming' : null;
                setState(() => _view = view);
                ref.read(ordersListProvider.notifier).setView(view);
              },
            ),
            const SizedBox(height: 10),
          ],
          DashChoiceChips<OrderStatus?>(
            values: _allStatuses,
            selected: _status,
            label: (s) => s?.label ?? l10n.commonAll,
            onSelected: (s) {
              setState(() => _status = s);
              ref.read(ordersListProvider.notifier).filterByStatus(s);
            },
          ),
        ],
      ),
      floatingActionButton: isRetailer && !isSellerView
          ? FloatingActionButton(
              tooltip: l10n.ordersPickWholesaler,
              onPressed: () => context.push(RouteNames.orderNewSellerPicker),
              child: const Icon(Icons.add_rounded),
            )
          : null,
      body: listState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => DashEmptyState(
          icon: Icons.cloud_off_rounded,
          text: l10n.commonErrorWith('$error'),
          action: TextButton(onPressed: () => ref.invalidate(ordersListProvider), child: Text(l10n.commonRetry)),
        ),
        data: (state) => RefreshIndicator(
          color: AppColors.onBrand,
          backgroundColor: AppColors.brandYellow,
          onRefresh: () => ref.read(ordersListProvider.notifier).refresh(),
          child: state.items.isEmpty
              ? DashEmptyState(icon: Icons.receipt_long_rounded, text: l10n.ordersNotFound)
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                  itemCount: state.items.length + (state.hasNext ? 1 : 0),
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    if (index >= state.items.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final order = state.items[index];
                    final counterpart = isSellerView ? order.buyer : order.seller;
                    final tint = OrderStatusBadge.colorOf(context, order.status);
                    return DashListCard(
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: tint.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(Icons.receipt_long_rounded, color: tint),
                      ),
                      title: counterpart?.fullName ?? order.orderNumber,
                      // Date first: order numbers are long and would push it out.
                      subtitle: [
                        _dateFormat.format(order.createdAt.toLocal()),
                        l10n.commonProductCount(order.itemCount),
                        order.orderNumber,
                      ].join(' · '),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            CurrencyFormatter.format(order.total, order.currency),
                            style: TextStyle(color: colors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          OrderStatusBadge(status: order.status),
                        ],
                      ),
                      // Customers get the tracking-style order screen (Phase 9 U3c).
                      onTap: () => context.push(
                        role == UserRole.customer
                            ? RouteNames.customerOrder(order.id)
                            : RouteNames.orderDetail(order.id),
                      ),
                    ).animate().fadeIn(delay: (25 * (index % 12)).ms, duration: AppMotion.standard);
                  },
                ),
        ),
      ),
    );
  }

  static const _allStatuses = <OrderStatus?>[
    null,
    OrderStatus.newOrder,
    OrderStatus.approved,
    OrderStatus.delivered,
    OrderStatus.rejected,
  ];
}
