import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/orders/domain/entities/order_write_params.dart';
import 'package:bsmart/features/orders/domain/usecases/create_order_usecase.dart';
import 'package:bsmart/features/orders/presentation/providers/orders_list_notifier.dart';
import 'package:bsmart/features/storefront/presentation/providers/delivery_address_providers.dart';
import 'package:bsmart/features/storefront/presentation/providers/storefront_cart_notifier.dart';
import 'package:bsmart/features/storefront/presentation/screens/delivery_address_screen.dart';
import 'package:bsmart/features/storefront/presentation/screens/delivery_pin_screen.dart';
import 'package:bsmart/features/storefront/presentation/widgets/checkout_parts.dart';
import 'package:bsmart/features/storefront/presentation/widgets/slide_to_confirm.dart';
import 'package:bsmart/features/storefront/presentation/widgets/storefront_actions.dart';
import 'package:bsmart/features/storefront/presentation/widgets/storefront_image.dart';
import 'package:bsmart/features/storefront/presentation/widgets/storefront_search_parts.dart';

/// Checkout (Phase 9 U3b, Swiggy checkout reference). `POST /orders` reused
/// as-is from `features/orders` (the DTO is already generic across every
/// buyer role — see `order.service.ts`). Only reachable while logged in (see
/// `StorefrontCartTab`'s doc comment on the router redirect).
///
/// Header: where it goes (a saved address, or pickup). Body: the items with
/// steppers, a note for the shop, the bill. Bottom: with no address yet
/// "Qayerga yetkazamiz?" + add/select (or pickup); otherwise the payment line
/// and the slide-to-order control. On success → [RouteNames.customerOrderPlaced].
class StorefrontCartReviewScreen extends ConsumerStatefulWidget {
  const StorefrontCartReviewScreen({super.key});

  @override
  ConsumerState<StorefrontCartReviewScreen> createState() => _StorefrontCartReviewScreenState();
}

class _StorefrontCartReviewScreenState extends ConsumerState<StorefrontCartReviewScreen> {
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectAddress() async {
    final picked = await DeliveryAddressScreen.open(context);
    if (picked != null) ref.read(checkoutDeliveryProvider.notifier).choose(DeliverTo(picked));
  }

  Future<void> _addAddress() async {
    final picked = await DeliveryPinScreen.open(context);
    if (picked == null) return;
    await ref.read(savedAddressesProvider.notifier).remember(picked);
    ref.read(checkoutDeliveryProvider.notifier).choose(DeliverTo(picked));
  }

  Future<void> _submit() async {
    final cart = ref.read(storefrontCartProvider);
    final delivery = ref.read(checkoutDeliveryProvider);
    if (cart.isEmpty || cart.sellerId == null || delivery == null || _isSubmitting) return;
    final address = delivery is DeliverTo ? delivery.address : null;
    final shop = shopNameOf(cart.lines.values.first.product);

    setState(() => _isSubmitting = true);
    final result = await getIt<CreateOrderUseCase>().call(
      CreateOrderParams(
        sellerId: cart.sellerId!,
        items: [
          for (final line in cart.lines.values)
            CreateOrderItemParams(productId: line.product.id, quantity: line.quantity, unitPrice: line.product.price),
        ],
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        deliveryAddress: address?.text,
        deliveryPoint: address?.point,
      ),
    );

    if (!mounted) return;
    result.fold(
      (order) {
        if (address != null) ref.read(savedAddressesProvider.notifier).remember(address);
        ref.read(storefrontCartProvider.notifier).clear();
        ref.invalidate(ordersListProvider);
        context.go(RouteNames.customerOrderPlaced(order.id, shop: shop));
      },
      (failure) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(failure.message)));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Emptied with the steppers → nothing to check out; back to the cart.
    ref.listen(storefrontCartProvider.select((c) => c.isEmpty), (_, isEmpty) {
      if (isEmpty && !_isSubmitting && context.canPop()) context.pop();
    });
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Theme(
      data: BrandTheme.of(context),
      child: Builder(
        builder: (context) {
          final colors = BrandColors.of(context);
          final cart = ref.watch(storefrontCartProvider);
          final delivery = ref.watch(checkoutDeliveryProvider);
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark).copyWith(
              statusBarColor: Colors.transparent,
            ),
            child: Stack(
              children: [
                Scaffold(
                  backgroundColor: dark ? colors.sheet : const Color(0xFFF2F3F6),
                  body: SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        _Header(delivery: delivery, onTap: _selectAddress),
                        Expanded(
                          child: cart.isEmpty
                              ? const SizedBox.shrink()
                              : _Body(cart: cart, notesController: _notesController),
                        ),
                        if (!cart.isEmpty)
                          _BottomPanel(
                            delivery: delivery,
                            total: CurrencyFormatter.format(cart.total, cart.lines.values.first.product.currency),
                            onAdd: _addAddress,
                            onSelect: _selectAddress,
                            onPickup: () => ref.read(checkoutDeliveryProvider.notifier).choose(const PickUp()),
                            onSubmit: _submit,
                            busy: _isSubmitting,
                          ),
                      ],
                    ),
                  ),
                ),
                if (_isSubmitting) const _PlacingOverlay(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.delivery, required this.onTap});

