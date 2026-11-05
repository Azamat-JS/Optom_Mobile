import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/payment_method.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/customers/domain/entities/customer.dart';
import 'package:bsmart/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:bsmart/features/sales/domain/entities/sale_write_params.dart';
import 'package:bsmart/features/sales/domain/manual_revenue.dart';
import 'package:bsmart/features/sales/domain/usecases/create_manual_revenue_usecase.dart';
import 'package:bsmart/features/sales/presentation/providers/sales_list_notifier.dart';
import 'package:bsmart/features/sales/presentation/widgets/customer_picker_sheet.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';
import 'package:bsmart/shared/widgets/payment_method_tiles.dart';

enum _CustomerMode { none, pick, newCustomer }

/// Records a manual revenue (Optom_Savdo "Manual Revenue"): money from goods
/// that were never entered in the app. Amount, currency and payment method
/// are required; the day (empty = now) and the customer are optional. Pops
/// `true` once saved, after refreshing the sales history and the dashboard.
class ManualRevenueFormScreen extends ConsumerStatefulWidget {
  const ManualRevenueFormScreen({super.key});

  @override
  ConsumerState<ManualRevenueFormScreen> createState() => _ManualRevenueFormScreenState();
}

class _ManualRevenueFormScreenState extends ConsumerState<ManualRevenueFormScreen> {
  static final _dayFormat = DateFormat('dd.MM.yyyy');

  final _formKey = GlobalKey<FormState>();
  final _customerCardKey = GlobalKey();
  final _amountController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController(text: '+998');

  Currency _currency = Currency.uzs;
  PaymentMethod _method = PaymentMethod.cash;
  DateTime? _date;
  _CustomerMode _customerMode = _CustomerMode.none;
  Customer? _customer;
  bool _pickMissing = false;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // The formatted preview under the field follows what's typed.
    _amountController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amountController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = tashkentToday();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? today,
      firstDate: manualRevenueFirstDate(),
      lastDate: today,
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickCustomer() async {
    final picked = await CustomerPickerSheet.show(context);
    if (picked != null && mounted) {
      setState(() {
        _customer = picked;
        _pickMissing = false;
      });
    }
  }

