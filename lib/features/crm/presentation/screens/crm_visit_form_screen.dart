import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/sale_enums.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/crm/domain/crm_due.dart';
import 'package:bsmart/features/crm/domain/entities/crm_driver.dart';
import 'package:bsmart/features/crm/domain/entities/crm_params.dart';
import 'package:bsmart/features/crm/domain/usecases/create_crm_visit_usecase.dart';
import 'package:bsmart/features/crm/presentation/widgets/crm_widgets.dart';
import 'package:bsmart/features/products/domain/entities/product.dart';
import 'package:bsmart/features/products/domain/entities/product_query.dart';
import 'package:bsmart/features/products/domain/usecases/list_products_usecase.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// One line being entered: a store product, or a typed name.
class _Line {
  _Line.product(Product p)
    : productId = p.id,
      stock = p.stock,
      currency = p.currency,
      unitShort = p.unit?.shortLabel,
      name = TextEditingController(text: p.name),
      price = TextEditingController(text: _plain(p.price));

  _Line.manual()
    : productId = null,
      stock = null,
      currency = null,
      unitShort = null,
      name = TextEditingController(),
      price = TextEditingController();

  final String? productId;
  final double? stock;
  final Currency? currency;
  final String? unitShort;
  final TextEditingController name;
  final TextEditingController price;
  final interval = TextEditingController();
  double quantity = 1;

  /// Set by hand; null = from km.
  DateTime? dueDate;

  void dispose() {
    name.dispose();
    price.dispose();
    interval.dispose();
  }

  static String _plain(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toString();
}

/// Record a service visit (Optom_Savdo "CRM" → C3): what was installed on the car, when the car is
/// due back for each part (from km at the car's daily km, or a date set by hand), and the sale.
/// Pops true when saved.
class CrmVisitFormScreen extends ConsumerStatefulWidget {
  const CrmVisitFormScreen({required this.driver, required this.vehicleId, super.key});

  final CrmDriver driver;
  final String vehicleId;

  @override
  ConsumerState<CrmVisitFormScreen> createState() => _CrmVisitFormScreenState();
}

class _CrmVisitFormScreenState extends ConsumerState<CrmVisitFormScreen> {
  late String _vehicleId = widget.vehicleId;
  final DateTime _today = crmToday();
  late DateTime _serviceDate = _today;
  final _odometer = TextEditingController();
  final _notes = TextEditingController();
  final _paid = TextEditingController();
  final List<_Line> _lines = [];
  bool _recordSale = true;
  SaleType _saleType = SaleType.paid;
  bool _saving = false;
  String? _error;

  CrmVehicle? get _vehicle => widget.driver.vehicles.where((v) => v.id == _vehicleId).firstOrNull;
  Currency get _currency => _lines.map((l) => l.currency).nonNulls.firstOrNull ?? Currency.uzs;
  double get _total =>
      _lines.fold(0, (s, l) => s + (double.tryParse(l.price.text.replaceAll(',', '.')) ?? 0) * l.quantity);

  @override
  void dispose() {
    _odometer.dispose();
    _notes.dispose();
    _paid.dispose();
    for (final l in _lines) {
      l.dispose();
    }
    super.dispose();
  }

  Future<void> _addProduct() async {
    final product = await showModalBottomSheet<Product>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _ProductPickerSheet(),
    );
    if (product == null || !mounted) return;
    if (_lines.any((l) => l.currency != null && l.currency != product.currency)) {
      return _showError(context.l10n.crmMixedCurrency);
    }
    final existing = _lines.where((l) => l.productId == product.id).firstOrNull;
    setState(() {
      _error = null;
      if (existing != null) {
        existing.quantity += 1;
      } else {
        _lines.add(_Line.product(product));
      }
    });
  }

  Future<DateTime?> _pickDay({required DateTime initial, required DateTime first, required DateTime last}) async {
    final picked = await showDatePicker(context: context, initialDate: initial, firstDate: first, lastDate: last);
    return picked == null ? null : asDay(picked);
  }

  /// The km-based estimate, or null when there's no interval or no daily km.
  DateTime? _autoDue(_Line l) {
    final km = int.tryParse(l.interval.text.trim());
    final daily = _vehicle?.dailyKm;
    if (km == null || km < 1 || daily == null) return null;
    return dueFromKm(_serviceDate, km, daily);
  }

  String? _validate() {
    final l10n = context.l10n;
    if (_vehicle == null) return l10n.crmPickVehicle;
    if (_lines.isEmpty) return l10n.crmAddPartFirst;
    for (final l in _lines) {
      final name = l.name.text.trim();
      if (name.isEmpty) return l10n.crmManualNameMissing;
      if (_recordSale && l.stock != null && l.quantity > l.stock!) return l10n.crmNotEnoughStock(name);
      final price = double.tryParse(l.price.text.replaceAll(',', '.'));
      if (_recordSale && (price == null || price <= 0)) return l10n.crmPriceMissing(name);
      if (l.dueDate != null && !l.dueDate!.isAfter(_serviceDate)) return l10n.crmDueAfterService(name);
      if (l.interval.text.trim().isNotEmpty && l.dueDate == null && _vehicle!.dailyKm == null) {
        return l10n.crmDueNeeded(name);
      }
    }
    final paid = double.tryParse(_paid.text.replaceAll(',', '.')) ?? 0;
    if (_recordSale && _saleType == SaleType.debt && paid > _total) return l10n.crmPaidTooMuch;
    return null;
  }

