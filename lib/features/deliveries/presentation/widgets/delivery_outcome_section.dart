import 'package:flutter/material.dart';

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

  static String _distance(int meters) =>
      meters < 1000 ? '$meters m' : '${(meters / 1000).toStringAsFixed(1).replaceAll('.', ',')} km';

  Future<void> _waive() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kodsiz topshirishga ruxsat berilsinmi?'),
        content: const Text(
          'Kuryer buyurtmani mijoz kodisiz topshira oladi. Faqat mijoz bilan gaplashib, buyurtmani olganiga ishonch hosil qilsangiz ruxsat bering.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Yo'q")),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ruxsat berish')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    final result = await getIt<WaiveHandoverUseCase>().call(widget.delivery.id);
    if (!mounted) return;
    setState(() => _busy = false);
    result.fold(
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ruxsat berildi — kuryer kodsiz topshira oladi')),
        );
        widget.onChanged();
      },
      (failure) => DeliveryActions.showError(context, failure.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final d = widget.delivery;
    final h = d.handover;
    final lines = <Widget>[];

    if (d.status == DeliveryStatus.failed && d.failReason != null) {
      lines.add(_line(theme, Icons.report_outlined, theme.colorScheme.error, 'Sabab: ${d.failReason!.label}'));
      if (d.failNote?.isNotEmpty ?? false) {
        lines.add(_line(theme, Icons.notes, theme.colorScheme.outline, '"${d.failNote}"'));
      }
    }
    final distance = d.outcomeLocation?.distanceToDropoffMeters;
    if (distance != null && (d.status == DeliveryStatus.failed || d.status == DeliveryStatus.delivered)) {
      lines.add(_line(
        theme,
        Icons.place_outlined,
        distance > 300 ? theme.colorScheme.error : theme.colorScheme.outline,
        'Kuryer mijoz manzilidan ${_distance(distance)} uzoqlikda edi',
      ));
    }
    if (d.status == DeliveryStatus.cancelled && (d.cancelReason?.isNotEmpty ?? false)) {
      lines.add(_line(theme, Icons.info_outline, theme.colorScheme.outline, 'Bekor qilish sababi: ${d.cancelReason}'));
    }
    if (h.pending && d.status.isWithCourier) {
      lines.add(_line(
        theme,
        h.locked ? Icons.lock_outline : Icons.pin_outlined,
        h.locked ? theme.colorScheme.error : theme.colorScheme.tertiary,
        h.locked
            ? "Kod bloklandi: kuryer noto'g'ri kodni ko'p kiritdi"
            : 'Mijoz kodi kutilmoqda (${h.attemptsLeft} urinish qoldi)',
      ));
    } else if (h.required && h.waived) {
      lines.add(_line(theme, Icons.verified_outlined, theme.colorScheme.outline, 'Kodsiz topshirishga ruxsat berilgan'));
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
                label: const Text('Kodsiz topshirishga ruxsat'),
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
