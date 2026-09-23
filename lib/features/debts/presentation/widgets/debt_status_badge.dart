import 'package:flutter/material.dart';

import 'package:bsmart/core/enums/sale_enums.dart';

class DebtStatusBadge extends StatelessWidget {
  const DebtStatusBadge({super.key, required this.status});

  final DebtStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (background, foreground) = switch (status) {
      DebtStatus.active => (scheme.errorContainer, scheme.onErrorContainer),
      DebtStatus.partial => (Colors.orange.shade100, Colors.orange.shade900),
      DebtStatus.settled => (Colors.green.shade100, Colors.green.shade900),
      DebtStatus.overdue => (Colors.red.shade200, Colors.red.shade900),
      DebtStatus.writtenOff => (Colors.grey.shade300, Colors.grey.shade800),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(6)),
      child: Text(
        status.label,
        style: TextStyle(color: foreground, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
