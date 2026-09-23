import 'package:flutter/material.dart';

import 'package:bsmart/core/enums/sale_enums.dart';

class SaleStatusBadge extends StatelessWidget {
  const SaleStatusBadge({super.key, required this.status});

  final SaleStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (background, foreground) = switch (status) {
      SaleStatus.completed => (Colors.green.shade100, Colors.green.shade900),
      SaleStatus.cancelled => (scheme.errorContainer, scheme.onErrorContainer),
      SaleStatus.partiallyReturned => (Colors.orange.shade100, Colors.orange.shade900),
      SaleStatus.returned => (scheme.errorContainer, scheme.onErrorContainer),
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

class SaleTypeBadge extends StatelessWidget {
  const SaleTypeBadge({super.key, required this.type});

  final SaleType type;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (type) {
      SaleType.paid => (Colors.green.shade100, Colors.green.shade900),
      SaleType.debt => (Colors.orange.shade100, Colors.orange.shade900),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(6)),
      child: Text(
        type.label,
        style: TextStyle(color: foreground, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
