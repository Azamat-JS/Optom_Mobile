import 'package:flutter/material.dart';

import 'package:bsmart/core/l10n/l10n.dart';

/// "So'rovni rad etish" with an optional reason. Returns null when dismissed, otherwise the
/// (possibly empty) reason.
Future<String?> askRejectReason(BuildContext context) async {
  final l10n = context.l10n;
  final controller = TextEditingController();
  final result = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.ownerRejectTitle),
      content: TextField(
        controller: controller,
        maxLength: 300,
        autofocus: true,
        decoration: InputDecoration(labelText: l10n.ownerRejectReason),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.commonCancel)),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
          onPressed: () => Navigator.of(context).pop(controller.text.trim()),
          child: Text(l10n.ownerReject),
        ),
      ],
    ),
  );
  controller.dispose();
  return result;
}

/// A yes/no confirmation with a title and body (payment and return confirmations).
Future<bool> askOwnerConfirm(
  BuildContext context, {
  required String title,
  required String text,
  List<String> lines = const [],
}) async {
  final l10n = context.l10n;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text),
          for (final line in lines) ...[
            const SizedBox(height: 8),
            Text(line, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.commonCancel)),
        FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.ownerConfirm)),
      ],
    ),
  );
  return confirmed == true;
}

/// Reject (outlined, red) + Confirm (filled) pinned under a pending request.
class OwnerDecisionBar extends StatelessWidget {
  const OwnerDecisionBar({required this.onReject, required this.onConfirm, this.busy = false, super.key});

  final VoidCallback onReject;
  final VoidCallback onConfirm;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final error = Theme.of(context).colorScheme.error;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  foregroundColor: error,
                  side: BorderSide(color: error.withValues(alpha: 0.5)),
                ),
                onPressed: busy ? null : onReject,
                child: Text(l10n.ownerReject),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                onPressed: busy ? null : onConfirm,
                child: busy
                    ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                    : Text(l10n.ownerConfirm),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
