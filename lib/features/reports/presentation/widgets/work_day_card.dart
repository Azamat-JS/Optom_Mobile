import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/features/reports/domain/entities/work_day.dart';
import 'package:bsmart/features/reports/domain/usecases/export_debts_xlsx_usecase.dart';

/// "Ish kuni" (shift) card — start/end a trading shift, and download the
/// full outstanding-debts ledger as an Excel file at any time (not scoped to
/// a shift, see `work-day.service.ts`'s `getOutstandingDebtsExport` doc
/// comment). Mobile has no browser-download equivalent, so the exported
/// bytes are handed to `share_plus` (save/share sheet) rather than written
/// to a fixed path — matches the original plan's "stream bytes via Dio then
/// hand off via share_plus" note for Excel exports.
class WorkDayCard extends StatefulWidget {
  const WorkDayCard({super.key, required this.workDay, required this.onStart, required this.onEnd});

  final WorkDay? workDay;
  final VoidCallback onStart;
  final VoidCallback onEnd;

  @override
  State<WorkDayCard> createState() => _WorkDayCardState();
}

class _WorkDayCardState extends State<WorkDayCard> {
  bool _isExporting = false;
  static final _dateFormat = DateFormat('dd.MM.yyyy HH:mm');

  Future<void> _exportDebts() async {
    setState(() => _isExporting = true);
    final result = await getIt<ExportDebtsXlsxUseCase>().call();
    if (!mounted) return;
    setState(() => _isExporting = false);
    result.fold(
      (bytes) => Share.shareXFiles(
        [
          XFile.fromData(
            bytes,
            name: 'qarzlar.xlsx',
            mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          ),
        ],
        text: "Qarzlar ro'yxati",
      ),
      (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xatolik: ${failure.message}'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workDay = widget.workDay;
    final isOpen = workDay?.status == WorkDayStatus.open;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Ish kuni', style: Theme.of(context).textTheme.titleMedium),
                if (workDay != null)
                  Chip(
                    label: Text(isOpen ? 'Ochiq' : 'Yopilgan'),
                    visualDensity: VisualDensity.compact,
                    backgroundColor: isOpen
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (workDay == null)
              const Text('Hali ish kuni boshlanmagan')
            else ...[
              Text('Boshlangan: ${_dateFormat.format(workDay.startedAt.toLocal())}'),
              if (workDay.endedAt != null) Text('Tugagan: ${_dateFormat.format(workDay.endedAt!.toLocal())}'),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (!isOpen)
                  FilledButton.icon(
                    onPressed: widget.onStart,
                    icon: const Icon(Icons.play_arrow_outlined),
                    label: const Text('Ish kunini boshlash'),
                  )
                else
                  FilledButton.tonalIcon(
                    onPressed: widget.onEnd,
                    icon: const Icon(Icons.stop_circle_outlined),
                    label: const Text('Ish kunini yakunlash'),
                  ),
                OutlinedButton.icon(
                  onPressed: _isExporting ? null : _exportDebts,
                  icon: _isExporting
                      ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.download_outlined),
                  label: const Text('Qarzlar (Excel)'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
