import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
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
///
/// The bytes are written to a real temp file before sharing rather than
/// passed via `XFile.fromData(..., name: ...)` directly — `cross_file`'s own
/// IO-platform source states `name` is ignored there, and the file's name
/// is always derived from `path`; without a real `path`, `share_plus` had to
/// invent one (a random UUID), which is why the Android share sheet used to
/// show a UUID filename instead of `qarzlar.xlsx` despite `name:` being set.
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
    final shareText = context.l10n.workDayDebtsShareText;
    setState(() => _isExporting = true);
    final result = await getIt<ExportDebtsXlsxUseCase>().call();
    if (!mounted) return;
    setState(() => _isExporting = false);
    await result.fold(
      (bytes) async {
        final file = File('${Directory.systemTemp.path}/qarzlar.xlsx');
        await file.writeAsBytes(bytes);
        await Share.shareXFiles([
          XFile(file.path, mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'),
        ], text: shareText);
      },
      (failure) async {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.commonErrorWith(failure.message))));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final workDay = widget.workDay;
    final isOpen = workDay?.status == WorkDayStatus.open;
    final statusColor = isOpen ? AppColors.success : colors.textMuted;

    return DashCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.brandYellow.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(Icons.schedule_rounded, color: colors.accentText, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.workDayTitle,
                  style: TextStyle(color: colors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
              if (workDay != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isOpen ? l10n.workDayOpen : l10n.workDayClosed,
                        style: TextStyle(color: statusColor, fontSize: 13, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (workDay == null)
            Text(
              l10n.workDayNotStarted,
              style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w600),
            )
          else ...[
            Text(
              l10n.workDayStartedAt(_dateFormat.format(workDay.startedAt.toLocal())),
              style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w600),
            ),
            if (workDay.endedAt != null)
              Text(
                l10n.workDayEndedAt(_dateFormat.format(workDay.endedAt!.toLocal())),
                style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w600),
              ),
          ],
          const SizedBox(height: 16),
          if (!isOpen)
            FilledButton.icon(
              onPressed: widget.onStart,
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(l10n.workDayStart),
            )
          else
            FilledButton.icon(
              onPressed: widget.onEnd,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: AppColors.ink,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.stop_circle_rounded),
              label: Text(l10n.workDayEnd),
            ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _isExporting ? null : _exportDebts,
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            icon: _isExporting
                ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.download_rounded),
            label: Text(l10n.workDayExportDebts),
          ),
        ],
      ),
    );
  }
}
