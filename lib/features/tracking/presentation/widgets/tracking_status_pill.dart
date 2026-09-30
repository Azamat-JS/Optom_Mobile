import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/features/tracking/presentation/providers/tracking_notifier.dart';
import 'package:bsmart/features/tracking/presentation/providers/tracking_state.dart';
import 'package:bsmart/features/tracking/presentation/tracking_actions.dart';
import 'package:bsmart/features/tracking/presentation/widgets/tracking_details_sheet.dart';
import 'package:bsmart/features/tracking/presentation/widgets/tracking_status_style.dart';

/// Always-visible AppBar indicator of location sharing ("Joylashuv
/// ulashilmoqda · 5 soniya oldin"). Tap opens [TrackingDetailsSheet].
class TrackingStatusPill extends ConsumerStatefulWidget {
  const TrackingStatusPill({super.key});

  @override
  ConsumerState<TrackingStatusPill> createState() => _TrackingStatusPillState();
}

class _TrackingStatusPillState extends ConsumerState<TrackingStatusPill> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Keeps the "N soniya oldin" part fresh.
    _ticker = Timer.periodic(const Duration(seconds: 5), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tracking = ref.watch(trackingNotifierProvider);
    final style = TrackingStatusStyle.of(tracking.phase, Theme.of(context).colorScheme);
    final label = tracking.phase == TrackingPhase.sharing
        ? trackingAgoLabel(tracking.lastSentAt, DateTime.now())
        : style.label;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        color: style.color.withValues(alpha: 0.12),
        shape: StadiumBorder(side: BorderSide(color: style.color.withValues(alpha: 0.5))),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: () => TrackingDetailsSheet.show(context),
          child: AnimatedSize(
            duration: AppMotion.standard,
            curve: AppMotion.emphasized,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PulsingDot(color: style.color, pulsing: tracking.phase == TrackingPhase.sharing),
                  const SizedBox(width: 6),
                  Text(label, style: TextStyle(color: style.color, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.color, required this.pulsing});

  final Color color;
  final bool pulsing;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));

  @override
  void initState() {
    super.initState();
    if (widget.pulsing) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_PulsingDot old) {
    super.didUpdateWidget(old);
    if (widget.pulsing && !_controller.isAnimating) _controller.repeat(reverse: true);
    if (!widget.pulsing) _controller.value = 1;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.35, end: 1.0).animate(_controller),
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}
