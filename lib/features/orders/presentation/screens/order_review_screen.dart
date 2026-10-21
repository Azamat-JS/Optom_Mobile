import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/orders/domain/entities/order_write_params.dart';
import 'package:bsmart/features/orders/domain/usecases/create_order_usecase.dart';
import 'package:bsmart/features/orders/presentation/providers/create_order_cart_notifier.dart';
import 'package:bsmart/features/orders/presentation/providers/orders_list_notifier.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// Step 3: review the cart, add notes/delivery address, and submit
/// (`POST /orders`).
class OrderReviewScreen extends ConsumerStatefulWidget {
  const OrderReviewScreen({super.key});

  @override
  ConsumerState<OrderReviewScreen> createState() => _OrderReviewScreenState();
}

class _OrderReviewScreenState extends ConsumerState<OrderReviewScreen> {
  final _notesController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _notesController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final cart = ref.read(createOrderCartProvider);
    if (cart.seller == null || cart.isEmpty) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final result = await getIt<CreateOrderUseCase>().call(
      CreateOrderParams(
        sellerId: cart.seller!.id,
        items: [
          for (final line in cart.lines.values)
            CreateOrderItemParams(
              productId: line.product.id,
              quantity: line.quantity,
              unitPrice: line.unitPrice,
              discount: line.discount > 0 ? line.discount : null,
            ),
        ],
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        deliveryAddress: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      ),
    );

    if (!mounted) return;
    result.fold(
      (order) {
        ref.read(createOrderCartProvider.notifier).clear();
        ref.invalidate(ordersListProvider);
        context.go(RouteNames.orderDetail(order.id));
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
    final cart = ref.watch(createOrderCartProvider);
    final currency = cart.lines.isEmpty ? null : cart.lines.values.first.product.currency;
    final notifier = ref.read(createOrderCartProvider.notifier);

    return DashPage(
      title: l10n.ordersReviewTitle,
      bottomBar: DashBottomButton(
        label: currency == null
            ? l10n.ordersPlace
            : '${l10n.ordersPlace} · ${CurrencyFormatter.format(cart.total, currency)}',
        busy: _isSubmitting,
        onPressed: cart.isEmpty ? null : _submit,
      ),
      body: DashFormTheme(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            if (cart.seller != null)
              DashListCard(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(color: AppColors.brandYellow, shape: BoxShape.circle),
                  child: const Icon(Icons.storefront_rounded, color: AppColors.onBrand),
                ),
                title: cart.seller!.fullName,
                subtitle: cart.store?.name ?? l10n.ordersAllBranches,
              ),
            DashSectionTitle(
              l10n.commonProducts,
              trailing: Text(
                l10n.commonProductCount(cart.itemCount),
                style: TextStyle(color: colors.textMuted, fontWeight: FontWeight.w700),
              ),
            ),
            DashCard(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                children: [
                  for (final (i, line) in cart.lines.values.indexed) ...[
                    if (i > 0) Divider(height: 1, indent: 16, color: colors.outline),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  line.product.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: colors.textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '${CurrencyFormatter.format(line.unitPrice, line.product.currency)}'
                                  '${line.product.unit == null ? '' : ' / ${line.product.unit!.shortLabel}'}',
                                  style: TextStyle(
                                    color: colors.textMuted,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  CurrencyFormatter.format(line.total, line.product.currency),
                                  style: TextStyle(
                                    color: colors.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          DashStepper(
                            value: line.quantity.toStringAsFixed(
                              (line.product.unit?.isWeighable ?? false) &&
                                      line.quantity != line.quantity.truncateToDouble()
                                  ? 2
                                  : 0,
                            ),
                            onMinus: () => notifier.updateQuantity(line.product.id, line.quantity - 1),
                            onPlus: () => notifier.updateQuantity(line.product.id, line.quantity + 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (cart.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(l10n.productsNotFound, style: TextStyle(color: colors.textMuted)),
                    ),
                ],
              ),
            ),
            DashSectionTitle(l10n.commonDeliveryAddress),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: l10n.commonDeliveryAddress,
                prefixIcon: const Icon(Icons.location_on_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(labelText: l10n.commonNote, prefixIcon: const Icon(Icons.edit_note_rounded)),
            ),
            if (currency != null) ...[
              const SizedBox(height: 16),
              DashCard(
                padding: const EdgeInsets.all(18),
                child: BillRow(
                  label: l10n.commonTotal,
                  value: CurrencyFormatter.format(cart.total, currency),
                  strong: true,
                ),
              ),
            ],
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
      ),
    );
  }
}
