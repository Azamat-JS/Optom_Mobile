import 'package:flutter/material.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/features/deliveries/domain/entities/delivery.dart';
import 'package:bsmart/features/deliveries/domain/usecases/manage_delivery_usecases.dart';
import 'package:bsmart/features/deliveries/presentation/delivery_actions.dart';

/// Staff view of how a delivery ended / where it's stuck (Phase 7 N2): the courier's fail reason
/// and note, how far from the customer they were, the cancel reason, and the handover-code state
/// with "Kodsiz topshirishga ruxsat" (waive). Renders nothing when there's nothing to say.
class DeliveryOutcomeSection extends StatefulWidget {
  const DeliveryOutcomeSection({super.key, required this.delivery, required this.onChanged});

  final Delivery delivery;

  /// Called after a successful waiver so the parent reloads the delivery.
  final VoidCallback onChanged;

  @override
  State<DeliveryOutcomeSection> createState() => _DeliveryOutcomeSectionState();
}

class _DeliveryOutcomeSectionState extends State<DeliveryOutcomeSection> {
  bool _busy = false;

  static String _distance(AppLocalizations l10n, int meters) => meters < 1000
      ? l10n.commonMeters('$meters')
      : l10n.commonKm((meters / 1000).toStringAsFixed(1).replaceAll('.', ','));

  Future<void> _waive() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.dlvWaiveTitle),
        content: Text(context.l10n.dlvWaiveBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.l10n.commonNo)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(context.l10n.dlvWaiveConfirm)),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    final result = await getIt<WaiveHandoverUseCase>().call(widget.delivery.id);
    if (!mounted) return;
    setState(() => _busy = false);
    result.fold((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.dlvWaived)));
      widget.onChanged();
    }, (failure) => DeliveryActions.showError(context, failure.message));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final d = widget.delivery;
    final h = d.handover;
    final lines = <Widget>[];

    if (d.status == DeliveryStatus.failed && d.failReason != null) {
      lines.add(_line(theme, Icons.report_outlined, theme.colorScheme.error, l10n.dlvReasonWith(d.failReason!.label)));
      if (d.failNote?.isNotEmpty ?? false) {
        lines.add(_line(theme, Icons.notes, theme.colorScheme.outline, '"${d.failNote}"'));
      }
    }
    final distance = d.outcomeLocation?.distanceToDropoffMeters;
    if (distance != null && (d.status == DeliveryStatus.failed || d.status == DeliveryStatus.delivered)) {
      lines.add(
        _line(
          theme,
          Icons.place_outlined,
          distance > 300 ? theme.colorScheme.error : theme.colorScheme.outline,
          l10n.dlvDistanceFromDropoff(_distance(l10n, distance)),
        ),
      );
    }
    if (d.status == DeliveryStatus.cancelled && (d.cancelReason?.isNotEmpty ?? false)) {
      lines.add(_line(theme, Icons.info_outline, theme.colorScheme.outline, l10n.dlvCancelReasonWith(d.cancelReason!)));
    }
    if (h.pending && d.status.isWithCourier) {
      lines.add(
        _line(
          theme,
          h.locked ? Icons.lock_outline : Icons.pin_outlined,
          h.locked ? theme.colorScheme.error : theme.colorScheme.tertiary,
          h.locked ? l10n.dlvCodeLockedStaff : l10n.dlvCodeWaiting(h.attemptsLeft),
        ),
      );
    } else if (h.required && h.waived) {
      lines.add(_line(theme, Icons.verified_outlined, theme.colorScheme.outline, l10n.dlvWaivedStaff));
    }
    if (lines.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...lines,
          if (h.pending && d.status.isWithCourier)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _busy ? null : _waive,
                icon: const Icon(Icons.lock_open_outlined, size: 18),
                label: Text(l10n.dlvWaiveButton),
              ),
            ),
        ],
      ),
    );
  }

  Widget _line(ThemeData theme, IconData icon, Color color, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
      ],
    ),
  );
}
