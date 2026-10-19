import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/core/theme/brand_theme.dart';

/// "Buyurtma qabul qilindi!" after checkout (the reference's "Yay! Order
/// Received"). Route `/customer/order-placed/:orderId?shop=`, login required.
class OrderPlacedScreen extends StatelessWidget {
  const OrderPlacedScreen({required this.orderId, this.shop, super.key});

  final String orderId;
  final String? shop;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Theme(
      data: BrandTheme.of(context),
      child: Builder(
        builder: (context) {
          final colors = BrandColors.of(context);
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark).copyWith(
              statusBarColor: Colors.transparent,
            ),
            child: PopScope(
              // Back goes to the storefront, not to the emptied checkout.
              canPop: false,
              onPopInvokedWithResult: (didPop, _) {
                if (!didPop) context.go(RouteNames.customerHome);
              },
              child: Scaffold(
                backgroundColor: colors.sheet,
                body: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 0, 28, 20),
                    child: Column(
                      children: [
                        const Spacer(flex: 3),
                        Container(
                              width: 150,
                              height: 150,
                              decoration: const BoxDecoration(color: AppColors.brandYellow, shape: BoxShape.circle),
                              child: const Icon(Icons.check_rounded, size: 92, color: AppColors.onBrand),
                            )
                            .animate()
                            .scale(begin: const Offset(0.4, 0.4), duration: 650.ms, curve: Curves.elasticOut)
                            .fadeIn(duration: AppMotion.fast),
                        const SizedBox(height: 32),
                        Text(
                          l10n.coPlacedTitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ).animate().fadeIn(delay: 250.ms, duration: AppMotion.standard).slideY(begin: 0.2, end: 0),
                        const SizedBox(height: 10),
                        Text(
                          l10n.coPlacedBody(shop ?? ''),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colors.textSecondary, fontSize: 16, height: 1.45),
                        ).animate().fadeIn(delay: 350.ms, duration: AppMotion.standard),
                        const Spacer(flex: 4),
                        FilledButton(
                          onPressed: () => context
                            ..go(RouteNames.customerHome)
                            ..push(RouteNames.customerOrder(orderId)),
                          child: Text(l10n.coTrackOrder),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => context.go(RouteNames.customerHome),
                          child: Text(l10n.coContinueShopping),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
