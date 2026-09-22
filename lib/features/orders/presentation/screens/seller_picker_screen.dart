import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/features/catalog/domain/entities/catalog_seller.dart';
import 'package:bsmart/features/catalog/domain/usecases/list_catalog_sellers_usecase.dart';
import 'package:bsmart/features/orders/presentation/providers/create_order_cart_notifier.dart';

/// Step 1 of the RETAILER create-order flow: pick which wholesaler to buy
/// from. `GET /catalog/sellers` — RETAILER only.
class SellerPickerScreen extends ConsumerStatefulWidget {
  const SellerPickerScreen({super.key});

  @override
  ConsumerState<SellerPickerScreen> createState() => _SellerPickerScreenState();
}

class _SellerPickerScreenState extends ConsumerState<SellerPickerScreen> {
  List<CatalogSeller>? _sellers;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await getIt<ListCatalogSellersUseCase>().call();
    if (!mounted) return;
    setState(() {
      result.fold((sellers) => _sellers = sellers, (failure) => _errorMessage = failure.message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Optomchini tanlang')),
      body: _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : _sellers == null
              ? const Center(child: CircularProgressIndicator())
              : _sellers!.isEmpty
                  ? const Center(child: Text('Optomchilar topilmadi'))
                  : ListView.separated(
                      itemCount: _sellers!.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final seller = _sellers![index];
                        return ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.storefront_outlined)),
                          title: Text(seller.fullName),
                          subtitle: Text(seller.phone),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            ref.read(createOrderCartProvider.notifier).selectSeller(seller);
                            context.push(RouteNames.orderCatalogBrowse);
                          },
                        );
                      },
                    ),
    );
  }
}
