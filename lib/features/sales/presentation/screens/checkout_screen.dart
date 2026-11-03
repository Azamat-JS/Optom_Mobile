import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/enums/payment_method.dart';
import 'package:bsmart/core/enums/sale_enums.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/customers/domain/entities/customer.dart';
import 'package:bsmart/features/sales/domain/entities/sale_write_params.dart';
import 'package:bsmart/features/sales/domain/pricing/discount_limit.dart';
import 'package:bsmart/features/sales/domain/usecases/create_sale_usecase.dart';
import 'package:bsmart/features/sales/presentation/providers/pos_cart_notifier.dart';
import 'package:bsmart/features/sales/presentation/providers/sales_list_notifier.dart';
import 'package:bsmart/features/sales/presentation/screens/sale_detail_screen.dart';
import 'package:bsmart/features/sales/presentation/widgets/customer_picker_sheet.dart';
import 'package:bsmart/features/sales/presentation/widgets/special_pricing_notice.dart';
import 'package:bsmart/features/customers/presentation/widgets/special_customer_tag.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/payment_method_tiles.dart';

/// POS checkout — pick a customer, choose PAID (+ payment method) or DEBT
/// (+ optional up-front `paidAmount`/due date), apply a sale-level discount,
/// then submit. Mirrors `CreateSaleDto` exactly (see `sale.service.ts`).
///
/// Phase 9 U4b: grey page with cards — customer, items with steppers, the
/// paid/debt pill toggle, payment-method tiles, discount + note, the bill —
/// and a sticky yellow confirm button with the total.
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  Customer? _customer;
  SaleType _type = SaleType.paid;
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  final _discountController = TextEditingController();
  final _paidAmountController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _discountController.dispose();
    _paidAmountController.dispose();
    _notesController.dispose();
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
    final cart = ref.read(posCartProvider);
    if (cart.isEmpty) return;
    if (_customer == null) {
      setState(() => _errorMessage = context.l10n.commonPickCustomer);
      return;
    }

    final discount = double.tryParse(_discountController.text.trim()) ?? 0;
    final paidAmount = double.tryParse(_paidAmountController.text.trim()) ?? 0;
    final special = _customer!.isSpecial;
    // The owners' discount limits cap the sale-level discount (the server spreads it over the
    // lines and refuses a sale that takes a product past its limit).
    final discountMax = _saleDiscountMax(cart, special);
    if (discountMax != null && discount > discountMax + 0.005) {
      setState(
        () => _errorMessage = context.l10n.salesDiscountTooHigh(CurrencyFormatter.format(discountMax, cart.currency!)),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final params = CreateSaleParams(
      customerId: _customer!.id,
      type: _type,
      paymentMethod: _type == SaleType.paid ? _paymentMethod : (paidAmount > 0 ? _paymentMethod : null),
      items: cart.lines.values
          .map(
            (line) => CreateSaleItemParams(
              productId: line.product.id,
              quantity: line.quantity,
              discount: line.discountFor(specialCustomer: special),
            ),
          )
          .toList(),
      discount: discount,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      paidAmount: _type == SaleType.debt ? paidAmount : null,
    );

    final result = await getIt<CreateSaleUseCase>().call(params);
    if (!mounted) return;
    result.fold(
      (sale) {
        ref.read(posCartProvider.notifier).clear();
        // The sales history is app-wide; without this it misses the new sale.
        ref.read(salesListProvider.notifier).refresh();
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => SaleDetailScreen(saleId: sale.id, justCreated: true)));
      },
      (failure) => setState(() {
        _isSubmitting = false;
        _errorMessage = failure.message;
      }),
    );
  }

  static double? _saleDiscountMax(PosCartState cart, bool special) => maxSaleDiscount([
    for (final line in cart.lines.values)
      LimitLine(product: line.product, quantity: line.quantity, total: line.totalFor(specialCustomer: special)),
  ]);

  /// Asks for a line's discount in %, never above the owner's limit for it.
  Future<void> _editLineDiscount(PosCartLine line, bool special) async {
    final max = line.maxPercentFor(specialCustomer: special);
    final picked = await showDialog<double>(
      context: context,
      builder: (_) => _LineDiscountDialog(
        name: line.product.name,
        initial: line.percentFor(specialCustomer: special),
        max: max,
      ),
    );
    if (picked != null) ref.read(posCartProvider.notifier).setDiscountPercent(line.product.id, picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final cart = ref.watch(posCartProvider);
    // The last stepper "−" empties the cart: go back to the POS.
    if (cart.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isSubmitting) Navigator.of(context).maybePop();
      });
      return Scaffold(backgroundColor: DashColors.page(context));
    }
    final currency = cart.currency!;
    String money(double v) => CurrencyFormatter.format(v, currency);
    // A special customer pays the retail price — the server charges exactly that (the app sends no
    // line prices), so the bill must show it too. Another customer brings the stock prices back.
    final special = _customer?.isSpecial ?? false;
    final subtotal = cart.subtotalFor(specialCustomer: special);
    final discount = double.tryParse(_discountController.text.trim()) ?? 0;
    final total = (subtotal - discount).clamp(0, double.infinity).toDouble();
    final discountMax = _saleDiscountMax(cart, special);
    final paidAmount = double.tryParse(_paidAmountController.text.trim()) ?? 0;
    final showMethods = _type == SaleType.paid || paidAmount > 0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark).copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: DashColors.page(context),
        body: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              Row(
                children: [
                  DashRoundButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.salesPayment,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6,
                      ),
                    ),
                  ),
                ],
              ),
              DashSectionTitle(l10n.salesCustomer, padding: const EdgeInsets.fromLTRB(4, 18, 4, 10)),
              _CustomerCard(customer: _customer, onTap: _pickCustomer, missing: _errorMessage != null),
              if (special) ...[
                const SizedBox(height: 10),
                SpecialPricingNotice(
                  lines: [for (final line in cart.lines.values) (line.product, line.quantity)],
                  currency: currency,
                ),
              ],
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
                      if (i > 0) Divider(height: 1, indent: 68, color: colors.outline),
                      _LineRow(
                        line: line,
                        specialCustomer: special,
                        onQuantity: (q) => ref.read(posCartProvider.notifier).updateQuantity(line.product.id, q),
                        onDiscount: () => _editLineDiscount(line, special),
                      ),
                    ],
                  ],
                ),
              ),
              DashSectionTitle(l10n.salesPaymentType),
              PillToggle<SaleType>(
                values: const [SaleType.paid, SaleType.debt],
                selected: _type,
                expand: true,
                label: (t) => t == SaleType.paid ? l10n.salesPaidNow : l10n.commonOnCredit,
                onChanged: (t) => setState(() => _type = t),
              ),
              const SizedBox(height: 12),
              if (_type == SaleType.debt) ...[
                _AmountField(
                  controller: _paidAmountController,
                  label: l10n.salesDownPaymentOptional,
                  icon: Icons.savings_rounded,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
              ],
              if (showMethods) ...[
                PaymentMethodTiles(selected: _paymentMethod, onSelected: (m) => setState(() => _paymentMethod = m)),
                const SizedBox(height: 12),
              ],
              _AmountField(
                controller: _discountController,
                label: l10n.commonDiscount,
                icon: Icons.local_offer_rounded,
                onChanged: (_) => setState(() {}),
                helperText: discountMax == null ? null : l10n.salesDiscountMax(money(discountMax)),
                error: discountMax != null && discount > discountMax + 0.005,
              ),
              const SizedBox(height: 12),
              _AmountField(
                controller: _notesController,
                label: l10n.commonNote,
                icon: Icons.edit_note_rounded,
                numeric: false,
              ),
              const SizedBox(height: 16),
              DashCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    BillRow(label: l10n.commonSubtotal, value: money(subtotal), muted: true),
                    if (discount > 0) ...[
                      const SizedBox(height: 8),
                      BillRow(label: l10n.commonDiscount, value: '−${money(discount)}', muted: true),
                    ],
                    if (_type == SaleType.debt) ...[
                      const SizedBox(height: 8),
                      BillRow(
                        label: l10n.salesDebtLeft,
                        value: money((total - paidAmount).clamp(0, double.infinity).toDouble()),
                        muted: true,
                      ),
                    ],
                    const SizedBox(height: 14),
                    DashedDivider(color: colors.outline),
                    const SizedBox(height: 14),
                    BillRow(label: l10n.commonTotal, value: money(total), strong: true),
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
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                textStyle: const TextStyle(
                  fontFamily: BrandTheme.fontFamily,
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                  : Text(l10n.salesConfirmWithTotal(money(total))),
            ),
          ),
        ),
      ),
    );
  }
}