  /// Inline at the bottom of the form and as a snackbar: the form scrolls, so the bottom line is
  /// often off screen when "save" is tapped.
  void _showError(String message) {
    setState(() => _error = message);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    final problem = _validate();
    if (problem != null) return _showError(problem);
    setState(() => _error = null);
    setState(() => _saving = true);
    final result = await getIt<CreateCrmVisitUseCase>().call(
      CreateCrmVisitParams(
        vehicleId: _vehicleId,
        serviceDate: _serviceDate,
        odometerKm: int.tryParse(_odometer.text.trim()),
        notes: _notes.text,
        recordSale: _recordSale,
        saleType: _saleType,
        paidAmount: double.tryParse(_paid.text.replaceAll(',', '.')),
        items: [
          for (final l in _lines)
            CrmVisitItemParams(
              productId: l.productId,
              productName: l.productId == null ? l.name.text : null,
              quantity: l.quantity,
              unitPrice: double.tryParse(l.price.text.replaceAll(',', '.')),
              intervalKm: int.tryParse(l.interval.text.trim()),
              dueDate: l.dueDate,
            ),
        ],
      ),
    );
    if (!mounted) return;
    result.fold((_) => Navigator.of(context).pop(true), (failure) {
      setState(() => _saving = false);
      _showError(failure.message);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final vehicle = _vehicle;
    return DashPage(
      title: l10n.crmVisitTitle,
      bottomBar: DashBottomButton(
        label: _recordSale && _lines.isNotEmpty
            ? '${l10n.crmSaveVisit} · ${CurrencyFormatter.format(_total, _currency)}'
            : l10n.crmSaveVisit,
        busy: _saving,
        onPressed: _submit,
      ),
      body: DashFormTheme(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _vehicleId,
              decoration: InputDecoration(
                labelText: l10n.crmVehicle,
                prefixIcon: const Icon(Icons.directions_car_rounded),
              ),
              items: [
                for (final v in widget.driver.vehicles)
                  DropdownMenuItem(value: v.id, child: Text('${formatPlate(v.plateNumber)} · ${v.model}')),
              ],
              onChanged: (id) => setState(() => _vehicleId = id ?? _vehicleId),
            ),
            if (vehicle != null && vehicle.dailyKm == null)
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 6, 4, 0),
                child: Text(
                  l10n.crmDueNeedsDate,
                  style: const TextStyle(color: Color(0xFFB86E00), fontWeight: FontWeight.w600),
                ),
              ),
            const SizedBox(height: 12),
            // One per row: side by side, the Russian labels didn't fit a phone's half width.
            InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () async {
                final day = await _pickDay(
                  initial: _serviceDate,
                  first: _today.subtract(const Duration(days: 366)),
                  last: _today,
                );
                if (day != null) setState(() => _serviceDate = day);
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.crmServiceDate,
                  prefixIcon: const Icon(Icons.event_rounded),
                ),
                child: Text(crmDayFormat.format(_serviceDate)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _odometer,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.crmOdometer,
                prefixIcon: const Icon(Icons.speed_rounded),
              ),
            ),
            DashSectionTitle(
              l10n.crmParts,
              trailing: TextButton.icon(
                onPressed: () => setState(() => _lines.add(_Line.manual())),
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: Text(l10n.crmAddManual),
              ),
            ),
            for (final l in _lines) ...[_lineCard(l), const SizedBox(height: 10)],
            OutlinedButton.icon(
              onPressed: _addProduct,
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.crmAddPart),
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            ),
            if (_lines.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l10n.crmPartsEmpty,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.textMuted),
                ),
              ),
            const SizedBox(height: 16),
            DashCard(
              padding: const EdgeInsets.fromLTRB(16, 6, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _recordSale,
                    onChanged: (v) => setState(() => _recordSale = v),
                    title: Text(l10n.crmRecordSale, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(
                      _recordSale ? l10n.crmRecordSaleOn : l10n.crmRecordSaleOff,
                      style: TextStyle(color: colors.textSecondary),
                    ),
                  ),
                  if (_recordSale) ...[
                    PillToggle<SaleType>(
                      values: SaleType.values,
                      selected: _saleType,
                      expand: true,
                      label: (t) => t == SaleType.paid ? l10n.commonPaid : l10n.commonOnCredit,
                      onChanged: (t) => setState(() => _saleType = t),
                    ),
                    if (_saleType == SaleType.debt) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: _paid,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          labelText: l10n.crmPaidNow,
                          prefixIcon: const Icon(Icons.payments_rounded),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.crmDebtLeft(
                          CurrencyFormatter.format(
                            (_total - (double.tryParse(_paid.text.replaceAll(',', '.')) ?? 0))
                                .clamp(0, double.infinity)
                                .toDouble(),
                            _currency,
                          ),
                        ),
                        style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notes,
              decoration: InputDecoration(
                labelText: l10n.commonNoteOptional,
                prefixIcon: const Icon(Icons.edit_note_rounded),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 14),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w600),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _lineCard(_Line l) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final auto = _autoDue(l);
    final hasInterval = l.interval.text.trim().isNotEmpty;
    final hint = l.dueDate != null
        ? l10n.crmDueManual
        : auto != null
        ? l10n.crmDueAuto(crmDayFormat.format(auto))
        : hasInterval
        ? l10n.crmDueNeedsDate
        : l10n.crmNoReminder;
    return DashCard(
      padding: const EdgeInsets.fromLTRB(14, 10, 6, 12),
      child: DashFormTheme(
        onSheet: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: l.productId != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.name.text,
                              style: TextStyle(fontWeight: FontWeight.w800, color: colors.textPrimary),
                            ),
                            if (l.stock != null)
                              Text(
                                l10n.crmInStock('${crmQtyFormat.format(l.stock)} ${l.unitShort ?? ''}'.trim()),
                                style: TextStyle(color: colors.textMuted, fontSize: 12.5),
                              ),
                          ],
                        )
                      : TextField(
                          controller: l.name,
                          decoration: InputDecoration(labelText: l10n.crmManualName, isDense: true),
                        ),
                ),
                IconButton(
                  tooltip: l10n.commonDelete,
                  icon: Icon(Icons.close_rounded, color: Theme.of(context).colorScheme.error),
                  onPressed: () => setState(() {
                    _lines.remove(l);
                    l.dispose();
                  }),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Row(
                children: [
                  DashStepper(
                    value: crmQtyFormat.format(l.quantity),
                    onMinus: () => setState(() => l.quantity = l.quantity > 1 ? l.quantity - 1 : l.quantity),
                    onPlus: () => setState(() => l.quantity += 1),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: l.price,
                      enabled: _recordSale,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(labelText: l10n.commonPrice, isDense: true),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextField(
                controller: l.interval,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(labelText: l10n.crmIntervalKm, hintText: '5000', isDense: true),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () async {
                  final day = await _pickDay(
                    initial: l.dueDate ?? auto ?? _serviceDate.add(const Duration(days: 30)),
                    first: _serviceDate.add(const Duration(days: 1)),
                    last: _serviceDate.add(const Duration(days: 365 * 3)),
                  );
                  if (day != null) setState(() => l.dueDate = day);
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.crmNextDate,
                    isDense: true,
                    prefixIcon: const Icon(Icons.event_rounded, size: 20),
                    suffixIcon: l.dueDate == null
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () => setState(() => l.dueDate = null),
                          ),
                  ),
                  child: Text(l.dueDate == null ? '—' : crmDayFormat.format(l.dueDate!)),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hint,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: hasInterval && auto == null && l.dueDate == null
                    ? const Color(0xFFB86E00)
                    : colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Searches the active store's own products (the server only sells those).
class _ProductPickerSheet extends StatefulWidget {
  const _ProductPickerSheet();

  @override
  State<_ProductPickerSheet> createState() => _ProductPickerSheetState();
}

class _ProductPickerSheetState extends State<_ProductPickerSheet> {
  final _search = TextEditingController();
  Timer? _debounce;
  List<Product>? _results;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  Future<void> _load(String q) async {
    final result = await getIt<ListProductsUseCase>().call(
      ProductQuery(search: q.trim().isEmpty ? null : q.trim(), limit: 30),
    );
    if (!mounted) return;
    setState(
      () => result.fold((page) {
        _results = page.data;
        _error = null;
      }, (failure) => _error = failure.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.75,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: DashSearchField(
                controller: _search,
                hint: l10n.crmPartSearch,
                onChanged: (v) {
                  _debounce?.cancel();
                  _debounce = Timer(const Duration(milliseconds: 300), () => _load(v));
                },
              ),
            ),
            Expanded(
              child: _results == null
                  ? Center(child: _error != null ? Text(_error!) : const CircularProgressIndicator())
                  : _results!.isEmpty
                  ? Center(
                      child: Text(l10n.commonNothingFound, style: TextStyle(color: colors.textMuted)),
                    )
                  : ListView.separated(
                      itemCount: _results!.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final p = _results![i];
                        final outOfStock = p.stock <= 0;
                        return ListTile(
                          enabled: !outOfStock,
                          title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text(
                            l10n.crmInStock('${crmQtyFormat.format(p.stock)} ${p.unit?.shortLabel ?? ''}'.trim()),
                          ),
                          trailing: Text(
                            CurrencyFormatter.format(p.price, p.currency),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          onTap: () => Navigator.of(context).pop(p),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
