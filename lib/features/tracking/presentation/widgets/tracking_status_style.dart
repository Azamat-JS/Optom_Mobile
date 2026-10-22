import 'package:flutter/material.dart';

import 'package:bsmart/core/l10n/app_l10n.dart';
import 'package:bsmart/features/tracking/presentation/providers/tracking_state.dart';

/// Colour + label per tracking phase, shared by the pill, sheet and toggle so
/// they always agree.
class TrackingStatusStyle {
  const TrackingStatusStyle(this.color, this.label, this.icon);

  final Color color;
  final String label;
  final IconData icon;

  static TrackingStatusStyle of(TrackingPhase phase, ColorScheme scheme) => switch (phase) {
    TrackingPhase.sharing => TrackingStatusStyle(const Color(0xFF2E7D32), appL10n.trkSharing, Icons.share_location),
    TrackingPhase.starting => TrackingStatusStyle(const Color(0xFFF9A825), appL10n.trkConnecting, Icons.sync),
    TrackingPhase.noGpsFix => TrackingStatusStyle(const Color(0xFFF9A825), appL10n.trkNoGps, Icons.gps_not_fixed),
    TrackingPhase.reconnecting => TrackingStatusStyle(
      const Color(0xFFF9A825),
      appL10n.trkReconnecting,
      Icons.cloud_off,
    ),
    TrackingPhase.permissionDenied || TrackingPhase.permissionDeniedForever => TrackingStatusStyle(
      scheme.error,
      appL10n.trkDenied,
      Icons.location_disabled,
    ),
    TrackingPhase.servicesDisabled => TrackingStatusStyle(scheme.error, appL10n.trkGpsOff, Icons.location_off),
    TrackingPhase.off => TrackingStatusStyle(scheme.outline, appL10n.trkOffline, Icons.location_off_outlined),
  };
}
