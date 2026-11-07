import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/payment_method.dart';
import 'package:bsmart/core/enums/sale_enums.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/customers/domain/entities/customer.dart';
import 'package:bsmart/features/customers/domain/usecases/resolve_walk_in_customer_usecase.dart';
import 'package:bsmart/features/restaurant_orders/domain/entities/restaurant_order.dart';
import 'package:bsmart/features/restaurant_orders/presentation/providers/open_restaurant_orders_notifier.dart';
import 'package:bsmart/features/restaurant_pos/presentation/providers/restaurant_pos_providers.dart';
import 'package:bsmart/features/sales/domain/entities/sale_write_params.dart';
import 'package:bsmart/features/sales/domain/usecases/create_sale_usecase.dart';
import 'package:bsmart/features/sales/presentation/providers/sales_list_notifier.dart';
import 'package:bsmart/features/sales/presentation/screens/sale_detail_screen.dart';
import 'package:bsmart/features/sales/presentation/widgets/customer_picker_sheet.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';
import 'package:bsmart/shared/widgets/payment_method_tiles.dart';

double _round2(double v) => (v * 100).roundToDouble() / 100;
String _plain(double v) => v == v.truncateToDouble() ? v.toStringAsFixed(0) : v.toString();

/// "To'lovga o'tish" for a restaurant bill (Optom_Savdo "Restaurant POS"): the same sale the web
/// Kassa's CheckoutDrawer makes — the bill's dishes at the bill's own prices, the table service
/// charge and the waiter's percent as their own lines (each can be switched off), the discount
/// chosen on the table screen, and `restaurantOrderId`, which links the bill and frees the table
/// (a takeaway goes to the kitchen then). No customer = the store's walk-in buyer.
class RestaurantCheckoutScreen extends ConsumerStatefulWidget {
  const RestaurantCheckoutScreen({required this.order, this.discount, super.key});

  final RestaurantOrder order;

  /// The discount typed on the table screen; null = the order's own.
  final double? discount;

  @override
  ConsumerState<RestaurantCheckoutScreen> createState() => _RestaurantCheckoutScreenState();
}

class _RestaurantCheckoutScreenState extends ConsumerState<RestaurantCheckoutScreen> {
  Customer? _customer;
  SaleType _type = SaleType.paid;
  PaymentMethod _method = PaymentMethod.cash;
  bool _service = true;
  bool _waiter = true;
  final _paidController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  RestaurantOrder get _order => widget.order;
  double get _discount => (widget.discount ?? _order.discount).clamp(0, _order.subtotal).toDouble();
  double get _pre => (_order.subtotal - _discount).clamp(0, double.infinity).toDouble();
  double get _serviceAmount => _service ? _round2(_pre * _order.serviceChargePercent / 100) : 0;
  double get _waiterAmount => _waiter ? _round2(_pre * _order.waiterCommissionPercent / 100) : 0;
  double get _total => _round2(_pre + _serviceAmount + _waiterAmount);

  @override
  void dispose() {
    _paidController.dispose();
    super.dispose();
  }

