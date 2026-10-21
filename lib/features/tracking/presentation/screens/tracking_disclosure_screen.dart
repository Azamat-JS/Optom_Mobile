import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// Full-screen "prominent disclosure" shown before the first OS location
/// prompt (a Google Play requirement for location used in the background),
/// and re-openable read-only from the tracking details sheet.
class TrackingDisclosureScreen extends StatelessWidget {
  const TrackingDisclosureScreen({super.key, this.readOnly = false});

  final bool readOnly;

  /// Resolves to true only when the courier tapped "Roziman".
  static Future<bool?> show(BuildContext context, {bool readOnly = false}) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute(fullscreenDialog: true, builder: (_) => TrackingDisclosureScreen(readOnly: readOnly)),
    );
  }

  static const _items = [
    (
      Icons.my_location_rounded,
      'Nima ulashiladi',
      "Telefoningizning GPS joylashuvi: koordinatalar, tezlik va harakat yo'nalishi.",
    ),
    (
      Icons.schedule_rounded,
      'Qachon',
      "Faqat siz «Onlayn» bo'lganingizda yoki faol yetkazish paytida — ilova fonda yoki ekran "
          "o'chiq bo'lsa ham. Bu vaqtda bildirishnomalar panelida doimiy xabar turadi.",
    ),
    (
      Icons.visibility_rounded,
      "Kim ko'radi",
      'Biznes egangiz va uning administratorlari, hamda faol yetkazish buyurtmasining mijozi.',
    ),
    (
      Icons.pause_circle_rounded,
      "Qanday to'xtatiladi",
      "Istalgan vaqtda «Oflayn» ga o'ting — joylashuv yuborish darhol to'xtaydi. Oflayn paytida "
          'joylashuvingiz yuborilmaydi.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(18));
    const height = Size.fromHeight(56);
    return DashPage(
      title: 'Joylashuvni ulashish',
      bottomBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          child: readOnly
              ? OutlinedButton(
                  style: OutlinedButton.styleFrom(minimumSize: height, shape: shape),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Yopish'),
                )
              : Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(minimumSize: height, shape: shape),
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Hozir emas'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(minimumSize: height, shape: shape),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Roziman'),
                      ),
                    ),
                  ],
                ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        children: [
          Center(
            child: Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(color: AppColors.brandYellow, shape: BoxShape.circle),
              child: const Icon(Icons.share_location_rounded, size: 44, color: AppColors.onBrand),
            ).animate().scale(duration: AppMotion.slow, curve: AppMotion.emphasized),
          ),
          const SizedBox(height: 16),
          Text(
            'Yetkazishlarni kuzatish uchun bsmart joylashuvingizdan foydalanadi',
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800, height: 1.25),
          ),
          const SizedBox(height: 20),
          DashCard(
            child: Column(
              children: [
                for (final (i, item) in _items.indexed)
                  Padding(
                        padding: EdgeInsets.only(top: i == 0 ? 0 : 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: DashColors.inset(context),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(item.$1, size: 21, color: colors.textPrimary),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.$2,
                                    style: TextStyle(
                                      color: colors.textPrimary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.$3,
                                    style: TextStyle(color: colors.textSecondary, fontSize: 14, height: 1.35),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                      .animate(delay: AppMotion.fast * (i + 1))
                      .fadeIn(duration: AppMotion.standard)
                      .slideY(begin: 0.1, curve: AppMotion.emphasized),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
