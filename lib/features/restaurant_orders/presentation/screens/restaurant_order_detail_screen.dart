import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/restaurant_order_enums.dart';
import 'package:bsmart/core/enums/user_role.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/restaurant_orders/domain/entities/restaurant_order.dart';
import 'package:bsmart/features/restaurant_orders/domain/restaurant_order_status_actions.dart';
import 'package:bsmart/features/restaurant_orders/domain/usecases/accept_restaurant_order_usecase.dart';
import 'package:bsmart/features/restaurant_orders/domain/usecases/assign_restaurant_order_courier_usecase.dart';
import 'package:bsmart/features/restaurant_orders/domain/usecases/get_restaurant_order_usecase.dart';
import 'package:bsmart/features/restaurant_orders/domain/usecases/list_restaurant_order_couriers_usecase.dart';
import 'package:bsmart/features/restaurant_orders/domain/usecases/update_restaurant_order_status_usecase.dart';
import 'package:bsmart/features/restaurant_orders/domain/entities/restaurant_order_person_ref.dart';
import 'package:bsmart/features/restaurant_orders/presentation/widgets/restaurant_order_status_badge.dart';

class RestaurantOrderDetailScreen extends ConsumerStatefulWidget {
  const RestaurantOrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<RestaurantOrderDetailScreen> createState() => _RestaurantOrderDetailScreenState();
}

