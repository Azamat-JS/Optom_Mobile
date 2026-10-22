import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/realtime/tracking_socket.dart';

import 'package:bsmart/features/deliveries/domain/entities/delivery.dart';
import 'package:bsmart/features/deliveries/presentation/providers/delivery_detail_notifier.dart';

/// Courier's "Topshirdim" when the customer's handover code is required (Phase 7 N2).
///
/// Watches the delivery itself, so attempts left / locked come straight from the server after each
/// try, and a staff waiver (`delivery:handover`) turns the prompt into a plain confirm. Pops `true`
/// once the delivery is completed.
class HandoverCodeSheet extends ConsumerStatefulWidget {
  const HandoverCodeSheet({super.key, required this.deliveryId});

  final String deliveryId;

  static Future<bool> show(BuildContext context, String deliveryId) async {
    final done = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => HandoverCodeSheet(deliveryId: deliveryId),
    );
    return done == true;
  }

  @override
  ConsumerState<HandoverCodeSheet> createState() => _HandoverCodeSheetState();
}

class _HandoverCodeSheetState extends ConsumerState<HandoverCodeSheet> {
  final _code = TextEditingController();
  final _socket = getIt<TrackingSocket>();
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    // The courier may be offline (socket closed): hold it while the sheet is open so a staff
    // waiver (`delivery:handover`) arrives live, and start from fresh server state.
    _socket.hold(this);
    Future.microtask(() => ref.read(deliveryDetailProvider(widget.deliveryId).notifier).refresh());
  }

  @override
  void dispose() {
    _socket.release(this);
    _code.dispose();
    super.dispose();
  }

  Future<void> _recheck() async {
    setState(() => _busy = true);
    await ref.read(deliveryDetailProvider(widget.deliveryId).notifier).refresh();
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _submit({required bool withCode}) async {
    if (withCode && _code.text.length != 4) {
      setState(() => _error = context.l10n.dlvCodeFourDigits);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final failure = await ref
        .read(deliveryDetailProvider(widget.deliveryId).notifier)
        .complete(code: withCode ? _code.text : null);
    if (!mounted) return;
    if (failure == null) {
      Navigator.of(context).pop(true);
      return;
    }
    _code.clear();
    setState(() {
      _busy = false;
      _error = failure.message;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final d = ref.watch(deliveryDetailProvider(widget.deliveryId)).valueOrNull;
    final handover = d?.handover ?? DeliveryHandover.none;
    final waived = d != null && !handover.pending;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            handover.locked ? Icons.lock_outline : (waived ? Icons.verified_outlined : Icons.pin_outlined),
            size: 40,
            color: handover.locked ? theme.colorScheme.error : theme.colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            handover.locked
                ? context.l10n.dlvCodeLocked
                : (waived ? context.l10n.dlvWaivedTitle : context.l10n.dlvHandoverCode),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            handover.locked
                ? context.l10n.dlvTooManyTries
                : (waived ? context.l10n.dlvConfirmHandedOver : context.l10n.dlvAskCodeLong),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          if (!handover.locked && !waived) ...[
            const SizedBox(height: 20),
            TextField(
              controller: _code,
              autofocus: true,
              enabled: !_busy,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 4,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: theme.textTheme.headlineMedium?.copyWith(letterSpacing: 16, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                counterText: '',
                hintText: '••••',
                errorText: _error,
                helperText: context.l10n.dlvAttemptsLeft(handover.attemptsLeft),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _submit(withCode: true),
            ),
          ] else if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ],
          const SizedBox(height: 16),
          if (handover.locked) ...[
            FilledButton.tonalIcon(
              onPressed: _busy ? null : _recheck,
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.dlvRecheck),
            ),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: () => Navigator.of(context).pop(false), child: Text(context.l10n.commonClose)),
          ] else
            FilledButton.icon(
              onPressed: _busy ? null : () => _submit(withCode: !waived),
              icon: _busy
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.task_alt),
              label: Text(waived ? context.l10n.dlvYesHandedOver : context.l10n.commonConfirm),
            ),
        ],
      ),
    );
  }
}

/// "Yetkazib bo'lmadi" — reason (+ note, required for "Boshqa sabab"). Returns null if dismissed.
class FailDeliverySheet extends StatefulWidget {
  const FailDeliverySheet({super.key});

  static Future<(DeliveryFailReason, String?)?> show(BuildContext context) =>
      showModalBottomSheet<(DeliveryFailReason, String?)>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => const FailDeliverySheet(),
      );

  @override
  State<FailDeliverySheet> createState() => _FailDeliverySheetState();
}

class _FailDeliverySheetState extends State<FailDeliverySheet> {
  DeliveryFailReason? _reason;
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  bool get _valid => _reason != null && (_reason != DeliveryFailReason.other || _note.text.trim().isNotEmpty);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(context.l10n.dlvWhyFailed, style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(context.l10n.dlvFailNotice, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          RadioGroup<DeliveryFailReason>(
            groupValue: _reason,
            onChanged: (r) => setState(() => _reason = r),
            child: Column(
              children: [
                for (final r in DeliveryFailReason.values)
                  RadioListTile<DeliveryFailReason>(value: r, title: Text(r.label), contentPadding: EdgeInsets.zero),
              ],
            ),
          ),
          TextField(
            controller: _note,
            maxLength: 300,
            maxLines: 2,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: _reason == DeliveryFailReason.other
                  ? context.l10n.dlvNoteRequired
                  : context.l10n.commonNoteOptional,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.error),
            onPressed: _valid ? () => Navigator.of(context).pop((_reason!, _note.text.trim())) : null,
            icon: const Icon(Icons.report_outlined),
            label: Text(context.l10n.dlvFailed),
          ),
        ],
      ),
    );
  }
}
