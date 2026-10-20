import 'dart:async';

import 'package:flutter/material.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/features/master_catalog/domain/entities/master_product.dart';
import 'package:bsmart/features/master_catalog/domain/usecases/search_master_catalog_usecase.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// "Add from Catalog" — search the SUPER_ADMIN-curated shared catalog and
/// pick an entry to link a new product to. Pops with the selected
/// [MasterProduct], or `null` if cancelled.
class MasterCatalogPickerScreen extends StatefulWidget {
  const MasterCatalogPickerScreen({super.key});

  @override
  State<MasterCatalogPickerScreen> createState() => _MasterCatalogPickerScreenState();
}

class _MasterCatalogPickerScreenState extends State<MasterCatalogPickerScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  List<MasterProduct> _results = const [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _runSearch('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _runSearch(value));
  }

  Future<void> _runSearch(String query) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final result = await getIt<SearchMasterCatalogUseCase>().call(search: query);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      result.fold((page) => _results = page.data, (failure) => _errorMessage = failure.message);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DashPage(
      title: l10n.productsPickFromCatalog,
      header: DashSearchField(controller: _searchController, hint: l10n.masterSearchHint, onChanged: _onQueryChanged),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _results.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return DashEmptyState(icon: Icons.cloud_off_rounded, text: _errorMessage!);
    }
    if (_results.isEmpty) {
      return DashEmptyState(icon: Icons.search_off_rounded, text: context.l10n.commonNothingFound);
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: _results.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = _results[index];
        return DashListCard(
          leading: DashThumb(url: item.primaryImageUrl),
          title: item.name,
          subtitle: [
            if (item.brand != null) item.brand!,
            if (item.categoryName != null) item.categoryName!,
          ].join(' · '),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => Navigator.of(context).pop(item),
        );
      },
    );
  }
}
