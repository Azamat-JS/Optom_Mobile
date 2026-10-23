import 'package:flutter/material.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/entities/geo_point.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/map_pin_picker_screen.dart';

/// Form row for an optional map pin: "Xaritada belgilash" until chosen, then
/// "Belgilangan" with change/clear actions. Phase 9: a filled tile with a
/// tinted pin icon, styled like the form fields around it.
class LocationPickerField extends StatelessWidget {
  const LocationPickerField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.pickerTitle,
    this.helper,
  });

  final GeoPoint? value;
  final ValueChanged<GeoPoint?> onChanged;

  /// Default labels are localized ("Mark on map" / "Mark the location").
  final String? label;
  final String? pickerTitle;
  final String? helper;

  Future<void> _pick(BuildContext context) async {
    final picked = await MapPinPickerScreen.pick(
      context,
      title: pickerTitle ?? context.l10n.locationPickTitle,
      initial: value,
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = BrandColors.of(context);
    final set = value != null;
    // Same fill as the text fields around it (DashFormTheme sets it per page / sheet).
    final fill = theme.inputDecorationTheme.fillColor ?? DashColors.card(context);
    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _pick(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 6, 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: set ? AppColors.brandYellow : AppColors.brandYellow.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  set ? Icons.where_to_vote_rounded : Icons.add_location_alt_rounded,
                  color: set ? AppColors.onBrand : colors.accentText,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      set ? context.l10n.locationMarked : (label ?? context.l10n.locationMarkOnMap),
                      style: TextStyle(color: colors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      set ? value!.label : (helper ?? context.l10n.locationCourierHint),
                      style: TextStyle(color: colors.textMuted, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              if (set)
                IconButton(
                  tooltip: context.l10n.locationRemove,
                  icon: Icon(Icons.close_rounded, color: colors.textSecondary),
                  onPressed: () => onChanged(null),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(Icons.chevron_right_rounded, color: colors.textMuted),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