/// Picked customer (initial, name, phone, "O'zgartirish") or a prompt.
class _CustomerCard extends StatelessWidget {
  const _CustomerCard({required this.customer, required this.onTap, required this.missing});

  final Customer? customer;
  final VoidCallback onTap;

  /// Checkout was tried without a customer: outline the prompt in red.
  final bool missing;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final c = customer;
    final error = Theme.of(context).colorScheme.error;
    // Foreground: the card's own Material would paint over a background border.
    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: c == null && missing ? Border.all(color: error, width: 1.5) : null,
      ),
      child: DashCard(
        onTap: onTap,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: c == null ? DashColors.inset(context) : AppColors.brandYellow,
                shape: BoxShape.circle,
              ),
              child: c == null
                  ? Icon(Icons.person_add_alt_1_rounded, color: colors.textSecondary)
                  : Text(
                      c.firstName.characters.firstOrNull?.toUpperCase() ?? '?',
                      style: const TextStyle(
                        fontFamily: BrandTheme.fontFamily,
                        color: AppColors.onBrand,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          c?.fullName ?? l10n.commonPickCustomer,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                      ),
                      if (c != null && c.isSpecial) ...[const SizedBox(width: 6), const SpecialCustomerTag()],
                    ],
                  ),
                  Text(
                    c == null ? l10n.salesCustomerHint : (c.phone ?? '—'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: c == null && missing ? error : colors.textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              c == null ? '' : l10n.commonChange,
              style: TextStyle(color: colors.accentText, fontSize: 13.5, fontWeight: FontWeight.w800),
            ),
            Icon(Icons.chevron_right_rounded, color: colors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _LineRow extends StatelessWidget {
  const _LineRow({
    required this.line,
    required this.specialCustomer,
    required this.onQuantity,
    required this.onDiscount,
  });

  final PosCartLine line;

  /// Priced for a special customer: the retail price, with the stock price struck through.
  final bool specialCustomer;
  final ValueChanged<double> onQuantity;
  final VoidCallback onDiscount;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final product = line.product;
    // 0 = this price allows no discount at all (e.g. a retail price below the owner's limit).
    final maxPercent = line.maxPercentFor(specialCustomer: specialCustomer);
    final percent = line.percentFor(specialCustomer: specialCustomer);
    final discountAmount = line.discountFor(specialCustomer: specialCustomer);
    final image = product.primaryImage?.url;
    final weighable = product.unit?.isWeighable == true;
    final q = line.quantity.toStringAsFixed(weighable && line.quantity.truncateToDouble() != line.quantity ? 2 : 0);
    final unit = product.unit == null ? '' : ' / ${product.unit!.shortLabel}';
    final unitPrice = line.unitPriceFor(specialCustomer: specialCustomer);
    final repriced = unitPrice != product.price;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 44,
              height: 44,
              color: DashColors.inset(context),
              child: image == null
                  ? Icon(Icons.inventory_2_rounded, color: colors.textMuted, size: 22)
                  : CachedNetworkImage(
                      imageUrl: image,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => Icon(Icons.inventory_2_rounded, color: colors.textMuted, size: 22),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.textPrimary, fontSize: 14.5, fontWeight: FontWeight.w700),
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      if (repriced)
                        TextSpan(
                          text: '${CurrencyFormatter.format(product.price, product.currency)} ',
                          style: const TextStyle(decoration: TextDecoration.lineThrough),
                        ),
                      TextSpan(
                        text: '${CurrencyFormatter.format(unitPrice, product.currency)}$unit',
                        style: repriced ? TextStyle(color: colors.accentText, fontWeight: FontWeight.w800) : null,
                      ),
                    ],
                  ),
                  // Two prices side by side need the room.
                  maxLines: repriced ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.textMuted, fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  CurrencyFormatter.format(line.totalFor(specialCustomer: specialCustomer), product.currency),
                  style: TextStyle(color: colors.textPrimary, fontSize: 14, fontWeight: FontWeight.w800),
                ),
                if (maxPercent != 0)
                  InkWell(
                    onTap: onDiscount,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.local_offer_rounded, size: 14, color: colors.accentText),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              percent > 0
                                  ? l10n.salesLineDiscountApplied(
                                      _percentText(percent),
                                      CurrencyFormatter.format(discountAmount, product.currency),
                                    )
                                  : maxPercent == null
                                  ? l10n.salesLineDiscountAdd
                                  : l10n.salesLineDiscountAddUpTo(_percentText(maxPercent)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: colors.accentText, fontSize: 12.5, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          DashStepper(
            value: q,
            onMinus: () => onQuantity(line.quantity - 1),
            onPlus: () => onQuantity(line.quantity + 1),
          ),
        ],
      ),
    );
  }
}

