import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/enums/order_status.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/maps/map_icons.dart';
import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/deliveries/domain/entities/delivery.dart';
import 'package:bsmart/features/deliveries/presentation/delivery_actions.dart';
import 'package:bsmart/features/deliveries/presentation/providers/order_delivery_notifier.dart';
import 'package:bsmart/features/deliveries/presentation/screens/delivery_tracking_screen.dart';
import 'package:bsmart/features/deliveries/presentation/widgets/handover_code_card.dart';
import 'package:bsmart/features/orders/domain/entities/order.dart';
import 'package:bsmart/features/orders/domain/usecases/get_order_usecase.dart';
import 'package:bsmart/features/storefront/presentation/widgets/checkout_parts.dart';
import 'package:bsmart/features/storefront/presentation/widgets/storefront_search_parts.dart';

/// Where a customer's order is, as one stage of the progress bar.
enum CustomerOrderStage { placed, approved, onTheWay, delivered, rejected }

/// The order's stage, taking the courier delivery (if any) into account.
CustomerOrderStage customerOrderStage(Order order, Delivery? delivery) {
  if (order.status == OrderStatus.rejected) return CustomerOrderStage.rejected;
  if (order.status == OrderStatus.delivered ||
      order.status == OrderStatus.paid ||
      order.status == OrderStatus.debtRecorded ||
      delivery?.status == DeliveryStatus.delivered) {
    return CustomerOrderStage.delivered;
  }
  if (order.status == OrderStatus.newOrder) return CustomerOrderStage.placed;
  if (delivery != null && delivery.status.isWithCourier) return CustomerOrderStage.onTheWay;
  return CustomerOrderStage.approved;
}

final customerOrderProvider = FutureProvider.autoDispose.family<Order, String>((ref, id) async {
  final result = await getIt<GetOrderUseCase>().call(id);
  return result.fold((order) => order, (failure) => throw failure);
});

/// A customer's order (Phase 9 U3c, Swiggy order-tracking reference). Route
/// `/customer/orders/:id`, login required.
///
/// Map on top (destination pin from checkout, the shop once a courier
/// delivery exists), a status card with the stage, progress steps and the
/// courier's ETA, then courier / shop / bill cards. Refreshes every 30 s
/// until the order is finished; the live courier map is
/// [DeliveryTrackingScreen].
class CustomerOrderScreen extends StatelessWidget {
  const CustomerOrderScreen({required this.orderId, super.key});

  final String orderId;

  @override
  Widget build(BuildContext context) => Theme(
    data: BrandTheme.of(context),
    child: _Body(orderId: orderId),
  );
}

class _Body extends ConsumerStatefulWidget {
  const _Body({required this.orderId});

  final String orderId;

  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> {
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    _poll = Timer.periodic(const Duration(seconds: 30), (_) {
      final order = ref.read(customerOrderProvider(widget.orderId)).valueOrNull;
      final stage = order == null
          ? null
          : customerOrderStage(order, ref.read(orderDeliveryProvider(widget.orderId)).valueOrNull);
      if (stage != CustomerOrderStage.delivered && stage != CustomerOrderStage.rejected) _refresh();
    });
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  void _refresh() {
    ref.invalidate(customerOrderProvider(widget.orderId));
    ref.invalidate(orderDeliveryProvider(widget.orderId));
  }

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    final l10n = context.l10n;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final async = ref.watch(customerOrderProvider(widget.orderId));
    // A delivery error just means "no courier info" here.
    final delivery = ref.watch(orderDeliveryProvider(widget.orderId)).valueOrNull;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark).copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: dark ? colors.sheet : const Color(0xFFF2F3F6),
        body: async.when(
          skipLoadingOnRefresh: true,
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: _RoundButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                    onTap: () => _back(context),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: TextButton(onPressed: _refresh, child: Text(l10n.commonRetry)),
                  ),
                ),
              ],
            ),
          ),
          data: (order) => RefreshIndicator(
            onRefresh: () async => _refresh(),
            color: AppColors.onBrand,
            backgroundColor: AppColors.brandYellow,
            child: _Content(order: order, delivery: delivery, onRefresh: _refresh),
          ),
        ),
      ),
    );
  }
}

