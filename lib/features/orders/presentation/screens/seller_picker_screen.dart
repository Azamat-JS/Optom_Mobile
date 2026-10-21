import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/features/catalog/domain/entities/catalog_seller.dart';
import 'package:bsmart/features/catalog/domain/usecases/list_catalog_sellers_usecase.dart';
import 'package:bsmart/features/orders/presentation/providers/create_order_cart_notifier.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

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
    final l10n = context.l10n;
    final sellers = _sellers;
    return DashPage(
      title: l10n.ordersPickWholesaler,
      body: _errorMessage != null
          ? DashEmptyState(icon: Icons.cloud_off_rounded, text: _errorMessage!)
          : sellers == null
          ? const Center(child: CircularProgressIndicator())
          : sellers.isEmpty
          ? DashEmptyState(icon: Icons.storefront_rounded, text: l10n.ordersNoWholesalers)
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              itemCount: sellers.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final seller = sellers[index];
                return DashListCard(
                  leading: Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(color: AppColors.brandYellow, shape: BoxShape.circle),
                    child: Text(
                      seller.fullName.characters.firstOrNull?.toUpperCase() ?? '?',
                      style: const TextStyle(color: AppColors.onBrand, fontSize: 19, fontWeight: FontWeight.w800),
                    ),
                  ),
                  title: seller.fullName,
                  subtitle: seller.phone,
                  trailing: const Icon(Icons.chevron_right_rounded),
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