class _RestaurantOrderDetailScreenState extends ConsumerState<RestaurantOrderDetailScreen> {
  RestaurantOrder? _order;
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
  }

  Future<void> _updateStatus(RestaurantOrderStatus status) async {
    setState(() => _isBusy = true);
    final result = await getIt<UpdateRestaurantOrderStatusUseCase>().call(widget.orderId, status);
    if (!mounted) return;
    setState(() => _isBusy = false);
    result.fold(
      (order) => setState(() => _order = order),
      (failure) => _showError(failure.message),
    );
  }

  Future<void> _accept() async {
    setState(() => _isBusy = true);
    final result = await getIt<AcceptRestaurantOrderUseCase>().call(widget.orderId);
    if (!mounted) return;
    setState(() => _isBusy = false);
    result.fold(
      (order) => setState(() => _order = order),
      (failure) => _showError(failure.message),
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
        title: const Text('Kuryerni tanlang'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('— Tayinlanmagan (barcha kuryerlarga) —'),
          ),
          for (final courier in couriers)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(courier.id),
              child: Text(courier.fullName),
            ),
        ],
      ),
    );
    if (!mounted) return;
    setState(() => _isBusy = true);
    final result = await getIt<AssignRestaurantOrderCourierUseCase>().call(widget.orderId, selected);
    if (!mounted) return;
    setState(() => _isBusy = false);
    result.fold(
      (order) => setState(() => _order = order),
      (failure) => _showError(failure.message),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _statusActionLabel(RestaurantOrderStatus status) => switch (status) {
        RestaurantOrderStatus.preparing => 'Tayyorlashni boshlash',
        RestaurantOrderStatus.ready => 'Tayyor deb belgilash',
        RestaurantOrderStatus.served => 'Berildi deb belgilash',
        RestaurantOrderStatus.delivered => 'Yetkazildi deb belgilash',
        RestaurantOrderStatus.cancelled => 'Bekor qilish',
        RestaurantOrderStatus.newOrder => '',
      };

  @override
  Widget build(BuildContext context) {
    final order = _order;
    final session = ref.watch(sessionNotifierProvider).valueOrNull?.session;
    final role = session?.role;
    final userId = session?.userId;

    return Scaffold(
      appBar: AppBar(title: Text(order?.orderNumber ?? 'Buyurtma')),
      body: _errorMessage != null && order == null
          ? Center(child: Text(_errorMessage!))
          : order == null
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(order.orderNumber, style: Theme.of(context).textTheme.titleLarge),
                          RestaurantOrderStatusBadge(status: order.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(order.type.label, style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 16),
                      _buildInfoCard(order),
                      const SizedBox(height: 16),
                      _buildItemsCard(order),
                      const SizedBox(height: 16),
                      _buildTotalsCard(order),
                      if (order.type == RestaurantOrderType.delivery) ...[
                        const SizedBox(height: 16),
                        _buildCourierCard(context, order, role),
                      ],
                      if (role != null &&
                          userId != null &&
                          (getStatusActions(order, role, userId).isNotEmpty ||
                              canAcceptOrder(order, role, userId))) ...[
                        const SizedBox(height: 20),
                        _buildActions(order, role, userId),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoCard(RestaurantOrder order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (order.type == RestaurantOrderType.dineIn)
              Text('Stol: ${order.tableNumber ?? order.table?.name ?? '—'}')
            else
              Text('Manzil: ${order.deliveryAddress ?? '—'}'),
            if (order.customerName?.isNotEmpty == true) Text('Mijoz: ${order.customerName}'),
            if (order.customerPhone?.isNotEmpty == true) Text('Telefon: ${order.customerPhone}'),
            if (order.waiter != null) Text('Ofitsiant: ${order.waiter!.fullName}'),
            if (order.createdBy != null) Text('Yaratdi: ${order.createdBy!.fullName}'),
            if (order.notes?.isNotEmpty == true) Text('Izoh: ${order.notes}'),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsCard(RestaurantOrder order) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text('Taomlar', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          for (final item in order.items)
            ListTile(
              dense: true,
              title: Text(item.productName),
              subtitle: Text('${item.quantity} x ${CurrencyFormatter.format(item.unitPrice, Currency.uzs)}'),
              trailing: Text(CurrencyFormatter.format(item.total, Currency.uzs)),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildTotalsCard(RestaurantOrder order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _totalRow('Oraliq summa', order.subtotal),
            if (order.discount > 0) _totalRow('Chegirma', -order.discount),
            if (order.serviceChargeAmount > 0)
              _totalRow('Xizmat haqi (${order.serviceChargePercent.toStringAsFixed(0)}%)', order.serviceChargeAmount),
            if (order.waiterCommissionAmount > 0)
              _totalRow(
                'Ofitsiant xizmat haqi (${order.waiterCommissionPercent.toStringAsFixed(0)}%)',
                order.waiterCommissionAmount,
              ),
            const Divider(),
            _totalRow('Jami', order.grandTotal, isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _totalRow(String label, double amount, {bool isBold = false}) {
    final style = isBold ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 16) : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(CurrencyFormatter.format(amount, Currency.uzs), style: style),
        ],
      ),
    );
  }

  Widget _buildCourierCard(BuildContext context, RestaurantOrder order, UserRole? role) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                order.courier == null
                    ? 'Kuryer tayinlanmagan'
                    : 'Kuryer: ${order.courier!.fullName}'
                        '${order.isCourierAssignmentPending ? ' (qabul qilinishi kutilmoqda)' : ''}',
              ),
            ),
            if (role != null && canAssignCourier(order, role) && !_isBusy)
              TextButton(onPressed: _assignCourier, child: const Text('Tayinlash')),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(RestaurantOrder order, UserRole role, String userId) {
    final actions = getStatusActions(order, role, userId);
    final canAccept = canAcceptOrder(order, role, userId);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (canAccept)
          FilledButton.icon(
            onPressed: _isBusy ? null : _accept,
            icon: const Icon(Icons.check),
            label: const Text('Qabul qilish'),
          ),
        for (final status in actions)
          if (status == RestaurantOrderStatus.cancelled)
            OutlinedButton.icon(
              onPressed: _isBusy ? null : () => _confirmCancel(status),
              icon: const Icon(Icons.close),
              label: const Text('Bekor qilish'),
            )
          else
            FilledButton(
              onPressed: _isBusy ? null : () => _updateStatus(status),
              child: Text(_statusActionLabel(status)),
            ),
      ],
    );
  }

  Future<void> _confirmCancel(RestaurantOrderStatus status) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buyurtmani bekor qilish'),
        content: const Text('Bu buyurtmani bekor qilishni tasdiqlaysizmi?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("Yo'q")),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Ha')),
        ],
      ),
    );
    if (confirmed == true) _updateStatus(status);
  }
}
