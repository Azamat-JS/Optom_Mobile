import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/features/master_catalog/domain/entities/master_product.dart';
import 'package:bsmart/features/master_catalog/domain/usecases/search_master_catalog_usecase.dart';

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
      result.fold(
        (page) => _results = page.data,
        (failure) => _errorMessage = failure.message,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Katalogdan qidirish...', border: InputBorder.none),
          onChanged: _onQueryChanged,
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _results.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }
    if (_results.isEmpty) {
      return const Center(child: Text('Hech narsa topilmadi'));
    }
    return ListView.separated(
      itemCount: _results.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = _results[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: item.primaryImageUrl != null ? CachedNetworkImageProvider(item.primaryImageUrl!) : null,
            child: item.primaryImageUrl == null ? const Icon(Icons.inventory_2_outlined) : null,
          ),
          title: Text(item.name),
          subtitle: Text([if (item.brand != null) item.brand!, if (item.categoryName != null) item.categoryName!].join(' • ')),
          onTap: () => Navigator.of(context).pop(item),
        );
      },
    );
  }
}
