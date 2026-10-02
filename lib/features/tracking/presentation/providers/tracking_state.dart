/// What the courier's location sharing is doing right now — the single source
/// of truth behind the status pill, details sheet, problem banner and online
/// toggle.
enum TrackingPhase {
  /// Not sharing (offline).
  off,
  starting,

  /// Points are reaching the server.
  sharing,

  /// Online, but no usable GPS fix lately (indoors, poor signal, points
  /// rejected as inaccurate). Presence is still kept alive by heartbeats.
  noGpsFix,

  /// Online, but the socket is down — reconnecting automatically.
  reconnecting,
  permissionDenied,
  permissionDeniedForever,
  servicesDisabled,
}

class TrackingState {
  const TrackingState({
    this.phase = TrackingPhase.off,
    this.lastSentAt,
    this.notificationsDenied = false,
    this.activeDeliveryLabel,
    this.customerWatches = false,
  });

  final TrackingPhase phase;
  final DateTime? lastSentAt;

  /// Android 13+: the foreground notification can't be shown.
  final bool notificationsDenied;

  /// Set while the courier has an accepted, unfinished delivery (e.g. "#ORD-123" or "2 ta
  /// yetkazish") — drives the notification text and the "who sees me" wording.
  final String? activeDeliveryLabel;

  /// True when a B2C customer can currently watch this courier (restaurant customers have no
  /// account, so they can't in v1).
  final bool customerWatches;

  String get watchersLabel {
    if (!isOnline) return 'Hech kim — joylashuv yuborilmayapti';
    if (activeDeliveryLabel != null && customerWatches) {
      return 'Biznes egangiz, administratorlar va mijoz ($activeDeliveryLabel)';
    }
    return 'Biznes egangiz va administratorlar';
  }

  /// The courier currently wants to be online (location may still be
  /// temporarily unavailable — see [phase]).
  bool get isOnline => const {
        TrackingPhase.starting,
        TrackingPhase.sharing,
        TrackingPhase.noGpsFix,
        TrackingPhase.reconnecting,
      }.contains(phase);

  bool get hasProblem => const {
        TrackingPhase.permissionDenied,
        TrackingPhase.permissionDeniedForever,
        TrackingPhase.servicesDisabled,
      }.contains(phase);

  TrackingState copyWith({TrackingPhase? phase, DateTime? lastSentAt, bool? notificationsDenied}) =>
      TrackingState(
        phase: phase ?? this.phase,
        lastSentAt: lastSentAt ?? this.lastSentAt,
        notificationsDenied: notificationsDenied ?? this.notificationsDenied,
        activeDeliveryLabel: activeDeliveryLabel,
        customerWatches: customerWatches,
      );

  TrackingState withActiveDelivery(String? label, {required bool customerWatches}) => TrackingState(
        phase: phase,
        lastSentAt: lastSentAt,
        notificationsDenied: notificationsDenied,
        activeDeliveryLabel: label,
        customerWatches: customerWatches,
      );
}
