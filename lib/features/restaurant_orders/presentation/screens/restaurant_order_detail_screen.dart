import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/restaurant_order_enums.dart';
import 'package:bsmart/core/enums/user_role.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/core/network/api_exception.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/deliveries/domain/entities/delivery.dart';
import 'package:bsmart/features/deliveries/domain/usecases/manage_delivery_usecases.dart';
import 'package:bsmart/features/deliveries/presentation/widgets/delivery_outcome_section.dart';
import 'package:bsmart/features/deliveries/presentation/widgets/delivery_status_badge.dart';
import 'package:bsmart/features/restaurant_orders/domain/entities/restaurant_order.dart';
import 'package:bsmart/features/restaurant_orders/domain/restaurant_order_status_actions.dart';
import 'package:bsmart/features/restaurant_orders/domain/usecases/accept_restaurant_order_usecase.dart';
import 'package:bsmart/features/restaurant_orders/domain/usecases/assign_restaurant_order_courier_usecase.dart';
import 'package:bsmart/features/restaurant_orders/domain/usecases/get_restaurant_order_usecase.dart';
import 'package:bsmart/features/restaurant_orders/domain/usecases/list_restaurant_order_couriers_usecase.dart';
import 'package:bsmart/features/restaurant_orders/domain/usecases/update_restaurant_order_status_usecase.dart';
import 'package:bsmart/features/restaurant_orders/domain/entities/restaurant_order_person_ref.dart';
import 'package:bsmart/features/restaurant_orders/presentation/widgets/restaurant_order_status_badge.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

class RestaurantOrderDetailScreen extends ConsumerStatefulWidget {
  const RestaurantOrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<RestaurantOrderDetailScreen> createState() => _RestaurantOrderDetailScreenState();
}

class _RestaurantOrderDetailScreenState extends ConsumerState<RestaurantOrderDetailScreen> {
  RestaurantOrder? _order;

