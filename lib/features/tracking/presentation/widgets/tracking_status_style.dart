import 'package:flutter/material.dart';

import 'package:bsmart/features/tracking/presentation/providers/tracking_state.dart';

/// Colour + label per tracking phase, shared by the pill, sheet and toggle so
/// they always agree.
class TrackingStatusStyle {
  const TrackingStatusStyle(this.color, this.label, this.icon);

  final Color color;
  final String label;
  final IconData icon;

  static TrackingStatusStyle of(TrackingPhase phase, ColorScheme scheme) => switch (phase) {
        TrackingPhase.sharing => const TrackingStatusStyle(Color(0xFF2E7D32), 'Joylashuv ulashilmoqda', Icons.share_location),
        TrackingPhase.starting => const TrackingStatusStyle(Color(0xFFF9A825), 'Ulanmoqda…', Icons.sync),
        TrackingPhase.noGpsFix => const TrackingStatusStyle(Color(0xFFF9A825), "GPS signali yo'q", Icons.gps_not_fixed),
        TrackingPhase.reconnecting => const TrackingStatusStyle(Color(0xFFF9A825), 'Qayta ulanmoqda…', Icons.cloud_off),
        TrackingPhase.permissionDenied ||
        TrackingPhase.permissionDeniedForever =>
          TrackingStatusStyle(scheme.error, 'Ruxsat berilmagan', Icons.location_disabled),
        TrackingPhase.servicesDisabled => TrackingStatusStyle(scheme.error, "GPS o'chirilgan", Icons.location_off),
        TrackingPhase.off => TrackingStatusStyle(scheme.outline, 'Oflayn', Icons.location_off_outlined),
      };
}
