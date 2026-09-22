import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/features/dashboard/presentation/providers/dashboard_provider.dart';

/// UZS and USD are two parallel, never-summed ledgers (see `CLAUDE.md`) — this
/// toggle is how every dashboard screen switches which one is on display,
/// never blending them into one figure.
class CurrencyToggle extends ConsumerWidget {
  const CurrencyToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedDashboardCurrencyProvider);

    return SegmentedButton<Currency>(
      segments: const [
        ButtonSegment(value: Currency.uzs, label: Text('UZS')),
        ButtonSegment(value: Currency.usd, label: Text('USD')),
      ],
      selected: {selected},
      showSelectedIcon: false,
      onSelectionChanged: (value) =>
          ref.read(selectedDashboardCurrencyProvider.notifier).state = value.first,
    );
  }
}
