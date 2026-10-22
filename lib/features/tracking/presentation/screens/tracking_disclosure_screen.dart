import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:bsmart/core/l10n/l10n.dart';
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

  static List<(IconData, String, String)> _items(AppLocalizations l10n) => [
    (Icons.my_location_rounded, l10n.trkWhatTitle, l10n.trkWhatBody),
    (Icons.schedule_rounded, l10n.trkWhenTitle, l10n.trkWhenBody),
    (Icons.visibility_rounded, l10n.trkWhoTitle, l10n.trkWhoBody),
    (Icons.pause_circle_rounded, l10n.trkStopTitle, l10n.trkStopBody),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(18));
    const height = Size.fromHeight(56);
    return DashPage(
      title: context.l10n.trkShareTitle,
      bottomBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          child: readOnly
              ? OutlinedButton(
                  style: OutlinedButton.styleFrom(minimumSize: height, shape: shape),
                  onPressed: () => Navigator.pop(context),
                  child: Text(context.l10n.commonClose),
                )
              : Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(minimumSize: height, shape: shape),
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(context.l10n.trkNotNow),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(minimumSize: height, shape: shape),
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(context.l10n.trkAgree),
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
            context.l10n.trkDisclosureLead,
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800, height: 1.25),
          ),
          const SizedBox(height: 20),
          DashCard(
            child: Column(
              children: [
                for (final (i, item) in _items(context.l10n).indexed)
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