void _back(BuildContext context) => context.canPop() ? context.pop() : context.go(RouteNames.customerHome);

class _Content extends StatelessWidget {
  const _Content({required this.order, required this.delivery, required this.onRefresh});

  final Order order;
  final Delivery? delivery;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    final l10n = context.l10n;
    final size = MediaQuery.sizeOf(context);
    final stage = customerOrderStage(order, delivery);
    final d = delivery;
    final destination = order.deliveryPoint != null
        ? LatLng(order.deliveryPoint!.lat, order.deliveryPoint!.lng)
        : d?.dropoff != null
        ? LatLng(d!.dropoff!.lat, d.dropoff!.lng)
        : null;
    final shop = d?.pickup != null ? LatLng(d!.pickup!.lat, d.pickup!.lng) : null;
    final heroHeight = math.max(560.0, size.height * 0.74);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        SizedBox(
          height: heroHeight,
          child: Stack(
            children: [
              // The map runs behind the status card (like the reference).
              Positioned.fill(
                bottom: 60,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                  child: destination == null && shop == null
                      ? const _NoMapHero()
                      : _OrderMap(destination: destination, shop: shop),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: [
                        _RoundButton(
                          icon: Icons.arrow_back_rounded,
                          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                          onTap: () => _back(context),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                            decoration: BoxDecoration(
                              color: colors.sheet.withValues(alpha: 0.94),
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 10)],
                            ),
                            child: Column(
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    l10n.otTitle(order.orderNumber),
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: colors.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                Text(
                                  l10n.otSubtitle(
                                    DateFormat.Hm().format(order.createdAt.toLocal()),
                                    order.items.isNotEmpty ? order.items.length : order.itemCount,
                                  ),
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: colors.textSecondary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _RoundButton(icon: Icons.refresh_rounded, tooltip: l10n.otRefresh, onTap: onRefresh),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 0,
                child: _StatusCard(order: order, delivery: d, stage: stage)
                    .animate()
                    .fadeIn(duration: AppMotion.standard)
                    .slideY(begin: 0.12, end: 0, curve: AppMotion.emphasized),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (d != null && d.handover.code != null && !d.status.isTerminal) ...[
                HandoverCodeCard(code: d.handover.code!),
                const SizedBox(height: 14),
              ],
              if (d != null && d.courier != null && !d.status.isTerminal) ...[
                _CourierCard(delivery: d),
                const SizedBox(height: 14),
              ],
              _ShopCard(order: order),
              const SizedBox(height: 14),
              CheckoutCard(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SearchSectionLabel(text: l10n.cartBillTitle),
                    BillRow(
                      label: '${l10n.cartItemsTotal} (${order.items.length})',
                      value: CurrencyFormatter.format(order.subtotal, order.currency),
                    ),
                    if (order.discount > 0) ...[
                      const SizedBox(height: 10),
                      BillRow(
                        label: l10n.commonDiscount,
                        value: '− ${CurrencyFormatter.format(order.discount, order.currency)}',
                        muted: true,
                      ),
                    ],
                    const SizedBox(height: 10),
                    BillRow(label: l10n.cartDelivery, value: l10n.cartDeliveryAgreed, muted: true),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: DashedDivider(color: colors.outline),
                    ),
                    BillRow(
                      label: l10n.cartToPay,
                      value: CurrencyFormatter.format(order.total, order.currency),
                      strong: true,
                    ),
                  ],
                ),
              ),
              if (order.notes?.trim().isNotEmpty ?? false) ...[
                const SizedBox(height: 14),
                CheckoutCard(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SearchSectionLabel(text: l10n.commonNote),
                      Text(order.notes!, style: TextStyle(color: colors.textPrimary, fontSize: 15, height: 1.4)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.order, required this.delivery, required this.stage});

  final Order order;
  final Delivery? delivery;
  final CustomerOrderStage stage;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    final l10n = context.l10n;
    final d = delivery;
    final (title, hint) = switch (stage) {
      CustomerOrderStage.rejected => (l10n.otRejectedTitle, order.rejectionReason ?? ''),
      CustomerOrderStage.delivered => (l10n.otDeliveredTitle, l10n.otDeliveredHint),
      CustomerOrderStage.placed => (l10n.otNewTitle, l10n.otNewHint),
      _ when d != null => (
        switch (d.status) {
          DeliveryStatus.pending => l10n.otCourierSearching,
          DeliveryStatus.assigned => l10n.otCourierAssigned,
          DeliveryStatus.accepted => l10n.otCourierToShop,
          DeliveryStatus.pickedUp => l10n.otOnTheWay,
          DeliveryStatus.arrived => l10n.otArrived,
          DeliveryStatus.delivered => l10n.otDeliveredTitle,
          DeliveryStatus.cancelled => l10n.otDeliveryCancelled,
          DeliveryStatus.failed => l10n.otDeliveryFailed,
        },
        switch (d.status) {
          DeliveryStatus.failed => d.failReason?.label ?? '',
          DeliveryStatus.pickedUp ||
          DeliveryStatus.arrived when d.courier != null => l10n.otCourierBringing(d.courier!.firstName),
          _ => l10n.otApprovedHint,
        },
      ),
      _ => (l10n.otApprovedTitle, l10n.otApprovedHint),
    };
    final etaMinutes = d != null && d.status.isActive && d.status != DeliveryStatus.arrived && d.eta != null
        ? math.max(1, (d.eta!.seconds / 60).ceil())
        : null;
    final shopName = order.seller == null ? '' : '${order.seller!.firstName} ${order.seller!.lastName}'.trim();
    final destination = order.deliveryAddress?.trim().isNotEmpty ?? false
        ? order.deliveryAddress!.trim()
        : l10n.otPickupAt;

    return Material(
      color: colors.sheet,
      elevation: 6,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(26),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 16, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedSwitcher(
                        duration: AppMotion.standard,
                        child: Text(
                          title,
                          key: ValueKey(title),
                          style: TextStyle(
                            color: stage == CustomerOrderStage.rejected
                                ? Theme.of(context).colorScheme.error
                                : colors.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                            height: 1.15,
                          ),
                        ),
                      ),
                      if (hint.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(hint, style: TextStyle(color: colors.textSecondary, fontSize: 14, height: 1.35)),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _StageBadge(stage: stage, etaMinutes: etaMinutes),
              ],
            ),
            if (stage != CustomerOrderStage.rejected) ...[const SizedBox(height: 14), _Steps(stage: stage)],
            const SizedBox(height: 14),
            _Route(from: shopName, to: destination),
            const SizedBox(height: 4),
            Divider(height: 1, color: colors.outline),
            InkWell(
              onTap: () => _showItems(context, order),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Text(
                      l10n.otViewItems,
                      style: TextStyle(color: colors.textPrimary, fontSize: 15.5, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right_rounded, color: colors.accentText),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Green ETA box while the courier is on the way (the reference's "13
/// mins"); otherwise an icon for the stage.
class _StageBadge extends StatelessWidget {
  const _StageBadge({required this.stage, required this.etaMinutes});

  final CustomerOrderStage stage;
  final int? etaMinutes;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    if (etaMinutes != null) {
      return Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1FA463), Color(0xFF12784A)],
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$etaMinutes',
              style: const TextStyle(
                fontFamily: BrandTheme.fontFamily,
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
            Text(
              context.l10n.otMins,
              style: const TextStyle(fontFamily: BrandTheme.fontFamily, color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(end: 1.04, duration: 1200.ms);
    }
    final (icon, fill, ink) = switch (stage) {
      CustomerOrderStage.placed => (Icons.receipt_long_rounded, AppColors.brandYellow, AppColors.onBrand),
      CustomerOrderStage.approved => (Icons.inventory_2_rounded, AppColors.brandYellow, AppColors.onBrand),
      CustomerOrderStage.onTheWay => (Icons.delivery_dining_rounded, AppColors.brandYellow, AppColors.onBrand),
      CustomerOrderStage.delivered => (Icons.check_rounded, colors.success, Colors.white),
      CustomerOrderStage.rejected => (Icons.close_rounded, Theme.of(context).colorScheme.error, Colors.white),
    };
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(18)),
      child: Icon(icon, color: ink, size: 32),
    );
  }
}

class _Steps extends StatelessWidget {
  const _Steps({required this.stage});

  final CustomerOrderStage stage;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    final l10n = context.l10n;
    final labels = [l10n.otStepPlaced, l10n.otStepApproved, l10n.otStepOnTheWay, l10n.otStepDelivered];
    final current = switch (stage) {
      CustomerOrderStage.placed => 0,
      CustomerOrderStage.approved => 1,
      CustomerOrderStage.onTheWay => 2,
      CustomerOrderStage.delivered => 3,
      CustomerOrderStage.rejected => -1,
    };
    return Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < labels.length; i++) ...[
              if (i > 0) const SizedBox(width: 4),
              Expanded(
                child: AnimatedContainer(
                  duration: AppMotion.slow,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i <= current ? AppColors.brandYellow : colors.field,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            for (var i = 0; i < labels.length; i++)
              Expanded(
                child: Text(
                  labels[i],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: i == current ? colors.textPrimary : colors.textMuted,
                    fontSize: 12,
                    fontWeight: i == current ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Shop → destination with dots and a connector (the reference's
/// "Instamart → To Mall").
class _Route extends StatelessWidget {
  const _Route({required this.from, required this.to});

  final String from;
  final String to;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    Widget dot() => Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: colors.textMuted.withValues(alpha: 0.5), shape: BoxShape.circle),
    );
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                dot(),
                Expanded(child: Container(width: 1.5, color: colors.outline)),
                dot(),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  from,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.textPrimary, fontSize: 15.5, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Text(
                  to,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.textSecondary, fontSize: 15, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CourierCard extends StatelessWidget {
  const _CourierCard({required this.delivery});

  final Delivery delivery;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    final l10n = context.l10n;
    final courier = delivery.courier!;
    return CheckoutCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(color: AppColors.ink, shape: BoxShape.circle),
                child: const Icon(Icons.delivery_dining_rounded, color: AppColors.brandYellow),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      courier.firstName,
                      style: TextStyle(color: colors.textPrimary, fontSize: 16.5, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      l10n.otYourCourier,
                      style: TextStyle(color: colors.textSecondary, fontSize: 13.5, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              if (courier.phone != null)
                IconButton(
                  onPressed: () => DeliveryActions.call(context, courier.phone),
                  tooltip: l10n.sfCallShop,
                  icon: Icon(Icons.call_rounded, color: colors.success),
                  style: IconButton.styleFrom(
                    side: BorderSide(color: colors.success.withValues(alpha: 0.5)),
                    fixedSize: const Size(46, 46),
                  ),
                ),
            ],
          ),
          if (delivery.status.isActive) ...[
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => DeliveryTrackingScreen(deliveryId: delivery.id))),
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              icon: const Icon(Icons.near_me_rounded),
              label: Text(l10n.otTrackCourier),
            ),
          ],
        ],
      ),
    );
  }
}

class _ShopCard extends StatelessWidget {
  const _ShopCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    final l10n = context.l10n;
    final seller = order.seller;
    if (seller == null) return const SizedBox.shrink();
    return CheckoutCard(
      padding: const EdgeInsets.all(14),
      onTap: () =>
          context.push(RouteNames.customerShop(seller.id, name: '${seller.firstName} ${seller.lastName}'.trim())),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: AppColors.brandYellow, borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.storefront_rounded, color: AppColors.onBrand),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${seller.firstName} ${seller.lastName}'.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.textPrimary, fontSize: 16.5, fontWeight: FontWeight.w800),
                ),
                Text(
                  l10n.sfOpenShop,
                  style: TextStyle(color: colors.accentText, fontSize: 13.5, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          if (seller.phone != null)
            IconButton(
              onPressed: () => DeliveryActions.call(context, seller.phone),
              tooltip: l10n.otCallShop,
              icon: Icon(Icons.call_rounded, color: colors.success),
              style: IconButton.styleFrom(
                side: BorderSide(color: colors.success.withValues(alpha: 0.5)),
                fixedSize: const Size(46, 46),
              ),
            ),
        ],
      ),
    );
  }
}

Future<void> _showItems(BuildContext context, Order order) {
  final theme = BrandTheme.of(context);
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => Theme(
      data: theme,
      child: Builder(
        builder: (context) {
          final colors = BrandColors.of(context);
          return SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.7),
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                children: [
                  Text(context.l10n.otViewItems, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  for (final item in order.items)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.productName,
                              style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                          Text(
                            '× ${item.quantity == item.quantity.roundToDouble() ? item.quantity.toInt() : item.quantity}',
                            style: TextStyle(color: colors.textSecondary, fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            CurrencyFormatter.format(item.total, order.currency),
                            style: TextStyle(color: colors.textPrimary, fontSize: 15.5, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}

class _OrderMap extends StatefulWidget {
  const _OrderMap({required this.destination, required this.shop});

  final LatLng? destination;
  final LatLng? shop;

  @override
  State<_OrderMap> createState() => _OrderMapState();
}

class _OrderMapState extends State<_OrderMap> {
  GoogleMapController? _map;
  BitmapDescriptor? _shopIcon;
  BitmapDescriptor? _homeIcon;

  @override
  void initState() {
    super.initState();
    MapIcons.pin(
      Icons.storefront_rounded,
      fill: AppColors.ink,
      ring: AppColors.brandYellow,
      glyphColor: AppColors.brandYellow,
    ).then((i) => mounted ? setState(() => _shopIcon = i) : null);
    MapIcons.pin(
      Icons.near_me_rounded,
      fill: AppColors.ink,
      ring: Colors.white,
      glyphColor: Colors.white,
    ).then((i) => mounted ? setState(() => _homeIcon = i) : null);
  }

  @override
  void didUpdateWidget(covariant _OrderMap old) {
    super.didUpdateWidget(old);
    if (old.shop != widget.shop || old.destination != widget.destination) _fit();
  }

  @override
  void dispose() {
    _map?.dispose();
    super.dispose();
  }

  Future<void> _fit() async {
    final pts = [?widget.destination, ?widget.shop];
    final map = _map;
    if (map == null || pts.isEmpty) return;
    if (pts.length == 1) return map.moveCamera(CameraUpdate.newLatLngZoom(pts.first, 15));
    await map.moveCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(pts.map((p) => p.latitude).reduce(math.min), pts.map((p) => p.longitude).reduce(math.min)),
          northeast: LatLng(pts.map((p) => p.latitude).reduce(math.max), pts.map((p) => p.longitude).reduce(math.max)),
        ),
        40,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final target = widget.destination ?? widget.shop!;
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: target, zoom: 15),
      onMapCreated: (c) {
        _map = c;
        Future.delayed(AppMotion.standard, _fit);
      },
      // The map pans/zooms inside the scrolling page.
      gestureRecognizers: {Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new)},
      // Top: the floating header. Bottom: the status card overlaps the map.
      padding: const EdgeInsets.only(top: 140, bottom: 270),
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      markers: {
        if (widget.destination != null && _homeIcon != null)
          Marker(
            markerId: const MarkerId('destination'),
            position: widget.destination!,
            icon: _homeIcon!,
            anchor: const Offset(0.5, 1),
          ),
        if (widget.shop != null && _shopIcon != null)
          Marker(
            markerId: const MarkerId('shop'),
            position: widget.shop!,
            icon: _shopIcon!,
            anchor: const Offset(0.5, 1),
          ),
      },
      polylines: {
        if (widget.destination != null && widget.shop != null)
          Polyline(
            polylineId: const PolylineId('line'),
            points: [widget.shop!, widget.destination!],
            color: AppColors.ink,
            width: 3,
            patterns: [PatternItem.dash(18), PatternItem.gap(12)],
          ),
      },
    );
  }
}

/// No pin to show (pickup order without a courier): a branded panel instead
/// of an empty map.
class _NoMapHero extends StatelessWidget {
  const _NoMapHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.ink, Color(0xFF2A2108)],
        ),
      ),
      child: Center(
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(color: AppColors.brandYellow.withValues(alpha: 0.16), shape: BoxShape.circle),
          child: const Icon(Icons.shopping_bag_rounded, size: 60, color: AppColors.brandYellow),
        ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: -4, end: 4, duration: 1800.ms),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.tooltip, required this.onTap});

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    return Material(
      color: colors.sheet,
      shape: const CircleBorder(),
      elevation: 3,
      shadowColor: Colors.black26,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Tooltip(
          message: tooltip,
          child: SizedBox(width: 48, height: 48, child: Icon(icon, color: colors.textPrimary)),
        ),
      ),
    );
  }
}