  /// The courier delivery behind a DELIVERY order, for staff (Phase 7 N3) — exists once a courier
  /// has accepted; shows a failed attempt's reason, the handover-code state and link revocation.
  Delivery? _delivery;
  String? _errorMessage;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isBusy = true;
      _errorMessage = null;
    });
    final result = await getIt<GetRestaurantOrderUseCase>().call(widget.orderId);
    if (!mounted) return;
    setState(() {
      _isBusy = false;
      result.fold((order) => _order = order, (failure) => _errorMessage = failure.message);
    });
    await _loadDelivery();
  }

  bool get _isStaff {
    final role = ref.read(sessionNotifierProvider).valueOrNull?.session?.role;
    return role == UserRole.retailer || role == UserRole.retailerAdmin;
  }

  Future<void> _loadDelivery() async {
    final order = _order;
    if (order == null || order.type != RestaurantOrderType.delivery || order.courierAcceptedAt == null || !_isStaff) {
      return;
    }
    final result = await getIt<GetRestaurantOrderDeliveryUseCase>().call(order.id);
    if (!mounted) return;
    result.fold((d) => setState(() => _delivery = d), (_) {});
  }

  Future<void> _revokeTrackingLinks(Delivery delivery) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.restRevokeLinksTitle),
        content: Text(context.l10n.restRevokeLinksBody),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(context.l10n.commonNo)),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(context.l10n.restRevoke)),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _isBusy = true);
    final result = await getIt<RevokeTrackingLinksUseCase>().call(delivery.id);
    if (!mounted) return;
    setState(() => _isBusy = false);
    result.fold(
      (count) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(count == 0 ? context.l10n.restNoActiveLinks : context.l10n.restLinksRevoked(count))),
      ),
      (failure) => _showError(failure.message),
    );
  }

  Future<void> _updateStatus(RestaurantOrderStatus status) async {
    setState(() => _isBusy = true);
    final result = await getIt<UpdateRestaurantOrderStatusUseCase>().call(widget.orderId, status);
    if (!mounted) return;
    setState(() => _isBusy = false);
    result.fold((order) => setState(() => _order = order), (failure) => _showError(failure.message));
    await _loadDelivery();
  }

  Future<void> _accept() async {
    setState(() => _isBusy = true);
    final result = await getIt<AcceptRestaurantOrderUseCase>().call(widget.orderId);
    if (!mounted) return;
    setState(() => _isBusy = false);
    result.fold((order) => setState(() => _order = order), (failure) => _showError(failure.message));
    await _loadDelivery();
  }

  /// Phase 6 V6: a public tracking URL for a phone/walk-in customer without
  /// the app, handed to the share sheet (SMS, Telegram, …). The backend shows
  /// each URL only once, so a new one is created per share.
  Future<void> _shareTrackingLink(RestaurantOrder order) async {
    setState(() => _isBusy = true);
    final result = await getIt<CreateTrackingLinkUseCase>().call(restaurantOrderId: order.id);
    if (!mounted) return;
    setState(() => _isBusy = false);
    await result.fold(
      (link) => Share.share(
        context.l10n.restShareTrackText(order.orderNumber, link.url),
        subject: context.l10n.restShareTrackSubject,
      ),
      (failure) async =>
          _showError(failure is NotFoundApiException ? context.l10n.restCourierNotAccepted : failure.message),
    );
  }

  Future<void> _assignCourier() async {
    final couriersResult = await getIt<ListRestaurantOrderCouriersUseCase>().call();
    if (!mounted) return;
    final couriers = couriersResult.fold((c) => c, (failure) {
      _showError(failure.message);
      return <RestaurantOrderPersonRef>[];
    });

    final selected = await showDialog<String?>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(context.l10n.restPickCourier),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(null),
            child: Text(context.l10n.restUnassignedAll),
          ),
          for (final courier in couriers)
            SimpleDialogOption(onPressed: () => Navigator.of(context).pop(courier.id), child: Text(courier.fullName)),
        ],
      ),
    );
    if (!mounted) return;
    setState(() => _isBusy = true);
    final result = await getIt<AssignRestaurantOrderCourierUseCase>().call(widget.orderId, selected);
    if (!mounted) return;
    setState(() => _isBusy = false);
    result.fold((order) => setState(() => _order = order), (failure) => _showError(failure.message));
    await _loadDelivery();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _statusActionLabel(RestaurantOrderStatus status) => switch (status) {
    RestaurantOrderStatus.preparing => context.l10n.restActionPreparing,
    RestaurantOrderStatus.ready => context.l10n.restActionReady,
    RestaurantOrderStatus.served => context.l10n.restActionServed,
    RestaurantOrderStatus.delivered => context.l10n.restActionDelivered,
    RestaurantOrderStatus.cancelled => context.l10n.restCancelOrder,
    RestaurantOrderStatus.newOrder => '',
  };

  static final _dateFormat = DateFormat('dd.MM.yyyy HH:mm');

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final order = _order;
    final session = ref.watch(sessionNotifierProvider).valueOrNull?.session;
    final role = session?.role;
    final userId = session?.userId;
    final showActions =
        order != null &&
        role != null &&
        userId != null &&
        (getStatusActions(order, role, userId).isNotEmpty || canAcceptOrder(order, role, userId));

    return DashPage(
      title: order?.orderNumber ?? l10n.ordersOrder,
      bottomBar: showActions ? _buildActions(order, role, userId) : null,
      body: _errorMessage != null && order == null
          ? DashEmptyState(
              icon: Icons.cloud_off_rounded,
              text: _errorMessage!,
              action: TextButton(onPressed: _load, child: Text(l10n.commonRetry)),
            )
          : order == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              color: AppColors.onBrand,
              backgroundColor: AppColors.brandYellow,
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                children: [
                  _buildHeaderCard(order),
                  const SizedBox(height: 12),
                  _buildInfoCard(order),
                  DashSectionTitle(
                    l10n.restDishes,
                    trailing: Text(
                      l10n.restDishCount(order.items.length),
                      style: TextStyle(color: BrandColors.of(context).textMuted, fontWeight: FontWeight.w700),
                    ),
                  ),
                  _buildItemsCard(order),
                  if (order.type == RestaurantOrderType.delivery) ...[
                    const SizedBox(height: 12),
                    _buildCourierCard(context, order, role),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderCard(RestaurantOrder order) {
    final colors = BrandColors.of(context);
    final dineIn = order.type == RestaurantOrderType.dineIn;
    return DashCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              RestaurantOrderStatusBadge(status: order.status),
              const Spacer(),
              Text(
                _dateFormat.format(order.createdAt.toLocal()),
                style: TextStyle(color: colors.textMuted, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              CurrencyFormatter.format(order.grandTotal, Currency.uzs),
              style: TextStyle(color: colors.textPrimary, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -1),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                dineIn ? Icons.table_restaurant_rounded : Icons.moped_rounded,
                size: 18,
                color: colors.textSecondary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  [
                    order.type.label,
                    if (dineIn) context.l10n.restTableWith(order.tableNumber ?? order.table?.name ?? '—'),
                  ].join(' · '),
                  style: TextStyle(color: colors.textSecondary, fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(RestaurantOrder order) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    Widget row(IconData icon, String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: colors.textMuted, fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
                Text(
                  value,
                  style: TextStyle(color: colors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    final rows = [
      if (order.type == RestaurantOrderType.delivery)
        row(Icons.place_rounded, l10n.commonAddress, order.deliveryAddress ?? '—'),
      if (order.customerName?.isNotEmpty == true) row(Icons.person_rounded, l10n.salesCustomer, order.customerName!),
      if (order.customerPhone?.isNotEmpty == true) row(Icons.phone_rounded, l10n.commonPhone, order.customerPhone!),
      if (order.waiter != null) row(Icons.room_service_rounded, UserRole.waiter.label, order.waiter!.fullName),
      if (order.createdBy != null) row(Icons.badge_rounded, l10n.restCreatedBy, order.createdBy!.fullName),
      if (order.notes?.isNotEmpty == true) row(Icons.notes_rounded, l10n.commonNote, order.notes!),
    ];
    if (rows.isEmpty) return const SizedBox.shrink();
    return DashCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(children: rows),
    );
  }

  Widget _buildItemsCard(RestaurantOrder order) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    String money(double v) => CurrencyFormatter.format(v, Currency.uzs);
    return DashCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          for (final (i, item) in order.items.indexed) ...[
            if (i > 0) const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        style: TextStyle(color: colors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '${item.quantity} × ${money(item.unitPrice)}',
                        style: TextStyle(color: colors.textMuted, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  money(item.total),
                  style: TextStyle(color: colors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          DashedDivider(color: colors.outline),
          const SizedBox(height: 14),
          BillRow(label: l10n.commonSubtotal, value: money(order.subtotal), muted: true),
          if (order.discount > 0) ...[
            const SizedBox(height: 6),
            BillRow(label: l10n.commonDiscount, value: '−${money(order.discount)}', muted: true),
          ],
          if (order.serviceChargeAmount > 0) ...[
            const SizedBox(height: 6),
            BillRow(
              label: l10n.restServiceChargeWith(order.serviceChargePercent.toStringAsFixed(0)),
              value: money(order.serviceChargeAmount),
              muted: true,
            ),
          ],
          if (order.waiterCommissionAmount > 0) ...[
            const SizedBox(height: 6),
            BillRow(
              label: l10n.restWaiterCommissionWith(order.waiterCommissionPercent.toStringAsFixed(0)),
              value: money(order.waiterCommissionAmount),
              muted: true,
            ),
          ],
          const SizedBox(height: 10),
          BillRow(label: l10n.commonTotal, value: money(order.grandTotal), strong: true),
        ],
      ),
    );
  }

  Widget _buildCourierCard(BuildContext context, RestaurantOrder order, UserRole? role) {
    final colors = BrandColors.of(context);
    final delivery = _delivery;
    final canAssign = role != null && canAssignCourier(order, role) && !_isBusy;
    final canShare = role != null && canShareTrackingLink(order, role);
    final buttonStyle = OutlinedButton.styleFrom(
      minimumSize: const Size(0, 42),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
    return DashCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: order.courier == null ? DashColors.inset(context) : AppColors.brandYellow,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.moped_rounded,
                  size: 21,
                  color: order.courier == null ? colors.textSecondary : AppColors.onBrand,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.courier?.fullName ?? context.l10n.restNoCourier,
                      style: TextStyle(color: colors.textPrimary, fontSize: 15.5, fontWeight: FontWeight.w700),
                    ),
                    if (order.courier != null)
                      Text(
                        order.isCourierAssignmentPending ? context.l10n.restAwaitingAccept : UserRole.courier.label,
                        style: TextStyle(color: colors.textMuted, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                  ],
                ),
              ),
              if (delivery != null) DeliveryStatusBadge(status: delivery.status),
            ],
          ),
          if (canAssign || canShare) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (canAssign)
                  OutlinedButton.icon(
                    onPressed: _assignCourier,
                    style: buttonStyle,
                    icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                    label: Text(context.l10n.restAssign),
                  ),
                if (canShare)
                  OutlinedButton.icon(
                    onPressed: _isBusy ? null : () => _shareTrackingLink(order),
                    style: buttonStyle,
                    icon: const Icon(Icons.share_location_rounded, size: 18),
                    label: Text(context.l10n.restTrackingLink),
                  ),
              ],
            ),
          ],
          if (delivery != null) ...[
            DeliveryOutcomeSection(delivery: delivery, onChanged: _loadDelivery),
            TextButton.icon(
              onPressed: _isBusy ? null : () => _revokeTrackingLinks(delivery),
              icon: const Icon(Icons.link_off_rounded, size: 18),
              label: Text(context.l10n.restRevokeLinks),
            ),
          ],
        ],
      ),
    );
  }

  /// Sticky bottom actions: the courier's "Qabul qilish", or the next status
  /// (filled) beside a red outlined cancel.
  Widget _buildActions(RestaurantOrder order, UserRole role, String userId) {
    final actions = getStatusActions(order, role, userId);
    final error = Theme.of(context).colorScheme.error;
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(18));
    const height = Size.fromHeight(56);
    // Cancel on the left; the next step(s) on the right get more room.
    final cancel = [
      if (actions.contains(RestaurantOrderStatus.cancelled))
        // No icon: the label must fit on one line in the narrower slot.
        OutlinedButton(
          onPressed: _isBusy ? null : () => _confirmCancel(RestaurantOrderStatus.cancelled),
          style: OutlinedButton.styleFrom(
            minimumSize: height,
            shape: shape,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            foregroundColor: error,
            side: BorderSide(color: error.withValues(alpha: 0.5)),
          ),
          child: Text(context.l10n.restCancelOrder, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
    ];
    final forward = [
      if (canAcceptOrder(order, role, userId))
        FilledButton.icon(
          onPressed: _isBusy ? null : _accept,
          style: FilledButton.styleFrom(minimumSize: height, shape: shape),
          icon: const Icon(Icons.check_rounded),
          label: Text(context.l10n.restAccept),
        ),
      for (final status in actions)
        if (status != RestaurantOrderStatus.cancelled)
          FilledButton(
            onPressed: _isBusy ? null : () => _updateStatus(status),
            style: FilledButton.styleFrom(minimumSize: height, shape: shape),
            child: Text(_statusActionLabel(status), textAlign: TextAlign.center),
          ),
    ];
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
        child: Row(
          children: [
            for (final button in cancel) Expanded(flex: 2, child: button),
            if (cancel.isNotEmpty && forward.isNotEmpty) const SizedBox(width: 10),
            for (final (i, button) in forward.indexed) ...[
              if (i > 0) const SizedBox(width: 10),
              Expanded(flex: 3, child: button),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmCancel(RestaurantOrderStatus status) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.restCancelOrderTitle),
        content: Text(context.l10n.restCancelOrderConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(context.l10n.commonNo)),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(context.l10n.commonYes)),
        ],
      ),
    );
    if (confirmed == true) _updateStatus(status);
  }
}
