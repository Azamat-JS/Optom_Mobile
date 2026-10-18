import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/features/storefront/presentation/providers/storefront_shop_providers.dart';
import 'package:bsmart/features/storefront/presentation/widgets/storefront_masonry.dart';

/// A shop's products as a photo mosaic with a live search (Phase 9 U2d, the
/// reference's "Search in Mainland China" grid). Route
/// `/customer/shops/:sellerId/explore?storeId=&name=`, guest-eligible.
///
/// Reuses [shopProductsProvider], so coming from the shop page needs no new
/// request.
class StorefrontShopExploreScreen extends StatelessWidget {
  const StorefrontShopExploreScreen({required this.sellerId, this.storeId, this.name, super.key});

  final String sellerId;
  final String? storeId;
  final String? name;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark).copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Theme(
        data: BrandTheme.of(context),
        child: _ExploreBody(sellerId: sellerId, storeId: storeId, name: name),
      ),
    );
  }
}

class _ExploreBody extends ConsumerStatefulWidget {
  const _ExploreBody({required this.sellerId, required this.storeId, required this.name});

  final String sellerId;
  final String? storeId;
  final String? name;

  @override
  ConsumerState<_ExploreBody> createState() => _ExploreBodyState();
}

class _ExploreBodyState extends ConsumerState<_ExploreBody> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    final l10n = context.l10n;
    final async = ref.watch(shopProductsProvider((sellerId: widget.sellerId, storeId: widget.storeId)));
    final all = async.valueOrNull ?? const [];
    final needle = _query.trim().toLowerCase();
    final visible = needle.isEmpty ? all : all.where((p) => p.name.toLowerCase().contains(needle)).toList();
    final shopName = widget.name ?? all.firstOrNull?.storeName ?? all.firstOrNull?.sellerName ?? '';

    return Scaffold(
      backgroundColor: colors.sheet,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: Container(
                height: 58,
                decoration: BoxDecoration(color: colors.field, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                      icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.textPrimary, size: 20),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        autofocus: false,
                        onChanged: (value) => setState(() => _query = value),
                        textInputAction: TextInputAction.search,
                        cursorColor: colors.accentText,
                        style: TextStyle(color: colors.textPrimary, fontSize: 17, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          hintText: l10n.sfSearchInShop(shopName),
                          hintMaxLines: 1,
                          hintStyle: TextStyle(color: colors.textMuted, fontSize: 17, fontWeight: FontWeight.w500),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isCollapsed: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    if (_query.isNotEmpty)
                      IconButton(
                        tooltip: l10n.authClear,
                        onPressed: () {
                          _controller.clear();
                          setState(() => _query = '');
                        },
                        icon: Icon(Icons.close_rounded, color: colors.textSecondary),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Icon(Icons.search_rounded, color: colors.textSecondary, size: 26),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: async.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => Center(
                  child: TextButton(
                    onPressed: () =>
                        ref.invalidate(shopProductsProvider((sellerId: widget.sellerId, storeId: widget.storeId))),
                    child: Text(l10n.commonRetry),
                  ),
                ),
                data: (_) => visible.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            needle.isEmpty ? l10n.sfShopEmpty : l10n.sfNoResults(_query.trim()),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: colors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      )
                    : StorefrontMasonry(products: visible),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