  final DeliveryChoice? delivery;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    final l10n = context.l10n;
    final choice = delivery;
    final (title, subtitle) = switch (choice) {
      DeliverTo(:final address) => (address.title, address.rest.isEmpty ? l10n.coDeliverTo : address.rest),
      PickUp() => (l10n.coPickup, l10n.coPickupHint),
      null => (l10n.coTitle, l10n.coWhereToDeliver),
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 6, 16, 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: colors.textPrimary),
          ),
          Expanded(
            child: InkWell(
              onTap: choice == null ? null : onTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (choice != null) ...[
                          Icon(
                            choice is PickUp ? Icons.storefront_rounded : Icons.near_me_rounded,
                            size: 20,
                            color: colors.textPrimary,
                          ),
                          const SizedBox(width: 6),
                        ],
                        Flexible(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: colors.textPrimary, fontSize: 20, fontWeight: FontWeight.w800),
                          ),
                        ),
                        if (choice != null) Icon(Icons.keyboard_arrow_down_rounded, color: colors.textPrimary),
                      ],
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.cart, required this.notesController});

  final StorefrontCartState cart;
  final TextEditingController notesController;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    final l10n = context.l10n;
    final lines = cart.lines.values.toList();
    final first = lines.first.product;
    final currency = first.currency;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        CheckoutCard(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.storefront_rounded, size: 20, color: colors.accentText),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      shopNameOf(first),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colors.textPrimary, fontSize: 17, fontWeight: FontWeight.w800),
                    ),
                  ),
                  Text(
                    l10n.commonProductCount(lines.length),
                    style: TextStyle(color: colors.textSecondary, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: DashedDivider(color: colors.outline),
              ),
              for (final line in lines) _ItemRow(line: line),
            ],
          ),
        ),
        const SizedBox(height: 14),
        CheckoutCard(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SearchSectionLabel(text: l10n.commonNote),
              TextField(
                controller: notesController,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(hintText: l10n.coNoteHint),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        CheckoutCard(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SearchSectionLabel(text: l10n.cartBillTitle),
              BillRow(
                label: '${l10n.cartItemsTotal} (${lines.length})',
                value: CurrencyFormatter.format(cart.total, currency),
              ),
              const SizedBox(height: 10),
              BillRow(label: l10n.cartDelivery, value: l10n.cartDeliveryAgreed, muted: true),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: DashedDivider(color: colors.outline),
              ),
              BillRow(label: l10n.cartToPay, value: CurrencyFormatter.format(cart.total, currency), strong: true),
            ],
          ),
        ),
        const SizedBox(height: 14),
        CheckoutCard(
          padding: const EdgeInsets.all(16),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${l10n.cartNoteLabel} ',
                  style: TextStyle(color: colors.accentText, fontWeight: FontWeight.w800),
                ),
                TextSpan(text: l10n.cartNote),
              ],
            ),
            style: TextStyle(color: colors.textSecondary, fontSize: 14.5, height: 1.45),
          ),
        ),
      ],
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.line});

  final StorefrontCartLine line;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    final product = line.product;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(width: 52, height: 52, child: StorefrontImage(url: product.imageUrl, iconSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.textPrimary, fontSize: 15.5, fontWeight: FontWeight.w700),
                ),
                Text(
                  CurrencyFormatter.format(line.total, product.currency),
                  style: TextStyle(color: colors.textSecondary, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          AddToCartButton(product: product, width: 104),
        ],
      ),
    );
  }
}

class _BottomPanel extends StatelessWidget {
  const _BottomPanel({
    required this.delivery,
    required this.total,
    required this.onAdd,
    required this.onSelect,
    required this.onPickup,
    required this.onSubmit,
    required this.busy,
  });

  final DeliveryChoice? delivery;
  final String total;
  final VoidCallback onAdd;
  final VoidCallback onSelect;
  final VoidCallback onPickup;
  final VoidCallback onSubmit;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    final l10n = context.l10n;
    return Container(
      decoration: BoxDecoration(
        color: colors.sheet,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 18, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: AnimatedSwitcher(
            duration: AppMotion.standard,
            child: delivery == null
                ? Column(
                    key: const ValueKey('no-address'),
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const AddressBadge(),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.coWhereToDeliver,
                              style: TextStyle(color: colors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: onAdd,
                              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 54)),
                              child: Text(l10n.coAddAddress),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed: onSelect,
                              style: FilledButton.styleFrom(minimumSize: const Size(0, 54)),
                              child: Text(l10n.coSelectAddress),
                            ),
                          ),
                        ],
                      ),
                      TextButton(onPressed: onPickup, child: Text(l10n.coNoDelivery)),
                    ],
                  )
                : Column(
                    key: const ValueKey('ready'),
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: colors.outline),
                            ),
                            child: Icon(Icons.payments_outlined, color: colors.success),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.coPayment,
                                  style: TextStyle(
                                    color: colors.textSecondary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  l10n.coPaymentValue,
                                  style: TextStyle(
                                    color: colors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SlideToConfirm(label: l10n.coSlideToOrder(total), enabled: !busy, onConfirmed: onSubmit),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Full-screen "Biroz kuting!" while the order is sent (the reference's
/// "Hold On!").
class _PlacingOverlay extends StatelessWidget {
  const _PlacingOverlay();

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    return Positioned.fill(
      child: ColoredBox(
        color: colors.sheet,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 120,
              height: 120,
              child: CircularProgressIndicator(
                strokeWidth: 10,
                strokeCap: StrokeCap.round,
                color: AppColors.brandYellow,
                backgroundColor: Color(0x33FFC904),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              context.l10n.coPlacing,
              style: TextStyle(
                fontFamily: BrandTheme.fontFamily,
                color: colors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: AppMotion.fast),
    );
  }
}