/// White rounded field with a leading icon (discount, down payment, note).
class _AmountField extends StatelessWidget {
  const _AmountField({
    required this.controller,
    required this.label,
    required this.icon,
    this.onChanged,
    this.numeric = true,
    this.helperText,
    this.error = false,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String>? onChanged;
  final bool numeric;

  /// A line under the field (e.g. the discount cap); shown in the error color when [error].
  final String? helperText;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    // Underline-type border so the floating label stays inside the filled box.
    final border = UnderlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none);
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: numeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: colors.textSecondary),
        helperText: error ? null : helperText,
        errorText: error ? helperText : null,
        helperMaxLines: 2,
        errorMaxLines: 2,
        filled: true,
        fillColor: DashColors.card(context),
        border: border,
        enabledBorder: border,
        focusedBorder: border,
      ),
    );
  }
}

/// 10.0 → "10", 12.5 → "12.5".
String _percentText(double v) => v == v.truncateToDouble() ? v.toStringAsFixed(0) : v.toString();

/// "Chegirma, %" for one checkout line, capped at the product owner's limit ([max]; null = none).
class _LineDiscountDialog extends StatefulWidget {
  const _LineDiscountDialog({required this.name, required this.initial, required this.max});

  final String name;
  final double initial;
  final double? max;

  @override
  State<_LineDiscountDialog> createState() => _LineDiscountDialogState();
}

class _LineDiscountDialogState extends State<_LineDiscountDialog> {
  late final _controller = TextEditingController(text: widget.initial > 0 ? _percentText(widget.initial) : '');
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final l10n = context.l10n;
    final raw = _controller.text.trim().replaceAll(',', '.');
    final value = raw.isEmpty ? 0.0 : double.tryParse(raw);
    final max = widget.max ?? 100;
    if (value == null || !isValidDiscountPercent(value) || value > max + 1e-9) {
      setState(() => _error = l10n.salesLineDiscountRange(_percentText(max)));
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final max = widget.max;
    return AlertDialog(
      title: Text(widget.name, maxLines: 2, overflow: TextOverflow.ellipsis),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onSubmitted: (_) => _save(),
        decoration: InputDecoration(
          labelText: l10n.salesLineDiscountLabel,
          suffixText: '%',
          helperText: max == null ? null : l10n.salesLineDiscountMax(_percentText(max)),
          errorText: _error,
          errorMaxLines: 2,
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.commonCancel)),
        FilledButton(onPressed: _save, child: Text(l10n.commonSave)),
      ],
    );
  }
}
