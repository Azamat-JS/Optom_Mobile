import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:bsmart/core/theme/app_motion.dart';

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
      Icons.my_location,
      'Nima ulashiladi',
      "Telefoningizning GPS joylashuvi: koordinatalar, tezlik va harakat yo'nalishi.",
    ),
    (
      Icons.schedule,
      'Qachon',
      "Faqat siz «Onlayn» bo'lganingizda yoki faol yetkazish paytida — ilova fonda yoki ekran "
          "o'chiq bo'lsa ham. Bu vaqtda bildirishnomalar panelida doimiy xabar turadi.",
    ),
    (
      Icons.visibility_outlined,
      "Kim ko'radi",
      'Biznes egangiz va uning administratorlari, hamda faol yetkazish buyurtmasining mijozi.',
    ),
    (
      Icons.pause_circle_outline,
      "Qanday to'xtatiladi",
      "Istalgan vaqtda «Oflayn» ga o'ting — joylashuv yuborish darhol to'xtaydi. Oflayn paytida "
          'joylashuvingiz yuborilmaydi.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Joylashuvni ulashish')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                children: [
                  Icon(Icons.share_location, size: 64, color: theme.colorScheme.primary)
                      .animate()
                      .scale(duration: AppMotion.slow, curve: AppMotion.emphasized),
                  const SizedBox(height: 16),
                  Text(
                    'Yetkazishlarni kuzatish uchun bsmart joylashuvingizdan foydalanadi',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24),
                  for (final (i, item) in _items.indexed)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(item.$1, color: theme.colorScheme.primary),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.$2, style: theme.textTheme.titleSmall),
                                const SizedBox(height: 4),
                                Text(item.$3, style: theme.textTheme.bodyMedium),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: readOnly
                  ? SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Yopish')),
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Hozir emas'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Roziman'),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
