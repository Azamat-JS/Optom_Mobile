import 'package:flutter/material.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/entities/geo_point.dart';
import 'package:bsmart/shared/widgets/map_pin_picker_screen.dart';

/// Form row for an optional map pin: "Xaritada belgilash" until chosen, then
/// "Belgilangan" with change/clear actions.
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
    final picked = await MapPinPickerScreen.pick(context, title: pickerTitle ?? context.l10n.locationPickTitle, initial: value);
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final set = value != null;
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: set ? theme.colorScheme.primary : theme.colorScheme.outlineVariant),
      ),
      child: ListTile(
        onTap: () => _pick(context),
        leading: Icon(set ? Icons.where_to_vote : Icons.add_location_alt_outlined, color: theme.colorScheme.primary),
        title: Text(set ? context.l10n.locationMarked : (label ?? context.l10n.locationMarkOnMap)),
        subtitle: Text(set ? value!.label : (helper ?? context.l10n.locationCourierHint)),
        trailing: set
            ? IconButton(tooltip: context.l10n.locationRemove, icon: const Icon(Icons.close), onPressed: () => onChanged(null))
            : const Icon(Icons.chevron_right),
      ),
    );
  }
}
