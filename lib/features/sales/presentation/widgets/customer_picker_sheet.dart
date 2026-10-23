import 'dart:async';

import 'package:flutter/material.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/features/customers/domain/entities/customer.dart';
import 'package:bsmart/features/customers/domain/entities/customer_query.dart';
import 'package:bsmart/features/customers/domain/entities/customer_write_params.dart';
import 'package:bsmart/features/customers/domain/usecases/create_customer_usecase.dart';
import 'package:bsmart/features/customers/domain/usecases/list_customers_usecase.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// A bottom sheet used by POS checkout to pick (or quick-create) a
/// `Customer` — every `Sale` requires one, so this is the one place a
/// cashier picks who they're selling to.
class CustomerPickerSheet extends StatefulWidget {
  const CustomerPickerSheet({super.key});

  static Future<Customer?> show(BuildContext context) {
    return showModalBottomSheet<Customer>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const CustomerPickerSheet(),
    );
  }

  @override
  State<CustomerPickerSheet> createState() => _CustomerPickerSheetState();
}

class _CustomerPickerSheetState extends State<CustomerPickerSheet> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  List<Customer> _results = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _search('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    setState(() => _isLoading = true);
    final result = await getIt<ListCustomersUseCase>().call(
      CustomerQuery(search: query.isEmpty ? null : query, isActive: true, limit: 30),
    );
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      result.fold((page) => _results = page.data, (_) => _results = const []);
    });
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _search(value));
  }

  Future<void> _quickCreate() async {
    final query = _searchController.text.trim();
    final created = await showDialog<Customer>(
      context: context,
      builder: (context) => _QuickCreateCustomerDialog(initialPhone: query),
    );
    if (created != null && mounted) Navigator.of(context).pop(created);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 16, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.commonPickCustomer,
                          style: TextStyle(color: colors.textPrimary, fontSize: 20, fontWeight: FontWeight.w800),
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: _quickCreate,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 40),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                        label: Text(l10n.commonNew),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: l10n.salesCustomerSearchHint,
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: colors.field,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _results.isEmpty
                      ? Center(
                          child: Text(
                            l10n.salesCustomerNotFound,
                            style: TextStyle(color: colors.textMuted, fontWeight: FontWeight.w600),
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          itemCount: _results.length,
                          itemBuilder: (context, index) {
                            final customer = _results[index];
                            return ListTile(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              leading: CircleAvatar(
                                backgroundColor: AppColors.brandYellow,
                                foregroundColor: AppColors.onBrand,
                                child: Text(
                                  customer.firstName.characters.firstOrNull?.toUpperCase() ?? '?',
                                  style: const TextStyle(fontWeight: FontWeight.w800),
                                ),
                              ),
                              title: Text(
                                customer.fullName,
                                style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w700),
                              ),
                              subtitle: Text(customer.phone ?? '—', style: TextStyle(color: colors.textMuted)),
                              trailing: Icon(Icons.chevron_right_rounded, color: colors.textMuted),
                              onTap: () => Navigator.of(context).pop(customer),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _QuickCreateCustomerDialog extends StatefulWidget {
  const _QuickCreateCustomerDialog({this.initialPhone});

  final String? initialPhone;

  @override
  State<_QuickCreateCustomerDialog> createState() => _QuickCreateCustomerDialogState();
}

class _QuickCreateCustomerDialogState extends State<_QuickCreateCustomerDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _firstNameController = TextEditingController();
  late final _phoneController = TextEditingController(
    text: RegExp(r'^\+?[0-9]+$').hasMatch(widget.initialPhone ?? '') ? widget.initialPhone : null,
  );
  bool _isSaving = false;
  String? _errorMessage;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });
    // Backend requires a non-empty lastName; the quick-create dialog only
    // asks for one name field, so a bare single word becomes firstName with
    // a placeholder lastName rather than failing validation.
    final fullName = _firstNameController.text.trim();
    final spaceIndex = fullName.indexOf(' ');
    final firstName = spaceIndex == -1 ? fullName : fullName.substring(0, spaceIndex);
    final lastName = spaceIndex == -1 ? '-' : fullName.substring(spaceIndex + 1).trim();

    final result = await getIt<CreateCustomerUseCase>().call(
      CreateCustomerParams(
        firstName: firstName,
        lastName: lastName.isEmpty ? '-' : lastName,
        phone: _phoneController.text.trim(),
      ),
    );
    if (!mounted) return;
    result.fold(
      (customer) => Navigator.of(context).pop(customer),
      (failure) => setState(() {
        _isSaving = false;
        _errorMessage = failure.message;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final error = Theme.of(context).colorScheme.error;
    return DashFormTheme(
      onSheet: true,
      child: AlertDialog(
        scrollable: true,
        title: Text(context.l10n.customersNewTitle),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _firstNameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: context.l10n.commonFirstNameRequired,
                  prefixIcon: const Icon(Icons.person_rounded),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? context.l10n.commonFirstNameMissing : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: context.l10n.commonPhoneRequired,
                  hintText: '+998901234567',
                  prefixIcon: const Icon(Icons.phone_rounded),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return context.l10n.commonPhoneMissing;
                  if (!RegExp(r'^\+?[0-9]{9,15}$').hasMatch(v.trim())) return context.l10n.commonInvalidFormat;
                  return null;
                },
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: error, fontWeight: FontWeight.w700),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(context.l10n.commonCancel)),
          FilledButton(
            onPressed: _isSaving ? null : _submit,
            child: _isSaving
                ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(context.l10n.commonSave),
          ),
        ],
      ),
    );
  }
}