  Future<void> _pickCustomer() async {
    final picked = await CustomerPickerSheet.show(context);
    if (picked != null) {
      setState(() {
        _customer = picked;
        _errorMessage = null;
      });
    }
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final paid = double.tryParse(_paidController.text.trim().replaceAll(',', '.')) ?? 0;
    if (_type == SaleType.debt && _customer == null) {
      setState(() => _errorMessage = l10n.rposDebtNeedsCustomer);
      return;
    }
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    var customerId = _customer?.id;
    if (customerId == null) {
      final walkIn = await getIt<ResolveWalkInCustomerUseCase>().call();
      if (!mounted) return;
      walkIn.fold((c) => customerId = c.id, (failure) => _errorMessage = failure.message);
      if (customerId == null) {
        setState(() => _isSubmitting = false);
        return;
      }
    }

    final params = CreateSaleParams(
      customerId: customerId!,
      type: _type,
      paymentMethod: _type == SaleType.paid || paid > 0 ? _method : null,
      paidAmount: _type == SaleType.debt ? paid : null,
      discount: _discount,
      restaurantOrderId: _order.id,
      items: [
        for (final item in _order.items)
          item.productId != null
              ? CreateSaleItemParams(productId: item.productId, quantity: item.quantity.toDouble(), unitPrice: item.unitPrice)
              : CreateSaleItemParams(productName: item.productName, quantity: item.quantity.toDouble(), unitPrice: item.unitPrice),
        // The table's service charge: pure income for the owner.
        if (_serviceAmount > 0)
          CreateSaleItemParams(
            productName: l10n.restServiceChargeWith(_plain(_order.serviceChargePercent)),
            quantity: 1,
            unitPrice: _serviceAmount,
            costPrice: 0,
          ),
        // The waiter's percent: passed on to the waiter, no profit for the owner.
        if (_waiterAmount > 0)
          CreateSaleItemParams(
            productName: l10n.restWaiterCommissionWith(_plain(_order.waiterCommissionPercent)),
            quantity: 1,
            unitPrice: _waiterAmount,
            costPrice: _waiterAmount,
          ),
      ],
    );

    final result = await getIt<CreateSaleUseCase>().call(params);
    if (!mounted) return;
    result.fold(
      (sale) {
        ref.read(unpaidRestaurantOrdersProvider.notifier).refresh();
        ref.invalidate(openRestaurantOrdersProvider);
        ref.read(salesListProvider.notifier).refresh();
        final short = _order.orderNumber.split('-').last;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => SaleDetailScreen(
              saleId: sale.id,
              justCreated: true,
              orderLabel: _order.isTakeaway ? l10n.rposOrderLabelTakeaway(short) : l10n.rposOrderLabel(short),
            ),
          ),
        );
      },
      (failure) => setState(() {
        _isSubmitting = false;
        _errorMessage = failure.message;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    String money(double v) => CurrencyFormatter.format(v, Currency.uzs);
    final paid = double.tryParse(_paidController.text.trim().replaceAll(',', '.')) ?? 0;
    final where = _order.isTakeaway
        ? l10n.rposTakeaway
        : _order.table != null
        ? l10n.restTableWith(_order.tableNumber ?? _order.table!.name)
        : (_order.customerName ?? '');

    return DashPage(
      title: l10n.salesPayment,
      bottomBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          child: FilledButton(
            onPressed: _isSubmitting ? null : _submit,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              textStyle: const TextStyle(fontFamily: BrandTheme.fontFamily, fontSize: 16.5, fontWeight: FontWeight.w800),
            ),
            child: _isSubmitting
                ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                : Text(l10n.salesConfirmWithTotal(money(_total))),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          Text(
            '${_order.orderNumber}${where.isEmpty ? '' : ' · $where'}',
            style: TextStyle(color: colors.textMuted, fontSize: 13.5, fontWeight: FontWeight.w700),
          ),
          DashSectionTitle(l10n.rposCustomerOptional, padding: const EdgeInsets.fromLTRB(4, 14, 4, 10)),
          DashCard(
            onTap: _pickCustomer,
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _customer == null ? DashColors.inset(context) : AppColors.brandYellow,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _customer == null ? Icons.person_outline_rounded : Icons.person_rounded,
                    color: _customer == null ? colors.textSecondary : AppColors.onBrand,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _customer?.fullName ?? l10n.rposWalkInCustomer,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        _customer == null ? l10n.commonPickCustomer : (_customer!.phone ?? '—'),
                        style: TextStyle(color: colors.textMuted, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                if (_customer != null)
                  IconButton(
                    tooltip: l10n.rposWalkInCustomer,
                    onPressed: () => setState(() => _customer = null),
                    icon: Icon(Icons.close_rounded, color: colors.textMuted),
                  ),
              ],
            ),
          ),
          DashSectionTitle(l10n.restDishes),
          DashCard(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Column(
              children: [
                for (final item in _order.items)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: BillRow(label: '${item.productName} × ${item.quantity}', value: money(item.total)),
                  ),
              ],
            ),
          ),
          DashSectionTitle(l10n.salesPaymentType),
          PillToggle<SaleType>(
            values: const [SaleType.paid, SaleType.debt],
            selected: _type,
            expand: true,
            label: (t) => t == SaleType.paid ? l10n.salesPaidNow : l10n.commonOnCredit,
            onChanged: (t) => setState(() {
              _type = t;
              _errorMessage = null;
            }),
          ),
          const SizedBox(height: 12),
          if (_type == SaleType.debt) ...[
            TextField(
              controller: _paidController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: l10n.salesDownPaymentOptional,
                prefixIcon: const Icon(Icons.savings_rounded),
                filled: true,
                fillColor: DashColors.card(context),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (_type == SaleType.paid || paid > 0) ...[
            PaymentMethodTiles(selected: _method, onSelected: (m) => setState(() => _method = m)),
            const SizedBox(height: 12),
          ],
          if (_order.serviceChargePercent > 0)
            _Switch(
              label: l10n.restServiceChargeWith(_plain(_order.serviceChargePercent)),
              value: _service,
              onChanged: (v) => setState(() => _service = v),
            ),
          if (_order.waiterCommissionPercent > 0)
            _Switch(
              label: l10n.restWaiterCommissionWith(_plain(_order.waiterCommissionPercent)),
              value: _waiter,
              onChanged: (v) => setState(() => _waiter = v),
            ),
          const SizedBox(height: 8),
          DashCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                BillRow(label: l10n.commonSubtotal, value: money(_order.subtotal), muted: true),
                if (_discount > 0) ...[
                  const SizedBox(height: 8),
                  BillRow(label: l10n.commonDiscount, value: '−${money(_discount)}', muted: true),
                ],
                if (_serviceAmount > 0) ...[
                  const SizedBox(height: 8),
                  BillRow(
                    label: l10n.restServiceChargeWith(_plain(_order.serviceChargePercent)),
                    value: '+${money(_serviceAmount)}',
                    muted: true,
                  ),
                ],
                if (_waiterAmount > 0) ...[
                  const SizedBox(height: 8),
                  BillRow(
                    label: l10n.restWaiterCommissionWith(_plain(_order.waiterCommissionPercent)),
                    value: '+${money(_waiterAmount)}',
                    muted: true,
                  ),
                ],
                if (_type == SaleType.debt) ...[
                  const SizedBox(height: 8),
                  BillRow(
                    label: l10n.salesDebtLeft,
                    value: money((_total - paid).clamp(0, double.infinity).toDouble()),
                    muted: true,
                  ),
                ],
                const SizedBox(height: 14),
                DashedDivider(color: colors.outline),
                const SizedBox(height: 14),
                BillRow(label: l10n.commonTotal, value: money(_total), strong: true),
              ],
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w700),
            ),
          ],
        ],
      ),
    );
  }
}

class _Switch extends StatelessWidget {
  const _Switch({required this.label, required this.value, required this.onChanged});

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DashCard(
        padding: const EdgeInsets.fromLTRB(16, 6, 10, 6),
        child: Row(
          children: [
            Expanded(
              child: Text(label, style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w700)),
            ),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}