  Future<void> _submit() async {
    // The keyboard would hide the bottom of the form, where a customer problem shows.
    FocusScope.of(context).unfocus();
    final formValid = _formKey.currentState!.validate();
    final pickMissing = _customerMode == _CustomerMode.pick && _customer == null;
    setState(() => _pickMissing = pickMissing);
    if (pickMissing && formValid) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final cardContext = _customerCardKey.currentContext;
        if (cardContext != null && cardContext.mounted) {
          Scrollable.ensureVisible(cardContext, duration: const Duration(milliseconds: 250), alignment: 0.4);
        }
      });
    }
    if (!formValid || pickMissing) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });
    final params = CreateManualRevenueParams(
      amount: parseManualRevenueAmount(_amountController.text)!,
      currency: _currency,
      paymentMethod: _method,
      date: manualRevenueDateParam(_date),
      customerId: _customerMode == _CustomerMode.pick ? _customer!.id : null,
      customer: _customerMode == _CustomerMode.newCustomer
          ? ManualRevenueCustomer(
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              phone: cleanManualRevenuePhone(_phoneController.text),
            )
          : null,
    );
    final result = await getIt<CreateManualRevenueUseCase>().call(params);
    if (!mounted) return;
    result.fold(
      (_) {
        ref.read(salesListProvider.notifier).refresh();
        ref.invalidate(dashboardProvider);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.manualRevenueCreated)));
        Navigator.of(context).pop(true);
      },
      (failure) => setState(() {
        _isSaving = false;
        _errorMessage = failure.message;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final amount = parseManualRevenueAmount(_amountController.text);

    return DashPage(
      title: l10n.manualRevenueTitle,
      bottomBar: DashBottomButton(label: l10n.manualRevenueSave, busy: _isSaving, onPressed: _submit),
      body: DashFormTheme(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
                child: Text(
                  l10n.manualRevenueIntro,
                  style: TextStyle(color: colors.textSecondary, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              DashSectionTitle(
                l10n.manualRevenueAmount,
                padding: const EdgeInsets.fromLTRB(4, 18, 4, 10),
                trailing: PillToggle<Currency>(
                  values: const [Currency.uzs, Currency.usd],
                  selected: _currency,
                  label: (c) => c == Currency.uzs ? 'UZS' : 'USD',
                  onChanged: (c) => setState(() => _currency = c),
                ),
              ),
              TextFormField(
                key: const Key('manualRevenueAmount'),
                // Re-checked as it's corrected, so a stale error doesn't hide the field's hint.
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: _amountController,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,\s]'))],
                style: TextStyle(color: colors.textPrimary, fontSize: 20, fontWeight: FontWeight.w800),
                decoration: InputDecoration(
                  hintText: '0',
                  prefixIcon: const Icon(Icons.payments_rounded),
                  helperText: amount != null ? CurrencyFormatter.format(amount, _currency) : null,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return l10n.manualRevenueAmountMissing;
                  final parsed = parseManualRevenueAmount(v);
                  if (parsed == null) return l10n.manualRevenueAmountInvalid;
                  if (parsed > manualRevenueMaxAmount) return l10n.manualRevenueAmountTooLarge;
                  return null;
                },
              ),
              DashSectionTitle(l10n.manualRevenueMethod, padding: const EdgeInsets.fromLTRB(4, 18, 4, 10)),
              PaymentMethodTiles(selected: _method, onSelected: (m) => setState(() => _method = m)),
              DashSectionTitle(l10n.manualRevenueDate, padding: const EdgeInsets.fromLTRB(4, 18, 4, 10)),
              InkWell(
                key: const Key('manualRevenueDate'),
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(18),
                child: InputDecorator(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.calendar_today_rounded),
                    helperText: _date == null ? l10n.manualRevenueDateHint : null,
                    suffixIcon: _date == null
                        ? null
                        : IconButton(
                            tooltip: l10n.manualRevenueDateClear,
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => setState(() => _date = null),
                          ),
                  ),
                  child: Text(_date == null ? l10n.manualRevenueDateNow : _dayFormat.format(_date!)),
                ),
              ),
              DashSectionTitle(l10n.manualRevenueCustomer, padding: const EdgeInsets.fromLTRB(4, 18, 4, 10)),
              PillToggle<_CustomerMode>(
                values: _CustomerMode.values,
                selected: _customerMode,
                expand: true,
                label: (m) => switch (m) {
                  _CustomerMode.none => l10n.manualRevenueCustomerNone,
                  _CustomerMode.pick => l10n.manualRevenueCustomerPick,
                  _CustomerMode.newCustomer => l10n.manualRevenueCustomerNew,
                },
                onChanged: (m) => setState(() {
                  _customerMode = m;
                  _pickMissing = false;
                }),
              ),
              const SizedBox(height: 12),
              ...switch (_customerMode) {
                _CustomerMode.none => [_Hint(l10n.manualRevenueCustomerNoneHint)],
                _CustomerMode.pick => [
                  _PickedCustomerCard(
                    key: _customerCardKey,
                    customer: _customer,
                    missing: _pickMissing,
                    onTap: _pickCustomer,
                  ),
                  if (_pickMissing) ...[const SizedBox(height: 6), _Hint(l10n.manualRevenuePickMissing, error: true)],
                ],
                _CustomerMode.newCustomer => [
                  TextFormField(
                    key: const Key('manualRevenueFirstName'),
                    // Re-checked as it's corrected, so a stale error doesn't hide the field's hint.
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: _firstNameController,
                    textCapitalization: TextCapitalization.words,
                    maxLength: 100,
                    decoration: InputDecoration(
                      labelText: l10n.manualRevenueFirstName,
                      prefixIcon: const Icon(Icons.person_rounded),
                      counterText: '',
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? l10n.manualRevenueNameMissing : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _lastNameController,
                    textCapitalization: TextCapitalization.words,
                    maxLength: 100,
                    decoration: InputDecoration(
                      labelText: l10n.manualRevenueLastName,
                      prefixIcon: const Icon(Icons.badge_rounded),
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('manualRevenuePhone'),
                    // Re-checked as it's corrected, so a stale error doesn't hide the field's hint.
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: l10n.manualRevenuePhone,
                      prefixIcon: const Icon(Icons.phone_rounded),
                      helperText: l10n.manualRevenueReturningHint,
                      helperMaxLines: 2,
                    ),
                    validator: (v) => isValidManualRevenuePhone(v ?? '') ? null : l10n.manualRevenuePhoneInvalid,
                  ),
                ],
              },
              if (_errorMessage != null) ...[
                const SizedBox(height: 14),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w700),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint(this.text, {this.error = false});

  final String text;
  final bool error;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        text,
        style: TextStyle(
          color: error ? Theme.of(context).colorScheme.error : BrandColors.of(context).textMuted,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// The customer picked from the store's list, or a prompt to pick one.
class _PickedCustomerCard extends StatelessWidget {
  const _PickedCustomerCard({required this.customer, required this.missing, required this.onTap, super.key});

  final Customer? customer;
  final bool missing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final c = customer;
    return DashCard(
      onTap: onTap,
      outlineColor: missing ? Theme.of(context).colorScheme.error : null,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: c == null ? DashColors.inset(context) : AppColors.brandYellow,
              shape: BoxShape.circle,
            ),
            child: c == null
                ? Icon(Icons.person_search_rounded, color: colors.textSecondary)
                : Text(
                    c.firstName.characters.firstOrNull?.toUpperCase() ?? '?',
                    style: const TextStyle(color: AppColors.onBrand, fontSize: 18, fontWeight: FontWeight.w800),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c?.fullName ?? l10n.manualRevenuePickCustomer,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.textPrimary, fontSize: 15.5, fontWeight: FontWeight.w800),
                ),
                if (c?.phone != null)
                  Text(
                    c!.phone!,
                    style: TextStyle(color: colors.textMuted, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: colors.textMuted),
        ],
      ),
    );
  }
}
